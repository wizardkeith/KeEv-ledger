# KeEv Ledger data inventory — Phase 9

Classification: **S** sensitive personal/financial; **P** personal; **I** internal; **A** authentication secret; **C** cryptographic secret; **X** server-only secret. Local Only means no Supabase ledger upload. “Cloud” below requires the relevant opt-in. This inventory describes the repository, not an assertion about production processor configuration.

| Data | Class | Device location | Remote / recipient | Export / deletion |
|---|---|---|---|---|
| Profile, accounts, categories, transactions, transfers, projects, budgets, currency/FX, notes | S | Drift SQLite, app sandbox; SQLite is plaintext | Supabase Postgres when live sync enabled; TLS/RLS, **not E2EE** | Encrypted `.keevbackup`; current local ledger retained after cloud-account deletion |
| Receipt metadata, processed JPEG | S | Drift and app-private support files; temporary staging/safety files during restore | Private Supabase Storage JPEG if live receipt sync enabled; encrypted ciphertext if cloud backup enabled | Exported inside `.keevbackup`; cloud copies removed on account deletion; user-selected external copies outside KeEv control |
| Voice audio/transcript | S | OS recognition session / in-memory draft; KeEv does not persist raw audio | OS speech service may process it; depends on platform | Discarded at session end |
| Email, provider identity, Supabase UUID | P | Namespaced secure session record | Supabase Auth, Apple/Google provider where chosen | Auth identity removed after cloud cleanup; provider retains its own records |
| Fresh Apple deletion authorization code, identity token, nonce; exchanged Apple token | A | Ephemeral native memory only; returned Apple token server memory only | Authenticated delete-account Edge and Apple `/auth/token`/`/auth/revoke` | Not logged/persisted/exported; discarded after operation; failure leaves cloud account intact |
| Access/refresh tokens | A | `flutter_secure_storage` and memory; Supabase SDK plaintext persistence disabled | Supabase Auth | Clear on successful deletion/sign-out; never backup/export |
| Sync device ID, generation, revisions, outbox, conflicts, mutation receipts | I/P; S when payload present | Drift plus private receipt spool | Supabase Postgres/Storage on sync opt-in | Never in `.keevbackup`; cloud rows cascade with Auth deletion; local sync unlinked after success |
| Backup salt, nonce, encrypted container | I/C for ephemeral derived key | Temporary app-private file; user-chosen external encrypted export | Optional encrypted object in private Storage | App temporary file deleted after flow; external copy user-controlled |
| Backup passphrase and derived key | C | Transient memory only | Never sent to KeEv/Supabase | Never saved; cannot be recovered |
| App Lock salted verifier, throttle state, biometric preference | A/P | Secure storage; platform biometric templates stay in OS | None | Never in `.keevbackup`; local state survives cloud account deletion |
| UMP consent, ATT authorization, Mobile Ads signals | P | UMP SDK cache, OS ATT state | Google ads/consent services only when configured/gated | Not in ledger, sync or backup; SDK/OS privacy controls |
| Store product, transaction identity, purchase journal, entitlement cache | P/A for proof | Secure storage, not Drift/backup | Apple/Google store; verified server state | Client cache bound to account; store cancellation separate from account deletion |
| Play purchase token, Apple JWS, billing source, provider event | P/X for private proof | Never ordinary device ledger storage | Private Edge environment/private Postgres; signed data transient except token needed for refresh | Deletion removes source and raw token; private unlinked identity fingerprint tombstone remains pending legal retention review |
| Service-role, Apple IAP key, Google service-account key, Pub/Sub secret | X | **Never Flutter/assets/preferences** | Supabase Edge secrets only | Rotated/managed by owner; no values in repository |

OS logs: application code has no direct financial/secret logging calls; native SDK/OS diagnostics and server infrastructure must be checked in release network/log review. Encrypted backup differs from cloud-readable live sync. Android generic OS backup is disabled; iOS device-backup and file-protection behavior need native inspection. The owner controls any user-created export outside the app.
