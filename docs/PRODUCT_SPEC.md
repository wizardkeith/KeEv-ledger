# KeEv 記帳 / KeEv Ledger — product specification

Version 0.1, 19 September 2026. Owner: KeEv Global Services Limited / 雪歌伊環球服務有限公司. This is the internally reconciled target specification, not a claim that features are implemented. Owner's current 40-section brief is authoritative.

## Product and boundaries

A real Flutter iOS/Android personal bookkeeping app for ordinary consumers. No core WebView, embedded React, PWA shell, professional accounting model or claim of standards compliance. Local Only is a full supported mode; login is requested only for optional cloud functionality. No bank connectivity, securities trading, tax filing or invoicing is implied.

Use Transaction History / 交易紀錄, Income & Expense Report / 收入與支出報告, Assets & Liabilities Overview / 資產與負債概覽. Money accounts are 「戶口」; KeEv cloud identity is 「KeEv 帳戶」. Avoid debit/credit/journal/trial balance/accounting period/chart of accounts in user flows.

Report disclaimer: “For personal bookkeeping only. These simplified reports are not financial statements prepared under IFRS, HKFRS or GAAP, and are not a substitute for professional accounting, tax or investment advice.” Hong Kong copy:「只供個人記帳參考。這些簡化報告並非按照 IFRS、HKFRS 或 GAAP 編製的財務報表，亦不能代替專業會計、稅務或投資意見。」All five translations require release editorial review.

## Resolved specification tensions

| Topic | Decision |
|---|---|
| “At least three migration paths” but C “optional” | A cloud restore and B encrypted file restore are mandatory v1. C secure device transfer is post-v1. Three paths remain roadmap scope; v1 does not claim three implemented paths. |
| JSON backup versus encrypted file | Payload is versioned JSON plus receipt files, inside authenticated encrypted `.keevbackup` container. Optional explicit plaintext JSON data export is separate, locally generated, warned and user initiated. |
| Guest purchasing vs cloud account optional | Same-store purchase/restore can use store identity without KeEv cloud registration. Cross-store entitlement linking is optional and requires KeEv account plus verified ownership; no automatic Apple↔Google restore claim. |
| Free “basic monthly summary” vs paid advanced report | Free monthly totals and ordinary History/CSV; premium configurable breakdowns, comparisons and advanced exports. Basic account balances always free; advanced net-worth report premium. |
| Multi-currency vs fast entry | Default transaction currency = account currency. Advanced detail permits alternate currency plus confirmed account amount; FX transfer requires both amounts. Never silently assume 1:1. |
| Cloud Backup vs Multi-device Sync | Separate opt-in states: local, cloud backup, cloud sync. Both require sign-in. Backup captures encrypted snapshots; sync handles incremental records. Turning sync off preserves existing cloud data until explicit deletion. |
| Phase_2 audit label vs numbered phases | PHASE_2 = future product backlog; implementation Phase 2 = local database and core entries. |
| Optional ads vs commercial completion | AdService/consent infrastructure required. Actual ads remain off until owner chooses provider/markets and privacy is verified. No fictional ad revenue or fake ad SDK. |
| Biometrics vs identity | Biometric/PIN unlocks local app only. Cloud reauthentication uses provider/email proof. |
| Existing prototype unlocks | Never import adsRemoved/reportsUnlocked/ownedThemes as purchases. |

## Core user journeys and acceptance criteria

### Start and privacy (P01)

First launch offers locale (zh-HK primary), concise summary, offline-readable policy and Terms. Explicit acceptance stores policy/terms versions and UTC timestamp atomically. Optional tracking/analytics consents are separate. Continue locally seeds one Cash account in chosen base currency; additional presets optional. No network or account creation needed to create the first entry. Production policy text must reflect integrated processors, not planned ones.

### Quick Add (P02)

Focus numeric Amount → Expense/Income (Expense default) → category → account → Save. Remember last valid type/category/account per local profile; reset invalid/archived defaults. Today in profile time zone is default. Optional expandable merchant/payee, note, date/time, project/tag, receipt, currency/rate and voice text. Save validates once, disables repeated submission, commits locally before showing success; storage failure keeps the draft. Median target ≤10 seconds for ordinary entry in a usability test; this is a target, not measured evidence.

Transactions support create, inspect, edit and confirmed delete. Positive amount only; type determines effect. Zero, malformed decimal, unsupported scale, NaN/infinity, same-account transfer and invalid references fail with localized errors. No negative “expense” workaround. Corrections use edit; refunds/reversals need a later explicit design if introduced. Created time immutable; modified time updated; tombstone records deletion.

### Accounts and transfers (P03)

Cash, Bank (savings/current), Credit Card, Octopus, e-wallet, loan and custom money/debt accounts. Create/edit/archive/unarchive/reorder. No external financial-service integration implied by labels. Archive hides from new entry pickers; existing history and net worth remain. Hard deletion only for unused zero-balance account; otherwise archive. Currency and money/debt kind immutable after first use. Opening balance has an effective date; reject earlier entries unless user explicitly moves that date.

A transfer atomically affects both accounts. Source and destination must differ and belong to the same profile. For different currencies user confirms sent and received amounts; optional linked fee is a separate expense. Credit-card payment is bank→card transfer and not a second expense. All balances derive from opening amount and transactions, not independently editable cached totals.

### Budgets and projects (P04)

