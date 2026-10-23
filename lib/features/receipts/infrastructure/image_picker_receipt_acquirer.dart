import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/result.dart';
import '../application/receipt_contracts.dart';

final class ImagePickerReceiptAcquirer implements ReceiptImageAcquirer {
  ImagePickerReceiptAcquirer([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  @override
  Future<Result<AcquiredReceipt?>> acquire(
    ReceiptAcquisitionSource source,
  ) async {
    try {
      final picked = await _picker.pickImage(
        source: source == ReceiptAcquisitionSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        requestFullMetadata: false,
      );
      return Success(picked == null ? null : AcquiredReceipt(picked.path));
    } on PlatformException catch (error) {
      if (error.code.contains('denied') || error.code.contains('restricted')) {
        return const Failure(FailureCode.attachmentPermissionDenied);
      }
      return const Failure(FailureCode.attachmentStorageUnavailable);
    }
  }

  @override
  Future<Result<AcquiredReceipt?>> recoverInterrupted() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return const Success(null);
      final file = response.files?.firstOrNull;
      return file == null
          ? const Failure(FailureCode.attachmentStorageUnavailable)
          : Success(AcquiredReceipt(file.path));
    } on PlatformException {
      return const Failure(FailureCode.attachmentStorageUnavailable);
    }
  }
}
