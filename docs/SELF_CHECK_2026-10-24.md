# Independent self-check and iOS compile preparation

Baseline: main `61e82b5510f3a429515a8bf5f19bad21839761ba`, checked live on 24 October 2026 (Hong Kong time). This is a source/engineering checkpoint, not a release acceptance. Latest candidate SHA and terminal CI outcomes are recorded in the PR and canonical main `PROJECT_STATE.md`.

## Reproduced findings

1. `python3 tools/phase9_security_checks.py` failed on the account-deletion URL define: the guard expected a one-line Dart constructor, while the pinned formatter uses multiple lines and a trailing comma. The constructor and environment key were still correct. The corrected assertion permits only the relevant whitespace/trailing comma variation. Four subprocess tests run the real guard against a copied synthetic checkout, including wrong-key and literal-URL rejection.
2. The complete backend command below reported **60 passed, 1 failed**. The failing source assertion required Supabase availability and nonempty catalogue prerequisites on one line. The replacement retains both prerequisites and `&&`, permits whitespace, and has positive/negative regression cases. After correction: **63 passed, 0 failed, 0 skipped** locally.
3. The retained quality gate covered Flutter/Android but omitted the existing Phase 9/10/11 source checks and all five backend test files. A new repository job runs those checks, the secret scan and the regression tests before the Flutter and iOS lanes. No deployed authorization, account setting or application security behavior changes.

Local fresh checks passed: Phase 9 (after correction), Phase 10, Phase 11 source guards; four Python regressions; 63 Node backend tests; secret scan; bundled-font hashes/licences/glyph checks; diff whitespace. These are static/mock/local checks, not live Supabase/store, native device or release evidence.

```sh
python3 -m unittest discover -s tools -p 'test_*.py' -v
python3 tools/phase9_security_checks.py
python3 tools/phase10_qa_checks.py
python3 tools/phase11_android_rc_checks.py
python3 tools/secret_scan.py
node --test supabase/functions/_shared/billing/tests/*.test.mjs supabase/functions/_shared/account_deletion/tests/*.test.mjs
```

## Next planned engineering step

The phase-order source is [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md), Phase 12 row: **iOS RC — signed archive on macOS/Xcode, device install, required capabilities**. Its macOS-lane paragraph explicitly separates an unsigned `flutter build ios --release --no-codesign` compile from later protected signing/archive. The current [Phase 11 checkpoint](../checkpoints/PHASE_11.md) and [release blockers](RELEASE_BLOCKERS.md) retain owner signing, real-device and live-service requirements.

This candidate adds the unsigned **production-flavor compile only** lane, using the same official Flutter 3.47.5 framework pin `6a19cca56475dbfba1478ee68d7bd0c2ef891da1` / Dart 3.13.4, GitHub-hosted macOS 26 and explicit Xcode 26.6. The lane logs actual Xcode/iOS SDK/CocoaPods versions and keeps purchases/ads disabled with the checked-in example defines. It does not sign, archive for distribution, upload, install on an owner's device or use store credentials. CI must actually complete before compile acceptance is claimed.

Runner/tool reference: [official macOS image inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md). Flutter tooling is taken from the exact existing project pin, including its dependency-manager setup. No speculative Podfile or account/capability changes were made before executing the native build.

## Remaining acceptance

- Linux cloud checkout has no Flutter/Dart executable, Xcode, iOS SDK, CocoaPods, Android SDK or physical device; hosted CI supplies the build tools. Local setup/download failures from previous tasks are historical, not a fresh native result.
- A passing unsigned compile is only the engineering preflight for Phase 12. It does not complete the signed iOS RC, Apple team/bundle confirmation, provisioning/capabilities, aggregated vendor privacy report, installation or native plugin/lifecycle/accessibility/device acceptance.
- Phase 11 Android debug passes do not replace unsigned/signed release lint/AAB, real Android 16/16 KB device, purchase/auth/ads or live-backend acceptance. Existing release blockers remain open.
- No core architecture, money/FX behavior, local-first/privacy behavior, migrations, production signing, credentials/account/security settings, enabled purchases/ads or store publication changes are authorized by this checkpoint. Substantive work stays in an unmerged draft PR.

## Publication blocked at this checkpoint

Automatic approval review rejected `github_create_tree` for the five-file candidate in `wizardkeith/KeEv-ledger`. Stated reason: the iOS compile lane and broader backend/CI changes advance beyond the earlier format-only scope. The action returned rejection rather than a tree SHA; remote branch lookup confirms this work branch was not created, and no PR or candidate CI exists. No alternate API/CLI route was used to publish the rejected changes.

The current parent instruction explicitly requests independent self-check fixes and the next planned engineering step, but that does not remove the actual execution block. The candidate remains local pending further parent/owner authorization addressing these exact changes. The prepared unsigned iOS lane is **not executed** and Phase 12 acceptance remains **blocked**, not passed. Linux source inspection additionally parsed six plist/privacy/entitlements files and checked the three flavor schemes/config names/Dart entrypoint references; these checks do not establish native build or device behavior.
