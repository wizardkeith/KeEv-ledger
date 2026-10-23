import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/account/application/cloud_backend_contracts.dart';
import 'package:ledger/features/account/application/cloud_backup_coordinator.dart';

final class _CloudRemote implements CloudBackupRemote {
  _CloudRemote({this.currentAccountId});

  @override
  String? currentAccountId;
  final events = <String>[];
  final objects = <String, List<int>>{};
  final metadata = <String, CloudBackupMetadata>{};
  FailureCode? uploadFailure, metadataFailure, listFailure;

  @override
  Future<Result<void>> uploadObject(String path, File file) async {
    events.add('upload:$path');
    if (uploadFailure != null) return Failure(uploadFailure!);
    objects[path] = await file.readAsBytes();
    return const Success(null);
  }

  @override
  Future<Result<CloudBackupMetadata>> insertMetadata(
    String accountId,
    String path,
    CloudBackupUpload upload,
  ) async {
    events.add('metadata:${upload.id}');
    if (metadataFailure != null) return Failure(metadataFailure!);
    final value = CloudBackupMetadata(
      id: upload.id,
      createdAtUtc: DateTime.utc(2026, 9, 21),
      byteSize: upload.byteSize,
      formatVersion: upload.formatVersion,
      encryptedSha256: upload.encryptedSha256,
      storagePath: path,
      appVersion: upload.appVersion,
    );
    metadata[value.id] = value;
    return Success(value);
  }

  @override
  Future<Result<List<CloudBackupMetadata>>> listMetadata(
    String accountId,
  ) async {
    events.add('list:$accountId');
    return listFailure == null
        ? Success(metadata.values.toList())
        : Failure(listFailure!);
  }

  @override
  Future<Result<CloudBackupMetadata>> getMetadata(
    String accountId,
    String backupId,
  ) async {
    events.add('get:$backupId');
    final value = metadata[backupId];
    return value == null
        ? const Failure(FailureCode.cloudBackupNotFound)
        : Success(value);
  }

  @override
  Future<Result<List<int>>> downloadObject(String path) async {
    events.add('download:$path');
    final value = objects[path];
    return value == null
        ? const Failure(FailureCode.cloudBackupNotFound)
        : Success(value);
  }

  @override
  Future<Result<void>> deleteObject(String path) async {
    events.add('delete-object:$path');
    return objects.remove(path) == null
        ? const Failure(FailureCode.cloudBackupNotFound)
        : const Success(null);
  }

  @override
  Future<Result<void>> deleteMetadata(String accountId, String backupId) async {
    events.add('delete-metadata:$backupId');
    metadata.remove(backupId);
    return const Success(null);
  }
}

void main() {
  late Directory directory;
  late File file;
  late List<int> bytes;
  late CloudBackupUpload upload;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keev-cloud-backup-');
    bytes = List<int>.generate(64, (index) => index);
    file = await File('${directory.path}/backup.keevbackup')
        .writeAsBytes(bytes);
    upload = CloudBackupUpload(
      id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      filePath: file.path,
      byteSize: bytes.length,
      encryptedSha256: sha256.convert(bytes).toString(),
      formatVersion: 1,
      appVersion: '1.0.0',
    );
  });

  tearDown(() => directory.delete(recursive: true));

  test('signed-out cloud operations are rejected', () async {
    final coordinator = CloudBackupCoordinator(_CloudRemote());
    expect(
      await coordinator.upload(upload),
      isA<Failure<CloudBackupMetadata>>(),
    );
    expect(await coordinator.list(), isA<Failure<List<CloudBackupMetadata>>>());
    expect(await coordinator.retrieve(upload.id), isA<Failure<List<int>>>());
    expect(await coordinator.delete(upload.id), isA<Failure<void>>());
  });

  test('upload uses owned path then metadata', () async {
    final remote = _CloudRemote(currentAccountId: 'user-1');
    final coordinator = CloudBackupCoordinator(remote);
    expect(
      await coordinator.upload(upload),
      isA<Success<CloudBackupMetadata>>(),
    );
    expect(remote.events, [
      'upload:user-1/${upload.id}.keevbackup',
      'metadata:${upload.id}',
    ]);
  });

  test('upload and metadata failures cannot leave a claimed backup', () async {
    final uploadFailed = _CloudRemote(currentAccountId: 'user-1')
      ..uploadFailure = FailureCode.networkUnavailable;
    expect(
      await CloudBackupCoordinator(uploadFailed).upload(upload),
      isA<Failure<CloudBackupMetadata>>(),
    );
    expect(uploadFailed.events, ['upload:user-1/${upload.id}.keevbackup']);

    final metadataFailed = _CloudRemote(currentAccountId: 'user-1')
      ..metadataFailure = FailureCode.backendUnavailable;
    expect(
      await CloudBackupCoordinator(metadataFailed).upload(upload),
      isA<Failure<CloudBackupMetadata>>(),
    );
    expect(metadataFailed.events, [
      'upload:user-1/${upload.id}.keevbackup',
      'metadata:${upload.id}',
      'delete-object:user-1/${upload.id}.keevbackup',
    ]);
    expect(metadataFailed.objects, isEmpty);
  });

  test(
    'list, retrieve, integrity rejection, delete and network mapping',
    () async {
      final remote = _CloudRemote(currentAccountId: 'user-1');
      final coordinator = CloudBackupCoordinator(remote);
      await coordinator.upload(upload);
      expect(
        await coordinator.list(),
        isA<Success<List<CloudBackupMetadata>>>(),
      );
      final retrieved = await coordinator.retrieve(upload.id);
      expect((retrieved as Success<List<int>>).value, bytes);

      remote.objects['user-1/${upload.id}.keevbackup'] = [1, 2, 3];
      final corrupt = await coordinator.retrieve(upload.id);
      expect(corrupt, isA<Failure<List<int>>>());
      expect((corrupt as Failure<List<int>>).code, FailureCode.corruptedBackup);

      remote.objects['user-1/${upload.id}.keevbackup'] = bytes;
      expect(await coordinator.delete(upload.id), isA<Success<void>>());
      expect(remote.metadata, isEmpty);
      expect(remote.objects, isEmpty);

      remote.listFailure = FailureCode.networkUnavailable;
      final unavailable = await coordinator.list();
      expect(
        (unavailable as Failure<List<CloudBackupMetadata>>).code,
        FailureCode.networkUnavailable,
      );
    },
  );
}
