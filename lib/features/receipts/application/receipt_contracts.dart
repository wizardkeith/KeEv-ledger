import 'dart:io';

import '../../../core/result.dart';

enum ReceiptAcquisitionSource { camera, photoLibrary }

final class AcquiredReceipt {
  const AcquiredReceipt(this.path);
  final String path;
}

abstract interface class ReceiptImageAcquirer {
  /// A successful null value means that the user cancelled the native picker.
  Future<Result<AcquiredReceipt?>> acquire(ReceiptAcquisitionSource source);
  Future<Result<AcquiredReceipt?>> recoverInterrupted();
}

final class StoredReceiptFile {
  const StoredReceiptFile({
    required this.storageKey,
    required this.byteSize,
    required this.sha256Hex,
  });
  final String storageKey, sha256Hex;
  final int byteSize;
}

abstract interface class ReceiptFileStore {
  Future<Result<StoredReceiptFile>> importImage(
    File source,
    String attachmentId,
  );
  Future<Result<File>> resolve(String storageKey);
  Future<Result<void>> remove(String storageKey);
  Future<Result<ReceiptReconciliation>> reconcile(
    Set<String> referencedStorageKeys,
  );
}

final class ReceiptReconciliation {
  const ReceiptReconciliation({
    required this.removedStaging,
    required this.removedOrphans,
    required this.missingReferences,
  });
  final int removedStaging, removedOrphans;
  final Set<String> missingReferences;
}
