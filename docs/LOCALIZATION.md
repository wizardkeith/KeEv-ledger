# Phase 1 localization

Flutter ARB/gen-l10n implements exactly five selectable locales: zh-HK, zh-CN, en, ja, th. `app_en.arb` is the generator template. `app_zh.arb` mirrors Hong Kong wording solely as the generator-required Chinese fallback and is not a sixth UI language. Primary and unknown-locale fallback is zh-HK. The Phase 0 proposal is preserved in `phase_0/LOCALIZATION.md`.

Device locale resolution handles Hant and HK/MO/TW as zh-HK, Hans and CN/SG as zh-CN, then supported en/ja/th preferences in device order. A manual selection overrides detection; Follow device language clears the override. SettingsController updates through PreferencesRepository. Phase 1 uses explicit session-scoped state; durable locale/theme/consent storage is Phase 2, not a hidden SharedPreferences database.

Each implemented screen, navigation item, legal-preview notice, error, loading state and common control uses ARB text. Native Material controls use Flutter's localization delegates. The logo is owner-supplied artwork. Internal route names, asset paths and developer-only bootstrap errors are not UI copy. `phaseLabel` has a typed ICU integer placeholder; future plural/date/money messages must retain complete grammatical messages and exact financial values.

All five files have key/placeholder parity tests, generated delegate loading tests, language switching tests and 200% light/dark navigation tests. Generation is configured to format output. The generated Dart files are included in delivery and can be regenerated with `flutter gen-l10n`.

## Editorial and legal status

All Phase 1 translations are development drafts pending human linguistic review. Legal screens explicitly say they are placeholders, not final terms or privacy policy. No owner-approved legal text has been silently translated or invented. Native production permission strings and final legal policies are deferred until the corresponding implementations exist. Money account terminology is 戶口 (HK); KeEv identity is KeEv 帳戶. zh-TW is not presented as a commercial primary locale.

Phase 1A bundles all five production font families. Theme selection uses zh-HK → Noto Sans HK and zh-CN → Noto Sans SC independently; en, ja and th have their own approved families. See [typography and font licences](TYPOGRAPHY.md). Existing Phase 1 headless screenshots used separate QA font loaders and remain historical evidence; Phase 1A font checks and captures use the bundled production fonts. Actual mobile CJK/Thai shaping remains a device QA item.

References checked 20 September 2026: [Flutter internationalization](https://docs.flutter.dev/ui/internationalization), [intl 0.20.3](https://pub.dev/packages/intl). The latter's official listing identifies dart.dev, BSD-3-Clause, Android/iOS support and a release two months before the check.

Phase 2B2 Quick Add, account/category creation, save errors and transfer labels are ARB/gen-l10n keys for zh-HK, zh-CN, en, ja and th. Currency codes and user-entered names are data; no legal copy was translated. The generic preview label now indicates that only some features are still in development, since local bookkeeping can be saved.
