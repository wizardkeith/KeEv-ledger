import 'dart:io';

import '../../../core/result.dart';

abstract interface class SyncReceiptSpool {
  Future<Result<bool>> prepare({
    required String attachmentId,
    required File processedFile,
    required String sha256Hex,
    required int byteSize,
  });
  Future<Result<File>> resolve(String attachmentId);
  Future<Result<void>> remove(String attachmentId);
  Future<Result<void>> removeIfUnreferenced(String attachmentId);
  Future<Result<void>> clearAll();
}
