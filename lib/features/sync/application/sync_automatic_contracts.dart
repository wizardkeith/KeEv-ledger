import '../../../core/result.dart';
import '../domain/sync_protocol.dart';

abstract interface class SyncTriggerTarget {
  SyncDurableState? get durable;
  String? Function() get authenticatedAccountId;
  Future<void> load();
  Future<Result<SyncRunSummary>> requestSync({
    required String reason,
    required bool automatic,
    int? maximumCycles,
  });
  Future<void> markNeedsReconciliation();
}

abstract interface class SyncRetryScheduleSource {
  Future<Result<DateTime?>> earliestPendingRetryAt();
}
