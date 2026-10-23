import 'dart:io';

import 'package:ledger/app/environment.dart';
import 'package:ledger/features/ads/domain/ads.dart';

Never _fail(String message) => throw StateError(message);
void _expect(bool condition, String message) {
  if (!condition) _fail(message);
}

String _read(String path) => File(path).readAsStringSync();

void main() {
  const policy = AdEligibilityPolicy();
  _expect(
    policy.canShow(
      placement: AdPlacement.reportsFooter,
      surface: AdSurface.reports,
      featureEnabled: true,
      entitlementAllowsAds: true,
      consentAllowsAds: true,
      appLocked: false,
      potentiallyOnline: true,
    ),
    'approved reports placement must be eligible',
  );
  for (final surface in AdSurface.values.where((v) => v != AdSurface.reports)) {
    _expect(
      !policy.canShow(
        placement: AdPlacement.reportsFooter,
        surface: surface,
        featureEnabled: true,
        entitlementAllowsAds: true,
        consentAllowsAds: true,
        appLocked: false,
        potentiallyOnline: true,
      ),
      'sensitive surface ${surface.name} must be denied',
    );
  }

  const productionWithoutIds = AdsConfiguration(
    environment: AppEnvironment.production,
    featureEnabled: true,
    trackingEnabled: false,
    androidBannerId: '',
    iosBannerId: '',
  );
  _expect(
    !productionWithoutIds.enabled,
    'production must fail closed without IDs',
  );

  final ump = _read('lib/features/ads/infrastructure/google_ads_gateways.dart');
  for (final requiredCall in [
    'requestConsentInfoUpdate',
    'loadAndShowConsentFormIfRequired',
    'canRequestAds',
    'getPrivacyOptionsRequirementStatus',
    'showPrivacyOptionsForm',
  ]) {
    _expect(ump.contains(requiredCall), 'missing UMP call $requiredCall');
  }
  final controller = _read('lib/features/ads/application/ads_controller.dart');
  _expect(
    controller.indexOf('canRequest = await _consent.canRequestAds()') <
        controller.indexOf('await _sdk.initialize()'),
    'SDK initialization must follow canRequestAds',
  );
  _expect(
    !_read('lib/app/app.dart').contains('requestTrackingIfNeeded'),
    'application startup must not automatically request ATT',
  );
  final adApi =
      '${_read('lib/features/ads/application/ads_contracts.dart')}\n'
      '${_read('lib/features/ads/domain/ads.dart')}';
  for (final financialType in [
    'Transaction',
    'Account',
    'Budget',
    'Receipt',
    'SyncConflict',
  ]) {
    _expect(!adApi.contains(financialType), 'ads API accepts $financialType');
  }

  final ios = _read('ios/Runner/AppDelegate.swift');
  _expect(
    ios.contains('ATTrackingManager.trackingAuthorizationStatus'),
    'ATT status missing',
  );
  _expect(ios.contains('requestTrackingAuthorization'), 'ATT request missing');
  final manifest = _read('android/app/src/main/AndroidManifest.xml');
  _expect(
    manifest.contains('com.google.android.gms.ads.APPLICATION_ID'),
    'Android App ID missing',
  );

  stdout.writeln('Phase 7 ads/consent static smoke: PASS');
}
