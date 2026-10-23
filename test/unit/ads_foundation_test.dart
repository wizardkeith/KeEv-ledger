import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/environment.dart';
import 'package:ledger/features/ads/application/ads_contracts.dart';
import 'package:ledger/features/ads/application/ads_controller.dart';
import 'package:ledger/features/ads/domain/ads.dart';

final class FakeConsent implements AdConsentGateway {
  bool allowed = false;
  bool failUpdate = false;
  PrivacyOptionsRequirement options = PrivacyOptionsRequirement.notRequired;
  int updates = 0;
  int forms = 0;
  int privacyForms = 0;

  @override
  Future<bool> canRequestAds() async => allowed;
  @override
  Future<void> loadAndShowConsentFormIfRequired() async => forms++;
  @override
  Future<PrivacyOptionsRequirement> privacyOptionsRequirement() async =>
      options;
  @override
  Future<void> requestConsentInfoUpdate() async {
    updates++;
    if (failUpdate) throw StateError('test update failure');
  }

  @override
  Future<void> showPrivacyOptionsForm() async => privacyForms++;
}

final class FakeSdk implements AdsSdkGateway {
  int initializations = 0;
  @override
  Future<void> initialize() async => initializations++;
}

final class FakeTracking implements TrackingAuthorizationGateway {
  TrackingAuthorizationStatus value = TrackingAuthorizationStatus.notDetermined;
  int requests = 0;
  @override
  Future<TrackingAuthorizationStatus> requestAuthorization() async {
    requests++;
    value = TrackingAuthorizationStatus.authorized;
    return value;
  }

  @override
  Future<TrackingAuthorizationStatus> status() async => value;
}

final class FakeEntitlement implements AdsEntitlement {
  FakeEntitlement(this.adsAllowed);
  @override
  final bool adsAllowed;
}

AdsConfiguration configuration({
  bool enabled = true,
  bool tracking = false,
  AppEnvironment environment = AppEnvironment.development,
  String androidId = AdsConfiguration.androidTestBannerId,
  String iosId = AdsConfiguration.iosTestBannerId,
}) => AdsConfiguration(
  environment: environment,
  featureEnabled: enabled,
  trackingEnabled: tracking,
  androidBannerId: androidId,
  iosBannerId: iosId,
);

AdsController controller({
  required FakeConsent consent,
  required FakeSdk sdk,
  required FakeTracking tracking,
  bool entitlement = true,
  AdsConfiguration? config,
}) => AdsController(
  configuration: config ?? configuration(),
  consent: consent,
  sdk: sdk,
  tracking: tracking,
  entitlement: FakeEntitlement(entitlement),
);

