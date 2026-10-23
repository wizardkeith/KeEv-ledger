# Phase 1 implementation

Authoritative product direction remains the approved PRODUCT_SPEC.md, PROTOTYPE_AUDIT.md and ARCHITECTURE.md. This phase adds the native Flutter foundation only; no Phase 2 implementation is authorized.

The code uses Flutter SDK widgets and ChangeNotifier, ARB/gen-l10n, SDK navigation, and a typed result boundary for UI preferences. There is no WebView, database, transaction persistence, cloud, login SDK, camera, voice, billing, ads or analytics. More-screen routes for future features show labelled empty states and cannot create financial records. Add displays a Phase 2 availability notice.

SettingsController owns preference operations. PreferencesRepository is the boundary for later durable settings. SessionPreferences explicitly survives only within the running process; neither it nor the onboarding acknowledgement is represented as durable consent. Phase 2 must supply persistence and policy-version/time records. All local entry is account-free.

The first-launch sequence is language → concise development privacy introduction → readable development Privacy Policy/Terms placeholders → explicit preview acknowledgement → Local Only shell. The acknowledgement is not acceptance of a fabricated production legal policy. All five translations are development/editorial drafts pending human review, not approved legal copy.

See checkpoints/PHASE_1.md for actual final verification results and platform limits. Previous attempts and failures are retained as evidence rather than silently relabelled successful. No store registration, deployment or credential collection is performed.
