# Phase 10 manual QA — synthetic data only

Record build, device, locale, network condition and issue ID. Keep checkout disabled. Test a fresh install and an upgrade from a real older fixture independently.

- [ ] **Fresh install:** onboarding → Local Only without Supabase; create account/category, add expense/income, transfer, budget/project, edit/delete, report and CSV. Restart; verify amounts/dates/receipts remain.
- [ ] **Existing user upgrade:** migrate v5, v6 and v7 fixtures to v8; compare counts, IDs, money, attachments, outbox and reconciliation state; reopen database. Test JPY, HKD, mixed Unicode and time-zone changes.
- [ ] **Local Only:** offline, no auth, ads unavailable; create/edit/delete and App Lock still work. Test large ledger scroll/search/report and near-limit backup with synthetic receipts.
- [ ] **Cloud:** Apple/Google/email OTP cancellation/errors; session restore/expiry; account A→B isolation; linked Apple deletion reauth cancel/failure/retry; verify only A cloud data removed and local ledger preserved.
- [ ] **Sync:** A create→B pull→B edit→A pull; simultaneous edits conflict; offline edit/retry, receipts, generation reset, pause/unlink, background/resume and network flapping; no false Up to date.
- [ ] **Backup:** create/export wrong-passphrase/tamper; receipt restore preview/confirm/rollback; cloud upload/list/download/delete and private Storage ownership. Repeat at low storage and 200% text with keyboard open.
- [ ] **Premium:** unavailable/partial store catalogue, localized store price, pending/cancel/restore/account mismatch; verified adFree hides banner promptly, expired entitlement only restores consent-eligible ads. Live Sandbox/internal acceptance is separate and checkout stays off.
- [ ] **Privacy:** UMP privacy options, ATT denial, no ads on auth/App Lock/backup/conflict/purchase; published legal links and deletion web page before submission.
- [ ] **Deletion:** warning says subscriptions remain store-managed; Apple provider revocation before cloud cleanup, provider outage safe; stale JWT and cross-account deletion denied; Local Only ledger remains.

Log actual defects in `QA_BUG_LOG.md`; compare against `QA_ACCEPTANCE_MATRIX.md` and real-device accessibility checklist.
