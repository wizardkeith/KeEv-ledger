# Phase 10 localization QA

Source check: **281/281 message keys** and ICU placeholder sets match across en, zh-HK, ja and th. `zh-CN` is also present but not a required Phase 10 acceptance locale. Six strings identical to English in each approved non-English ARB are the brand word `Premium` and self-names of the language choices; no missing key was found. Locale-aware typography is already covered by `typography_test.dart`; Flutter execution unavailable here.

| Locale | Source completeness | Native/manual review still needed |
|---|---|---|
| zh-HK | PASS: key/placeholder parity | Hong Kong bookkeeping phrasing, no Simplified leakage, VoiceOver, 200% text |
| en | PASS: key/placeholder parity | Consistent Sync/Backup/Restore/Premium terms and long-text layout |
| ja | PASS: key/placeholder parity | Natural report, billing, backup and deletion wording; line breaks |
| th | PASS: key/placeholder parity | Long labels/buttons, font rendering and keyboard at 200% text |

A source parity check is not a linguistic or rendered-layout pass. The backup passphrase dialog now scrolls; its widget regression requires Flutter CI. Google UMP and store-returned localized metadata remain provider-owned.
