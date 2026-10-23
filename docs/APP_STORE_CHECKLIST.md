# Apple release checklist — all implementation evidence pending

Reviewed official guidance 19 September 2026; recheck at submission. A plan is not compliance verification.

- [ ] Owner Apple Developer team and App Store Connect app exist; bundle ID ownership confirmed.
- [ ] Flutter-generated Runner compiles on supported Xcode/macOS; signing and provisioning are reproducible in protected CI.
- [ ] Native camera/photo/microphone/speech/Face ID descriptions localized; permissions contextual and denial handled.
- [ ] Sign in with Apple capability/flow and Google alternative evaluated against current login rule; revocation tested.
- [ ] In-app cloud-account deletion, recent auth, Apple token revocation and disclosed retention work. [Apple deletion guidance](https://developer.apple.com/support/offering-account-deletion-in-your-app/).
- [ ] Deploy/test `delete-account` with recent sign-in and retry; live-test the implemented Sign in with Apple reauthorization, token exchange and revocation (including cancellation, retry and multi-provider account); confirm device ledger stays local and store subscription continues until separately cancelled.
- [ ] Set owner-approved HTTPS `PRIVACY_POLICY_URL` and `TERMS_URL`; missing URLs are hidden in release and block submission. Review `APP_STORE_PRIVACY_DATA_MAP.md` and `DATA_RETENTION.md`.
- [ ] App Privacy responses match final SDKs and data map; privacy policy and Terms publicly accessible and available in app.
- [ ] Required privacy manifests/reason APIs reconciled with actual dependencies; Runner declares linked first-party optional cloud/billing collection for app functionality; reconcile the final Xcode report before submission. [Privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files).
- [ ] Inspect Runner's `PrivacyInfo.xcprivacy` in Xcode aggregated report against first-party Required Reason API use; inspect vendor manifests/signatures in resolved release SDKs.
- [ ] ATT only if applicable to actual tracking; consent denial does not block bookkeeping.
- [ ] Replace the safe sample `ADMOB_APP_ID` in the signed production build; configure AdMob UMP European/UK/Swiss, applicable US-state, and IDFA messages before enabling ads.
- [ ] Verify `google_mobile_ads` and every bundled native SDK privacy manifest/signature in the archived app. KeEv's own `PrivacyInfo.xcprivacy` declares no first-party tracking for the Phase 7 default; revise it if production behavior changes.
- [ ] Reconcile App Privacy answers with the production SDK privacy report (identifiers, advertising data, coarse location, usage and diagnostics as actually collected).
- [ ] Localize/review `NSUserTrackingUsageDescription`; invoke ATT only after contextual/UMP IDFA explanation when tracking is genuinely enabled. Test authorized, denied, restricted and not-determined states on a physical device.
- [ ] StoreKit products configured; sandbox purchase/pending/cancel/refund/restore tested; visible Restore Purchases; no local unlock boolean.
- [ ] Approved price/catalog, subscription explanation if selected and Manage Subscription route.
- [ ] App-switcher privacy, VoiceOver, large text, contrast, reduced motion, offline flows reviewed on physical devices.
- [ ] Localized title/subtitle/description/keywords/support URL/privacy URL/age rating; screenshots from real app with synthetic data for current required device sizes.
- [ ] Encryption/export-compliance questionnaire answered for final backup/auth implementation; do not inherit prototype's declaration unquestioningly.
- [ ] Review notes explain local mode, account access/testing, cloud/purchases, permissions and deletion; backend reachable during review.
- [ ] Signed archive accepted by TestFlight; install/update/restore tested; crash-free signoff evidence attached.
- [ ] Owner approves submission package and publication timing; submit only after all release gates pass.

Checklist derives from the user's scope and [current App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/); storefront exceptions must be reviewed if changing payment strategy. No compliance guarantee or successful review claimed.

- Phase 8A: configure subscription group, products, Sandbox testers, prices and accurate Terms/Privacy URLs; verify StoreKit transaction completion and App Store privacy data disclosures. Checkout remains disabled until Phase 8B trusted server verification is deployed. See `APP_STORE_IAP_SETUP.md`.
