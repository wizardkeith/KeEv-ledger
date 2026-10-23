# Phase 5C checkpoint

**Status: PASS — repository implementation complete.** Live Supabase and native document-picker verification require owner configuration/toolchains.

- Backup format: `.keevbackup` container v1; logical snapshot + ZIP (`archive` 4.3.0), receipts under logical relative paths.
- Encryption: Argon2id v19 (19,456 KiB, 2 iterations, parallelism 1, 32-byte key) + AES-256-GCM; fresh 16-byte salt/12-byte nonce; authenticated header. Passphrase is dedicated, ≥10 Unicode characters, case-sensitive, never trimmed/stored/uploaded/logged, and not recoverable.
- Bound: v1 **final encrypted container** is limited to 64 MiB. Plaintext/expanded data is limited to 67,104,740 bytes after reserving a 4,096-byte header and 28-byte fixed framing/tag allowance; final ciphertext is checked again. Archives are limited to 1,024 entries. `file_picker` 13.1.0 supplies native document import/export without broad storage permissions.
- Local backup: Local Only create/export/import/preview/restore implemented without account/network; plaintext is never exported.
- Restore: validates container, archive paths/types/count/size, manifest/counts, entities/IDs/relationships/currencies, JPEG receipt size/SHA-256 before mutation. Full snapshot replacement uses a Drift transaction plus private receipt safety/staging directories and rollback. App Lock and cloud-session stores are excluded/preserved.
- Cloud backup: authenticated create/list/download/hash-check/restore/delete implemented through provider-neutral contracts and Supabase. Immutable encrypted object path is `<auth.uid()>/<backup-uuid>.keevbackup`; metadata is inserted only after upload and failed metadata insert triggers best-effort orphan cleanup.
- Supabase: `supabase/migrations/202609210002_encrypted_backups.sql` creates private `ledger-backups`, minimal `public.ledger_backups`, own-user metadata RLS and first-folder Storage RLS. No public read or client service-role use.
- Database: local Drift schema remains **v5**; backup format version is independent.
- Verification: `flutter pub get` PASS; `flutter gen-l10n` PASS; format PASS; focused Phase 5C tests **7/7 PASS**; full Flutter suite **155/155 PASS**; final `flutter analyze` **PASS — No issues found**.
- Native: Android build/camera/document-provider/cloud verification **BLOCKED** (Android SDK/owner credentials unavailable). iOS build/document picker **NOT VERIFIED** (Linux; macOS/Xcode/owner credentials required).
- Owner action: apply migrations per environment; create/verify projects in Singapore `ap-southeast-1`; adversarial two-user RLS/Storage verification; native picker/export and live upload/download tests. Legal/company jurisdiction remains KeEv Global Services Limited, Hong Kong.
- Deferred: live production cloud verification, streaming/chunked containers above 64 MiB, automatic/scheduled backup, retention quotas, billing, and server-side recovery.
- **Phase 6 synchronization was not implemented or started.** No realtime listeners, mutation queue, merge/conflict logic, or background bookkeeping sync was added.
- Displayed ChatGPT Work usage: not exposed to the implementation runtime.

## Owner-review fix gate — restore safety and container limits

- **PASS.** Receipt staging and a fully verified safety copy now complete before any live receipt mutation. Injected staging, safety-copy, install, database, rollback and cleanup failures are covered; failed rollback preserves the safety directory.
- The 64 MiB contract now applies to the complete encrypted container. Exact-bound plaintext succeeds with a reserved header/tag allowance, one-byte excess is rejected, and oversized decrypt input is rejected.
- Adversarial coverage now includes invalid magic/version/KDF/header authentication/truncation; ZIP traversal, absolute/Windows/backslash paths, duplicates, unexpected/missing/extra/corrupt entries and entry-count bounds; invalid logical references, duplicates, currencies, dates and schema versions.
- Deterministic cloud fake coverage verifies signed-out rejection, owner-derived paths, upload-before-metadata ordering, failed-metadata orphan cleanup, list/download integrity, delete and network-failure mapping.
- UI: destructive cloud deletion requires explicit confirmation stating that local bookkeeping data remains; busy-state guards and `finally` cleanup prevent concurrent duplicate actions or a permanently stuck loading state. Restore preview includes date, format, source app version, base currency, entity/receipt counts and encrypted size.
- Verification: format **PASS**; focused backup tests **15/15 PASS**; cloud coordinator tests **4/4 PASS**; deletion-confirmation widget test **1/1 PASS**; `flutter analyze` **PASS — No issues found**. The previously passing full suite was not redundantly rerun under the fix-gate instruction.
- Native verification remains unchanged: Android **BLOCKED** (SDK/owner cloud configuration unavailable); iOS **NOT VERIFIED** (Linux, no Xcode/owner configuration). Phase 6 was not started.
