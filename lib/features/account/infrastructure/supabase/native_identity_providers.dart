import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/result.dart';
import '../../../../app/environment.dart';
import 'supabase_auth_ports.dart';

final class NativeAppleCredentialProvider implements AppleCredentialProvider {
  const NativeAppleCredentialProvider(this.configuration);

  final SupabaseConfiguration configuration;

  @override
  Future<Result<ProviderCredential>> acquire() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        return const Failure(FailureCode.authenticationProviderFailure);
      }
      WebAuthenticationOptions? web;
      if (Platform.isAndroid) {
        final serviceId = configuration.appleServiceId;
        final redirect = configuration.appleRedirectUri;
        if (serviceId == null || redirect == null) {
          return const Failure(FailureCode.cloudConfigurationUnavailable);
        }
        web = WebAuthenticationOptions(
          clientId: serviceId,
          redirectUri: redirect,
        );
      } else if (!Platform.isIOS && !Platform.isMacOS) {
        return const Failure(FailureCode.authenticationProviderFailure);
      }
      final rawNonce = _nonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
        webAuthenticationOptions: web,
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        return const Failure(FailureCode.authenticationProviderFailure);
      }
      final displayName = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
      return Success(
        ProviderCredential(
          idToken: identityToken,
          rawNonce: rawNonce,
          authorizationCode: credential.authorizationCode,
          displayName: displayName.isEmpty ? null : displayName,
        ),
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      return Failure(
        error.code == AuthorizationErrorCode.canceled
            ? FailureCode.cloudAuthenticationCancelled
            : FailureCode.authenticationProviderFailure,
      );
    } on Object {
      return const Failure(FailureCode.authenticationProviderFailure);
    }
  }

  String _nonce([int length = 32]) {
    const alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}

final class GoogleAuthenticationResult {
  const GoogleAuthenticationResult({required this.idToken, this.displayName});

  final String? idToken;
  final String? displayName;
}

abstract interface class GoogleSignInClient {
  Future<void> initialize({String? clientId, String? serverClientId});
  Future<GoogleAuthenticationResult> authenticate();
  Future<String?> authorizationForScopes(List<String> scopes);
  Future<String> authorizeScopes(List<String> scopes);
  Future<void> signOut();
}

final class FlutterGoogleSignInClient implements GoogleSignInClient {
  GoogleSignInAccount? _account;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) =>
      GoogleSignIn.instance.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

  @override
  Future<GoogleAuthenticationResult> authenticate() async {
    final account = await GoogleSignIn.instance.authenticate();
    _account = account;
    return GoogleAuthenticationResult(
      idToken: account.authentication.idToken,
      displayName: account.displayName,
    );
  }

  @override
  Future<String?> authorizationForScopes(List<String> scopes) async =>
      (await _requiredAccount().authorizationClient.authorizationForScopes(
        scopes,
      ))?.accessToken;

  @override
  Future<String> authorizeScopes(List<String> scopes) async =>
      (await _requiredAccount().authorizationClient.authorizeScopes(scopes))
          .accessToken;

  GoogleSignInAccount _requiredAccount() {
    final account = _account;
    if (account == null) throw StateError('Google authentication is required.');
    return account;
  }

  @override
  Future<void> signOut() => GoogleSignIn.instance.signOut();
}

final class NativeGoogleCredentialProvider implements GoogleCredentialProvider {
  NativeGoogleCredentialProvider(
    this.configuration, {
    GoogleSignInClient? client,
  }) : _client = client ?? FlutterGoogleSignInClient();

  final SupabaseConfiguration configuration;
  final GoogleSignInClient _client;
  Future<void>? _initialization;
  static const _identityScopes = <String>['openid', 'email'];

  Future<void> _initialize() => _initialization ??= _client.initialize(
    clientId: Platform.isIOS ? configuration.googleIosClientId : null,
    serverClientId: configuration.googleWebClientId,
  );

  @override
  Future<Result<ProviderCredential>> acquire() async {
    try {
      await _initialize();
      final account = await _client.authenticate();
      final idToken = account.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Failure(FailureCode.authenticationProviderFailure);
      }
      final silentAuthorization = await _client.authorizationForScopes(
        _identityScopes,
      );
      final accessToken =
          silentAuthorization ?? await _client.authorizeScopes(_identityScopes);
      if (accessToken.isEmpty) {
        return const Failure(FailureCode.authenticationProviderFailure);
      }
      return Success(
        ProviderCredential(
          idToken: idToken,
          accessToken: accessToken,
          displayName: account.displayName,
        ),
      );
    } on GoogleSignInException catch (error) {
      return Failure(switch (error.code) {
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted =>
          FailureCode.cloudAuthenticationCancelled,
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          FailureCode.cloudConfigurationUnavailable,
        _ => FailureCode.authenticationProviderFailure,
      });
    } on Object {
      return const Failure(FailureCode.authenticationProviderFailure);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _initialize();
      await _client.signOut();
    } on Object {
      // Supabase and KeEv secure-session clearing remain authoritative.
    }
  }
}
