import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/result.dart';
import '../../application/authentication_contracts.dart';
import '../../application/cloud_backend_contracts.dart';
import '../../application/cloud_backup_coordinator.dart';
import 'supabase_backup_remote.dart';

/// Profile and immutable encrypted backup API. Contains no synchronization.
final class SupabaseBackendApi implements AuthenticatedBackendApi {
  SupabaseBackendApi(this.client)
    : _backups = CloudBackupCoordinator(SupabaseBackupRemote(client));

  final SupabaseClient client;
  final CloudBackupCoordinator _backups;

  @override
  Future<Result<void>> validateSession(SessionSecrets secrets) async {
    try {
      final user = await client.auth.getUser(secrets.accessToken);
      return user.user == null
          ? const Failure(FailureCode.unauthorized)
          : const Success(null);
    } on AuthRetryableFetchException {
      return const Failure(FailureCode.networkUnavailable);
    } on AuthException {
      return const Failure(FailureCode.unauthorized);
    } on Object {
      return const Failure(FailureCode.backendUnavailable);
    }
  }

  @override
  Future<Result<CloudAccountProfile>> currentProfile(
    SessionSecrets secrets,
  ) async {
    try {
      final user = await client.auth.getUser(secrets.accessToken);
      final id = user.user?.id;
      if (id == null) return const Failure(FailureCode.unauthorized);
      final row = await client.from('profiles').select().eq('id', id).single();
      return Success(_profile(row));
    } on AuthRetryableFetchException {
      return const Failure(FailureCode.networkUnavailable);
    } on PostgrestException catch (error) {
      return Failure(
        error.code == '42501'
            ? FailureCode.unauthorized
            : FailureCode.backendUnavailable,
      );
    } on Object {
      return const Failure(FailureCode.backendUnavailable);
    }
  }

  @override
  Future<Result<void>> updateAccountProfile(
    SessionSecrets secrets,
    CloudAccountProfileUpdate update,
  ) async {
    try {
      final user = await client.auth.getUser(secrets.accessToken);
      final id = user.user?.id;
      if (id == null) return const Failure(FailureCode.unauthorized);
      await client.from('profiles').upsert({
        'id': id,
        'display_name': _name(update.displayName),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return const Success(null);
    } on AuthRetryableFetchException {
      return const Failure(FailureCode.networkUnavailable);
    } on PostgrestException catch (error) {
      return Failure(
        error.code == '42501'
            ? FailureCode.unauthorized
            : FailureCode.backendUnavailable,
      );
    } on Object {
      return const Failure(FailureCode.backendUnavailable);
    }
  }

  CloudAccountProfile _profile(Map<String, dynamic> row) => CloudAccountProfile(
    accountId: row['id'] as String,
    displayName: _name(row['display_name'] as String?),
    createdAtUtc: DateTime.parse(row['created_at'] as String).toUtc(),
    updatedAtUtc: DateTime.parse(row['updated_at'] as String).toUtc(),
  );

  String? _name(String? value) {
    final name = value?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  @override
  Future<Result<CloudBackupMetadata>> uploadBackup(
    SessionSecrets secrets,
    CloudBackupUpload upload,
  ) => _backups.upload(upload);

  @override
  Future<Result<List<CloudBackupMetadata>>> listBackups(
    SessionSecrets secrets,
  ) => _backups.list();

  @override
  Future<Result<List<int>>> retrieveBackup(
    SessionSecrets secrets,
    String backupId,
  ) => _backups.retrieve(backupId);

  @override
  Future<Result<void>> deleteBackup(SessionSecrets secrets, String backupId) =>
      _backups.delete(backupId);
}
