import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../domain/backup.dart';

final class BackupArchiveCodec {
  const BackupArchiveCodec();

  List<int> encode({
    required BackupManifest manifest,
    required Map<String, dynamic> ledgerData,
    required Map<String, List<int>> receipts,
  }) {
    final archive = Archive();
    archive.addFile(
      ArchiveFile.string('manifest.json', jsonEncode(manifest.toJson())),
    );
    archive.addFile(
      ArchiveFile.string('ledger-data.json', jsonEncode(ledgerData)),
    );
    for (final key in receipts.keys.toList()..sort()) {
      archive.addFile(ArchiveFile.bytes('receipts/$key', receipts[key]!));
    }
    final encoded = ZipEncoder().encodeBytes(
      archive,
      modified: manifest.createdAtUtc,
    );
    if (encoded.length > maximumBackupPlaintextBytes)
      throw const FormatException('Backup too large');
    return encoded;
  }

  PreparedRestore decode(List<int> bytes, {required int encryptedBytes}) {
    if (bytes.length > maximumBackupPlaintextBytes)
      throw const FormatException();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    if (archive.length > maximumBackupEntries) throw const FormatException();
    final entries = <String, ArchiveFile>{};
    var expanded = 0;
    for (final entry in archive) {
      final name = entry.name;
      if (!entry.isFile ||
          entry.isSymbolicLink ||
          !_safePath(name) ||
          entries.containsKey(name)) {
        throw const FormatException('Unsafe archive');
      }
      if (name != 'manifest.json' &&
          name != 'ledger-data.json' &&
          !RegExp(r'^receipts/[0-9a-f-]{36}\.jpg$').hasMatch(name)) {
        throw const FormatException('Unexpected entry');
      }
      expanded += entry.size;
      if (expanded > maximumBackupPlaintextBytes)
        throw const FormatException('Archive too large');
      entries[name] = entry;
    }
    final manifestEntry = entries['manifest.json'];
    final ledgerEntry = entries['ledger-data.json'];
    if (manifestEntry == null || ledgerEntry == null)
      throw const FormatException();
    final manifestJson = jsonDecode(utf8.decode(manifestEntry.content));
    final ledgerJson = jsonDecode(utf8.decode(ledgerEntry.content));
    if (manifestJson is! Map<String, dynamic> ||
        ledgerJson is! Map<String, dynamic>)
      throw const FormatException();
    final manifest = BackupManifest.fromJson(manifestJson);
    for (final key in [
      'accounts',
      'categories',
      'projects',
      'budgets',
      'transactions',
      'transfers',
    ]) {
      final rows = ledgerJson[key];
      if (rows is! List || rows.length != manifest.entityCounts[key]) {
        throw const FormatException('Manifest mismatch');
      }
    }
    final receiptRows = ledgerJson['receiptAttachments'];
    if (receiptRows is! List || receiptRows.length != manifest.attachmentCount)
      throw const FormatException();
    final receipts = <String, List<int>>{};
    for (final row in receiptRows) {
      if (row is! Map<String, dynamic>) throw const FormatException();
      final key = row['storageKey'] as String?;
      final expectedHash = row['sha256Hex'] as String?;
      final expectedSize = row['byteSize'] as int?;
      if (key == null ||
          expectedHash == null ||
          expectedSize == null ||
          receipts.containsKey(key))
        throw const FormatException();
      final entry = entries['receipts/$key'];
      if (entry == null) throw const FormatException('Missing receipt');
      final content = entry.content;
      if (content.length != expectedSize ||
          sha256.convert(content).toString() != expectedHash ||
          !_jpeg(content))
        throw const FormatException('Receipt mismatch');
      receipts[key] = content;
    }
    if (entries.keys.where((e) => e.startsWith('receipts/')).length !=
        receipts.length)
      throw const FormatException();
    return PreparedRestore(
      preview: RestorePreview(
        manifest: manifest,
        encryptedBytes: encryptedBytes,
      ),
      ledgerData: ledgerJson,
      receiptFiles: receipts,
    );
  }

  bool _safePath(String name) =>
      name.isNotEmpty &&
      !name.startsWith('/') &&
      !name.startsWith('\\') &&
      !RegExp(r'^[A-Za-z]:').hasMatch(name) &&
      !name.split('/').contains('..') &&
      !name.contains('\\');

  bool _jpeg(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;
}
