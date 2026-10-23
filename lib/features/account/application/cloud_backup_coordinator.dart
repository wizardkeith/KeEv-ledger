import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/result.dart';
import 'cloud_backend_contracts.dart';

abstract interface class CloudBackupRemote {
  String? get currentAccountId;
  Future<Result<void>> uploadObject(String path, File file);
  Future<Result<void>> deleteObject(String path);
  Future<Result<CloudBackupMetadata>> insertMetadata(
    String accountId,
    String path,
    CloudBackupUpload upload,
  );
  Future<Result<List<CloudBackupMetadata>>> listMetadata(String accountId);
  Future<Result<CloudBackupMetadata>> getMetadata(
    String accountId,
    String backupId,
  );
  Future<Result<List<int>>> downloadObject(String path);
  Future<Result<void>> deleteMetadata(String accountId, String backupId);
}

/// Provider-neutral immutable snapshot orchestration. User ownership is taken
/// only from the authenticated remote, never from presentation input.
final class CloudBackupCoordinator {
  const CloudBackupCoordinator(this.remote);
  final CloudBackupRemote remote;

  Future<Result<CloudBackupMetadata>> upload(CloudBackupUpload upload) async {
    final accountId = remote.currentAccountId;
    if (accountId == null) {
      return const Failure(FailureCode.cloudAuthenticationRequired);
    }
    final path = '$accountId/${upload.id}.keevbackup';
    final object = await remote.uploadObject(path, File(upload.filePath));
    if (object is Failure<void>) return Failure(object.code);
    final metadata = await remote.insertMetadata(accountId, path, upload);
    if (metadata is Failure<CloudBackupMetadata>) {
      await remote.deleteObject(path); // Best effort orphan cleanup.
      return Failure(metadata.code);
    }
    return metadata;
  }

  Future<Result<List<CloudBackupMetadata>>> list() {
    final accountId = remote.currentAccountId;
    return accountId == null
        ? Future.value(const Failure(FailureCode.cloudAuthenticationRequired))
        : remote.listMetadata(accountId);
  }

  Future<Result<List<int>>> retrieve(String backupId) async {
    final accountId = remote.currentAccountId;
    if (accountId == null) {
      return const Failure(FailureCode.cloudAuthenticationRequired);
    }
    final metadata = await remote.getMetadata(accountId, backupId);
    if (metadata is Failure<CloudBackupMetadata>) {
      return Failure(metadata.code);
    }
    final value = (metadata as Success<CloudBackupMetadata>).value;
    final download = await remote.downloadObject(value.storagePath);
    if (download is Failure<List<int>>) return Failure(download.code);
    final bytes = (download as Success<List<int>>).value;
    if (sha256.convert(bytes).toString() != value.encryptedSha256) {
      return const Failure(FailureCode.corruptedBackup);
    }
    return Success(bytes);
  }

  Future<Result<void>> delete(String backupId) async {
    final accountId = remote.currentAccountId;
    if (accountId == null) {
      return const Failure(FailureCode.cloudAuthenticationRequired);
    }
    final metadata = await remote.getMetadata(accountId, backupId);
    if (metadata is Failure<CloudBackupMetadata>) {
      return Failure(metadata.code);
    }
    final value = (metadata as Success<CloudBackupMetadata>).value;
    final object = await remote.deleteObject(value.storagePath);
    if (object is Failure<void> &&
        object.code != FailureCode.cloudBackupNotFound) {
      return Failure(object.code);
    }
    return remote.deleteMetadata(accountId, backupId);
  }
}
