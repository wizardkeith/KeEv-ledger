# Phase 3B checkpoint — Reports + Export

## Completed scope

- **PASS** — Inclusive business-date report queries support reporting currency plus optional account, category, and Project filters. Transaction History adds coherent event-type and note filtering; transfers remain one business event.
- **PASS** — Income, Expense, Net, category/account breakdowns, daily trend data, and equal-length previous-period comparison share one `IncomeExpenseReport` calculation source. Transfers, credit-card payments, future/out-of-range events, and tombstoned entries do not distort totals.
- **PASS** — Assets & Liabilities uses historical as-of balances: opening balance + income − expense − outgoing sent Money + incoming received Money. Future activity is excluded and archived accounts remain represented.
- **PASS** — Exact same-date recorded/transfer-implied FX is used only when unambiguous. Missing or conflicting rates return the known converted subtotal with explicit incomplete status, currency/rate issues, and provenance; no nominal summation or 1:1 fallback exists.
- **PASS** — Local, user-initiated CSV consumes the same report result as the screen, preserves Unicode/financial precision, escapes commas/quotes/newlines, and neutralizes user-controlled formula prefixes (`=`, `+`, `-`, `@`).
- **PASS** — Consumer Reports UI, accessible text trend alternative, enlarged-text coverage, and all five ARB locales are integrated.

## Persistence and architecture

- Database schema remains **v4**; Phase 3B requires no new table, migration, Drift generation, or dependency.
- `ReportingService` owns report/history/as-of calculations; presentation and `CsvReportExporter` consume its result models. Domain models remain independent of Flutter and Drift.
- `RecordedFxConverter` is shared with Planning so report and budget/project FX completeness rules remain consistent.
- `LocalCsvExportGateway` defines the future native save/share boundary. The current Reports UI provides an in-app selectable CSV preview without uploading data.

## Quality gate

| Check | Result |
|---|---|
| `flutter gen-l10n` | **PASS** — generated for the updated five-locale ARB set |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** — 73 files, 0 changed |
| `flutter analyze` | **PASS** — no issues |
| `flutter test` | **PASS** — 98 tests |
| Android native build/share | **BLOCKED** — Android SDK unavailable |
| iOS native build/share | **NOT VERIFIED** — Linux host; requires macOS/Xcode |

Headless/widget success does not claim real-device file/share-sheet or screen-reader verification.

## Deferred / blockers

Native save/share gateway implementation and device verification, PDF, XLSX, live/managed historical FX, advanced visual charts, entitlement purchasing, cloud systems, and Phase 4 features are **DEFERRED**. There are no Phase 3B calculation or test blockers.
