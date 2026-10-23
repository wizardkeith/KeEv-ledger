import '../../../core/result.dart';
import 'authentication_contracts.dart';

final class CloudAccountProfileUpdate {
  const CloudAccountProfileUpdate({this.displayName});
  final String? displayName;
}

final class CloudAccountProfile {
  const CloudAccountProfile({
    required this.accountId,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.displayName,
  });

  final String accountId;
  final String? displayName;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class CloudBackupMetadata {
  const CloudBackupMetadata({
    required this.id,
    required this.createdAtUtc,
    required this.byteSize,
    required this.formatVersion,
    required this.encryptedSha256,
    required this.storagePath,
    this.appVersion,
  });

  final String id;
  final DateTime createdAtUtc;
  final int byteSize;
  final int formatVersion;
  final String encryptedSha256, storagePath;
  final String? appVersion;
}

final class CloudBackupUpload {
  const CloudBackupUpload({
    required this.id,
    required this.filePath,
    required this.byteSize,
    required this.encryptedSha256,
    required this.formatVersion,
    required this.appVersion,
  });

  final String id, filePath, encryptedSha256, appVersion;
  final int byteSize;
  final int formatVersion;
}

/// Authenticated Phase 5 API boundary. No Phase 6 sync operations belong here.
abstract interface class AuthenticatedBackendApi {
  Future<Result<void>> validateSession(SessionSecrets secrets);
  Future<Result<CloudAccountProfile>> currentProfile(SessionSecrets secrets);
  Future<Result<void>> updateAccountProfile(
    SessionSecrets secrets,
    CloudAccountProfileUpdate update,
  );
  Future<Result<CloudBackupMetadata>> uploadBackup(
    SessionSecrets secrets,
    CloudBackupUpload upload,
  );
  Future<Result<List<CloudBackupMetadata>>> listBackups(SessionSecrets secrets);
  Future<Result<List<int>>> retrieveBackup(
    SessionSecrets secrets,
    String backupId,
  );
  Future<Result<void>> deleteBackup(SessionSecrets secrets, String backupId);
}