Monthly total and per-expense-category budget in base currency. Progress, remaining/over amount and default 80% warning threshold (adjustable 1–100%). No rollover in v1. Changes to base currency prompt explicit budget conversion/review. Count expense only, not transfers; uncategorised expenses count toward total. Missing FX gives incomplete-progress state, not zero. Month uses profile time zone. Projects / Tags optional; one primary project plus multiple tags supported by model. Archive preserves links; deletion of used project defaults to archive.

### Reports and FX (P05)

Free History with date/type/category/account/project filters, search and CSV; monthly income, expense, net change and account balances. Premium category/account breakdown, trend, equal-length previous-period comparison, advanced Income & Expense and as-of Assets & Liabilities reports/export. Text/table alternative for every chart. “No previous value” instead of divide-by-zero percentages.

Preserve HKD, TWD, CNY, JPY, THB, USD, EUR, GBP, CAD, SGD, VND. Currency metadata defines minor units; JPY/VND zero, others normally two for this set; use maintained currency data and test. Integer amounts, rational decimal rates, explicit half-even rounding to target minor units. Transaction original amount and account amount are stored. Historical flow report uses recorded transaction rate; net worth uses a labelled as-of valuation snapshot. Changing base currency never rewrites original amounts; require usable rates for chosen report basis. Online reference rates optional; manual confirmed rate works offline. Missing/stale rates visible; dated prototype fallback values never silently used in production.

### Receipts and voice (P06)

Camera/native photo picker only after user action. Up to five receipts per transaction as initial technical bound, with visible size errors and orientation preserved. Store compressed files (target ≤2048 px long edge; cap 10 MiB decoded/uploaded file after processing), strip EXIF where supported; DB holds metadata. Stage files before DB link, retain originals until safe replacement; recover orphan/partial files after crash. Cloud backup/sync includes receipts with progress and integrity hashes.

Speech uses platform on-device capability when available; unavailable languages/devices get text entry. If platform requires cloud speech, disclose processor/connection before starting and allow refusal. No silent xAI/LLM fallback. Audio not persisted; transcript stays draft until confirmed. Parse Cantonese numerals (“八十五蚊”) as candidate HKD 85, Food, Expense; ambiguous amounts remain unresolved. Never save from recognition callback; late results cannot overwrite user's edited draft.

### Backup, restore and sync (P07)

Encrypted file backup always free and available locally. Passphrase distinct from short app PIN; loss cannot be magically recovered. Include data, attachment files, manifest, hashes and schema versions; exclude OAuth tokens, PIN verifiers, device keys, verified entitlements. Import validates limits/version/integrity first, shows preview, snapshots current state, applies atomically. Unknown future version leaves current data unchanged. Prototype JSON import is a separate bounded legacy converter that flags missing receipts, maps zh-TW→zh-HK and strips privilege flags.

Cloud sign-in and restore preserve offline writes. Local-to-cloud attachment previews both datasets and imports without destructive replace. Last-success time updates only after acknowledged cycle; queue/conflict/receipt status separate. Background work is best effort under OS scheduling, foreground resume and Sync Now complete missed work. Conflicting edits preserve both versions for user resolution; deletion does not silently resurrect.

### Identity, lock and deletion (P08)

Local Only, Apple, Google and email OTP. Email OTP is passwordless for both signup and later login, reducing unnecessary password management. Provider linking requires proof on both identities; matching email alone never merges accounts. Secure token storage; expiration/rotation/revocation supported. Lock uses platform biometrics or 4–6 digit PIN, masks app-switcher snapshot, re-locks on background according to documented timeout. Changing lock requires unlock; forgotten PIN cannot silently bypass or delete data.

Settings → KeEv Account → Delete Account describes cloud data removal, local retention choice, subscription cancellation distinction and confirmed timeframe. Recent reauthentication; delete/revoke sessions and Apple tokens; stop queued uploads and prevent deleted-account data from reappearing. Public web request route also required. Owner approves retention schedule before publishing final policy.

### Monetization, design and languages (P09)

Default KeEv theme light/dark free. Native billing only; restore visible. Product IDs supported `keev_remove_ads`, `keev_advanced_reports`; bundle/catalog and price await owner decision before Phase 8. No local boolean proves purchase. Local cached verification has bounded grace and cannot unlock from imported data. Ads never around entry Save/Delete, authentication/privacy or consent UI; bookkeeping data never ad targeting. Optional analytics default off and no financial payloads.

Logo and brand colours #DAA7E7, #B847CD, #9F44C5, #7D40B9, #4037A4. Restrained glass, precise spacing, solid readable financial surfaces, system font stacks. 48 logical-pixel primary touch targets, screen-reader labels, 200% text test, reduced-motion/opaque surface support. Contrast measured after compositing; colour never the only income/expense cue.

All visible copy, validation, semantics, platform permission text, settings, deletion, purchases, policies and errors localized for zh-HK, zh-CN, en, ja, th. ARB source, no runtime hard-coded widgets. User-entered names never machine-translated without request.

## Delivery and Definition of Done

Phases 0–16 follow the owner's order. Each checkpoint records tests, analyze, issues, fixes and remaining gates. A critical implementation/verification failure blocks the next phase. Infrastructure-only prototype tests are not Flutter correctness tests.

Release requires signed Android and iOS release builds; real offline persistence; delivered OTP/OAuth; cloud backup and cross-device restore with receipts; biometric/PIN/camera/speech device tests; five-language and accessibility review; store sandbox purchase/restore/refund; deletion and privacy evidence; backend isolation/security; Play testing and TestFlight; final submission materials. No checked box is granted for an interface placeholder.
