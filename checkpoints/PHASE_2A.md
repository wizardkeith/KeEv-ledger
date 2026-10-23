# KeEv Ledger Phase 2A checkpoint — 20 September 2026

**PASS — core foundation complete.** Approved Phase 0/1/1A source and typography remain in the workspace; no Phase 2B feature flows were implemented. New: `lib/core/{currency,money,exact_fx_rate,clock,local_id,local_unit_of_work}.dart`, `lib/features/local_profile/{domain,data}/`, `lib/infrastructure/local/ledger_database.{dart,g.dart}`, v1 schema snapshot, focused unit tests and `docs/CORE_DATA.md`. Existing shell still permits Local Only without cloud identity; explicit local-profile persistence is ready for Phase 2B wiring.

**Representations.** Money = signed SQLite int64 minor units (range ±9,223,372,036,854,775,807), checked with BigInt intermediates; currency registry HKD/USD/EUR/GBP/JPY/THB/CNY, JPY 0 digits. FX = reduced positive BigInt numerator/denominator in target/source **major units**, converts exactly and rounds once to target minor units with HALF-EVEN. Secure UUID v4 IDs are independent of DB rows/cloud. Clock supplies UTC technical instants. Domain imports neither Flutter nor Drift.

**SQLite.** `drift` **2.35.0**, `drift_flutter` **0.3.1**; dev-only `drift_dev` **2.35.0**, `build_runner` **2.16.1** added and locked. Schema version **1**: one local profile, unique offline ID, base currency and UTC microsecond timestamps; SQLite CHECK, NOT NULL, unique/primary key constraints, foreign-key setting and transactional unit of work. Real temporary database files test reopen/persistence, constraints, exception rollback and typed-failure rollback. Initial snapshot committed at `drift_schemas/ledger_database/drift_schema_v1.json`. No historical migration exists; unimplemented upgrades fail closed until a reviewed versioned migration is added. **No DB encryption claim:** ordinary OS sandbox protection only. Licence/dependency details: `docs/DEPENDENCIES.md` and `docs/phase_2a_licenses/`.

**Commands actually run.** `flutter pub get`; `flutter pub run build_runner build --delete-conflicting-outputs` (runner reports deprecated flag ignored, generation succeeded); `flutter pub run drift_dev make-migrations` (v1 snapshot only); `dart format`; `flutter analyze`; `flutter test`; after moving the unit-of-work interface into shared core, affected tests and analysis rerun, followed by `dart format --output=none --set-exit-if-changed`. CI and `tools/verify.sh` now run code generation. Evidence in `docs/evidence/phase_2a/`; original checkpoints remain historical.

| Gate | Status | Observed result |
|---|---|---|
| Format check | PASS | 42 files, 0 changed |
| `flutter analyze` | PASS | No issues found (4.4s), final run |
| Full `flutter test` | PASS | **55/55** existing and new tests before a mechanical interface-file move |
| Affected core/SQLite tests after move | PASS | **14/14** |
| Real SQLite file reopen / constraints / rollback | PASS | Included in focused tests |
| Android native build | BLOCKED | Android SDK absent; previously documented Phase 1 build attempt, no new attempt |
| iOS native build | NOT VERIFIED | Requires macOS/Xcode |

**DEFERRED to Phase 2B:** account, category, transaction, transfer and FX-history tables; UI Quick Add and bookkeeping flows; business-date handling; receipt and sync metadata; actual wiring of local-profile creation into the shell. Owner-side review remains the next step. No unresolved analyzer/test failure. **STOP after Phase 2A.**
