import 'dart:io';

import 'package:crypto/crypto.dart';

abstract interface class ReceiptRestoreFileSystem {
  Future<Directory> createDirectory(String path);
  Future<void> writeVerified(File file, List<int> bytes);
  Future<void> copyVerifiedReceipts(Directory from, Directory to);
  Future<void> verifyPrepared(
    Directory directory,
    Map<String, List<int>> expected,
  );
  Future<void> clearReceipts(Directory directory);
  Future<void> deleteTree(Directory directory);
}

final class LocalReceiptRestoreFileSystem implements ReceiptRestoreFileSystem {
  const LocalReceiptRestoreFileSystem();

  static final _receiptName = RegExp(r'^[0-9a-f-]{36}\.jpg$');

  @override
  Future<Directory> createDirectory(String path) =>
      Directory(path).create(recursive: true);

  @override
  Future<void> writeVerified(File file, List<int> bytes) async {
    await file.writeAsBytes(bytes, flush: true);
    final stored = await file.readAsBytes();
    if (stored.length != bytes.length ||
        sha256.convert(stored) != sha256.convert(bytes)) {
      throw const FileSystemException('Receipt staging verification failed');
    }
  }

  @override
  Future<void> copyVerifiedReceipts(Directory from, Directory to) async {
    if (!await from.exists()) return;
    if (!await to.exists()) await to.create(recursive: true);
    await for (final entity in from.list(followLinks: false)) {
      if (entity is! File ||
          !_receiptName.hasMatch(entity.uri.pathSegments.last)) {
        continue;
      }
      final target = File(
        '${to.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}',
      );
      final sourceBytes = await entity.readAsBytes();
      await target.writeAsBytes(sourceBytes, flush: true);
      final copied = await target.readAsBytes();
      if (copied.length != sourceBytes.length ||
          sha256.convert(copied) != sha256.convert(sourceBytes)) {
        throw const FileSystemException('Receipt safety copy failed');
      }
    }
  }

  @override
  Future<void> verifyPrepared(
    Directory directory,
    Map<String, List<int>> expected,
  ) async {
    for (final entry in expected.entries) {
      final file = File(
        '${directory.path}${Platform.pathSeparator}${entry.key}',
      );
      if (!await file.exists()) {
        throw const FileSystemException('Prepared receipt missing');
      }
      final bytes = await file.readAsBytes();
      if (bytes.length != entry.value.length ||
          sha256.convert(bytes) != sha256.convert(entry.value)) {
        throw const FileSystemException('Prepared receipt mismatch');
      }
    }
  }

  @override
  Future<void> clearReceipts(Directory directory) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File &&
          _receiptName.hasMatch(entity.uri.pathSegments.last)) {
        await entity.delete();
      }
    }
  }

  @override
  Future<void> deleteTree(Directory directory) async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
