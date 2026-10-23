import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../domain/backup.dart';

const _magic = 'KEEVBK1\n';

final class BackupCryptoParameters {
  const BackupCryptoParameters({
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });
  final int memoryKiB, iterations, parallelism;
}

final class BackupSizeLimits {
  const BackupSizeLimits({
    this.containerBytes = maximumBackupContainerBytes,
    this.maximumHeaderBytes = maximumBackupHeaderBytes,
  });
  final int containerBytes, maximumHeaderBytes;
  int get plaintextBytes =>
      containerBytes - maximumHeaderBytes - backupContainerFixedOverheadBytes;
}

final class BackupCrypto {
  BackupCrypto({
    this.parameters = const BackupCryptoParameters(),
    this.limits = const BackupSizeLimits(),
    Random? random,
  }) : _random = random ?? Random.secure();

  final BackupCryptoParameters parameters;
  final BackupSizeLimits limits;
  final Random _random;

  Future<Uint8List> encrypt(List<int> plaintext, String passphrase) async {
    _validatePassphrase(passphrase);
    if (plaintext.length > limits.plaintextBytes) {
      throw const FormatException('Backup exceeds v1 size limit');
    }
    final salt = _randomBytes(16), nonce = _randomBytes(12);
    final header = <String, Object>{
      'formatVersion': keevBackupFormatVersion,
      'encryption': 'AES-256-GCM',
      'kdf': 'Argon2id',
      'argon2Version': 19,
      'memoryKiB': parameters.memoryKiB,
      'iterations': parameters.iterations,
      'parallelism': parameters.parallelism,
      'salt': base64Url.encode(salt),
      'nonce': base64Url.encode(nonce),
      'plaintextLength': plaintext.length,
    };
    final headerBytes = utf8.encode(jsonEncode(header));
    if (headerBytes.length > limits.maximumHeaderBytes) {
      throw const FormatException('Backup header exceeds v1 limit');
    }
    final aad = [
      ...utf8.encode(_magic),
      ..._u32(headerBytes.length),
      ...headerBytes,
    ];
    final key = await _derive(passphrase, salt, parameters);
    final box = await AesGcm.with256bits().encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
      aad: aad,
    );
    final result = Uint8List.fromList([
      ...aad,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
    if (result.length > limits.containerBytes) {
      throw const FormatException('Encrypted backup exceeds v1 limit');
    }
    return result;
  }

  Future<Uint8List> decrypt(List<int> container, String passphrase) async {
    _validatePassphrase(passphrase);
    if (container.length > limits.containerBytes || container.length < 29) {
      throw const FormatException('Invalid backup');
    }
    final bytes = Uint8List.fromList(container);
    final magic = utf8.decode(bytes.sublist(0, 8));
    if (magic != _magic) throw const FormatException('Invalid backup');
    final headerLength = ByteData.sublistView(bytes, 8, 12).getUint32(0);
    if (headerLength <= 0 ||
        headerLength > limits.maximumHeaderBytes ||
        12 + headerLength + 16 > bytes.length) {
      throw const FormatException('Invalid header');
    }
    final headerEnd = 12 + headerLength;
    final headerBytes = bytes.sublist(12, headerEnd);
    final header = jsonDecode(utf8.decode(headerBytes));
    if (header is! Map<String, dynamic> ||
        header['formatVersion'] != 1 ||
        header['encryption'] != 'AES-256-GCM' ||
        header['kdf'] != 'Argon2id') {
      throw const FormatException('Unsupported backup');
    }
    final p = BackupCryptoParameters(
      memoryKiB: header['memoryKiB'] as int,
      iterations: header['iterations'] as int,
      parallelism: header['parallelism'] as int,
    );
    if (p.memoryKiB < 1024 ||
        p.memoryKiB > 65536 ||
        p.iterations < 1 ||
        p.iterations > 8 ||
        p.parallelism != 1) {
      throw const FormatException('Unsafe KDF parameters');
    }
    final salt = base64Url.decode(header['salt'] as String);
    final nonce = base64Url.decode(header['nonce'] as String);
    if (salt.length != 16 || nonce.length != 12) throw const FormatException();
    final cipherEnd = bytes.length - 16;
    final box = SecretBox(
      bytes.sublist(headerEnd, cipherEnd),
      nonce: nonce,
      mac: Mac(bytes.sublist(cipherEnd)),
    );
    final key = await _derive(passphrase, salt, p);
    final clear = await AesGcm.with256bits().decrypt(
      box,
      secretKey: key,
      aad: bytes.sublist(0, headerEnd),
    );
    if (clear.length != header['plaintextLength'])
      throw const FormatException();
    return Uint8List.fromList(clear);
  }

  Future<SecretKey> _derive(
    String passphrase,
    List<int> salt,
    BackupCryptoParameters p,
  ) => Argon2id(
    parallelism: p.parallelism,
    memory: p.memoryKiB,
    iterations: p.iterations,
    hashLength: 32,
  ).deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  List<int> _randomBytes(int length) =>
      List.generate(length, (_) => _random.nextInt(256));
  List<int> _u32(int value) =>
      (ByteData(4)..setUint32(0, value)).buffer.asUint8List();
  void _validatePassphrase(String value) {
    if (value.runes.length < 10 || value.runes.length > 256) {
      throw const FormatException('Invalid passphrase');
    }
  }
}
