import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/environment.dart';
import '../unavailable_authentication_gateway.dart';
import '../../application/authentication_contracts.dart';
import 'native_identity_providers.dart';
import 'supabase_auth_api.dart';
import 'supabase_authentication_gateway.dart';
import 'supabase_backend_api.dart';
import '../../application/cloud_backend_contracts.dart';

final class NoopPkceStorage extends GotrueAsyncStorage {
  const NoopPkceStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

AuthenticatedBackendApi? createAuthenticatedBackendApi(
  SupabaseConfiguration? configuration,
) {
  if (configuration == null) return null;
  try {
    return SupabaseBackendApi(Supabase.instance.client);
  } on Object {
    return null;
  }
}

Future<AuthenticationGateway> createAuthenticationGateway(
  SupabaseConfiguration? configuration,
) async {
  if (configuration == null) return const UnavailableAuthenticationGateway();
  try {
    final instance = await Supabase.initialize(
      url: configuration.url.toString(),
      publishableKey: configuration.publishableKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: NoopPkceStorage(),
      ),
    );
    return SupabaseAuthenticationGateway(
      api: SupabaseClientAuthApi(instance.client),
      apple: NativeAppleCredentialProvider(configuration),
      google: NativeGoogleCredentialProvider(configuration),
    );
  } on Object {
    return const UnavailableAuthenticationGateway();
  }
}
