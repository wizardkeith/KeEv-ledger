import '../../../core/result.dart';

abstract interface class AppLockSecureStore {
  Future<Result<String?>> read();
  Future<Result<void>> write(String value);
  Future<Result<void>> delete();
}

abstract interface class PinDeriver {
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  });

  List<int> randomSalt();
}

enum BiometricCapability { available, unavailable, notEnrolled }

enum BiometricAuthenticationResult {
  success,
  failed,
  cancelled,
  unavailable,
  notEnrolled,
  temporarilyLocked,
  permanentlyLocked,
  error,
}

abstract interface class BiometricAuthenticator {
  Future<BiometricCapability> capability();
  Future<BiometricAuthenticationResult> authenticate(String reason);
  Future<void> cancel();
}
