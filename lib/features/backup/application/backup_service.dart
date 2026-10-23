import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../domain/backup.dart';
import '../infrastructure/backup_archive_codec.dart';
import '../infrastructure/backup_crypto.dart';
import '../infrastructure/receipt_restore_file_system.dart';
import 'backup_contracts.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();

final class BackupService {
  BackupService({
    required this.store,
    required this.receiptDirectoryProvider,
    required this.temporaryDirectoryProvider,
    BackupCrypto? crypto,
    this.archive = const BackupArchiveCodec(),
    this.clock = const SystemClock(),
    ReceiptRestoreFileSystem? restoreFiles,
  }) : crypto = crypto ?? BackupCrypto(),
       restoreFiles = restoreFiles ?? const LocalReceiptRestoreFileSystem();

  final LedgerBackupStore store;
  final BackupDirectoryProvider receiptDirectoryProvider;
  final BackupDirectoryProvider temporaryDirectoryProvider;
  final BackupCrypto crypto;
  final BackupArchiveCodec archive;
  final Clock clock;
  final ReceiptRestoreFileSystem restoreFiles;

  Future<Result<LocalBackupFile>> createLocalBackup(String passphrase) async {
    try {
      final snapshotResult = await store.exportLogicalSnapshot();
      if (snapshotResult is Failure<Map<String, dynamic>>)
        return Failure(snapshotResult.code);
      final snapshot = (snapshotResult as Success<Map<String, dynamic>>).value;
      final profiles = snapshot['localProfiles'] as List;
      final profile = profiles.single as Map<String, dynamic>;
      final receiptRows = snapshot['receiptAttachments'] as List;
      final receipts = <String, List<int>>{};
      final receiptRoot = await receiptDirectoryProvider();
      for (final item in receiptRows) {
        final row = item as Map<String, dynamic>;
        final key = row['storageKey'] as String;
        if (!RegExp(r'^[0-9a-f-]{36}\.jpg$').hasMatch(key))
          throw const FormatException();
        final file = File('${receiptRoot.path}${Platform.pathSeparator}$key');
        if (!await file.exists())
          return const Failure(FailureCode.attachmentNotFound);
        final bytes = await file.readAsBytes();
        if (bytes.length != row['byteSize'] ||
            sha256.convert(bytes).toString() != row['sha256Hex'] ||
            bytes.length < 4 ||
            bytes[0] != 0xff ||
            bytes[1] != 0xd8 ||
            bytes[2] != 0xff) {
          return const Failure(FailureCode.corruptedBackup);
        }
        receipts[key] = bytes;
      }
      final counts = <String, int>{
        for (final key in [
          'accounts',
          'categories',
          'projects',
          'budgets',
          'transactions',
          'transfers',
        ])
          key: (snapshot[key] as List).length,
      };
      final now = clock.nowUtc();
      final manifest = BackupManifest(
        createdAtUtc: now,
        appVersion: '0.1.0+1',
        sourcePlatform: Platform.operatingSystem,
        sourceSchemaVersion: snapshot['sourceDriftSchemaVersion'] as int,
        profileId: profile['id'] as String,
        baseCurrencyCode: profile['baseCurrencyCode'] as String,
        entityCounts: counts,
        attachmentCount: receipts.length,
      );
      final plain = archive.encode(
        manifest: manifest,
        ledgerData: snapshot,
        receipts: receipts,
      );
      final encrypted = await crypto.encrypt(plain, passphrase);
      final temp = await temporaryDirectoryProvider();
      if (!await temp.exists()) await temp.create(recursive: true);
      final file = File(
        '${temp.path}${Platform.pathSeparator}${_fileName(now)}',
      );
      await file.writeAsBytes(encrypted, flush: true);
      return Success(LocalBackupFile(file: file, manifest: manifest));
    } on FileSystemException {
      return const Failure(FailureCode.insufficientLocalStorage);
    } on FormatException {
      return const Failure(FailureCode.backupGenerationFailed);
    } on Object {
      return const Failure(FailureCode.backupGenerationFailed);
    }
  }

