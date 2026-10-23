# KeEv Ledger — Phase 1A typography alignment checkpoint

Date: 20 September 2026. Scope: frozen KeEv Global Typography Standard v1.0, **no Phase 2 functionality**. The approved Phase 0 documents, original logo, Android/iOS generated projects and original Phase 1 checkpoint/evidence are preserved. Compared against the delivered `KeEv_Ledger_Phase_1.zip`: zero missing original files; only the ten expected existing source/document files were edited. `PHASE_1_SHA256.json` stays historical; `PHASE_1A_SHA256.json` inventories the updated source. `docs/evidence/phase_1a/` records the new checks.

## Objective and exact mappings

| Locale | Production primary font | Status |
|---|---|---|
| en / Latin | Plus Jakarta Sans | PASS |
| zh-HK | Noto Sans HK | PASS |
| zh-CN | Noto Sans SC | PASS — independent primary family |
| ja | Noto Sans JP | PASS |
| th | Noto Sans Thai | PASS |

One official Google Fonts unmodified variable TTF per family and five upstream SIL OFL 1.1 licence files are bundled in `assets/fonts/` and declared in `pubspec.yaml`. Variable weight ranges: Plus Jakarta Sans 200–800; Noto HK/SC/JP/Thai 100–900. No runtime font download or third-party Flutter font package. See `docs/TYPOGRAPHY.md` for sources, hashes, semantics and fallback behavior.

## Files changed

Existing: `README.md`, `pubspec.yaml`, `lib/design_system/theme.dart`, `lib/design_system/components.dart`, `android/app/build.gradle.kts`, `docs/BRANDING.md`, `docs/LOCALIZATION.md`, `docs/ACCESSIBILITY.md`, `docs/DEPENDENCIES.md`, `docs/REPOSITORY_STRUCTURE.md`. The Android stale template TODO was removed without changing IDs. New: `assets/fonts/{PlusJakartaSans,NotoSansHK,NotoSansSC,NotoSansJP,NotoSansThai}.ttf`, their five `*-OFL.txt` licence copies, `docs/TYPOGRAPHY.md`, `test/widget/typography_test.dart`, `tools/verify_fonts.py`, `tools/capture_typography_test.dart`, this checkpoint and Phase 1A evidence/previews. No package or lockfile change. Original Phase 1 tests remain intact.

## Actual commands and results

| Verification | Status | Observed result / evidence |
|---|---|---|
| `flutter pub get --enforce-lockfile` | PASS | Resolved existing pinned package graph; `PUB_GET.txt` |
| `dart format lib test tools/capture_typography_test.dart` then `dart format --output=none --set-exit-if-changed lib test tools/capture_shell_test.dart tools/capture_typography_test.dart` | PASS | 28 files, 0 changed on check; `FORMAT_APPLY.txt`, `FORMAT_CHECK.txt` |
| `flutter analyze` | PASS | `No issues found! (ran in 8.9s)`; `ANALYZE.txt` |
| `flutter test` | PASS | **41/41** unit/widget tests; `ALL_TESTS_FINAL.txt`. Original 23 remain; 18 new font/locale/mixed-script tests added. |
| `python3 tools/verify_fonts.py` | PASS | All five official-source pinned SHA-256 hashes, internal family names, weight axes, retained licences, pubspec entries, sample glyph union and digit metrics verified; `FONT_VALIDATION.json` |
| `flutter test tools/capture_typography_test.dart` | PASS | 1 dedicated visual-evidence test; 20 screenshots: five locales × light/dark × top/bottom at 200%; `VISUAL_CAPTURE_FINAL.txt`, `screenshots/` |
| `flutter --show-test-device run -d flutter-tester -t lib/main_development.dart --no-pub --no-resident` | PASS (headless only) | Actual native Flutter headless engine launch, exit 0; `RUNTIME.txt` |

One intermediate `flutter test` attempt **FAIL** exposed a 2.69:1 Add label contrast regression after switching to semantic label styles (`ALL_TESTS.txt`). The Add label now explicitly uses `onPrimary`; no test was weakened or removed. Final 41/41 pass including the original contrast/semantics check.

## Accessibility and mixed-script findings

**PASS, scoped Flutter widget/headless checks:** all five locales and light/dark at 200% scale on all original routes; live locale switch updates the actual shell font; retained semantics and minimum-target tests; retained action contrast checks. Additional previews and tests cover `HK$ 12,580.50 餐飲`, `支付寶 Alipay ¥1,280`, `Amazon JP ¥8,900`, `ร้านอาหาร HK$350`, `東京 Metro ¥220`, `KeEv Ledger 交易紀錄`, `Visa •••• 1234`, `USD 1,250.75`, `THB 3,450.00` and a very large amount. No Flutter layout exceptions, overflow or visibly clipped Thai tone marks/CJK glyphs were found in the inspected headless captures. Large amounts wrap within the available width. All sample code points occur in the union of bundled font cmaps. Noto HK/SC/JP/Thai digits have equal default widths; Plus Jakarta Sans exposes `tnum` and the amount widget applies `FontFeature.tabularFigures()` while retaining locale family.

**NOT VERIFIED:** actual Android/iOS font rasterization, full mobile native text shaping/fallback across every untested transaction string, VoiceOver/TalkBack, dynamic text across physical devices and hardware keyboard behavior. Headless rendering and cmap checks do not certify these. Existing Phase 1 accessibility documentation is extended, not erased.

## Native platform status and known limits

- **Android: BLOCKED.** This host has no Android SDK or emulator; the original Phase 1 APK attempt failed explicitly with `No Android SDK found`. No Phase 1A APK or Android native font-rendering PASS is asserted.
- **iOS: NOT VERIFIED — requires macOS/Xcode.** Generated project remains intact; neither iOS compilation nor native font QA ran here.
- **DEFERRED:** device typography QA and mobile binary/font-size measurement. Uncompressed font source assets total approximately 39.7 MB; actual store artefact impact and font subsetting remain unverified. The bundled variable font coverage is retained rather than silently trimming commercial locale glyphs.
- **No architecture blocker or unresolved Flutter test/analyze failure.** Development legal text and skeleton bookkeeping screens retain their Phase 1 status. Phase 1A does not implement persistence, Money, real transactions, accounts, billing, cloud or analytics.

**STOP after Phase 1A.** Owner review of this complete workspace precedes explicit Phase 2 approval.
