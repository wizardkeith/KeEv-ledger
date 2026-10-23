// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ledger/app/environment.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/account/application/account_controller.dart';
import 'package:ledger/features/account/application/authentication_contracts.dart';
import 'package:ledger/features/account/domain/cloud_account.dart';
import 'package:ledger/features/account/infrastructure/supabase/native_identity_providers.dart';
import 'package:ledger/features/account/infrastructure/supabase/supabase_auth_ports.dart';
import 'package:ledger/features/account/infrastructure/supabase/supabase_authentication_gateway.dart';

void main() {
  test('configuration is optional, typed and HTTPS-only', () {
    expect(
      SupabaseConfiguration.fromValues(url: '', publishableKey: ''),
      isNull,
    );
    expect(
      SupabaseConfiguration.fromValues(
        url: 'http://example.invalid',
        publishableKey: 'publishable',
      ),
      isNull,
    );
    final valid = SupabaseConfiguration.fromValues(
      url: 'https://example.supabase.co',
      publishableKey: 'publishable',
    );
    expect(valid?.url.host, 'example.supabase.co');
  });

  test(
    'Apple and Google credentials map behind provider-neutral gateway',
    () async {
      for (final provider in [
        AuthenticationProvider.apple,
        AuthenticationProvider.google,
      ]) {
        final api = _AuthApi();
        final credential = ProviderCredential(
          idToken: provider.name,
          accessToken: provider == AuthenticationProvider.google
              ? 'google-access'
              : null,
        );
        final gateway = SupabaseAuthenticationGateway(
          api: api,
          apple: _Apple(const Success(ProviderCredential(idToken: 'apple'))),
          google: _Google(Success(credential)),
        );
        final result = await gateway.signIn(provider);
        expect(result, isA<Success<AuthenticationBundle>>());
        expect(api.provider, provider);
        expect(api.credential?.idToken, provider.name);
        if (provider == AuthenticationProvider.google) {
          expect(api.credential?.accessToken, 'google-access');
        }
      }
    },
  );

  test(
    'native Google acquisition returns ID and OAuth access tokens',
    () async {
      final client = _GoogleClient(
        authentication: const GoogleAuthenticationResult(
          idToken: 'google-id-token',
          displayName: 'Owner',
        ),
        silentAccessToken: 'google-access-token',
      );
      final provider = NativeGoogleCredentialProvider(
        _supabaseConfiguration(),
        client: client,
      );

      final result = await provider.acquire() as Success<ProviderCredential>;
      expect(result.value.idToken, 'google-id-token');
      expect(result.value.accessToken, 'google-access-token');
      expect(client.requestedScopes, const ['openid', 'email']);
      expect(client.interactiveAuthorizationCalls, 0);
    },
  );

  test(
    'Google authorization fallback obtains access token interactively',
    () async {
      final client = _GoogleClient(
        authentication: const GoogleAuthenticationResult(idToken: 'id-token'),
        interactiveAccessToken: 'interactive-access-token',
      );
      final result = await NativeGoogleCredentialProvider(
        _supabaseConfiguration(),
        client: client,
      ).acquire();

      expect(
        (result as Success<ProviderCredential>).value.accessToken,
        'interactive-access-token',
      );
      expect(client.interactiveAuthorizationCalls, 1);
    },
  );

  test('Google cancellation remains cancellation', () async {
    final client = _GoogleClient(
      authentication: const GoogleAuthenticationResult(idToken: 'id-token'),
      authorizationError: const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      ),
    );
    final result = await NativeGoogleCredentialProvider(
      _supabaseConfiguration(),
      client: client,
    ).acquire();

    expect(
      (result as Failure<ProviderCredential>).code,
      FailureCode.cloudAuthenticationCancelled,
    );
  });

  test('missing Google access token cannot authenticate', () async {
    final client = _GoogleClient(
      authentication: const GoogleAuthenticationResult(idToken: 'id-token'),
      interactiveAccessToken: '',
    );
    final result = await NativeGoogleCredentialProvider(
      _supabaseConfiguration(),
      client: client,
    ).acquire();

    expect(
      (result as Failure<ProviderCredential>).code,
      FailureCode.authenticationProviderFailure,
    );
  });

  test('provider cancellation and failure never call Supabase API', () async {
    for (final result in const <Result<ProviderCredential>>[
      Failure(FailureCode.cloudAuthenticationCancelled),
      Failure(FailureCode.authenticationProviderFailure),
    ]) {
      final api = _AuthApi();
      final gateway = SupabaseAuthenticationGateway(
        api: api,
        apple: _Apple(result),
        google: _Google(result),
      );
      final response = await gateway.signIn(AuthenticationProvider.apple);
      expect(
        (response as Failure<AuthenticationBundle>).code,
        (result as Failure<ProviderCredential>).code,
      );
      expect(api.provider, isNull);
    }
  });

  test(
    'email OTP normalizes email, validates six digits and throttles resend',
    () async {
      final api = _AuthApi();
      final clock = FakeClock(DateTime.utc(2026, 9, 21));
      final controller = AccountController(
        gateway: SupabaseAuthenticationGateway(
          api: api,
          apple: _Apple(
            const Failure(FailureCode.authenticationProviderFailure),
          ),
          google: _Google(
            const Failure(FailureCode.authenticationProviderFailure),
          ),
        ),
        sessionStore: _Store(),
        clock: clock,
      );
      await controller.initialize();
      expect(
        await controller.requestEmailOtp(' Owner@Example.COM '),
        isA<Success<void>>(),
      );
      expect(api.email, 'owner@example.com');
      expect(
        (await controller.requestEmailOtp(
          'owner@example.com',
        ) as Failure<void>).code,
        FailureCode.rateLimited,
      );
      expect(
        (await controller.verifyEmailOtp(
          email: 'owner@example.com',
          otp: '12',
        ) as Failure<void>).code,
        FailureCode.invalidOtp,
      );
      clock.advance(const Duration(seconds: 61));
      expect(
        await controller.requestEmailOtp('owner@example.com'),
        isA<Success<void>>(),
      );
    },
  );

  test('rotated refresh credentials replace secure store atomically', () async {
    final old = _bundle('old-access', 'old-refresh');
    final rotated = _bundle('new-access', 'new-refresh');
    final store = _Store()..value = old;
    final api = _AuthApi()..restoreResult = Success(old);
    final controller = AccountController(
      gateway: SupabaseAuthenticationGateway(
        api: api,
        apple: _Apple(const Failure(FailureCode.authenticationProviderFailure)),
        google: _Google(
          const Failure(FailureCode.authenticationProviderFailure),
        ),
      ),
      sessionStore: store,
    );
    await controller.initialize();
    api.refreshResult = Success(rotated);
    expect(await controller.refresh(), isA<Success<void>>());
    expect(store.value?.secrets.accessToken, 'new-access');
    expect(store.value?.secrets.refreshToken, 'new-refresh');
  });

  test('permanent refresh rejection clears credentials; network failure preserves them', () async {
    final bundle = _bundle('access', 'refresh');
    for (final code in [
      FailureCode.sessionExpired,
      FailureCode.networkUnavailable,
    ]) {
      final store = _Store()..value = bundle;
      final api = _AuthApi()
        ..restoreResult = Success(bundle)
        ..refreshResult = Failure(code);
      final controller = AccountController(
        gateway: SupabaseAuthenticationGateway(
          api: api,
          apple: _Apple(
            const Failure(FailureCode.authenticationProviderFailure),
          ),
          google: _Google(
            const Failure(FailureCode.authenticationProviderFailure),
          ),
        ),
        sessionStore: store,
      );
      await controller.initialize();
      await controller.refresh();
      if (code == FailureCode.sessionExpired) {
        expect(store.value, isNull);
        expect(controller.state, AccountSessionState.requiresReauthentication);
      } else {
        expect(store.value, same(bundle));
        expect(controller.state, AccountSessionState.temporarilyUnavailable);
      }
    }
  });

  test(
    'tracked profile SQL enables RLS and contains no ledger sync tables',
    () {
      final sql = File('supabase/migrations/202609210001_profiles.sql')
          .readAsStringSync();
      expect(sql, contains('enable row level security'));
      expect(sql, contains('auth.uid()'));
      expect(sql, contains('references auth.users(id) on delete cascade'));
      expect(sql, isNot(contains('service_role')));
      expect(sql, isNot(contains('transactions')));
    },
  );

  test('Supabase SDK persistence is disabled in favor of secure store', () {
    final runtime = File(
      'lib/features/account/infrastructure/supabase/supabase_runtime.dart',
    ).readAsStringSync();
    expect(runtime, contains('persistSession: false'));
    expect(runtime, contains('autoRefreshToken: false'));
    expect(runtime, contains('EmptyLocalStorage()'));
    expect(runtime, contains('NoopPkceStorage()'));
    expect(runtime, isNot(contains('SharedPreferences')));
  });
}

