# KeEv Ledger — architecture and decisions

Status: target design agreed internally against the owner's brief, implementation gated by toolchain and phase tests. No production cloud provider or deployed API is claimed.

## Dependency direction

Presentation → Application → Domain. Data implements domain repository interfaces. Infrastructure supplies SQLite, files, platform authentication, secure storage, network and native stores. The app composition root injects implementations. Widgets render state and dispatch commands; they do not calculate balances, call SQL, authorize purchases or decide sync conflicts.

Use feature-based modules with these layers inside each feature; `core/` contains shared Money, Currency, Clock, IdGenerator and typed failures. SDK ChangeNotifier/Listenable is sufficient initially for presentation controllers; no state-management package until demonstrated need. Domain stays plain Dart. Application commands own atomic unit-of-work boundaries. Repository APIs return typed results and streams of immutable views.

## Recorded decisions

| ADR | Decision | Reason / guardrail |
|---|---|---|
| 001 | Flutter native-rendered widgets, no WebView for core | Owner requirement; do not reuse native shells |
| 002 | SQLite via Drift, schema migrations in data layer | Relational constraints, atomic writes/outbox, generated migration tests; package version pinned only after successful resolution/tests |
| 003 | Local profile UUID independent of cloud user | Full offline mode; cloud attach doesn't change record IDs |
| 004 | Integer minor-unit Money, exact rate numerator/denominator | Avoid IEEE-754 bookkeeping drift; serialize large integers as decimal strings in API/backup |
| 005 | One transaction with two explicit transfer amounts | Atomic transfer; cross-currency and debt-account signs unambiguous |
| 006 | Transactional outbox, server conditional versions and change cursor | Durable offline writes; avoid full-snapshot clobber and wall-clock last-write wins |
| 007 | Explicit conflict records; retain both candidate edits | Financial amounts cannot be silently merged/duplicated |
| 008 | New authenticated versioned API with PostgreSQL behind it | No direct privileged DB client, no Grok broker or preview credentials |
| 009 | Files for receipts, staged/hashed metadata in SQLite | No Base64 DB images; separate upload lifecycle and crash recovery |
| 010 | Versioned JSON payload inside authenticated encrypted backup | Portable Android↔iOS format with integrity and migrations |
| 011 | Passwordless email OTP, native-supported OAuth | User's email-first verification; small attack surface; provider linking explicit |
| 012 | Store identities independent of bookkeeping ownership | Guest same-store purchases; optional KeEv link for cross-platform entitlement |
| 013 | ARB/gen-l10n; primary zh-HK | Five complete locales; translation key parity and ICU checks |
| 014 | No analytics/ad/cloud speech initialization before appropriate opt-in | Local-only privacy must be true in network capture, not merely UI copy |
| 015 | Distinct local / cloudBackup / cloudSync states | Backup snapshots differ from mutable sync; avoid ambiguous storage toggle |
| 016 | OS sandbox at-rest protection; secure storage only for secrets | Do not call SQLite encrypted unless encrypted DB integration is actually implemented and verified; app PIN isn't full filesystem encryption |

Flutter's separation-of-concerns guidance informs this design; details above are KeEv decisions. [Flutter architecture](https://docs.flutter.dev/app-architecture). Drift supports SQLite transactions and migration tooling on Android/iOS; package page inspected 19 September 2026 showed 2.35.0 published nine days earlier. This is a candidate baseline, not an installed/tested dependency. [Drift](https://pub.dev/packages/drift), [migration documentation](https://drift.simonbinder.eu/migrations/).

## Repository interfaces

- TransactionRepository: watchHistory(query), get(id), apply(command, expectedVersion), delete(id, expectedVersion). Mutation includes attachment metadata and outbox in same DB transaction. No widgets see SQL rows.
- AccountRepository: watchAccounts(includeArchived), create, editMetadata, archive, reorder. Used account currency/kind immutable; restrict referenced deletes.
- BudgetRepository / ProjectRepository: scoped queries and versioned mutations.
- ReportRepository: aggregate(query, valuationPolicy), returns totals plus completeness/rate provenance. CSV consumes this same result, not a second calculation implementation.
- BackupRepository: previewImport, createEncrypted, restoreValidated; isolate expensive crypto/image work; file bounds before allocation/decompression.
- SyncRepository: enqueue in unit of work, claimBatch, acknowledgeOperation, applyPullAtomically, persistConflict, resetCursorWithSafeResnapshot.
- AuthRepository: requestOtp, verifyOtp, providerLogin, refresh, logout, deleteAccount; secure storage implementation owns tokens.
- EntitlementRepository: verified signed snapshot, refresh, acknowledge/revoke; UI has no writable “isPremium”.
- AdService: eligibility(consent, placement, entitlement), load, dispose; no transaction metadata input type.

