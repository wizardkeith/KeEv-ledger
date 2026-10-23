# Phase 5B checkpoint — Supabase authentication + backend integration

**PASS — REPOSITORY IMPLEMENTATION COMPLETE** — live provider/backend and native-device verification remains separately pending owner configuration.

## Owner-review fix gate

- **PASS** — Google Sign-In now obtains both the ID token and OAuth access token through the `google_sign_in` 7.2.0 `authorizationClient` flow, with silent authorization followed by interactive authorization when required. Only `openid` and `email` identity scopes are requested; both tokens reach the Supabase API adapter.
- **PASS** — missing/failed access-token acquisition cannot report authentication success; Google cancellation retains its typed cancellation result.
- **PASS** — the account card displays Local Only only for `AccountSessionState.localOnly`; all signed-out/authenticating/authenticated/reauthentication/temporary-unavailable states use the localized Cloud Account heading.
- Focused Google/account/UI verification: **PASS — 21 tests**. Final `flutter analyze`: **PASS — no issues**.
- Real Google sign-in remains **NOT VERIFIED** pending owner Google Cloud OAuth configuration, the iOS reversed-client-ID URL scheme, and Android/iOS device testing. Phase 5C was **NOT STARTED**.

## Completed

- Backend selected: **Supabase** (`supabase_flutter` **2.17.2**). Legal/commercial owner jurisdiction: **KeEv Global Services Limited, Hong Kong**. Preferred project region: **Singapore, AWS ap-southeast-1**.
- Provider-neutral Supabase gateway implements Apple (`sign_in_with_apple` 8.2.0), Google (`google_sign_in` 7.2.0), passwordless email OTP, restore, refresh/rotation and sign-out.
- SDK persistence uses `persistSession: false`, `EmptyLocalStorage`, disabled auto-refresh and no-op PKCE storage. `FlutterSecureSessionStore` / `keev.cloud_session.v1` is the sole persisted token source; SharedPreferences is **not** authoritative token storage. App Lock remains independent at `keev.local_app_lock.v1`.
- Permanent expired/unauthorized refresh clears memory and secure credentials; temporary network/backend failures preserve recoverable credentials and expose a distinct UI state.
- `public.profiles` SQL migration with auth-user UUID ownership, forced RLS and own-row SELECT/INSERT/UPDATE policies: `supabase/migrations/202609210001_profiles.sql`.
- Typed Dart-define configuration supports separate development/staging/production projects; absent configuration keeps Local Only fully usable. Apple entitlement/Android callback and five-locale account/OTP UI are tracked.
- Drift schema remains **v5**; no local database migration was required.

## Verification

| Check | Result |
|---|---|
| `flutter pub get` | **PASS** |
| `flutter gen-l10n` | **PASS** |
| Dart format check | **PASS** — 109 files, 0 changed on final check |
| Focused Phase 5B/account/App Lock/localization/widget suite | **PASS** — 51 tests |
| Added secure-persistence regression suite rerun | **PASS** — 8 tests |
| `flutter analyze` | **PASS** — no issues |
| Android native provider/build verification | **BLOCKED** — Android SDK/device unavailable |
| iOS native provider/build verification | **NOT VERIFIED** — Linux host; requires macOS/Xcode/device or simulator |

## Owner action / deferred

Configure real Supabase projects, apply/verify SQL/RLS, configure Apple/Google identities and callbacks, configure/test email OTP and production SMTP, and implement trusted account deletion/revocation. No fabricated credentials were added.

Cloud Backup upload/restore is **NOT IMPLEMENTED** (Phase 5C). Phase 6 bookkeeping synchronization/realtime/queues/conflict handling is **NOT IMPLEMENTED**. Billing/subscriptions are **NOT IMPLEMENTED**.
