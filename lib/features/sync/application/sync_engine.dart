import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../domain/sync_protocol.dart';
import 'sync_contracts.dart';
import 'sync_receipt_spool.dart';

/// Explicit, bounded executor. Composition registers it but no lifecycle code
/// invokes it automatically before Phase 6C.
final class SyncEngine {
  const SyncEngine({
    required this.remote,
    required this.local,
    required this.clock,
    this.receiptTransport,
    this.receiptSpool,
    this.maximumPushesPerCycle = 20,
    this.maximumPullPagesPerCycle = 2,
  });

  final SyncRemoteStore remote;
  final SyncRuntimeLocalStore local;
  final Clock clock;
  final SyncReceiptTransport? receiptTransport;
  final SyncReceiptSpool? receiptSpool;
  final int maximumPushesPerCycle, maximumPullPagesPerCycle;

  Future<Result<DateTime?>> earliestPendingRetryAt() =>
      local is SyncRetryScheduleStore
      ? (local as SyncRetryScheduleStore).earliestPendingRetryAt()
      : Future.value(const Success(null));

  Future<Result<SyncRunSummary>> runCycle({
    required String? authenticatedAccountId,
  }) async {
    final contextResult = await local.readExecutionContext();
    if (contextResult is Failure<SyncExecutionContext>) {
      return Failure(contextResult.code);
    }
    final context = (contextResult as Success<SyncExecutionContext>).value;
    if (context.paused) return const Failure(FailureCode.syncPaused);
    final decision = SyncLinkPolicy.evaluate(
      linkedAccountId: context.linkedAccountId,
      authenticatedAccountId: authenticatedAccountId,
      syncEnabled: context.syncEnabled,
      needsReconciliation: context.needsReconciliation,
    );
    if (decision.status == SyncLinkStatus.needsReconciliation) {
      return const Failure(FailureCode.syncNeedsReconciliation);
    }
    if (!decision.maySendMutations) {
      return const Failure(FailureCode.syncAuthenticationRequired);
    }
    final datasetGeneration = context.datasetGeneration;
    if (datasetGeneration == null || datasetGeneration.isEmpty) {
      await local.markNeedsReconciliation();
      return const Failure(FailureCode.syncNeedsReconciliation);
    }

    final recovered = await local.recoverInterruptedProcessing();
    if (recovered is Failure<void>) return Failure(recovered.code);

    var pushed = 0;
    var pulled = 0;
    var conflicts = 0;
    var deferred = 0;
    var blocked = 0;
    int? lastAcknowledgedRevision;
    final now = clock.nowUtc();

    if (receiptTransport != null) {
      final cleanup = await local.dueAttachmentCleanup(now);
      if (cleanup is Failure<List<String>>) return Failure(cleanup.code);
      for (final path in (cleanup as Success<List<String>>).value) {
        final deleted = await receiptTransport!.delete(path);
        if (deleted is Success<void>)
          await local.completeAttachmentCleanup(path);
      }
    }

    while (pushed < maximumPushesPerCycle) {
      final pendingResult = await local.nextDueMutation(now);
      if (pendingResult is Failure<PendingSyncMutation?>) {
        return Failure(pendingResult.code);
      }
      final pending = (pendingResult as Success<PendingSyncMutation?>).value;
      if (pending == null) break;
      var base = pending.baseServerVersion;
      if (base == null) {
        final resolved = await local.resolveDeferredBase(pending);
        if (resolved is Failure<int?>) return Failure(resolved.code);
        base = (resolved as Success<int?>).value;
        if (base == null) {
          deferred++;
          break;
        }
      }
      final attempted = pending.withResolvedBase(base);
      final marked = await local.markAttemptStarted(pending.mutationId, now);
      if (marked is Failure<void>) return Failure(marked.code);
      if (pending.entityType == SyncEntityType.receiptAttachment &&
          pending.operation == SyncOperation.create) {
        if (receiptTransport == null || receiptSpool == null) {
          return const Failure(FailureCode.syncAttachmentFailure);
        }
        final fileResult = await receiptSpool!.resolve(pending.entityId);
        if (fileResult is Failure<File>) {
          final blockedResult = await _blockAttachmentIntegrity(
            attempted,
            fileResult.code,
          );
          if (blockedResult is Failure<void>)
            return Failure(blockedResult.code);
          blocked++;
          continue;
        }
        final List<int> bytes;
        try {
          bytes = await (fileResult as Success<File>).value.readAsBytes();
        } on Object {
          final blockedResult = await _blockAttachmentIntegrity(
            attempted,
            FailureCode.syncAttachmentIntegrityFailure,
          );
          if (blockedResult is Failure<void>)
            return Failure(blockedResult.code);
          blocked++;
          continue;
        }
        final expectedHash = pending.payload['sha256_hex'];
        final expectedSize = pending.payload['byte_size'];
        final objectPath = pending.payload['storage_path'];
        if (objectPath is! String ||
            expectedHash is! String ||
            expectedSize is! int ||
            bytes.length != expectedSize ||
            sha256.convert(bytes).toString() != expectedHash) {
          final blockedResult = await _blockAttachmentIntegrity(
            attempted,
            FailureCode.syncAttachmentIntegrityFailure,
          );
          if (blockedResult is Failure<void>)
            return Failure(blockedResult.code);
          blocked++;
          continue;
        }
        final uploaded = await receiptTransport!.uploadImmutable(
          objectPath: objectPath,
          bytes: bytes,
          sha256Hex: expectedHash,
        );
        if (uploaded is Failure<void>) {
          if (!_isTransient(uploaded.code)) {
            final blockedResult = await _blockAttachmentIntegrity(
              attempted,
              uploaded.code,
            );
            if (blockedResult is Failure<void>) {
              return Failure(blockedResult.code);
            }
            blocked++;
            continue;
          }
          final delay = SyncRetryPolicy.delayFor(
            attemptCount: pending.attemptCount + 1,
            mutationId: pending.mutationId,
          );
          await local.deferRetry(
            pending.mutationId,
            uploaded.code,
            now.add(delay),
          );
          return Success(
            SyncRunSummary(
              retriesDeferred: 1,
              failure: uploaded.code,
              moreWorkAvailable: true,
            ),
          );
        }
      }
      final result = await remote.applyMutation(
        SyncMutation(
          mutationId: pending.mutationId,
          deviceId: context.deviceId,
          entityType: pending.entityType,
          entityId: pending.entityId,
          operation: pending.operation,
          baseServerVersion: attempted.baseServerVersion!,
          payload: pending.payload,
          datasetGeneration: datasetGeneration,
        ),
      );
      if (result is Failure<SyncMutationResult>) {
        if (_isTransient(result.code)) {
          final delay = SyncRetryPolicy.delayFor(
            attemptCount: pending.attemptCount + 1,
            mutationId: pending.mutationId,
          );
          final deferredResult = await local.deferRetry(
            pending.mutationId,
            result.code,
            now.add(delay),
          );
          if (deferredResult is Failure<void>)
            return Failure(deferredResult.code);
          return Success(
            SyncRunSummary(
              pushed: pushed,
              retriesDeferred: deferred + 1,
              failure: result.code,
              moreWorkAvailable: true,
            ),
          );
        }
        return Failure(result.code);
      }
      final remoteResult = (result as Success<SyncMutationResult>).value;
      if (remoteResult.status == SyncMutationStatus.reconciliationRequired) {
        await local.markNeedsReconciliation();
        return const Failure(FailureCode.syncGenerationMismatch);
      }
      if (remoteResult.status == SyncMutationStatus.applied ||
          remoteResult.status == SyncMutationStatus.alreadyApplied) {
        final ack = await local.acknowledgeMutation(attempted, remoteResult);
        if (ack is Failure<void>) return Failure(ack.code);
        if (pending.entityType == SyncEntityType.receiptAttachment) {
          if (pending.operation == SyncOperation.create) {
            await receiptSpool?.remove(pending.entityId);
          } else if (pending.operation == SyncOperation.delete) {
            final path = pending.payload['storage_path'] as String?;
            if (path != null && receiptTransport != null) {
              final removed = await receiptTransport!.delete(path);
              if (removed is Failure<void>)
                await local.scheduleAttachmentCleanup(path);
            }
          }
        }
        pushed++;
      } else {
        final block = await local.blockMutation(attempted, remoteResult);
        if (block is Failure<void>) return Failure(block.code);
        if (remoteResult.status == SyncMutationStatus.rejected &&
            pending.entityType == SyncEntityType.receiptAttachment &&
            pending.operation == SyncOperation.create &&
            receiptTransport != null) {
          final path = pending.payload['storage_path'] as String?;
          if (path != null) {
            final removed = await receiptTransport!.delete(path);
            if (removed is Failure<void>) {
              await local.scheduleAttachmentCleanup(path);
            }
          }
        }
        blocked++;
        if (remoteResult.status == SyncMutationStatus.conflict) conflicts++;
      }
    }

    final morePush = await local.hasImmediatelyEligiblePush(now);
    if (morePush is Failure<bool>) return Failure(morePush.code);
    if ((morePush as Success<bool>).value) {
      return Success(
        SyncRunSummary(
          pushed: pushed,
          conflicts: conflicts,
          retriesDeferred: deferred,
          blocked: blocked,
          moreWorkAvailable: true,
        ),
      );
    }

    var pullMoreWorkAvailable = false;
    for (var pageIndex = 0; pageIndex < maximumPullPagesPerCycle; pageIndex++) {
      final cursorResult = await local.readCursor();
      if (cursorResult is Failure<SyncCursor>)
        return Failure(cursorResult.code);
      final pageResult = await remote.fetchChanges(
        afterSequence:
            (cursorResult as Success<SyncCursor>).value.lastAppliedSequence,
      );
      if (pageResult is Failure<SyncChangePage>) {
        if (pageResult.code == FailureCode.syncNeedsReconciliation ||
            pageResult.code == FailureCode.syncGenerationMismatch) {
          await local.markNeedsReconciliation();
        }
        return Failure(pageResult.code);
      }
      final page = (pageResult as Success<SyncChangePage>).value;
      if (page.datasetGeneration != datasetGeneration) {
        await local.markNeedsReconciliation();
        return const Failure(FailureCode.syncGenerationMismatch);
      }
      if (page.changes.isEmpty) break;
      final applied = await local.applyPageAtomically(
        page,
        localDeviceId: context.deviceId,
      );
      if (applied is Failure<SyncPageApplyResult>) return Failure(applied.code);
      final summary = (applied as Success<SyncPageApplyResult>).value;
      pulled += summary.applied;
      conflicts += summary.conflicts;
      if (remote case final SyncDeviceAcknowledger acknowledger) {
        final maximum = page.maximumSequence;
        if (maximum != null) {
          final acknowledged = await acknowledger.acknowledgeDevice(
            deviceId: context.deviceId,
            generation: datasetGeneration,
            revision: maximum,
          );
          if (acknowledged is Failure<void>) {
            // The local cursor is already durable. A later sync contact can
            // repeat this monotonic acknowledgement without replaying data.
            if (!_isTransient(acknowledged.code)) {
              if (acknowledged.code == FailureCode.syncNeedsReconciliation ||
                  acknowledged.code == FailureCode.syncGenerationMismatch) {
                await local.markNeedsReconciliation();
              }
              return Failure(acknowledged.code);
            }
          } else {
            lastAcknowledgedRevision = maximum;
          }
        }
      }
      final fullPage = page.changes.length >= maximumSyncPageSize;
      if (!fullPage) break;
      if (pageIndex == maximumPullPagesPerCycle - 1) {
        pullMoreWorkAvailable = true;
      }
    }
    final acknowledger = switch (remote) {
      final SyncDeviceAcknowledger value => value,
      _ => null,
    };
    if (!pullMoreWorkAvailable && acknowledger != null) {
      final cursorResult = await local.readCursor();
      if (cursorResult is Failure<SyncCursor>)
        return Failure(cursorResult.code);
      final revision =
          (cursorResult as Success<SyncCursor>).value.lastAppliedSequence;
      if (lastAcknowledgedRevision != revision) {
        final heartbeat = await acknowledger.acknowledgeDevice(
          deviceId: context.deviceId,
          generation: datasetGeneration,
          revision: revision,
        );
        if (heartbeat is Failure<void>) {
          if (heartbeat.code == FailureCode.syncNeedsReconciliation ||
              heartbeat.code == FailureCode.syncGenerationMismatch) {
            await local.markNeedsReconciliation();
          }
          // Cursor/business state is already durable. A later cycle retries
          // this idempotent heartbeat, but this run is not fully protected.
          return Failure(heartbeat.code);
        }
      }
    }
    if (!pullMoreWorkAvailable && conflicts == 0) {
      final recorded = await local.recordSuccessfulSync(clock.nowUtc());
      if (recorded is Failure<void>) return Failure(recorded.code);
    }
    return Success(
      SyncRunSummary(
        pushed: pushed,
        pulled: pulled,
        conflicts: conflicts,
        retriesDeferred: deferred,
        blocked: blocked,
        moreWorkAvailable: pullMoreWorkAvailable,
      ),
    );
  }

  Future<Result<void>> _blockAttachmentIntegrity(
    PendingSyncMutation mutation,
    FailureCode failure,
  ) => local.blockMutation(
    mutation,
    SyncMutationResult(
      status: SyncMutationStatus.rejected,
      failure: failure == FailureCode.syncAttachmentIntegrityFailure
          ? failure
          : FailureCode.syncAttachmentIntegrityFailure,
    ),
  );

  static bool _isTransient(FailureCode code) => switch (code) {
    FailureCode.syncNetworkUnavailable ||
    FailureCode.syncBackendUnavailable ||
    FailureCode.syncRateLimited ||
    FailureCode.syncAttachmentFailure => true,
    _ => false,
  };
}
