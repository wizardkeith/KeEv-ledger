import 'package:local_auth/local_auth.dart';

import '../application/app_lock_contracts.dart';

final class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<BiometricCapability> capability() async {
    try {
      if (!await _authentication.canCheckBiometrics) {
        return BiometricCapability.unavailable;
      }
      return (await _authentication.getAvailableBiometrics()).isEmpty
          ? BiometricCapability.notEnrolled
          : BiometricCapability.available;
    } on Object {
      return BiometricCapability.unavailable;
    }
  }

  @override
  Future<BiometricAuthenticationResult> authenticate(String reason) async {
    try {
      final result = await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );
      return result
          ? BiometricAuthenticationResult.success
          : BiometricAuthenticationResult.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.userRequestedFallback ||
        LocalAuthExceptionCode.timeout =>
          BiometricAuthenticationResult.cancelled,
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          BiometricAuthenticationResult.notEnrolled,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
        LocalAuthExceptionCode.uiUnavailable =>
          BiometricAuthenticationResult.unavailable,
        LocalAuthExceptionCode.temporaryLockout =>
          BiometricAuthenticationResult.temporarilyLocked,
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthenticationResult.permanentlyLocked,
        _ => BiometricAuthenticationResult.error,
      };
    } on Object {
      return BiometricAuthenticationResult.error;
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _authentication.stopAuthentication();
    } on Object {
      // Cancellation is best-effort; generation guards reject stale results.
    }
  }
}
