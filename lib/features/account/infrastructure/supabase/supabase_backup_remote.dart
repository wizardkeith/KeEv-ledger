import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/result.dart';
import '../../application/cloud_backend_contracts.dart';
import '../../application/cloud_backup_coordinator.dart';

final class SupabaseBackupRemote implements CloudBackupRemote {
  const SupabaseBackupRemote(this.client);
  final SupabaseClient client;

  @override
  String? get currentAccountId => client.auth.currentUser?.id;

  @override
  Future<Result<void>> uploadObject(String path, File file) async {
    try {
      await client.storage
          .from('ledger-backups')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'application/octet-stream',
            ),
          );
      return const Success(null);
    } on StorageException catch (error) {
      return Failure(
        error.statusCode == '413'
            ? FailureCode.storageQuotaExceeded
            : FailureCode.cloudUploadFailed,
      );
    } on Object {
      return const Failure(FailureCode.cloudUploadFailed);
    }
  }

  @override
  Future<Result<void>> deleteObject(String path) async {
    try {
      await client.storage.from('ledger-backups').remove([path]);
      return const Success(null);
    } on StorageException catch (error) {
      return Failure(classifyDeleteStorageFailure(error.statusCode));
    } on Object {
      return const Failure(FailureCode.networkUnavailable);
    }
  }

  static FailureCode classifyDeleteStorageFailure(String? statusCode) {
    final status = int.tryParse(statusCode ?? '');
    if (status == 404) return FailureCode.cloudBackupNotFound;
    if (status == 401 || status == 403) return FailureCode.unauthorized;
    if (status == 408) return FailureCode.networkUnavailable;
    if (status == 429) return FailureCode.rateLimited;
    if (status != null && status >= 500) return FailureCode.backendUnavailable;
    return FailureCode.cloudBackupDeleteFailed;
  }

  @override
  Future<Result<CloudBackupMetadata>> insertMetadata(
    String accountId,
    String path,
    CloudBackupUpload upload,
  ) async {
    try {
      final row = await client
          .from('ledger_backups')
          .insert({
            'id': upload.id,
            'user_id': accountId,
            'storage_path': path,
            'encrypted_size_bytes': upload.byteSize,
            'format_version': upload.formatVersion,
            'encrypted_sha256': upload.encryptedSha256,
            'app_version': upload.appVersion,
          })
          .select()
          .single();
      return Success(_backup(row));
    } on PostgrestException catch (error) {
      return Failure(
        error.code == '42501'
            ? FailureCode.unauthorized
            : FailureCode.cloudUploadFailed,
      );
    } on Object {
      return const Failure(FailureCode.cloudUploadFailed);
    }
  }

  @override
  Future<Result<List<CloudBackupMetadata>>> listMetadata(
    String accountId,
  ) async {
    try {
      final rows = await client
          .from('ledger_backups')
          .select()
          .eq('user_id', accountId)
          .order('created_at', ascending: false);
      return Success(rows.map(_backup).toList());
    } on Object {
      return const Failure(FailureCode.backendUnavailable);
    }
  }

  @override
  Future<Result<CloudBackupMetadata>> getMetadata(
    String accountId,
    String backupId,
  ) async {
    try {
      final row = await client
          .from('ledger_backups')
          .select()
          .eq('user_id', accountId)
          .eq('id', backupId)
          .single();
      return Success(_backup(row));
    } on Object {
      return const Failure(FailureCode.cloudBackupNotFound);
    }
  }

  @override
  Future<Result<List<int>>> downloadObject(String path) async {
    try {
      return Success(
        await client.storage.from('ledger-backups').download(path),
      );
    } on Object {
      return const Failure(FailureCode.cloudDownloadFailed);
    }
  }

  @override
  Future<Result<void>> deleteMetadata(String accountId, String backupId) async {
    try {
      await client
          .from('ledger_backups')
          .delete()
          .eq('user_id', accountId)
          .eq('id', backupId);
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.cloudBackupDeleteFailed);
    }
  }

  CloudBackupMetadata _backup(Map<String, dynamic> row) => CloudBackupMetadata(
    id: row['id'] as String,
    createdAtUtc: DateTime.parse(row['created_at'] as String).toUtc(),
    byteSize: row['encrypted_size_bytes'] as int,
    formatVersion: row['format_version'] as int,
    encryptedSha256: row['encrypted_sha256'] as String,
    storagePath: row['storage_path'] as String,
    appVersion: row['app_version'] as String?,
  );
}
