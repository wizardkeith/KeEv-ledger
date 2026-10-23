# Supabase setup

## Done in repository

- Supabase Auth adapter for Apple, Google, and passwordless email OTP.
- Build-time `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` configuration, plus provider public identifiers.
- SDK default token persistence disabled; KeEv platform secure storage is authoritative.
- `supabase/migrations/202609210001_profiles.sql` creates `public.profiles`, enables/forces RLS, and limits select/insert/update to `auth.uid() = id`.
- `supabase/migrations/202609210002_encrypted_backups.sql` creates the private `ledger-backups` bucket, immutable `public.ledger_backups` metadata, and own-user metadata/Storage RLS policies. The object path is `<auth.uid()>/<backup-uuid>.keevbackup`; there is no public-read policy.
- Apple iOS entitlement and Android callback activity are tracked. No service-role/admin secret exists in Flutter source.

Example public build configuration (use environment-specific values; do not commit credential files):

```sh
flutter run --flavor development -t lib/main_development.dart \
  --dart-define=SUPABASE_URL=https://PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=OWNER_SUPPLIED_PUBLISHABLE_KEY \
  --dart-define=GOOGLE_WEB_CLIENT_ID=OWNER_SUPPLIED_WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=OWNER_SUPPLIED_IOS_CLIENT_ID \
  --dart-define=APPLE_SERVICE_ID=OWNER_SUPPLIED_SERVICE_ID \
  --dart-define=APPLE_REDIRECT_URI=https://OWNER_SUPPLIED_CALLBACK
```

Missing/invalid configuration disables cloud actions without blocking Local Only.

## Owner action required

### Organization and projects

- Commercial owner: **KeEv Global Services Limited**.
- Company/legal/billing country or region: **Hong Kong**. Use actual owner-supplied Hong Kong registration, address, tax, telephone, representative, and payment details. Never derive jurisdiction from VPN/IP/device location.
- Create separate development, staging, and production Supabase projects where practical.
- Preferred infrastructure region for all three: **Singapore, AWS ap-southeast-1**. Infrastructure region does not change the Hong Kong company jurisdiction.
- Apply the tracked SQL migration to each project and verify RLS as two distinct test users.
- Apply both migrations in order. Verify cross-user list/download/insert/delete rejection for metadata and Storage, confirm the bucket remains private, and confirm the 64 MiB object limit.

## Phase 6A sync foundation

Apply the Phase 6A migrations in this order after the profile and encrypted-backup migrations:

1. `202609220001_sync_protocol_v1.sql` — canonical `sync_*` tables, revision sequence, change log, receipts, base RPC and private receipt bucket.
2. `202609220002_sync_protocol_v1_hardening.sql` — cloud/local constraints, one-ledger root, timestamp ordering, advisory-lock serialization, post-lock receipt recheck and structured validation failures.
3. `202609220003_sync_protocol_v1_final_parity.sql` — active-only receipt-position uniqueness, receipt path length, supported account opening range, and tombstone timestamp ordering.
4. `202609230001_sync_runtime_v1.sql` — immutable revision snapshots, origin/mutation metadata, deterministic conflict receipts, supported-delete validation, and runtime RPC hardening.
5. `202609230002_sync_runtime_v1_fix_gate.sql` — rejects unsupported receipt-attachment updates while preserving authenticated-only RPC execution and the existing security-definer boundary.
6. `202609230003_sync_onboarding_v1.sql` — dataset generations, explicit discovery, per-user initialization/reset locking, bounded canonical snapshot, generation-gated mutation/pull, and authenticated-only onboarding RPCs.
7. `202609230004_sync_onboarding_v1_fix_gate.sql` — 30-minute server-time initialization leases, same-operation resume, stale-operation takeover, trusted abort, and milestone lease refresh.
8. `202609230005_sync_realtime_and_retention_v1.sql` — private Broadcast invalidation, monotonic device acknowledgements and trusted retention foundation.
9. `202609230006_sync_retention_safety_v1.sql` — generation-scoped acknowledgement reset, durable retained-history floor, history-gap rejection and monotonic pruning-floor advancement.
10. `202609230007_sync_device_lifecycle_safety_v1.sql` — floor/head-bounded device heartbeat acknowledgements and authenticated own-device/generation unlink hardening.

