import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../app/environment.dart';
import '../domain/ads.dart';
import 'ads_contracts.dart';

final class AdsController extends ChangeNotifier {
  AdsController({
    required this.configuration,
    required AdConsentGateway consent,
    required AdsSdkGateway sdk,
    required TrackingAuthorizationGateway tracking,
    required AdsEntitlement entitlement,
    AdEligibilityPolicy policy = const AdEligibilityPolicy(),
  }) : _consent = consent,
       _sdk = sdk,
       _tracking = tracking,
       _entitlement = entitlement,
       _policy = policy {
    if (entitlement case final Listenable source) {
      source.addListener(_entitlementChanged);
    }
  }

  final AdsConfiguration configuration;
  final AdConsentGateway _consent;
  final AdsSdkGateway _sdk;
  final TrackingAuthorizationGateway _tracking;
  final AdsEntitlement _entitlement;
  final AdEligibilityPolicy _policy;

  void _entitlementChanged() => notifyListeners();

  @override
  void dispose() {
    if (_entitlement case final Listenable source) {
      source.removeListener(_entitlementChanged);
    }
    super.dispose();
  }

  ConsentSnapshot snapshot = const ConsentSnapshot.unknown();
  TrackingAuthorizationStatus trackingStatus =
      TrackingAuthorizationStatus.notSupported;
  bool potentiallyOnline = true;
  bool appLocked = false;
  bool _sdkInitialized = false;
  Future<void>? _startup;

  bool get privacyOptionsRequired =>
      snapshot.privacyOptions == PrivacyOptionsRequirement.required;

  Future<void> start() => _startup ??= _startOnce();

  Future<void> _startOnce() async {
    if (!configuration.enabled || !_entitlement.adsAllowed) {
      snapshot = const ConsentSnapshot(
        state: ConsentState.adsUnavailable,
        canRequestAds: false,
        privacyOptions: PrivacyOptionsRequirement.unknown,
      );
      notifyListeners();
      return;
    }
    snapshot = const ConsentSnapshot(
      state: ConsentState.updating,
      canRequestAds: false,
      privacyOptions: PrivacyOptionsRequirement.unknown,
    );
    notifyListeners();
    var updateFailed = false;
    try {
      await _consent.requestConsentInfoUpdate();
      await _consent.loadAndShowConsentFormIfRequired();
    } on Object {
      updateFailed = true;
    }
    await _reevaluate(updateFailed: updateFailed);
  }

  Future<void> _reevaluate({bool updateFailed = false}) async {
    var canRequest = false;
    var options = PrivacyOptionsRequirement.unknown;
    try {
      canRequest = await _consent.canRequestAds();
      options = await _consent.privacyOptionsRequirement();
      if (canRequest && !_sdkInitialized) {
        await _sdk.initialize();
        _sdkInitialized = true;
      }
      trackingStatus = await _tracking.status();
    } on Object {
      snapshot = ConsentSnapshot(
        state: ConsentState.error,
        canRequestAds: false,
        privacyOptions: options,
      );
      notifyListeners();
      return;
    }
    snapshot = ConsentSnapshot(
      state: canRequest
          ? ConsentState.readyForAds
          : updateFailed
          ? ConsentState.error
          : ConsentState.adsUnavailable,
      canRequestAds: canRequest && _sdkInitialized,
      privacyOptions: options,
    );
    notifyListeners();
  }

  Future<void> showPrivacyOptions() async {
    if (!privacyOptionsRequired) return;
    try {
      await _consent.showPrivacyOptionsForm();
    } on Object {
      snapshot = ConsentSnapshot(
        state: ConsentState.error,
        canRequestAds: snapshot.canRequestAds,
        privacyOptions: snapshot.privacyOptions,
      );
      notifyListeners();
      return;
    }
    await _reevaluate();
  }

  /// This is intentionally not called during cold-start. A future product
  /// choice may invoke it after a contextual explanation and UMP IDFA message.
  Future<TrackingAuthorizationStatus> requestTrackingIfNeeded() async {
    trackingStatus = await _tracking.status();
    if (!configuration.trackingEnabled ||
        !snapshot.canRequestAds ||
        trackingStatus != TrackingAuthorizationStatus.notDetermined) {
      return trackingStatus;
    }
    trackingStatus = await _tracking.requestAuthorization();
    notifyListeners();
    return trackingStatus;
  }

  bool canShow(AdPlacement placement, AdSurface surface) => _policy.canShow(
    placement: placement,
    surface: surface,
    featureEnabled: configuration.enabled,
    entitlementAllowsAds: _entitlement.adsAllowed,
    consentAllowsAds: snapshot.canRequestAds,
    appLocked: appLocked,
    potentiallyOnline: potentiallyOnline,
  );

  void setAppLocked(bool value) {
    if (value == appLocked) return;
    appLocked = value;
    notifyListeners();
  }

  void setPotentiallyOnline(bool value) {
    if (value == potentiallyOnline) return;
    potentiallyOnline = value;
    notifyListeners();
  }
}
