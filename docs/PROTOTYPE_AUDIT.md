# KeEv Ledger — prototype audit

Audit date: 19 September 2026. Source: `92fhOe9ROytjLWOz-grok-workspace.zip` supplied by the owner. Scope: Phase 0, static source audit with targeted executable characterization. This is not a penetration test or certification of the running prototype.

## Executive finding

The prototype is a React/TanStack Start application, backed by browser localStorage and server functions. Its `native/` directories are Swift WKWebView and Kotlin WebView containers. Neither is a Flutter implementation. Preserve the product's quick entry, personal accounts, optional projects, useful filters and KeEv visual identity; rebuild persistence, authentication, synchronization, platform features, purchase verification and native projects.

The new owner specification supersedes the archived Grok build instructions and older product brief. The original workspace is reference-only and remains unchanged. In particular its demo-quality, web deployment and branding-injection instructions are not instructions for the new Flutter repository.

## Coverage and evidence limits

- All 377 extracted files were inventoried by path, size and SHA-256 in `evidence/PROTOTYPE_FILE_INVENTORY.json`.
- 104 non-generated code/configuration text files were structurally scanned for symbols, imports and browser/platform APIs; see `evidence/SOURCE_SCAN.json`.
- Product flow review covers all sections of `daybook-app.tsx`, state/persistence, domain calculations, server ledger functions, authentication gates, migrations, privacy, localization structure and native wrappers. Supporting framework/broker/preview files were inspected for their role and integration boundaries, not independently security-certified.
- `package-lock.json` contains 467 package records. Inventory is not a vulnerability or licence audit; no transitive dependency is approved for reuse.
- 63 screenshot files are historical reference evidence. Visually reviewed representative Home, Quick Add, account report and Projects screenshots. These are not freshly executed Flutter or React screenshots.
- The supplied official logo was visually inspected: purple-to-indigo elephant/cart symbol, KEEV wordmark, 雪歌伊 text, white circular field and dark outer background. The unchanged original is retained under `assets/brand/`. It is a reference master, not a finished adaptive launcher icon.
- Generated deployment bundles (66 files), Grok metadata/skills (87 files), historical screenshots and unrelated attachment images are inventoried, not copied into the production app. No unrelated personal reference images are shipped.
- Runtime cloud credentials and production service configuration are absent. Live OAuth, actual email delivery, cloud availability and phone capabilities have not been verified.

## Classification

KEEP retains product behaviour, not React implementation. IMPROVE retains the feature with explicit corrections. REBUILD replaces an unsafe/browser-specific or missing implementation. REMOVE means exclude from the new Flutter product, not delete the original source. PHASE_2 means post-v1 backlog; it does **not** mean implementation Phase 2 (which is local database and transactions).

