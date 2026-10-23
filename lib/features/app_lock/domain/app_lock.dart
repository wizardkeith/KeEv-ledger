import 'dart:convert';

const appLockRecordVersion = 1;
const appLockKdfName = 'pbkdf2-hmac-sha256';
const appLockKdfIterations = 210000;
const appLockSaltBytes = 16;
const appLockDerivedBytes = 32;

final class AppLockRecord {
  AppLockRecord({
    required this.version,
    required this.kdf,
    required this.iterations,
    required this.salt,
    required this.verifier,
    required this.biometricsEnabled,
    required this.failedAttempts,
    this.throttleUntilUtc,
  }) {
    if (version != appLockRecordVersion ||
        kdf != appLockKdfName ||
        iterations < 100000 ||
        salt.length < appLockSaltBytes ||
        verifier.length != appLockDerivedBytes ||
        failedAttempts < 0 ||
        (throttleUntilUtc != null && !throttleUntilUtc!.isUtc)) {
      throw const FormatException('Invalid app lock record');
    }
  }

  final int version, iterations, failedAttempts;
  final String kdf;
  final List<int> salt, verifier;
  final bool biometricsEnabled;
  final DateTime? throttleUntilUtc;

  AppLockRecord copyWith({
    bool? biometricsEnabled,
    int? failedAttempts,
    DateTime? throttleUntilUtc,
    bool clearThrottle = false,
  }) => AppLockRecord(
    version: version,
    kdf: kdf,
    iterations: iterations,
    salt: salt,
    verifier: verifier,
    biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    throttleUntilUtc: clearThrottle
        ? null
        : throttleUntilUtc ?? this.throttleUntilUtc,
  );

  String encode() => jsonEncode({
    'version': version,
    'kdf': kdf,
    'iterations': iterations,
    'salt': base64UrlEncode(salt),
    'verifier': base64UrlEncode(verifier),
    'biometricsEnabled': biometricsEnabled,
    'failedAttempts': failedAttempts,
    'throttleUntilUtc': throttleUntilUtc?.toIso8601String(),
  });

  factory AppLockRecord.decode(String value) {
    final json = jsonDecode(value);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid app lock record');
    }
    try {
      final throttle = json['throttleUntilUtc'];
      return AppLockRecord(
        version: json['version'] as int,
        kdf: json['kdf'] as String,
        iterations: json['iterations'] as int,
        salt: base64Url.decode(json['salt'] as String),
        verifier: base64Url.decode(json['verifier'] as String),
        biometricsEnabled: json['biometricsEnabled'] as bool,
        failedAttempts: json['failedAttempts'] as int,
        throttleUntilUtc: throttle == null
            ? null
            : DateTime.parse(throttle as String).toUtc(),
      );
    } on Object {
      throw const FormatException('Invalid app lock record');
    }
  }
}
