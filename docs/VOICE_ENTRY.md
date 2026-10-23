# Phase 4B voice-assisted entry

Voice Entry is an optional Quick Add aid for Income and Expense. `VoiceRecognizer` is the package-neutral application boundary; `SpeechToTextRecognizer` is the native-package adapter. Recognition callbacks only update draft UI state. The existing explicit Save action, Money validation, repository and SQLite path remain authoritative. Transfers remain manual. KeEv stores no raw audio, does not persist the transcript or copy it into notes, and sends neither audio nor transcript to an LLM or analytics.

## Locale and privacy behavior

| UI locale | Accepted installed recognizer locale |
|---|---|
| `zh-HK` | `yue-HK` preferred, then exact `zh-HK`; never `zh-TW`/`zh-CN` fallback |
| `zh-CN` | exact `zh-CN` |
| `en` | installed English locale, preferring exact/device-common `en-US` or `en-GB` |
| `ja` | `ja-JP` / exact `ja` |
| `th` | `th-TH` / exact `th` |

The adapter reads the device's installed locale list rather than inventing support. Missing Hong Kong/Cantonese recognition is reported as unavailable and manual entry remains usable. The platform recognizer may process audio over a network; a disclosure is shown before first use on the Quick Add screen. No claim of universal on-device processing is made.

Android declares microphone and Internet permissions plus the recognition-service query. Bluetooth recognition is disabled to avoid unrelated Bluetooth permissions. iOS declares microphone and speech-recognition usage descriptions. Permissions are first requested by the native plugin only after Voice Entry is selected.

## Parser and race safety

The local deterministic parser handles strict digit amounts, supported currency precision, explicit JPY wording, bounded Chinese integers (including `八十五蚊`, `一百二十蚊`, `二百五十蚊`), small income/expense vocabularies, and food/transport/shopping intents. Unknown or ambiguous content stays unresolved; there is no FX or AI inference. Category intent is resolved against active user category names rather than database IDs.

Each recognition run has a generation. Cancelled/old results are ignored. Fields become user-owned after manual editing and late results cannot overwrite them. Screen disposal cancels recognition. Recognition failure leaves the existing draft intact.

Real Android/iOS recognition quality, permission dialogs, Cantonese availability, and on-device/network behavior are **NOT VERIFIED** in the current Linux toolchain.
