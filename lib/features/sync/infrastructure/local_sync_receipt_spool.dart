import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../application/sync_receipt_spool.dart';

typedef SyncSpoolDirectoryProvider = Future<Directory> Function();

final class LocalSyncReceiptSpool implements SyncReceiptSpool {
  const LocalSyncReceiptSpool({
    required this.db,
    required SyncSpoolDirectoryProvider directoryProvider,
    this.clock = const SystemClock(),
  }) : _directoryProvider = directoryProvider;

  final LedgerDatabase db;
  final SyncSpoolDirectoryProvider _directoryProvider;
  final Clock clock;

  Future<Directory> _root() async {
    final root = await _directoryProvider();
    if (!await root.exists()) await root.create(recursive: true);
    return root;
  }

  @override
  Future<Result<bool>> prepare({
    required String attachmentId,
    required File processedFile,
    required String sha256Hex,
    required int byteSize,
  }) async {
    File? staged;
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
      final bytes = await processedFile.readAsBytes();
      if (bytes.length != byteSize ||
          sha256.convert(bytes).toString() != sha256Hex) {
        return const Failure(FailureCode.syncAttachmentIntegrityFailure);
      }
      final root = await _root();
      staged = File(
        '${root.path}${Platform.pathSeparator}$attachmentId.pending',
      );
      final target = File(
        '${root.path}${Platform.pathSeparator}$attachmentId.jpg',
      );
      await staged.writeAsBytes(bytes, flush: true);
      if (await target.exists()) await target.delete();
      await staged.rename(target.path);
      await db
          .into(db.syncReceiptSpoolEntries)
          .insertOnConflictUpdate(
            SyncReceiptSpoolEntriesCompanion.insert(
              attachmentId: attachmentId,
              storageKey: '$attachmentId.jpg',
              sha256Hex: sha256Hex,
              byteSize: byteSize,
              createdAtUtc: clock.nowUtc().microsecondsSinceEpoch,
            ),
          );
      return const Success(true);
    } on Object {
      if (staged != null && await staged.exists()) await staged.delete();
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<File>> resolve(String attachmentId) async {
    try {
      final row =
          await (db.select(db.syncReceiptSpoolEntries)
                ..where((row) => row.attachmentId.equals(attachmentId)))
              .getSingleOrNull();
      if (row == null) return const Failure(FailureCode.attachmentNotFound);
      final file = File(
        '${(await _root()).path}${Platform.pathSeparator}${row.storageKey}',
      );
      return await file.exists()
          ? Success(file)
          : const Failure(FailureCode.attachmentNotFound);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> removeIfUnreferenced(String attachmentId) async {
    try {
      final referenced =
          await (db.select(db.syncReceiptSpoolEntries)
                ..where((row) => row.attachmentId.equals(attachmentId)))
              .getSingleOrNull();
      if (referenced != null) return const Success(null);
      final file = File(
        '${(await _root()).path}${Platform.pathSeparator}$attachmentId.jpg',
      );
      if (await file.exists()) await file.delete();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> remove(String attachmentId) async {
    try {
      final file = File(
        '${(await _root()).path}${Platform.pathSeparator}$attachmentId.jpg',
      );
      if (await file.exists()) await file.delete();
      await (db.delete(
        db.syncReceiptSpoolEntries,
      )..where((row) => row.attachmentId.equals(attachmentId))).go();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      final root = await _root();
      if (await root.exists()) await root.delete(recursive: true);
      await db.delete(db.syncReceiptSpoolEntries).go();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }
}
