import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:async';

import '../features/settings/application/settings_controller.dart';
import '../features/settings/data/session_preferences.dart';
import 'app.dart';
import 'environment.dart';
import '../core/clock.dart';
import '../features/app_lock/application/app_lock_controller.dart';
import '../features/app_lock/infrastructure/flutter_secure_lock_store.dart';
import '../features/app_lock/infrastructure/local_auth_biometric_authenticator.dart';
import '../features/app_lock/infrastructure/pbkdf2_pin_deriver.dart';
import '../features/account/application/account_controller.dart';
import '../features/account/infrastructure/flutter_secure_session_store.dart';
import '../features/account/infrastructure/supabase/supabase_runtime.dart';
import '../features/ads/application/ads_runtime.dart';
import '../features/purchases/application/purchase_controller.dart';
import '../features/purchases/application/purchase_ports.dart';
import '../features/purchases/application/purchase_ads_entitlement.dart';
import '../features/purchases/infrastructure/flutter_store_gateway.dart';
import '../features/purchases/infrastructure/secure_purchase_journal.dart';
import '../features/purchases/infrastructure/supabase_purchase_remote.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (appFlavor != null && appFlavor != environment.name)
    throw StateError('Native flavor and Dart entry point do not match.');
  final controller = SettingsController(SessionPreferences());
  final appLock = AppLockController(
    store: const FlutterSecureLockStore(),
    pinDeriver: Pbkdf2PinDeriver(),
    biometrics: LocalAuthBiometricAuthenticator(),
    clock: const SystemClock(),
  );
  final supabase = SupabaseConfiguration.fromEnvironment();
  final adsConfiguration = AdsConfiguration.fromEnvironment(environment);
  final account = AccountController(
    gateway: await createAuthenticationGateway(supabase),
    sessionStore: const FlutterSecureSessionStore(),
    backend: createAuthenticatedBackendApi(supabase),
  );
  await Future.wait([
    controller.load(),
    appLock.initialize(),
    account.initialize(),
  ]);
  const configuredIds = String.fromEnvironment('PREMIUM_PRODUCT_IDS');
  final purchases = PurchaseController(
    store: FlutterStoreGateway(),
    verifier: supabase == null
        ? const UnavailablePurchaseVerifier()
        : SupabasePurchaseRemote(Supabase.instance.client),
    entitlementRemote: supabase == null
        ? null
        : SupabasePurchaseRemote(Supabase.instance.client),
    journal: SecurePurchaseJournal(),
    cache: SecureEntitlementCache(),
    catalogue: PurchaseCatalogue(
      configuredIds
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet(),
    ),
    accountId: () => account.account?.id,
    // Explicit release opt-in only after live store/backend acceptance.
    // Account, catalogue and store availability are rechecked by buy().
    purchaseEnabled:
        const bool.fromEnvironment('PURCHASES_ENABLED', defaultValue: false) &&
        supabase != null &&
        configuredIds.trim().isNotEmpty,
  );
  unawaited(purchases.start());
  final adsRuntime = AdsRuntime.production(
    adsConfiguration,
    entitlement: PurchaseAdsEntitlement(purchases),
  );
  runApp(
    KeEvApp(
      controller: controller,
      configuration: AppConfiguration(
        environment,
        supabase: supabase,
        ads: adsConfiguration,
      ),
      appLockController: appLock,
      accountController: account,
      adsController: adsRuntime.controller,
      purchaseController: purchases,
    ),
  );
}
