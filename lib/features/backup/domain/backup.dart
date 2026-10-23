import 'dart:io';

const keevBackupFormatVersion = 1;
const maximumBackupContainerBytes = 64 * 1024 * 1024;
const maximumBackupHeaderBytes = 4096;
const backupContainerFixedOverheadBytes = 8 + 4 + 16;
const maximumBackupPlaintextBytes =
    maximumBackupContainerBytes -
    maximumBackupHeaderBytes -
    backupContainerFixedOverheadBytes;
const maximumBackupEntries = 1024;

final class BackupManifest {
  const BackupManifest({
    required this.createdAtUtc,
    required this.appVersion,
    required this.sourcePlatform,
    required this.sourceSchemaVersion,
    required this.profileId,
    required this.baseCurrencyCode,
    required this.entityCounts,
    required this.attachmentCount,
  });
  final DateTime createdAtUtc;
  final String appVersion, sourcePlatform, profileId, baseCurrencyCode;
  final int sourceSchemaVersion, attachmentCount;
  final Map<String, int> entityCounts;

  Map<String, Object> toJson() => {
    'productId': 'com.keev.ledger',
    'formatVersion': keevBackupFormatVersion,
    'appVersion': appVersion,
    'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
    'sourcePlatform': sourcePlatform,
    'sourceSchemaVersion': sourceSchemaVersion,
    'profileId': profileId,
    'baseCurrencyCode': baseCurrencyCode,
    'entityCounts': Map<String, int>.from(entityCounts),
    'attachmentCount': attachmentCount,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    if (json['productId'] != 'com.keev.ledger' ||
        json['formatVersion'] != keevBackupFormatVersion) {
      throw const FormatException('Unsupported manifest');
    }
    final counts = json['entityCounts'];
    if (counts is! Map<String, dynamic>) throw const FormatException();
    return BackupManifest(
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String).toUtc(),
      appVersion: json['appVersion'] as String,
      sourcePlatform: json['sourcePlatform'] as String,
      sourceSchemaVersion: json['sourceSchemaVersion'] as int,
      profileId: json['profileId'] as String,
      baseCurrencyCode: json['baseCurrencyCode'] as String,
      entityCounts: counts.map((key, value) => MapEntry(key, value as int)),
      attachmentCount: json['attachmentCount'] as int,
    );
  }
}

final class RestorePreview {
  const RestorePreview({required this.manifest, required this.encryptedBytes});
  final BackupManifest manifest;
  final int encryptedBytes;
}

final class PreparedRestore {
  const PreparedRestore({
    required this.preview,
    required this.ledgerData,
    required this.receiptFiles,
  });
  final RestorePreview preview;
  final Map<String, dynamic> ledgerData;
  final Map<String, List<int>> receiptFiles;
}

final class LocalBackupFile {
  const LocalBackupFile({required this.file, required this.manifest});
  final File file;
  final BackupManifest manifest;
}

final class CloudBackupRecord {
  const CloudBackupRecord({
    required this.id,
    required this.createdAtUtc,
    required this.encryptedSizeBytes,
    required this.formatVersion,
    required this.encryptedSha256,
    this.appVersion,
  });
  final String id, encryptedSha256;
  final String? appVersion;
  final DateTime createdAtUtc;
  final int encryptedSizeBytes, formatVersion;
}
