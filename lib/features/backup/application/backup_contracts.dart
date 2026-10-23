import 'dart:io';

import '../../../core/result.dart';
import '../domain/backup.dart';

abstract interface class LedgerBackupStore {
  Future<Result<Map<String, dynamic>>> exportLogicalSnapshot();
  Future<Result<void>> validateLogicalSnapshot(Map<String, dynamic> snapshot);
  Future<Result<void>> replaceLogicalSnapshot(Map<String, dynamic> snapshot);
}

abstract interface class BackupAttachmentStore {
  Future<Result<File>> resolve(String storageKey);
  Future<Result<Directory>> createRestoreStaging();
  Future<Result<void>> installPrepared(
    Directory staging,
    Set<String> storageKeys,
  );
  Future<Result<void>> discardPrepared(Directory staging);
  Future<Result<void>> reconcile(Set<String> storageKeys);
}

abstract interface class CloudBackupRepository {
  Future<Result<CloudBackupRecord>> upload(File encryptedBackup);
  Future<Result<List<CloudBackupRecord>>> list();
  Future<Result<File>> download(CloudBackupRecord backup, Directory target);
  Future<Result<void>> delete(CloudBackupRecord backup);
}
