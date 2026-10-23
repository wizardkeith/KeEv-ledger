# Phase 6A — Sync Protocol + Cloud/Local Schema Foundation

Phase 6A Status: **PASS — REPOSITORY IMPLEMENTATION COMPLETE**  
Date: 2026-09-22

## Completed scope

- Drift schema **v6** with disabled/unlinked sync control state, an app-generated installation UUID, durable pull cursor, per-entity server state, outbox foundation, and two-sided conflict records.
- Sync Protocol **v1** domain/application contracts and a non-activated Supabase adapter for mutation RPC, bounded change pages, and batched canonical-row retrieval.
- Supabase migration `202609220001_sync_protocol_v1.sql` for canonical sync entities, integer money, server versions, sequence-backed revisions, tombstones, change log, mutation receipts, optimistic-concurrency RPC, RLS, explicit grants, and private `ledger-sync-receipts` storage policies.
- Syncable entities: profile/ledger state, accounts, categories, transactions, transfers, projects, budgets, and receipt attachment metadata. Secure credentials, App Lock material, backup passphrases, reports/caches, files-in-staging, and sync-control state are excluded.
- Backup restore clears stale transport assumptions and marks an existing cloud link `needsReconciliation`; it never uploads restored data automatically. `.keevbackup` remains a logical user-data snapshot and excludes installation ID, cursor, outbox, server state, conflicts, and cloud credentials.
- Phase 5 hardening: Storage delete now treats only a genuine 404 as absent; 401/403, network, rate-limit, 5xx, and other failures remain failures. `ledger_backups` now explicitly revokes `public`/`anon`/`authenticated` defaults and grants authenticated `SELECT`, `INSERT`, and `DELETE` only.
- Fix Gate migration `202609220002_sync_protocol_v1_hardening.sql` adds one profile root per user, receipt `(user_id, transaction_id, position)` uniqueness, same-currency transfer amount parity, and canonical timestamp ordering without changing Drift v6.
- Canonical pull now requires `throughSequence`, filters `server_revision <= throughSequence`, validates canonical metadata provider-neutrally, and defers future state to its later change-log entry.
- The mutation RPC now serializes mutation/entity races with transaction-scoped advisory locks, rechecks mutation receipts after locking, preserves replay/conflict semantics, and returns structured validation rejection for expected payload errors.
- Final parity migration `202609220003_sync_protocol_v1_final_parity.sql` replaces ordinary receipt-position uniqueness with active-row uniqueness, retains unique storage paths, enforces receipt path length and the supported account opening range, and guarantees `deleted_at >= created_at` across canonical tombstones.

## Protocol/security decisions

- A mutation carries one stable `mutation_id` and `base_server_version`; retrying reuses the ID.
- The security-definer RPC derives ownership from `auth.uid()`, uses an empty search path and fully qualified objects, has explicit allow-listed entity branches, and is executable only by `authenticated` (not `PUBLIC`/`anon`).
- Creates require base version 0; updates/deletes require an exact observed version. A mismatch returns structured `CONFLICT`; no silent last-write-wins path exists.
- Successful writes increment `server_version`, allocate a database sequence revision, emit a change-log descriptor, and retain soft-delete tombstones.
- Canonical tables and the change log are own-user readable. Direct canonical writes and direct change-log writes are not granted to the mobile client.
- Realtime is not configured. Durable push/pull remains authoritative; actual execution is deferred.

## Verification

- Code generation: **PASS** (`build_runner`; Drift v6 schema/migration helpers generated).
- Focused protocol, SQL/security, delete-classification, account-switch, backup exclusion/reconciliation tests: **PASS**.
- Drift migrations, including realistic v5 → v6 preservation of accounts, categories, transactions, transfers, projects, budgets, and receipts: **PASS**.
- Directly affected Phase 5C backup/cloud-backup tests: **PASS**.
- Original Phase 6A focused run: **47 tests passed**.
- Fix Gate focused run: **52 tests passed** (protocol/boundary validation, SQL/security hardening, Drift v1→v6 migration matrix, realistic v5→v6 preservation, backup compatibility and Phase 5 cloud-backup regressions).
- Final parity gate focused run: **16 tests passed** (active-only receipt uniqueness, storage-path/account-range parity, tombstone timestamp ordering, and prior Phase 6A protocol/security regressions).
- `flutter analyze --no-pub`: **PASS** (no issues).
- Live Supabase migration/provider/device verification: **NOT VERIFIED**; owner must apply migrations to development/staging/production and validate RLS/RPC/storage policies with real authenticated users.
- Android/iOS native build: **NOT VERIFIED** in this Linux environment; no device-provider behavior changed in Phase 6A.

## External setup / deferred work

- Owner action: apply Phase 5 hardening, then Phase 6A migrations `202609220001` → `202609220002` → `202609220003` to each Supabase project; run the documented two-user and concurrent-RPC integration checks. Company jurisdiction remains **Hong Kong**; preferred Supabase region remains **Singapore (`ap-southeast-1`)**.
- Phase 6B was **not started**: no repository mutation capture, worker, push/pull loop, retries, attachment transport, or background execution.
- Phase 6C was **not started**: no initial migration/onboarding, reconciliation UX, conflict resolution, lifecycle scheduling, Realtime hints, pruning, or compaction.
- Displayed ChatGPT Work consumption: unavailable to the implementation environment. Owner-reported final parity gate starting value: 74%.
