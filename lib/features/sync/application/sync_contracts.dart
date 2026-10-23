import '../../../core/result.dart';
import '../domain/sync_protocol.dart';

final class SyncExecutionContext {
  const SyncExecutionContext({
    required this.linkedAccountId,
    required this.deviceId,
    required this.syncEnabled,
    required this.needsReconciliation,
    this.datasetGeneration,
    this.paused = false,
  });
  final String? linkedAccountId;
  final String deviceId;
  final String? datasetGeneration;
  final bool syncEnabled, needsReconciliation;
  final bool paused;
}

final class PendingSyncMutation {
  const PendingSyncMutation({
    required this.queueSequence,
    required this.mutationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.baseServerVersion,
    required this.payload,
    required this.attemptCount,
  });
  final int queueSequence, attemptCount;
  final String mutationId, entityId;
  final SyncEntityType entityType;
  final SyncOperation operation;
  final int? baseServerVersion;
  final Map<String, Object?> payload;

  PendingSyncMutation withResolvedBase(int value) => PendingSyncMutation(
    queueSequence: queueSequence,
    mutationId: mutationId,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    baseServerVersion: value,
    payload: payload,
    attemptCount: attemptCount,
  );
}

final class PreparedSyncReceipt {
  PreparedSyncReceipt({
    required this.storageKey,
    required this.stagingFile,
    required this.liveFile,
  });

  final String storageKey;
  final Object stagingFile;
  final Object liveFile;
  bool promoted = false;
}

final class SyncPageApplyResult {
  const SyncPageApplyResult({required this.applied, required this.conflicts});
  final int applied, conflicts;
}

abstract interface class SyncRemoteStore {
  Future<Result<SyncMutationResult>> applyMutation(SyncMutation mutation);
  Future<Result<SyncChangePage>> fetchChanges({
    required int afterSequence,
    int limit = maximumSyncPageSize,
  });
}

abstract interface class SyncDeviceAcknowledger {
  Future<Result<void>> acknowledgeDevice({
    required String deviceId,
    required String generation,
    required int revision,
  });
}

/// Provider-neutral server lifecycle operations for this installation.
abstract interface class SyncDeviceRegistrationRemote
    implements SyncDeviceAcknowledger {
  Future<Result<void>> unlinkDevice({
    required String deviceId,
    required String generation,
  });
}

abstract interface class SyncLocalStateStore {
  Future<Result<SyncCursor>> readCursor();
  Future<Result<void>> commitAppliedPage(SyncChangePage page);
  Future<Result<void>> markNeedsReconciliationAfterRestore();
}

abstract interface class SyncRuntimeLocalStore implements SyncLocalStateStore {
  Future<Result<SyncExecutionContext>> readExecutionContext();
  Future<Result<void>> recoverInterruptedProcessing();
  Future<Result<PendingSyncMutation?>> nextDueMutation(DateTime nowUtc);
  Future<Result<int?>> resolveDeferredBase(PendingSyncMutation mutation);
  Future<Result<void>> markAttemptStarted(String mutationId, DateTime nowUtc);
  Future<Result<void>> deferRetry(
    String mutationId,
    FailureCode failure,
    DateTime nextAttemptUtc,
  );
  Future<Result<void>> acknowledgeMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  );
  Future<Result<void>> blockMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  );
  Future<Result<SyncPageApplyResult>> applyPageAtomically(
    SyncChangePage page, {
    required String localDeviceId,
  });
  Future<Result<bool>> hasImmediatelyEligiblePush(DateTime nowUtc);
  Future<Result<void>> scheduleAttachmentCleanup(String storagePath);
  Future<Result<List<String>>> dueAttachmentCleanup(DateTime nowUtc);
  Future<Result<void>> completeAttachmentCleanup(String storagePath);
  Future<Result<void>> markNeedsReconciliation();
  Future<Result<void>> recordSuccessfulSync(DateTime nowUtc);
  Future<Result<void>> resolveConflictKeepCloud({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
  });
}

abstract interface class SyncRetryScheduleStore {
  Future<Result<DateTime?>> earliestPendingRetryAt();
}

abstract interface class SyncOnboardingRemoteStore {
  Future<Result<SyncCloudDiscovery>> discover();
  Future<Result<SyncInitializationLease>> beginInitialization({
    required String operationId,
    required SyncOnboardingChoice choice,
  });
  Future<Result<SyncInitialEntityResult>> uploadInitialEntity({
    required SyncInitializationLease lease,
    required String deviceId,
    required SyncInitialEntity entity,
  });
  Future<Result<int>> finalizeInitialization(SyncInitializationLease lease);
  Future<Result<void>> abortInitialization(SyncInitializationLease lease);
  Future<Result<SyncSnapshotPage>> fetchSnapshotPage({
    required String generation,
    required int highWaterRevision,
    required int offset,
    int limit = maximumSyncPageSize,
  });
  Future<Result<SyncCanonicalEntity>> fetchCurrentEntity({
    required String generation,
    required SyncEntityType entityType,
    required String entityId,
  });
}

abstract interface class SyncOnboardingLocalStore {
  Future<Result<SyncLedgerSummary>> summarizeLocal();
  Future<Result<SyncDurableState>> readDurableState();
  Future<Result<String>> beginOnboarding(SyncOnboardingStage stage);
  Future<Result<void>> bindInitialization({
    required String accountId,
    required String generation,
  });
  Future<Result<List<SyncInitialEntity>>> readInitialEntities();
  Future<Result<void>> activate({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntityResult> entityStates,
  });
  Future<Result<void>> replaceWithCloudSnapshot({
    required String accountId,
    required String generation,
    required int cursor,
    required List<SyncInitialEntity> entities,
    required Map<String, List<int>> receiptBytes,
  });
  Future<Result<void>> failOnboarding();
  Future<Result<void>> setPaused(bool paused);
  Future<Result<void>> requireReconciliation();
  Future<Result<void>> unlink();
}

abstract interface class SyncConflictRemoteStore {
  Future<Result<SyncCanonicalEntity>> fetchCurrentEntity({
    required String generation,
    required SyncEntityType entityType,
    required String entityId,
  });
}

abstract interface class SyncConflictLocalStore {
  Future<Result<List<SyncConflictItem>>> unresolvedConflicts();
  Future<Result<void>> keepLocal({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
    required String generation,
  });
  Future<Result<void>> keepCloud({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
  });
}

abstract interface class SyncReceiptTransport {
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  });
  Future<Result<List<int>>> download(String objectPath);
  Future<Result<void>> delete(String objectPath);
}

abstract interface class SyncReceiptPullFiles {
  Future<Result<PreparedSyncReceipt>> prepare(SyncChange change);
  Future<Result<String>> promote(PreparedSyncReceipt prepared);
  Future<Result<void>> compensate(PreparedSyncReceipt prepared);
  Future<Result<void>> rollbackPromotion(PreparedSyncReceipt prepared);
  Future<Result<void>> removeAfterCommit(String storageKey);
}