void main() {
  test('unknown and updating consent cannot request or show ads', () async {
    final consent = FakeConsent();
    final sdk = FakeSdk();
    final ads = controller(
      consent: consent,
      sdk: sdk,
      tracking: FakeTracking(),
    );
    expect(ads.canShow(AdPlacement.reportsFooter, AdSurface.reports), isFalse);
    final start = ads.start();
    expect(ads.snapshot.state, ConsentState.updating);
    await start;
    expect(ads.snapshot.canRequestAds, isFalse);
    expect(sdk.initializations, 0);
  });

  test(
    'UMP permission initializes SDK once and duplicate startup coalesces',
    () async {
      final consent = FakeConsent()..allowed = true;
      final sdk = FakeSdk();
      final ads = controller(
        consent: consent,
        sdk: sdk,
        tracking: FakeTracking(),
      );
      await Future.wait([ads.start(), ads.start(), ads.start()]);
      expect(consent.updates, 1);
      expect(consent.forms, 1);
      expect(sdk.initializations, 1);
      expect(ads.snapshot.state, ConsentState.readyForAds);
      expect(ads.canShow(AdPlacement.reportsFooter, AdSurface.reports), isTrue);
    },
  );

  test(
    'update failure uses valid previous SDK consent but otherwise hides ads',
    () async {
      final prior = FakeConsent()
        ..failUpdate = true
        ..allowed = true;
      final priorSdk = FakeSdk();
      final allowed = controller(
        consent: prior,
        sdk: priorSdk,
        tracking: FakeTracking(),
      );
      await allowed.start();
      expect(allowed.snapshot.canRequestAds, isTrue);
      expect(priorSdk.initializations, 1);

      final none = FakeConsent()..failUpdate = true;
      final noneSdk = FakeSdk();
      final blocked = controller(
        consent: none,
        sdk: noneSdk,
        tracking: FakeTracking(),
      );
      await blocked.start();
      expect(blocked.snapshot.canRequestAds, isFalse);
      expect(noneSdk.initializations, 0);
    },
  );

  test('privacy options are exposed only when UMP requires them', () async {
    final consent = FakeConsent()
      ..allowed = true
      ..options = PrivacyOptionsRequirement.required;
    final ads = controller(
      consent: consent,
      sdk: FakeSdk(),
      tracking: FakeTracking(),
    );
    await ads.start();
    expect(ads.privacyOptionsRequired, isTrue);
    await ads.showPrivacyOptions();
    expect(consent.privacyForms, 1);
  });

  test(
    'policy denies every sensitive surface and wrong placement pairing',
    () async {
      final consent = FakeConsent()..allowed = true;
      final ads = controller(
        consent: consent,
        sdk: FakeSdk(),
        tracking: FakeTracking(),
      );
      await ads.start();
      for (final sensitive in AdSurface.values.where(
        (value) => value != AdSurface.reports,
      )) {
        expect(ads.canShow(AdPlacement.reportsFooter, sensitive), isFalse);
      }
      ads.setAppLocked(true);
      expect(
        ads.canShow(AdPlacement.reportsFooter, AdSurface.reports),
        isFalse,
      );
      ads.setAppLocked(false);
      ads.setPotentiallyOnline(false);
      expect(
        ads.canShow(AdPlacement.reportsFooter, AdSurface.reports),
        isFalse,
      );
    },
  );

  test(
    'entitlement and global kill switch prevent SDK and ad requests',
    () async {
      for (final setup in [
        (false, configuration()),
        (true, configuration(enabled: false)),
      ]) {
        final consent = FakeConsent()..allowed = true;
        final sdk = FakeSdk();
        final ads = controller(
          consent: consent,
          sdk: sdk,
          tracking: FakeTracking(),
          entitlement: setup.$1,
          config: setup.$2,
        );
        await ads.start();
        expect(consent.updates, 0);
        expect(sdk.initializations, 0);
      }
    },
  );

  test(
    'production without owner IDs fails closed; non-production uses test IDs',
    () {
      final production = configuration(
        environment: AppEnvironment.production,
        androidId: '',
        iosId: '',
      );
      expect(production.enabled, isFalse);
      final development = configuration();
      expect(development.usesTestAds, isTrue);
      expect(development.androidBannerId, AdsConfiguration.androidTestBannerId);
      expect(development.iosBannerId, AdsConfiguration.iosTestBannerId);
    },
  );

  test(
    'ATT is separate, contextual, and never requested when not configured',
    () async {
      final consent = FakeConsent()..allowed = true;
      final tracking = FakeTracking();
      final noTracking = controller(
        consent: consent,
        sdk: FakeSdk(),
        tracking: tracking,
      );
      await noTracking.start();
      await noTracking.requestTrackingIfNeeded();
      expect(tracking.requests, 0);

      final configuredTracking = FakeTracking();
      final trackingAds = controller(
        consent: FakeConsent()..allowed = true,
        sdk: FakeSdk(),
        tracking: configuredTracking,
        config: configuration(tracking: true),
      );
      await trackingAds.start();
      expect(
        configuredTracking.requests,
        0,
        reason: 'startup must not prompt ATT',
      );
      expect(
        await trackingAds.requestTrackingIfNeeded(),
        TrackingAuthorizationStatus.authorized,
      );
      expect(configuredTracking.requests, 1);
    },
  );
}