## Persistence and application safety

One SQLite DB and attachment directory per local profile. Enable foreign keys and appropriate journaling; migration upgrade runs inside transaction after recoverable backup. Schema snapshots and migration tests committed. No catch-and-return-empty database on corruption; open a recovery state with backup/export options. `save` succeeds only after durable DB write; full disk/permission errors keep draft.

No raw Dart double represents money. Keep account-currency amount for income/expense and both transfer sides; computed caches disposable. Opening balance effective date and archived status do not erase money. Sorting uses occurred time plus stable tie-breaker, not display locale.

## Cloud system boundary

Mobile ↔ HTTPS versioned API ↔ private PostgreSQL and private object storage. Auth, sync, attachments, backups, entitlements and deletion have explicit API modules and authorization tests. Region, hosting/email processors and operational budget require owner selection before provisioning. Do not inherit the prototype's provider choice silently. API derives user from verified token; foreign record/account/project IDs checked under that owner. No client-supplied user ID is authority.

Phase 6 protocol v1 uses local Drift + durable outbox, optimistic server row versions, server-assigned change sequence, tombstones, idempotent mutation IDs and explicit conflicts. Drift remains the immediate working store. Direct canonical cloud writes are unavailable to mobile roles; authenticated RPCs apply allow-listed mutations and user-scoped initialization. Explicit Enable Sync and opaque generations protect onboarding/reset. Phase 6C-B adds one bounded single-flight coordinator for cold start, resume, connectivity/reconnect, retry, manual, private Broadcast and optional background hints. These triggers never replace authoritative push/pull. See `SYNC_PROTOCOL_V1.md`.

Server-only secrets in deployment secret manager; release mobile configuration holds public IDs/origins only. Server controls OTP attempts, entitlement verification, record versions, device leases and deletion jobs. Store notifications verified and processed idempotently. Reject production startup if a required credential is missing; no in-memory database/dev-user fallbacks.

Cloud backup: immutable versioned snapshots including receipts; authenticated manifest and server encryption-at-rest. This is **not** advertised as end-to-end encryption unless a separate client key-recovery design is implemented. Local portable backups use user passphrase encryption and no server upload. Sync is per-record with transactional outbox and receipt upload tasks. See SYNC_DESIGN.md.

## Packages and verification policy

Phase 1 should use Flutter SDK, flutter_localizations, flutter_test and SDK integration_test. `intl` version must match pinned Flutter localization dependency. No external routing/state/chart package needed for shell. Every additional package gets a recorded review: official publisher/repository, recent release/maintainer activity, licence, native minimum OS, permissions/privacy, transitive dependencies, resolved version and device test evidence. A pub.dev iOS/Android badge is eligibility evidence, not successful native integration.

Later candidates (not added/approved): drift for SQLite; platform secure storage, local_auth, image picker, speech adapter, sharing, native billing and Google/Apple sign-in adapters. Inspect official current documentation at each phase before adding. Avoid a dependency for simple domain maths or UI ornaments. Pin toolchain/lockfile after verified install. Use stable Flutter, not beta/main for releases. [Flutter SDK archive](https://docs.flutter.dev/install/archive).

## Platform and CI boundaries

Generate `android/` and `ios/` with Flutter SDK rather than copying WebView projects. Dev/staging/prod application IDs and app names distinct. Provisional root ID `com.keev.ledger` matches prototype, but store ownership must be confirmed before registration. Android native signing and iOS capabilities remain configuration gates. iOS signed builds require macOS/Xcode and owner team; Linux analysis cannot prove them.

CI gate: toolchain version → dependencies/lockfile → gen-l10n/build generation → format → analyze (fatal warnings/info) → unit/widget/migration tests → Android build. macOS lane adds iOS no-codesign compile first, then protected signed archive/TestFlight. Store sandbox integration and accessibility evidence are separate mandatory gates, never bypassed by CI green.

## Proposed directory structure

See REPOSITORY_STRUCTURE.md. This checkpoint intentionally separates reference audit materials from implementation. No generated platform project, empty repository interface or stub service is evidence of a working app.
