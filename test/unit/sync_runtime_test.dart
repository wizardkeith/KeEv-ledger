import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/data/drift_bookkeeping_repositories.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/sync/application/sync_contracts.dart';
import 'package:ledger/features/sync/application/sync_engine.dart';
import 'package:ledger/features/sync/data/drift_sync_mutation_capture.dart';
import 'package:ledger/features/sync/data/drift_sync_state_store.dart';
import 'package:ledger/features/sync/domain/sync_protocol.dart';
import 'package:ledger/features/sync/infrastructure/local_sync_receipt_pull_files.dart';
import 'package:ledger/features/sync/infrastructure/local_sync_receipt_spool.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    hide Account, SyncCursor;

const profileId = '11111111-1111-4111-8111-111111111111';
const accountId = '22222222-2222-4222-8222-222222222222';
const categoryId = '33333333-3333-4333-8333-333333333333';
const cloudId = '44444444-4444-4444-8444-444444444444';
const deviceId = '55555555-5555-4555-8555-555555555555';
const otherDevice = '66666666-6666-4666-8666-666666666666';
const mutationId = '77777777-7777-4777-8777-777777777777';
const attachmentId = '99999999-9999-4999-8999-999999999999';
const transactionId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const secondAttachmentId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const datasetGeneration = '88000000-0000-4000-8000-000000000001';

