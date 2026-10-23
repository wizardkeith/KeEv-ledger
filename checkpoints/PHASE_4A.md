# Phase 4A checkpoint — Receipts + Camera + Photo Attachments

## Completed scope

- **PASS** — Optional Income/Expense receipt attachments use stable domain IDs and SQLite metadata; image bytes live only as app-controlled local files. Quick Add supports camera/library selection, pending thumbnails, remove-before-save, five-item enforcement, and save orchestration. History supports basic viewing and removal for stored receipts.
- **PASS** — `ImagePickerReceiptAcquirer` treats cancellation as a non-error and maps native access failures to typed failures. Acquisition is user initiated; no permission request or SDK initialization occurs at startup.
- **PASS** — Files are content-decoded, orientation-baked, capped to a 2048 px long edge, and encoded once as JPEG (quality fallback 88/80/72) with a 10 MiB processed maximum and SHA-256 metadata. The newly encoded supported-image copy contains pixels rather than copied original EXIF blocks; the original library file is never modified or deleted.
- **PASS** — Staging/final/database sequencing, compensating cleanup, active-transaction retry behavior, abandoned staging/orphan cleanup, and missing-reference reconciliation are tested. Filesystem + SQLite are not described as one ACID transaction.
- **PASS** — Local Only remains authoritative: no upload, OCR, AI, analytics, auth, billing, ads, voice, or biometrics were introduced.

## Persistence and dependencies

- Schema **v5** adds `receipt_attachments` with profile/transaction foreign keys, stable storage key, JPEG MIME, byte size, SHA-256, position 0–4, UTC creation time, and unique transaction/position index. Images are not SQLite BLOB/TEXT/Base64.
- Real v4→v5 data-integrity migration and generated v1/v2/v3/v4→v5 migration paths pass; existing profiles, accounts, categories, transactions, transfers, Projects, and Budgets survive.
- Added: `image_picker` 1.2.3 (BSD-3-Clause), `path_provider` 2.1.6 (BSD-3-Clause), `image` 4.10.1 (MIT), and `crypto` 3.0.7 (BSD-3-Clause). See `docs/DEPENDENCIES.md`.

## Quality gate

| Check | Result |
|---|---|
| `flutter pub get` | **PASS** |
| `flutter gen-l10n` | **PASS** — five commercial locales plus zh fallback |
| `dart run build_runner build` | **PASS** |
| `dart run drift_dev make-migrations` | **PASS** — v5 snapshot/tests generated |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** — 81 files, 0 changed after final format |
| `flutter analyze` | **PASS** — no issues |
| `flutter test` | **PASS** — 108 tests |
| Android camera/gallery/build | **BLOCKED** — Android SDK/device unavailable |
| iOS camera/gallery/build | **NOT VERIFIED** — Linux host; requires macOS/Xcode/device or simulator |

Automated tests use deterministic file/picker boundaries and do not claim real native camera, photo picker, or permission-dialog verification.

## Deferred / blockers

OCR/AI extraction, cloud receipt upload/backup/sync, voice (Phase 4B), PIN/biometrics (Phase 4C), and a broad transaction-edit/delete UX are **DEFERRED**. Native device verification is the only Phase 4A verification blocker; there is no source/test blocker.
