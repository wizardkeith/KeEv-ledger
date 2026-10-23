import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/sync/application/sync_contracts.dart';
import 'package:ledger/features/sync/application/sync_onboarding_service.dart';
import 'package:ledger/features/sync/application/sync_receipt_spool.dart';
import 'package:ledger/features/sync/data/drift_sync_conflict_store.dart';
import 'package:ledger/features/sync/data/drift_sync_mutation_capture.dart';
import 'package:ledger/features/sync/data/drift_sync_state_store.dart';
import 'package:ledger/features/sync/domain/sync_protocol.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart';

import '../generated_migrations/ledger_database/generated/schema_v7.dart' as v7;

const accountId = '10000000-0000-4000-8000-000000000001';
const deviceId = '20000000-0000-4000-8000-000000000001';
const generation = '30000000-0000-4000-8000-000000000001';
const operationId = '40000000-0000-4000-8000-000000000001';

void main() {
  test('discovery classifies all four cases without modification', () async {
    for (final item in <(bool, bool, SyncDiscoveryCase)>[
      (false, false, SyncDiscoveryCase.bothEmpty),
      (true, false, SyncDiscoveryCase.localOnly),
      (false, true, SyncDiscoveryCase.cloudOnly),
      (true, true, SyncDiscoveryCase.bothHaveData),
    ]) {
      final local = _Local(hasData: item.$1);
      final remote = _Remote(hasData: item.$2);
      final service = _service(local, remote);
      final result = await service.discover();
      expect((result as Success<SyncDiscovery>).value.classification, item.$3);
      expect(local.beginCount, 0);
      expect(remote.beginCount, 0);
    }
  });

  test(
    'both empty explicitly initializes generation without ledger rows',
    () async {
      final local = _Local(hasData: false);
      final remote = _Remote(hasData: false);
      final service = _service(local, remote);
      final discovery =
          (await service.discover() as Success<SyncDiscovery>).value;
      expect(
        await service.confirm(
          accountId: accountId,
          discovery: discovery,
          choice: SyncOnboardingChoice.enableEmpty,
        ),
        isA<Success<void>>(),
      );
      expect(remote.uploaded, isEmpty);
      expect(local.activatedGeneration, generation);
      expect(remote.acknowledgedRevision, 0);
      expect(remote.acknowledgedDevice, deviceId);
    },
  );

  test(
    'local to cloud uses dependency order and activates after finalize',
    () async {
      final local = _Local(hasData: true)
        ..initial = const [
          SyncInitialEntity(
            entityType: SyncEntityType.profile,
            entityId: '50000000-0000-4000-8000-000000000001',
            payload: {'base_currency_code': 'HKD'},
          ),
          SyncInitialEntity(
            entityType: SyncEntityType.account,
            entityId: '50000000-0000-4000-8000-000000000002',
            payload: {'profile_id': '50000000-0000-4000-8000-000000000001'},
          ),
          SyncInitialEntity(
            entityType: SyncEntityType.transaction,
            entityId: '50000000-0000-4000-8000-000000000003',
            payload: {'account_id': '50000000-0000-4000-8000-000000000002'},
          ),
        ];
      final remote = _Remote(hasData: false);
      final service = _service(local, remote);
      final discovery =
          (await service.discover() as Success<SyncDiscovery>).value;
      await service.confirm(
        accountId: accountId,
        discovery: discovery,
        choice: SyncOnboardingChoice.keepLocal,
      );
      expect(remote.uploaded, [
        SyncEntityType.profile,
        SyncEntityType.account,
        SyncEntityType.transaction,
      ]);
      expect(local.activatedCursor, 3);
      expect(remote.acknowledgedRevision, 3);
    },
  );

  test('both-side cancel leaves both datasets untouched', () async {
    final local = _Local(hasData: true);
    final remote = _Remote(hasData: true);
    final service = _service(local, remote);
    final discovery =
        (await service.discover() as Success<SyncDiscovery>).value;
    await service.confirm(
      accountId: accountId,
      discovery: discovery,
      choice: SyncOnboardingChoice.cancel,
    );
    expect(local.beginCount, 0);
    expect(remote.beginCount, 0);
  });

  test(
    'provider-neutral online device unlink reaches the remote contract',
    () async {
      final local = _Local(hasData: false);
      final remote = _Remote(hasData: false);
      final result = await _service(local, remote).unlinkDevice(generation);
      expect(result, isA<Success<void>>());
      expect(remote.unlinkCalls, 1);
    },
  );

  test(
    'registration failure preserves finalized local activation for retry',
    () async {
      final local = _Local(hasData: false);
      final remote = _Remote(
        hasData: false,
        ackFailure: FailureCode.syncNetworkUnavailable,
      );
      final service = _service(local, remote);
      final discovery =
          (await service.discover() as Success<SyncDiscovery>).value;
      final result = await service.confirm(
        accountId: accountId,
        discovery: discovery,
        choice: SyncOnboardingChoice.enableEmpty,
      );
      expect(result, isA<Failure<void>>());
      expect(local.activatedGeneration, generation);
      expect(local.failCount, 0);
    },
  );

  test('v8 seeds onboarding state and does not invent a generation', () async {
    final db = LedgerDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final row = await db
        .customSelect(
          'SELECT dataset_generation,stage,paused FROM sync_onboarding_state',
        )
        .getSingle();
    expect(row.read<String?>('dataset_generation'), isNull);
    expect(row.read<String>('stage'), 'idle');
    expect(row.read<int>('paused'), 0);
    expect(db.schemaVersion, 8);
  });

  test(
    'v7 linked state migrates to reconciliation without fake generation',
    () async {
      final directory = Directory.systemTemp.createTempSync('keev-v7-v8-');
      final file = File('${directory.path}/ledger.sqlite');
      final old = v7.DatabaseAtV7(NativeDatabase(file));
      await old.customStatement('''
        INSERT INTO sync_link_states
          (slot, cloud_account_id, state, sync_enabled,
           needs_reconciliation, updated_at_utc)
        VALUES (1, '$accountId', 'linked', 1, 0, 1);
      ''');
      await old.close();

      final db = LedgerDatabase(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        directory.deleteSync(recursive: true);
      });
      final onboarding = await db
          .customSelect(
            'SELECT dataset_generation,stage FROM sync_onboarding_state '
            'WHERE slot=1',
          )
          .getSingle();
      final link = await db.select(db.syncLinkStates).getSingle();

      expect(onboarding.read<String?>('dataset_generation'), isNull);
      expect(onboarding.read<String>('stage'), 'reconciling');
      expect(link.state, 'needsReconciliation');
      expect(link.syncEnabled, false);
    },
  );

  test(
    'local edits during initialization are captured but not executed',
    () async {
      final db = LedgerDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.select(db.syncDeviceStates).getSingle();
      await (db.update(
        db.syncLinkStates,
      )..where((row) => row.slot.equals(1))).write(
        const SyncLinkStatesCompanion(
          cloudAccountId: Value(accountId),
          state: Value('linked'),
          syncEnabled: Value(false),
        ),
      );
      await db.customStatement(
        "UPDATE sync_onboarding_state SET stage='localToCloud', "
        'dataset_generation=?, initialization_operation_id=? WHERE slot=1',
        [generation, operationId],
      );
      final captured = await DriftSyncMutationCapture(db).capture(
        entityType: SyncEntityType.account,
        entityId: '50000000-0000-4000-8000-000000000010',
        operation: SyncOperation.create,
        payload: const {'name': 'Added during upload'},
      );
      expect(captured, isA<Success<bool>>());
      expect((captured as Success<bool>).value, true);
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
      expect(
        (await db.select(db.syncLinkStates).get()).single.syncEnabled,
        false,
      );
    },
  );

  test('server onboarding migration is generation and privilege hardened', () {
    final sql = File('supabase/migrations/202609230003_sync_onboarding_v1.sql')
        .readAsStringSync()
        .toLowerCase();
    expect(sql, contains('create table public.sync_datasets'));
    expect(sql, contains("set search_path = ''"));
    expect(sql, contains('p_generation uuid'));
    expect(sql, contains("'reconciliation_required'"));
    expect(sql, contains('auth.uid()'));
    expect(
      sql,
      contains('revoke all on function public.sync_begin_initialization_v1'),
    );
    expect(sql, contains('from public,anon'));
    expect(
      sql,
      contains('grant execute on function public.sync_begin_initialization_v1'),
    );
    expect(
      sql,
      contains('revoke insert,update,delete on public.sync_datasets'),
    );
    expect(sql, isNot(contains('service_role')));
  });

  test('initialization lease supports resume, active rejection and takeover', () {
    final sql = File(
      'supabase/migrations/202609230004_sync_onboarding_v1_fix_gate.sql',
    ).readAsStringSync().toLowerCase();
    expect(sql, contains("interval '30 minutes'"));
    expect(sql, contains("'status','resumed'"));
    expect(sql, contains("'status','initialization_in_progress'"));
    expect(sql, contains("'status','recovered'"));
    expect(sql, contains('initialization_lease_expires_at'));
    expect(sql, contains('pg_catalog.clock_timestamp()'));
    expect(sql, contains('pg_advisory_xact_lock'));
    expect(sql, contains('where user_id=v_user'));
    expect(sql, contains('sync_abort_initialization_v1'));
    expect(
      sql,
      contains(
        'revoke all on function public.sync_abort_initialization_v1(uuid,uuid)',
      ),
    );
    expect(sql, contains('from public,anon'));
    expect(sql, isNot(contains('service_role')));
  });

  test('activation source does not claim caught-up or write sync time', () {
    final local = File(
      'lib/features/sync/data/drift_sync_onboarding_store.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/features/sync/application/sync_controller.dart',
    ).readAsStringSync();
    expect(local, contains('last_successful_sync_at_utc=NULL'));
    expect(controller, contains('pullCaughtUp = false;'));
    expect(controller, isNot(contains('pullCaughtUp = true;')));
  });

  test(
    'keep local conflict creates a new mutation at refreshed remote base',
    () async {
      final db = LedgerDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.select(db.syncDeviceStates).getSingle();
      const entity = '50000000-0000-4000-8000-000000000009';
      const oldMutation = '60000000-0000-4000-8000-000000000001';
      const conflictId = '70000000-0000-4000-8000-000000000001';
      const local = <String, Object?>{
        'name': 'Historical conflict candidate',
        '_local_operation': 'update',
      };
      await db
          .into(db.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              slot: const Value(1),
              id: '80000000-0000-4000-8000-000000000001',
              baseCurrencyCode: 'HKD',
              createdAtUtc: 1,
              updatedAtUtc: 1,
            ),
          );
      final profile = await db.select(db.localProfiles).getSingle();
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: entity,
              profileId: profile.id,
              name: 'Latest local state after M3',
              kind: 'cash',
              currencyCode: 'HKD',
              openingMinorUnits: 300,
              openingDate: '2026-09-23',
              createdAtUtc: 1,
              updatedAtUtc: 3,
            ),
          );
      await db
          .into(db.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              mutationId: oldMutation,
              entityType: 'account',
              entityId: entity,
              operation: 'update',
              baseServerVersion: const Value(4),
              payloadJson: jsonEncode(local),
              state: const Value('blocked'),
              createdAtUtc: 1,
            ),
          );
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: conflictId,
              entityType: 'account',
              entityId: entity,
              mutationId: const Value(oldMutation),
              baseServerVersion: 4,
              remoteServerVersion: 5,
              remoteServerRevision: 5,
              localCandidateJson: jsonEncode(local),
              remoteCandidateJson: jsonEncode({'name': 'Cloud'}),
              detectedAtUtc: 2,
            ),
          );
      for (final entry in const [
        ('60000000-0000-4000-8000-000000000002', 'M2'),
        ('60000000-0000-4000-8000-000000000003', 'M3'),
      ]) {
        await db
            .into(db.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                mutationId: entry.$1,
                entityType: 'account',
                entityId: entity,
                operation: 'update',
                payloadJson: jsonEncode({'name': entry.$2}),
                state: const Value('blocked'),
                createdAtUtc: entry.$2 == 'M2' ? 2 : 3,
              ),
            );
      }
      final store = DriftSyncConflictStore(
        db: db,
        runtime: DriftSyncStateStore(db),
      );
      final conflict =
          (await store.unresolvedConflicts() as Success<List<SyncConflictItem>>)
              .value
              .single;
      await store.keepLocal(
        conflict: conflict,
        currentRemote: SyncCanonicalEntity(
          entityType: SyncEntityType.account,
          id: entity,
          serverVersion: 7,
          serverRevision: 9,
          isDeleted: false,
          payload: const {'name': 'Newer cloud'},
          throughSequence: 9,
        ),
        generation: generation,
      );
      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.single.mutationId, isNot(oldMutation));
      expect(outbox.single.baseServerVersion, 7);
      final payload =
          jsonDecode(outbox.single.payloadJson) as Map<String, dynamic>;
      expect(payload['_conflict_resolution'], true);
      expect(payload['name'], 'Latest local state after M3');
      expect(payload['opening_minor_units'], 300);
      expect(payload['name'], isNot(local['name']));
      expect(
        (await db.select(db.syncConflicts).get()).single.status,
        'resolved',
      );
    },
  );
}

