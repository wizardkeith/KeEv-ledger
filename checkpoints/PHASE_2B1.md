# KeEv Ledger Phase 2B1 checkpoint — 20 September 2026

**PASS — Phase 2B1 data/application foundation.** Approved Flutter shell and earlier checkpoints preserved. Removed byte-identical, unused `lib/data/local/ledger_database.{dart,g.dart}` after confirming all imports and `build.yaml` use `lib/infrastructure/local/`.

- **Schema v2:** Retains existing v1 `local_profiles`; adds `accounts`, `categories`, `bookkeeping_transactions` and profile/date/ID history index. Actual v1→v2 migration creates only new schema objects; both v1 and v2 snapshots and generated migration verifier are committed. Real-file migration, preserved profile identity, reopening and generated schema/data-integrity migration tests **PASS**.
- **Domain/application/data:** `lib/features/bookkeeping/{domain,application,data}/` adds offline accounts (cash, bank, credit card, e-wallet, other), income/expense categories, positive-minor-unit entries, business dates, UTC timestamps, archive/tombstone policy, typed repository failures and application operations. Repository checks profile ownership, account currency, category kind, active status and opening date within SQLite transaction; local profile remains cloud independent. Account balances derive from persisted opening amount plus active income minus expense with checked `BigInt` arithmetic. Credit-card purchases decrease balance; payments wait for transfers. No stored mutable current balance, monetary REAL/double, new dependency or Phase 2B2 feature.
- **Focused coverage:** persistence/reload; stable history ordering; ownership and SQLite FK/CHECK; amount/currency/category/date validation; large integer and credit-card balances; archives and tombstones; failed multi-write rollback; v1 migration plus preserved data and reopening. Existing Phase 1/1A/2A suite retained. See `docs/BOOKKEEPING.md`.

| Gate | Status | Actual result |
|---|---|---|
| `flutter pub run build_runner build --delete-conflicting-outputs` | PASS | Generated v2 Drift classes (flag reported ignored by runner) |
| `flutter pub run drift_dev make-migrations` | PASS | v2 snapshot, step helper and generated migration tests |
| `dart format --output=none --set-exit-if-changed lib test tools/...` | PASS | 49 files; 0 changed |
| `flutter analyze` | PASS | No issues found (11.5 s), after correcting test typing |
| `flutter test` | PASS | **65/65** tests including v1→v2 migration and existing widgets |
| Android native build | BLOCKED | Android SDK unavailable (carried from Phase 2A; no native build attempted) |
| iOS native build | NOT VERIFIED | Requires macOS/Xcode |

**Deferred Phase 2B2:** transfers, cross-currency workflow, Quick Add UI and UI wiring, edits/unarchive, card payments. Local bookkeeping works through the application service offline; existing Add screen remains a placeholder. No unresolved analyzer/test blocker. **STOP before Phase 2B2.**