void main() {
  late LedgerDatabase db;
  late _Clock clock;

  setUp(() async {
    db = LedgerDatabase(NativeDatabase.memory());
    clock = _Clock(DateTime.utc(2026, 9, 23));
    await db
        .into(db.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            slot: const Value(1),
            id: profileId,
            baseCurrencyCode: 'HKD',
            createdAtUtc: 1,
            updatedAtUtc: 1,
          ),
        );
  });
  tearDown(() => db.close());

  Future<void> link({bool enabled = true, bool reconcile = false}) async {
    await (db.update(
      db.syncLinkStates,
    )..where((row) => row.slot.equals(1))).write(
      SyncLinkStatesCompanion(
        cloudAccountId: const Value(cloudId),
        state: Value(reconcile ? 'needsReconciliation' : 'linked'),
        syncEnabled: Value(enabled),
        needsReconciliation: Value(reconcile),
        updatedAtUtc: Value(clock.nowUtc().microsecondsSinceEpoch),
      ),
    );
    await (db.update(db.syncDeviceStates)..where((row) => row.slot.equals(1)))
        .write(const SyncDeviceStatesCompanion(deviceId: Value(deviceId)));
    await db.customStatement(
      'UPDATE sync_onboarding_state SET dataset_generation=?, '
      "stage='active' WHERE slot=1",
      [datasetGeneration],
    );
  }

  Future<void> seedReceiptParent() async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: accountId,
            profileId: profileId,
            name: 'Cash',
            kind: 'cash',
            currencyCode: 'HKD',
            openingMinorUnits: 0,
            openingDate: '2026-01-01',
            createdAtUtc: 1,
            updatedAtUtc: 1,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            profileId: profileId,
            name: 'Food',
            kind: 'expense',
            createdAtUtc: 1,
            updatedAtUtc: 1,
          ),
        );
    await db
        .into(db.bookkeepingTransactions)
        .insert(
          BookkeepingTransactionsCompanion.insert(
            id: transactionId,
            profileId: profileId,
            accountId: accountId,
            categoryId: categoryId,
            kind: 'expense',
            amountMinorUnits: 100,
            currencyCode: 'HKD',
            businessDate: '2026-09-23',
            createdAtUtc: 1,
            updatedAtUtc: 1,
          ),
        );
  }

  Future<void> captureAttemptedReceiptChain() async {
    await link();
    final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
    await capture.capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.create,
      payload: receiptSnapshot(const [7, 7, 7]),
    );
    final store = DriftSyncStateStore(db, clock: clock);
    final create =
        (await store.nextDueMutation(clock.nowUtc())
                as Success<PendingSyncMutation?>)
            .value!;
    await store.markAttemptStarted(create.mutationId, clock.nowUtc());
    await capture.capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.delete,
      payload: receiptSnapshot(const [7, 7, 7]),
    );
    expect(await db.select(db.syncOutbox).get(), hasLength(2));
  }

  Account account(String name) => Account(
    id: LocalId(accountId),
    profileId: LocalId(profileId),
    name: name,
    kind: AccountKind.cash,
    currency: Currency.hkd,
    openingBalance: Money.fromMinorUnits(Currency.hkd, 0),
    openingDate: BusinessDate('2026-01-01'),
    isArchived: false,
    createdAtUtc: clock.nowUtc(),
    updatedAtUtc: clock.nowUtc(),
  );

  test(
    'disabled and reconciliation modes never capture unsafe outbox',
    () async {
      final repository = DriftAccountRepository(db);
      expect(
        await repository.create(account('Local')),
        isA<Success<Account>>(),
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
      await (db.delete(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).go();
      await link(reconcile: true);
      expect(
        await repository.create(account('Reconcile')),
        isA<Success<Account>>(),
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );

  test('linked local write and durable intent commit atomically', () async {
    await link();
    final repository = DriftAccountRepository(db);
    expect(await repository.create(account('Cash')), isA<Success<Account>>());
    final row = (await db.select(db.syncOutbox).get()).single;
    expect(row.operation, 'create');
    expect(row.baseServerVersion, 0);
    expect(row.attemptCount, 0);
    expect(row.queueSequence, greaterThan(0));
  });

  test(
    'successor mutations defer and receive acknowledged predecessor base',
    () async {
      await link();
      final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
      await capture.capture(
        entityType: SyncEntityType.account,
        entityId: accountId,
        operation: SyncOperation.create,
        payload: const {'name': 'one'},
      );
      await capture.capture(
        entityType: SyncEntityType.account,
        entityId: accountId,
        operation: SyncOperation.update,
        payload: const {'name': 'two'},
      );
      final rows = await (db.select(
        db.syncOutbox,
      )..orderBy([(row) => OrderingTerm.asc(row.queueSequence)])).get();
      expect(rows.first.baseServerVersion, 0);
      expect(rows.last.baseServerVersion, isNull);
      final store = DriftSyncStateStore(db, clock: clock);
      final first =
          (await store.nextDueMutation(clock.nowUtc())
                  as Success<PendingSyncMutation?>)
              .value!;
      await store.acknowledgeMutation(
        first,
        const SyncMutationResult(
          status: SyncMutationStatus.applied,
          serverVersion: 1,
          serverRevision: 1,
        ),
      );
      expect(
        (await db.select(db.syncOutbox).get()).single.baseServerVersion,
        1,
      );
    },
  );

  test('processing crash recovers same immutable mutation identity', () async {
    await link();
    final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
    await capture.capture(
      entityType: SyncEntityType.account,
      entityId: accountId,
      operation: SyncOperation.create,
      payload: const {'name': 'stable'},
    );
    final store = DriftSyncStateStore(db, clock: clock);
    final pending =
        (await store.nextDueMutation(clock.nowUtc())
                as Success<PendingSyncMutation?>)
            .value!;
    await store.markAttemptStarted(pending.mutationId, clock.nowUtc());
    await store.recoverInterruptedProcessing();
    final retried =
        (await store.nextDueMutation(clock.nowUtc())
                as Success<PendingSyncMutation?>)
            .value!;
    expect(retried.mutationId, pending.mutationId);
    expect(retried.payload, pending.payload);
    expect(retried.baseServerVersion, pending.baseServerVersion);
    expect(retried.attemptCount, 1);
  });

  test('transient failure persists bounded retry without busy-loop', () async {
    await link();
    final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
    await capture.capture(
      entityType: SyncEntityType.account,
      entityId: accountId,
      operation: SyncOperation.create,
      payload: const {'name': 'offline'},
    );
    final local = DriftSyncStateStore(db, clock: clock);
    final engine = SyncEngine(
      remote: _Remote(failure: FailureCode.syncNetworkUnavailable),
      local: local,
      clock: clock,
    );
    final result = await engine.runCycle(authenticatedAccountId: cloudId);
    expect(result, isA<Success<SyncRunSummary>>());
    final row = (await db.select(db.syncOutbox).get()).single;
    expect(row.attemptCount, 1);
    expect(
      row.nextAttemptAtUtc,
      greaterThan(clock.nowUtc().microsecondsSinceEpoch),
    );
    expect(
      (await local.nextDueMutation(clock.nowUtc()) as Success).value,
      isNull,
    );
  });

  test('caught-up empty pull heartbeats the current durable cursor', () async {
    await link();
    await (db.update(db.syncCursors)..where((row) => row.slot.equals(1))).write(
      const SyncCursorsCompanion(lastAppliedSequence: Value(100)),
    );
    final remote = _Remote();
    final result = await SyncEngine(
      remote: remote,
      local: DriftSyncStateStore(db, clock: clock),
      clock: clock,
    ).runCycle(authenticatedAccountId: cloudId);
    expect(result, isA<Success<SyncRunSummary>>());
    expect(remote.acknowledgedRevision, 100);
    expect(remote.acknowledgedDevice, deviceId);
    expect(
      (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
      100,
    );
  });

  test('failed caught-up heartbeat does not claim successful sync', () async {
    await link();
    final result = await SyncEngine(
      remote: _Remote(ackFailure: FailureCode.syncNetworkUnavailable),
      local: DriftSyncStateStore(db, clock: clock),
      clock: clock,
    ).runCycle(authenticatedAccountId: cloudId);
    expect(result, isA<Failure<SyncRunSummary>>());
    expect(
      (result as Failure<SyncRunSummary>).code,
      FailureCode.syncNetworkUnavailable,
    );
    final onboarding = await db
        .customSelect(
          'SELECT last_successful_sync_at_utc FROM '
          'sync_onboarding_state WHERE slot=1',
        )
        .getSingle();
    expect(onboarding.read<int?>('last_successful_sync_at_utc'), isNull);
  });

  test(
    'another-device event with local pending work preserves conflict',
    () async {
      await link();
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: categoryId,
              profileId: profileId,
              name: 'Local edit',
              kind: 'expense',
              createdAtUtc: 1,
              updatedAtUtc: 2,
            ),
          );
      await db
          .into(db.syncEntityStates)
          .insert(
            SyncEntityStatesCompanion.insert(
              entityType: 'category',
              entityId: categoryId,
              serverVersion: 1,
              serverRevision: 1,
            ),
          );
      await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
        entityType: SyncEntityType.category,
        entityId: categoryId,
        operation: SyncOperation.update,
        payload: categorySnapshot('Local edit', version: 1, revision: 1),
      );
      final page = SyncChangePage(
        changes: [
          change(2, categorySnapshot('Remote edit', version: 2, revision: 2)),
        ],
      );
      final result = await DriftSyncStateStore(
        db,
        clock: clock,
      ).applyPageAtomically(page, localDeviceId: deviceId);
      expect((result as Success<SyncPageApplyResult>).value.conflicts, 1);
      expect((await db.select(db.categories).get()).single.name, 'Local edit');
      expect(await db.select(db.syncConflicts).get(), hasLength(1));
      expect((await db.select(db.syncOutbox).get()).single.state, 'blocked');
      expect(
        (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
        2,
      );
    },
  );

  test(
    'own echo updates baseline without overwriting newer successor',
    () async {
      await link();
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: categoryId,
              profileId: profileId,
              name: 'Newest local',
              kind: 'expense',
              createdAtUtc: 1,
              updatedAtUtc: 3,
            ),
          );
      await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
        entityType: SyncEntityType.category,
        entityId: categoryId,
        operation: SyncOperation.update,
        payload: categorySnapshot('Newest local', version: 1, revision: 1),
      );
      final page = SyncChangePage(
        changes: [
          change(
            2,
            categorySnapshot('Older echo', version: 2, revision: 2),
            origin: deviceId,
          ),
        ],
      );
      await DriftSyncStateStore(
        db,
        clock: clock,
      ).applyPageAtomically(page, localDeviceId: deviceId);
      expect(
        (await db.select(db.categories).get()).single.name,
        'Newest local',
      );
      expect(await db.select(db.syncConflicts).get(), isEmpty);
      expect(
        (await db.select(db.syncEntityStates).get()).single.serverVersion,
        2,
      );
    },
  );

  test('runtime SQL stores exact immutable events and least privilege', () {
    final sql = File(
      'supabase/migrations/202609230001_sync_runtime_v1.sql',
    ).readAsStringSync().toLowerCase();
    expect(sql, contains('add column payload jsonb'));
    expect(sql, contains('add column mutation_id uuid'));
    expect(sql, contains('add column origin_device_id uuid'));
    expect(sql, contains('sync_complete_change_event_v1'));
    expect(
      sql,
      contains(
        "p_operation='delete' and p_entity_type not in ('transaction','transfer','receipt_attachment')",
      ),
    );
    expect(sql, contains('result_json jsonb'));
    expect(
      sql,
      contains('revoke insert, update, delete on public.sync_change_log'),
    );
    expect(sql, contains('set search_path = \'\''));
    expect(sql, contains('v_profile_id'));
    final fixSql = File(
      'supabase/migrations/202609230002_sync_runtime_v1_fix_gate.sql',
    ).readAsStringSync().toLowerCase();
    expect(
      fixSql,
      contains("p_entity_type='receipt_attachment' and p_operation='update'"),
    );
    expect(fixSql, contains("'reason','unsupported_operation'"));
    expect(
      fixSql,
      contains(
        'revoke all on function public.sync_apply_mutation_v1_phase6b_base',
      ),
    );
  });

  test(
    'one cycle bounds push work and reports remaining durable work',
    () async {
      await link();
      final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
      await capture.capture(
        entityType: SyncEntityType.account,
        entityId: accountId,
        operation: SyncOperation.create,
        payload: const {'name': 'first'},
      );
      await capture.capture(
        entityType: SyncEntityType.category,
        entityId: categoryId,
        operation: SyncOperation.create,
        payload: const {'name': 'second'},
      );
      final remote = _Remote();
      final result = await SyncEngine(
        remote: remote,
        local: DriftSyncStateStore(db, clock: clock),
        clock: clock,
        maximumPushesPerCycle: 1,
      ).runCycle(authenticatedAccountId: cloudId);
      final summary = (result as Success<SyncRunSummary>).value;
      expect(summary.pushed, 1);
      expect(summary.moreWorkAvailable, isTrue);
      expect(remote.calls, 1);
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
    },
  );

  test(
    'blocked entity chain does not prevent unrelated eligible push',
    () async {
      await link();
      const entityA = '12121212-1212-4212-8212-121212121212';
      const entityB = '13131313-1313-4313-8313-131313131313';
      await db.batch((batch) {
        batch.insertAll(db.syncOutbox, [
          SyncOutboxCompanion.insert(
            mutationId: '14141414-1414-4414-8414-141414141414',
            entityType: 'account',
            entityId: entityA,
            operation: 'update',
            baseServerVersion: const Value(3),
            payloadJson: '{"name":"conflicted"}',
            state: const Value('blocked'),
            attemptCount: const Value(1),
            createdAtUtc: 1,
          ),
          SyncOutboxCompanion.insert(
            mutationId: '15151515-1515-4515-8515-151515151515',
            entityType: 'account',
            entityId: entityA,
            operation: 'update',
            payloadJson: '{"name":"latest local"}',
            createdAtUtc: 2,
          ),
          SyncOutboxCompanion.insert(
            mutationId: '16161616-1616-4616-8616-161616161616',
            entityType: 'category',
            entityId: entityB,
            operation: 'create',
            baseServerVersion: const Value(0),
            payloadJson: '{"name":"unrelated"}',
            createdAtUtc: 3,
          ),
        ]);
      });
      final remote = _Remote();
      final result = await SyncEngine(
        remote: remote,
        local: DriftSyncStateStore(db, clock: clock),
        clock: clock,
        maximumPushesPerCycle: 1,
      ).runCycle(authenticatedAccountId: cloudId);
      expect(result, isA<Success<SyncRunSummary>>());
      expect(remote.calls, 1);
      final rows = await db.select(db.syncOutbox).get();
      expect(rows.where((row) => row.entityId == entityA), hasLength(2));
      expect(rows.where((row) => row.entityId == entityB), isEmpty);
    },
  );

  test('pull receipt preparation rejects corrupt private bytes', () async {
    final directory = await Directory.systemTemp.createTemp('keev-sync-pull-');
    addTearDown(() => directory.delete(recursive: true));
    final intended = <int>[1, 2, 3, 4];
    final event = SyncChange(
      sequence: 1,
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      serverVersion: 1,
      operation: SyncOperation.create,
      originDeviceId: otherDevice,
      mutationId: mutationId,
      snapshot: {
        'storage_path': '$cloudId/receipts/$attachmentId/hash.jpg',
        'sha256_hex': sha256.convert(intended).toString(),
        'byte_size': intended.length,
        'mime_type': 'image/jpeg',
      },
    );
    final files = LocalSyncReceiptPullFiles(
      transport: const _ReceiptTransport(<int>[9, 9, 9, 9]),
      directoryProvider: () async => directory,
    );
    expect(
      await files.prepare(event),
      isA<Failure<PreparedSyncReceipt>>().having(
        (failure) => failure.code,
        'code',
        FailureCode.syncAttachmentIntegrityFailure,
      ),
    );
    expect(directory.listSync(), isEmpty);
  });

  test('receipt conflict never downloads or overwrites live bytes', () async {
    await link();
    final directory = await Directory.systemTemp.createTemp('keev-live-');
    addTearDown(() => directory.delete(recursive: true));
    final live = File('${directory.path}/$attachmentId.jpg');
    await live.writeAsBytes(const [7, 7, 7]);
    await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.create,
      payload: receiptSnapshot(const [7, 7, 7]),
    );
    final transport = _CountingReceiptTransport(const [1, 2, 3]);
    final result =
        await DriftSyncStateStore(
          db,
          clock: clock,
          receiptFiles: LocalSyncReceiptPullFiles(
            transport: transport,
            directoryProvider: () async => directory,
          ),
        ).applyPageAtomically(
          SyncChangePage(changes: [receiptChange(origin: otherDevice)]),
          localDeviceId: deviceId,
        );
    expect(result, isA<Success<SyncPageApplyResult>>());
    expect(transport.downloads, 0);
    expect(await live.readAsBytes(), const [7, 7, 7]);
    expect(await db.select(db.syncConflicts).get(), hasLength(1));
  });

  test(
    'receipt own echo preserves newer live bytes without download',
    () async {
      await link();
      final directory = await Directory.systemTemp.createTemp('keev-echo-');
      addTearDown(() => directory.delete(recursive: true));
      final live = File('${directory.path}/$attachmentId.jpg');
      await live.writeAsBytes(const [8, 8]);
      await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
        entityType: SyncEntityType.receiptAttachment,
        entityId: attachmentId,
        operation: SyncOperation.create,
        payload: receiptSnapshot(const [8, 8]),
      );
      final transport = _CountingReceiptTransport(const [1, 2, 3]);
      await DriftSyncStateStore(
        db,
        clock: clock,
        receiptFiles: LocalSyncReceiptPullFiles(
          transport: transport,
          directoryProvider: () async => directory,
        ),
      ).applyPageAtomically(
        SyncChangePage(changes: [receiptChange(origin: deviceId)]),
        localDeviceId: deviceId,
      );
      expect(transport.downloads, 0);
      expect(await live.readAsBytes(), const [8, 8]);
    },
  );

  test('remote receipt update is rejected before download', () async {
    final directory = await Directory.systemTemp.createTemp('keev-update-');
    addTearDown(() => directory.delete(recursive: true));
    final transport = _CountingReceiptTransport(const [1, 2, 3]);
    final result =
        await DriftSyncStateStore(
          db,
          clock: clock,
          receiptFiles: LocalSyncReceiptPullFiles(
            transport: transport,
            directoryProvider: () async => directory,
          ),
        ).applyPageAtomically(
          SyncChangePage(
            changes: [receiptChange(operation: SyncOperation.update)],
          ),
          localDeviceId: deviceId,
        );
    expect(
      result,
      isA<Failure<SyncPageApplyResult>>().having(
        (failure) => failure.code,
        'code',
        FailureCode.syncInvalidRemoteData,
      ),
    );
    expect(transport.downloads, 0);
  });

  test('resolved deferred base is preserved in conflict history', () async {
    await link();
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            profileId: profileId,
            name: 'Local candidate',
            kind: 'expense',
            createdAtUtc: 1,
            updatedAtUtc: 2,
          ),
        );
    await db
        .into(db.syncEntityStates)
        .insert(
          SyncEntityStatesCompanion.insert(
            entityType: 'category',
            entityId: categoryId,
            serverVersion: 4,
            serverRevision: 4,
          ),
        );
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            mutationId: mutationId,
            entityType: 'category',
            entityId: categoryId,
            operation: 'update',
            baseServerVersion: const Value(null),
            payloadJson: '{"name":"Local candidate"}',
            createdAtUtc: 1,
          ),
        );
    await SyncEngine(
      remote: const _ConflictRemote(),
      local: DriftSyncStateStore(db, clock: clock),
      clock: clock,
    ).runCycle(authenticatedAccountId: cloudId);
    final conflict = (await db.select(db.syncConflicts).get()).single;
    expect(conflict.baseServerVersion, 4);
    expect((await db.select(db.syncOutbox).get()).single.state, 'blocked');
    expect(
      (await db.select(db.categories).get()).single.name,
      'Local candidate',
    );
  });

  test('pull bounding uses fetched page fullness, not applied count', () async {
    for (final scenario in <(String, SyncChangePage, int, bool)>[
      (
        'own echoes',
        pagingPage(maximumSyncPageSize, origin: deviceId),
        0,
        true,
      ),
      ('conflicts', pagingPage(maximumSyncPageSize), maximumSyncPageSize, true),
      ('short', pagingPage(1), 0, false),
      ('empty', SyncChangePage(changes: const []), 0, false),
    ]) {
      final local = _PagingLocal(conflicts: scenario.$3);
      final result = await SyncEngine(
        remote: _PagingRemote(scenario.$2),
        local: local,
        clock: clock,
        maximumPullPagesPerCycle: 1,
      ).runCycle(authenticatedAccountId: cloudId);
      expect(
        (result as Success<SyncRunSummary>).value.moreWorkAvailable,
        scenario.$4,
        reason: scenario.$1,
      );
    }
  });

  test('never-attempted receipt compaction removes physical spool', () async {
    await link();
    final root = await Directory.systemTemp.createTemp('keev-spool-');
    addTearDown(() => root.delete(recursive: true));
    final source = File('${root.path}/source.jpg');
    const bytes = [1, 2, 3];
    await source.writeAsBytes(bytes);
    final spool = LocalSyncReceiptSpool(
      db: db,
      directoryProvider: () async => Directory('${root.path}/spool'),
      clock: clock,
    );
    final hash = sha256.convert(bytes).toString();
    expect(
      await spool.prepare(
        attachmentId: attachmentId,
        processedFile: source,
        sha256Hex: hash,
        byteSize: bytes.length,
      ),
      isA<Success<bool>>(),
    );
    final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
    await capture.capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.create,
      payload: receiptSnapshot(bytes),
    );
    await capture.capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.delete,
      payload: receiptSnapshot(bytes),
    );
    await spool.removeIfUnreferenced(attachmentId);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
    expect(await db.select(db.syncReceiptSpoolEntries).get(), isEmpty);
    expect(File('${root.path}/spool/$attachmentId.jpg').existsSync(), isFalse);
  });

  test(
    'attempted receipt create retains spool through delete intent',
    () async {
      await link();
      final root = await Directory.systemTemp.createTemp('keev-spool-attempt-');
      addTearDown(() => root.delete(recursive: true));
      final source = File('${root.path}/source.jpg');
      const bytes = [4, 5, 6];
      await source.writeAsBytes(bytes);
      final spool = LocalSyncReceiptSpool(
        db: db,
        directoryProvider: () async => Directory('${root.path}/spool'),
        clock: clock,
      );
      final hash = sha256.convert(bytes).toString();
      await spool.prepare(
        attachmentId: attachmentId,
        processedFile: source,
        sha256Hex: hash,
        byteSize: bytes.length,
      );
      final capture = DriftSyncMutationCapture(db, clock: clock, ids: _Ids());
      await capture.capture(
        entityType: SyncEntityType.receiptAttachment,
        entityId: attachmentId,
        operation: SyncOperation.create,
        payload: receiptSnapshot(bytes),
      );
      final store = DriftSyncStateStore(db, clock: clock);
      final create =
          (await store.nextDueMutation(clock.nowUtc())
                  as Success<PendingSyncMutation?>)
              .value!;
      await store.markAttemptStarted(create.mutationId, clock.nowUtc());
      await capture.capture(
        entityType: SyncEntityType.receiptAttachment,
        entityId: attachmentId,
        operation: SyncOperation.delete,
        payload: receiptSnapshot(bytes),
      );
      await spool.removeIfUnreferenced(attachmentId);
      expect(await db.select(db.syncOutbox).get(), hasLength(2));
      expect(await db.select(db.syncReceiptSpoolEntries).get(), hasLength(1));
      expect(File('${root.path}/spool/$attachmentId.jpg').existsSync(), isTrue);
    },
  );

  test(
    'local receipt corruption blocks while transport failure retries',
    () async {
      await link();
      final root = await Directory.systemTemp.createTemp('keev-integrity-');
      addTearDown(() => root.delete(recursive: true));
      final source = File('${root.path}/source.jpg');
      const bytes = [1, 3, 5];
      await source.writeAsBytes(bytes);
      final spool = LocalSyncReceiptSpool(
        db: db,
        directoryProvider: () async => Directory('${root.path}/spool'),
        clock: clock,
      );
      final hash = sha256.convert(bytes).toString();
      await spool.prepare(
        attachmentId: attachmentId,
        processedFile: source,
        sha256Hex: hash,
        byteSize: bytes.length,
      );
      await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
        entityType: SyncEntityType.receiptAttachment,
        entityId: attachmentId,
        operation: SyncOperation.create,
        payload: receiptSnapshot(bytes),
      );
      await File(
        '${root.path}/spool/$attachmentId.jpg',
      ).writeAsBytes(const [9]);
      await SyncEngine(
        remote: _Remote(),
        local: DriftSyncStateStore(db, clock: clock),
        clock: clock,
        receiptSpool: spool,
        receiptTransport: const _FailingReceiptTransport(
          FailureCode.syncNetworkUnavailable,
        ),
      ).runCycle(authenticatedAccountId: cloudId);
      final blocked = (await db.select(db.syncOutbox).get()).single;
      expect(blocked.state, 'blocked');
      expect(
        blocked.lastFailureCode,
        FailureCode.syncAttachmentIntegrityFailure.name,
      );
      expect(blocked.nextAttemptAtUtc, isNull);
    },
  );

  test('transient receipt transport failure remains retryable', () async {
    await link();
    final root = await Directory.systemTemp.createTemp('keev-transport-');
    addTearDown(() => root.delete(recursive: true));
    final source = File('${root.path}/source.jpg');
    const bytes = [2, 4, 6];
    await source.writeAsBytes(bytes);
    final spool = LocalSyncReceiptSpool(
      db: db,
      directoryProvider: () async => Directory('${root.path}/spool'),
      clock: clock,
    );
    final hash = sha256.convert(bytes).toString();
    await spool.prepare(
      attachmentId: attachmentId,
      processedFile: source,
      sha256Hex: hash,
      byteSize: bytes.length,
    );
    await DriftSyncMutationCapture(db, clock: clock, ids: _Ids()).capture(
      entityType: SyncEntityType.receiptAttachment,
      entityId: attachmentId,
      operation: SyncOperation.create,
      payload: receiptSnapshot(bytes),
    );
    await SyncEngine(
      remote: _Remote(),
      local: DriftSyncStateStore(db, clock: clock),
      clock: clock,
      receiptSpool: spool,
      receiptTransport: const _FailingReceiptTransport(
        FailureCode.syncNetworkUnavailable,
      ),
    ).runCycle(authenticatedAccountId: cloudId);
    final pending = (await db.select(db.syncOutbox).get()).single;
    expect(pending.state, 'pending');
    expect(pending.nextAttemptAtUtc, isNotNull);
    expect(pending.lastFailureCode, FailureCode.syncNetworkUnavailable.name);
  });

  test(
    'post-commit tombstone cleanup failure preserves committed receipt',
    () async {
      await seedReceiptParent();
      final root = await Directory.systemTemp.createTemp('keev-post-commit-');
      addTearDown(() => root.delete(recursive: true));
      final oldFile = File('${root.path}/$secondAttachmentId.jpg');
      await oldFile.writeAsBytes(const [8, 8, 8]);
      await db
          .into(db.receiptAttachments)
          .insert(
            ReceiptAttachmentsCompanion.insert(
              id: secondAttachmentId,
              profileId: profileId,
              transactionId: transactionId,
              storageKey: '$secondAttachmentId.jpg',
              mimeType: 'image/jpeg',
              byteSize: 3,
              sha256Hex: sha256.convert(const [8, 8, 8]).toString(),
              position: 1,
              createdAtUtc: 1,
            ),
          );
      final files = _FaultingPullFiles(root, throwRemoveAfterCommit: true);
      final result =
          await DriftSyncStateStore(
            db,
            clock: clock,
            receiptFiles: files,
          ).applyPageAtomically(
            SyncChangePage(
              changes: [
                receiptChangeFor(attachmentId, sequence: 1, position: 0),
                receiptChangeFor(
                  secondAttachmentId,
                  sequence: 2,
                  position: 1,
                  operation: SyncOperation.delete,
                  deleted: true,
                ),
              ],
            ),
            localDeviceId: deviceId,
          );

      expect(result, isA<Success<SyncPageApplyResult>>());
      expect(
        await (db.select(
          db.receiptAttachments,
        )..where((row) => row.id.equals(attachmentId))).getSingleOrNull(),
        isNotNull,
      );
      expect(
        (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
        2,
      );
      expect(File('${root.path}/$attachmentId.jpg').existsSync(), isTrue);
      expect(files.rolledBack, isEmpty);
      expect(oldFile.existsSync(), isTrue);
    },
  );

  test(
    'post-commit staging cleanup failure cannot roll back applied receipt',
    () async {
      await seedReceiptParent();
      final root = await Directory.systemTemp.createTemp('keev-stage-cleanup-');
      addTearDown(() => root.delete(recursive: true));
      final files = _FaultingPullFiles(
        root,
        throwCompensateFor: secondAttachmentId,
        onPrepare: (change) async {
          if (change.entityId != secondAttachmentId) return;
          await db
              .into(db.syncOutbox)
              .insert(
                SyncOutboxCompanion.insert(
                  mutationId: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
                  entityType: 'receipt_attachment',
                  entityId: secondAttachmentId,
                  operation: 'create',
                  baseServerVersion: const Value(0),
                  payloadJson: '{}',
                  createdAtUtc: 1,
                ),
              );
        },
      );
      final result =
          await DriftSyncStateStore(
            db,
            clock: clock,
            receiptFiles: files,
          ).applyPageAtomically(
            SyncChangePage(
              changes: [
                receiptChangeFor(attachmentId, sequence: 1, position: 0),
                receiptChangeFor(secondAttachmentId, sequence: 2, position: 1),
              ],
            ),
            localDeviceId: deviceId,
          );

      expect(result, isA<Success<SyncPageApplyResult>>());
      expect(File('${root.path}/$attachmentId.jpg').existsSync(), isTrue);
      expect(
        await (db.select(
          db.receiptAttachments,
        )..where((row) => row.id.equals(attachmentId))).getSingleOrNull(),
        isNotNull,
      );
      expect(
        (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
        2,
      );
      expect(files.rolledBack, isEmpty);
      expect(
        File(
          '${root.path}/.sync_staging/$secondAttachmentId.pending',
        ).existsSync(),
        isTrue,
      );
    },
  );

  test('receipt pre-scan accepts multiple own-echo outbox rows', () async {
    await captureAttemptedReceiptChain();
    final root = await Directory.systemTemp.createTemp('keev-multi-echo-');
    addTearDown(() => root.delete(recursive: true));
    final live = File('${root.path}/$attachmentId.jpg');
    await live.writeAsBytes(const [7, 7, 7]);
    final transport = _CountingReceiptTransport(const [1, 2, 3]);
    final result =
        await DriftSyncStateStore(
          db,
          clock: clock,
          receiptFiles: LocalSyncReceiptPullFiles(
            transport: transport,
            directoryProvider: () async => root,
          ),
        ).applyPageAtomically(
          SyncChangePage(changes: [receiptChange(origin: deviceId)]),
          localDeviceId: deviceId,
        );

    expect(result, isA<Success<SyncPageApplyResult>>());
    expect(transport.downloads, 0);
    expect(await live.readAsBytes(), const [7, 7, 7]);
    expect(await db.select(db.syncOutbox).get(), hasLength(2));
    expect(
      (await db.select(db.syncOutbox).get()).any(
        (row) => row.operation == 'delete',
      ),
      isTrue,
    );
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    expect(
      (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
      1,
    );
  });

  test(
    'receipt pre-scan preserves conflict with multiple pending rows',
    () async {
      await captureAttemptedReceiptChain();
      final root = await Directory.systemTemp.createTemp(
        'keev-multi-conflict-',
      );
      addTearDown(() => root.delete(recursive: true));
      final live = File('${root.path}/$attachmentId.jpg');
      await live.writeAsBytes(const [7, 7, 7]);
      final transport = _CountingReceiptTransport(const [1, 2, 3]);
      final result =
          await DriftSyncStateStore(
            db,
            clock: clock,
            receiptFiles: LocalSyncReceiptPullFiles(
              transport: transport,
              directoryProvider: () async => root,
            ),
          ).applyPageAtomically(
            SyncChangePage(changes: [receiptChange(origin: otherDevice)]),
            localDeviceId: deviceId,
          );

      expect(result, isA<Success<SyncPageApplyResult>>());
      expect(transport.downloads, 0);
      expect(await live.readAsBytes(), const [7, 7, 7]);
      expect(await db.select(db.syncConflicts).get(), hasLength(1));
      expect(
        (await db.select(db.syncOutbox).get()).every(
          (row) => row.state == 'blocked',
        ),
        isTrue,
      );
      expect(
        (await db.select(db.syncCursors).get()).single.lastAppliedSequence,
        1,
      );
    },
  );

  test('revision snapshots retain exact historical parent state', () {
    final revision10 = categorySnapshot('Parent v1', version: 1, revision: 10);
    final revision20 = categorySnapshot('Parent v2', version: 2, revision: 20);
    final page = SyncChangePage(
      changes: [
        change(10, revision10),
        SyncChange(
          sequence: 15,
          entityType: SyncEntityType.transaction,
          entityId: accountId,
          serverVersion: 1,
          operation: SyncOperation.create,
          originDeviceId: otherDevice,
          mutationId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          snapshot: const {'parent_id': categoryId},
        ),
        change(20, revision20),
      ],
    );
    expect(page.changes[0].snapshot['name'], 'Parent v1');
    expect(page.changes[2].snapshot['name'], 'Parent v2');
  });
}

Map<String, Object?> categorySnapshot(
  String name, {
  required int version,
  required int revision,
}) => {
  'id': categoryId,
  'profile_id': profileId,
  'name': name,
  'kind': 'expense',
  'is_archived': false,
  'server_version': version,
  'server_revision': revision,
  'created_at': '2026-09-23T00:00:00.000Z',
  'updated_at': '2026-09-23T00:00:00.000Z',
  'deleted_at': null,
};

Map<String, Object?> receiptSnapshot(List<int> bytes) => {
  'id': attachmentId,
  'profile_id': profileId,
  'transaction_id': transactionId,
  'storage_path': '$cloudId/receipts/$attachmentId/receipt.jpg',
  'mime_type': 'image/jpeg',
  'byte_size': bytes.length,
  'sha256_hex': sha256.convert(bytes).toString(),
  'position': 0,
  'server_version': 1,
  'server_revision': 1,
  'created_at': '2026-09-23T00:00:00.000Z',
  'updated_at': '2026-09-23T00:00:00.000Z',
  'deleted_at': null,
};

SyncChange receiptChange({
  String origin = otherDevice,
  SyncOperation operation = SyncOperation.create,
}) => SyncChange(
  sequence: 1,
  entityType: SyncEntityType.receiptAttachment,
  entityId: attachmentId,
  serverVersion: 1,
  operation: operation,
  originDeviceId: origin,
  mutationId: mutationId,
  snapshot: receiptSnapshot(const [1, 2, 3]),
);

SyncChange receiptChangeFor(
  String id, {
  required int sequence,
  required int position,
  SyncOperation operation = SyncOperation.create,
  bool deleted = false,
}) {
  const bytes = <int>[1, 2, 3];
  return SyncChange(
    sequence: sequence,
    entityType: SyncEntityType.receiptAttachment,
    entityId: id,
    serverVersion: 1,
    operation: operation,
    originDeviceId: otherDevice,
    mutationId: id,
    snapshot: {
      'id': id,
      'profile_id': profileId,
      'transaction_id': transactionId,
      'storage_path': '$cloudId/receipts/$id/receipt.jpg',
      'mime_type': 'image/jpeg',
      'byte_size': bytes.length,
      'sha256_hex': sha256.convert(bytes).toString(),
      'position': position,
      'server_version': 1,
      'server_revision': sequence,
      'created_at': '2026-09-23T00:00:00.000Z',
      'updated_at': '2026-09-23T00:00:00.000Z',
      'deleted_at': deleted ? '2026-09-23T00:00:00.000Z' : null,
    },
  );
}

SyncChangePage pagingPage(int count, {String origin = otherDevice}) =>
    SyncChangePage(
      changes: List.generate(
        count,
        (index) => SyncChange(
          sequence: index + 1,
          entityType: SyncEntityType.category,
          entityId: categoryId,
          serverVersion: index + 1,
          operation: SyncOperation.update,
          originDeviceId: origin,
          mutationId:
              '00000000-0000-4000-8000-'
              '${index.toRadixString(16).padLeft(12, '0')}',
          snapshot: {'name': 'revision-${index + 1}'},
        ),
      ),
    );

SyncChange change(
  int sequence,
  Map<String, Object?> snapshot, {
  String origin = otherDevice,
}) => SyncChange(
  sequence: sequence,
  entityType: SyncEntityType.category,
  entityId: categoryId,
  serverVersion: snapshot['server_version']! as int,
  operation: SyncOperation.update,
  originDeviceId: origin,
  mutationId: mutationId,
  snapshot: snapshot,
);

final class _Clock implements Clock {
  _Clock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
}

final class _Ids implements IdGenerator {
  var value = 8;
  @override
  LocalId generate() {
    final digit = value++;
    return LocalId('88888888-8888-4888-8888-88888888888${digit % 10}');
  }
}

final class _Remote implements SyncRemoteStore, SyncDeviceAcknowledger {
  _Remote({this.failure, this.ackFailure});
  final FailureCode? failure, ackFailure;
  int calls = 0;
  int? acknowledgedRevision;
  String? acknowledgedDevice;

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
  Future<Result<SyncMutationResult>> applyMutation(
    SyncMutation mutation,
  ) async {
    calls++;
    return failure == null
        ? Success(
            SyncMutationResult(
              status: SyncMutationStatus.applied,
              serverVersion: calls,
              serverRevision: calls,
            ),
          )
        : Failure(failure!);
  }

  @override
  Future<Result<SyncChangePage>> fetchChanges({
    required int afterSequence,
    int limit = maximumSyncPageSize,
  }) async => Success(
    SyncChangePage(datasetGeneration: datasetGeneration, changes: []),
  );
}

final class _ConflictRemote implements SyncRemoteStore {
  const _ConflictRemote();

  @override
  Future<Result<SyncMutationResult>> applyMutation(
    SyncMutation mutation,
  ) async => const Success(
    SyncMutationResult(
      status: SyncMutationStatus.conflict,
      serverVersion: 5,
      serverRevision: 5,
      remoteSnapshot: {'name': 'Remote candidate'},
    ),
  );

  @override
  Future<Result<SyncChangePage>> fetchChanges({
    required int afterSequence,
    int limit = maximumSyncPageSize,
  }) async => Success(SyncChangePage(changes: const []));
}

final class _PagingRemote implements SyncRemoteStore {
  _PagingRemote(this.page);
  final SyncChangePage page;

  @override
  Future<Result<SyncMutationResult>> applyMutation(
    SyncMutation mutation,
  ) async => throw StateError('No push expected');

  @override
  Future<Result<SyncChangePage>> fetchChanges({
    required int afterSequence,
    int limit = maximumSyncPageSize,
  }) async => Success(
    page.datasetGeneration == null
        ? SyncChangePage(
            datasetGeneration: '88000000-0000-4000-8000-000000000001',
            changes: page.changes,
          )
        : page,
  );
}

final class _PagingLocal implements SyncRuntimeLocalStore {
  _PagingLocal({required this.conflicts});
  final int conflicts;
  var cursor = 0;

  @override
  Future<Result<SyncExecutionContext>> readExecutionContext() async =>
      const Success(
        SyncExecutionContext(
          linkedAccountId: cloudId,
          deviceId: deviceId,
          syncEnabled: true,
          needsReconciliation: false,
          datasetGeneration: '88000000-0000-4000-8000-000000000001',
        ),
      );

  @override
  Future<Result<PendingSyncMutation?>> nextDueMutation(DateTime nowUtc) async =>
      const Success(null);

  @override
  Future<Result<bool>> hasImmediatelyEligiblePush(DateTime nowUtc) async =>
      const Success(false);

  @override
  Future<Result<SyncCursor>> readCursor() async => Success(SyncCursor(cursor));

  @override
  Future<Result<SyncPageApplyResult>> applyPageAtomically(
    SyncChangePage page, {
    required String localDeviceId,
  }) async {
    cursor = page.maximumSequence ?? cursor;
    return Success(SyncPageApplyResult(applied: 0, conflicts: conflicts));
  }

  @override
  Future<Result<void>> recoverInterruptedProcessing() async =>
      const Success(null);
  @override
  Future<Result<int?>> resolveDeferredBase(
    PendingSyncMutation mutation,
  ) async => const Success(null);
  @override
  Future<Result<void>> markAttemptStarted(
    String mutationId,
    DateTime nowUtc,
  ) async => const Success(null);
  @override
  Future<Result<void>> deferRetry(
    String mutationId,
    FailureCode failure,
    DateTime nextAttemptUtc,
  ) async => const Success(null);
  @override
  Future<Result<void>> acknowledgeMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  ) async => const Success(null);
  @override
  Future<Result<void>> blockMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  ) async => const Success(null);
  @override
  Future<Result<void>> commitAppliedPage(SyncChangePage page) async =>
      const Success(null);
  @override
  Future<Result<void>> markNeedsReconciliationAfterRestore() async =>
      const Success(null);
  @override
  Future<Result<void>> scheduleAttachmentCleanup(String storagePath) async =>
      const Success(null);
  @override
  Future<Result<List<String>>> dueAttachmentCleanup(DateTime nowUtc) async =>
      const Success([]);
  @override
  Future<Result<void>> completeAttachmentCleanup(String storagePath) async =>
      const Success(null);
  @override
  Future<Result<void>> markNeedsReconciliation() async => const Success(null);
  @override
  Future<Result<void>> recordSuccessfulSync(DateTime nowUtc) async =>
      const Success(null);
  @override
  Future<Result<void>> resolveConflictKeepCloud({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
  }) async => const Success(null);
}