| ID | Feature / observed behaviour | Classification | Source evidence | Flutter disposition |
|---|---|---|---|---|
| F01 | First-launch policy checkbox and five-language selector | IMPROVE | `components/privacy-gate.tsx`; `lib/local-db.ts` | Short summary, separate Policy/Terms, versioned acceptance and contextual optional permissions |
| F02 | Guest session with persistent local entries | KEEP | `lib/guest.ts`; `routes/login.tsx` | Full Local Only mode; never describe it as a temporary trial |
| F03 | Default profile is cloud; guest overrides it | REBUILD | `lib/types.ts`; `daybook-context.tsx` | Default local profile, no startup account or network dependency |
| F04 | Email/password registration, then separate preview OTP gate | REBUILD | `routes/login.tsx`; `components/otp-gate.tsx` | Email → delivered OTP → verify → account/session, no account created before proof |
| F05 | Google and X through Grok OAuth broker | REBUILD | `lib/auth/providers.ts`, `client.ts`, `server.ts`, `popup.server.ts` | Own Apple/Google native-supported flows and API token exchange; no Grok broker dependency |
| F06 | Apple button disabled, Facebook absent | REBUILD | `BindPanel` in `daybook-app.tsx` | Apple required for v1; Facebook PHASE_2 |
| F07 | X login | REMOVE | `lib/auth/providers.ts` | Outside current v1 authentication scope |
| F08 | Home: net worth, account chips, project chips, monthly income/expense, six recent entries | IMPROVE | `HomeScreen` | Keep understandable summaries; projects secondary; archived balances retained |
| F09 | Bottom navigation Home / History / Add / Budget / More | KEEP | `Shell` | Native Flutter navigation and central Quick Add action |
| F10 | Income/expense Quick Add: amount, account, category, date, note, project | IMPROVE | `AddSheet` | Amount-first focus, remembered valid defaults, optional details collapsed; add merchant and time; prevent duplicate saves |
| F11 | Transaction create and delete; no exposed transaction edit flow | IMPROVE | `TxRow`; `DaybookContextValue` | Add edit/detail, modified timestamp, durable delete and undo policy |
| F12 | Transfer selects source/destination and records one amount | REBUILD | `AddSheet`; `accounts.accountDelta` | Atomic two-account effect, destination amount for FX, no income/expense effect |
| F13 | Nine expense and five income categories | KEEP | `lib/categories.ts` | Stable IDs plus localized seeded labels; no accounting chart of accounts |
| F14 | Receipt capture/upload, compression to JPEG Data URL | REBUILD | `AddSheet`; `lib/image.ts`, `local-db.ts` | Native picker, files/metadata, compression and EXIF handling; cloud receipt restore |
| F15 | Browser speech + local keyword parser + optional xAI transcript parsing | REBUILD | `parse-voice.ts`; `AddSheet.listen`; `server/ledger.parseVoiceAi` | On-device preference, explicit cloud disclosure, typed fallback, review before Save |
| F16 | Monthly category budgets/progress/overspend | IMPROVE | `BudgetView`; `saveBudget` | Add monthly total budget, configurable warning threshold, strict positive amount validation |
| F17 | Personal asset/debt accounts; create, edit, archive, unarchive, delete | IMPROVE | `accounts.ts`; `AccountsView`, `AccountForm` | Preserve Cash/Bank/Card/Octopus/e-wallet/custom and loan types; add reorder, protect historical references |
| F18 | Account currency/type/opening amount editable without history safeguards | REBUILD | `AccountForm` | Lock currency/type once used; dated opening balance and explicit correction flow |
| F19 | Project presets Travel / Work trip / Home / Event; create/edit/archive/delete | IMPROVE | `projects.ts`; `ProjectsView` | Optional Projects / Tags including wedding/reimbursement; historical references preserved |
| F20 | History: current month/all time; account, project, income/expense-category filters | KEEP | `LedgerView` | Add custom date range and search, include archived references in history |
| F21 | Account/category/project CSV export | IMPROVE | `reports.ts`; `LedgerView.exportRows` | Correct opening balance, per-currency totals, escaping/formula protection and native share |
| F22 | Income statement / balance sheet labels and simplified totals | REBUILD | `ReportsView`; `reports.ts` | Consumer names; as-of net worth, reproducible FX and disclaimer |
| F23 | Pie charts including account and project composition | IMPROVE | `report-pie.ts`; `AccountPie` | Accessible data alternative; trends/comparisons added; signed balances not silently hidden |
| F24 | 11 currencies, base currency selector, HKD-based external FX feed/cache | IMPROVE | `types.ts`; `fx.ts`; `server/fx.ts` | Preserve currencies; manual rate works offline; stored transaction FX; unknown rate is never 1:1 |
| F25 | JSON version-1 export/import | REBUILD | `local-db.exportSnapshot/parseSnapshot`; `applySnapshot` | Versioned authenticated encrypted backup, bounded validation, attachments, atomic restore |
| F26 | Same account on new phone retrieves cloud records | REBUILD | `loadCloud`; `hydrate` | Incremental sync, receipt hydration, validated version/cursor; recovery checks |
| F27 | Eight-character transfer code, 24-hour expiry, plaintext server payload | PHASE_2 | `createTransferCode/redeemTransferCode` | Third migration path only after reviewed single-use secure transfer protocol |
| F28 | Offline banner and queue of upserts/deletes | REBUILD | `offline.ts`; `flushPending` | Transactional SQLite outbox, per-operation ACK, versions, conflicts, tombstones |
| F29 | Switch local/cloud uses whole-cloud delete and replace | REMOVE | `switchStorage`; `replaceAllCloud` | Non-destructive local-to-cloud attach/import with confirmation and resumability |
| F30 | Guest binding merges local data then replaces cloud data | REBUILD | `consumeGuestLedger`; `hydrate` | Preserve both datasets, show counts, do not erase cloud or guest until committed |
| F31 | 4–6 digit PIN using salted SHA-256 in localStorage | REBUILD | `lock.ts`; `SettingsView` | Secure-storage verifier, bounded KDF, retry throttling, lifecycle relock, protected settings |
| F32 | WebAuthn platform credential quick unlock | REBUILD | `lock.ts`; `lock-screen.tsx` | OS local authentication only; no biometric templates or cloud identity substitution |
| F33 | Paper / Ink / Matcha / Ocean / Sand themes, all free/unlocked | IMPROVE | `types.ts`; `styles.css`; `SettingsView` | Free KeEv light/dark; additional themes subject to later commercial decision and accessibility |
| F34 | Shop lists every item as Owned; server unlock endpoint trusts product ID | REBUILD | `ShopView`; `completePurchase`; `withAllFeatures` | StoreKit/Play Billing purchase state machine and verified entitlements |
| F35 | AdSlot rotates marketing strings, suppressed by adsRemoved | REBUILD | `ad-slot.tsx`; `types.ts` | AdService abstraction; no SDK until consent/processor decisions; safe placements |
| F36 | Five language dictionaries with spreads/fallbacks; traditional code zh-TW | IMPROVE | `i18n.ts`; `types.ts` | ARB for zh-HK, zh-CN, en, ja, th; complete screen/error/semantics coverage |
| F37 | Existing PWA privacy policy and disclaimer | REBUILD | `privacy.ts` | Implementation-specific policy/data map; accurate speech and third-party disclosures |
| F38 | Account deletion UI/API absent | REBUILD | All settings/server routes reviewed | Reauthentication, cloud deletion job, Apple revocation, public deletion page |
| F39 | Sample data insertion from empty History | REMOVE | `loadSample`; `LedgerView` | Test fixtures only; no sample finances in production profile |
| F40 | Clipboard fallback and hidden iframe print | REMOVE | `export.ts` | Native file Share Sheet; PDF PHASE_2; no automatic clipboard of financial datasets |
| F41 | WebView mobile shells and placeholder website URLs | REMOVE | `native/ios/.../WebContainerView.swift`; `native/android/.../MainActivity.kt` | New Flutter Runner/platform projects generated by verified Flutter SDK |
| F42 | Preview bridge, PWA tutorial, Grok branding injection, Vercel output | REMOVE | `server/`, `scripts/grok-pwa-*`, preview helpers | No dependency in Flutter app; leave supplied prototype intact |
| F43 | Unused generic multiplayer WebRTC utility | REMOVE | `lib/multiplayer/`; source import scan | Not a secure phone migration implementation |
| F44 | Remote Google Fonts, broad blur, click-bloom animation | IMPROVE | `__root.tsx`; `styles.css`; `click-bloom.tsx` | System/bundled licensed fonts, constrained glass effects, reduced motion |
| F45 | App config, manifests, signing instructions | REBUILD | `native/`; package/build configs | Flavors, permissions, actual SDK privacy disclosures and store build evidence |
| F46 | Existing tests cover infrastructure/PWA and scripted web screenshots | REBUILD | `scripts/*.test.mjs`; `artifacts/` | Domain/property, widget, native integration, backend isolation and store sandbox tests |

