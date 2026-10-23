import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;

import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart' as sql;
import '../../sync/data/drift_sync_mutation_capture.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/receipt_attachment.dart';

DateTime _utc(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);

ReceiptAttachment _map(sql.ReceiptAttachment row) => ReceiptAttachment(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  transactionId: LocalId(row.transactionId),
  storageKey: row.storageKey,
  mimeType: row.mimeType,
  byteSize: row.byteSize,
  sha256Hex: row.sha256Hex,
  position: row.position,
  createdAtUtc: _utc(row.createdAtUtc),
);

final class DriftReceiptAttachmentRepository
    implements ReceiptAttachmentRepository {
  DriftReceiptAttachmentRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<ReceiptAttachment>> create(ReceiptAttachment attachment) async {
    try {
      return await _db.transaction(() async {
        final transaction =
            await (_db.select(_db.bookkeepingTransactions)..where(
                  (row) =>
                      row.id.equals(attachment.transactionId.value) &
                      row.profileId.equals(attachment.profileId.value) &
                      row.deletedAtUtc.isNull(),
                ))
                .getSingleOrNull();
        if (transaction == null) {
          return const Failure(FailureCode.recordNotFound);
        }
        final count =
            await (_db.selectOnly(_db.receiptAttachments)
                  ..addColumns([_db.receiptAttachments.id.count()])
                  ..where(
                    _db.receiptAttachments.transactionId.equals(
                      attachment.transactionId.value,
                    ),
                  ))
                .map((row) => row.read(_db.receiptAttachments.id.count())!)
                .getSingle();
        if (count >= maximumReceiptsPerTransaction) {
          return const Failure(FailureCode.attachmentLimitReached);
        }
        await _db
            .into(_db.receiptAttachments)
            .insert(
              sql.ReceiptAttachmentsCompanion.insert(
                id: attachment.id.value,
                profileId: attachment.profileId.value,
                transactionId: attachment.transactionId.value,
                storageKey: attachment.storageKey,
                mimeType: attachment.mimeType,
                byteSize: attachment.byteSize,
                sha256Hex: attachment.sha256Hex,
                position: attachment.position,
                createdAtUtc: attachment.createdAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.receiptAttachment,
          entityId: attachment.id.value,
          operation: SyncOperation.create,
          payload: _payload(attachment),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success(attachment);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<ReceiptAttachment>>> list(
    LocalId profileId,
    LocalId transactionId,
  ) async {
    try {
      final query = _db.select(_db.receiptAttachments)
        ..where(
          (row) =>
              row.profileId.equals(profileId.value) &
              row.transactionId.equals(transactionId.value),
        )
        ..orderBy([
          (row) => drift.OrderingTerm.asc(row.position),
          (row) => drift.OrderingTerm.asc(row.id),
        ]);
      return Success((await query.get()).map(_map).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<ReceiptAttachment>>> listAll(LocalId profileId) async {
    try {
      final query = _db.select(_db.receiptAttachments)
        ..where((row) => row.profileId.equals(profileId.value));
      return Success((await query.get()).map(_map).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<ReceiptAttachment>> remove(
    LocalId profileId,
    LocalId attachmentId,
  ) async {
    try {
      return await _db.transaction(() async {
        final row =
            await (_db.select(_db.receiptAttachments)..where(
                  (item) =>
                      item.id.equals(attachmentId.value) &
                      item.profileId.equals(profileId.value),
                ))
                .getSingleOrNull();
        if (row == null) {
          return const Failure(FailureCode.attachmentNotFound);
        }
        final attachment = _map(row);
        final captured = await _sync.capture(
          entityType: SyncEntityType.receiptAttachment,
          entityId: attachment.id.value,
          operation: SyncOperation.delete,
          payload: _payload(attachment),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        await (_db.delete(
          _db.receiptAttachments,
        )..where((item) => item.id.equals(attachmentId.value))).go();
        return Success(attachment);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

Map<String, Object?> _payload(ReceiptAttachment value) => {
  'profile_id': value.profileId.value,
  'transaction_id': value.transactionId.value,
  'storage_path': value.storageKey,
  'mime_type': value.mimeType,
  'byte_size': value.byteSize,
  'sha256_hex': value.sha256Hex,
  'position': value.position,
  'created_at': SyncPayloads.timestamp(value.createdAtUtc),
  'updated_at': SyncPayloads.timestamp(value.createdAtUtc),
};
