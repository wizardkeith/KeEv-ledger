import '../../../core/result.dart';
import '../domain/cloud_account.dart';

/// Secrets live only in memory or through [SecureSessionStore].
final class SessionSecrets {
  const SessionSecrets({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;
}

final class AuthenticationBundle {
  const AuthenticationBundle({required this.session, required this.secrets});

  final AuthenticatedSession session;
  final SessionSecrets secrets;
}

abstract interface class AuthenticationGateway {
  bool get isConfigured;
  Future<Result<AuthenticationBundle>> signIn(AuthenticationProvider provider);
  Future<Result<void>> requestEmailOtp(String email);
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  });
  Future<Result<AuthenticationBundle>> restoreSession(SessionSecrets secrets);
  Future<Result<AuthenticationBundle>> refreshSession(SessionSecrets secrets);
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets);
  Future<Result<void>> signOut(SessionSecrets secrets);
  Future<Result<void>> revokeAccount(SessionSecrets secrets);
}

abstract interface class SecureSessionStore {
  Future<Result<AuthenticationBundle?>> read();
  Future<Result<void>> write(AuthenticationBundle bundle);
  Future<Result<void>> clear();
}