## Critical findings and required regression cases

| Finding | Evidence / failure mechanism | Required replacement evidence |
|---|---|---|
| S01 OTP is not proof of mailbox ownership | `hashCode` just uppercases; `Math.random`; code returned as `previewCode`; no email send; `markEmailVerified` and writable profile flag bypass gate | No OTP in API/logs; delivered code; atomic consumption; cryptographic random; HMAC/server-protected code; rate/cooldown/attempt tests; client cannot set verified |
| S02 Purchasing can be self-awarded | `completePurchase(productId)` accepts caller selection without store proof; `withAllFeatures` forces all unlocked | Server verifies store transaction; duplicate/replay/refund/pending tests; reject modified cache |
| S03 Guest attach/cloud mode can erase existing remote data | `replaceAllCloud` sequentially deletes tables then inserts without one transaction; hydration calls it before cloud merge | Fault injection during import; original and remote records survive; no delete-all sync |
| S04 Sync can lose newly queued work or resurrect deletes | `flushPending` captures queue then calls `clearPending`; hard deletes; merge includes local-only rows, no server version | Concurrent local edit during sync remains queued; stale devices cannot revive tombstones |
| S05 Cross-currency transfers materially wrong | `accountDelta` applies `tx.amount` unchanged to both account currencies | HKD 780 out / USD 100 in produces exact amounts and zero income/expense |
| S06 Missing FX silently becomes 1:1 | `convertAmount` returns input when rate absent; historical reports use current rates | Missing-rate state; stored rates; no aggregate falsely presented as complete |
| S07 Archived accounts disappear from totals | `netWorth` filters archived accounts; archive doesn't change historical ownership | Archive cash with balance; total unchanged; picker hides it only |
| S08 Export and report date inconsistencies | account CSV starts at openingBalance despite date-filtered inputs; on-screen account report includes prior entries; balance ignores date filter | CSV equals screen at same range; as-of excludes future transactions |
| S09 Mixed-currency category CSV total sums nominal amounts | `categoryLedgerCsv` reduces `tx.amount` without conversion | Currency subtotals or explicit conversion; never add HKD 10 to JPY 10 as 20 of one currency |
| S10 Receipt recovery incomplete | `cloudTx` omits image; server only stores hasReceipt; local removal leaves separate receipt keys possible | New-phone restore verifies all attachment hashes; queued deletion cleans orphan files |
| S11 Speech claims incomplete | authenticated voice path sends transcript to xAI if key available, including local-storage account mode; policy doesn't identify that processor; browser speech may use network | No optional cloud processing before consent; capability check; no guessed auto-save |
| S12 Backup validation and encryption absent | `parseSnapshot` only checks container shape, ignores unknown version; raw JSON contains financial data | Malformed/oversized/tampered/wrong-passphrase/future-version rejection with original DB intact |
| S13 Transfer code not safe phone pairing | non-cryptographic code; plaintext payload; any authenticated redeemer with code; read/delete not atomic | Retire endpoint; future authenticated encrypted pairing, expiry/rate limit/single atomic redemption |
| S14 Export injection | CSV quoting incomplete; no formula neutralization; `printExport` replaces `<` with itself then writes HTML | Formula prefix/newline/quote tests; native export avoids HTML injection |
| S15 Money and references weakly validated | floating numbers; negative client input truthy; loose server date/currency; no account ownership FKs | Integer money; strict parse; server checks every referenced owner/type/currency; atomic constraints |
| S16 Lock/settings integrity | PIN local storage; no durable retry counter; setPin lacks old-PIN check; browser session state | Native relock/background cover, reauth to change, retry lockout, migration excludes PIN |
| S17 Privacy gate doesn't stop all startup processors | AuthProvider wraps gate; remote fonts load in document head | Network capture on clean Local Only install; optional SDK lazy initialization |

