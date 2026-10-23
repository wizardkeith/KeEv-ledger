# Phase 1 repository structure

Phase 2A adds `lib/core/{currency,money,exact_fx_rate,clock,local_id}.dart`, `lib/infrastructure/local/ledger_database.dart` plus committed generated `.g.dart`, `lib/features/local_profile/{domain,data}/`, `drift_schemas/ledger_database/drift_schema_v1.json`, two focused unit test files and `checkpoints/PHASE_2A.md`. The remaining Phase 1 inventory below is retained as its historical baseline; the new infrastructure layer supplies local SQLite while data implements the domain profile repository.

The approved full target tree is preserved in `phase_0/REPOSITORY_STRUCTURE.md`. The implemented foundation is deliberately smaller:

```text
android/                  Flutter-generated native Android project + flavors
ios/                      Flutter-generated Runner project + shared schemes
lib/
  main.dart               development default
  main_development.dart
  main_staging.dart
  main_production.dart
  app/                    bootstrap, environment, app composition, routes
  core/                   typed Result/Failure
  design_system/          colours, themes, reusable primitives
  localization/arb/       five locales + Chinese generator fallback
  localization/generated/
  features/
    onboarding/presentation/
    home/presentation/    Home, History, Budget, More navigation shell
    settings/
      presentation/       language and appearance
      application/        settings controller
      domain/             preferences repository boundary
      data/               explicit session implementation
assets/brand/             original logo, unchanged
assets/fonts/             Phase 1A licensed five-family variable TTFs + OFL notices
 test/unit/               localization and preference behaviour
 test/widget/             navigation, onboarding, themes, accessibility
 tools/                   repeatable verify and optional visual capture
 checkpoints/PHASE_1.md
 checkpoints/PHASE_1A.md
 docs/evidence/phase_1/
 docs/evidence/phase_1a/   bundled-font validation and headless captures
 .github/workflows/phase1.yml
```

Accounts, projects, reports, backup, authentication and premium currently use the small generic `FeatureShell` in app/routes.dart. This is an honest labelled empty screen, not a fake repository or service. History/Budget remain distinct navigation destinations without sample financial data. Feature-specific application/domain/data modules will be created only when their real behaviour is approved and implemented. No empty speculative repositories, SQL directory, backend or service integrations are populated for appearances.

Dependency direction remains presentation → application → repository interface; the composition root chooses SessionPreferences. No financial calculation or persistence is inside a widget. Navigation, onboarding checkbox and selected tab are temporary UI state. Settings preferences are not bookkeeping data. KeEvAmountText only displays already formatted text; no money model or transaction input is implemented early.

Phase 2B1 adds `lib/features/bookkeeping/{domain,application,data}/`, updates the single canonical database in `lib/infrastructure/local/` to schema v2, commits both v1/v2 snapshots and migration tests, and removes the unused byte-identical `lib/data/local/` duplicate. See `docs/BOOKKEEPING.md`.

Phase 2B2 adds `lib/features/bookkeeping/domain/transfer.dart`, `data/drift_transfer_repository.dart`, application session/input logic and Quick Add/History presentation; `lib/app/bookkeeping_runtime.dart` composes actual SQLite repositories. The canonical infrastructure schema moves to v3 and keeps v1/v2/v3 snapshots and verifier tests.
