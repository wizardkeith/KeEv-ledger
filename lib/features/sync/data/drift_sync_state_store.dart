import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart' hide SyncCursor;
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';

final class DriftSyncStateStore
    implements
        SyncLocalStateStore,
        SyncRuntimeLocalStore,
        SyncRetryScheduleStore {
  const DriftSyncStateStore(
    this.db, {
    this.clock = const SystemClock(),
    this.receiptFiles,
  });
  final LedgerDatabase db;
  final Clock clock;
  final SyncReceiptPullFiles? receiptFiles;

  @override
  Future<Result<SyncCursor>> readCursor() async {
    try {
      final row = await (db.select(
        db.syncCursors,
      )..where((e) => e.slot.equals(1))).getSingle();
      return Success(SyncCursor(row.lastAppliedSequence));
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> commitAppliedPage(SyncChangePage page) async {
    final maximum = page.maximumSequence;
    if (maximum == null) return const Success(null);
    try {
      await (db.update(db.syncCursors)..where((e) => e.slot.equals(1))).write(
        SyncCursorsCompanion(lastAppliedSequence: Value(maximum)),
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> markNeedsReconciliationAfterRestore() async {
    try {
      await db.transaction(() async {
        await db.delete(db.syncOutbox).go();
        await db.delete(db.syncEntityStates).go();
        await db.delete(db.syncConflicts).go();
        await db.delete(db.syncReceiptSpoolEntries).go();
        await db.delete(db.syncAttachmentCleanup).go();
        await db.customStatement('DELETE FROM sync_initialization_entities');
        await (db.update(db.syncCursors)..where((e) => e.slot.equals(1))).write(
          const SyncCursorsCompanion(lastAppliedSequence: Value(0)),
        );
        final link = await (db.select(
          db.syncLinkStates,
        )..where((e) => e.slot.equals(1))).getSingle();
        await (db.update(
          db.syncLinkStates,
        )..where((e) => e.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            syncEnabled: const Value(false),
            needsReconciliation: Value(link.cloudAccountId != null),
            state: Value(
              link.cloudAccountId == null ? 'unlinked' : 'needsReconciliation',
            ),
            updatedAtUtc: Value(DateTime.now().toUtc().microsecondsSinceEpoch),
          ),
        );
        await db.customStatement(
          "UPDATE sync_onboarding_state SET stage=?, "
          'initialization_operation_id=NULL, paused=0, '
          'last_successful_sync_at_utc=NULL, updated_at_utc=? WHERE slot=1',
          [
            link.cloudAccountId == null ? 'idle' : 'reconciling',
            clock.nowUtc().microsecondsSinceEpoch,
          ],
        );
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<SyncExecutionContext>> readExecutionContext() async {
    try {
      final link = await db.select(db.syncLinkStates).getSingle();
      final device = await db.select(db.syncDeviceStates).getSingle();
      final onboarding = await db
          .customSelect(
            'SELECT dataset_generation, paused FROM sync_onboarding_state '
            'WHERE slot = 1',
          )
          .getSingle();
      return Success(
        SyncExecutionContext(
          linkedAccountId: link.cloudAccountId,
          deviceId: device.deviceId,
          syncEnabled: link.syncEnabled,
          needsReconciliation: link.needsReconciliation,
          datasetGeneration: onboarding.read<String?>('dataset_generation'),
          paused: onboarding.read<int>('paused') == 1,
        ),
      );
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> recoverInterruptedProcessing() async {
    try {
      await (db.update(db.syncOutbox)
            ..where((row) => row.state.equals('processing')))
          .write(const SyncOutboxCompanion(state: Value('pending')));
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<PendingSyncMutation?>> nextDueMutation(DateTime nowUtc) async {
    try {
      // Select the first runnable entity head in one bounded query. A blocked
      // or deferred chain is excluded without imposing an arbitrary scan
      // limit that could starve unrelated entities queued behind it.
      final row = await db
          .customSelect(
            '''
SELECT o.*
FROM sync_outbox AS o
WHERE o.state = 'pending'
  AND (o.next_attempt_at_utc IS NULL OR o.next_attempt_at_utc <= ?)
  AND NOT EXISTS (
    SELECT 1 FROM sync_outbox AS predecessor
    WHERE predecessor.entity_type = o.entity_type
      AND predecessor.entity_id = o.entity_id
      AND predecessor.queue_sequence < o.queue_sequence
  )
  AND NOT EXISTS (
    SELECT 1 FROM sync_conflicts AS conflict
    WHERE conflict.entity_type = o.entity_type
      AND conflict.entity_id = o.entity_id
      AND conflict.status = 'unresolved'
  )
ORDER BY o.queue_sequence ASC
LIMIT 1
''',
            variables: [Variable.withInt(nowUtc.microsecondsSinceEpoch)],
            readsFrom: {db.syncOutbox, db.syncConflicts},
          )
          .getSingleOrNull();
      if (row == null) return const Success(null);
      return Success(
        PendingSyncMutation(
          queueSequence: row.read<int>('queue_sequence'),
          mutationId: row.read<String>('mutation_id'),
          entityType: _parseEntity(row.read<String>('entity_type')),
          entityId: row.read<String>('entity_id'),
          operation: SyncOperation.values.byName(row.read<String>('operation')),
          baseServerVersion: row.readNullable<int>('base_server_version'),
          payload: Map<String, Object?>.from(
            jsonDecode(row.read<String>('payload_json')) as Map,
          ),
          attemptCount: row.read<int>('attempt_count'),
        ),
      );
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<DateTime?>> earliestPendingRetryAt() async {
    try {
      final row = await db
          .customSelect(
            "SELECT min(next_attempt_at_utc) AS retry_at FROM sync_outbox "
            "WHERE state='pending' AND next_attempt_at_utc IS NOT NULL",
            readsFrom: {db.syncOutbox},
          )
          .getSingle();
      final value = row.readNullable<int>('retry_at');
      return Success(
        value == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true),
      );
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<int?>> resolveDeferredBase(PendingSyncMutation mutation) async {
    try {
      final predecessor =
          await (db.select(db.syncOutbox)
                ..where(
                  (row) =>
                      row.entityType.equals(_entityName(mutation.entityType)) &
                      row.entityId.equals(mutation.entityId) &
                      row.queueSequence.isSmallerThanValue(
                        mutation.queueSequence,
                      ),
                )
                ..limit(1))
              .getSingleOrNull();
      if (predecessor != null) return const Success(null);
      final state =
          await (db.select(db.syncEntityStates)..where(
                (row) =>
                    row.entityType.equals(_entityName(mutation.entityType)) &
                    row.entityId.equals(mutation.entityId),
              ))
              .getSingleOrNull();
      final base = mutation.operation == SyncOperation.create
          ? 0
          : state?.serverVersion;
      if (base == null) return const Success(null);
      await (db.update(db.syncOutbox)
            ..where((row) => row.mutationId.equals(mutation.mutationId)))
          .write(SyncOutboxCompanion(baseServerVersion: Value(base)));
      return Success(base);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> markAttemptStarted(
    String mutationId,
    DateTime nowUtc,
  ) async {
    try {
      final row = await (db.select(
        db.syncOutbox,
      )..where((row) => row.mutationId.equals(mutationId))).getSingle();
      await (db.update(
        db.syncOutbox,
      )..where((row) => row.mutationId.equals(mutationId))).write(
        SyncOutboxCompanion(
          state: const Value('processing'),
          attemptCount: Value(row.attemptCount + 1),
          lastAttemptAtUtc: Value(nowUtc.microsecondsSinceEpoch),
          nextAttemptAtUtc: const Value(null),
        ),
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> deferRetry(
    String mutationId,
    FailureCode failure,
    DateTime nextAttemptUtc,
  ) async {
    try {
      await (db.update(
        db.syncOutbox,
      )..where((row) => row.mutationId.equals(mutationId))).write(
        SyncOutboxCompanion(
          state: const Value('pending'),
          nextAttemptAtUtc: Value(nextAttemptUtc.microsecondsSinceEpoch),
          lastFailureCode: Value(failure.name),
        ),
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> acknowledgeMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  ) async {
    if (result.serverVersion == null || result.serverRevision == null) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    try {
      await db.transaction(() async {
        await db
            .into(db.syncEntityStates)
            .insertOnConflictUpdate(
              SyncEntityStatesCompanion.insert(
                entityType: _entityName(mutation.entityType),
                entityId: mutation.entityId,
                serverVersion: result.serverVersion!,
                serverRevision: result.serverRevision!,
              ),
            );
        await (db.delete(
          db.syncOutbox,
        )..where((row) => row.mutationId.equals(mutation.mutationId))).go();
        final successor =
            await (db.select(db.syncOutbox)
                  ..where(
                    (row) =>
                        row.entityType.equals(
                          _entityName(mutation.entityType),
                        ) &
                        row.entityId.equals(mutation.entityId) &
                        row.baseServerVersion.isNull(),
                  )
                  ..orderBy([(row) => OrderingTerm.asc(row.queueSequence)])
                  ..limit(1))
                .getSingleOrNull();
        if (successor != null && successor.attemptCount == 0) {
          await (db.update(db.syncOutbox)..where(
                (row) => row.queueSequence.equals(successor.queueSequence),
              ))
              .write(
                SyncOutboxCompanion(
                  baseServerVersion: Value(result.serverVersion!),
                ),
              );
        }
        if (mutation.entityType == SyncEntityType.receiptAttachment) {
          final stillNeeded =
              await (db.select(db.syncOutbox)
                    ..where((row) => row.entityId.equals(mutation.entityId)))
                  .getSingleOrNull();
          if (stillNeeded == null) {
            await (db.delete(
              db.syncReceiptSpoolEntries,
            )..where((row) => row.attachmentId.equals(mutation.entityId))).go();
          }
        }
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> blockMutation(
    PendingSyncMutation mutation,
    SyncMutationResult result,
  ) async {
    if (result.status == SyncMutationStatus.conflict &&
        mutation.baseServerVersion == null) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    try {
      await db.transaction(() async {
        await (db.update(db.syncOutbox)..where(
              (row) =>
                  row.entityType.equals(_entityName(mutation.entityType)) &
                  row.entityId.equals(mutation.entityId),
            ))
            .write(
              SyncOutboxCompanion(
                state: const Value('blocked'),
                lastFailureCode: Value(
                  result.failure?.name ??
                      FailureCode.syncInvalidRemoteData.name,
                ),
              ),
            );
        if (result.status == SyncMutationStatus.conflict &&
            result.serverVersion != null &&
            result.serverRevision != null &&
            result.remoteSnapshot != null) {
          await db
              .into(db.syncConflicts)
              .insert(
                SyncConflictsCompanion.insert(
                  id: SecureUuidV4Generator().generate().value,
                  entityType: _entityName(mutation.entityType),
                  entityId: mutation.entityId,
                  mutationId: Value(mutation.mutationId),
                  baseServerVersion: mutation.baseServerVersion!,
                  remoteServerVersion: result.serverVersion!,
                  remoteServerRevision: result.serverRevision!,
                  localCandidateJson: jsonEncode({
                    ...mutation.payload,
                    '_local_operation': mutation.operation.name,
                  }),
                  remoteCandidateJson: jsonEncode(result.remoteSnapshot),
                  detectedAtUtc: clock.nowUtc().microsecondsSinceEpoch,
                ),
              );
        }
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<SyncPageApplyResult>> applyPageAtomically(
    SyncChangePage page, {
    required String localDeviceId,
  }) async {
    final prepared = <String, PreparedSyncReceipt>{};
    final appliedReceiptIds = <String>{};
    final removedKeys = <String>[];
    var applied = 0;
    var conflicts = 0;
    var databaseCommitted = false;
    try {
      for (final change in page.changes) {
        if (change.entityType != SyncEntityType.receiptAttachment) continue;
        if (change.operation == SyncOperation.update) {
          await _discardPreparedReceipts(prepared.values);
          return const Failure(FailureCode.syncInvalidRemoteData);
        }
        final prior =
            await (db.select(db.syncEntityStates)..where(
                  (row) =>
                      row.entityType.equals(_entityName(change.entityType)) &
                      row.entityId.equals(change.entityId),
                ))
                .getSingleOrNull();
        if (prior != null && prior.serverRevision >= change.sequence) continue;
        final pending =
            await (db.select(db.syncOutbox)
                  ..where(
                    (row) =>
                        row.entityType.equals(_entityName(change.entityType)) &
                        row.entityId.equals(change.entityId),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (pending != null) {
          // Conflict and own-echo decisions preserve current local bytes.
          continue;
        }
        if (change.isDeleted) {
          final existing = await (db.select(
            db.receiptAttachments,
          )..where((row) => row.id.equals(change.entityId))).getSingleOrNull();
          if (existing != null) removedKeys.add(existing.storageKey);
        } else {
          if (receiptFiles == null) {
            await _discardPreparedReceipts(prepared.values);
            return const Failure(FailureCode.syncAttachmentFailure);
          }
          final result = await receiptFiles!.prepare(change);
          if (result is Failure<PreparedSyncReceipt>) {
            await _discardPreparedReceipts(prepared.values);
            return Failure(result.code);
          }
          prepared[change.entityId] =
              (result as Success<PreparedSyncReceipt>).value;
        }
      }
      await db.transaction(() async {
        for (final change in page.changes) {
          final prior =
              await (db.select(db.syncEntityStates)..where(
                    (row) =>
                        row.entityType.equals(_entityName(change.entityType)) &
                        row.entityId.equals(change.entityId),
                  ))
                  .getSingleOrNull();
          if (prior != null && prior.serverRevision >= change.sequence)
            continue;
          final pending =
              await (db.select(db.syncOutbox)
                    ..where(
                      (row) =>
                          row.entityType.equals(
                            _entityName(change.entityType),
                          ) &
                          row.entityId.equals(change.entityId),
                    )
                    ..orderBy([(row) => OrderingTerm.asc(row.queueSequence)]))
                  .get();
          final ownEcho = change.originDeviceId == localDeviceId;
          if (pending.isNotEmpty && !ownEcho) {
            final first = pending.first;
            final existing =
                await (db.select(db.syncConflicts)..where(
                      (row) =>
                          row.entityType.equals(
                            _entityName(change.entityType),
                          ) &
                          row.entityId.equals(change.entityId) &
                          row.status.equals('unresolved'),
                    ))
                    .getSingleOrNull();
            if (existing == null) {
              await db
                  .into(db.syncConflicts)
                  .insert(
                    SyncConflictsCompanion.insert(
                      id: SecureUuidV4Generator().generate().value,
                      entityType: _entityName(change.entityType),
                      entityId: change.entityId,
                      mutationId: Value(first.mutationId),
                      baseServerVersion: first.baseServerVersion ?? 0,
                      remoteServerVersion: change.serverVersion,
                      remoteServerRevision: change.sequence,
                      localCandidateJson: jsonEncode({
                        ...Map<String, Object?>.from(
                          jsonDecode(first.payloadJson) as Map,
                        ),
                        '_local_operation': first.operation,
                      }),
                      remoteCandidateJson: jsonEncode(change.snapshot),
                      detectedAtUtc: clock.nowUtc().microsecondsSinceEpoch,
                    ),
                  );
            } else if (change.sequence > existing.remoteServerRevision) {
              await (db.update(
                db.syncConflicts,
              )..where((row) => row.id.equals(existing.id))).write(
                SyncConflictsCompanion(
                  remoteServerVersion: Value(change.serverVersion),
                  remoteServerRevision: Value(change.sequence),
                  remoteCandidateJson: Value(jsonEncode(change.snapshot)),
                ),
              );
            }
            await (db.update(db.syncOutbox)..where(
                  (row) =>
                      row.entityType.equals(_entityName(change.entityType)) &
                      row.entityId.equals(change.entityId),
                ))
                .write(const SyncOutboxCompanion(state: Value('blocked')));
            conflicts++;
          } else if (!(ownEcho && pending.isNotEmpty)) {
            String? receiptStorageKey;
            if (change.entityType == SyncEntityType.receiptAttachment &&
                !change.isDeleted) {
              final staged = prepared[change.entityId];
              if (staged == null) {
                throw const FormatException('Missing staged receipt');
              }
              final promoted = await receiptFiles!.promote(staged);
              if (promoted is Failure<String>) {
                throw _ReceiptPromotionFailure(promoted.code);
              }
              receiptStorageKey = (promoted as Success<String>).value;
            }
            await _applySnapshot(change, receiptStorageKey: receiptStorageKey);
            if (change.entityType == SyncEntityType.receiptAttachment &&
                !change.isDeleted) {
              appliedReceiptIds.add(change.entityId);
            }
            if (change.entityType == SyncEntityType.receiptAttachment &&
                change.isDeleted) {
              final staged = prepared[change.entityId];
              if (staged != null) removedKeys.add(staged.storageKey);
            }
            applied++;
          }
          await db
              .into(db.syncEntityStates)
              .insertOnConflictUpdate(
                SyncEntityStatesCompanion.insert(
                  entityType: _entityName(change.entityType),
                  entityId: change.entityId,
                  serverVersion: change.serverVersion,
                  serverRevision: change.sequence,
                ),
              );
        }
        final maximum = page.maximumSequence;
        if (maximum != null) {
          await (db.update(db.syncCursors)..where((row) => row.slot.equals(1)))
              .write(SyncCursorsCompanion(lastAppliedSequence: Value(maximum)));
        }
      });
      databaseCommitted = true;
    } on _ReceiptPromotionFailure catch (error) {
      if (!databaseCommitted) {
        await _rollbackPreparedReceipts(prepared.values);
      }
      return Failure(error.code);
    } on FormatException {
      if (!databaseCommitted) {
        await _rollbackPreparedReceipts(prepared.values);
      }
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on Object {
      if (!databaseCommitted) {
        await _rollbackPreparedReceipts(prepared.values);
      }
      return const Failure(FailureCode.localStoreUnavailable);
    }

    // The database and cursor are durable now. Cleanup is deliberately
    // outside the rollback path: a stale staging/orphan file is safer than
    // deleting a live JPEG referenced by committed receipt metadata.
    for (final entry in prepared.entries) {
      if (!appliedReceiptIds.contains(entry.key)) {
        await _safeCompensate(entry.value);
      }
    }
    for (final key in removedKeys) {
      await _safeRemoveAfterCommit(key);
    }
    return Success(SyncPageApplyResult(applied: applied, conflicts: conflicts));
  }

  Future<void> _rollbackPreparedReceipts(
    Iterable<PreparedSyncReceipt> prepared,
  ) async {
    for (final item in prepared) {
      if (item.promoted) {
        await _safeRollbackPromotion(item);
      } else {
        await _safeCompensate(item);
      }
    }
  }

  Future<void> _discardPreparedReceipts(
    Iterable<PreparedSyncReceipt> prepared,
  ) async {
    for (final item in prepared) {
      await _safeCompensate(item);
    }
  }

  Future<Result<void>> _safeCompensate(PreparedSyncReceipt prepared) async {
    try {
      return await receiptFiles?.compensate(prepared) ?? const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  Future<Result<void>> _safeRollbackPromotion(
    PreparedSyncReceipt prepared,
  ) async {
    try {
      return await receiptFiles?.rollbackPromotion(prepared) ??
          const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  Future<Result<void>> _safeRemoveAfterCommit(String storageKey) async {
    try {
      return await receiptFiles?.removeAfterCommit(storageKey) ??
          const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<bool>> hasImmediatelyEligiblePush(DateTime nowUtc) async {
    final next = await nextDueMutation(nowUtc);
    return switch (next) {
      Success<PendingSyncMutation?>(value: final value) => Success(
        value != null,
      ),
      Failure<PendingSyncMutation?>(code: final code) => Failure(code),
    };
  }

  @override
  Future<Result<void>> scheduleAttachmentCleanup(String storagePath) async {
    try {
      await db
          .into(db.syncAttachmentCleanup)
          .insertOnConflictUpdate(
            SyncAttachmentCleanupCompanion.insert(
              storagePath: storagePath,
              createdAtUtc: clock.nowUtc().microsecondsSinceEpoch,
            ),
          );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<String>>> dueAttachmentCleanup(DateTime nowUtc) async {
    try {
      final rows =
          await (db.select(db.syncAttachmentCleanup)
                ..where(
                  (row) =>
                      row.nextAttemptAtUtc.isNull() |
                      row.nextAttemptAtUtc.isSmallerOrEqualValue(
                        nowUtc.microsecondsSinceEpoch,
                      ),
                )
                ..limit(20))
              .get();
      return Success(
        rows.map((row) => row.storagePath).toList(growable: false),
      );
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> completeAttachmentCleanup(String storagePath) async {
    try {
      await (db.delete(
        db.syncAttachmentCleanup,
      )..where((row) => row.storagePath.equals(storagePath))).go();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> markNeedsReconciliation() async {
    try {
      await db.transaction(() async {
        await (db.update(
          db.syncLinkStates,
        )..where((row) => row.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            syncEnabled: const Value(false),
            needsReconciliation: const Value(true),
            state: const Value('needsReconciliation'),
            updatedAtUtc: Value(clock.nowUtc().microsecondsSinceEpoch),
          ),
        );
        await db.customStatement(
          "UPDATE sync_onboarding_state SET stage='reconciling', "
          'paused=0, updated_at_utc=? WHERE slot=1',
          [clock.nowUtc().microsecondsSinceEpoch],
        );
      });
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> recordSuccessfulSync(DateTime nowUtc) async {
    try {
      await db.customStatement(
        'UPDATE sync_onboarding_state SET last_successful_sync_at_utc=?, '
        "stage='active', updated_at_utc=? WHERE slot=1",
        [nowUtc.microsecondsSinceEpoch, nowUtc.microsecondsSinceEpoch],
      );
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<void>> resolveConflictKeepCloud({
    required SyncConflictItem conflict,
    required SyncCanonicalEntity currentRemote,
  }) async {
    if (conflict.entityType != currentRemote.entityType ||
        conflict.entityId != currentRemote.id) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    final change = SyncChange(
      sequence: currentRemote.serverRevision,
      entityType: currentRemote.entityType,
      entityId: currentRemote.id,
      serverVersion: currentRemote.serverVersion,
      operation: currentRemote.isDeleted
          ? SyncOperation.delete
          : currentRemote.entityType == SyncEntityType.receiptAttachment
          ? SyncOperation.create
          : SyncOperation.update,
      originDeviceId: SecureUuidV4Generator().generate().value,
      mutationId: SecureUuidV4Generator().generate().value,
      snapshot: currentRemote.payload,
    );
    PreparedSyncReceipt? prepared;
    File? receiptSafety;
    String? oldReceiptKey;
    var committed = false;
    try {
      if (change.entityType == SyncEntityType.receiptAttachment) {
        final old = await (db.select(
          db.receiptAttachments,
        )..where((row) => row.id.equals(change.entityId))).getSingleOrNull();
        oldReceiptKey = old?.storageKey;
        if (!change.isDeleted) {
          if (receiptFiles == null) {
            return const Failure(FailureCode.syncAttachmentFailure);
          }
          final staged = await receiptFiles!.prepare(change);
          if (staged is Failure<PreparedSyncReceipt>) {
            return Failure(staged.code);
          }
          prepared = (staged as Success<PreparedSyncReceipt>).value;
          final live = prepared.liveFile as File;
          if (await live.exists()) {
            receiptSafety = File('${live.path}.${conflict.id}.safety');
            await live.rename(receiptSafety.path);
          }
        }
      }
      await db.transaction(() async {
        String? storageKey;
        if (prepared != null) {
          final promotion = await receiptFiles!.promote(prepared);
          if (promotion is Failure<String>) {
            throw _ReceiptPromotionFailure(promotion.code);
          }
          storageKey = (promotion as Success<String>).value;
        }
        await _applySnapshot(change, receiptStorageKey: storageKey);
        await db
            .into(db.syncEntityStates)
            .insertOnConflictUpdate(
              SyncEntityStatesCompanion.insert(
                entityType: _entityName(change.entityType),
                entityId: change.entityId,
                serverVersion: change.serverVersion,
                serverRevision: change.sequence,
              ),
            );
        await (db.delete(db.syncOutbox)..where(
              (row) =>
                  row.entityType.equals(_entityName(change.entityType)) &
                  row.entityId.equals(change.entityId),
            ))
            .go();
        await (db.update(db.syncConflicts)
              ..where((row) => row.id.equals(conflict.id)))
            .write(const SyncConflictsCompanion(status: Value('resolved')));
      });
      committed = true;
    } on _ReceiptPromotionFailure catch (error) {
      if (!committed && prepared != null) {
        await _safeRollbackPromotion(prepared);
        await _restoreReceiptSafety(receiptSafety, prepared);
      }
      return Failure(error.code);
    } on FormatException {
      if (!committed && prepared != null) {
        await _safeRollbackPromotion(prepared);
        await _restoreReceiptSafety(receiptSafety, prepared);
      }
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on Object {
      if (!committed && prepared != null) {
        await _safeRollbackPromotion(prepared);
        await _restoreReceiptSafety(receiptSafety, prepared);
      }
      return const Failure(FailureCode.syncLocalStoreFailure);
    }
    if (oldReceiptKey != null &&
        (currentRemote.isDeleted || oldReceiptKey != prepared?.storageKey)) {
      await _safeRemoveAfterCommit(oldReceiptKey);
    }
    if (receiptSafety != null) {
      try {
        if (await receiptSafety.exists()) await receiptSafety.delete();
      } on Object {
        // An app-private orphan safety copy is preferable to data loss.
      }
    }
    return const Success(null);
  }

  Future<void> _restoreReceiptSafety(
    File? safety,
    PreparedSyncReceipt prepared,
  ) async {
    if (safety == null) return;
    try {
      final live = prepared.liveFile as File;
      if (await safety.exists() && !await live.exists()) {
        await safety.rename(live.path);
      }
    } on Object {
      // The original is retained at its private safety path for recovery.
    }
  }

  Future<void> _applySnapshot(
    SyncChange change, {
    String? receiptStorageKey,
  }) async {
    final p = change.snapshot;
    int micros(String key) =>
        DateTime.parse(p[key] as String).toUtc().microsecondsSinceEpoch;
    final deleted = p['deleted_at'] == null ? null : micros('deleted_at');
    switch (change.entityType) {
      case SyncEntityType.profile:
        if (change.isDeleted)
          throw const FormatException('Profile delete unsupported');
        await db
            .into(db.localProfiles)
            .insertOnConflictUpdate(
              LocalProfilesCompanion.insert(
                slot: const Value(1),
                id: change.entityId,
                baseCurrencyCode: p['base_currency_code'] as String,
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
              ),
            );
      case SyncEntityType.account:
        if (change.isDeleted)
          throw const FormatException('Account delete unsupported');
        await db
            .into(db.accounts)
            .insertOnConflictUpdate(
              AccountsCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                name: p['name'] as String,
                kind: p['kind'] as String,
                currencyCode: p['currency_code'] as String,
                openingMinorUnits: p['opening_minor_units'] as int,
                openingDate: p['opening_date'] as String,
                isArchived: Value(p['is_archived'] as bool),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
              ),
            );
      case SyncEntityType.category:
        if (change.isDeleted)
          throw const FormatException('Category delete unsupported');
        await db
            .into(db.categories)
            .insertOnConflictUpdate(
              CategoriesCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                name: p['name'] as String,
                kind: p['kind'] as String,
                isArchived: Value(p['is_archived'] as bool),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
              ),
            );
      case SyncEntityType.project:
        if (change.isDeleted)
          throw const FormatException('Project delete unsupported');
        await db
            .into(db.projects)
            .insertOnConflictUpdate(
              ProjectsCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                name: p['name'] as String,
                description: Value(p['description'] as String?),
                isArchived: Value(p['is_archived'] as bool),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
              ),
            );
      case SyncEntityType.budget:
        if (change.isDeleted)
          throw const FormatException('Budget delete unsupported');
        await db
            .into(db.budgets)
            .insertOnConflictUpdate(
              BudgetsCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                name: p['name'] as String,
                amountMinorUnits: p['amount_minor_units'] as int,
                currencyCode: p['currency_code'] as String,
                month: p['month'] as String,
                categoryId: Value(p['category_id'] as String?),
                warningThresholdPercent: Value(
                  p['warning_threshold_percent'] as int,
                ),
                isArchived: Value(p['is_archived'] as bool),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
              ),
            );
      case SyncEntityType.transaction:
        await db
            .into(db.bookkeepingTransactions)
            .insertOnConflictUpdate(
              BookkeepingTransactionsCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                accountId: p['account_id'] as String,
                categoryId: p['category_id'] as String,
                projectId: Value(p['project_id'] as String?),
                kind: p['kind'] as String,
                amountMinorUnits: p['amount_minor_units'] as int,
                currencyCode: p['currency_code'] as String,
                businessDate: p['business_date'] as String,
                note: Value(p['note'] as String?),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
                deletedAtUtc: Value(deleted),
              ),
            );
      case SyncEntityType.transfer:
        await db
            .into(db.transfers)
            .insertOnConflictUpdate(
              TransfersCompanion.insert(
                id: change.entityId,
                profileId: p['profile_id'] as String,
                sourceAccountId: p['source_account_id'] as String,
                destinationAccountId: p['destination_account_id'] as String,
                sourceMinorUnits: p['source_minor_units'] as int,
                sourceCurrencyCode: p['source_currency_code'] as String,
                destinationMinorUnits: p['destination_minor_units'] as int,
                destinationCurrencyCode:
                    p['destination_currency_code'] as String,
                businessDate: p['business_date'] as String,
                note: Value(p['note'] as String?),
                createdAtUtc: micros('created_at'),
                updatedAtUtc: micros('updated_at'),
                deletedAtUtc: Value(deleted),
              ),
            );
      case SyncEntityType.receiptAttachment:
        if (change.isDeleted) {
          await (db.delete(
            db.receiptAttachments,
          )..where((row) => row.id.equals(change.entityId))).go();
        } else {
          await db
              .into(db.receiptAttachments)
              .insertOnConflictUpdate(
                ReceiptAttachmentsCompanion.insert(
                  id: change.entityId,
                  profileId: p['profile_id'] as String,
                  transactionId: p['transaction_id'] as String,
                  storageKey:
                      receiptStorageKey ??
                      (throw const FormatException('Missing receipt file')),
                  mimeType: p['mime_type'] as String,
                  byteSize: p['byte_size'] as int,
                  sha256Hex: p['sha256_hex'] as String,
                  position: p['position'] as int,
                  createdAtUtc: micros('created_at'),
                ),
              );
        }
    }
  }

  static String _entityName(SyncEntityType type) =>
      type == SyncEntityType.receiptAttachment
      ? 'receipt_attachment'
      : type.name;
  static SyncEntityType _parseEntity(String value) =>
      value == 'receipt_attachment'
      ? SyncEntityType.receiptAttachment
      : SyncEntityType.values.byName(value);
}

final class _ReceiptPromotionFailure implements Exception {
  const _ReceiptPromotionFailure(this.code);
  final FailureCode code;
}
