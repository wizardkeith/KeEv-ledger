# Verified toolchain — 20 September 2026

| Component | Observed result |
|---|---|
| Flutter | 3.47.5 stable release tag; framework commit `6a19cca56475dbfba1478ee68d7bd0c2ef891da1` |
| Channel display | `[user-branch]` because the verified release tag is checked out detached; this is not a beta/main selection |
| Dart | 3.13.4 stable, bundled with the release |
| Engine | `af7e796e161ae0bb1ff0758c71a7105418bd9ded` |
| Java | OpenJDK 17.0.20, 64-bit |
| Host | Linux x86_64, Ubuntu 24.04.3 LTS |
| Android SDK / adb / sdkmanager | Not installed/detected; APK attempt BLOCKED |
| Android emulator / physical phone | None available |
| Xcode / CocoaPods | Not installed; iOS NOT VERIFIED — requires macOS/Xcode |
| Linux desktop toolchain | Missing clang++, CMake, Ninja and pkg-config; not a desktop release target |
| Actually launched runtime | Flutter's `flutter-tester` device with `--show-test-device`, native Flutter engine, debug mode |

`flutter doctor -v` was executed and its full output retained in `evidence/phase_1/FLUTTER_DOCTOR_CURRENT.txt`. It reported five issue categories, including the detached-channel/PATH warning, Android and Linux toolchains, unused web/Chrome support and a proxy-validator network-interface enumeration error. Doctor's process exit code of zero is **not** a clean doctor report. SDK dependencies, generation, analysis and tests nevertheless execute successfully. No mobile compile or real screen-reader result is inferred from the headless runtime.

## Safe bootstrap and reproducibility

SDK source was obtained from the official Flutter repository at the exact stable tag; engine and Dart assets were downloaded through the environment's existing HTTPS proxy. `CI=true` and `FLUTTER_SUPPRESS_ANALYTICS=true` were set. In this SDK, CI detection short-circuits the Azure metadata probe in `packages/flutter_tools/lib/src/base/bot_detector.dart`; no metadata query is needed. `TAR_OPTIONS=--no-same-owner` preserves the current extraction owner in the restricted container rather than attempting unavailable UID changes. No SDK source was patched, fabricated engine stamp supplied, or successful test invented.

The SDK and package cache are build dependencies, excluded from the source delivery. On a normal machine, install Flutter 3.47.5 and put its `bin` on PATH, then run `tools/verify.sh`. The workflow verifies the framework commit. Use Java 17 plus an appropriately configured Android SDK for APK verification. Use macOS/Xcode for iOS; no private developer credentials are needed for an unsigned simulator/compile check. Signing, device provisioning and store distribution remain later owner-controlled steps.

Official references: [Flutter SDK archive](https://docs.flutter.dev/install/archive), [Flutter source release](https://github.com/flutter/flutter/tree/3.47.5). Raw version and host observations are retained beside the doctor log.