  Future<Result<PreparedRestore>> prepareRestore(
    File file,
    String passphrase,
  ) async {
    try {
      if (!await file.exists() ||
          await file.length() > maximumBackupContainerBytes) {
        return const Failure(FailureCode.invalidBackupFile);
      }
      final encrypted = await file.readAsBytes();
      final plain = await crypto.decrypt(encrypted, passphrase);
      final prepared = archive.decode(plain, encryptedBytes: encrypted.length);
      final validation = await store.validateLogicalSnapshot(
        prepared.ledgerData,
      );
      return validation is Failure<void>
          ? Failure(validation.code)
          : Success(prepared);
    } on SecretBoxAuthenticationError {
      return const Failure(FailureCode.wrongBackupPassphrase);
    } on FormatException {
      return const Failure(FailureCode.corruptedBackup);
    } on FileSystemException {
      return const Failure(FailureCode.localImportFailed);
    } on Object {
      return const Failure(FailureCode.corruptedBackup);
    }
  }

  Future<Result<void>> restore(PreparedRestore prepared) async {
    Directory? safety;
    Directory? staging;
    final receiptRoot = await receiptDirectoryProvider();
    var safetySnapshotComplete = false;
    var liveReceiptMutationStarted = false;
    var databaseReplacementSucceeded = false;
    var rollbackSucceeded = false;
    try {
      final tempRoot = await temporaryDirectoryProvider();
      staging = await restoreFiles.createDirectory(
        '${tempRoot.path}${Platform.pathSeparator}keev-restore-${clock.nowUtc().microsecondsSinceEpoch}',
      );
      for (final entry in prepared.receiptFiles.entries) {
        await restoreFiles.writeVerified(
          File('${staging.path}${Platform.pathSeparator}${entry.key}'),
          entry.value,
        );
      }
      await restoreFiles.verifyPrepared(staging, prepared.receiptFiles);

      safety = await restoreFiles.createDirectory(
        '${tempRoot.path}${Platform.pathSeparator}keev-safety-${clock.nowUtc().microsecondsSinceEpoch}',
      );
      await restoreFiles.copyVerifiedReceipts(receiptRoot, safety);
      safetySnapshotComplete = true;

      if (!await receiptRoot.exists())
        await restoreFiles.createDirectory(receiptRoot.path);
      liveReceiptMutationStarted = true;
      await restoreFiles.clearReceipts(receiptRoot);
      await restoreFiles.copyVerifiedReceipts(staging, receiptRoot);
      await restoreFiles.verifyPrepared(receiptRoot, prepared.receiptFiles);
      final replaced = await store.replaceLogicalSnapshot(prepared.ledgerData);
      if (replaced is Failure<void>) {
        await restoreFiles.clearReceipts(receiptRoot);
        await restoreFiles.copyVerifiedReceipts(safety, receiptRoot);
        rollbackSucceeded = true;
        return Failure(replaced.code);
      }
      databaseReplacementSucceeded = true;
      return const Success(null);
    } on FileSystemException {
      if (liveReceiptMutationStarted &&
          safetySnapshotComplete &&
          safety != null) {
        try {
          await restoreFiles.clearReceipts(receiptRoot);
          await restoreFiles.copyVerifiedReceipts(safety, receiptRoot);
          rollbackSucceeded = true;
        } on FileSystemException {
          rollbackSucceeded = false;
        }
      }
      return const Failure(FailureCode.restoreFailed);
    } finally {
      if (staging != null) {
        try {
          await restoreFiles.deleteTree(staging);
        } on FileSystemException {
          // Cleanup is best effort; it cannot invalidate a core result.
        }
      }
      final mayDeleteSafety =
          databaseReplacementSucceeded ||
          (!liveReceiptMutationStarted && !safetySnapshotComplete) ||
          (liveReceiptMutationStarted && rollbackSucceeded);
      if (safety != null && mayDeleteSafety) {
        try {
          await restoreFiles.deleteTree(safety);
        } on FileSystemException {
          // A leftover private safety copy is safer than surfacing cleanup.
        }
      }
    }
  }

  String _fileName(DateTime value) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'KeEv-Ledger-${value.year}${two(value.month)}${two(value.day)}-${two(value.hour)}${two(value.minute)}${two(value.second)}.keevbackup';
  }
}
