import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/sync/application/sync_automatic_contracts.dart';
import 'package:ledger/features/sync/application/sync_connectivity.dart';
import 'package:ledger/features/sync/application/sync_trigger_coordinator.dart';
import 'package:ledger/features/sync/domain/sync_protocol.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _generation = '20000000-0000-4000-8000-000000000001';

void main() {
  test(
    'cold start and rapid resume are bounded by automatic interval',
    () async {
      final target = _Target();
      final clock = _Clock(DateTime.utc(2026, 9, 23));
      final coordinator = SyncTriggerCoordinator(
        controller: target,
        clock: clock,
      );
      await coordinator.coldStart();
      await coordinator.resumed();
      expect(target.runs, 1);
      clock.value = clock.value.add(const Duration(seconds: 46));
      await coordinator.resumed();
      expect(target.runs, 2);
    },
  );

  test(
    'pause, reconciliation, unlink and account mismatch block automation',
    () async {
      for (final state in <SyncDurableState>[
        _state(paused: true),
        _state(needsReconciliation: true),
        _state(syncEnabled: false),
        _state(linkedAccountId: null, generation: null),
      ]) {
        final target = _Target()..durable = state;
        final coordinator = SyncTriggerCoordinator(
          controller: target,
          clock: _Clock(DateTime.utc(2026)),
        );
        await coordinator.coldStart();
        expect(target.runs, 0);
      }
      final mismatch = _Target()..authenticated = 'different-account';
      final coordinator = SyncTriggerCoordinator(
        controller: mismatch,
        clock: _Clock(DateTime.utc(2026)),
      );
      await coordinator.coldStart();
      expect(mismatch.runs, 0);
    },
  );

  test(
    'generation-changing Broadcast never applies payload and reconciles',
    () async {
      final target = _Target();
      final hints = _Hints();
      final coordinator = SyncTriggerCoordinator(
        controller: target,
        clock: _Clock(DateTime.utc(2026)),
        realtime: hints,
      );
      await coordinator.coldStart();
      hints.invalidate('30000000-0000-4000-8000-000000000001');
      await Future<void>.delayed(Duration.zero);
      expect(target.reconciled, isTrue);
      expect(hints.subscriptions, 1);
    },
  );

  test('background boundary exits safely when paused', () async {
    final target = _Target()..durable = _state(paused: true);
    final result = await SyncBackgroundWorker(target).run();
    expect(result, isNull);
    expect(target.runs, 0);
  });

  test('6C-B SQL is private, minimal and acknowledgement-aware', () async {
    final sql = await File(
      'supabase/migrations/202609230005_sync_realtime_and_retention_v1.sql',
    ).readAsString();
    expect(sql, contains("'sync_invalidated'"));
    expect(sql, contains("'generation',new.generation"));
    expect(sql, contains("'newest_revision',new.sequence"));
    expect(sql, isNot(contains("'amount'")));
    expect(sql, isNot(contains("'note'")));
    expect(
      sql,
      contains(
        "revoke all on function public.sync_prune_safe_history_v1(uuid)",
      ),
    );
    expect(sql, contains("from public,anon,authenticated"));
    expect(sql, contains("interval '180 days'"));
    expect(sql, contains("interval '365 days'"));
    expect(sql, contains('pg_catalog.greatest'));
    expect(sql, contains("keev-ledger:'||(select auth.uid())::text"));
  });

  test('acknowledgement is monotonic only within one generation', () {
    expect(_ack('g1', 100, 'g1', 90), 100);
    expect(_ack('g1', 100, 'g1', 120), 120);
    expect(_ack('g1', 5000, 'g2', 20), 20);
  });

  test('retained-history floor rejects stale cursors', () {
    expect(_incrementalPullAllowed(cursor: 100, floor: 100), isTrue);
    expect(_incrementalPullAllowed(cursor: 120, floor: 100), isTrue);
    expect(_incrementalPullAllowed(cursor: 99, floor: 100), isFalse);
    expect(_incrementalPullAllowed(cursor: 50, floor: 100), isFalse);
  });

  test('retention safety migration resets generation ack and gates history', () async {
    final sql = await File(
      'supabase/migrations/202609230006_sync_retention_safety_v1.sql',
    ).readAsString();
    expect(sql, contains('history_floor_revision bigint not null default 0'));
    expect(
      sql,
      contains(
        'when public.sync_device_registrations.generation=excluded.generation',
      ),
    );
    expect(sql, contains('else excluded.acknowledged_revision'));
    expect(sql, contains('if p_after_sequence<v_floor then'));
    expect(sql, contains("'reason','HISTORY_UNAVAILABLE'"));
    expect(sql, contains('pg_catalog.greatest(history_floor_revision,v_safe)'));
    expect(sql, contains("interval '180 days'"));
    expect(sql, contains("interval '365 days'"));
    expect(sql, contains('from public,anon,authenticated'));
  });

  test(
    'stale device reconciles instead of partially applying newer history',
    () {
      const deviceCursor = 50;
      const prunedThrough = 100;
      const remainingFirstRevision = 150;
      expect(
        _incrementalPullAllowed(cursor: deviceCursor, floor: prunedThrough),
        isFalse,
      );
      expect(remainingFirstRevision, greaterThan(prunedThrough));
    },
  );

  test(
    'device lifecycle migration bounds ack and hardens own-device unlink',
    () async {
      final sql = await File(
        'supabase/migrations/202609230007_sync_device_lifecycle_safety_v1.sql',
      ).readAsString();
      expect(sql, contains('if p_revision<v_floor then'));
      expect(sql, contains("'reason','HISTORY_UNAVAILABLE'"));
      expect(sql, contains('if p_revision>v_head then'));
      expect(sql, contains("'reason','INVALID_ACK_REVISION'"));
      expect(sql, contains('user_id=v_user and device_id=p_device_id'));
      expect(sql, contains('and generation=p_generation and linked=true'));
      expect(sql, contains('else excluded.acknowledged_revision'));
      expect(sql, contains("set search_path = ''"));
      expect(sql, contains('from public,anon'));
    },
  );

  test('Android connectivity EventSink always uses the main Looper', () async {
    final source = await File(
      'android/app/src/main/kotlin/com/keev/ledger/MainActivity.kt',
    ).readAsString();
    expect(source, contains('Handler(Looper.getMainLooper())'));
    expect(
      source,
      contains(
        'if (connectivitySink === events) events.success(potentiallyOnline)',
      ),
    );
    expect('events.success'.allMatches(source), hasLength(1));
  });

  test('unlink is best effort remotely and preserves local unlink', () async {
    final source = await File(
      'lib/features/sync/application/sync_controller.dart',
    ).readAsString();
    final remote = source.indexOf('await onboarding.unlinkDevice');
    final local = source.indexOf('final result = await local.unlink()', remote);
    expect(remote, greaterThan(0));
    expect(local, greaterThan(remote));
    expect(
      source,
      contains('authenticatedAccountId() == state!.linkedAccountId'),
    );
  });

  test(
    'production connectivity binding forwards only offline-to-online hint',
    () async {
      final target = _Target();
      final coordinator = SyncTriggerCoordinator(
        controller: target,
        clock: _Clock(DateTime.utc(2026)),
        minimumAutomaticInterval: Duration.zero,
        connectivityDebounce: Duration.zero,
      );
      await coordinator.coldStart();
      final observer = _Connectivity();
      final binding = SyncConnectivityBinding(
        observer: observer,
        coordinator: coordinator,
      );
      await binding.start();
      observer.emit(false);
      observer.emit(true);
      await Future<void>.delayed(Duration.zero);
      expect(target.reasons, contains('connectivityRestored'));
      final runs = target.runs;
      observer.emit(true);
      await Future<void>.delayed(Duration.zero);
      expect(target.runs, runs);
      await binding.dispose();
      expect(observer.disposed, isTrue);
      await coordinator.dispose();
    },
  );

  test(
    'missed Realtime is recoverable by connectivity-triggered durable sync',
    () async {
      final target = _Target();
      final coordinator = SyncTriggerCoordinator(
        controller: target,
        clock: _Clock(DateTime.utc(2026)),
        minimumAutomaticInterval: Duration.zero,
        connectivityDebounce: Duration.zero,
      );
      await coordinator.coldStart();
      coordinator.connectivityChanged(false);
      coordinator.connectivityChanged(true);
      await Future<void>.delayed(Duration.zero);
      expect(target.reasons.last, 'connectivityRestored');
      await coordinator.dispose();
    },
  );
}

