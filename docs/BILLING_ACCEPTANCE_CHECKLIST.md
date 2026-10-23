# Phase 8 live billing acceptance — OWNER ACTION REQUIRED

Keep `PURCHASES_ENABLED=false` until staging migrations, Edge runtime and these native/store checks pass. Use two KeEv accounts and separate Apple Sandbox/Google Play license-test identities; never run automated tests against real ad or purchase inventory.

## Apple Sandbox and App Store Connect

- [ ] Deploy both billing migrations and all five Edge Functions. Confirm official Apple server library imports, Apple PKI roots and production/sandbox certificate/environment rejection in the actual Edge runtime.
- [ ] Set separate Sandbox and Production App Store Server Notifications **V2** URLs. Request Test Notification; inspect Get Notification History and retries.
- [ ] Test initial purchase, renewal, auto-renew cancellation while paid, monthly-to-annual product change, restore, grace period with paid expiry past, billing retry, recovery, refund and revocation. Confirm server entitlement and ad suppression/reappearance.
- [ ] Replay notification UUID, delay an older signedDate, and interrupt processing after event claim. Confirm current App Store Server API state wins and durable retry resumes.

## Google Play internal test

- [ ] Use license testers and approved product/base plans. Test pending, purchase, renewal, cancel while paid, grace, on-hold, recovery, expiry, refund/revoke and backend acknowledgement before store deadline.
- [ ] Configure authenticated Pub/Sub push (OIDC audience and exact service-account email), send testNotification, duplicate messageId, wrong audience/account token and delayed old RTDN. Confirm invalid callers cannot reach store reconciliation.
- [ ] Interrupt acknowledgement after entitlement commit; confirm `acknowledgement_pending` and scheduled retry. Omit RTDN entirely and confirm the hourly bounded reconciliation detects current Play state.

## Account, product and client

- [ ] Account A purchase cannot be claimed by B. A's Apple purchase enables A's server capability on Android; B receives none. With two valid store sources, revoke one then the other and confirm Premium persists then ends.
- [ ] Confirm `adFree` hides existing banners immediately; when all sources end, ads return only if UMP/ATT and placement policy permit. Verify Local Only, sync, App Lock and encrypted `.keevbackup` remain independent.
- [ ] Test app kill/redelivery, Apple finish after trusted verification, Play local wrapper retirement without second acknowledgement, account mismatch recovery and server refresh after external refund.
- [ ] Verify iOS StoreKit and Android Play Billing native builds, Flutter full tests/analyze, product metadata/price, Terms and Privacy URLs, and store disclosures. Account deletion does **not** cancel the store subscription; direct users to App Store/Play management.

Only after all relevant checks pass should the owner explicitly set `PURCHASES_ENABLED=true` for an approved release. Company/account country: Hong Kong; preferred Supabase region: Singapore.
