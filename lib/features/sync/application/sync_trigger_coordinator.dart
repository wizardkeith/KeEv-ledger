import 'dart:async';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../domain/sync_protocol.dart';
import 'sync_automatic_contracts.dart';

enum SyncTriggerReason {
  coldStart,
  appResume,
  connectivityRestored,
  realtimeInvalidation,
  manual,
  retryDue,
  backgroundRefresh,
}

abstract interface class SyncRealtimeHints {
  Future<Result<void>> subscribe({
    required String accountId,
    required String generation,
    required void Function(String generation) onInvalidated,
  });
  Future<void> unsubscribe();
}

/// Decides when to run the durable engine. It never applies remote payloads.
final class SyncTriggerCoordinator {
  SyncTriggerCoordinator({
    required this.controller,
    required this.clock,
    this.realtime,
    this.minimumAutomaticInterval = const Duration(seconds: 45),
    this.connectivityDebounce = const Duration(seconds: 3),
  });

  final SyncTriggerTarget controller;
  final Clock clock;
  final SyncRealtimeHints? realtime;
  final Duration minimumAutomaticInterval, connectivityDebounce;

  bool _foreground = false;
  bool _disposed = false;
  bool _onlineHint = true;
  DateTime? _lastAutomaticAttempt;
  Timer? _connectivityTimer;
  Timer? _retryTimer;
  String? _subscribedGeneration;

  Future<void> coldStart() async {
    _foreground = true;
    await controller.load();
    await _refreshRealtime();
    await trigger(SyncTriggerReason.coldStart);
    await _rescheduleRetry();
  }

  Future<void> resumed() async {
    _foreground = true;
    await controller.load();
    await _refreshRealtime();
    await trigger(SyncTriggerReason.appResume);
    await _rescheduleRetry();
  }

  Future<void> accountStateChanged() async {
    await controller.load();
    if (!_foreground) return;
    await _refreshRealtime();
    await trigger(SyncTriggerReason.appResume, force: true);
  }

  void stateChanged() {
    if (_disposed) return;
    if (!_eligible(controller.durable)) {
      _retryTimer?.cancel();
      unawaited(_unsubscribeRealtime());
      return;
    }
    unawaited(_rescheduleRetry());
  }

  Future<void> leftForeground() async {
    _foreground = false;
    _connectivityTimer?.cancel();
    _retryTimer?.cancel();
    await _unsubscribeRealtime();
  }

  void connectivityChanged(bool potentiallyOnline) {
    final wasOnline = _onlineHint;
    _onlineHint = potentiallyOnline;
    if (!_foreground || !potentiallyOnline || wasOnline) return;
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer(connectivityDebounce, () {
      unawaited(trigger(SyncTriggerReason.connectivityRestored));
    });
  }

  Future<Result<SyncRunSummary>?> trigger(
    SyncTriggerReason reason, {
    bool force = false,
  }) async {
    if (_disposed ||
        (!_foreground && reason != SyncTriggerReason.backgroundRefresh)) {
      return null;
    }
    final state = controller.durable;
    if (!_eligible(state)) return null;
    final automatic = reason != SyncTriggerReason.manual;
    final now = clock.nowUtc();
    if (automatic &&
        !force &&
        _lastAutomaticAttempt != null &&
        now.difference(_lastAutomaticAttempt!) < minimumAutomaticInterval) {
      return null;
    }
    if (automatic) _lastAutomaticAttempt = now;
    final result = await controller.requestSync(
      reason: reason.name,
      automatic: automatic,
    );
    await _rescheduleRetry();
    return result;
  }

  Future<void> _rescheduleRetry() async {
    _retryTimer?.cancel();
    if (!_foreground ||
        controller is! SyncRetryScheduleSource ||
        !_eligible(controller.durable))
      return;
    final result = await (controller as SyncRetryScheduleSource)
        .earliestPendingRetryAt();
    if (result is! Success<DateTime?> || result.value == null) return;
    final delay = result.value!.difference(clock.nowUtc());
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      unawaited(trigger(SyncTriggerReason.retryDue, force: true));
    });
  }

  Future<void> _refreshRealtime() async {
    final hints = realtime;
    final state = controller.durable;
    if (hints == null || !_eligible(state)) {
      await _unsubscribeRealtime();
      return;
    }
    if (_subscribedGeneration == state!.generation) return;
    await _unsubscribeRealtime();
    final result = await hints.subscribe(
      accountId: state.linkedAccountId!,
      generation: state.generation!,
      onInvalidated: (remoteGeneration) {
        if (remoteGeneration != state.generation) {
          unawaited(controller.markNeedsReconciliation());
          return;
        }
        unawaited(trigger(SyncTriggerReason.realtimeInvalidation, force: true));
      },
    );
    if (result is Success<void>) _subscribedGeneration = state.generation;
  }

  bool _eligible(SyncDurableState? state) =>
      _foreground &&
      state != null &&
      state.syncEnabled &&
      !state.paused &&
      !state.needsReconciliation &&
      state.linkedAccountId != null &&
      state.generation != null &&
      controller.authenticatedAccountId() == state.linkedAccountId;

  Future<void> _unsubscribeRealtime() async {
    _subscribedGeneration = null;
    await realtime?.unsubscribe();
  }

  Future<void> dispose() async {
    _disposed = true;
    _connectivityTimer?.cancel();
    _retryTimer?.cancel();
    await _unsubscribeRealtime();
  }
}

/// UI-free, bounded entrypoint suitable for a future native background host.
/// Correctness never depends on the host actually scheduling this service.
final class SyncBackgroundWorker {
  const SyncBackgroundWorker(this.controller, {this.maximumCycles = 1});
  final SyncTriggerTarget controller;
  final int maximumCycles;

  Future<Result<SyncRunSummary>?> run() async {
    await controller.load();
    final state = controller.durable;
    if (state == null ||
        !state.syncEnabled ||
        state.paused ||
        state.needsReconciliation ||
        state.generation == null ||
        controller.authenticatedAccountId() != state.linkedAccountId) {
      return null;
    }
    return controller.requestSync(
      reason: SyncTriggerReason.backgroundRefresh.name,
      automatic: true,
      maximumCycles: maximumCycles,
    );
  }
}
