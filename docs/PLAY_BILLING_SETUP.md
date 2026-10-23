# Google Play Billing setup

## Done in repository

The official `in_app_purchase: 3.3.1` gateway uses its endorsed Android implementation. Product prices are obtained from the store. Purchase updates are journaled before completion and cannot grant Premium without a trusted verifier. The selected endorsed Android plugin is 0.5.3, whose official changelog specifies native Billing Library 8.0.0. The current Dart 3.12 toolchain cannot resolve this workspace; confirm actual resolved lockfile and Gradle artifacts in CI. No Billing Library 7 pin is added.

## Owner action required

For KeEv Global Services Limited, use Hong Kong for the business/payments profile. In Play Console, configure subscription product IDs, base plans, eligible offers, descriptions, localizations, payments and internal testing/license testers. Provide IDs through `PREMIUM_PRODUCT_IDS`. Test purchase, acknowledgement, pending transactions, restore and refund in Play internal testing. Phase 8B implements Play Developer API verification and RTDN/Pub/Sub; live deployment acceptance remains required. Treat RTDN as an invalidation signal. Enable production checkout only after trusted verification and test entitlement delivery. No production IDs or prices are fabricated.

## 8B-A server setup

OWNER ACTION REQUIRED: enable Play Developer API, link a narrowly authorized service account to Play Console, configure the Android package, approved subscription product/base-plan IDs, license testers and server secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`. Backend reads `subscriptionsv2.get`; acknowledgement uses the Play subscriptions acknowledgement method after durable entitlement grant. Confirm sandbox/ack deadline behaviour before checkout is enabled. RTDN/Pub/Sub is implemented in 8B-B and awaits live internal testing. KeEv business/payment jurisdiction is Hong Kong regardless of VPN/IP.

## 8B-B RTDN — owner action required

Create a Google Cloud Pub/Sub topic, configure the Play Console RTDN topic, and create an **authenticated push** subscription to the deployed `google-play-rtdn` function. Use an owner-created push service account; grant the Google Pub/Sub service agent permission to create OIDC tokens for it. Set an explicit OIDC audience (prefer the exact push endpoint URL) and configure that exact string as `BILLING_PUBSUB_AUDIENCE`; configure the exact push service-account email as `BILLING_PUBSUB_PUSH_SERVICE_ACCOUNT`. No project ID, endpoint, credential or purchase price is invented here. Exercise testNotification, invalid OIDC, duplicate/delayed messages, token reconciliation, account binding and backend acknowledgement in internal testing. RTDN is a signal; current `subscriptionsv2.get` is authority. Production checkout stays disabled by default. Store cancellation is separate from KeEv account deletion.