These findings describe code paths and deterministic risks. They are not claims that a live production service has been exploited.

## Localization and design findings

The dictionaries have 367 explicit English and Traditional keys, 359 Simplified keys and 358 Japanese/Thai keys. Simplified spreads Traditional; Japanese/Thai spread English, so fewer explicit keys indicate inherited copy, not necessarily missing runtime strings. Hard-coded English remains in error/auth/accessibility text. `detectLocale` maps Hong Kong Traditional to zh-TW, while `speechLang` already maps it to zh-HK. Migrate UI wording deliberately instead of replacing a locale string alone.

Keep the purple hierarchy and readable rounded cards. The supplied Quick Add screenshot wraps short action labels across lines, spends substantial space on optional fields, and uses weak secondary text. New design must prioritise amount, category, account and Save; optional fields expand below; test large text and keyboard obstruction.

## Verification status

Original Node suite executed under Node 24.19.0: **122 tests, 110 pass, 12 fail**. Failures include two suites unable to import missing `vite`, PWA metadata expectations diverging from current branded output, and a migration-template expectation incompatible with populated migrations. These are original-suite results, not Flutter validation. Do not silently rewrite original tests merely to make the audit green.

See `checkpoints/PHASE_0.md` and `evidence/` for actual command logs and focused characterization results. No live phone, cloud authentication, receipt restoration, billing or store compliance has passed at this checkpoint.