SyncOnboardingService _service(_Local local, _Remote remote) =>
    SyncOnboardingService(
      local: local,
      remote: remote,
      receipts: _Receipts(),
      receiptSource: (_) async => const Failure(FailureCode.attachmentNotFound),
      receiptSpool: _Spool(),
      deviceIdProvider: () async => const Success(deviceId),
      deviceRegistration: remote,
    );

final class _Local implements SyncOnboardingLocalStore {
  _Local({required this.hasData});
  final bool hasData;
  int beginCount = 0;
  int failCount = 0;
  int? activatedCursor;
  String? activatedGeneration;
  List<SyncInitialEntity> initial = const [];

  @override
  Future<Result<SyncLedgerSummary>> summarizeLocal() async => Success(
    SyncLedgerSummary(
      accounts: hasData ? 1 : 0,
      transactions: 0,
      receipts: 0,
      baseCurrencyCode: 'HKD',
    ),
  );
  @override
  Future<Result<String>> beginOnboarding(SyncOnboardingStage stage) async {
    beginCount++;
    return const Success(operationId);
  }

  @override
  Future<Result<void>> bindInitialization({
    required String accountId,
    required String generation,
  }) async => const Success(null);

  @override
  Future<Result<List<SyncInitialEntity>>> readInitialEntities() async =>
      Success(initial);
  @override
  Future<Result<void>> activate({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntityResult> entityStates,
  }) async {
    activatedGeneration = generation;
    activatedCursor = cursor;
    return const Success(null);
  }

