# Phase 1 accessibility

The automated checks cover five locales × light/dark at approximately 200% text scale, onboarding, primary destinations, More routes and settings subroutes. They test layout exceptions and navigability. Separate semantics, labelled target, Android/iOS target-size and text-contrast checks cover the shell. See the checkpoint for actual outcomes.

Controls use Material focus/keyboard semantics, 48-pixel minimum targets, scrollable content, safe areas, selected semantics and text labels. No action depends on colour alone. Decorative images/icons do not duplicate nearby spoken labels. Text scaling is not clamped. Theme and route transitions are instantaneous, avoiding decorative motion. There are no input keyboards in this phase.

Widget checks are not a TalkBack/VoiceOver certification. Real mobile screen-reader traversal, native CJK/Thai shaping, gesture navigation insets, display contrast and hardware keyboards remain NOT VERIFIED. Rendered preview images are evidence of the headless Flutter renderer only; they are not iOS/Android screenshots.

## Observed results

PASS: 10 locale/theme combinations at 200% in widget navigation tests, labelled central Add semantics, Android 48-pixel/iOS 44-pixel guideline checks on the home shell, labelled actionable nodes, home-shell text-contrast guideline, and primary action pair contrast ≥4.5:1. Light/dark English and all five home language previews were visually inspected; separate Thai 200% capture uses a real Thai font for additional layout review. All automated checks are practical scoped evidence, not an audit of every future financial screen.

The initial Phase 1 capture lacked CJK/Thai fonts and raced image decoding; the Phase 1 capture tool later loaded local QA fonts and precached the original logo. Phase 1A bundles the five approved families in the production app. Widget tests additionally exercise long English, mixed HK/SC/JP/Thai scripts, large financial figures, Thai combining marks, light/dark and 200% scaling without layout exceptions; see `docs/evidence/phase_1a/`. Rendering and font cmap/metrics checks cannot substitute for VoiceOver/TalkBack or mobile glyph-shaping review. No remote font runtime dependency exists.

Phase 2B2 Quick Add uses labeled text inputs and selectors, scrolling beneath the keyboard, accessible Material controls and inline error text. History keeps dates and both transfer amounts together and lays out amounts below the title to allow large text wrapping. Widget tests exercise Quick Add and cross-currency History at 200% text scaling; physical-device screen-reader behavior remains unverified pending Android/iOS toolchains.
