import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../domain/sync_protocol.dart';

/// Captures immutable local intent. Call inside the same Drift transaction as
/// the associated business-row write.
final class DriftSyncMutationCapture {
  DriftSyncMutationCapture(
    this.db, {
    this.clock = const SystemClock(),
    IdGenerator? ids,
  }) : ids = ids ?? SecureUuidV4Generator();

  final LedgerDatabase db;
  final Clock clock;
  final IdGenerator ids;

  Future<Result<bool>> capture({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, Object?> payload,
  }) async {
    try {
      final link = await db.select(db.syncLinkStates).getSingle();
      final onboarding = await db
          .customSelect(
            'SELECT stage,dataset_generation,initialization_operation_id '
            'FROM sync_onboarding_state WHERE slot=1',
          )
          .getSingle();
      final initializationCapture =
          onboarding.read<String>('stage') == 'localToCloud' &&
          onboarding.read<String?>('dataset_generation') != null &&
          onboarding.read<String?>('initialization_operation_id') != null;
      if ((!link.syncEnabled && !initializationCapture) ||
          link.cloudAccountId == null ||
          link.needsReconciliation ||
          link.state != 'linked') {
        return const Success(false);
      }
      final type = entityType == SyncEntityType.receiptAttachment
          ? 'receipt_attachment'
          : entityType.name;
      final chain =
          await (db.select(db.syncOutbox)
                ..where(
                  (row) =>
                      row.entityType.equals(type) &
                      row.entityId.equals(entityId),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.queueSequence)]))
              .get();
      final unresolvedConflict =
          await (db.select(db.syncConflicts)..where(
                (row) =>
                    row.entityType.equals(type) &
                    row.entityId.equals(entityId) &
                    row.status.equals('unresolved'),
              ))
              .getSingleOrNull();

      if (operation == SyncOperation.delete &&
          chain.isNotEmpty &&
          chain.first.operation == 'create' &&
          chain.every((row) => row.attemptCount == 0)) {
        final server =
            await (db.select(db.syncEntityStates)..where(
                  (row) =>
                      row.entityType.equals(type) &
                      row.entityId.equals(entityId),
                ))
                .getSingleOrNull();
        if (server == null) {
          await (db.delete(db.syncOutbox)..where(
                (row) =>
                    row.entityType.equals(type) & row.entityId.equals(entityId),
              ))
              .go();
          await (db.delete(
            db.syncReceiptSpoolEntries,
          )..where((row) => row.attachmentId.equals(entityId))).go();
          return const Success(true);
        }
      }

      final server =
          await (db.select(db.syncEntityStates)..where(
                (row) =>
                    row.entityType.equals(type) & row.entityId.equals(entityId),
              ))
              .getSingleOrNull();
      final base = chain.isNotEmpty
          ? null
          : operation == SyncOperation.create
          ? 0
          : server?.serverVersion;
      final canonicalPayload = Map<String, Object?>.from(payload);
      if (entityType == SyncEntityType.receiptAttachment &&
          canonicalPayload['sha256_hex'] is String) {
        canonicalPayload['storage_path'] =
            '${link.cloudAccountId}/receipts/$entityId/${canonicalPayload['sha256_hex']}.jpg';
      }
      await db
          .into(db.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              mutationId: ids.generate().value,
              entityType: type,
              entityId: entityId,
              operation: operation.name,
              baseServerVersion: Value(base),
              payloadJson: jsonEncode(canonicalPayload),
              state: Value(unresolvedConflict == null ? 'pending' : 'blocked'),
              createdAtUtc: clock.nowUtc().microsecondsSinceEpoch,
            ),
          );
      return const Success(true);
    } on Object {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

abstract final class SyncPayloads {
  static String timestamp(DateTime value) => value.toUtc().toIso8601String();

  static Map<String, Object?> account({
    required String profileId,
    required String name,
    required String kind,
    required String currencyCode,
    required int openingMinorUnits,
    required String openingDate,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => {
    'profile_id': profileId,
    'name': name,
    'kind': kind,
    'currency_code': currencyCode,
    'opening_minor_units': openingMinorUnits,
    'opening_date': openingDate,
    'is_archived': isArchived,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
  };

  static Map<String, Object?> category({
    required String profileId,
    required String name,
    required String kind,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => {
    'profile_id': profileId,
    'name': name,
    'kind': kind,
    'is_archived': isArchived,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
  };

  static Map<String, Object?> entry({
    required String profileId,
    required String accountId,
    required String categoryId,
    required String? projectId,
    required String kind,
    required int amountMinorUnits,
    required String currencyCode,
    required String businessDate,
    required String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) => {
    'profile_id': profileId,
    'account_id': accountId,
    'category_id': categoryId,
    'project_id': projectId,
    'kind': kind,
    'amount_minor_units': amountMinorUnits,
    'currency_code': currencyCode,
    'business_date': businessDate,
    'note': note,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
    'deleted_at': deletedAt == null ? null : timestamp(deletedAt),
  };

  static Map<String, Object?> transfer({
    required String profileId,
    required String sourceAccountId,
    required String destinationAccountId,
    required int sourceMinorUnits,
    required String sourceCurrencyCode,
    required int destinationMinorUnits,
    required String destinationCurrencyCode,
    required String businessDate,
    required String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) => {
    'profile_id': profileId,
    'source_account_id': sourceAccountId,
    'destination_account_id': destinationAccountId,
    'source_minor_units': sourceMinorUnits,
    'source_currency_code': sourceCurrencyCode,
    'destination_minor_units': destinationMinorUnits,
    'destination_currency_code': destinationCurrencyCode,
    'business_date': businessDate,
    'note': note,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
    'deleted_at': deletedAt == null ? null : timestamp(deletedAt),
  };

  static Map<String, Object?> project({
    required String profileId,
    required String name,
    required String? description,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => {
    'profile_id': profileId,
    'name': name,
    'description': description,
    'is_archived': isArchived,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
  };

  static Map<String, Object?> budget({
    required String profileId,
    required String name,
    required int amountMinorUnits,
    required String currencyCode,
    required String month,
    required String? categoryId,
    required int warningThresholdPercent,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => {
    'profile_id': profileId,
    'name': name,
    'amount_minor_units': amountMinorUnits,
    'currency_code': currencyCode,
    'month': month,
    'category_id': categoryId,
    'warning_threshold_percent': warningThresholdPercent,
    'is_archived': isArchived,
    'created_at': timestamp(createdAt),
    'updated_at': timestamp(updatedAt),
  };
}
