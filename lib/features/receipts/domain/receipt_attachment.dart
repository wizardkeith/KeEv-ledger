import '../../../core/local_id.dart';
import '../../../core/result.dart';

const maximumReceiptsPerTransaction = 5;
const maximumProcessedReceiptBytes = 10 * 1024 * 1024;

final class ReceiptAttachment {
  ReceiptAttachment({
    required this.id,
    required this.profileId,
    required this.transactionId,
    required this.storageKey,
    required this.mimeType,
    required this.byteSize,
    required this.sha256Hex,
    required this.position,
    required this.createdAtUtc,
  }) {
    if (!RegExp(r'^[0-9a-f-]{36}\.jpg$').hasMatch(storageKey)) {
      throw ArgumentError.value(storageKey, 'storageKey', 'Unsafe storage key');
    }
    if (mimeType != 'image/jpeg') throw ArgumentError('Unsupported MIME type');
    if (byteSize <= 0 || byteSize > maximumProcessedReceiptBytes) {
      throw ArgumentError.value(byteSize, 'byteSize', 'Outside size limit');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256Hex)) {
      throw ArgumentError.value(sha256Hex, 'sha256Hex', 'Invalid SHA-256');
    }
    if (position < 0 || position >= maximumReceiptsPerTransaction) {
      throw ArgumentError.value(position, 'position');
    }
    if (!createdAtUtc.isUtc) throw ArgumentError('Timestamp must be UTC');
  }

  final LocalId id, profileId, transactionId;
  final String storageKey, mimeType, sha256Hex;
  final int byteSize, position;
  final DateTime createdAtUtc;
}

abstract interface class ReceiptAttachmentRepository {
  Future<Result<ReceiptAttachment>> create(ReceiptAttachment attachment);
  Future<Result<List<ReceiptAttachment>>> list(
    LocalId profileId,
    LocalId transactionId,
  );
  Future<Result<List<ReceiptAttachment>>> listAll(LocalId profileId);
  Future<Result<ReceiptAttachment>> remove(
    LocalId profileId,
    LocalId attachmentId,
  );
}