final class _FaultingPullFiles implements SyncReceiptPullFiles {
  _FaultingPullFiles(
    this.root, {
    this.throwRemoveAfterCommit = false,
    this.throwCompensateFor,
    this.onPrepare,
  });

  final Directory root;
  final bool throwRemoveAfterCommit;
  final String? throwCompensateFor;
  final Future<void> Function(SyncChange change)? onPrepare;
  final List<String> rolledBack = <String>[];

  @override
  Future<Result<PreparedSyncReceipt>> prepare(SyncChange change) async {
    final staging = Directory('${root.path}/.sync_staging');
    await staging.create(recursive: true);
    final staged = File('${staging.path}/${change.entityId}.pending');
    await staged.writeAsBytes(const [1, 2, 3], flush: true);
    await onPrepare?.call(change);
    return Success(
      PreparedSyncReceipt(
        storageKey: '${change.entityId}.jpg',
        stagingFile: staged,
        liveFile: File('${root.path}/${change.entityId}.jpg'),
      ),
    );
  }

  @override
  Future<Result<String>> promote(PreparedSyncReceipt prepared) async {
    await (prepared.stagingFile as File).rename(
      (prepared.liveFile as File).path,
    );
    prepared.promoted = true;
    return Success(prepared.storageKey);
  }

