# Local app lock

Phase 4C adds an optional local access gate. Unlocking KeEv Ledger with a PIN or an operating-system biometric proves only that the local app may be opened; it is not KeEv cloud identity, account reauthentication, purchase entitlement, or authorization for a future server operation.

## Credential and biometric design

- PINs are restricted to 4–6 ASCII digits and require confirmation. The raw PIN is never stored or logged.
- The verifier record is version 1: PBKDF2-HMAC-SHA-256, 210,000 iterations, a cryptographically random 16-byte salt, and a 32-byte derived verifier. Verification uses a length-checked constant-time byte comparison. The version, algorithm and parameters allow later migration.
- One encoded record containing the salt, verifier, biometric preference and retry state is held under `keev.local_app_lock.v1` by `flutter_secure_storage`. It is not stored in Drift, preferences, CSV, receipts or bookkeeping exports. On iOS the package uses Keychain; on Android it uses its platform secure-storage implementation. Hardware backing is not asserted for every device.
- `local_auth` asks the OS to perform biometric matching with `biometricOnly: true`. KeEv never receives or stores face/fingerprint templates. Unavailable, unenrolled, cancelled, failed and locked-out results keep the app locked and leave PIN available.
- Enabling, changing or disabling protection requires the configured PIN. Credential replacement is a single secure-store write; a failed write leaves the in-memory and previously stored verifier unchanged. Disabling removes only the lock record after authentication and never deletes bookkeeping data.

Missing, corrupt or unreadable secure configuration does not grant access: an unreadable/corrupt record enters a fail-closed configuration-error state. A genuinely absent record means the optional lock has never been enabled. There is no insecure forgotten-PIN bypass and no claimed cloud recovery in Local Only mode.

## Retry, lifecycle and privacy

Failed counts and UTC throttle expiry are stored with the secure record, so navigation or widget rebuilds do not reset them. The third failure waits 5 seconds, the fourth 15 seconds, and the fifth and later failures 60 seconds. A successful PIN or biometric unlock resets the retry state. The injected `Clock` makes expiry deterministic in tests.

When enabled, startup renders the opaque lock gate before application routes are exposed. Moving to `paused`, `hidden` or `detached` locks immediately. `inactive`/background lifecycle states activate an opaque branded privacy cover without financial content; this is best-effort app-switcher privacy, not guaranteed screenshot prevention. Generation tokens invalidate results from cancelled or earlier authentication sessions, and only one biometric prompt may run at a time.

## Native configuration and verification

Android declares `USE_BIOMETRIC`, uses `FlutterFragmentActivity`, and uses an AppCompat launch/application theme as required by `local_auth`. iOS declares `NSFaceIDUsageDescription` and a Runner keychain-access-group entitlement. Permissions/prompts are reached only through deliberate lock setup/unlock actions.

Automated tests use fake secure-store/biometric adapters and verify controller, race, throttle and UI lifecycle behavior. Real Keychain, Android secure storage/Keystore behavior, Face ID, Touch ID, Android biometrics and OS app-switcher capture remain native-device verification items.