int _ack(
  String existingGeneration,
  int existing,
  String incomingGeneration,
  int incoming,
) => existingGeneration == incomingGeneration
    ? (existing > incoming ? existing : incoming)
    : incoming;

bool _incrementalPullAllowed({required int cursor, required int floor}) =>
    cursor >= floor;

SyncDurableState _state({
  bool paused = false,
  bool needsReconciliation = false,
  bool syncEnabled = true,
  String? linkedAccountId = _account,
  String? generation = _generation,
}) => SyncDurableState(
  linkedAccountId: linkedAccountId,
  generation: generation,
  stage: SyncOnboardingStage.active,
  syncEnabled: syncEnabled,
  needsReconciliation: needsReconciliation,
  paused: paused,
  pendingChanges: 0,
  unresolvedConflicts: 0,
);

final class _Clock implements Clock {
  _Clock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
}

final class _Target implements SyncTriggerTarget {
  @override
  SyncDurableState? durable = _state();
  String? authenticated = _account;
  int runs = 0;
  final reasons = <String>[];
  bool reconciled = false;
  @override
  String? Function() get authenticatedAccountId =>
      () => authenticated;
  @override
  Future<void> load() async {}
  @override
  Future<void> markNeedsReconciliation() async => reconciled = true;
  @override
  Future<Result<SyncRunSummary>> requestSync({
    required String reason,
    required bool automatic,
    int? maximumCycles,
  }) async {
    runs++;
    reasons.add(reason);
    return const Success(SyncRunSummary());
  }
}

final class _Connectivity implements SyncConnectivityObserver {
  void Function(bool)? callback;
  bool disposed = false;
  void emit(bool online) => callback?.call(online);
  @override
  Future<void> start(void Function(bool potentiallyOnline) onChanged) async {
    callback = onChanged;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    callback = null;
  }
}

final class _Hints implements SyncRealtimeHints {
  void Function(String)? callback;
  int subscriptions = 0;
  void invalidate(String generation) => callback?.call(generation);
  @override
  Future<Result<void>> subscribe({
    required String accountId,
    required String generation,
    required void Function(String generation) onInvalidated,
  }) async {
    subscriptions++;
    callback = onInvalidated;
    return const Success(null);
  }

  @override
  Future<void> unsubscribe() async => callback = null;
}
