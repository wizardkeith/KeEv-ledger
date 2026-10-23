import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as image;

import '../../../core/result.dart';
import '../application/receipt_contracts.dart';
import '../domain/receipt_attachment.dart';

typedef ReceiptDirectoryProvider = Future<Directory> Function();

final class LocalReceiptFileStore implements ReceiptFileStore {
  LocalReceiptFileStore({
    required ReceiptDirectoryProvider directoryProvider,
    this.maximumSourceBytes = 30 * 1024 * 1024,
    this.maximumLongEdge = 2048,
  }) : _directoryProvider = directoryProvider;

  final ReceiptDirectoryProvider _directoryProvider;
  final int maximumSourceBytes, maximumLongEdge;

  Future<Directory> _root() async {
    final root = await _directoryProvider();
    if (!await root.exists()) await root.create(recursive: true);
    return root;
  }

  String _path(Directory root, String name) =>
      '${root.path}${Platform.pathSeparator}$name';

  bool _safeKey(String key) => RegExp(r'^[0-9a-f-]{36}\.jpg$').hasMatch(key);

  @override
  Future<Result<StoredReceiptFile>> importImage(
    File source,
    String attachmentId,
  ) async {
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(attachmentId)) {
      throw ArgumentError.value(attachmentId, 'attachmentId');
    }
    try {
      if (!await source.exists()) {
        return const Failure(FailureCode.attachmentNotFound);
      }
      final sourceSize = await source.length();
      if (sourceSize <= 0 || sourceSize > maximumSourceBytes) {
        return const Failure(FailureCode.attachmentTooLarge);
      }
      final sourceBytes = await source.readAsBytes();
      var decoded = image.decodeImage(sourceBytes);
      if (decoded == null) {
        return const Failure(FailureCode.attachmentInvalidImage);
      }
      decoded = image.bakeOrientation(decoded);
      final longEdge = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      if (longEdge > maximumLongEdge) {
        decoded = decoded.width >= decoded.height
            ? image.copyResize(decoded, width: maximumLongEdge)
            : image.copyResize(decoded, height: maximumLongEdge);
      }

      List<int>? processed;
      for (final quality in const [88, 80, 72]) {
        final candidate = image.encodeJpg(decoded, quality: quality);
        if (candidate.length <= maximumProcessedReceiptBytes) {
          processed = candidate;
          break;
        }
      }
      if (processed == null || processed.isEmpty) {
        return const Failure(FailureCode.attachmentTooLarge);
      }

      final root = await _root();
      final storageKey = '$attachmentId.jpg';
      final staging = File(_path(root, '$attachmentId.pending'));
      final finalFile = File(_path(root, storageKey));
      await staging.writeAsBytes(processed, flush: true);
      if (await finalFile.exists()) await finalFile.delete();
      await staging.rename(finalFile.path);
      return Success(
        StoredReceiptFile(
          storageKey: storageKey,
          byteSize: processed.length,
          sha256Hex: sha256.convert(processed).toString(),
        ),
      );
    } on FileSystemException {
      return const Failure(FailureCode.attachmentStorageUnavailable);
    } on RangeError {
      return const Failure(FailureCode.attachmentInvalidImage);
    }
  }

  @override
  Future<Result<File>> resolve(String storageKey) async {
    if (!_safeKey(storageKey)) {
      return const Failure(FailureCode.attachmentNotFound);
    }
    try {
      final file = File(_path(await _root(), storageKey));
      return await file.exists()
          ? Success(file)
          : const Failure(FailureCode.attachmentNotFound);
    } on FileSystemException {
      return const Failure(FailureCode.attachmentStorageUnavailable);
    }
  }

  @override
  Future<Result<void>> remove(String storageKey) async {
    if (!_safeKey(storageKey)) {
      return const Failure(FailureCode.attachmentNotFound);
    }
    try {
      final file = File(_path(await _root(), storageKey));
      if (await file.exists()) await file.delete();
      return const Success(null);
    } on FileSystemException {
      return const Failure(FailureCode.attachmentStorageUnavailable);
    }
  }

  @override
  Future<Result<ReceiptReconciliation>> reconcile(
    Set<String> referencedStorageKeys,
  ) async {
    try {
      final root = await _root();
      var staging = 0, orphans = 0;
      final present = <String>{};
      await for (final entity in root.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (RegExp(r'^[0-9a-f-]{36}\.pending$').hasMatch(name)) {
          await entity.delete();
          staging++;
        } else if (_safeKey(name)) {
          if (referencedStorageKeys.contains(name)) {
            present.add(name);
          } else {
            await entity.delete();
            orphans++;
          }
        }
      }
      return Success(
        ReceiptReconciliation(
          removedStaging: staging,
          removedOrphans: orphans,
          missingReferences: referencedStorageKeys.difference(present),
        ),
      );
    } on FileSystemException {
      return const Failure(FailureCode.attachmentStorageUnavailable);
    }
  }
}
