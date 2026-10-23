# Security review and implementation gates

Phase 7 isolates advertising behind `AdsController`, UMP and an allow-listed
placement policy. Widgets cannot initialize the SDK or bypass consent,
entitlement, App Lock, online and surface gates. The only initial placement is
the Reports footer; authentication, App Lock, backup/restore, receipt,
sync/reconciliation/conflict and destructive flows are denied. Advertising
interfaces accept placement/state only—never bookkeeping entities or payloads.
Production IDs are build configuration, absent IDs fail closed, and
development/staging use Google's official test units. ATT is a separate native
system-status boundary and is never requested automatically. Advertising
state is not part of Drift, sync or portable backups. Do not log consent
strings, IDFA, ad identifiers or financial context.

Phase 0 source review is complete at the scope described in PROTOTYPE_AUDIT.md. Production security validation is **not complete**.

Phase 6C-B private Broadcast is invalidation-only and owner/generation scoped; its payload has no financial content. Device acknowledgement is monotonic, generation-scoped and owned by `auth.uid()`. Trusted retention maintenance has no mobile-role execute grant. Realtime/background failure cannot bypass durable push/pull, and no service-role credential is included in Flutter.

| Threat | Required control | Evidence before release |
|---|---|---|
| Cross-user record/object access | Token-derived owner, every nested reference checked, private object storage, short-lived scoped upload/download grants | Two-user adversarial API suite and object-access checks |
| Forged purchase | Store verification, signed notifications, unique original transaction ownership, revocation | Store sandbox + replay/refund/restore tests |
| Offline data loss | SQLite atomic entity/outbox, WAL/recovery, staged files, no silent empty fallback | Crash/full-disk/concurrent-save/migration fault injection |
| Sync overwrite | Conditional versions, idempotency, tombstones, dirty-record conflict | Two-device/offline deterministic tests |
| OTP abuse | CSPRNG, protected codes, atomic attempts, email/IP/device/global limits | Expiry/resend/race/enumeration test suite |
| Credential extraction | Secure storage, no secrets in repo/mobile, environment separation, revoke/rotate | Secret scan and release binary/config inspection |
| Malicious restore | Authenticated encryption, parameter bounds, path/size checks, strict schemas, staging | Fuzz/malformed/wrong-key/future-version corpus |
| Receipt privacy | Private file store, EXIF stripping, encrypted transport, no analytics content | Metadata inspection and network capture |
| CSV/HTML injection | Formula neutralization including leading whitespace/control prefixes, complete CSV quoting, native renderer | Formula/quote/newline fixtures |
| Sensitive logging | Allowlisted diagnostics only, errors coded, scrub crash stack metadata/breadcrumbs | Capture all failure paths and inspect logs |
| Lost phone | OS data protection, app lock, secure secrets, backup choices | Native lifecycle/lock tests; disclose rooted-device limits |
| Account deletion race | Disable sync/token family; deletion job idempotency and object cleanup | Stale device cannot recreate erased data |

No tokens, OTPs, transaction payloads, merchant/note, receipts, keys or full export content may enter logs. Diagnostics use event type, safe error code and coarse timing only. Optional analytics remain disabled until data map and consent reviewed. Never emit raw backend exception to user.

Transport HTTPS only in all environments. Development may use an isolated HTTPS service; no global trust-all TLS override. Missing cloud configuration disables optional cloud actions but must not block Local Only startup. Public Supabase URL/publishable key and OAuth client IDs may use environment-specific Dart defines; privileged secrets remain in owner/provider secret management and never in the app. Dependency review includes publisher, licence and lockfile; this checkpoint is not an independent SCA audit.

SQLite relies on OS sandbox/data protection unless separately encrypted and verified. Prevent implicit financial DB/receipt/secret leakage through Android Auto Backup or iOS backup defaults; configure exclusions deliberately and disclose any supported OS backup. Portable encrypted backup remains explicit user action.

Phase 5C portable backups use Argon2id (19,456 KiB, two iterations, parallelism one) and AES-256-GCM with fresh salt/nonce and authenticated headers. The hostile parser caps the final encrypted container at 64 MiB, reserves header/tag overhead before accepting plaintext, limits expanded data/entry count, rejects traversal/symlinks/duplicates/unexpected entries, and validates references and receipt hashes. Restore stages new receipts and verifies a complete safety copy before live mutation; rollback failure preserves the safety copy. The passphrase is not recoverable or stored. Supabase receives ciphertext plus minimal metadata only.

