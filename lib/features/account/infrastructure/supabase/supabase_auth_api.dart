import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/result.dart';
import '../../application/authentication_contracts.dart';
import '../../domain/cloud_account.dart';
import 'supabase_auth_ports.dart';

final class SupabaseClientAuthApi implements SupabaseAuthApi {
  const SupabaseClientAuthApi(this.client);

  final SupabaseClient client;

  @override
  Future<Result<AuthenticationBundle>> signInWithProvider({
    required AuthenticationProvider provider,
    required ProviderCredential credential,
  }) => _guardBundle(() async {
    final response = await client.auth.signInWithIdToken(
      provider: switch (provider) {
        AuthenticationProvider.apple => OAuthProvider.apple,
        AuthenticationProvider.google => OAuthProvider.google,
        AuthenticationProvider.emailOtp => throw StateError(
          'Email OTP does not use an identity token.',
        ),
      },
      idToken: credential.idToken,
      accessToken: credential.accessToken,
      nonce: credential.rawNonce,
    );
    return _bundle(
      response.session,
      fallbackDisplayName: credential.displayName,
    );
  });

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    try {
      await client.auth.signInWithOtp(email: email, shouldCreateUser: true);
      return const Success(null);
    } on Object catch (error) {
      return Failure(_mapFailure(error, otpOperation: true));
    }
  }

  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) => _guardBundle(() async {
    final response = await client.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.email,
    );
    return _bundle(response.session);
  }, otpOperation: true);

  @override
  Future<Result<AuthenticationBundle>> restore(SessionSecrets secrets) =>
      _guardBundle(() async {
        final refresh = secrets.refreshToken;
        if (refresh == null || refresh.isEmpty) {
          throw AuthSessionMissingException();
        }
        final response = await client.auth.setSession(
          refresh,
          accessToken: secrets.accessToken,
        );
        return _bundle(response.session);
      });

  @override
  Future<Result<AuthenticationBundle>> refresh(SessionSecrets secrets) =>
      _guardBundle(() async {
        final refresh = secrets.refreshToken;
        if (refresh == null || refresh.isEmpty) {
          throw AuthSessionMissingException();
        }
        final response = await client.auth.refreshSession(refresh);
        return _bundle(response.session);
      });

  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) async {
    try {
      final response = await client.auth.getUser(secrets.accessToken);
      final user = response.user;
      if (user == null) return const Failure(FailureCode.unauthorized);
      return Success(_account(user));
    } on Object catch (error) {
      return Failure(_mapFailure(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await client.auth.signOut(scope: SignOutScope.local);
      return const Success(null);
    } on Object catch (error) {
      return Failure(_mapFailure(error));
    }
  }

  Future<Result<AuthenticationBundle>> _guardBundle(
    Future<AuthenticationBundle> Function() operation, {
    bool otpOperation = false,
  }) async {
    try {
      return Success(await operation());
    } on Object catch (error) {
      return Failure(_mapFailure(error, otpOperation: otpOperation));
    }
  }

  AuthenticationBundle _bundle(
    Session? session, {
    String? fallbackDisplayName,
  }) {
    if (session == null ||
        session.accessToken.isEmpty ||
        (session.refreshToken?.isEmpty ?? true)) {
      throw AuthSessionMissingException();
    }
    final expirySeconds = session.expiresAt;
    final expiry = expirySeconds == null
        ? DateTime.now().toUtc().add(
            Duration(seconds: session.expiresIn ?? 3600),
          )
        : DateTime.fromMillisecondsSinceEpoch(
            expirySeconds * 1000,
            isUtc: true,
          );
    return AuthenticationBundle(
      session: AuthenticatedSession(
        account: _account(
          session.user,
          fallbackDisplayName: fallbackDisplayName,
        ),
        expiresAtUtc: expiry,
        canRefresh: true,
      ),
      secrets: SessionSecrets(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
  }

  CloudAccount _account(User user, {String? fallbackDisplayName}) {
    final identities = <ProviderIdentity>[];
    for (final identity in user.identities ?? const <UserIdentity>[]) {
      final provider = _provider(identity.provider);
      if (provider != null && identity.identityId.isNotEmpty) {
        identities.add(
          ProviderIdentity(provider: provider, subject: identity.identityId),
        );
      }
    }
    if (identities.isEmpty) {
      final provider = _provider(user.appMetadata['provider'] as String?);
      identities.add(
        ProviderIdentity(
          provider: provider ?? AuthenticationProvider.emailOtp,
          subject: user.id,
        ),
      );
    }
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName =
        _nonEmpty(metadata['display_name']) ??
        _nonEmpty(metadata['full_name']) ??
        _nonEmpty(fallbackDisplayName);
    final createdAt = DateTime.tryParse(user.createdAt)?.toUtc();
    return CloudAccount(
      id: user.id,
      identities: identities,
      email: _nonEmpty(user.email),
      displayName: displayName,
      createdAtUtc:
          createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  AuthenticationProvider? _provider(String? value) => switch (value) {
    'apple' => AuthenticationProvider.apple,
    'google' => AuthenticationProvider.google,
    'email' || 'email_otp' => AuthenticationProvider.emailOtp,
    _ => null,
  };

  String? _nonEmpty(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  FailureCode _mapFailure(Object error, {bool otpOperation = false}) {
    if (error is AuthRetryableFetchException) {
      return FailureCode.networkUnavailable;
    }
    if (error is AuthSessionMissingException ||
        error is AuthInvalidJwtException) {
      return FailureCode.sessionExpired;
    }
    if (error is AuthException) {
      final status = int.tryParse(error.statusCode ?? '');
      final code = error.code ?? '';
      if (status == 429 || code.contains('rate_limit')) {
        return FailureCode.rateLimited;
      }
      if (otpOperation && code.contains('expired')) {
        return FailureCode.expiredOtp;
      }
      if (otpOperation && (code.contains('invalid') || code.contains('otp'))) {
        return FailureCode.invalidOtp;
      }
      if (status == 401 || status == 403 || code.contains('unauthorized')) {
        return FailureCode.unauthorized;
      }
      if (code.contains('refresh_token') || code.contains('session')) {
        return FailureCode.sessionExpired;
      }
      if (status != null && status >= 500) {
        return FailureCode.backendUnavailable;
      }
      return FailureCode.authenticationProviderFailure;
    }
    return FailureCode.unknownAuthenticationFailure;
  }
}
