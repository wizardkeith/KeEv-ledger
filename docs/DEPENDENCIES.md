# Dependency review (through Phase 7)

Phase 7 adds `google_mobile_ads` **9.1.0** (Apache-2.0; Google;
https://github.com/googleads/googleads-mobile-flutter). It is the supported
Flutter bridge for Google Mobile Ads and the Google User Messaging Platform
(UMP), including adaptive banners and privacy-option forms. Version 9.1.0
requires Flutter 3.38.1 or later and is compatible with KeEv's 3.47-series
target. It brings `webview_flutter` 4.14.1 and its Android/iOS platform
packages transitively for SDK-rendered content. No Firebase, analytics,
attribution, billing, or second consent SDK was added. ATT uses KeEv's small
native iOS method-channel adapter to Apple's system framework.

Phase 5C adds two pinned direct dependencies:

| Package | Version | Purpose | Publisher/source | Licence | Native implications |
|---|---:|---|---|---|---|
| `archive` | 4.3.0 | Deterministic ZIP container encoding and hostile-input decoding | Brendan Duncan, https://github.com/brendan-duncan/archive | MIT | Pure Dart; application enforces entry/path/count/expanded-size limits |
| `file_picker` | 13.1.0 | Native document import and completed encrypted-file export | miguelpruivo/file_picker contributors, https://github.com/miguelpruivo/flutter_file_picker | MIT | Android system document picker and iOS document APIs; no broad storage permission requested |

The existing `cryptography` 2.9.0 supplies Argon2id and AES-256-GCM, so no second cryptographic dependency was added. The Flutter SDK has no ZIP or cross-platform document-picker API. Exact transitives are locked in `pubspec.lock`; native picker behavior is not verified in this Linux environment.

Phase 5B adds three pinned direct dependencies:

| Package | Version | Purpose | Publisher/source | Licence | Native implications |
|---|---:|---|---|---|---|
| `supabase_flutter` | 2.17.2 | Supabase Auth/Postgres client behind KeEv interfaces | Supabase, https://github.com/supabase/supabase-flutter | MIT | Network client and app lifecycle auth integration; its default SharedPreferences session persistence is explicitly disabled |
| `sign_in_with_apple` | 8.2.0 | Native Apple credential and nonce flow | About You/sign-in-with-apple contributors, https://github.com/aboutyou/dart_packages | MIT | iOS entitlement/Apple Developer setup; Android browser callback activity and owner HTTPS callback |
| `google_sign_in` | 7.2.0 | Native Google identity token acquisition | Flutter team, https://github.com/flutter/packages/tree/main/packages/google_sign_in/google_sign_in | BSD-3-Clause | Android/iOS OAuth client configuration and native provider UI |

Flutter has no built-in Supabase, Apple Sign In, or Google Sign In client. No Firebase, SMTP, cloud-backup, synchronization, billing, ads, or analytics dependency was added. Exact transitives are locked in `pubspec.lock`; real provider behavior remains unverified in the current Linux environment.

Phase 5A adds no package. Its cloud-session boundary reuses the already approved `flutter_secure_storage` dependency under a key separate from App Lock. No Apple, Google, email, Firebase, Supabase, cloud backup or synchronization SDK was introduced.

Phase 4C adds three precisely pinned dependencies:

| Package | Version | Purpose | Publisher/source | Licence | Native implications |
|---|---:|---|---|---|---|
| `flutter_secure_storage` | 11.2.0 | Store the versioned salted PIN verifier and retry state outside Drift/preferences | German Saprykin and contributors, https://github.com/mogol/flutter_secure_storage | BSD-3-Clause | iOS Keychain and Android secure-storage implementation; hardware backing is device-dependent and not claimed universally |
| `local_auth` | 3.0.2 | OS-owned Face ID/Touch ID/Android biometric prompt and capability API | Flutter team, https://github.com/flutter/packages/tree/main/packages/local_auth/local_auth | BSD-3-Clause | Android requires `FlutterFragmentActivity`, AppCompat theme and `USE_BIOMETRIC`; iOS requires a Face ID usage description |
| `cryptography` | 2.9.0 | PBKDF2-HMAC-SHA-256 and secure random salt generation | Dint project, https://github.com/dint-dev/cryptography | Apache-2.0 | Pure Dart implementation used by this build; no authentication/cloud service |

Flutter does not provide a cross-platform secure key/value store or biometric abstraction, while ad-hoc PIN hashing is not suitable. No cloud authentication package was added. Exact platform subpackages are locked in `pubspec.lock`; real native behavior remains unverified in this Linux environment.

Phase 4B adds `speech_to_text` **7.5.0** (BSD-3-Clause; Corner Software Development Corp.; https://github.com/csdcorp/speech_to_text). It supplies the maintained Android/iOS speech-recognition bridge and installed-locale capability API absent from the Flutter SDK. It requests speech/microphone access only when Voice Entry is activated and may use the OS/platform provider's network recognition. Android declares `RECORD_AUDIO`, `INTERNET`, and the recognition-service query; Bluetooth support is disabled in adapter initialization, so Bluetooth permissions were not added. iOS declares microphone and speech-recognition usage descriptions. `speech_to_text_platform_interface` **2.5.0** and `speech_to_text_windows` **1.0.1** resolve transitively; this repository does not target Windows. No cloud speech SDK, LLM, analytics, or audio recorder was added. Version 7.5.0 was published 14 September 2026 and is compatible with the pinned SDK. Native behavior remains unverified in this Linux environment.

Phase 4A adds four precisely pinned, maintained dependencies:

| Package | Version | Purpose | Publisher/source | Licence | Native implications |
|---|---:|---|---|---|---|
| `image_picker` | 1.2.3 | User-initiated camera and system photo picker | Flutter team, https://github.com/flutter/packages/tree/main/packages/image_picker/image_picker | BSD-3-Clause | Registers Android/iOS picker plugins; iOS usage descriptions required; no startup capture |
| `path_provider` | 2.1.6 | Resolve private application-support storage | Flutter team, https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider | BSD-3-Clause | Native app-directory lookup; no permission dialog |
| `image` | 4.10.1 | Decode, orient, resize and JPEG re-encode locally | Brendan Duncan, https://github.com/brendan-duncan/image | MIT | Pure Dart; CPU/memory bounded by application validation |
| `crypto` | 3.0.7 | SHA-256 integrity metadata | Dart team, https://github.com/dart-lang/core/tree/main/pkgs/crypto | BSD-3-Clause | Pure Dart; no permissions |

Flutter SDK APIs do not provide a cross-platform camera/photo picker, private directory resolution, image decoding/resizing/encoding, or SHA-256 implementation. These packages do not initialize cloud, analytics, OCR, ads, billing, or authentication. Exact resolved native subpackages are locked in `pubspec.lock`; Android/iOS compilation and real picker behavior remain unverified in the current Linux environment.

Phase 2A adds precisely pinned packages: `drift` **2.35.0** (MIT; Simon Binder, [source](https://github.com/simolus3/drift); typed SQLite), `drift_flutter` **0.3.1** (MIT; same publisher/repository; app-documents SQLite location and native library setup), and development-only `drift_dev` **2.35.0** (MIT; same publisher/repository; code/schema generation) and `build_runner` **2.16.1** (BSD-3-Clause; Dart project, [source](https://github.com/dart-lang/build); runs the generator). Dart/Flutter SDKs alone do not supply relational storage or generated migrations. Versions are resolved in `pubspec.lock`; no unrelated SDK was added. Native implications: `drift_flutter` uses `path_provider` and `sqlite3` transitively and resolves end-of-life compatibility placeholder packages `sqlite3_flutter_libs` and `sqlcipher_flutter_libs`. This **does not enable or verify SQLCipher encryption**; database protection is currently OS app sandbox only. Actual Android/iOS native compilation remains unverified. Source packages/lockfile should be reviewed in the later native build gate.

The four direct packages' full upstream licence texts are retained in `docs/phase_2a_licenses/`.

The paragraphs and package inventory below describe the **historical Phase 1/1A baseline**; Phase 2A's newly resolved transitive graph is held in the updated lockfile.

Phase 1A adds five locally bundled SIL Open Font License 1.1 variable font assets but **no Dart, native plugin or package dependency**. Exact upstream files, sources and separate retained licence texts are documented in [TYPOGRAPHY.md](TYPOGRAPHY.md) and `assets/fonts/*-OFL.txt`. These assets are part of the app bundle and are not network-fetched at runtime.

The only direct non-SDK application dependency is `intl` 0.20.3. It is required by Flutter gen-l10n/generated ICU code and matches Flutter 3.47.5's flutter_localizations pin. Publisher: dart.dev; repository: https://github.com/dart-lang/i18n/tree/main/pkgs/intl. The resolved source, pubspec and license were inspected. It is maintained in the Dart team's i18n repository; no independent claim of future maintenance is made. It is pure Dart, with no iOS/Android native plugin, permission or SDK initialization. Flutter's core SDK alone does not supply the generated ICU formatter API. No routing, state management, fonts, database, network, analytics, ads, billing or authentication package was added.

All other hosted packages below are transitive SDK/intl dependencies or Flutter test dependencies, not individually selected feature SDKs. Exact versions are locked; provenance comes from each resolved pubspec. Maintenance assessment: inherited from and validated against the pinned Flutter test/runtime dependency graph, not a claim that each is the latest release. All are Dart runtime/tooling packages with no mobile plugin registration; native mobile builds remain unverified. The four newer versions reported by pub are not blindly upgraded across SDK constraints. Full licenses are retained in THIRD_PARTY_NOTICES.md.

| Package | Exact version | Dependency role | Source | License |
|---|---|---|---|---|
| async | 2.13.1 | transitive | https://github.com/dart-lang/core/tree/main/pkgs/async | BSD-3-Clause |
| boolean_selector | 2.1.2 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/boolean_selector | BSD-3-Clause |
| characters | 1.4.1 | transitive | https://github.com/dart-lang/core/tree/main/pkgs/characters | BSD-3-Clause |
| clock | 1.1.3 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/clock | See retained license |
| collection | 1.19.1 | transitive | https://github.com/dart-lang/core/tree/main/pkgs/collection | BSD-3-Clause |
| fake_async | 1.3.3 | transitive | https://github.com/dart-lang/test/tree/master/pkgs/fake_async | See retained license |
| intl | 0.20.3 | direct main | https://github.com/dart-lang/i18n/tree/main/pkgs/intl | BSD-3-Clause |
| leak_tracker | 11.0.2 | transitive | https://github.com/dart-lang/leak_tracker/tree/main/pkgs/leak_tracker | BSD-3-Clause |
| leak_tracker_flutter_testing | 3.0.10 | transitive | https://github.com/dart-lang/leak_tracker/tree/main/pkgs/leak_tracker_flutter_testing | BSD-3-Clause |
| leak_tracker_testing | 3.0.2 | transitive | https://github.com/dart-lang/leak_tracker/tree/main/pkgs/leak_tracker_testing | BSD-3-Clause |
| matcher | 0.12.20 | transitive | https://github.com/dart-lang/test/tree/master/pkgs/matcher | BSD-3-Clause |
| material_color_utilities | 0.13.0 | transitive | https://github.com/material-foundation/material-color-utilities/tree/main/dart | See retained license |
| meta | 1.18.3 | transitive | https://github.com/dart-lang/sdk/tree/main/pkg/meta | BSD-3-Clause |
| path | 1.9.1 | transitive | https://github.com/dart-lang/core/tree/main/pkgs/path | BSD-3-Clause |
| source_span | 1.10.2 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/source_span | BSD-3-Clause |
| stack_trace | 1.12.2 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/stack_trace | BSD-3-Clause |
| stream_channel | 2.1.4 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/stream_channel | BSD-3-Clause |
| string_scanner | 1.4.1 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/string_scanner | BSD-3-Clause |
| term_glyph | 1.2.2 | transitive | https://github.com/dart-lang/tools/tree/main/pkgs/term_glyph | BSD-3-Clause |
| test_api | 0.7.12 | transitive | https://github.com/dart-lang/test/tree/master/pkgs/test_api | BSD-3-Clause |
| vector_math | 2.4.0 | transitive | https://github.com/flutter/core-packages/tree/main/packages/vector_math | BSD-3-Clause |
| vm_service | 15.3.0 | transitive | https://github.com/dart-lang/sdk/tree/main/pkg/vm_service | BSD-3-Clause |

The direct dependency's official [pub.dev listing](https://pub.dev/packages/intl), checked 20 September 2026, shows 0.20.3, publisher dart.dev, BSD-3-Clause, Android/iOS support and publication two months earlier. This independently confirms the resolved source review. None of the optional capture fonts is an application dependency.

## Phase 8A
`in_app_purchase: 3.3.1` (flutter.dev; BSD-3-Clause), official endorsed StoreKit and Play Billing plugins; purchasing and restore interface. `url_launcher: 6.3.2` (flutter.dev; BSD-3-Clause), opens official store subscription management URLs. Selected endorsed `in_app_purchase_android: 0.5.3` uses Google Play Billing Library 8.0.0 according to its official changelog; `in_app_purchase_storekit: 0.4.13` supplies StoreKit 2 by default. CI must resolve and confirm native artifacts with Dart >=3.13.4.

## Phase 8B-B server JWT verification

Supabase Edge `google-play-rtdn` imports pinned `npm:jose@6.1.3` (panva/jose, MIT) to validate authenticated Pub/Sub push OIDC JWTs against Google's JWKS, issuer, audience and signing algorithm. It is server-only; it does not enter Flutter or `.keevbackup`. Apple remains on official `@apple/app-store-server-library@3.1.0`. Actual Deno Edge import/typecheck and deployed runtime remain CI/staging gates in this workspace.
