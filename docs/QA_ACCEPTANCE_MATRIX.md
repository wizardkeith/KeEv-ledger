# Phase 10 QA acceptance matrix — 24 September 2026

Status describes **execution in this workspace**, not whether a test source exists. Flutter/Dart, Deno, Xcode and Android toolchains are absent. Synthetic fixture coverage below remains unexecuted here. Real camera, biometric, store and assistive-technology outcomes require devices. Owner review identified QA-10-03, a P1 history receipt-state defect fixed in source; runtime confirmation remains a CI gate.

## Automated inventory

| Layer | Inventory | Execution |
|---|---|---|
| Flutter | 22 unit, 7 widget, 1 Drift migration file; v1–v8 generated schema snapshots | NOT EXECUTABLE IN CURRENT ENVIRONMENT: no `flutter`/`dart`; `flutter test`, `flutter analyze`, and `flutter pub get` unavailable |
| Backend | 5 Node test files for Apple/Google billing, webhooks and deletion | PASS: see Phase 10 checkpoint for final test count |
| Static/security | Phase 9 security script, secret scan, Phase 10 locale/schema/config check | PASS: see checkpoint |
| Live/native | Supabase staging SQL/RLS; Edge/Deno import; Android/iOS build and Xcode privacy report | OWNER / REAL DEVICE VERIFICATION REQUIRED |

## Functional flows

| Flow | Repository evidence / next manual focus | Status |
|---|---|---|
| First launch | `app_test.dart`, onboarding and local bootstrap | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Local Only | `app_test.dart`, `bookkeeping_test.dart`; offline/no auth | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Create cloud account | `account_auth_test.dart`, `account_cloud_test.dart`; real provider setup | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Sign in / session restore / sign out | `account_auth_test.dart`, `supabase_auth_foundation_test.dart` | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| App Lock | `app_lock_test.dart`, `app_test.dart`; actual biometric/resume | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Quick Add | `quick_add_test.dart`; income, expense, invalid amount, rapid save, 200% text | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Transaction create / edit / delete | `bookkeeping_test.dart`, `quick_add_test.dart`, `local_database_test.dart` | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Accounts | `bookkeeping_test.dart`, `app_test.dart`; archive/history | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Categories | `bookkeeping_test.dart`; archived historical references | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Projects | `planning_test.dart`, `planning_ui_test.dart` | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Budgets | `planning_test.dart`, `planning_ui_test.dart`; month/currency | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Transfers | `transfer_test.dart`, `quick_add_test.dart`; cross-currency/history | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Receipts | `receipt_test.dart`, `backup_test.dart`; native camera/gallery/permission | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| History receipt filter/reorder | `history_receipt_identity_test.dart`: attached→empty and empty→attached slot changes; opened file belongs to selected row; stable identity and defensive reload | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Voice Entry | `voice_test.dart`, `quick_add_test.dart`; microphone/locale | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Reports | `reporting_test.dart`, `reports_test.dart`; totals and empty state | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| CSV export | `reporting_test.dart`; Unicode, quoting, transfers | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Local backup / restore | `backup_test.dart`, new large-text dialog regression; tamper/rollback | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Cloud backup / restore | `cloud_backup_coordinator_test.dart`, `backup_test.dart`; live Storage RLS | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Sync onboarding / Sync Now | `sync_onboarding_test.dart`, `sync_runtime_test.dart`, `sync_automation_test.dart` | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Conflict resolution / pause / unlink | `sync_runtime_test.dart`, `sync_onboarding_test.dart`; two devices | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Account switch | `account_auth_test.dart`, `purchase_foundation_test.dart`; real cloud isolation | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Premium screen / purchase / restore | `purchase_foundation_test.dart`, `purchase_backend_contract_test.dart`; store sandbox | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Ads / UMP / ATT | `ads_foundation_test.dart`; native consent/permission flow | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Delete Account | `account_cloud_test.dart`, backend Apple/deletion tests; staging ownership and real Apple revoke | OWNER / REAL DEVICE VERIFICATION REQUIRED |

## Integrity, security and accessibility

| Gate | Evidence | Status |
|---|---|---|
| Drift v5→v6→v7→v8; fresh v8 | `migration_test.dart` and `sync_onboarding_test.dart` fixtures, Phase 10 source check | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Money, dates, Unicode, backup/recovery | Core/transfer/report/backup/sync tests; mixed-script native review | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| Apple/Google server entitlement and deletion | Full Node suite with deterministic fakes | PASS |
| RLS, Storage, account isolation | Migration/static checks; deployed two-user adversarial test still required | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Four approved locales | 281 keys and ICU argument sets checked in en, zh-HK, ja, th; native rendering pending | PASS (source parity only) |
| 100/150/200% text and tap/label/contrast guidelines | Existing representative `app_test.dart`, `typography_test.dart`, `quick_add_test.dart`; backup dialog added | NOT EXECUTABLE IN CURRENT ENVIRONMENT |
| VoiceOver / TalkBack / Switch / Voice Control | `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md` | OWNER / REAL DEVICE VERIFICATION REQUIRED |
| Production safety and privacy manifest | Phase 9/10 scripts, secret scan, plist syntax; Xcode report pending | PASS (static scope only) |
| Startup/large ledger/list/low-storage/network flapping | History stays on lazy `ListView.builder`; 80-record viewport regression retained alongside receipt-state tests; manual synthetic stress and device profiling needed, no timing assertion made | OWNER / REAL DEVICE VERIFICATION REQUIRED |

A QA matrix row becomes PASS for Flutter only after a compatible CI run and linked test evidence. See `MANUAL_QA_CHECKLIST.md`, `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md`, and `RELEASE_BLOCKERS.md`.
