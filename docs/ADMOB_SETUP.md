# KeEv Ledger AdMob setup

Commercial owner: **KeEv Global Services Limited**  
Company/account country: **Hong Kong** (never inferred from VPN/IP)  
Repository SDK: **google_mobile_ads 9.1.0**

## Done in repository

- Provider-neutral UMP consent, Mobile Ads initialization, ATT, entitlement
  and placement boundaries.
- Consent refresh and required-form flow once per launch after local entry;
  `canRequestAds` gates initialization and every banner.
- UMP-required privacy-options screen under Settings.
- One allow-listed adaptive banner at the Reports footer. Critical financial,
  security, cloud, backup, receipt and destructive flows are prohibited.
- Official Google test application/banner IDs for development/staging and a
  non-revenue native fallback. Automated tests use fakes and make no ad calls.
- Production Dart configuration fails closed unless `ADS_ENABLED=true` and
  both owner banner IDs are supplied.
- iOS ATT status/request adapter. Startup never prompts ATT; tracking is off
  unless `ADS_TRACKING_ENABLED=true` and a later contextual action requests it.

## Build configuration

- Dart defines: `ADS_ENABLED`, `ADS_TRACKING_ENABLED`,
  `ADMOB_ANDROID_BANNER_ID`, `ADMOB_IOS_BANNER_ID`.
- Android application ID: Gradle property `ADMOB_APP_ID` (CI/owner supplied).
- iOS application ID: Xcode build setting `ADMOB_APP_ID` (CI/owner supplied).
- Never put personal test-device identifiers or account credentials in source.

## Owner action required

1. Create or use the KeEv Google/AdMob organization with company country Hong
   Kong; provide the real legal address, tax and payment information privately.
2. Register the Android package and iOS bundle as separate AdMob apps; obtain
   their application IDs. Create only the required banner units.
3. Configure Privacy & Messaging: European regulations (EEA/UK/Switzerland),
   applicable US-state/GPP messages, privacy-options entry point, and an IDFA
   explainer only if KeEv actually enables ATT-dependent advertising.
4. Supply production IDs through protected release configuration, enable ads,
   and confirm release builds never request official test units as live ads.
5. Add test devices in the AdMob console without committing identifiers. Test
   UMP geography overrides only on test builds.
6. Review child-directed/under-age settings. KeEv is not currently a children's
   app and the repository does not falsely mark users as under age.
7. Validate physical iOS/Android consent withdrawal, ATT denial, offline mode,
   App Lock, accessibility, orientation, and reports layout.
8. Reconcile Apple privacy manifests/App Privacy, Google Play Data Safety,
   Contains Ads, public privacy policy and third-party SDK disclosures before
   submission.

No AdMob publisher, app, unit, tax or payment ID is fabricated or committed.
No Firebase backend, analytics, attribution, StoreKit or Play Billing is added.
