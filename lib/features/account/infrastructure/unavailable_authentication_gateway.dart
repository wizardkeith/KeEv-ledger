import '../../../core/result.dart';
import '../application/authentication_contracts.dart';
import '../domain/cloud_account.dart';

/// Phase 5A production placeholder: deliberately never reports fake success.
final class UnavailableAuthenticationGateway implements AuthenticationGateway {
  const UnavailableAuthenticationGateway();

  @override
  bool get isConfigured => false;

  @override
  Future<Result<AuthenticationBundle>> signIn(
    AuthenticationProvider provider,
  ) async => const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<void>> requestEmailOtp(String email) async =>
      const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async => const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<AuthenticationBundle>> restoreSession(
    SessionSecrets secrets,
  ) async => const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<AuthenticationBundle>> refreshSession(
    SessionSecrets secrets,
  ) async => const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) async =>
      const Failure(FailureCode.backendUnavailable);

  @override
  Future<Result<void>> signOut(SessionSecrets secrets) async =>
      const Success(null);

  @override
  Future<Result<void>> revokeAccount(SessionSecrets secrets) async =>
      const Failure(FailureCode.backendUnavailable);
}
