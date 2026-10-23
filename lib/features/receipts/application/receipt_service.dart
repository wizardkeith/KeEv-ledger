import 'dart:io';

import '../../../core/clock.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../bookkeeping/application/bookkeeping_service.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../sync/application/sync_receipt_spool.dart';
import '../domain/receipt_attachment.dart';
import 'receipt_contracts.dart';

final class ReceiptService {
  ReceiptService({
    required this.bookkeeping,
    required this.repository,
    required this.files,
    required this.acquirer,
    required this.ids,
    required this.clock,
    this.syncSpool,
  });

  final BookkeepingService bookkeeping;
  final ReceiptAttachmentRepository repository;
  final ReceiptFileStore files;
  final ReceiptImageAcquirer acquirer;
  final IdGenerator ids;
  final Clock clock;
  final SyncReceiptSpool? syncSpool;

  DateTime _now() {
    final now = clock.nowUtc();
    if (!now.isUtc) throw StateError('Clock must supply UTC instants');
    return now;
  }

  Future<Result<ReceiptAttachment>> attach({
    required LocalId profileId,
    required LocalId transactionId,
    required File source,
  }) async {
    final existing = await repository.list(profileId, transactionId);
    if (existing is Failure<List<ReceiptAttachment>>) {
      return Failure(existing.code);
    }
    final rows = (existing as Success<List<ReceiptAttachment>>).value;
    if (rows.length >= maximumReceiptsPerTransaction) {
      return const Failure(FailureCode.attachmentLimitReached);
    }
    final id = ids.generate();
    final stored = await files.importImage(source, id.value);
    if (stored is Failure<StoredReceiptFile>) return Failure(stored.code);
    final value = (stored as Success<StoredReceiptFile>).value;
    final spooled = await _prepareSpool(id, value);
    if (spooled is Failure<bool>) {
      await files.remove(value.storageKey);
      return Failure(spooled.code);
    }
    final attachment = ReceiptAttachment(
      id: id,
      profileId: profileId,
      transactionId: transactionId,
      storageKey: value.storageKey,
      mimeType: 'image/jpeg',
      byteSize: value.byteSize,
      sha256Hex: value.sha256Hex,
      position: rows.length,
      createdAtUtc: _now(),
    );
    final created = await repository.create(attachment);
    if (created is Failure<ReceiptAttachment>) {
      await files.remove(value.storageKey);
      await syncSpool?.remove(id.value);
    }
    return created;
  }

  Future<Result<BookkeepingEntry>> recordIncomeWithReceipts({
    required LocalId profileId,
    required LocalId accountId,
    required LocalId categoryId,
    required Money amount,
    required BusinessDate businessDate,
    required List<File> receiptSources,
    String? note,
    LocalId? projectId,
  }) => _recordWithReceipts(
    create: () => bookkeeping.recordIncome(
      profileId: profileId,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      businessDate: businessDate,
      note: note,
      projectId: projectId,
    ),
    profileId: profileId,
    receiptSources: receiptSources,
  );

  Future<Result<BookkeepingEntry>> recordExpenseWithReceipts({
    required LocalId profileId,
    required LocalId accountId,
    required LocalId categoryId,
    required Money amount,
    required BusinessDate businessDate,
    required List<File> receiptSources,
    String? note,
    LocalId? projectId,
  }) => _recordWithReceipts(
    create: () => bookkeeping.recordExpense(
      profileId: profileId,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      businessDate: businessDate,
      note: note,
      projectId: projectId,
    ),
    profileId: profileId,
    receiptSources: receiptSources,
  );

