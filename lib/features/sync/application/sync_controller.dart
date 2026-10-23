import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../domain/sync_protocol.dart';
import 'sync_conflict_service.dart';
import 'sync_automatic_contracts.dart';
import 'sync_contracts.dart';
import 'sync_engine.dart';
import 'sync_onboarding_service.dart';
import 'sync_receipt_spool.dart';

final class SyncController extends ChangeNotifier
    implements SyncTriggerTarget, SyncRetryScheduleSource {
  SyncController({
    required this.local,
    required this.onboarding,
    required this.engine,
    required this.conflicts,
    required this.authenticatedAccountId,
    this.receiptSpool,
    this.maximumManualCycles = 3,
  });

  final SyncOnboardingLocalStore local;
  final SyncOnboardingService onboarding;
  final SyncEngine engine;
  final SyncConflictService conflicts;
  final String? Function() authenticatedAccountId;
  final int maximumManualCycles;
  final SyncReceiptSpool? receiptSpool;

  SyncDurableState? durable;
  SyncDiscovery? discovery;
  List<SyncConflictItem> unresolved = const [];
  FailureCode? failure;
  bool busy = false;
  bool pullCaughtUp = false;
  SyncOnboardingProgress? progress;
  Future<Result<SyncRunSummary>>? _activeRun;
  bool _followUpRequested = false;
  String? lastTriggerReason;

  SyncUserStatus get status {
    if (busy) return SyncUserStatus.syncing;
    final state = durable;
    if (state == null) return SyncUserStatus.temporarilyUnavailable;
    if (state.linkedAccountId != null &&
        authenticatedAccountId() != state.linkedAccountId) {
      return SyncUserStatus.authenticationRequired;
    }
    if (state.needsReconciliation) return SyncUserStatus.needsReconciliation;
    if (state.stage == SyncOnboardingStage.localToCloud ||
        state.stage == SyncOnboardingStage.cloudToLocal ||
        state.stage == SyncOnboardingStage.reconciling ||
        state.stage == SyncOnboardingStage.failed) {
      return SyncUserStatus.initializationRequired;
    }
    if (!state.syncEnabled) {
      return authenticatedAccountId() == null
          ? SyncUserStatus.localOnly
          : SyncUserStatus.signedInDisabled;
    }
    if (state.paused) return SyncUserStatus.paused;
    if (state.unresolvedConflicts > 0) return SyncUserStatus.conflicts;
    if (failure == FailureCode.syncNetworkUnavailable ||
        failure == FailureCode.syncBackendUnavailable) {
      return SyncUserStatus.temporarilyUnavailable;
    }
    if (pullCaughtUp && state.pendingChanges == 0) {
      return SyncUserStatus.upToDate;
    }
    return SyncUserStatus.active;
  }

  Future<void> load() async {
    final state = await local.readDurableState();
    if (state case Success<SyncDurableState>(:final value)) {
      durable = value;
      failure = null;
      final authenticated = authenticatedAccountId();
      if (value.linkedAccountId != null &&
          authenticated != null &&
          value.linkedAccountId != authenticated &&
          !value.needsReconciliation) {
        final marked = await local.requireReconciliation();
        if (marked is Failure<void>) {
          failure = marked.code;
        } else {
          final refreshed = await local.readDurableState();
          if (refreshed is Success<SyncDurableState>) durable = refreshed.value;
        }
      }
    } else {
      failure = (state as Failure<SyncDurableState>).code;
    }
    await _loadConflicts();
    notifyListeners();
  }

  Future<Result<SyncDiscovery>> beginEnable() async {
    final account = authenticatedAccountId();
    if (account == null) {
      return const Failure(FailureCode.syncAuthenticationRequired);
    }
    if (durable?.linkedAccountId != null &&
        durable!.linkedAccountId != account) {
      return const Failure(FailureCode.syncNeedsReconciliation);
    }
    busy = true;
    progress = SyncOnboardingProgress.checking;
    failure = null;
    notifyListeners();
    final result = await onboarding.discover();
    if (result case Success<SyncDiscovery>(:final value)) discovery = value;
    if (result case Failure<SyncDiscovery>(:final code)) failure = code;
    busy = false;
    progress = null;
    notifyListeners();
    return result;
  }

  Future<Result<void>> confirm(SyncOnboardingChoice choice) async {
    final account = authenticatedAccountId();
    final current = discovery;
    if (account == null || current == null) {
      return const Failure(FailureCode.syncAuthenticationRequired);
    }
    busy = true;
    progress = SyncOnboardingProgress.preparing;
    failure = null;
    notifyListeners();
    final result = await onboarding.confirm(
      accountId: account,
      discovery: current,
      choice: choice,
      onProgress: (value) {
        progress = value;
        notifyListeners();
      },
    );
    final onboardingFailure = result is Failure<void> ? result.code : null;
    if (result is Success<void> && choice != SyncOnboardingChoice.cancel) {
      discovery = null;
      // Initialization establishes the link but is not proof that no newer
      // server revisions exist. Only a real caught-up engine cycle may set it.
      pullCaughtUp = false;
    }
    busy = false;
    progress = null;
    await load();
    failure = onboardingFailure;
    notifyListeners();
    return result;
  }

  Future<Result<SyncRunSummary>> syncNow() =>
      requestSync(reason: 'manual', automatic: false);

  /// Single-flight entrypoint shared by manual, lifecycle and background hints.
  Future<Result<SyncRunSummary>> requestSync({
    required String reason,
    required bool automatic,
    int? maximumCycles,
  }) {
    final active = _activeRun;
    if (active != null) {
      _followUpRequested = true;
      lastTriggerReason = reason;
      notifyListeners();
      return active;
    }
    final run = _runSync(
      reason: reason,
      automatic: automatic,
      maximumCycles: maximumCycles ?? maximumManualCycles,
    );
    _activeRun = run;
    return run.whenComplete(() {
      _activeRun = null;
      if (_followUpRequested &&
          durable?.syncEnabled == true &&
          durable?.paused == false &&
          durable?.needsReconciliation == false) {
        _followUpRequested = false;
        unawaited(requestSync(reason: 'coalescedFollowUp', automatic: true));
      } else {
        _followUpRequested = false;
      }
    });
  }

  Future<Result<SyncRunSummary>> _runSync({
    required String reason,
    required bool automatic,
    required int maximumCycles,
  }) async {
    if (durable?.paused == true) return const Failure(FailureCode.syncPaused);
    lastTriggerReason = reason;
    busy = true;
    pullCaughtUp = false;
    failure = null;
    notifyListeners();
    var total = const SyncRunSummary();
    for (var cycle = 0; cycle < maximumCycles; cycle++) {
      final result = await engine.runCycle(
        authenticatedAccountId: authenticatedAccountId(),
      );
      if (result is Failure<SyncRunSummary>) {
        final runFailure = result.code;
        busy = false;
        await load();
        failure = runFailure;
        notifyListeners();
        return result;
      }
      final value = (result as Success<SyncRunSummary>).value;
      total = SyncRunSummary(
        pushed: total.pushed + value.pushed,
        pulled: total.pulled + value.pulled,
        conflicts: total.conflicts + value.conflicts,
        retriesDeferred: total.retriesDeferred + value.retriesDeferred,
        blocked: total.blocked + value.blocked,
        moreWorkAvailable: value.moreWorkAvailable,
        failure: value.failure,
      );
      if (!value.moreWorkAvailable || value.conflicts > 0) break;
    }
    pullCaughtUp = !total.moreWorkAvailable && total.failure == null;
    final runFailure = total.failure;
    busy = false;
    await load();
    failure = runFailure;
    notifyListeners();
    return Success(total);
  }

  Future<void> markNeedsReconciliation() async {
    await local.requireReconciliation();
    pullCaughtUp = false;
    await load();
  }

  @override
  Future<Result<DateTime?>> earliestPendingRetryAt() =>
      engine.earliestPendingRetryAt();

  Future<Result<void>> pause(bool value) async {
    final result = await local.setPaused(value);
    if (result is Failure<void>) failure = result.code;
    await load();
    return result;
  }

  Future<Result<void>> unlink() async {
    final state = durable;
    if (state?.operationId != null && state?.generation != null) {
      // Best effort: local unlink remains available offline. The finite
      // server lease makes an unconfirmed abort recoverable later.
      await onboarding.abort(
        operationId: state!.operationId!,
        generation: state.generation!,
      );
    }
    if (state?.generation != null &&
        state?.linkedAccountId != null &&
        authenticatedAccountId() == state!.linkedAccountId) {
      // Best effort: an offline/auth-failed server unlink must never prevent
      // the device from becoming Local Only.
      await onboarding.unlinkDevice(state.generation!);
    }
    final result = await local.unlink();
    if (result is Success<void>) await receiptSpool?.clearAll();
    if (result is Failure<void>) failure = result.code;
    discovery = null;
    pullCaughtUp = false;
    await load();
    return result;
  }

  Future<Result<void>> resolve(
    SyncConflictItem conflict,
    SyncConflictChoice choice,
  ) async {
    final generation = durable?.generation;
    if (generation == null) {
      return const Failure(FailureCode.syncNeedsReconciliation);
    }
    busy = true;
    notifyListeners();
    final result = await conflicts.resolve(
      conflict: conflict,
      choice: choice,
      generation: generation,
    );
    if (result is Failure<void>) failure = result.code;
    busy = false;
    await load();
    return result;
  }

  Future<void> _loadConflicts() async {
    final result = await conflicts.list();
    unresolved = result is Success<List<SyncConflictItem>>
        ? result.value
        : const [];
  }
}
