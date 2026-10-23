import '../../../core/result.dart';

const syncProtocolVersion = 1;
const maximumSyncPageSize = 200;

enum SyncEntityType {
  profile,
  account,
  category,
  transaction,
  transfer,
  project,
  budget,
  receiptAttachment,
}

enum SyncOperation { create, update, delete }

enum SyncMutationStatus {
  applied,
  alreadyApplied,
  conflict,
  rejected,
  reconciliationRequired,
}

enum SyncLinkStatus { unlinked, linked, needsReconciliation }

final class SyncCursor {
  const SyncCursor(this.lastAppliedSequence);
  final int lastAppliedSequence;
}

final class SyncMutation {
  SyncMutation({
    required this.mutationId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.baseServerVersion,
    required this.payload,
    this.datasetGeneration = '',
  }) {
    if (baseServerVersion < 0 ||
        (operation == SyncOperation.create && baseServerVersion != 0) ||
        (operation != SyncOperation.create && baseServerVersion == 0)) {
      throw const FormatException('Invalid base server version');
    }
  }

  final String mutationId, deviceId, entityId, datasetGeneration;
  final SyncEntityType entityType;
  final SyncOperation operation;
  final int baseServerVersion;
  final Map<String, Object?> payload;
}

final class SyncMutationResult {
  const SyncMutationResult({
    required this.status,
    this.serverVersion,
    this.serverRevision,
    this.remoteSnapshot,
    this.isRemoteDeleted = false,
    this.failure,
  });
  final SyncMutationStatus status;
  final int? serverVersion, serverRevision;
  final Map<String, Object?>? remoteSnapshot;
  final bool isRemoteDeleted;
  final FailureCode? failure;
}

final class SyncChange {
  SyncChange({
    required this.sequence,
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.operation,
    required this.originDeviceId,
    required this.mutationId,
    required this.snapshot,
  }) {
    if (sequence < 1 ||
        serverVersion < 1 ||
        !_uuid.hasMatch(entityId) ||
        !_uuid.hasMatch(originDeviceId) ||
        !_uuid.hasMatch(mutationId) ||
        snapshot.isEmpty) {
      throw const FormatException('Invalid sync change event');
    }
  }
  final int sequence, serverVersion;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final String originDeviceId, mutationId;
  final Map<String, Object?> snapshot;

  bool get isDeleted => operation == SyncOperation.delete;

  static final RegExp _uuid = SyncCanonicalEntity._uuid;
}

final class SyncChangePage {
  SyncChangePage({required List<SyncChange> changes, this.datasetGeneration})
    : changes = List.unmodifiable(changes) {
    for (var i = 1; i < changes.length; i++) {
      if (changes[i - 1].sequence >= changes[i].sequence) {
        throw const FormatException('Changes must be strictly ordered');
      }
    }
  }
  final List<SyncChange> changes;
  final String? datasetGeneration;
  int? get maximumSequence => changes.isEmpty ? null : changes.last.sequence;
}

enum SyncOutboxState { pending, processing, blocked }

final class SyncRunSummary {
  const SyncRunSummary({
    this.pushed = 0,
    this.pulled = 0,
    this.conflicts = 0,
    this.retriesDeferred = 0,
    this.blocked = 0,
    this.moreWorkAvailable = false,
    this.failure,
  });

  final int pushed, pulled, conflicts, retriesDeferred, blocked;
  final bool moreWorkAvailable;
  final FailureCode? failure;
}

abstract final class SyncRetryPolicy {
  static Duration delayFor({
    required int attemptCount,
    required String mutationId,
  }) {
    final exponent = attemptCount.clamp(1, 8) - 1;
    final base = 2 << exponent;
    final jitter = mutationId.codeUnits.fold<int>(0, (a, b) => a + b) % 3;
    return Duration(seconds: (base + jitter).clamp(2, 300));
  }
}

/// Validated canonical server state returned for a revision-bounded pull page.
final class SyncCanonicalEntity {
  SyncCanonicalEntity({
    required this.entityType,
    required this.id,
    required this.serverVersion,
    required this.serverRevision,
    required this.isDeleted,
    required this.payload,
    required int throughSequence,
  }) {
    if (!_uuid.hasMatch(id) ||
        serverVersion < 1 ||
        serverRevision < 1 ||
        throughSequence < 1 ||
        serverRevision > throughSequence) {
      throw const FormatException('Invalid canonical sync entity');
    }
  }

  final SyncEntityType entityType;
  final String id;
  final int serverVersion, serverRevision;
  final bool isDeleted;
  final Map<String, Object?> payload;

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
}

final class SyncLinkDecision {
  const SyncLinkDecision(this.status, {required this.maySendMutations});
  final SyncLinkStatus status;
  final bool maySendMutations;
}

enum SyncDiscoveryCase { bothEmpty, localOnly, cloudOnly, bothHaveData }

enum SyncOnboardingChoice {
  enableEmpty,
  keepLocal,
  keepCloud,
  cancel,

