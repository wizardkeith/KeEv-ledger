# Localization and terminology

Required locales: zh-HK (primary), zh-CN, en, ja, th. Prototype zh-TW is explicitly migrated to zh-HK, not exposed as the commercial default. ARB and Flutter `gen-l10n`, with region/script-aware locale resolution and native permission localizations. [Flutter internationalization](https://docs.flutter.dev/ui/internationalization).

Use `app_en.arb` template with metadata and typed ICU placeholders; files `app_zh_HK.arb`, `app_zh_CN.arb`, `app_ja.arb`, `app_th.arb`. Where Flutter generation requires a Chinese base ARB, `app_zh.arb` is a documented fallback copy of zh-HK; do not advertise it as a sixth supported language. Explicit supported locale list resolves Traditional HK/MO/TW/Hant to zh-HK, Simplified CN/SG/Hans to zh-CN, ja/th/en accordingly, unknown to primary zh-HK. User selection persists locally before login.

| English | Hong Kong Traditional | Meaning |
|---|---|---|
| Transaction History | 交易紀錄 | Consumer history |
| Income & Expense Report | 收入與支出報告 | Simplified report |
| Assets & Liabilities Overview | 資產與負債概覽 | Personal net worth |
| Money account | 戶口 | Cash, bank, card |
| KeEv account | KeEv 帳戶 | Cloud identity |
| Local Only | 只儲存在此裝置 | Full local functionality, not trial |
| Projects / Tags | 項目／標籤 | Optional grouping |
| Save | 儲存 | Persist record |
| Backup / Restore | 備份／還原 | Recovery |

Resource coverage includes all screen labels, validation, error messages, screen-reader labels, empty states, chart descriptions, formatted plurals/dates/currencies, policy/Terms, permission prompts, deletion, purchases, backup progress and offline states. Server returns codes/parameters, not English prose shown raw. User names/notes remain untouched.

Never concatenate grammatical fragments around numbers. Use locale date formatting with ISO data storage, currency-aware minor-unit digits, accessible signed amounts and per-language fonts via platform fallback. Test Thai line breaks and Japanese long labels. Speech locale is independent capability mapping: HK Cantonese when available, not silent Mandarin replacement.

Prototype dictionary evidence: explicit counts 367/359/367/358/358, with inherited spreads; see evidence/LOCALIZATION_INVENTORY.json. This is an inventory, not proof of complete five-language editorial quality. Commercial-price strings and web-only login/error text are rewritten. Run key/placeholder parity, no hard-coded-widget-copy scan, five-locale widget tests and native permission-string review. Human linguistic QA remains pending.
