# Real-device accessibility acceptance — Phase 10

Record device, OS, locale, text size, pass/fail and issue ID for each run. Use synthetic ledger data. Automated Flutter navigation target/label/contrast checks exist but could not run in this workspace.

- [ ] iPhone VoiceOver: unlock PIN/biometric fallback; navigate Home, Accounts, History, Reports, Settings; add/edit transaction and attach receipt; create backup; hear sync/conflict state and resolve it; find and confirm Delete Account. Check focus order, formatted money, action labels, no PIN/passphrase announcement.
- [ ] Android TalkBack: repeat those tasks, including native picker, microphone permission, backup passphrase and cloud restore. Confirm no ad appears above App Lock and no unlabeled icon-only actions.
- [ ] Both: 100%, 150%, 200% text on small portrait phone and landscape; Thai/Japanese/zh-HK long labels; keyboard open on Quick Add, OTP, backup passphrase and deletion confirmation; Save/Confirm reachable. Bold text must not clip.
- [ ] Both: reduced motion and dark/light contrast on translucent cards; income/expense, sync error, conflict and premium state conveyed by text/semantics rather than color alone.
- [ ] Android Switch Access and iOS Voice Control: representative add transaction, restore backup and account deletion are operable by standard actions without gesture-only traps.
- [ ] No sensitive PIN, OTP or passphrase value is read or copied by app semantics; platform password manager and secure entry remain usable.

Owner/CI records results before store release preparation. Do not mark these as automated PASS.
