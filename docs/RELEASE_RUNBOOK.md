# Delivery and release runbook

Status: Phase 0 documentation/characterization checkpoint only; no Flutter executable or release candidate delivered. All later phase gates open.

| Phase | Deliverable | Blocking evidence |
|---|---|---|
| 0 | Prototype audit, product/architecture decisions, source inventory | Traceability, factual results, internally consistent specification, environment gate |
| 1 | Native Flutter shell, KeEv components, five ARBs | gen-l10n, format, analyze, localized widgets/light/dark/large text |
| 2 | SQLite accounts/entries/transfers | Atomic writes, restart offline, money/reference/migration tests |
| 3 | Budgets/projects/reports/exports | Range/FX/budget/export tests; encrypted local backup validation |
| 4 | Receipt/voice/app lock | Native permission denial/hardware/lifecycle evidence |
| 5 | Auth/API/cloud backup | Delivered OTP/OAuth, owner isolation, receipt-inclusive backup restore |
| 6 | Sync/phone migration | Full TEST_PLAN migration matrix; conflicts/outbox/tombstones |
| 7 | Ads/consent infrastructure | No premature tracking, safe placement, owner/provider gate |
| 8 | IAP/Play/entitlements | Store sandbox lifecycle/restore/refund tests |
| 9 | Deletion/privacy/security | Data map matches network/binary; purge/revocation; security findings resolved |
| 10 | Combined QA/accessibility | Five locales/devices/theme and accessibility signoff; prior suites green |
| 11 | Android RC | Signed release AAB, native dependencies/target API/signing, install smoke |
| 12 | iOS RC | Signed archive on macOS/Xcode, device install, required capabilities |
| 13 | Play testing | Owner-authorized internal/closed testing evidence |
| 14 | TestFlight | Upload/install/beta tester evidence |
| 15 | Metadata/compliance package | Current-policy review, accurate screenshots/ratings/privacy/notes |
| 16 | Submission | Owner-required external approval; submitted state confirmed, not approval invented |

At every phase: run relevant tests + flutter analyze, fix introduced regressions, record command exit codes and environment, update docs, write `docs/checkpoints/PHASE_N.md`. `BLOCKED` isn't `PASS`. Do not advance through critical failures. Original prototype suite failures are audit evidence rather than regressions introduced in a Flutter codebase; this checkpoint doesn't change original source to hide them.

## Build and CI (to instantiate when SDK gate clears)

Provision trusted pinned stable Flutter/Dart plus Android Java/SDK. Generate native projects, resolve dependencies and commit actual lockfile. CI command order:

```sh
flutter --version
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
flutter build appbundle --release --flavor production -t lib/main_production.dart
```

These are planned commands, not a working workflow in this checkpoint. Generation for Drift added before analyze in Phase 2. Pin action commits/toolchain in future CI, least-privilege token, no secrets for pull requests, protected release environment. A workflow isn't installed before an actual Flutter repository/toolchain exists.

macOS lane: same checks plus `flutter build ios --release --no-codesign` for compile evidence, then protected signing/archive via `flutter build ipa --release --flavor production -t lib/main_production.dart` after matching scheme/capability setup. No-codesign success is not signed release success. Upload credentials never committed.

## Release safety

Pre-release encrypted backend snapshot and documented forward-compatible migration. Never downgrade app over a newer local DB. Staged rollout; monitor only scrubbed crash and aggregate health metrics; pause on data loss, auth leakage, sync corruption or billing failure. Roll back compatible backend deployment or issue forward fix without destroying local data. Document incident contact/owner before launch. Re-run meaningful affected tests, not indiscriminate unrelated suites.

Final handoff includes exact source commit/build number, actual artifacts/hashes, test/device matrix, provider/region map, policy versions, store metadata, signed build/upload evidence, secrets-rotation ownership, support/deletion runbook and unresolved risks. Current checkpoint contains none of the store success evidence and does not claim completion.
