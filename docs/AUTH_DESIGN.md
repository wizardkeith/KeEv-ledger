# Authentication and app lock

Phase 5B selects Supabase Auth while Local Only remains identity-free. Money account names and Phase 4C App Lock are distinct from KeEv cloud identity. Repository-side Apple, Google and email OTP integration exists; actual provider credentials, Supabase projects and production SMTP remain owner configuration. See `SUPABASE_SETUP.md`.

## Email OTP

Passwordless signup and login. POST challenge endpoint responds generically and comparably for existing/new addresses. Validate email syntax and normalized delivery address; avoid provider-specific dot/plus rewriting. Generate CSPRNG six-digit code; protect it with keyed server HMAC plus challenge/email binding and constant-time compare. Keep secret pepper in server secret manager; no code in logs/responses/client bundle.

The client applies a 60-second resend cooldown and six-digit input validation. OTP expiry, attempts, rate limiting, generic responses and account creation remain authoritative in Supabase Auth configuration. Production SMTP/domain setup and provider-side abuse tests are owner release actions; no preview OTP fallback exists in the app.

Sessions: short-lived access token, rotating refresh token family, replay revocation, per-device registration/revocation. Store refresh token in Keychain/Keystore-backed storage; server stores protected refresh credentials. Token checks issuer/audience/expiry/signature. Sign-out revokes current device; Delete Account revokes all.

## Apple / Google

Platform-supported sign-in/browser authorization, with nonce/state/PKCE where the provider flow requires it. Backend validates tokens/signatures/audience and exchanges authorization code server-side where required. No privileged OAuth secret in mobile. Provider subject is identity key. Never auto-link only because email matches; require proof of existing account and new provider. Handle Apple relay email and first-sign-in-only profile fields. Account deletion requires recent KeEv auth plus a fresh Apple native authorization for every linked Apple identity, even on multi-provider accounts. The trusted deletion endpoint validates Apple JWKS signature/issuer/audience/expiry/nonce and linked provider subject, verifies the token exchange subject, then revokes Apple authorization before cloud cleanup and Auth deletion. Cancel/failure leaves the cloud account intact.

Required owner configuration at Phase 5: Apple team/app ID, service ID and server signing key via secret manager if needed; Google iOS/Android/web clients, signing certificate fingerprints, verified redirect domains; backend origin and email domain sender verification. Public client IDs are configuration, private keys never pasted in source or chat.

## Local lock

Use OS Face ID/Touch ID/Android biometric API and retain no biometric templates. 4–6 digit PIN verifier in secure storage; vetted slow KDF with protected secret and persistent bounded retry state. Escalating delays after failed attempts, no automatic destructive wipe. Short PIN is convenience protection, not backup encryption or complete protection against rooted devices.

Lock on cold start and lifecycle timeout; cover task-switcher snapshot and receipt views when backgrounded. Protected changes (disable/reset lock, change PIN, enable biometric) require current unlock proof. Key invalidation or biometric enrollment change returns to PIN/recovery. Device lock credentials excluded from backups and re-enrolled on migration. Forgotten PIN: explain protected local recovery limits; authenticated cloud restore can recover cloud book after explicit local reset, but must not silently unlock unrelated local-only data.

## Account deletion

In-app Settings→KeEv Account→Delete Account plus public web initiation route. Explain cloud records/receipts/backups/identity removal, local retain/delete choice, inability to cancel store subscription by deletion alone, and approved retention timeframe. Recent reauth; idempotent request receipt and visible pending/completed state. Worker removes object storage, database records, identity links and provider tokens; purge residual processor/backups on disclosed schedule, retain only justified records. Reject offline stale sync after deletion. Security tests cover unauthorized deletion, account switching, repeated requests and race with attachment upload.
