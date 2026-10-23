# Monetization — Phase 8A

The free app retains transaction entry/editing, accounts, categories, local reports, App Lock, local encrypted backups and Local Only. Phase 7 permits one consent-gated Reports footer ad. Premium currently maps only to `adFree`; no ledger capability is paywalled.

The official `in_app_purchase: 3.3.1` gateway loads owner-configured product IDs via `PREMIUM_PRODUCT_IDS` and shows prices and descriptions supplied by the storefront. No product ID, price, free trial or period is hard-coded. One startup purchase observer journals opaque verification material in secure device storage; restore follows the same verification boundary. A 48-hour, expiration-bounded cache of previously verified entitlement is scoped to the original account and device; it is not permanent authority. The Phase 8B trusted verifier is implemented; purchase initiation defaults disabled until the owner completes live store acceptance. The `adsAllowed` seam reacts immediately to a verified `adFree` capability. No billing state enters the ledger, live sync or `.keevbackup`.

App Store / Play subscription management remains in the stores. Deleting a KeEv account does not cancel a store subscription. The owner must supply Terms and Privacy URLs and complete store disclosures before paid checkout is enabled. Phase 8B handles backend verification, renewal, grace, revocation, refunds and cross-device entitlement refresh; live acceptance remains pending. No store secret is embedded in Flutter.

## Phase 8B-A backend

Trusted store verification is now isolated in Supabase Edge Functions and server-only billing RPCs. The server derives effective Premium and adFree from validated Apple/Play sources; client callbacks and cache cannot mint Premium. Production checkout defaults disabled until store acceptance; 8B-B lifecycle notifications are implemented.

## Phase 8B-B release gate

Apple Notifications V2 and authenticated Google RTDN now trigger current-store reconciliation; an hourly, bounded trusted worker repairs missed events and retries Play acknowledgement. Server `premium`/`adFree` remains authoritative across multiple store sources. `PURCHASES_ENABLED` defaults to false and requires Supabase configuration plus configured product IDs; checkout must only be opted in after owner store/native acceptance. Free Local Only and all core bookkeeping remain usable. Account deletion does not cancel App Store/Play billing.
