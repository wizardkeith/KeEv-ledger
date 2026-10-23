# Phase 3A checkpoint — Budgets + Projects

## Completed scope

- **PASS** — Monthly local Budgets with integer-minor-unit Money, optional expense-category scope, warning threshold, archive state, derived spent/remaining/over-budget progress, and deliberate zero-budget behavior.
- **PASS** — Income, transfers, credit-card payment transfers, tombstoned expenses, out-of-period expenses and unrelated categories do not consume a scoped expense Budget.
- **PASS** — Exact same-business-date transfer-implied FX is used only when uniquely available. Missing/conflicting FX returns the known subtotal plus an explicit incomplete state and missing currencies; no 1:1 assumption or nominal cross-currency sum exists.
- **PASS** — Local Projects support create, edit, archive, persisted historical association, optional Income/Expense assignment, and income/expense/net summaries. Transfers have no Project and are excluded.
- **PASS** — Budget UI, Project UI, and optional Project selection in Quick Add use the existing design system and all five ARB locales.

## Persistence and architecture

- Schema **v4** adds `projects`, `budgets`, and nullable `bookkeeping_transactions.project_id`; Drift snapshot/generated migration coverage is committed.
- Real v3→v4 file migration preserves profile, accounts, categories, income/expense rows, transfers, derived balances, and null Project values, then reopens successfully. Generated verification covers every v1/v2/v3→v4 route.
- Domain models remain independent of Drift/Flutter. `PlanningService` owns use cases/calculation; Drift repositories map and validate rows. No new package dependency was introduced.

## Quality gate

| Check | Result |
|---|---|
| `flutter gen-l10n` | **PASS** |
| `dart run build_runner build` | **PASS** — generated Drift code |
| `dart run drift_dev make-migrations` | **PASS** — v4 snapshot/tests |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** — 65 files, 0 changed |
| `flutter analyze` | **PASS** — no issues |
| `flutter test` | **PASS** — 92 tests |

Android native build remains **BLOCKED** (Android SDK unavailable). iOS native build remains **NOT VERIFIED** (Linux host; requires macOS/Xcode). Widget/SQLite tests do not claim real-device rendering.

## Deferred / blockers

Phase 3B Reports/export, live or managed historical FX, multi-tagging, budget rollover/recurrence, cloud systems and later features are **DEFERRED**. No Phase 3B work was added. There are no Phase 3A implementation blockers.
