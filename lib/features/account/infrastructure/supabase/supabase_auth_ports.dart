import '../../../../core/result.dart';
import '../../application/authentication_contracts.dart';
import '../../domain/cloud_account.dart';

final class ProviderCredential {
  const ProviderCredential({
    required this.idToken,
    this.accessToken,
    this.rawNonce,
    this.authorizationCode,
    this.displayName,
  });

  final String idToken;
  final String? accessToken;
  final String? rawNonce;
  /// Ephemeral, single-use Apple code; never stored with the KeEv session.
  final String? authorizationCode;
  final String? displayName;
}

abstract interface class AppleCredentialProvider {
  Future<Result<ProviderCredential>> acquire();
}

abstract interface class GoogleCredentialProvider {
  Future<Result<ProviderCredential>> acquire();
  Future<void> signOut();
}

abstract interface class SupabaseAuthApi {
  Future<Result<AuthenticationBundle>> signInWithProvider({
    required AuthenticationProvider provider,
    required ProviderCredential credential,
  });
  Future<Result<void>> requestEmailOtp(String email);
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  });
  Future<Result<AuthenticationBundle>> restore(SessionSecrets secrets);
  Future<Result<AuthenticationBundle>> refresh(SessionSecrets secrets);
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets);
  Future<Result<void>> signOut();
}
