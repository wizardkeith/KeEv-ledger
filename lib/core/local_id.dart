import 'dart:math';

/// UUID v4 independent of row order and online identity.
final class LocalId {
  LocalId(this.value) {
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    ).hasMatch(value)) {
      throw FormatException('Expected a canonical lowercase UUID v4', value);
    }
  }

  final String value;

  @override
  bool operator ==(Object other) => other is LocalId && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

abstract interface class IdGenerator {
  LocalId generate();
}

final class SecureUuidV4Generator implements IdGenerator {
  SecureUuidV4Generator() : _random = Random.secure();

  final Random _random;

  @override
  LocalId generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return LocalId(
      '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20, 32)}',
    );
  }
}
