# Phase 4B checkpoint — Voice-assisted transaction entry

## Completed scope

- **PASS** — Optional Voice Entry is integrated into Income/Expense Quick Add as editable draft suggestions only. Recognition callbacks never invoke bookkeeping persistence; explicit Save continues through the existing Money/application/SQLite path. Manual entry and Transfer remain fully usable without speech.
- **PASS** — Package-neutral `VoiceRecognizer` boundary and `speech_to_text` adapter support contextual initialization, partial/final transcript status, stop/cancel/error handling, installed-locale selection, and screen-dispose cancellation.
- **PASS** — Locale mapping: `zh-HK` → installed `yue-HK`, else exact `zh-HK` only; `zh-CN` → exact `zh-CN`; `en` → installed English; `ja` → `ja-JP`/`ja`; `th` → `th-TH`/`th`. Hong Kong voice never falls back to `zh-TW` or Mandarin.
- **PASS** — Deterministic local parsing covers strict digit/decimal Money, zero-decimal JPY, bounded Chinese amounts including `八十五蚊`, income/expense terms, and conservative food/transport/shopping intent. Unknown input remains unresolved; no LLM, FX guess, or cloud parser exists.
- **PASS** — Recognition generation plus per-field user ownership prevents cancelled/old callbacks and late final results from overwriting manual edits. Failures preserve the draft.
- **PASS** — Five ARB locales include voice states, errors, review instruction, and platform-network disclosure. KeEv persists no audio or transcript and sends neither to AI/analytics. Platform speech may use network processing; no universal on-device claim is made.

## Dependency and native configuration

- Added `speech_to_text` **7.5.0** (BSD-3-Clause); resolved `speech_to_text_platform_interface` 2.5.0 and `speech_to_text_windows` 1.0.1 transitively. No cloud speech SDK was added.
- Android: contextual `RECORD_AUDIO`, `INTERNET`, recognition-service query; Bluetooth mode disabled and no Bluetooth permissions added.
- iOS: `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` added.
- Drift schema remains **v5**; no migration or bookkeeping persistence change was required.

## Quality gate

| Check | Result |
|---|---|
| `flutter pub get` | **PASS** |
| `flutter gen-l10n` | **PASS** — five commercial locales plus zh fallback |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** — 85 files, 0 changed |
| `flutter analyze` | **PASS** — no issues |
| `flutter test` | **PASS** — 115 tests |
| Automated speech adapter/parser/draft tests | **PASS** |
| Android native speech/permission/Cantonese verification | **BLOCKED** — Android SDK/device unavailable |
| iOS native speech/permission verification | **NOT VERIFIED** — Linux host; requires macOS/Xcode/device or simulator |

## Deferred / blockers

Real-device recognizer availability/quality, permission dialogs, and on-device versus provider-network behavior require native verification. Cloud/AI parsing is deliberately absent. PIN/biometrics remain **DEFERRED** to Phase 4C. There is no source/test blocker. **STOP after Phase 4B.**
