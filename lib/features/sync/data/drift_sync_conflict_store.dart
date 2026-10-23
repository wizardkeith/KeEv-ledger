import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';

final class DriftSyncConflictStore implements SyncConflictLocalStore {
  DriftSyncConflictStore({
    required this.db,
    required this.runtime,
    this.clock = const SystemClock(),
    IdGenerator? ids,
  }) : ids = ids ?? SecureUuidV4Generator();

  final LedgerDatabase db;
  final SyncRuntimeLocalStore runtime;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<Result<List<SyncConflictItem>>> unresolvedConflicts() async {
    try {
      final rows =
          await (db.select(db.syncConflicts)
                ..where((row) => row.status.equals('unresolved'))
                ..orderBy([(row) => OrderingTerm.asc(row.detectedAtUtc)]))
              .get();
      return Success(rows.map(_item).toList(growable: false));
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  @override
  Future<Result<void>> keepLocal({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
    required String generation,
  }) async {
    if (!_same(conflict, currentRemote) || generation.isEmpty) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    try {
      final current = await _currentLocalCandidate(conflict);
      if (current == null) {
        return const Failure(FailureCode.syncLocalStoreFailure);
      }
      if (conflict.entityType == SyncEntityType.receiptAttachment &&
          current.operation != SyncOperation.delete) {
        final spool =
            await (db.select(db.syncReceiptSpoolEntries)
                  ..where((row) => row.attachmentId.equals(conflict.entityId)))
                .getSingleOrNull();
        if (spool == null) {
          return const Failure(FailureCode.syncAttachmentIntegrityFailure);
        }
      }
      await db.transaction(() async {
        await (db.delete(db.syncOutbox)..where(
              (row) =>
                  row.entityType.equals(_entityName(conflict.entityType)) &
                  row.entityId.equals(conflict.entityId),
            ))
            .go();
        await db
            .into(db.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                mutationId: ids.generate().value,
                entityType: _entityName(conflict.entityType),
                entityId: conflict.entityId,
                operation: current.operation.name,
                baseServerVersion: Value(currentRemote.serverVersion),
                payloadJson: jsonEncode({
                  ...current.payload,
                  '_conflict_resolution': true,
                }),
                createdAtUtc: clock.nowUtc().microsecondsSinceEpoch,
              ),
            );
        await (db.update(db.syncConflicts)
              ..where((row) => row.id.equals(conflict.id)))
            .write(const SyncConflictsCompanion(status: Value('resolved')));
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
  }

  Future<({SyncOperation operation, Map<String, Object?> payload})?>
  _currentLocalCandidate(SyncConflictItem conflict) async {
    String iso(int value) => DateTime.fromMicrosecondsSinceEpoch(
      value,
      isUtc: true,
    ).toIso8601String();
    final id = conflict.entityId;
    switch (conflict.entityType) {
      case SyncEntityType.profile:
        final row = await (db.select(
          db.localProfiles,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        return (
          operation: SyncOperation.update,
          payload: {
            'base_currency_code': row.baseCurrencyCode,
            'created_at': iso(row.createdAtUtc),
            'updated_at': iso(row.updatedAtUtc),
          },
        );
      case SyncEntityType.account:
        final row = await (db.select(
          db.accounts,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        return (
          operation: SyncOperation.update,
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
        );
      case SyncEntityType.category:
        final row = await (db.select(
          db.categories,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        return (
          operation: SyncOperation.update,
          payload: {
            'profile_id': row.profileId,
            'name': row.name,
            'kind': row.kind,
            'is_archived': row.isArchived,
            'created_at': iso(row.createdAtUtc),
            'updated_at': iso(row.updatedAtUtc),
          },
        );
      case SyncEntityType.project:
        final row = await (db.select(
          db.projects,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        return (
          operation: SyncOperation.update,
          payload: {
            'profile_id': row.profileId,
            'name': row.name,
            'description': row.description,
            'is_archived': row.isArchived,
            'created_at': iso(row.createdAtUtc),
            'updated_at': iso(row.updatedAtUtc),
          },
        );
      case SyncEntityType.budget:
        final row = await (db.select(
          db.budgets,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        return (
          operation: SyncOperation.update,
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
        );
      case SyncEntityType.transaction:
        final row = await (db.select(
          db.bookkeepingTransactions,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return _currentDeletionPayload(conflict);
        final payload = <String, Object?>{
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
        };
        return (
          operation: row.deletedAtUtc == null
              ? SyncOperation.update
              : SyncOperation.delete,
          payload: payload,
        );
      case SyncEntityType.transfer:
        final row = await (db.select(
          db.transfers,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return _currentDeletionPayload(conflict);
        final payload = <String, Object?>{
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
        };
        return (
          operation: row.deletedAtUtc == null
              ? SyncOperation.update
              : SyncOperation.delete,
          payload: payload,
        );
      case SyncEntityType.receiptAttachment:
        final row = await (db.select(
          db.receiptAttachments,
        )..where((row) => row.id.equals(id))).getSingleOrNull();
        if (row == null) return _currentDeletionPayload(conflict);
        final link = await db.select(db.syncLinkStates).getSingle();
        final account = link.cloudAccountId;
        if (account == null) return null;
        return (
          operation: SyncOperation.update,
          payload: {
            'profile_id': row.profileId,
            'transaction_id': row.transactionId,
            'storage_key': row.storageKey,
            'storage_path': '$account/receipts/${row.id}/${row.sha256Hex}.jpg',
            'mime_type': row.mimeType,
            'byte_size': row.byteSize,
            'sha256_hex': row.sha256Hex,
            'position': row.position,
            'created_at': iso(row.createdAtUtc),
            'updated_at': iso(row.createdAtUtc),
            'deleted_at': null,
          },
        );
    }
  }

  Future<({SyncOperation operation, Map<String, Object?> payload})?>
  _currentDeletionPayload(SyncConflictItem conflict) async {
    final latest =
        await (db.select(db.syncOutbox)
              ..where(
                (row) =>
                    row.entityType.equals(_entityName(conflict.entityType)) &
                    row.entityId.equals(conflict.entityId),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.queueSequence)])
              ..limit(1))
            .getSingleOrNull();
    if (latest == null || latest.operation != SyncOperation.delete.name) {
      return null;
    }
    return (
      operation: SyncOperation.delete,
      payload: Map<String, Object?>.from(jsonDecode(latest.payloadJson) as Map),
    );
  }

  @override
  Future<Result<void>> keepCloud({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
  }) => runtime.resolveConflictKeepCloud(
    conflict: conflict,
    currentRemote: currentRemote,
  );

  SyncConflictItem _item(SyncConflict row) {
    final local = Map<String, Object?>.from(
      jsonDecode(row.localCandidateJson) as Map,
    );
    final remote = Map<String, Object?>.from(
      jsonDecode(row.remoteCandidateJson) as Map,
    );
    return SyncConflictItem(
      id: row.id,
      entityType: _parseEntity(row.entityType),
      entityId: row.entityId,
      localBaseVersion: row.baseServerVersion,
      remoteVersion: row.remoteServerVersion,
      remoteRevision: row.remoteServerRevision,
      localCandidate: local,
      remoteCandidate: remote,
      localDeleted:
          local['deleted_at'] != null ||
          local['_delete_intent'] == true ||
          local['_local_operation'] == 'delete',
      remoteDeleted: remote['deleted_at'] != null,
    );
  }

  static bool _same(SyncConflictItem conflict, SyncCanonicalEntity remote) =>
      conflict.entityType == remote.entityType &&
      conflict.entityId == remote.id;

  static String _entityName(SyncEntityType type) =>
      type == SyncEntityType.receiptAttachment
      ? 'receipt_attachment'
      : type.name;

  static SyncEntityType _parseEntity(String value) =>
      value == 'receipt_attachment'
      ? SyncEntityType.receiptAttachment
      : SyncEntityType.values.byName(value);
}
