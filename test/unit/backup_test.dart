import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/backup/application/backup_contracts.dart';
import 'package:ledger/features/backup/application/backup_service.dart';
import 'package:ledger/features/backup/data/drift_ledger_backup_store.dart';
import 'package:ledger/features/backup/domain/backup.dart';
import 'package:ledger/features/backup/infrastructure/backup_archive_codec.dart';
import 'package:ledger/features/backup/infrastructure/backup_crypto.dart';
import 'package:ledger/features/backup/infrastructure/receipt_restore_file_system.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart';

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 21, 15, 30);
}

final class _Store implements LedgerBackupStore {
  _Store(this.snapshot);
  Map<String, dynamic> snapshot;
  bool failRestore = false;
  int replacements = 0;

  @override
  Future<Result<Map<String, dynamic>>> exportLogicalSnapshot() async =>
      Success(snapshot);

  @override
  Future<Result<void>> validateLogicalSnapshot(
    Map<String, dynamic> value,
  ) async => const Success(null);

  @override
  Future<Result<void>> replaceLogicalSnapshot(
    Map<String, dynamic> value,
  ) async {
    if (failRestore) return const Failure(FailureCode.restoreFailed);
    snapshot = value;
    replacements++;
    return const Success(null);
  }
}

enum _FileFailure { stage, safetyCopy, installCopy, rollbackCopy, cleanup }

final class _FaultingReceiptFiles implements ReceiptRestoreFileSystem {
  _FaultingReceiptFiles([this.failure]);
  final _FileFailure? failure;
  final ReceiptRestoreFileSystem delegate =
      const LocalReceiptRestoreFileSystem();

  @override
  Future<Directory> createDirectory(String path) =>
      delegate.createDirectory(path);

  @override
  Future<void> writeVerified(File file, List<int> bytes) {
    if (failure == _FileFailure.stage) {
      throw const FileSystemException('injected stage failure');
    }
    return delegate.writeVerified(file, bytes);
  }

  @override
  Future<void> copyVerifiedReceipts(Directory from, Directory to) {
    final safetyCopy = to.path.contains('keev-safety-');
    final rollbackCopy = from.path.contains('keev-safety-');
    final installCopy = from.path.contains('keev-restore-');
    if ((failure == _FileFailure.safetyCopy && safetyCopy) ||
        (failure == _FileFailure.rollbackCopy && rollbackCopy) ||
        (failure == _FileFailure.installCopy && installCopy)) {
      throw const FileSystemException('injected copy failure');
    }
    return delegate.copyVerifiedReceipts(from, to);
  }

  @override
  Future<void> verifyPrepared(
    Directory directory,
    Map<String, List<int>> expected,
  ) => delegate.verifyPrepared(directory, expected);

  @override
  Future<void> clearReceipts(Directory directory) =>
      delegate.clearReceipts(directory);

  @override
  Future<void> deleteTree(Directory directory) {
    if (failure == _FileFailure.cleanup) {
      throw const FileSystemException('injected cleanup failure');
    }
    return delegate.deleteTree(directory);
  }
}

List<int> _rawContainer(Map<String, Object> header, {int payload = 16}) {
  final headerBytes = utf8.encode(jsonEncode(header));
  final length = ByteData(4)..setUint32(0, headerBytes.length);
  return [
    ...utf8.encode('KEEVBK1\n'),
    ...length.buffer.asUint8List(),
    ...headerBytes,
    ...List<int>.filled(payload, 0),
  ];
}

BackupManifest _manifest({int attachments = 1}) => BackupManifest(
  createdAtUtc: DateTime.utc(2026),
  appVersion: '1',
  sourcePlatform: 'test',
  sourceSchemaVersion: 5,
  profileId: '11111111-1111-4111-8111-111111111111',
  baseCurrencyCode: 'HKD',
  entityCounts: const {
    'accounts': 1,
    'categories': 1,
    'projects': 1,
    'budgets': 1,
    'transactions': 1,
    'transfers': 1,
  },
  attachmentCount: attachments,
);

