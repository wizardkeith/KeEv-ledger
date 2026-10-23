# KeEv Ledger Phase 7 checkpoint

Status: **PASS — REPOSITORY IMPLEMENTATION COMPLETE**

- SDK: `google_mobile_ads` **9.1.0**, pinned with its webview platform
  transitives; no Firebase, analytics, billing, attribution or second CMP.
- UMP: one launch-session consent refresh after local entry, required-form
  workflow, `canRequestAds` before SDK initialization/request, cached-valid
  state handling on update failure, duplicate-start guard, and UMP-required
  privacy-options reopening.
- ATT: provider-neutral Dart contract and native iOS AppTrackingTransparency
  adapter. UMP and ATT remain separate. Tracking is disabled by default and
  startup never requests ATT; denial/restriction never blocks bookkeeping or
  consent-permitted non-IDFA ads. Purpose text is accurate and localized for
  en, zh-HK, ja and th.
- Placement: one responsive anchored adaptive banner at the Reports footer.
  The policy allow-list denies authentication, App Lock, backup/restore, sync
  onboarding/reconciliation/conflicts, receipt capture, privacy and destructive
  flows. No interstitial, rewarded or app-open ad exists.
- Entitlement/config: provider-neutral `AdsEntitlement` is the Phase 8
  remove-ads seam. `ADS_ENABLED` is the global kill switch. Development and
  staging use official Google test banner IDs. Production requires both owner
  banner IDs and otherwise fails closed. Native application IDs use official
  non-revenue samples until owner release settings override them.
- Privacy: advertising APIs accept placement/state rather than financial
  domain objects; no ledger-derived targeting/keywords. Ads are hidden on
  failure/offline and disposed when consent/lock eligibility changes. Ads,
  UMP cache and ATT status are excluded from Drift, sync and `.keevbackup`.
- Privacy manifest/docs: KeEv `PrivacyInfo.xcprivacy` is bundled and declares
  no first-party tracking for the default configuration; third-party manifests
  and production collection still require archive review. Dependency,
  notices, privacy map, security, monetization, App Store, Play Store and
  `ADMOB_SETUP.md` documentation are updated.
- Tests added: `test/unit/ads_foundation_test.dart` covers unknown/updating,
  allowed/restricted/failure/cached consent, privacy options, duplicate
  startup, entitlement/kill switch, critical surfaces, production fail-closed
  IDs, and ATT timing. Tests use fakes and never contact an ad service.
- Executed verification: `tool/phase7_ads_smoke.dart` PASS; full standalone
  `dart analyze --no-fatal-warnings` PASS with no issues; targeted formatting,
  ARB JSON validation, financial-type isolation and forbidden-ad-format scans
  PASS. Dependency resolution added only Mobile Ads 9.1.0 and its four locked
  webview packages; no existing package version changed.
- Phase 6 regression smoke: 6C-A, 6C-B and retention-safety standalone checks
  PASS; Drift remains v8 and sync/backup persistence was not changed.
- Flutter verification limitation: focused `flutter test` and `flutter
  analyze` were attempted once; the bundled Flutter launcher aborts before
  execution with Dart VM `BUS_ADRERR`. No Flutter test/analyze PASS is claimed.
- Native verification limitation: Android compile was attempted once but the
  uncached Gradle 9.3.1 distribution could not be downloaded in this network.
  iOS compilation is unavailable on Linux. Owner/CI native builds are required.
- Owner action: create/configure AdMob apps and Privacy & Messaging under KeEv
  Global Services Limited, country Hong Kong; supply real app/banner IDs;
  validate UMP/ATT/privacy manifests, App Privacy and Data Safety on physical
  devices. No IDs, address, tax or payment data were fabricated.
- Displayed ChatGPT Work usage is not available to the assistant.
- Phase 8 billing/subscriptions were **not started**.
