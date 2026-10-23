# Environments

Proposed configuration, not generated/installed yet. Toolchain install/version validation is currently blocked; see Phase 0 checkpoint. Pin exact stable Flutter commit/version and bundled Dart in CI after verified installation. No unverified pubspec.lock fabricated.

| Environment | Provisional native ID | Backend / stores | Rule |
|---|---|---|---|
| development | com.keev.ledger.dev | Isolated dev API; mock store adapter only in dev | Visible dev label; no production user data |
| staging | com.keev.ledger.staging | Separate staging DB/object store; store test environment | Synthetic/test data, explicit credentials |
| production | com.keev.ledger | Owner-controlled production API/store IDs | Must fail missing config; never preview fallback |

Owner confirms bundle/package ID availability before registering apps. Build flavors/schemes define public API origin, redirect origin, policy URL/version and public OAuth client IDs. Dart define files contain public values only; secret credentials belong to backend/CI secret manager. Don't repurpose shell HOME/CODEX_HOME. No certificates, OAuth private keys, email API keys, DB passwords or signing keystores in source.

After native scaffolding: Android productFlavors+applicationIdSuffix; iOS shared schemes and xcconfigs for each environment. Entry points main_development/main_staging/main_production inject typed AppEnvironment. Cloud and purchase services must not silently use production endpoints from dev.

Phase 1 prerequisite: trusted Flutter/Dart executable, package resolution, gen-l10n, analyze and widget tests. Android release requires Java/Android SDK and signing arrangements; iOS release requires a macOS/Xcode worker, provisioning profiles and owner developer team. Credentials aren't needed to write the offline shell but working Flutter tooling is needed to pass its gate.