List<int> _zip(List<ArchiveFile> files) {
  final value = Archive();
  for (final file in files) value.addFile(file);
  return ZipEncoder().encodeBytes(value);
}

Map<String, dynamic> _logicalSnapshot(List<int> receiptBytes) {
  const profile = '11111111-1111-4111-8111-111111111111';
  const account = '22222222-2222-4222-8222-222222222222';
  const category = '33333333-3333-4333-8333-333333333333';
  const project = '44444444-4444-4444-8444-444444444444';
  const budget = '55555555-5555-4555-8555-555555555555';
  const transaction = '66666666-6666-4666-8666-666666666666';
  const receipt = '77777777-7777-4777-8777-777777777777';
  const key = '88888888-8888-4888-8888-888888888888.jpg';
  return {
    'logicalSchemaVersion': 1,
    'sourceDriftSchemaVersion': 5,
    'localProfiles': [
      {
        'slot': 1,
        'id': profile,
        'baseCurrencyCode': 'HKD',
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'accounts': [
      {
        'id': account,
        'profileId': profile,
        'name': 'Cash',
        'kind': 'cash',
        'currencyCode': 'HKD',
        'openingMinorUnits': 0,
        'openingDate': '2026-01-01',
        'isArchived': false,
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'categories': [
      {
        'id': category,
        'profileId': profile,
        'name': 'Food',
        'kind': 'expense',
        'isArchived': false,
        'sortOrder': 1,
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'projects': [
      {
        'id': project,
        'profileId': profile,
        'name': 'Trip',
        'description': null,
        'isArchived': false,
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'budgets': [
      {
        'id': budget,
        'profileId': profile,
        'name': 'Food budget',
        'amountMinorUnits': 10000,
        'currencyCode': 'HKD',
        'month': '2026-09',
        'categoryId': category,
        'warningThresholdPercent': 80,
        'isArchived': false,
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'transactions': [
      {
        'id': transaction,
        'profileId': profile,
        'accountId': account,
        'categoryId': category,
        'projectId': project,
        'kind': 'expense',
        'amountMinorUnits': 8500,
        'currencyCode': 'HKD',
        'businessDate': '2026-09-21',
        'note': null,
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
        'deletedAtUtc': null,
      },
    ],
    'transfers': <Object>[],
    'receiptAttachments': [
      {
        'id': receipt,
        'profileId': profile,
        'transactionId': transaction,
        'storageKey': key,
        'mimeType': 'image/jpeg',
        'byteSize': receiptBytes.length,
        'sha256Hex': sha256.convert(receiptBytes).toString(),
        'position': 0,
        'createdAtUtc': 1,
      },
    ],
  };
}

void main() {
  const password = 'Correct horse battery staple';
  const receiptKey = '12345678-1234-4123-8123-123456789abc.jpg';
  final receiptBytes = <int>[
    0xff,
    0xd8,
    0xff,
    ...utf8.encode('jpeg-test-content'),
    0xff,
    0xd9,
  ];
  late Directory root;
  late Directory receipts;
  late Directory temporary;

  Map<String, dynamic> snapshot() => {
    'logicalSchemaVersion': 1,
    'sourceDriftSchemaVersion': 5,
    'localProfiles': [
      {
        'slot': 1,
        'id': '11111111-1111-4111-8111-111111111111',
        'baseCurrencyCode': 'HKD',
        'createdAtUtc': 1,
        'updatedAtUtc': 2,
      },
    ],
    'accounts': [
      {
        'id': 'account',
        'openingMinorUnits': 9223372036854770000,
        'name': '現金 Cash',
      },
    ],
    'categories': [
      {'id': 'category', 'name': '餐飲'},
    ],
    'projects': [
      {'id': 'project', 'name': '東京旅行'},
    ],
    'budgets': [
      {'id': 'budget', 'amountMinorUnits': 12345},
    ],
    'transactions': [
      {'id': 'transaction', 'amountMinorUnits': 85, 'note': '午餐\nAlipay'},
    ],
    'transfers': [
      {
        'id': 'transfer',
        'sourceMinorUnits': 78000,
        'destinationMinorUnits': 10000,
      },
    ],
    'receiptAttachments': [
      {
        'id': 'receipt',
        'storageKey': receiptKey,
        'byteSize': receiptBytes.length,
        'sha256Hex': sha256.convert(receiptBytes).toString(),
      },
    ],
  };

  BackupCrypto crypto() => BackupCrypto(
    parameters: const BackupCryptoParameters(memoryKiB: 1024, iterations: 1),
  );

  setUp(() async {
    root = await Directory.systemTemp.createTemp('keev-backup-test-');
    receipts = await Directory('${root.path}/receipts').create();
    temporary = await Directory('${root.path}/temp').create();
    await File('${receipts.path}/$receiptKey').writeAsBytes(receiptBytes);
  });
  tearDown(() async => root.delete(recursive: true));

  test('AES-GCM + Argon2id round trip uses fresh salt/nonce', () async {
    final first = await crypto().encrypt(
      utf8.encode('private ledger'),
      password,
    );
    final second = await crypto().encrypt(
      utf8.encode('private ledger'),
      password,
    );
    expect(first, isNot(equals(second)));
    expect(
      utf8.decode(await crypto().decrypt(first, password)),
      'private ledger',
    );
    expect(base64.encode(first), isNot(contains(password)));
    final tampered = [...first]..[first.length - 20] ^= 1;
    await expectLater(crypto().decrypt(tampered, password), throwsA(anything));
    await expectLater(
      crypto().decrypt(first, 'Incorrect passphrase'),
      throwsA(anything),
    );
  });

  test('container limit reserves header and authentication overhead', () async {
    const limits = BackupSizeLimits(
      containerBytes: 2048,
      maximumHeaderBytes: 512,
    );
    final bounded = BackupCrypto(
      parameters: const BackupCryptoParameters(memoryKiB: 1024, iterations: 1),
      limits: limits,
    );
    final allowed = List<int>.filled(limits.plaintextBytes, 7);
    final container = await bounded.encrypt(allowed, password);
    expect(container.length, lessThanOrEqualTo(limits.containerBytes));
    expect(await bounded.decrypt(container, password), allowed);
    await expectLater(
      bounded.encrypt([...allowed, 8], password),
      throwsFormatException,
    );
    await expectLater(
      bounded.decrypt([...container, ...List<int>.filled(2048, 0)], password),
      throwsFormatException,
    );
  });

  test('container parser rejects hostile headers and truncation', () async {
    final valid = await crypto().encrypt(utf8.encode('ledger'), password);
    final badMagic = [...valid]..[0] ^= 1;
    await expectLater(
      crypto().decrypt(badMagic, password),
      throwsFormatException,
    );
    await expectLater(
      crypto().decrypt(valid.sublist(0, 20), password),
      throwsA(anything),
    );
    final unsupported = _rawContainer({
      'formatVersion': 2,
      'encryption': 'AES-256-GCM',
      'kdf': 'Argon2id',
    });
    await expectLater(
      crypto().decrypt(unsupported, password),
      throwsFormatException,
    );
    final unsafe = _rawContainer({
      'formatVersion': 1,
      'encryption': 'AES-256-GCM',
      'kdf': 'Argon2id',
      'memoryKiB': 999999,
      'iterations': 1,
      'parallelism': 1,
      'salt': base64Url.encode(List<int>.filled(16, 0)),
      'nonce': base64Url.encode(List<int>.filled(12, 0)),
      'plaintextLength': 0,
    });
    await expectLater(
      crypto().decrypt(unsafe, password),
      throwsFormatException,
    );

    final headerLength = ByteData.sublistView(
      Uint8List.fromList(valid),
      8,
      12,
    ).getUint32(0);
    final header = utf8.decode(valid.sublist(12, 12 + headerLength));
    final marker = '"plaintextLength":6';
    expect(header, contains(marker));
    final tamperedHeader = header.replaceFirst(marker, '"plaintextLength":5');
    final tampered = [
      ...valid.sublist(0, 12),
      ...utf8.encode(tamperedHeader),
      ...valid.sublist(12 + headerLength),
    ];
    await expectLater(crypto().decrypt(tampered, password), throwsA(anything));
  });

  test(
    'archive preserves exact integer, Unicode, entities, and receipt hash',
    () {
      final manifest = BackupManifest(
        createdAtUtc: DateTime.utc(2026, 9, 21),
        appVersion: '0.1.0+1',
        sourcePlatform: 'test',
        sourceSchemaVersion: 5,
        profileId: '11111111-1111-4111-8111-111111111111',
        baseCurrencyCode: 'HKD',
        entityCounts: const {
          'accounts': 1,
          'categories': 1,
          'projects': 1,
          'budgets': 1,
          'transactions': 1,
          'transfers': 1,
        },
        attachmentCount: 1,
      );
      final encoded = const BackupArchiveCodec().encode(
        manifest: manifest,
        ledgerData: snapshot(),
        receipts: {receiptKey: receiptBytes},
      );
      final decoded = const BackupArchiveCodec().decode(
        encoded,
        encryptedBytes: 123,
      );
      expect(
        ((decoded.ledgerData['accounts'] as List).single
            as Map<String, dynamic>)['openingMinorUnits'],
        9223372036854770000,
      );
      expect(
        ((decoded.ledgerData['transactions'] as List).single
            as Map<String, dynamic>)['note'],
        '午餐\nAlipay',
      );
      expect(decoded.receiptFiles[receiptKey], receiptBytes);
    },
  );

  test('archive rejects unsafe, duplicate, and unexpected entries', () {
    final manifest = ArchiveFile.string(
      'manifest.json',
      jsonEncode(_manifest().toJson()),
    );
    final ledger = ArchiveFile.string(
      'ledger-data.json',
      jsonEncode(snapshot()),
    );
    final invalidNames = [
      '../receipt.jpg',
      '/receipt.jpg',
      r'C:\receipt.jpg',
      r'receipts\receipt.jpg',
      'unexpected.txt',
    ];
    for (final name in invalidNames) {
      expect(
        () => const BackupArchiveCodec().decode(
          _zip([manifest, ledger, ArchiveFile.string(name, 'x')]),
          encryptedBytes: 1,
        ),
        throwsFormatException,
        reason: name,
      );
    }
    expect(
      () => const BackupArchiveCodec().decode(
        _zip([manifest, manifest, ledger]),
        encryptedBytes: 1,
      ),
      throwsFormatException,
    );
    expect(
      () => const BackupArchiveCodec().decode(
        _zip(List.generate(1025, (i) => ArchiveFile.string('x$i', 'x'))),
        encryptedBytes: 1,
      ),
      throwsFormatException,
    );
  });

  test('archive requires manifest, ledger and exact receipt set', () {
    final manifest = ArchiveFile.string(
      'manifest.json',
      jsonEncode(_manifest().toJson()),
    );
    final ledger = ArchiveFile.string(
      'ledger-data.json',
      jsonEncode(snapshot()),
    );
    final receipt = ArchiveFile.bytes('receipts/$receiptKey', receiptBytes);
    for (final files in <List<ArchiveFile>>[
      [ledger, receipt],
      [manifest, receipt],
      [manifest, ledger],
    ]) {
      expect(
        () => const BackupArchiveCodec().decode(_zip(files), encryptedBytes: 1),
        throwsFormatException,
      );
    }
    final noReceiptData = snapshot()..['receiptAttachments'] = <Object>[];
    final noReceiptManifest = ArchiveFile.string(
      'manifest.json',
      jsonEncode(_manifest(attachments: 0).toJson()),
    );
    expect(
      () => const BackupArchiveCodec().decode(
        _zip([
          noReceiptManifest,
          ArchiveFile.string('ledger-data.json', jsonEncode(noReceiptData)),
          receipt,
        ]),
        encryptedBytes: 1,
      ),
      throwsFormatException,
    );
    final corrupt = [...receiptBytes]..[3] ^= 1;
    expect(
      () => const BackupArchiveCodec().decode(
        _zip([
          manifest,
          ledger,
          ArchiveFile.bytes('receipts/$receiptKey', corrupt),
        ]),
        encryptedBytes: 1,
      ),
      throwsFormatException,
    );
  });

  test(
    'Local Only creates, previews, and fully replaces without network',
    () async {
      final store = _Store(snapshot());
      final service = BackupService(
        store: store,
        receiptDirectoryProvider: () async => receipts,
        temporaryDirectoryProvider: () async => temporary,
        crypto: crypto(),
        clock: _Clock(),
      );
      final created = await service.createLocalBackup(password);
      expect(created, isA<Success<LocalBackupFile>>());
      final file = (created as Success<LocalBackupFile>).value.file;
      store.snapshot = {...snapshot(), 'accounts': <Object>[]};
      final prepared = await service.prepareRestore(file, password);
      expect(prepared, isA<Success<PreparedRestore>>());
      expect(
        (prepared as Success<PreparedRestore>)
            .value
            .preview
            .manifest
            .attachmentCount,
        1,
      );
      expect(await service.restore(prepared.value), isA<Success<void>>());
      expect(store.replacements, 1);
      expect((store.snapshot['accounts'] as List), hasLength(1));
    },
  );

  test(
    'wrong password and failed replacement leave live state/files intact',
    () async {
      final store = _Store(snapshot());
      final service = BackupService(
        store: store,
        receiptDirectoryProvider: () async => receipts,
        temporaryDirectoryProvider: () async => temporary,
        crypto: crypto(),
        clock: _Clock(),
      );
      final file = (await service.createLocalBackup(
        password,
      ) as Success<LocalBackupFile>).value.file;
      final wrong = await service.prepareRestore(
        file,
        'Definitely wrong password',
      );
      expect(wrong, isA<Failure<PreparedRestore>>());
      expect(store.replacements, 0);
      final prepared = (await service.prepareRestore(
        file,
        password,
      ) as Success<PreparedRestore>).value;
      store.failRestore = true;
      expect(await service.restore(prepared), isA<Failure<void>>());
      expect(
        await File('${receipts.path}/$receiptKey').readAsBytes(),
        receiptBytes,
      );
    },
  );

  test('restore failure stages preserve or recover live receipts', () async {
    final replacementBytes = <int>[0xff, 0xd8, 0xff, 1, 2, 3, 0xff, 0xd9];
    final prepared = PreparedRestore(
      preview: RestorePreview(manifest: _manifest(), encryptedBytes: 100),
      ledgerData: snapshot(),
      receiptFiles: {receiptKey: replacementBytes},
    );
    for (final failure in [_FileFailure.stage, _FileFailure.safetyCopy]) {
      final store = _Store(snapshot());
      final service = BackupService(
        store: store,
        receiptDirectoryProvider: () async => receipts,
        temporaryDirectoryProvider: () async => temporary,
        restoreFiles: _FaultingReceiptFiles(failure),
        clock: _Clock(),
      );
      expect(await service.restore(prepared), isA<Failure<void>>());
      expect(store.replacements, 0);
      expect(
        await File('${receipts.path}/$receiptKey').readAsBytes(),
        receiptBytes,
      );
    }

    final installStore = _Store(snapshot());
    final installService = BackupService(
      store: installStore,
      receiptDirectoryProvider: () async => receipts,
      temporaryDirectoryProvider: () async => temporary,
      restoreFiles: _FaultingReceiptFiles(_FileFailure.installCopy),
      clock: _Clock(),
    );
    expect(await installService.restore(prepared), isA<Failure<void>>());
    expect(installStore.replacements, 0);
    expect(
      await File('${receipts.path}/$receiptKey').readAsBytes(),
      receiptBytes,
    );
  });

  test('database failure rolls receipts back and rollback failure preserves safety copy', () async {
    final replacementBytes = <int>[0xff, 0xd8, 0xff, 9, 8, 7, 0xff, 0xd9];
    final prepared = PreparedRestore(
      preview: RestorePreview(manifest: _manifest(), encryptedBytes: 100),
      ledgerData: snapshot(),
      receiptFiles: {receiptKey: replacementBytes},
    );
    final store = _Store(snapshot())..failRestore = true;
    final service = BackupService(
      store: store,
      receiptDirectoryProvider: () async => receipts,
      temporaryDirectoryProvider: () async => temporary,
      restoreFiles: _FaultingReceiptFiles(),
      clock: _Clock(),
    );
    expect(await service.restore(prepared), isA<Failure<void>>());
    expect(
      await File('${receipts.path}/$receiptKey').readAsBytes(),
      receiptBytes,
    );

    final failedRollback = BackupService(
      store: _Store(snapshot())..failRestore = true,
      receiptDirectoryProvider: () async => receipts,
      temporaryDirectoryProvider: () async => temporary,
      restoreFiles: _FaultingReceiptFiles(_FileFailure.rollbackCopy),
      clock: _Clock(),
    );
    expect(await failedRollback.restore(prepared), isA<Failure<void>>());
    final safety = await temporary
        .list()
        .where((entry) => entry.path.contains('keev-safety-'))
        .toList();
    expect(safety, isNotEmpty);
  });

  test('cleanup failure does not invalidate successful restore', () async {
    final replacementBytes = <int>[0xff, 0xd8, 0xff, 4, 5, 6, 0xff, 0xd9];
    final store = _Store(snapshot());
    final service = BackupService(
      store: store,
      receiptDirectoryProvider: () async => receipts,
      temporaryDirectoryProvider: () async => temporary,
      restoreFiles: _FaultingReceiptFiles(_FileFailure.cleanup),
      clock: _Clock(),
    );
    final result = await service.restore(
      PreparedRestore(
        preview: RestorePreview(manifest: _manifest(), encryptedBytes: 100),
        ledgerData: snapshot(),
        receiptFiles: {receiptKey: replacementBytes},
      ),
    );
    expect(result, isA<Success<void>>());
    expect(store.replacements, 1);
    expect(
      await File('${receipts.path}/$receiptKey').readAsBytes(),
      replacementBytes,
    );
  });

  test('unsafe and corrupt archives are rejected before restore', () {
    final manifest = _manifest();
    final data = snapshot();
    data['receiptAttachments'] = [
      {
        ...(data['receiptAttachments'] as List).single as Map<String, dynamic>,
        'sha256Hex': List.filled(64, '0').join(),
      },
    ];
    final encoded = const BackupArchiveCodec().encode(
      manifest: manifest,
      ledgerData: data,
      receipts: {receiptKey: receiptBytes},
    );
    expect(
      () => const BackupArchiveCodec().decode(
        encoded,
        encryptedBytes: encoded.length,
      ),
      throwsFormatException,
    );
  });

  test('Drift logical replacement preserves exact persisted rows', () async {
    final db = LedgerDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const profileId = '11111111-1111-4111-8111-111111111111';
    const accountId = '22222222-2222-4222-8222-222222222222';
    await db
        .into(db.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            slot: const Value(1),
            id: profileId,
            baseCurrencyCode: 'HKD',
            createdAtUtc: 1,
            updatedAtUtc: 2,
          ),
        );
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: accountId,
            profileId: profileId,
            name: '現金 Cash',
            kind: 'cash',
            currencyCode: 'HKD',
            openingMinorUnits: 9007199254740991,
            openingDate: '2026-01-01',
            createdAtUtc: 1,
            updatedAtUtc: 2,
            isArchived: const Value(false),
          ),
        );
    final store = DriftLedgerBackupStore(db);
    final exported = await store.exportLogicalSnapshot();
    expect(exported, isA<Success<Map<String, dynamic>>>());
    await db.delete(db.accounts).go();
    expect(
      await store.replaceLogicalSnapshot(
        (exported as Success<Map<String, dynamic>>).value,
      ),
      isA<Success<void>>(),
    );
    final restored = await db.select(db.accounts).getSingle();
    expect(restored.name, '現金 Cash');
    expect(restored.openingMinorUnits, 9007199254740991);
  });

  test(
    'logical validation rejects broken references and invalid values',
    () async {
      final db = LedgerDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftLedgerBackupStore(db);
      Map<String, dynamic> copy() =>
          jsonDecode(jsonEncode(_logicalSnapshot(receiptBytes)))
              as Map<String, dynamic>;

      final cases = <Map<String, dynamic> Function()>[
        () {
          final value = copy();
          ((value['transactions'] as List).single
                  as Map<String, dynamic>)['accountId'] =
              '99999999-9999-4999-8999-999999999999';
          return value;
        },
        () {
          final value = copy();
          ((value['transactions'] as List).single
                  as Map<String, dynamic>)['categoryId'] =
              '99999999-9999-4999-8999-999999999999';
          return value;
        },
        () {
          final value = copy();
          ((value['transactions'] as List).single
                  as Map<String, dynamic>)['projectId'] =
              '99999999-9999-4999-8999-999999999999';
          return value;
        },
        () {
          final value = copy();
          ((value['receiptAttachments'] as List).single
                  as Map<String, dynamic>)['transactionId'] =
              '99999999-9999-4999-8999-999999999999';
          return value;
        },
        () {
          final value = copy();
          ((value['accounts'] as List).single
                  as Map<String, dynamic>)['currencyCode'] =
              'ZZZ';
          return value;
        },
        () {
          final value = copy();
          ((value['transactions'] as List).single
                  as Map<String, dynamic>)['businessDate'] =
              '21/09/2026';
          return value;
        },
        () {
          final value = copy();
          value['logicalSchemaVersion'] = 99;
          return value;
        },
        () {
          final value = copy();
          (value['accounts'] as List).add(
            Map<String, dynamic>.from(
              (value['accounts'] as List).single as Map,
            ),
          );
          return value;
        },
        () {
          final value = copy();
          final duplicate = Map<String, dynamic>.from(
            (value['receiptAttachments'] as List).single as Map,
          )..['id'] = '99999999-9999-4999-8999-999999999999';
          (value['receiptAttachments'] as List).add(duplicate);
          return value;
        },
      ];
      for (final invalid in cases) {
        final result = await store.validateLogicalSnapshot(invalid());
        expect(result, isA<Failure<void>>());
        expect(
          (result as Failure<void>).code,
          FailureCode.restoreValidationFailed,
        );
      }
    },
  );

  test('Supabase artefact defines private own-user backup policies', () {
    final sql = File('supabase/migrations/202609210002_encrypted_backups.sql')
        .readAsStringSync();
    expect(sql, contains("'ledger-backups'"));
    expect(sql, contains('public.ledger_backups enable row level security'));
    expect(sql, contains('(select auth.uid()) = user_id'));
    expect(sql, contains('(storage.foldername(name))[1]'));
    expect(sql, contains('public, file_size_limit'));
    expect(sql, isNot(contains('service_role')));
    expect(sql, isNot(contains('for update')));
  });
}