  /// Internal trusted reset selected only after the both-sides warning.
  replaceCloud,
}

enum SyncOnboardingStage {
  idle,
  discovering,
  localToCloud,
  cloudToLocal,
  reconciling,
  active,
  failed,
}

enum SyncOnboardingProgress {
  checking,
  preparing,
  uploading,
  downloading,
  verifying,
  finalizing,
}

enum SyncUserStatus {
  localOnly,
  signedInDisabled,
  initializationRequired,
  active,
  paused,
  needsReconciliation,
  conflicts,
  authenticationRequired,
  temporarilyUnavailable,
  syncing,
  upToDate,
}

final class SyncLedgerSummary {
  const SyncLedgerSummary({
    required this.accounts,
    required this.transactions,
    required this.receipts,
    required this.baseCurrencyCode,
    this.otherRecords = 0,
    this.latestActivityDate,
  });

  final int accounts, transactions, receipts;
  final int otherRecords;
  final String? baseCurrencyCode, latestActivityDate;
  bool get hasMeaningfulData =>
      accounts > 0 || transactions > 0 || receipts > 0 || otherRecords > 0;
}

final class SyncCloudDiscovery {
  const SyncCloudDiscovery({
    required this.summary,
    required this.generation,
    required this.maximumRevision,
    required this.initializationInProgress,
  });

  final SyncLedgerSummary summary;
  final String? generation;
  final int maximumRevision;
  final bool initializationInProgress;
}

final class SyncDiscovery {
  const SyncDiscovery({required this.local, required this.cloud});
  final SyncLedgerSummary local;
  final SyncCloudDiscovery cloud;

  SyncDiscoveryCase get classification =>
      switch ((local.hasMeaningfulData, cloud.summary.hasMeaningfulData)) {
        (false, false) => SyncDiscoveryCase.bothEmpty,
        (true, false) => SyncDiscoveryCase.localOnly,
        (false, true) => SyncDiscoveryCase.cloudOnly,
        (true, true) => SyncDiscoveryCase.bothHaveData,
      };
}

final class SyncInitializationLease {
  const SyncInitializationLease({
    required this.operationId,
    required this.generation,
    required this.snapshotRevision,
  });
  final String operationId, generation;
  final int snapshotRevision;
}

final class SyncInitialEntity {
  const SyncInitialEntity({
    required this.entityType,
    required this.entityId,
    required this.payload,
  });
  final SyncEntityType entityType;
  final String entityId;
  final Map<String, Object?> payload;
}

final class SyncInitialEntityResult {
  const SyncInitialEntityResult({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.serverRevision,
  });
  final SyncEntityType entityType;
  final String entityId;
  final int serverVersion, serverRevision;
}

final class SyncSnapshotPage {
  const SyncSnapshotPage({
    required this.generation,
    required this.highWaterRevision,
    required this.entities,
    required this.nextOffset,
  });
  final String generation;
  final int highWaterRevision;
  final List<SyncInitialEntity> entities;
  final int? nextOffset;
}

final class SyncDurableState {
  const SyncDurableState({
    required this.linkedAccountId,
    required this.generation,
    required this.stage,
    required this.syncEnabled,
    required this.needsReconciliation,
    required this.paused,
    required this.pendingChanges,
    required this.unresolvedConflicts,
    this.operationId,
    this.lastSuccessfulSyncAtUtc,
  });

  final String? linkedAccountId, generation, operationId;
  final SyncOnboardingStage stage;
  final bool syncEnabled, needsReconciliation, paused;
  final int pendingChanges, unresolvedConflicts;
  final DateTime? lastSuccessfulSyncAtUtc;
}

final class SyncConflictItem {
  const SyncConflictItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localBaseVersion,
    required this.remoteVersion,
    required this.remoteRevision,
    required this.localCandidate,
    required this.remoteCandidate,
    required this.localDeleted,
    required this.remoteDeleted,
  });

  final String id, entityId;
  final SyncEntityType entityType;
  final int localBaseVersion, remoteVersion, remoteRevision;
  final Map<String, Object?> localCandidate, remoteCandidate;
  final bool localDeleted, remoteDeleted;
}

abstract final class SyncLinkPolicy {
  static SyncLinkDecision evaluate({
    required String? linkedAccountId,
    required String? authenticatedAccountId,
    required bool syncEnabled,
    required bool needsReconciliation,
  }) {
    if (needsReconciliation ||
        (linkedAccountId != null &&
            authenticatedAccountId != null &&
            linkedAccountId != authenticatedAccountId)) {
      return const SyncLinkDecision(
        SyncLinkStatus.needsReconciliation,
        maySendMutations: false,
      );
    }
    if (!syncEnabled ||
        linkedAccountId == null ||
        authenticatedAccountId == null) {
      return const SyncLinkDecision(
        SyncLinkStatus.unlinked,
        maySendMutations: false,
      );
    }
    return const SyncLinkDecision(
      SyncLinkStatus.linked,
      maySendMutations: true,
    );
  }
}