The follow-up migrations are deliberately separate so they are safe whether or not the base migration has already been exported/applied. They repair only pre-activation timestamp ordering before validating permanent constraints. Migration 003 drops the ordinary receipt-position constraint from 002 and replaces it with a partial unique index for `deleted_at IS NULL`; the existing storage-path uniqueness remains. If duplicate active profile roots/receipt positions or invalid transfers already exist, stop and reconcile the test data rather than deleting it silently. Canonical client roles retain SELECT-only access; writes go through `sync_apply_mutation_v1`. The inaccessible inner function is not executable by `PUBLIC`, `anon` or `authenticated` directly.

Before enabling Phase 6B, verify with two test users that cross-user canonical reads, change-log reads, RPC mutations and Storage operations fail. Concurrently submit the same mutation ID and two different create mutation IDs for one entity; verify `APPLIED`/`ALREADY_APPLIED` and `APPLIED`/`CONFLICT`, with one effect only. Verify exact immutable snapshots at successive revisions, stable conflict replay, supported-delete rejection, one profile root per user, receipt-position and transfer parity constraints, timestamp ordering, structured malformed-payload rejection, and stale base-version conflict. Exercise private receipt upload/download/hash/delete using owner test accounts. Do not enable Realtime or bulk-upload existing local books. Commercial owner remains KeEv Global Services Limited, Hong Kong; preferred project region remains Singapore / `ap-southeast-1`. Never place service-role/database credentials in Flutter.

Before releasing Phase 6C-A, apply migrations 006–007 to development/staging first. With two users and two devices verify: read-only discovery; all four empty/local/cloud/both cases; same-operation resume; active-lease rejection; recovery after the 30-minute server-time lease expires; generation rotation rejecting stale-device push/pull; per-user reset isolation; paginated snapshot consistency; private receipt initialization; and Keep Local/Keep Cloud conflicts. `PUBLIC` and `anon` must not execute onboarding/reset/abort RPCs, authenticated clients must not directly write datasets/canonical/change-log/receipt tables, and encrypted `ledger_backups` must survive live-dataset reset. Realtime and automatic lifecycle/background sync were disabled through Phase 6C-A.

For Phase 6C-B, apply migrations 008–010 in staging and verify private Broadcast and two-user topic isolation. The hint payload is limited to event type, generation and newest revision. Device acknowledgements are monotonic within their generation, reset on generation change, heartbeat caught-up empty pulls, and are rejected below the retained floor or above the authoritative head. Online unlink must mark only the current user's matching device/generation unlinked. Maintenance advances `history_floor_revision` only through its safe revision; pull below that floor returns structured reconciliation instead of skipping missing history. Devices seen within **180 days** protect history; mutation receipts retain at least **365 days**; canonical tombstones are retained in v1.

**OWNER ACTION REQUIRED:** review and schedule `sync_prune_safe_history_v1` from trusted Supabase infrastructure only. It has no mobile-role grant and is deliberately not cron-scheduled. Verify two-device concurrency, private receipt transport, generation reset, and best-effort iOS/Android background behavior. KeEv Global Services Limited remains the commercial owner; Hong Kong is the account jurisdiction and Singapore / `ap-southeast-1` remains the preferred project region.

### Apple

- In Apple Developer, enable Sign in with Apple for each real bundle identifier and Xcode target/profile.
- Supply actual Team ID, App/Service IDs, Key ID/private key, domains, and return URL in Supabase Auth's Apple provider settings. None are fabricated or committed here.
- For Android web authentication, deploy the owner-controlled HTTPS callback that safely redirects to the package-specific `signinwithapple://callback` intent. Set `APPLE_SERVICE_ID` and `APPLE_REDIRECT_URI`.
- Validate native iOS name/email first-login behavior and private relay email delivery on real accounts.

### Google

- Create/configure the Google Cloud OAuth consent screen and Android/iOS/Web OAuth clients using actual package IDs, signing SHA fingerprints, iOS bundle IDs, and the iOS reversed-client-ID URL scheme. The scheme cannot be committed until the owner supplies the real Google OAuth client ID.
- Configure Supabase Auth with the owner-supplied Google credentials. Set `GOOGLE_WEB_CLIENT_ID` and `GOOGLE_IOS_CLIENT_ID`; never embed a Google client secret.
- Use Hong Kong where a company/account country or region is requested.

