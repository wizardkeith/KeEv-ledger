# Phase 1 environments

The original Phase 0 proposal is preserved under `phase_0/ENVIRONMENTS.md`. Its three-environment direction is unchanged.

| Environment | Native identifier | Display name | Dart entry |
|---|---|---|---|
| development | com.keev.ledger.dev | KeEv Ledger Dev | lib/main_development.dart |
| staging | com.keev.ledger.staging | KeEv Ledger Staging | lib/main_staging.dart |
| production | com.keev.ledger | KeEv Ledger | lib/main_production.dart |

These are provisional local build identifiers; none was registered with a store. Android uses the `environment` flavor dimension and suffixes. iOS has shared development/staging/production schemes and corresponding Debug/Release/Profile configurations using Flutter's generated base xcconfigs. The original Runner scheme defaults to development. iOS build settings include FLUTTER_TARGET and display name. Native flavor and Dart entry point are checked for consistency at bootstrap; a mismatch is a developer configuration error, not a fallback to production.

Phase 5B adds optional typed Supabase configuration through `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`, `APPLE_SERVICE_ID`, and `APPLE_REDIRECT_URI` Dart defines. Each native environment must point to its own Supabase project. Missing or malformed configuration disables cloud actions without blocking startup or Local Only. Public URLs, publishable keys and OAuth client IDs are not privileged secrets, but configuration remains centralized and environment-specific. Service-role/secret keys, database passwords, provider client secrets and private keys must never enter Dart defines, app assets or source control.

KeEv Global Services Limited's legal/account country is **Hong Kong**. The preferred Supabase infrastructure region is separately **Singapore (AWS ap-southeast-1)** for development, staging and production. VPN/IP location is irrelevant to both decisions.

```sh
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter build apk --debug --flavor development -t lib/main_development.dart
# Requires a configured Android SDK; release signing is intentionally absent:
flutter build appbundle --release --flavor production -t lib/main_production.dart
# macOS/Xcode only; does not create a signed store archive:
flutter build ios --no-codesign --flavor development -t lib/main_development.dart
```

The generated Android debug-signing fallback was removed from the release configuration. A debug APK is never production-signed. Phase 1 remains visibly a development preview even when selecting a production build configuration; it is not for submission. Android build is BLOCKED locally by the missing SDK; iOS configurations received static structural checks only.
