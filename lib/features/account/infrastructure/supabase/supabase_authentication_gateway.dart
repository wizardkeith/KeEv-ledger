import '../../../../core/result.dart';
import '../../application/authentication_contracts.dart';
import '../../domain/cloud_account.dart';
import 'supabase_auth_ports.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseAuthenticationGateway implements AuthenticationGateway {
  const SupabaseAuthenticationGateway({
    required SupabaseAuthApi api,
    required AppleCredentialProvider apple,
    required GoogleCredentialProvider google,
  }) : _api = api,
       _apple = apple,
       _google = google;

  final SupabaseAuthApi _api;
  final AppleCredentialProvider _apple;
  final GoogleCredentialProvider _google;

  @override
  bool get isConfigured => true;

  @override
  Future<Result<AuthenticationBundle>> signIn(
    AuthenticationProvider provider,
  ) async {
    if (provider == AuthenticationProvider.emailOtp) {
      return const Failure(FailureCode.authenticationProviderFailure);
    }
    final acquired = provider == AuthenticationProvider.apple
        ? await _apple.acquire()
        : await _google.acquire();
    return switch (acquired) {
      Success<ProviderCredential>(:final value) => _api.signInWithProvider(
        provider: provider,
        credential: value,
      ),
      Failure<ProviderCredential>(:final code) => Failure(code),
    };
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) =>
      _api.requestEmailOtp(email);

  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) => _api.verifyEmailOtp(email: email, otp: otp);

  @override
  Future<Result<AuthenticationBundle>> restoreSession(SessionSecrets secrets) =>
      _api.restore(secrets);

  @override
  Future<Result<AuthenticationBundle>> refreshSession(SessionSecrets secrets) =>
      _api.refresh(secrets);

  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) =>
      _api.currentAccount(secrets);

  @override
  Future<Result<void>> signOut(SessionSecrets secrets) async {
    final remote = await _api.signOut();
    await _google.signOut();
    return remote;
  }

  @override
  Future<Result<void>> revokeAccount(SessionSecrets secrets) async {
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession?.accessToken != secrets.accessToken) {
        return const Failure(FailureCode.unauthorized);
      }
      // Refresh linked identities; the active login method is not sufficient.
      final user = (await client.auth.getUser(secrets.accessToken)).user;
      if (user == null) return const Failure(FailureCode.unauthorized);
      final identities = user.identities;
      if (identities == null)
        return const Failure(FailureCode.backendUnavailable);
      final linkedApple = identities.any(
        (identity) => identity.provider == 'apple',
      );
      final Map<String, String> body;
      if (linkedApple) {
        final acquired = await _apple.acquire();
        if (acquired case Failure<ProviderCredential>(:final code)) {
          return Failure(code);
        }
        final credential = (acquired as Success<ProviderCredential>).value;
        if ((credential.authorizationCode?.isEmpty ?? true) ||
            (credential.rawNonce?.isEmpty ?? true)) {
          return const Failure(FailureCode.authenticationProviderFailure);
        }
        body = {
          'appleIdentityToken': credential.idToken,
          'appleAuthorizationCode': credential.authorizationCode!,
          'appleRawNonce': credential.rawNonce!,
        };
      } else {
        body = const <String, String>{};
      }
      final response = await client.functions.invoke(
        'delete-account',
        body: body,
        headers: {'Authorization': 'Bearer ${secrets.accessToken}'},
      );
      if (response.data is! Map) {
        return const Failure(FailureCode.backendUnavailable);
      }
      return switch ((response.data as Map)['status']) {
        'DELETED' => const Success(null),
        'REAUTH_REQUIRED' => const Failure(FailureCode.sessionExpired),
        'APPLE_REAUTH_REQUIRED' => const Failure(
          FailureCode.authenticationProviderFailure,
        ),
        'ACCOUNT_MISMATCH' => const Failure(FailureCode.unauthorized),
        'AUTH_REQUIRED' => const Failure(FailureCode.unauthorized),
        _ => const Failure(FailureCode.backendUnavailable),
      };
    } on Object {
      return const Failure(FailureCode.backendUnavailable);
    }
  }
}