  @override
  Future<Result<void>> replaceWithCloudSnapshot({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntity> entities,
    required Map<String, List<int>> receiptBytes,
  }) async {
    activatedGeneration = generation;
    activatedCursor = cursor;
    return const Success(null);
  }

  @override
  Future<Result<SyncDurableState>> readDurableState() async => Success(
    SyncDurableState(
      linkedAccountId: activatedGeneration == null ? null : accountId,
      generation: activatedGeneration,
      stage: activatedGeneration == null
          ? SyncOnboardingStage.idle
          : SyncOnboardingStage.active,
      syncEnabled: activatedGeneration != null,
      needsReconciliation: false,
      paused: false,
      pendingChanges: 0,
      unresolvedConflicts: 0,
    ),
  );
  @override
  Future<Result<void>> failOnboarding() async {
    failCount++;
    return const Success(null);
  }

  @override
  Future<Result<void>> setPaused(bool paused) async => const Success(null);
  @override
  Future<Result<void>> requireReconciliation() async => const Success(null);
  @override
  Future<Result<void>> unlink() async => const Success(null);
}

final class _Remote
    implements SyncOnboardingRemoteStore, SyncDeviceRegistrationRemote {
  _Remote({required this.hasData, this.ackFailure});
  final bool hasData;
  final FailureCode? ackFailure;
  int beginCount = 0;
  final uploaded = <SyncEntityType>[];
  int? acknowledgedRevision;
  String? acknowledgedDevice;
  int unlinkCalls = 0;

  @override
  Future<Result<void>> acknowledgeDevice({
    required String deviceId,
    required String generation,
    required int revision,
  }) async {
    if (ackFailure != null) return Failure(ackFailure!);
    acknowledgedDevice = deviceId;
    acknowledgedRevision = revision;
    return const Success(null);
  }

  @override
  Future<Result<void>> unlinkDevice({
    required String deviceId,
    required String generation,
  }) async {
    unlinkCalls++;
    return const Success(null);
  }

  @override
  Future<Result<void>> abortInitialization(
    SyncInitializationLease lease,
  ) async => const Success(null);

  @override
  Future<Result<SyncCloudDiscovery>> discover() async => Success(
    SyncCloudDiscovery(
      summary: SyncLedgerSummary(
        accounts: hasData ? 1 : 0,
        transactions: 0,
        receipts: 0,
        baseCurrencyCode: hasData ? 'HKD' : null,
      ),
      generation: hasData ? generation : null,
      maximumRevision: hasData ? 4 : 0,
      initializationInProgress: false,
    ),
  );
  @override
  Future<Result<SyncInitializationLease>> beginInitialization({
    required String operationId,
    required SyncOnboardingChoice choice,
  }) async {
    beginCount++;
    return Success(
      SyncInitializationLease(
        operationId: operationId,
        generation: generation,
        snapshotRevision: 0,
      ),
    );
  }

  @override
  Future<Result<SyncInitialEntityResult>> uploadInitialEntity({
    required SyncInitializationLease lease,
    required String deviceId,
    required SyncInitialEntity entity,
  }) async {
    uploaded.add(entity.entityType);
    return Success(
      SyncInitialEntityResult(
        entityType: entity.entityType,
        entityId: entity.entityId,
        serverVersion: 1,
        serverRevision: uploaded.length,
      ),
    );
  }

  @override
  Future<Result<int>> finalizeInitialization(
    SyncInitializationLease lease,
  ) async => Success(uploaded.length);
  @override
  Future<Result<SyncSnapshotPage>> fetchSnapshotPage({
    required String generation,
    required int highWaterRevision,
    required int offset,
    int limit = maximumSyncPageSize,
  }) async => Success(
    SyncSnapshotPage(
      generation: generation,
      highWaterRevision: highWaterRevision,
      entities: const [],
      nextOffset: null,
    ),
  );
  @override
  Future<Result<SyncCanonicalEntity>> fetchCurrentEntity({
    required String generation,
    required SyncEntityType entityType,
    required String entityId,
  }) async => throw UnimplementedError();
}

final class _Receipts implements SyncReceiptTransport {
  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async => const Success(null);
  @override
  Future<Result<List<int>>> download(String objectPath) async =>
      const Success([]);
  @override
  Future<Result<void>> delete(String objectPath) async => const Success(null);
}

final class _Spool implements SyncReceiptSpool {
  @override
  Future<Result<bool>> prepare({
    required String attachmentId,
    required File processedFile,
    required String sha256Hex,
    required int byteSize,
  }) async => const Success(true);
  @override
  Future<Result<File>> resolve(String attachmentId) async =>
      const Failure(FailureCode.attachmentNotFound);
  @override
  Future<Result<void>> remove(String attachmentId) async => const Success(null);
  @override
  Future<Result<void>> removeIfUnreferenced(String attachmentId) async =>
      const Success(null);
  @override
  Future<Result<void>> clearAll() async => const Success(null);
}
