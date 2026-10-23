import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../application/ads_contracts.dart';
import '../domain/ads.dart';

final class GoogleUmpConsentGateway implements AdConsentGateway {
  const GoogleUmpConsentGateway();

  @override
  Future<void> requestConsentInfoUpdate() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      completer.complete,
      (error) => completer.completeError(StateError(error.message)),
    );
    return completer.future;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(StateError(error.message));
      }
    });
    return completer.future;
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<PrivacyOptionsRequirement> privacyOptionsRequirement() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return switch (status) {
      PrivacyOptionsRequirementStatus.required =>
        PrivacyOptionsRequirement.required,
      PrivacyOptionsRequirementStatus.notRequired =>
        PrivacyOptionsRequirement.notRequired,
      _ => PrivacyOptionsRequirement.unknown,
    };
  }

  @override
  Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(StateError(error.message));
      }
    });
    return completer.future;
  }
}

final class GoogleMobileAdsSdkGateway implements AdsSdkGateway {
  const GoogleMobileAdsSdkGateway();
  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}

final class PlatformTrackingAuthorizationGateway
    implements TrackingAuthorizationGateway {
  const PlatformTrackingAuthorizationGateway();
  static const _channel = MethodChannel('com.keev.ledger/tracking');

  @override
  Future<TrackingAuthorizationStatus> status() => _invoke('status');

  @override
  Future<TrackingAuthorizationStatus> requestAuthorization() =>
      _invoke('request');

  Future<TrackingAuthorizationStatus> _invoke(String method) async {
    try {
      final value = await _channel.invokeMethod<String>(method);
      return TrackingAuthorizationStatus.values.firstWhere(
        (candidate) => candidate.name == value,
        orElse: () => TrackingAuthorizationStatus.notSupported,
      );
    } on MissingPluginException {
      return TrackingAuthorizationStatus.notSupported;
    } on PlatformException {
      return TrackingAuthorizationStatus.notSupported;
    }
  }
}
