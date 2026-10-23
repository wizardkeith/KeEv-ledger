# Proposed Flutter repository

The tree below is the target, not a list of implemented files. Generate native directories using a verified pinned Flutter stable SDK. Root is one mobile app; backend is independently deployable with an explicit API contract.

```text
keev-ledger/
  README.md
  pubspec.yaml
  pubspec.lock
  analysis_options.yaml
  l10n.yaml
  android/                       # Flutter-generated, flavors and signing config
  ios/                           # Flutter-generated Runner, schemes/capabilities
  assets/brand/                  # Owner logo; approved derived icon assets
  assets/legal/                  # Versioned reviewed policies in five locales
  lib/
    main_development.dart
    main_staging.dart
    main_production.dart
    app/                         # Composition root, routing, lifecycle
    core/                        # Money, Currency, Clock, IDs, failures
    design_system/               # Tokens, KeEv components, semantics
    localization/arb/            # app_zh_HK, app_zh_CN, app_en, app_ja, app_th
    features/
      onboarding/
      authentication/
      transactions/
      accounts/
      budgets/
      projects/
      reports/
      backup/
      sync/
      settings/
      premium/
      receipts/
      voice/
      app_lock/
      advertising/
    data/
      database/                  # Drift tables, migrations, schema snapshots
      repositories/              # Domain repository implementations
      serialization/             # API/backup DTOs, validation/migrations
    infrastructure/
      api/
      auth/
      platform/
      secure_storage/
      files/
      billing/
      background/
  test/
    unit/
    widget/
    migrations/
    fixtures/
  integration_test/
  backend/
    contracts/                   # OpenAPI, sync/error/version contracts
    src/                         # auth, ledger, storage, billing, deletion
    migrations/
    tests/
  tools/
  docs/
  .github/workflows/
```

Each feature has `presentation/`, `application/`, `domain/` where required. Avoid empty classes and unused abstractions simply to fill this tree. Feature domain repositories are implemented under `data/repositories/`; infrastructure has no access to presentation.

Phase 1 component contracts: KeEvScaffold (safe area/scroll/insets), KeEvGlassCard (opaque accessibility mode), KeEvPrimaryButton (loading/disabled semantics), KeEvAmountInput (localized entry and no money arithmetic), KeEvTransactionTile (signed amount/type label), KeEvAccountPicker (active accounts), KeEvBottomSheet (keyboard-safe), KeEvReportCard (data+completeness), KeEvNavigationBar (localized labels and selection).
