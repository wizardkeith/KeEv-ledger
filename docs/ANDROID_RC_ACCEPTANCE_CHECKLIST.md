# Android RC acceptance — owner/CI

Run on the exact candidate AAB/APKs with synthetic ledger data. Record device, API level, page size, build hash and result. A source-only check is not a device PASS.

| Device / Android | Tasks |
|---|---|
| Minimum supported API (resolved from Flutter), representative mid API | Fresh install, local ledger CRUD, App Lock/PIN, backup export/restore, camera/gallery, microphone permission denial. |
| Android 15 phone | Edge-to-edge/insets, IME/forms, auth callback, sync/restart, UMP/test ads, Premium disabled checkout. |
| Android 16 small/standard phone | Startup, status/navigation bars, keyboard, predictive back on dialogs/backup/conflicts/Premium/delete account, App Lock privacy cover, camera/gallery, speech, auth, backup picker, sync and test ads. |
| Android 16 large/foldable/tablet or landscape | Resize/orientation, forms, history, reports, dialogs, safe areas, 150–200% text. |
| 16 KB page-size Android emulator/device | Start/install AAB-derived APKs; App Lock, receipt, ads/UMP, billing screen, backup and auth smoke; record `getconf PAGESIZE` and native crashes. |

Before owner acceptance, check Play Console internal-test installation, Google Sign-In using the **Play app-signing certificate** fingerprint, Apple web sign-in callback, test subscription pending/purchase/restore/backend acknowledgement, no public checkout, UMP consent withdrawal, no financial targeting, real-device TalkBack, and account deletion. Run a missed-sync/offline recovery scenario. Publish owner legal URLs and web account-deletion URL; verify the final Play Data Safety and Contains Ads answers. Do not submit the AAB in Phase 11.
