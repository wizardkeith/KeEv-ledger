import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/account/infrastructure/supabase/supabase_backup_remote.dart';
import 'package:ledger/features/backup/data/drift_ledger_backup_store.dart';
import 'package:ledger/features/sync/data/drift_sync_state_store.dart';
import 'package:ledger/features/sync/domain/sync_protocol.dart';
import 'package:ledger/features/sync/infrastructure/supabase_sync_remote_store.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    hide SyncCursor;

void main() {
  const mutationId = '11111111-1111-4111-8111-111111111111';
  const deviceId = '22222222-2222-4222-8222-222222222222';
  const entityId = '33333333-3333-4333-8333-333333333333';

  test('mutation base versions and stable retry identity are explicit', () {
    final create = SyncMutation(
      mutationId: mutationId,
      deviceId: deviceId,
      entityType: SyncEntityType.account,
      entityId: entityId,
      operation: SyncOperation.create,
      baseServerVersion: 0,
      payload: const {},
    );
    expect(create.mutationId, mutationId);
    expect(create.baseServerVersion, 0);
    for (final operation in [SyncOperation.update, SyncOperation.delete]) {
      expect(
        SyncMutation(
          mutationId: mutationId,
          deviceId: deviceId,
          entityType: SyncEntityType.transaction,
          entityId: entityId,
          operation: operation,
          baseServerVersion: 3,
          payload: const {},
        ).baseServerVersion,
        3,
      );
    }
    expect(
      () => SyncMutation(
        mutationId: mutationId,
        deviceId: deviceId,
        entityType: SyncEntityType.account,
        entityId: entityId,
        operation: SyncOperation.update,
        baseServerVersion: 0,
        payload: const {},
      ),
      throwsFormatException,
    );
  });

  test('mutation results parse applied, replay and conflict safely', () {
    for (final status in ['APPLIED', 'ALREADY_APPLIED']) {
      final result = SupabaseSyncRemoteStore.parseMutationResult({
        'status': status,
        'server_version': 2,
        'server_revision': 9,
      });
      expect(result.serverVersion, 2);
      expect(result.serverRevision, 9);
    }
    final conflict = SupabaseSyncRemoteStore.parseMutationResult({
      'status': 'CONFLICT',
      'server_version': 4,
      'server_revision': 8,
      'remote_snapshot': {'id': entityId},
    });
    expect(conflict.status, SyncMutationStatus.conflict);
    expect(conflict.failure, FailureCode.syncConflict);
    expect(
      () => SupabaseSyncRemoteStore.parseMutationResult({'status': 'MAYBE'}),
      throwsFormatException,
    );
    expect(
      () => SupabaseSyncRemoteStore.parseMutationResult({'status': 'APPLIED'}),
      throwsFormatException,
    );
  });

  test('change pages are strictly ordered and expose a post-apply cursor', () {
    SyncChange change(int sequence) => SyncChange(
      sequence: sequence,
      entityType: SyncEntityType.transaction,
      entityId: entityId,
      serverVersion: sequence,
      operation: SyncOperation.update,
      originDeviceId: deviceId,
      mutationId: mutationId,
      snapshot: const {'id': entityId},
    );
    final page = SyncChangePage(changes: [change(7), change(9)]);
    expect(page.maximumSequence, 9);
    expect(
      () => SyncChangePage(changes: [change(9), change(7)]),
      throwsFormatException,
    );
  });

  test('canonical rows are bounded by the current pull-page revision', () {
    Map<String, dynamic> row(int revision) => {
      'id': entityId,
      'entity_type': 'transaction',
      'server_version': 3,
      'server_revision': revision,
      'deleted_at': null,
    };

    for (final revision in [95, 100]) {
      final entity = SupabaseSyncRemoteStore.parseCanonicalEntity(
        row(revision),
        expectedType: SyncEntityType.transaction,
        throughSequence: 100,
      );
      expect(entity.serverRevision, revision);
      expect(entity.isDeleted, isFalse);
    }
    expect(
      () => SupabaseSyncRemoteStore.parseCanonicalEntity(
        row(105),
        expectedType: SyncEntityType.transaction,
        throughSequence: 100,
      ),
      throwsFormatException,
    );
  });

  test('malformed canonical metadata is rejected provider-neutrally', () {
    Map<String, dynamic> valid() => {
      'id': entityId,
      'entity_type': 'account',
      'server_version': 1,
      'server_revision': 1,
      'deleted_at': '2026-09-22T00:00:00Z',
    };

    for (final invalid in [
      {...valid(), 'id': 'not-a-stable-id'},
      {...valid()}..remove('server_version'),
      {...valid(), 'server_version': 0},
      {...valid()}..remove('server_revision'),
      {...valid(), 'server_revision': 0},
      {...valid(), 'entity_type': 'transaction'},
    ]) {
      expect(
        () => SupabaseSyncRemoteStore.parseCanonicalEntity(
          invalid,
          expectedType: SyncEntityType.account,
          throughSequence: 1,
        ),
        throwsFormatException,
      );
    }
  });

  test('Account A sync link cannot activate under Account B', () {
    final decision = SyncLinkPolicy.evaluate(
      linkedAccountId: 'account-a',
      authenticatedAccountId: 'account-b',
      syncEnabled: true,
      needsReconciliation: false,
    );
    expect(decision.status, SyncLinkStatus.needsReconciliation);
    expect(decision.maySendMutations, isFalse);
  });

  test('fresh v6 is unsynced with device identity and no outbox', () async {
    final db = LedgerDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final link = await db.select(db.syncLinkStates).getSingle();
    final device = await db.select(db.syncDeviceStates).getSingle();
    expect(link.cloudAccountId, equals(null));
    expect(link.syncEnabled, isFalse);
    expect(link.needsReconciliation, isFalse);
    expect(device.deviceId, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });

  test(
    'backup excludes transport state and restore requires reconciliation',
    () async {
      final db = LedgerDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      const profileId = '44444444-4444-4444-8444-444444444444';
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
      await (db.update(
        db.syncLinkStates,
      )..where((e) => e.slot.equals(1))).write(
        const SyncLinkStatesCompanion(
          cloudAccountId: Value('55555555-5555-4555-8555-555555555555'),
          state: Value('linked'),
          syncEnabled: Value(true),
          updatedAtUtc: Value(2),
        ),
      );
      await db
          .into(db.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              mutationId: mutationId,
              entityType: 'account',
              entityId: entityId,
              operation: 'update',
              baseServerVersion: const Value(1),
              payloadJson: '{}',
              createdAtUtc: 2,
            ),
          );
      final store = DriftLedgerBackupStore(db);
      final exported = await store.exportLogicalSnapshot();
      final snapshot = (exported as Success<Map<String, dynamic>>).value;
      expect(snapshot.keys, isNot(contains('syncOutbox')));
      expect(snapshot.keys, isNot(contains('syncDeviceStates')));
      expect(snapshot.keys, isNot(contains('syncCursors')));
      expect(snapshot.keys, isNot(contains('syncConflicts')));
      expect(
        await store.replaceLogicalSnapshot(snapshot),
        isA<Success<void>>(),
      );
      final link = await db.select(db.syncLinkStates).getSingle();
      expect(link.state, 'needsReconciliation');
      expect(link.syncEnabled, isFalse);
      expect(link.needsReconciliation, isTrue);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );

  test('cursor advances only through explicit applied-page commit', () async {
    final db = LedgerDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = DriftSyncStateStore(db);
    expect(
      (await store.readCursor() as Success<SyncCursor>)
          .value
          .lastAppliedSequence,
      0,
    );
    final page = SyncChangePage(
      changes: [
        SyncChange(
          sequence: 4,
          entityType: SyncEntityType.account,
          entityId: entityId,
          serverVersion: 1,
          operation: SyncOperation.update,
          originDeviceId: deviceId,
          mutationId: mutationId,
          snapshot: const {'id': entityId},
        ),
      ],
    );
    expect(
      (await store.readCursor() as Success<SyncCursor>)
          .value
          .lastAppliedSequence,
      0,
    );
    await store.commitAppliedPage(page);
    expect(
      (await store.readCursor() as Success<SyncCursor>)
          .value
          .lastAppliedSequence,
      4,
    );
  });

  test(
    'a page boundary may commit while a future canonical row is deferred',
    () async {
      final db = LedgerDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftSyncStateStore(db);
      final page = SyncChangePage(
        changes: [
          SyncChange(
            sequence: 100,
            entityType: SyncEntityType.transaction,
            entityId: entityId,
            serverVersion: 3,
            operation: SyncOperation.update,
            originDeviceId: deviceId,
            mutationId: mutationId,
            snapshot: const {'id': entityId},
          ),
        ],
      );
      expect(
        () => SupabaseSyncRemoteStore.parseCanonicalEntity(
          const {
            'id': entityId,
            'entity_type': 'transaction',
            'server_version': 4,
            'server_revision': 105,
            'deleted_at': null,
          },
          expectedType: SyncEntityType.transaction,
          throughSequence: page.maximumSequence!,
        ),
        throwsFormatException,
      );
      expect(await store.commitAppliedPage(page), isA<Success<void>>());
      expect(
        (await store.readCursor() as Success<SyncCursor>)
            .value
            .lastAppliedSequence,
        100,
      );
    },
  );

  test(
    'backup delete classification preserves metadata on non-404 failures',
    () {
      expect(
        SupabaseBackupRemote.classifyDeleteStorageFailure('404'),
        FailureCode.cloudBackupNotFound,
      );
      expect(
        SupabaseBackupRemote.classifyDeleteStorageFailure('403'),
        FailureCode.unauthorized,
      );
      expect(
        SupabaseBackupRemote.classifyDeleteStorageFailure('500'),
        FailureCode.backendUnavailable,
      );
      expect(
        SupabaseBackupRemote.classifyDeleteStorageFailure('408'),
        FailureCode.networkUnavailable,
      );
    },
  );

  test('SQL migration enforces grants, RLS and RPC security', () {
    final backup = File(
      'supabase/migrations/202609210002_encrypted_backups.sql',
    ).readAsStringSync();
    expect(backup, contains('revoke all on table public.ledger_backups'));
    expect(backup, contains('grant select, insert, delete'));
    expect(backup, isNot(contains('grant update')));

    final sql = File(
      'supabase/migrations/202609220001_sync_protocol_v1.sql',
    ).readAsStringSync();
    for (final table in [
      'sync_profiles',
      'sync_accounts',
      'sync_categories',
      'sync_transactions',
      'sync_transfers',
      'sync_projects',
      'sync_budgets',
      'sync_receipt_attachments',
      'sync_change_log',
      'sync_mutation_receipts',
    ]) {
      expect(sql, contains(table));
    }
    expect(sql, contains('enable row level security'));
    expect(sql, contains('revoke all on table'));
    expect(sql, contains('security definer'));
    expect(sql, contains("set search_path = ''"));
    expect(sql, contains('revoke all on function'));
    expect(sql, contains('from public, anon'));
    expect(sql, contains('grant execute on function'));
    expect(sql, contains('(select auth.uid()) = user_id'));
    expect(sql, contains("'ledger-sync-receipts'"));
    expect(sql, contains('public=false'));
    expect(sql, contains('(storage.foldername(name))[1]'));
    expect(sql, isNot(contains('service_role')));
    expect(
      sql,
      isNot(contains('grant insert on table public.sync_change_log')),
    );
  });

  test('Fix Gate SQL preserves schema parity and hardens mutation races', () {
    final sql = File(
      'supabase/migrations/202609220002_sync_protocol_v1_hardening.sql',
    ).readAsStringSync();
    final compact = sql.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    expect(compact, contains('unique (user_id)'));
    expect(compact, contains('unique (user_id, transaction_id, position)'));
    expect(
      compact,
      contains(
        'source_currency_code <> destination_currency_code or source_minor_units = destination_minor_units',
      ),
    );
    expect(compact, contains('check (updated_at >= created_at)'));
    expect(compact, contains('new.updated_at := new.created_at'));

    expect(compact, contains('pg_catalog.pg_advisory_xact_lock'));
    expect(compact, contains('pg_catalog.hashtextextended'));
    expect(compact, contains('required post-lock idempotency recheck'));
    expect(compact, contains("'already_applied'"));
    expect(compact, contains("'conflict'"));
    expect(compact, contains("'validation_failed'"));
    for (final validationClass in [
      'not_null_violation',
      'numeric_value_out_of_range',
      'datetime_field_overflow',
      'invalid_datetime_format',
      'invalid_text_representation',
      'check_violation',
      'foreign_key_violation',
    ]) {
      expect(compact, contains(validationClass));
    }

    expect(compact, contains("security definer set search_path = ''"));
    expect(compact, contains('from public, anon'));
    expect(compact, contains('to authenticated'));
    expect(compact, contains('sync_apply_mutation_v1_unlocked'));
    expect(compact, contains('revoke all on function'));
    expect(compact, isNot(contains('grant insert on table public.sync_')));
  });

  test('Supabase adapter requires and enforces throughSequence', () {
    final source = File(
      'lib/features/sync/infrastructure/supabase_sync_remote_store.dart',
    ).readAsStringSync();
    final domain = File(
      'lib/features/sync/domain/sync_protocol.dart',
    ).readAsStringSync();
    expect(source, contains('required int throughSequence'));
    expect(source, contains(".lte('server_revision', throughSequence)"));
    expect(domain, contains('serverRevision > throughSequence'));
  });

  test('final parity migration releases tombstoned receipt positions', () {
    final base = File(
      'supabase/migrations/202609220001_sync_protocol_v1.sql',
    ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final sql = File(
      'supabase/migrations/202609220003_sync_protocol_v1_final_parity.sql',
    ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    expect(
      sql,
      contains(
        'drop constraint if exists sync_receipts_transaction_position_unique',
      ),
    );
    expect(
      sql,
      contains(
        'create unique index if not exists sync_receipts_active_transaction_position_unique on public.sync_receipt_attachments(user_id, transaction_id, position) where deleted_at is null',
      ),
    );
    expect(base, contains('unique (user_id, storage_path)'));
    expect(sql, contains('check (length(storage_path) between 1 and 160)'));
    expect(
      sql,
      contains('check (opening_minor_units >= -9223372036854775807)'),
    );
  });

  test('final parity migration orders tombstone timestamps safely', () {
    final sql = File(
      'supabase/migrations/202609220003_sync_protocol_v1_final_parity.sql',
    ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    expect(
      sql,
      contains('check (deleted_at is null or deleted_at >= created_at)'),
    );
    expect(
      sql,
      contains(
        'if new.updated_at < new.created_at then new.updated_at := new.created_at',
      ),
    );
    expect(
      sql,
      contains(
        'if new.deleted_at is not null and new.deleted_at < new.created_at then new.deleted_at := new.created_at',
      ),
    );
    expect(sql, contains('sync_transactions_tombstone_order'));
    expect(sql, contains('sync_transfers_tombstone_order'));

    // The prior concurrency/security hardening must remain in the ordered chain.
    final prior = File(
      'supabase/migrations/202609220002_sync_protocol_v1_hardening.sql',
    ).readAsStringSync().toLowerCase();
    expect(prior, contains('pg_catalog.pg_advisory_xact_lock'));
    expect(prior, contains("set search_path = ''"));
    expect(prior, contains('from public, anon'));
  });
}