Phase 6 live sync is distinct from encrypted backup. Synced rows and immutable historical change snapshots are protected in transit by TLS and at access by Supabase Auth, own-user RLS, explicit least-privilege grants and private receipt Storage; they are not backup-passphrase E2EE. Canonical writes have no direct mobile-table grant and must use the allow-listed security-definer mutation RPC with authenticated ownership, fixed fully-qualified tables, optimistic versions, idempotency receipts and a server sequence. PUBLIC/anon cannot execute it. Private receipt bytes are size/hash verified on upload/download. Client time is never concurrency authority, and no financial payload, conflict content, receipt bytes or secret may be logged.

Phase 6C-A adds an opaque dataset generation to every push/pull. Trusted initialization/reset functions derive ownership from `auth.uid()`, serialize one user's initialization with a transaction advisory lock, use an empty search path, and deny `PUBLIC`/`anon`. A 30-minute server-time lease prevents active-operation theft while allowing authenticated per-user recovery after expiry; same-operation resume and trusted abort never accept a client-supplied owner. Generation rotation prevents stale devices and old outboxes from writing after Keep Local replaces cloud state. The mobile role retains no direct reset/canonical/change-log write privilege and contains no service-role credential. Pause retains capture for the same generation; unlink drops the association without deleting either ledger. Live two-user and stale-device verification remains an owner release gate.

Unresolved release gates: native secure storage/biometric integration, independent Supabase RLS adversarial review, native file-picker verification, privacy/retention approval, dependency audit and store billing validation. No certification asserted.

## Phase 8A purchase boundary
Store callbacks and local entitlement cache are not trusted permanent purchase proof. A trusted server verifier exists, while checkout defaults disabled until live store acceptance. Purchase tokens/JWS are stored in device secure storage for idempotent retries, excluded from ledger backups/sync, and never logged. The account binding is an opaque account UUID; the server enforces ownership before granting ad-free. No Apple API key, Google service account or Supabase service_role is shipped in Flutter.

## Phase 8B-A purchase boundary

Billing Edge Functions verify the caller's Supabase JWT and fetch store state with server-only secrets. Google tokens are stored only in `billing_private`, while authenticated users may SELECT their own sanitized entitlement and cannot mutate it. Apple signed data is checked against Apple-rooted certificate validation by the official library. Store identity binding is immutable under SQL locks. Native Apple library execution on the Supabase Deno runtime remains an explicit deployment gate; failure must prevent grant.

## Phase 8B-B asynchronous billing

External webhooks have platform JWT verification disabled only on their own routes. Apple V2 outer/nested signatures are checked with the root-anchored official verifier; authenticated Google Pub/Sub push is checked with Google JWKS, exact audience and service-account identity before reading RTDN. Bounded requests, private deduplicated event IDs, stale leases and current-store reconciliation prevent notification type or arrival order from minting Premium. The server-only periodic worker uses a distinct long random secret. Old purchase commit RPC access is retired in favor of observation-ordered v2 under per-account locking. Never log provider JWS, purchase tokens, OIDC bearer tokens or keys. Live Edge/runtime, SQL privileges and store sandbox tests remain release gates.

## Phase 9 deletion and device storage

Android generic OS cloud/device-transfer backup is disabled for the whole app because device-specific secure session/App Lock material, sync identity and unencrypted local SQLite must not be silently migrated; explicit passphrase-encrypted `.keevbackup` remains portable. iOS file protection and iCloud backup inclusions require native QA. The `delete-account` function verifies the JWT and recent sign-in, derives `user.id` server-side, deletes only two allow-listed user UUID Storage prefixes, atomically minimizes billing sources to private unlinked anti-replay fingerprints, then deletes the Auth user last. A server-only deletion job prevents stale JWTs from uploading new backup/receipt objects. Failures return retryable status; on success the app preserves the local ledger and unlinks sync. Apple-linked deletion requires a fresh native code and nonce; Edge verifies the Apple identity JWT against Apple JWKS, exact audience and linked Supabase provider subject, exchanges the code, verifies the exchanged identity, then revokes at Apple before any cloud cleanup. Server-only signing credentials never enter Flutter. Live Sandbox acceptance and final legal retention approval remain release blockers. No caller-provided user ID or path is accepted. Release builds omit unconfigured legal links and checkout remains default-disabled. Secret/static scans cannot replace deployed access tests.
