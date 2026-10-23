import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../../backup/application/backup_service.dart';
import '../../backup/domain/backup.dart';
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';

final class DriftSyncOnboardingStore implements SyncOnboardingLocalStore {
  DriftSyncOnboardingStore({
    required this.db,
    required this.backup,
    this.clock = const SystemClock(),
    IdGenerator? ids,
  }) : ids = ids ?? SecureUuidV4Generator();

  final LedgerDatabase db;
  final BackupService backup;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<Result<SyncLedgerSummary>> summarizeLocal() async {
    try {
      final profile = await db.select(db.localProfiles).getSingleOrNull();
      final accounts = await _count('accounts');
      final transactions = await _count(
        'bookkeeping_transactions',
        where: 'deleted_at_utc IS NULL',
      );
      final receipts = await _count('receipt_attachments');
      final otherRecords =
          await _count('categories') +
          await _count('projects') +
          await _count('budgets') +
          await _count('transfers', where: 'deleted_at_utc IS NULL');
      final latest = await db
          .customSelect(
            'SELECT max(business_date) AS latest FROM ('
            'SELECT business_date FROM bookkeeping_transactions '
            'WHERE deleted_at_utc IS NULL UNION ALL '
            'SELECT business_date FROM transfers WHERE deleted_at_utc IS NULL)',
          )
          .getSingle();
      return Success(
        SyncLedgerSummary(
          accounts: accounts,
          transactions: transactions,
          receipts: receipts,
          otherRecords: otherRecords,
          baseCurrencyCode: profile?.baseCurrencyCode,
          latestActivityDate: latest.read<String?>('latest'),
        ),
      );
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  Future<int> _count(String table, {String? where}) async {
    final row = await db
        .customSelect(
          'SELECT count(*) AS value FROM $table'
          '${where == null ? '' : ' WHERE $where'}',
        )
        .getSingle();
    return row.read<int>('value');
  }

  @override
  Future<Result<SyncDurableState>> readDurableState() async {
    try {
      final link = await db.select(db.syncLinkStates).getSingle();
      final row = await db
          .customSelect('SELECT * FROM sync_onboarding_state WHERE slot=1')
          .getSingle();
      final pending = await _count('sync_outbox');
      final conflicts = await _count(
        'sync_conflicts',
        where: "status='unresolved'",
      );
      final last = row.read<int?>('last_successful_sync_at_utc');
      return Success(
        SyncDurableState(
          linkedAccountId: link.cloudAccountId,
          generation: row.read<String?>('dataset_generation'),
          operationId: row.read<String?>('initialization_operation_id'),
          stage: SyncOnboardingStage.values.byName(row.read<String>('stage')),
          syncEnabled: link.syncEnabled,
          needsReconciliation: link.needsReconciliation,
          paused: row.read<int>('paused') == 1,
          pendingChanges: pending,
          unresolvedConflicts: conflicts,
          lastSuccessfulSyncAtUtc: last == null
              ? null
              : DateTime.fromMicrosecondsSinceEpoch(last, isUtc: true),
        ),
      );
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<String>> beginOnboarding(SyncOnboardingStage stage) async {
    try {
      final current = await db
          .customSelect(
            'SELECT initialization_operation_id, stage FROM '
            'sync_onboarding_state WHERE slot=1',
          )
          .getSingle();
      final existing = current.read<String?>('initialization_operation_id');
      final currentStage = current.read<String>('stage');
      if (existing != null && currentStage != stage.name) {
        return const Failure(FailureCode.syncInitializationInProgress);
      }
      final operationId = existing ?? ids.generate().value;
      await db.customStatement(
        'UPDATE sync_onboarding_state SET stage=?, '
        'initialization_operation_id=?, updated_at_utc=? WHERE slot=1',
        [stage.name, operationId, clock.nowUtc().microsecondsSinceEpoch],
      );
      return Success(operationId);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> bindInitialization({
    required String accountId,
    required String generation,
  }) async {
    try {
      final now = clock.nowUtc().microsecondsSinceEpoch;
      await db.transaction(() async {
        await (db.update(
          db.syncLinkStates,
        )..where((row) => row.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            cloudAccountId: Value(accountId),
            state: const Value('linked'),
            syncEnabled: const Value(false),
            needsReconciliation: const Value(false),
            updatedAtUtc: Value(now),
          ),
        );
        await db.customStatement(
          'UPDATE sync_onboarding_state SET dataset_generation=?, '
          'updated_at_utc=? WHERE slot=1',
          [generation, now],
        );
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<List<SyncInitialEntity>>> readInitialEntities() async {
    try {
      return await db.transaction(() async {
        final saved = await db
            .customSelect(
              'SELECT entity_type,entity_id,payload_json '
              'FROM sync_initialization_entities ORDER BY ordinal',
            )
            .get();
        if (saved.isNotEmpty) {
          return Success(
            saved
                .map(
                  (row) => SyncInitialEntity(
                    entityType: _parseEntity(row.read<String>('entity_type')),
                    entityId: row.read<String>('entity_id'),
                    payload: Map<String, Object?>.from(
                      jsonDecode(row.read<String>('payload_json')) as Map,
                    ),
                  ),
                )
                .toList(growable: false),
          );
        }
        String iso(int value) => DateTime.fromMicrosecondsSinceEpoch(
          value,
          isUtc: true,
        ).toIso8601String();
        final values = <SyncInitialEntity>[];
        final profile = await db.select(db.localProfiles).getSingle();
        values.add(
          SyncInitialEntity(
            entityType: SyncEntityType.profile,
            entityId: profile.id,
            payload: {
              'base_currency_code': profile.baseCurrencyCode,
              'created_at': iso(profile.createdAtUtc),
              'updated_at': iso(profile.updatedAtUtc),
            },
          ),
        );
        for (final row in await db.select(db.accounts).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.account,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'name': row.name,
                'kind': row.kind,
                'currency_code': row.currencyCode,
                'opening_minor_units': row.openingMinorUnits,
                'opening_date': row.openingDate,
                'is_archived': row.isArchived,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
              },
            ),
          );
        }
        for (final row in await db.select(db.categories).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.category,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'name': row.name,
                'kind': row.kind,
                'is_archived': row.isArchived,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
              },
            ),
          );
        }
        for (final row in await db.select(db.projects).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.project,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'name': row.name,
                'description': row.description,
                'is_archived': row.isArchived,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
              },
            ),
          );
        }
        for (final row in await db.select(db.budgets).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.budget,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'name': row.name,
                'amount_minor_units': row.amountMinorUnits,
                'currency_code': row.currencyCode,
                'month': row.month,
                'category_id': row.categoryId,
                'warning_threshold_percent': row.warningThresholdPercent,
                'is_archived': row.isArchived,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
              },
            ),
          );
        }
        for (final row in await db.select(db.bookkeepingTransactions).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.transaction,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'account_id': row.accountId,
                'category_id': row.categoryId,
                'project_id': row.projectId,
                'kind': row.kind,
                'amount_minor_units': row.amountMinorUnits,
                'currency_code': row.currencyCode,
                'business_date': row.businessDate,
                'note': row.note,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
                'deleted_at': row.deletedAtUtc == null
                    ? null
                    : iso(row.deletedAtUtc!),
              },
            ),
          );
        }
        for (final row in await db.select(db.transfers).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.transfer,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'source_account_id': row.sourceAccountId,
                'destination_account_id': row.destinationAccountId,
                'source_minor_units': row.sourceMinorUnits,
                'source_currency_code': row.sourceCurrencyCode,
                'destination_minor_units': row.destinationMinorUnits,
                'destination_currency_code': row.destinationCurrencyCode,
                'business_date': row.businessDate,
                'note': row.note,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.updatedAtUtc),
                'deleted_at': row.deletedAtUtc == null
                    ? null
                    : iso(row.deletedAtUtc!),
              },
            ),
          );
        }
        for (final row in await db.select(db.receiptAttachments).get()) {
          values.add(
            SyncInitialEntity(
              entityType: SyncEntityType.receiptAttachment,
              entityId: row.id,
              payload: {
                'profile_id': row.profileId,
                'transaction_id': row.transactionId,
                'storage_key': row.storageKey,
                'mime_type': row.mimeType,
                'byte_size': row.byteSize,
                'sha256_hex': row.sha256Hex,
                'position': row.position,
                'created_at': iso(row.createdAtUtc),
                'updated_at': iso(row.createdAtUtc),
                'deleted_at': null,
              },
            ),
          );
        }
        for (final value in values) {
          await db.customStatement(
            'INSERT INTO sync_initialization_entities '
            '(entity_type,entity_id,payload_json) VALUES (?,?,?)',
            [
              _entityName(value.entityType),
              value.entityId,
              jsonEncode(value.payload),
            ],
          );
        }
        return Success(List.unmodifiable(values));
      });
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> activate({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntityResult> entityStates,
  }) async {
    try {
      final now = clock.nowUtc().microsecondsSinceEpoch;
      await db.transaction(() async {
        await db.delete(db.syncEntityStates).go();
        for (final state in entityStates) {
          await db
              .into(db.syncEntityStates)
              .insert(
                SyncEntityStatesCompanion.insert(
                  entityType: _entityName(state.entityType),
                  entityId: state.entityId,
                  serverVersion: state.serverVersion,
                  serverRevision: state.serverRevision,
                ),
              );
        }
        await (db.update(db.syncCursors)..where((row) => row.slot.equals(1)))
            .write(SyncCursorsCompanion(lastAppliedSequence: Value(cursor)));
        await (db.update(
          db.syncLinkStates,
        )..where((row) => row.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            cloudAccountId: Value(accountId),
            state: const Value('linked'),
            syncEnabled: const Value(true),
            needsReconciliation: const Value(false),
            updatedAtUtc: Value(now),
          ),
        );
        await db.customStatement(
          'UPDATE sync_onboarding_state SET dataset_generation=?, '
          "stage='active', initialization_operation_id=NULL, paused=0, "
          'last_successful_sync_at_utc=NULL, updated_at_utc=? WHERE slot=1',
          [generation, now],
        );
        await db.customStatement('DELETE FROM sync_initialization_entities');
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> replaceWithCloudSnapshot({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntity> entities,
    required Map<String, List<int>> receiptBytes,
  }) async {
    try {
      final logical = _logicalSnapshot(entities);
      final profile =
          (logical['localProfiles'] as List).single as Map<String, dynamic>;
      final manifest = BackupManifest(
        createdAtUtc: clock.nowUtc(),
        appVersion: '0.1.0+1',
        sourcePlatform: Platform.operatingSystem,
        sourceSchemaVersion: db.schemaVersion,
        profileId: profile['id'] as String,
        baseCurrencyCode: profile['baseCurrencyCode'] as String,
        entityCounts: {
          for (final key in [
            'accounts',
            'categories',
            'projects',
            'budgets',
            'transactions',
            'transfers',
          ])
            key: (logical[key] as List).length,
        },
        attachmentCount: receiptBytes.length,
      );
      final restored = await backup.restore(
        PreparedRestore(
          preview: RestorePreview(manifest: manifest, encryptedBytes: 0),
          ledgerData: logical,
          receiptFiles: receiptBytes,
        ),
      );
      if (restored is Failure<void>) return Failure(restored.code);
      final states = entities
          .map(
            (entity) => SyncInitialEntityResult(
              entityType: entity.entityType,
              entityId: entity.entityId,
              serverVersion: entity.payload['server_version'] as int,
              serverRevision: entity.payload['server_revision'] as int,
            ),
          )
          .toList(growable: false);
      return await activate(
        accountId: accountId,
        generation: generation,
        cursor: cursor,
        entityStates: states,
      );
    } on Object {
      return const Failure(FailureCode.syncInvalidRemoteData);
    }
  }

  @override
  Future<Result<void>> failOnboarding() async {
    try {
      await db.customStatement(
        'UPDATE sync_onboarding_state SET paused=0, '
        'updated_at_utc=? WHERE slot=1',
        [clock.nowUtc().microsecondsSinceEpoch],
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> setPaused(bool paused) async {
    try {
      await db.customStatement(
        'UPDATE sync_onboarding_state SET paused=?, updated_at_utc=? '
        'WHERE slot=1',
        [paused ? 1 : 0, clock.nowUtc().microsecondsSinceEpoch],
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> requireReconciliation() async {
    try {
      final now = clock.nowUtc().microsecondsSinceEpoch;
      await db.transaction(() async {
        await (db.update(
          db.syncLinkStates,
        )..where((row) => row.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            syncEnabled: const Value(false),
            needsReconciliation: const Value(true),
            state: const Value('needsReconciliation'),
            updatedAtUtc: Value(now),
          ),
        );
        await db.customStatement(
          "UPDATE sync_onboarding_state SET stage='reconciling', paused=0, "
          'updated_at_utc=? WHERE slot=1',
          [now],
        );
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> unlink() async {
    try {
      final now = clock.nowUtc().microsecondsSinceEpoch;
      await db.transaction(() async {
        await db.delete(db.syncOutbox).go();
        await db.delete(db.syncEntityStates).go();
        await db.delete(db.syncConflicts).go();
        await db.delete(db.syncReceiptSpoolEntries).go();
        await db.delete(db.syncAttachmentCleanup).go();
        await db.customStatement('DELETE FROM sync_initialization_entities');
        await (db.update(db.syncCursors)..where((row) => row.slot.equals(1)))
            .write(const SyncCursorsCompanion(lastAppliedSequence: Value(0)));
        await (db.update(
          db.syncLinkStates,
        )..where((row) => row.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            cloudAccountId: const Value(null),
            state: const Value('unlinked'),
            syncEnabled: const Value(false),
            needsReconciliation: const Value(false),
            updatedAtUtc: Value(now),
          ),
        );
        await db.customStatement(
          'UPDATE sync_onboarding_state SET dataset_generation=NULL, '
          "stage='idle', initialization_operation_id=NULL, paused=0, "
          'last_successful_sync_at_utc=NULL, updated_at_utc=? WHERE slot=1',
          [now],
        );
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  Map<String, dynamic> _logicalSnapshot(List<SyncInitialEntity> entities) {
    final grouped = <SyncEntityType, List<Map<String, dynamic>>>{
      for (final type in SyncEntityType.values) type: [],
    };
    int micros(Object? value) =>
        DateTime.parse(value! as String).toUtc().microsecondsSinceEpoch;
    for (final entity in entities) {
      final p = entity.payload;
      if (entity.entityType == SyncEntityType.receiptAttachment &&
          p['deleted_at'] != null) {
        continue;
      }
      final common = <String, dynamic>{'id': entity.entityId};
      switch (entity.entityType) {
        case SyncEntityType.profile:
          grouped[entity.entityType]!.add({
            ...common,
            'slot': 1,
            'baseCurrencyCode': p['base_currency_code'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
          });
        case SyncEntityType.account:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'name': p['name'],
            'kind': p['kind'],
            'currencyCode': p['currency_code'],
            'openingMinorUnits': p['opening_minor_units'],
            'openingDate': p['opening_date'],
            'isArchived': p['is_archived'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
          });
        case SyncEntityType.category:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'name': p['name'],
            'kind': p['kind'],
            'isArchived': p['is_archived'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
          });
        case SyncEntityType.project:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'name': p['name'],
            'description': p['description'],
            'isArchived': p['is_archived'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
          });
        case SyncEntityType.budget:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'name': p['name'],
            'amountMinorUnits': p['amount_minor_units'],
            'currencyCode': p['currency_code'],
            'month': p['month'],
            'categoryId': p['category_id'],
            'warningThresholdPercent': p['warning_threshold_percent'],
            'isArchived': p['is_archived'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
          });
        case SyncEntityType.transaction:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'accountId': p['account_id'],
            'categoryId': p['category_id'],
            'projectId': p['project_id'],
            'kind': p['kind'],
            'amountMinorUnits': p['amount_minor_units'],
            'currencyCode': p['currency_code'],
            'businessDate': p['business_date'],
            'note': p['note'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
            'deletedAtUtc': p['deleted_at'] == null
                ? null
                : micros(p['deleted_at']),
          });
        case SyncEntityType.transfer:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'sourceAccountId': p['source_account_id'],
            'destinationAccountId': p['destination_account_id'],
            'sourceMinorUnits': p['source_minor_units'],
            'sourceCurrencyCode': p['source_currency_code'],
            'destinationMinorUnits': p['destination_minor_units'],
            'destinationCurrencyCode': p['destination_currency_code'],
            'businessDate': p['business_date'],
            'note': p['note'],
            'createdAtUtc': micros(p['created_at']),
            'updatedAtUtc': micros(p['updated_at']),
            'deletedAtUtc': p['deleted_at'] == null
                ? null
                : micros(p['deleted_at']),
          });
        case SyncEntityType.receiptAttachment:
          grouped[entity.entityType]!.add({
            ...common,
            'profileId': p['profile_id'],
            'transactionId': p['transaction_id'],
            'storageKey': '${entity.entityId}.jpg',
            'mimeType': p['mime_type'],
            'byteSize': p['byte_size'],
            'sha256Hex': p['sha256_hex'],
            'position': p['position'],
            'createdAtUtc': micros(p['created_at']),
          });
      }
    }
    return {
      'logicalSchemaVersion': 1,
      'sourceDriftSchemaVersion': db.schemaVersion,
      'localProfiles': grouped[SyncEntityType.profile],
      'accounts': grouped[SyncEntityType.account],
      'categories': grouped[SyncEntityType.category],
      'projects': grouped[SyncEntityType.project],
      'budgets': grouped[SyncEntityType.budget],
      'transactions': grouped[SyncEntityType.transaction],
      'transfers': grouped[SyncEntityType.transfer],
      'receiptAttachments': grouped[SyncEntityType.receiptAttachment],
    };
  }

  static String _entityName(SyncEntityType type) =>
      type == SyncEntityType.receiptAttachment
      ? 'receipt_attachment'
      : type.name;

  static SyncEntityType _parseEntity(String value) =>
      value == 'receipt_attachment'
      ? SyncEntityType.receiptAttachment
      : SyncEntityType.values.byName(value);
}
