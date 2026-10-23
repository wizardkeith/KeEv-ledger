import '../domain/ads.dart';

abstract interface class AdConsentGateway {
  Future<void> requestConsentInfoUpdate();
  Future<void> loadAndShowConsentFormIfRequired();
  Future<bool> canRequestAds();
  Future<PrivacyOptionsRequirement> privacyOptionsRequirement();
  Future<void> showPrivacyOptionsForm();
}

abstract interface class AdsSdkGateway {
  Future<void> initialize();
}

abstract interface class TrackingAuthorizationGateway {
  Future<TrackingAuthorizationStatus> status();
  Future<TrackingAuthorizationStatus> requestAuthorization();
}

abstract interface class AdsEntitlement {
  bool get adsAllowed;
}

final class FreeAdsEntitlement implements AdsEntitlement {
  const FreeAdsEntitlement();
  @override
  bool get adsAllowed => true;
}
