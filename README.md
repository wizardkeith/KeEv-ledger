# KeEv 記帳 / KeEv Ledger

KeEv Global Services Limited · 雪歌伊環球服務有限公司

## Current baseline

This repository restores **KeEv Ledger Phase 11 Native Build Fix Gate Complete**, the complete Flutter source delivered on 25 September 2026 (Hong Kong time). The source was imported into GitHub on 24 October 2026.

The final section of [the Phase 11 checkpoint](checkpoints/PHASE_11.md) records an **Android repository / unsigned release-candidate gate PASS**. Earlier failures in that document are historical. This is not a production release or an App Store / Google Play submission. Phase 12 has not been started by this import.

- [Current project state and next steps](PROJECT_STATE.md)
- [Release blockers](docs/RELEASE_BLOCKERS.md)
- [Import provenance and scope](docs/IMPORT_NOTES.md)
- [Agent continuity instructions](AGENTS.md)

## Historical verification

The recovered native-build evidence records Flutter **3.47.5**, Dart **3.13.4**, Microsoft JDK **17.0.20.1**, Android SDK **36**, Gradle **9.3.1**, AGP **9.1.0**, and Kotlin **2.4.0**. It records **322 successful Flutter test events, 0 failed, 0 skipped, 0 hung**; `flutter analyze` passed, native Android builds passed, and release lint reported 0 errors and 2 nonblocking warnings. Google Play Billing resolved to 8.0.0.

These are the original gate results, not tests rerun during the GitHub import. The unsigned production RC AAB is a separate build artifact, not a source file in this repository. iOS native build/signing and real-device acceptance remain separate work.

## Application

The app provides local-first personal bookkeeping with Drift/SQLite, integer minor-unit amounts, exact FX, five locales, Local Only mode, optional Supabase authentication/sync, encrypted portable backup, App Lock, consent-gated ads, and store purchase adapters with server-side verification. Public purchases and production ads remain disabled by default. Local SQLite is not separately encrypted. Read [the data inventory](docs/DATA_INVENTORY.md), [Supabase setup](docs/SUPABASE_SETUP.md), and [backup/restore guidance](docs/BACKUP_RESTORE.md).

## Prepare and verify a checkout

Use the project's pinned Flutter/Dart versions and install the required platform toolchain. From the repository root:

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
dart run build_runner build
./tools/verify.sh
flutter run --flavor development -t lib/main_development.dart
```

The last command needs a supported device/toolchain. Machine-specific SDK paths, generated plugin registrants, caches, credentials, signing keys, and real bookkeeping data are not part of this import. All bundled fonts and their OFL licences are included. The Gradle wrapper is checked in and executable on Unix hosts.

Live services and store release require the owner-controlled configuration and acceptance listed in [RELEASE_BLOCKERS.md](docs/RELEASE_BLOCKERS.md). Configure secrets through the development environment's protected settings, rather than committing them.
