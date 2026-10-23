# Phase 4C checkpoint — PIN, biometrics and local app lock

## Completed scope

- **PASS** — Optional 4–6 digit PIN setup/confirmation, unlock, authenticated change/disable, PIN fallback and Lock Now are integrated without changing Local Only or bookkeeping identity.
- **PASS** — Versioned verifier uses PBKDF2-HMAC-SHA-256, 210,000 iterations, random 16-byte salt and 32-byte output; raw PIN is never stored. Constant-time verifier comparison is used.
- **PASS** — `flutter_secure_storage` holds the verifier, salt, biometric preference and persistent retry state outside Drift/preferences/export. Missing/corrupt/unreadable configuration never grants access.
- **PASS** — `local_auth` provides OS-owned biometric capability/authentication through a package-neutral adapter with `biometricOnly: true`; KeEv never receives biometric templates. PIN remains the fallback.
- **PASS** — Failed PIN attempts persist and throttle at 5 seconds after attempt 3, 15 seconds after attempt 4, and 60 seconds after attempt 5 onward. Success resets the state; fake-Clock tests cover expiry.
- **PASS** — Lock-enabled startup is gated; paused/hidden/detached lifecycle states immediately re-lock. Inactive/background state displays an opaque, non-financial privacy cover. Generation guards reject stale authentication results and prevent simultaneous biometric prompts.
- **PASS** — Settings expose setup, change, biometric preference, Lock Now and authenticated disable. Forgotten PIN has guidance but no bypass or destructive automatic reset.
- **PASS** — New strings are generated for zh-HK, zh-CN, en, ja and th. Existing bookkeeping, receipt and voice paths remain unchanged.

## Dependencies and native configuration

| Dependency | Version | Purpose |
|---|---:|---|
| `flutter_secure_storage` | 11.2.0 | Platform-backed local lock record |
| `local_auth` | 3.0.2 | OS biometric capability and prompt |
| `cryptography` | 2.9.0 | PBKDF2-HMAC-SHA-256 and secure salt |

Android adds `USE_BIOMETRIC`, `FlutterFragmentActivity` and AppCompat themes. iOS adds `NSFaceIDUsageDescription` and a Runner keychain-access-group entitlement. Drift schema remains **v5**; no database migration was necessary.

## Quality gate

| Check | Result |
|---|---|
| `flutter pub get` | **PASS** |
| `flutter gen-l10n` | **PASS** — five commercial locales plus zh fallback |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** — 93 files, 0 changed |
| `flutter analyze` | **PASS** — no issues |
| `flutter test` | **PASS** — 126 tests |
| PIN/KDF/throttle/secure-store/biometric/race/lifecycle adapter tests | **PASS** |
| Android native secure storage/biometric/app-switcher verification | **BLOCKED** — Android SDK/device unavailable |
| iOS Keychain/Face ID/Touch ID/app-switcher verification | **NOT VERIFIED** — Linux host; requires macOS/Xcode/device or simulator |

## Deferred / limitations

Real native Keychain/Android secure-storage behavior, biometric dialogs/hardware changes and OS snapshot timing require device verification; automated adapter tests are not equivalent. The privacy cover is best-effort and not claimed as screenshot prevention. Local forgotten-PIN recovery has no insecure bypass; future verified cloud identity/recovery remains deferred. No cloud authentication, sync, billing, ads or analytics was added. There is no source/test blocker. **STOP after Phase 4C.**