AuthenticationBundle _bundle(String access, String refresh) =>
    AuthenticationBundle(
      session: AuthenticatedSession(
        account: CloudAccount(
          id: 'account-id',
          identities: const [
            ProviderIdentity(
              provider: AuthenticationProvider.emailOtp,
              subject: 'subject',
            ),
          ],
          createdAtUtc: DateTime.utc(2026, 9, 21),
        ),
        expiresAtUtc: DateTime.utc(2026, 9, 22),
        canRefresh: true,
      ),
      secrets: SessionSecrets(accessToken: access, refreshToken: refresh),
    );

SupabaseConfiguration _supabaseConfiguration() => SupabaseConfiguration(
  url: Uri.parse('https://example.supabase.co'),
  publishableKey: 'publishable',
  googleWebClientId: 'web-client-id',
);

final class _Apple implements AppleCredentialProvider {
  const _Apple(this.result);
  final Result<ProviderCredential> result;
  @override
  Future<Result<ProviderCredential>> acquire() async => result;
}

final class _Google implements GoogleCredentialProvider {
  const _Google(this.result);
  final Result<ProviderCredential> result;
  @override
  Future<Result<ProviderCredential>> acquire() async => result;
  @override
  Future<void> signOut() async {}
}

final class _GoogleClient implements GoogleSignInClient {
  _GoogleClient({
    required this.authentication,
    this.silentAccessToken,
    this.interactiveAccessToken = 'access-token',
    this.authorizationError,
  });

