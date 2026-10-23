enum AdPlacement { reportsFooter }

enum AdSurface {
  reports,
  authentication,
  appLock,
  backup,
  restore,
  syncOnboarding,
  reconciliation,
  conflictResolution,
  receiptCapture,
  destructiveConfirmation,
  privacy,
}

enum ConsentState { unknown, updating, readyForAds, adsUnavailable, error }

enum PrivacyOptionsRequirement { unknown, required, notRequired }

enum TrackingAuthorizationStatus {
  notSupported,
  notDetermined,
  restricted,
  denied,
  authorized,
}

final class ConsentSnapshot {
  const ConsentSnapshot({
    required this.state,
    required this.canRequestAds,
    required this.privacyOptions,
  });

  const ConsentSnapshot.unknown()
    : state = ConsentState.unknown,
      canRequestAds = false,
      privacyOptions = PrivacyOptionsRequirement.unknown;

  final ConsentState state;
  final bool canRequestAds;
  final PrivacyOptionsRequirement privacyOptions;
}

final class AdEligibilityPolicy {
  const AdEligibilityPolicy();

  static const Map<AdPlacement, AdSurface> _allowed = {
    AdPlacement.reportsFooter: AdSurface.reports,
  };

  bool canShow({
    required AdPlacement placement,
    required AdSurface surface,
    required bool featureEnabled,
    required bool entitlementAllowsAds,
    required bool consentAllowsAds,
    required bool appLocked,
    required bool potentiallyOnline,
  }) =>
      featureEnabled &&
      entitlementAllowsAds &&
      consentAllowsAds &&
      !appLocked &&
      potentiallyOnline &&
      _allowed[placement] == surface;
}
