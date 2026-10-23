import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/result.dart';
import '../application/authentication_contracts.dart';
import '../domain/cloud_account.dart';

const _cloudSessionKey = 'keev.cloud_session.v1';

final class FlutterSecureSessionStore implements SecureSessionStore {
  const FlutterSecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<Result<AuthenticationBundle?>> read() async {
    try {
      final value = await _storage.read(key: _cloudSessionKey);
      if (value == null) return const Success(null);
      return Success(_decode(value));
    } on Object {
      return const Failure(FailureCode.secureSessionStorageUnavailable);
    }
  }

  @override
  Future<Result<void>> write(AuthenticationBundle bundle) async {
    try {
      await _storage.write(key: _cloudSessionKey, value: _encode(bundle));
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.secureSessionStorageUnavailable);
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _storage.delete(key: _cloudSessionKey);
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.secureSessionStorageUnavailable);
    }
  }

  String _encode(AuthenticationBundle bundle) => jsonEncode({
    'version': 1,
    'account': {
      'id': bundle.session.account.id,
      'email': bundle.session.account.email,
      'displayName': bundle.session.account.displayName,
      'createdAtUtc': bundle.session.account.createdAtUtc.toIso8601String(),
      'identities': [
        for (final identity in bundle.session.account.identities)
          {'provider': identity.provider.name, 'subject': identity.subject},
      ],
    },
    'expiresAtUtc': bundle.session.expiresAtUtc.toIso8601String(),
    'canRefresh': bundle.session.canRefresh,
    'accessToken': bundle.secrets.accessToken,
    'refreshToken': bundle.secrets.refreshToken,
  });

  AuthenticationBundle _decode(String value) {
    try {
      final root = jsonDecode(value) as Map<String, dynamic>;
      if (root['version'] != 1) throw const FormatException();
      final accountJson = root['account'] as Map<String, dynamic>;
      final identitiesJson = accountJson['identities'] as List<dynamic>;
      final account = CloudAccount(
        id: accountJson['id'] as String,
        email: accountJson['email'] as String?,
        displayName: accountJson['displayName'] as String?,
        createdAtUtc: DateTime.parse(accountJson['createdAtUtc'] as String)
            .toUtc(),
        identities: [
          for (final item in identitiesJson.cast<Map<String, dynamic>>())
            ProviderIdentity(
              provider: AuthenticationProvider.values.byName(
                item['provider'] as String,
              ),
              subject: item['subject'] as String,
            ),
        ],
      );
      final accessToken = root['accessToken'] as String;
      if (accessToken.isEmpty) throw const FormatException();
      return AuthenticationBundle(
        session: AuthenticatedSession(
          account: account,
          expiresAtUtc: DateTime.parse(root['expiresAtUtc'] as String).toUtc(),
          canRefresh: root['canRefresh'] as bool,
        ),
        secrets: SessionSecrets(
          accessToken: accessToken,
          refreshToken: root['refreshToken'] as String?,
        ),
      );
    } on Object {
      throw const FormatException('Invalid secure cloud session');
    }
  }
}