  @override
  Future<Result<void>> compensate(PreparedSyncReceipt prepared) async {
    if (prepared.storageKey == '$throwCompensateFor.jpg') {
      throw const FileSystemException('simulated staging cleanup failure');
    }
    final staged = prepared.stagingFile as File;
    if (await staged.exists()) await staged.delete();
    return const Success(null);
  }

  @override
  Future<Result<void>> rollbackPromotion(PreparedSyncReceipt prepared) async {
    rolledBack.add(prepared.storageKey);
    final live = prepared.liveFile as File;
    if (await live.exists()) await live.delete();
    return const Success(null);
  }

  @override
  Future<Result<void>> removeAfterCommit(String storageKey) async {
    if (throwRemoveAfterCommit) {
      throw const FileSystemException('simulated tombstone cleanup failure');
    }
    final file = File('${root.path}/$storageKey');
    if (await file.exists()) await file.delete();
    return const Success(null);
  }
}

final class _ReceiptTransport implements SyncReceiptTransport {
  const _ReceiptTransport(this.bytes);
  final List<int> bytes;

  @override
  Future<Result<void>> delete(String objectPath) async => const Success(null);

  @override
  Future<Result<List<int>>> download(String objectPath) async => Success(bytes);

  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async => const Success(null);
}

final class _CountingReceiptTransport implements SyncReceiptTransport {
  _CountingReceiptTransport(this.bytes);
  final List<int> bytes;
  int downloads = 0;

  @override
  Future<Result<List<int>>> download(String objectPath) async {
    downloads++;
    return Success(bytes);
  }

  @override
  Future<Result<void>> delete(String objectPath) async => const Success(null);

  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async => const Success(null);
}

final class _FailingReceiptTransport implements SyncReceiptTransport {
  const _FailingReceiptTransport(this.failure);
  final FailureCode failure;

  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async => Failure(failure);

  @override
  Future<Result<List<int>>> download(String objectPath) async =>
      Failure(failure);

  @override
  Future<Result<void>> delete(String objectPath) async => Failure(failure);
}
