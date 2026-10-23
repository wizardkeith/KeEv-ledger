# Android release-candidate build procedure

The application ID `com.keev.ledger` and `0.1.0+1` are **provisional** until the owner confirms the first Play app. The production package ID becomes the update lineage after publication. Development/staging suffixes are separate apps. Company/developer/payments country: **Hong Kong**, irrespective of VPN/IP. Keep `PURCHASES_ENABLED=false` until live internal-test acceptance.

## Toolchain and source gate

Use a stable Flutter SDK with Dart ≥3.13.4, JDK 17, Android SDK platform 36 and build tools, and the checked-in Gradle 9.3.1 wrapper/AGP 9.1.0/Kotlin 2.4.0. AGP 9 uses the checked-in Flutter legacy-DSL/Kotlin compatibility flags; the app explicitly applies the legacy Kotlin Android plugin before Flutter. Verify this exact combination with the installed Flutter SDK. Flutter regenerates plugin registration and `.flutter-plugins-dependencies` after `flutter pub get`; neither generated file is authoritative source. `android/local.properties` is generated locally by Flutter and must point to the installed SDK; it is not exported as a release setting.

```sh
flutter --version
dart --version
java -version
flutter doctor -v
flutter pub get
flutter pub deps | grep -E 'in_app_purchase|google_mobile_ads'
flutter test
flutter analyze
python3 tools/phase11_android_rc_checks.py
flutter build appbundle --release --flavor production -t lib/main_production.dart \
  --dart-define-from-file=release.production.example.json
```

The example define file is only a **template**: copy it to ignored `release.production.json` or a protected CI path, update the command path, fill owner-approved public client settings, and keep `PURCHASES_ENABLED=false` for RC. Supabase publishable key and OAuth IDs are public client configuration; service-role, Apple private keys, Play service accounts and signing passwords are server/private CI secrets. Optional cloud/ads missing configuration must fail closed without blocking Local Only. A missing AdMob production App ID must not enable ads; the native Google sample fallback prevents SDK initialization failures while Dart disables live requests. Never run live ads using the sample app ID.

For a signed upload AAB, owner supplies `KEEV_UPLOAD_STORE_FILE` (absolute local path), `KEEV_UPLOAD_STORE_PASSWORD`, `KEEV_UPLOAD_KEY_ALIAS`, and `KEEV_UPLOAD_KEY_PASSWORD` as protected CI environment variables. All four must be set; a partial set fails configuration. Without them, the release build is **unsigned**, unsuitable for Play upload. Never commit the keystore, passwords, `key.properties`, or real define files. Enroll in Play App Signing and use a separate upload key. Use the Play **app-signing** certificate SHA-1/SHA-256 for Google OAuth/API provider fingerprints; the upload key certificate is distinct. Preserve a recovery process for the upload key.

## Inspect the built candidate

```sh
./android/gradlew -p android :app:dependencies --configuration productionReleaseRuntimeClasspath
./android/gradlew -p android :app:lintProductionRelease
sha256sum build/app/outputs/bundle/productionRelease/app-production-release.aab
unzip -l build/app/outputs/bundle/productionRelease/app-production-release.aab | grep -E 'lib/.*\.so|assets/flutter_assets/fonts'
bundletool dump manifest --bundle=build/app/outputs/bundle/productionRelease/app-production-release.aab
bundletool dump config --bundle=build/app/outputs/bundle/productionRelease/app-production-release.aab
```

Confirm actual package/version/API 36, final merged permissions/exported components, native `.so` ABIs, 16 KB `PAGE_ALIGNMENT_16K`, bundled fonts, R8/shrink behavior and no private credentials. If `bundletool` is unavailable, install it from the official distribution in CI. Generate APKs from the AAB for testing, then use an installed Android build-tools `zipalign -c -P 16 -v 4 <apk>` and a 16 KB emulator/device. Bundle alignment alone cannot prove native ELF compatibility. Keep R8 mapping and Flutter split-debug-info files private if enabled; no blanket keep-everything rule. This repository has not executed Gradle, lint, build or native smoke in Work, so **do not upload** until CI records all results.

Google Play Billing Library version must be read from the resolved `productionReleaseRuntimeClasspath` (official Flutter IAP plugin, not inferred from pubspec). Resolve IAP in the real lockfile via `flutter pub get`; never edit it by hand. Internal Play test/license testers are required for billing flows. Record AAB size/hash and signed/unsigned state in the release record. Final Play listing, legal URLs, upload key and credentials are owner actions.
