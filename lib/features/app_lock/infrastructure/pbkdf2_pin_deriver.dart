import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../application/app_lock_contracts.dart';
import '../domain/app_lock.dart';

final class Pbkdf2PinDeriver implements PinDeriver {
  Pbkdf2PinDeriver({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final key = await Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: appLockDerivedBytes * 8,
    ).deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
    return key.extractBytes();
  }

  @override
  List<int> randomSalt() => List<int>.generate(
    appLockSaltBytes,
    (_) => _random.nextInt(256),
    growable: false,
  );
}
