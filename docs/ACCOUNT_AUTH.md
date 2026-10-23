# Account and authentication

Phase 5B selects Supabase Auth/Postgres while preserving provider-neutral domain/application contracts. `AccountController` remains the single state source: `localOnly`, `signedOut`, `authenticating`, `authenticated`, `requiresReauthentication`, or `temporarilyUnavailable`. Local Only is the fresh-install default and never requires network or sign-in.

## Providers and sessions

`SupabaseAuthenticationGateway` supports native Apple and Google identity-token exchange plus passwordless email OTP. Supabase user UUID maps to `CloudAccount.id`; email is not a primary key. Raw OTP and provider identity tokens are never logged or persisted by KeEv. Apple-linked account deletion obtains a fresh native authorization code and nonce only after explicit Delete Account confirmation. The authenticated Edge endpoint verifies Apple JWKS identity and the linked provider subject, exchanges the code, verifies the exchanged token subject and calls Apple `/auth/revoke` before cloud cleanup. Tokens and signing key remain transient/server-only; cancellation or failure leaves the account intact. Non-Apple accounts do not prompt Apple.

The SDK is initialized with `persistSession: false`, `autoRefreshToken: false`, `EmptyLocalStorage`, and a no-op PKCE store. Therefore Supabase's SharedPreferences persistence is not authoritative or used. `FlutterSecureSessionStore` is the one persisted cloud-session source under `keev.cloud_session.v1`, separate from App Lock's `keev.local_app_lock.v1`. Rotated access/refresh credentials replace the secure record; permanently expired/revoked credentials are cleared, while temporary network/backend failures preserve the recoverable secure record.

Sign-out attempts the provider/Supabase local sign-out, always clears KeEv cloud credentials through the controller, and leaves the local ledger, receipts, preferences, and App Lock intact. Account deletion is a trusted Edge Function/API contract for later implementation; no service-role credential is present in the app.

## Backend boundary

`SupabaseBackendApi` implements session validation and the minimal `public.profiles` read/update boundary. Backup contracts remain deliberately unavailable until Phase 5C. No bookkeeping table, Realtime listener, synchronization queue, conflict resolution, or Phase 6 data path is present.

Cloud backup is not active in Phase 5B; authentication does not upload local bookkeeping data.
