import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/sync/application/sync_contracts.dart';
import 'package:ledger/features/sync/domain/sync_protocol.dart';
import 'package:ledger/features/sync/infrastructure/local_sync_receipt_pull_files.dart';

Future<void> main() async {
  final root = await Directory.systemTemp.createTemp('keev-fix-smoke-');
  try {
    const bytes = <int>[1, 2, 3];
    const entityId = '99999999-9999-4999-8999-999999999999';
    final live = File('${root.path}/$entityId.jpg');
    await live.writeAsBytes(const [7, 7, 7]);
    final files = LocalSyncReceiptPullFiles(
      transport: const _Transport(bytes),
      directoryProvider: () async => root,
    );
    final prepared = await files.prepare(
      SyncChange(
        sequence: 1,
        entityType: SyncEntityType.receiptAttachment,
        entityId: entityId,
        serverVersion: 1,
        operation: SyncOperation.create,
        originDeviceId: '55555555-5555-4555-8555-555555555555',
        mutationId: '77777777-7777-4777-8777-777777777777',
        snapshot: {
          'storage_path': 'owner/receipts/$entityId/hash.jpg',
          'mime_type': 'image/jpeg',
          'byte_size': bytes.length,
          'sha256_hex': sha256.convert(bytes).toString(),
        },
      ),
    );
    assert(prepared is Success<PreparedSyncReceipt>);
    assert(_same(await live.readAsBytes(), const [7, 7, 7]));
    final value = (prepared as Success<PreparedSyncReceipt>).value;
    assert(await (value.stagingFile as File).exists());
    assert(await files.promote(value) is Failure<String>);
    assert(_same(await live.readAsBytes(), const [7, 7, 7]));
    await files.compensate(value);
    assert(!await (value.stagingFile as File).exists());

    const pending = PendingSyncMutation(
      queueSequence: 1,
      mutationId: '77777777-7777-4777-8777-777777777777',
      entityType: SyncEntityType.category,
      entityId: '33333333-3333-4333-8333-333333333333',
      operation: SyncOperation.update,
      baseServerVersion: null,
      payload: {'name': 'local'},
      attemptCount: 0,
    );
    assert(pending.withResolvedBase(4).baseServerVersion == 4);

    final sql = File(
      'supabase/migrations/202609230002_sync_runtime_v1_fix_gate.sql',
    ).readAsStringSync();
    assert(sql.contains("p_entity_type='receipt_attachment'"));
    assert(sql.contains("p_operation='update'"));
    stdout.writeln('Phase 6B Fix Gate smoke checks passed.');
  } finally {
    await root.delete(recursive: true);
  }
}

bool _same(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

final class _Transport implements SyncReceiptTransport {
  const _Transport(this.bytes);
  final List<int> bytes;

  @override
  Future<Result<List<int>>> download(String objectPath) async => Success(bytes);
  @override
  Future<Result<void>> uploadImmutable({
    required String objectPath,
    required List<int> bytes,
    required String sha256Hex,
  }) async => const Success(null);
  @override
  Future<Result<void>> delete(String objectPath) async => const Success(null);
}