### Email OTP and SMTP

- Configure Supabase email OTP templates to expose the six-digit token, expiry, redirect rules, and appropriate rate limits; test invalid, expired, resend, and account-creation flows.
- Supabase default mail is development/testing infrastructure only. Production release requires a KeEv-controlled sender/domain and production SMTP provider with SPF, DKIM, DMARC, and reviewed limits. Register company/service country as Hong Kong where applicable. Provider selection and purchase remain owner decisions.

### Security

Never put a `service_role`/secret API key, database password, Apple private key, Google client secret, SMTP password, Supabase management token, or administrator credential in Flutter source, assets, Dart defines, logs, or mobile storage. Account deletion must use a trusted authenticated backend/Edge Function, not a client-held admin key.

## Phase 8B-A billing migration

Apply `202609240001_billing_verification_v1.sql` after the Phase 6 migrations. Deploy `verify-purchase` and `refresh-entitlements` with JWT verification enabled. Set server secrets from `supabase/functions/.env.example`; never put the service role, Apple private key or Play service-account JSON in Flutter. Verify two-user entitlement isolation and denial of client writes/privileged billing RPC execution. Staging Apple Sandbox/Play license-test verification, Apple library Deno compatibility, private token storage and acknowledgement must be exercised before any production checkout. Preferred project region Singapore; KeEv Global Services Limited company country Hong Kong.

## Phase 8B-B provider lifecycle

Apply `202609240002_billing_notifications_v1.sql` **after** `202609240001_billing_verification_v1.sql`. Deploy `apple-store-notifications`, `google-play-rtdn` and `billing-reconcile`; only these external/internal endpoints have `verify_jwt=false` in `config.toml`. Apple authenticates through verified V2 JWS, Google through verified Pub/Sub OIDC, and reconciliation through a separate long random server secret. `verify-purchase` and `refresh-entitlements` remain user-JWT functions. Set `BILLING_PUBSUB_AUDIENCE`, `BILLING_PUBSUB_PUSH_SERVICE_ACCOUNT`, `BILLING_RECONCILE_SECRET` as server secrets; never place privileged material in Flutter. Configure a trusted hourly scheduler with the reconciliation secret, and test event leases, one-account binding, RLS, bounded claims and old-observation rejection on staging Postgres. No production deletion job for provider events is installed. Live Edge import and store sandbox tests are required before checkout opt-in.

## Phase 9 account deletion

Apply `202609240003_account_deletion_v1.sql` after billing notifications. Deploy `delete-account` with `verify_jwt=true`, `SUPABASE_SERVICE_ROLE_KEY` available only to Edge, and the same project Auth settings. The handler derives the user from `auth.getUser(jwt)` and requires recent `last_sign_in_at`; no client user ID/path is accepted. It lists/removes only the caller's UUID prefix in `ledger-backups` and `ledger-sync-receipts`, writes private anti-replay tombstones and then calls admin Auth deletion. Partial failures remain retryable. The deletion job blocks stale JWT Storage uploads. Test Account A/B, repeated invocation, storage failure, billing binding and Auth cascade in staging; verify no other bucket or user object is touched. Configure separate server-only `APPLE_SIGNIN_TEAM_ID`, `APPLE_SIGNIN_KEY_ID`, `APPLE_SIGNIN_PRIVATE_KEY`, `APPLE_SIGNIN_ALLOWED_CLIENT_IDS` (native bundle ID and Android/web Services ID if used), and `APPLE_SIGNIN_REDIRECT_URIS_JSON` mapping Services IDs to registered HTTPS redirect URIs. Do not confuse the Sign in key with the IAP key. Apple-linked deletion requires fresh Apple reauthorization and server token exchange/revocation before cleanup; a cancelled/failed operation makes no destructive change. Live Apple Sandbox deletion, provider backup retention and tombstone/job legal retention need owner acceptance before release. The Flutter app preserves its local ledger and unlinks sync after success.