  final GoogleAuthenticationResult authentication;
  final String? silentAccessToken;
  final String interactiveAccessToken;
  final Object? authorizationError;
  List<String>? requestedScopes;
  int interactiveAuthorizationCalls = 0;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) async {}

  @override
  Future<GoogleAuthenticationResult> authenticate() async => authentication;

  @override
  Future<String?> authorizationForScopes(List<String> scopes) async {
    requestedScopes = List.of(scopes);
    if (authorizationError case final Object error) throw error;
    return silentAccessToken;
  }

  @override
  Future<String> authorizeScopes(List<String> scopes) async {
    interactiveAuthorizationCalls++;
    requestedScopes = List.of(scopes);
    if (authorizationError case final Object error) throw error;
    return interactiveAccessToken;
  }

  @override
  Future<void> signOut() async {}
}

final class _AuthApi implements SupabaseAuthApi {
  AuthenticationProvider? provider;
  ProviderCredential? credential;
  String? email;
  Result<AuthenticationBundle> restoreResult = Success(_bundle('a', 'r'));
  Result<AuthenticationBundle> refreshResult = Success(_bundle('b', 'rr'));

  @override
  Future<Result<AuthenticationBundle>> signInWithProvider({
    required AuthenticationProvider provider,
    required ProviderCredential credential,
  }) async {
    this.provider = provider;
    this.credential = credential;
    return Success(_bundle('access', 'refresh'));
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    this.email = email;
    return const Success(null);
  }

  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async => Success(_bundle('access', 'refresh'));

  @override
  Future<Result<AuthenticationBundle>> restore(SessionSecrets secrets) async =>
      restoreResult;
  @override
  Future<Result<AuthenticationBundle>> refresh(SessionSecrets secrets) async =>
      refreshResult;
  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) async =>
      Success(_bundle('a', 'r').session.account);
  @override
  Future<Result<void>> signOut() async => const Success(null);
}

final class _Store implements SecureSessionStore {
  AuthenticationBundle? value;
  @override
  Future<Result<AuthenticationBundle?>> read() async => Success(value);
  @override
  Future<Result<void>> write(AuthenticationBundle bundle) async {
    value = bundle;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    value = null;
    return const Success(null);
  }
}

final class FakeClock implements Clock {
  FakeClock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
  void advance(Duration duration) => value = value.add(duration);
}
