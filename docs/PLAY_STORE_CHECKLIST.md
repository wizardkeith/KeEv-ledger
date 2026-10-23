# Google Play release checklist — Phase 11 source prepared; native evidence pending

Official requirements checked 24 September 2026; recheck before upload. The Gradle source now explicitly sets compileSdk/targetSdk 36; a resolved build and merged manifest must confirm these values. Official policy requires new mobile apps/updates to target Android 16/API 36 or higher from 31 August 2026. [Target API policy](https://support.google.com/googleplay/android-developer/answer/11926878). See `ANDROID_RELEASE_BUILD.md`, `ANDROID_PERMISSION_MAP.md`, and `ANDROID_RC_ACCEPTANCE_CHECKLIST.md`.

- [ ] Owner Play Console developer identity/app registration and package ID ownership confirmed.
- [ ] Flutter-generated Android application, target API/current native-library compatibility verified on actual release build.
- [ ] Release signing/upload key in protected secrets; Play App Signing configured; no keystore/private key in repository.
- [ ] Camera/microphone/biometric and photo-picker handling contextual; no unnecessary broad storage permissions.
- [ ] Android backup/data-extraction rules checked against local-only privacy and secure-storage recovery.
- [ ] Verify `allowBackup=false` and `data_extraction_rules.xml` exclude OS cloud backup and device transfer on supported versions; explicit `.keevbackup` remains available.
- [ ] Google OAuth client IDs/fingerprints and app links verified; Apple/email flows work where offered.
- [ ] Play Billing integration/current permitted version verified, product catalog configured, sandbox/license testers ready. [Play Billing](https://developer.android.com/google/play/billing).
- [ ] Purchase pending/failure/acknowledgement/refund/restore works and verified server records match app entitlements.
- [ ] Data Safety form matches final SDK behaviour, ads declaration and privacy policy; contact/retention accurate.
- [ ] In-app account deletion and public web deletion initiation URL operational; page identifies app/developer and data/retention. [Google account deletion](https://support.google.com/googleplay/android-developer/answer/13327111).
- [ ] Deploy/test authenticated `delete-account` with Account A/B, recent sign-in, partial retry and exact Storage prefixes; publish HTTPS `ACCOUNT_DELETION_URL` per `ACCOUNT_DELETION_WEB_REQUIREMENT.md` and approve billing/deletion audit retention.
- [ ] Supply HTTPS `PRIVACY_POLICY_URL`, `TERMS_URL` and owner contact; reconcile `PLAY_DATA_SAFETY_MAP.md` with signed AAB and submit actual Data Safety answers.
- [ ] Ads/consent/regional behaviour validated; no financial targeting; test IDs excluded from production.
- [ ] Replace the official sample AdMob application ID through owner Gradle/CI configuration and supply production banner unit IDs before `ADS_ENABLED=true`.
- [ ] Configure and test AdMob Privacy & Messaging for European regulations and applicable US-state messages; verify the in-app privacy-options entry point.
- [ ] Reconcile Play Data Safety and the Contains Ads declaration with the exact production Google Mobile Ads SDK data behavior; verify no ledger-derived targeting or custom keywords.
- [ ] Content/age rating, target audience, app access/reviewer instructions, privacy URL, support and all five locale metadata prepared.
- [ ] Store screenshots/feature graphic captured from actual Flutter app with synthetic data.
- [ ] Internal testing AAB accepted/installed; pre-launch report reviewed; migration/backup/restore on physical phones.
- [ ] Closed-testing/production-access requirements checked for this developer account type and creation date. Do not assume personal-account thresholds apply to a company account. [Testing rules](https://support.google.com/googleplay/android-developer/answer/14151465).
- [ ] Staged rollout, crash thresholds, backend capacity and rollback/pause process approved.
- [ ] Owner approves final production submission.

No AAB/APK has been built, uploaded, or declared compliant at this checkpoint.

- Phase 8A: configure Play subscription base plans, internal testing/license testers, localized prices, payments and Data Safety purchase data disclosures; confirm Billing Library version after CI dependency resolution. Checkout remains disabled until Phase 8B trusted verification. See `PLAY_BILLING_SETUP.md`.