  Future<Result<BookkeepingEntry>> _recordWithReceipts({
    required Future<Result<BookkeepingEntry>> Function() create,
    required LocalId profileId,
    required List<File> receiptSources,
  }) async {
    if (receiptSources.length > maximumReceiptsPerTransaction) {
      return const Failure(FailureCode.attachmentLimitReached);
    }
    if (receiptSources.isEmpty) return create();

    final prepared = <(LocalId, StoredReceiptFile)>[];
    for (final source in receiptSources) {
      final id = ids.generate();
      final result = await files.importImage(source, id.value);
      if (result is Failure<StoredReceiptFile>) {
        await _removePrepared(prepared);
        return Failure(result.code);
      }
      prepared.add((id, (result as Success<StoredReceiptFile>).value));
      final spooled = await _prepareSpool(id, prepared.last.$2);
      if (spooled is Failure<bool>) {
        await _removePrepared(prepared);
        return Failure(spooled.code);
      }
    }

    final entryResult = await create();
    if (entryResult is Failure<BookkeepingEntry>) {
      await _removePrepared(prepared);
      return entryResult;
    }
    final entry = (entryResult as Success<BookkeepingEntry>).value;
    final associated = <ReceiptAttachment>[];
    for (var position = 0; position < prepared.length; position++) {
      final (id, stored) = prepared[position];
      final attachment = ReceiptAttachment(
        id: id,
        profileId: profileId,
        transactionId: entry.id,
        storageKey: stored.storageKey,
        mimeType: 'image/jpeg',
        byteSize: stored.byteSize,
        sha256Hex: stored.sha256Hex,
        position: position,
        createdAtUtc: _now(),
      );
      final result = await repository.create(attachment);
      if (result is Failure<ReceiptAttachment>) {
        for (final row in associated) {
          await repository.remove(profileId, row.id);
        }
        await _removePrepared(prepared);
        await bookkeeping.deleteEntry(profileId, entry.id);
        return Failure(result.code);
      }
      associated.add(attachment);
    }
    return Success(entry);
  }

  Future<void> _removePrepared(List<(LocalId, StoredReceiptFile)> rows) async {
    for (final (id, stored) in rows) {
      await files.remove(stored.storageKey);
      await syncSpool?.remove(id.value);
    }
  }

  Future<Result<bool>> _prepareSpool(
    LocalId id,
    StoredReceiptFile stored,
  ) async {
    if (syncSpool == null) return const Success(false);
    final resolved = await files.resolve(stored.storageKey);
    if (resolved is Failure<File>) return Failure(resolved.code);
    return syncSpool!.prepare(
      attachmentId: id.value,
      processedFile: (resolved as Success<File>).value,
      sha256Hex: stored.sha256Hex,
      byteSize: stored.byteSize,
    );
  }

  Future<Result<List<ReceiptAttachment>>> list(
    LocalId profileId,
    LocalId transactionId,
  ) => repository.list(profileId, transactionId);

  Future<Result<File>> resolve(ReceiptAttachment attachment) =>
      files.resolve(attachment.storageKey);

  Future<Result<void>> remove(LocalId profileId, LocalId attachmentId) async {
    final removed = await repository.remove(profileId, attachmentId);
    if (removed is Failure<ReceiptAttachment>) return Failure(removed.code);
    await syncSpool?.removeIfUnreferenced(attachmentId.value);
    return files.remove(
      (removed as Success<ReceiptAttachment>).value.storageKey,
    );
  }

  /// Sync transport files are device metadata and must not survive a full
  /// logical backup restore.
  Future<void> clearSyncSpoolAfterRestore() async {
    await syncSpool?.clearAll();
  }

  Future<Result<ReceiptReconciliation>> reconcile(LocalId profileId) async {
    final metadata = await repository.listAll(profileId);
    if (metadata is Failure<List<ReceiptAttachment>>) {
      return Failure(metadata.code);
    }
    final rows = (metadata as Success<List<ReceiptAttachment>>).value;
    final result = await files.reconcile({
      for (final row in rows) row.storageKey,
    });
    if (result is Failure<ReceiptReconciliation>) return result;
    final reconciliation = (result as Success<ReceiptReconciliation>).value;
    for (final row in rows) {
      if (reconciliation.missingReferences.contains(row.storageKey)) {
        await repository.remove(profileId, row.id);
      }
    }
    return Success(reconciliation);
  }
}
