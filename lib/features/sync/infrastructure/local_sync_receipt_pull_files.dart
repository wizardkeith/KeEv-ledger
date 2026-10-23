import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/result.dart';
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';

typedef ReceiptSyncDirectoryProvider = Future<Directory> Function();

final class LocalSyncReceiptPullFiles implements SyncReceiptPullFiles {
  const LocalSyncReceiptPullFiles({
    required this.transport,
    required ReceiptSyncDirectoryProvider directoryProvider,
  }) : _directoryProvider = directoryProvider;
  final SyncReceiptTransport transport;
  final ReceiptSyncDirectoryProvider _directoryProvider;

  @override
  Future<Result<PreparedSyncReceipt>> prepare(SyncChange change) async {
    final p = change.snapshot;
    final path = p['storage_path'];
    final expectedHash = p['sha256_hex'];
    final expectedSize = p['byte_size'];
    if (path is! String ||
        expectedHash is! String ||
        expectedSize is! int ||
        p['mime_type'] != 'image/jpeg') {
      return const Failure(FailureCode.syncInvalidRemoteData);
    }
    final downloaded = await transport.download(path);
    if (downloaded is Failure<List<int>>) return Failure(downloaded.code);
    final bytes = (downloaded as Success<List<int>>).value;
    if (bytes.length != expectedSize ||
        sha256.convert(bytes).toString() != expectedHash) {
      return const Failure(FailureCode.syncAttachmentIntegrityFailure);
    }
    try {
      final root = await _directoryProvider();
      if (!await root.exists()) await root.create(recursive: true);
      final key = '${change.entityId}.jpg';
      final stagingRoot = Directory(
        '${root.path}${Platform.pathSeparator}.sync_staging',
      );
      if (!await stagingRoot.exists()) {
        await stagingRoot.create(recursive: true);
      }
      final staged = File(
        '${stagingRoot.path}${Platform.pathSeparator}'
        '${change.mutationId}.pending',
      );
      final target = File('${root.path}${Platform.pathSeparator}$key');
      await staged.writeAsBytes(bytes, flush: true);
      return Success(
        PreparedSyncReceipt(
          storageKey: key,
          stagingFile: staged,
          liveFile: target,
        ),
      );
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<String>> promote(PreparedSyncReceipt prepared) async {
    final staged = prepared.stagingFile as File;
    final live = prepared.liveFile as File;
    try {
      if (await live.exists()) {
        return const Failure(FailureCode.syncInvalidRemoteData);
      }
      await staged.rename(live.path);
      prepared.promoted = true;
      return Success(prepared.storageKey);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> compensate(PreparedSyncReceipt prepared) async {
    try {
      final staged = prepared.stagingFile as File;
      if (await staged.exists()) await staged.delete();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> rollbackPromotion(PreparedSyncReceipt prepared) async {
    try {
      if (!prepared.promoted) return await compensate(prepared);
      final live = prepared.liveFile as File;
      if (await live.exists()) await live.delete();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }

  @override
  Future<Result<void>> removeAfterCommit(String storageKey) async {
    try {
      final root = await _directoryProvider();
      final file = File('${root.path}${Platform.pathSeparator}$storageKey');
      if (await file.exists()) await file.delete();
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.syncAttachmentFailure);
    }
  }
}
