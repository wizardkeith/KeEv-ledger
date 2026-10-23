import '../../../app/environment.dart';
import '../infrastructure/google_ads_gateways.dart';
import 'ads_contracts.dart';
import 'ads_controller.dart';

final class AdsRuntime {
  const AdsRuntime(this.controller);
  final AdsController controller;

  factory AdsRuntime.production(
    AdsConfiguration configuration, {
    AdsEntitlement entitlement = const FreeAdsEntitlement(),
  }) => AdsRuntime(
    AdsController(
      configuration: configuration,
      consent: const GoogleUmpConsentGateway(),
      sdk: const GoogleMobileAdsSdkGateway(),
      tracking: const PlatformTrackingAuthorizationGateway(),
      entitlement: entitlement,
    ),
  );
}
