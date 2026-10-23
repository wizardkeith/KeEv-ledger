import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../application/sync_contracts.dart';

final class SupabaseSyncReceiptTransport implements SyncReceiptTransport {
  const SupabaseSyncReceiptTransport(this.client);
  final SupabaseClient client;
  static const bucket = 'ledger-sync-receipts';

  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async {
    if (sha256.convert(bytes).toString() != sha256Hex) {
      return const Failure(FailureCode.syncAttachmentIntegrityFailure);
    }
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(
            objectPath,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      return const Success(null);
    } on StorageException catch (error) {
      if (error.statusCode == '409') {
        final existing = await download(objectPath);
        if (existing is Success<List<int>> &&
            sha256.convert(existing.value).toString() == sha256Hex &&
            existing.value.length == bytes.length) {
          return const Success(null);
        }
        return const Failure(FailureCode.syncAttachmentIntegrityFailure);
      }
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<List<int>>> download(String objectPath) async {
    try {
      return Success(await client.storage.from(bucket).download(objectPath));
    } on StorageException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<void>> delete(String objectPath) async {
    try {
      await client.storage.from(bucket).remove([objectPath]);
      return const Success(null);
    } on StorageException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  static FailureCode _failure(StorageException error) =>
      switch (error.statusCode) {
        '401' || '403' => FailureCode.syncUnauthorized,
        '429' => FailureCode.syncRateLimited,
        '500' || '502' || '503' || '504' => FailureCode.syncBackendUnavailable,
        _ => FailureCode.syncAttachmentFailure,
      };
}
