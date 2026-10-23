# App Store IAP setup

## Done in repository

Official `in_app_purchase: 3.3.1` client gateway; StoreKit 2 is the endorsed default. Purchase stream, encrypted pending journal, Restore Purchases, store price display and account-bound verification boundary are implemented. Production checkout defaults disabled behind an explicit owner-controlled flag; no product ID or price has been assumed.

## Owner action required

In the KeEv Global Services Limited Apple developer account (Hong Kong), complete banking/tax agreements; create the auto-renewable Premium subscription group, products, periods, regional prices, localizations and review metadata. Supply real IDs via `PREMIUM_PRODUCT_IDS`; set accurate terms/privacy URLs before enabling checkout. Configure StoreKit test plans and Sandbox accounts; test renewals, cancellation, pending approval, restore, billing retry and refund. Phase 8B implements the server API and Notifications V2; deployed runtime and live Sandbox acceptance remain required before production purchase initiation. Verify native archive and entitlement disclosures on iOS.

## 8B-A server setup

OWNER ACTION REQUIRED: create an App Store Connect In-App Purchase key, Key ID and Issuer ID; supply actual bundle ID and production App Apple ID, Apple PKI roots, approved subscription product IDs and Sandbox users as Supabase server secrets. Validate official `@apple/app-store-server-library@3.1.0` under deployed Supabase Edge runtime before enabling sandbox verification. Production checkout defaults disabled. Notifications V2 are implemented in 8B-B and require live deployment validation.

## 8B-B Notifications V2 — owner action required

Configure separate Production and Sandbox App Store Server Notifications **V2** URLs in App Store Connect, pointing to the deployed `apple-store-notifications` function for the matching billing environment. Do not use V1. Use Request Test Notification and Get Notification History during acceptance; verify root-anchored outer/nested JWS, duplicate UUID, retries, upgrade, grace, refund and revocation against current App Store Server API status. The repo supplies no real deployed URL or keys. Production checkout stays opt-in behind `PURCHASES_ENABLED=false` until native and live checks pass. Manage/cancel subscriptions in Apple's store; deleting a KeEv account does not cancel billing.
