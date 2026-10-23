# Phase 1 branding

Master: `assets/brand/keev-logo-original.png`, preserved byte-for-byte. The square image includes a white circular field and dark corners, an elephant symbol and bilingual wordmark. Use contain sizing with clear space. It is not a production launcher icon. No derived logo artwork is created in this phase. Generated Flutter launcher icons remain placeholders and must be replaced before store submission.

| Colour | Role |
|---|---|
| #DAA7E7 | Light accent; dark-mode primary |
| #B847CD | Decorative purple |
| #9F44C5 | Secondary accent |
| #7D40B9 | Light-mode primary action |
| #4037A4 | Deep brand emphasis |

Reading surfaces are opaque, lightly tinted, with subtle borders and rounded corners. This is the restrained glass treatment: no blur behind financial text, no gradient-dependent contrast. White/deep-purple and light-purple/dark-ink action pairs are tested for contrast. Selection uses semantics and a visible shape/check, not colour alone.

Phase 1A supersedes Phase 1's provisional system-font choice. The production application bundles Plus Jakarta Sans, Noto Sans HK, Noto Sans SC, Noto Sans JP and Noto Sans Thai locally; see [the font inventory, provenance, licences and typography tokens](TYPOGRAPHY.md). No font is fetched at runtime. Platform fonts are terminal fallbacks only. Actual font shaping must still be checked on Android and iOS. Logo typography is raster artwork and is not reused as a UI font.

Spacing: 4/8/12/16/24/32 logical pixels; 16-pixel standard page inset; at least 48×48 interactive targets. Text scales with platform settings. Amount text accepts already formatted content and uses tabular figures; it performs no money arithmetic. Theme and navigation transitions are deliberately instantaneous, including when reduced motion is requested.
