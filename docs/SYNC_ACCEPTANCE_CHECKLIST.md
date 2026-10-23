# KeEv Ledger live-sync owner acceptance

Use a staging Supabase project in Singapore (`ap-southeast-1`) owned by KeEv
Global Services Limited (Hong Kong). Apply migrations through
`202609230007_sync_device_lifecycle_safety_v1.sql` first.

- [ ] iPhone A and Android B sign into the same account and link the same generation.
- [ ] A creates a transaction; B resumes and receives it; B edits it; A receives the edit.
- [ ] A and B edit the same transaction from one base: one applies and the other preserves an explicit conflict.
- [ ] Repeat conflict with delete versus edit in both ordering directions.
- [ ] Disable connectivity, edit unrelated and same entities on both devices, reconnect, and confirm convergence/conflict isolation.
- [ ] Add a receipt on A and verify B's private JPEG hash/size; delete it and verify tombstone/file cleanup.
- [ ] Kill/relaunch each app; confirm one cold-start pull and no duplicate channels or mutation effects.
- [ ] Rapidly resume, restore connectivity, send Broadcast hints, and press Sync Now; confirm one pipeline plus bounded follow-up.
- [ ] Pause: local changes remain captured but launch/resume/Realtime/background execution stays dormant. Resume and sync them.
- [ ] Unlink/relink; verify both ledgers remain and old device registration no longer blocks retention after server cleanup.
- [ ] Sign into Account B on an Account A-linked device; verify every automatic trigger remains blocked.
- [ ] Keep Local as Primary to rotate G1→G2; verify the other G1 device requires reconciliation and cannot push.
- [ ] Simulate a device unseen for more than 180 days after safe history pruning; require full reconciliation on return.
- [ ] Move one device from generation G1 (high acknowledgement) to G2 (low revision); confirm its G2 acknowledgement resets rather than carrying the G1 value.
- [ ] Prune through revision 100, return a device at cursor 50, and confirm no revision 101+ is applied before full reconciliation.
- [ ] While foreground with a missed Broadcast, transition the native connectivity signal offline→online and confirm durable pull recovers the remote change.
- [ ] Restore `.keevbackup`; verify live sync requires reconciliation and encrypted cloud backups remain independent.
- [ ] Verify User A cannot read User B tables, receipts, Broadcast topics, or device acknowledgements.
- [ ] Verify iOS/Android best-effort background behavior on real devices; do not expect exact timing.
- [ ] Verify the native Android/iOS connectivity EventChannel starts once, disposes cleanly, and remains only a retry hint.
- [ ] Link an empty device to an empty dataset; confirm registration exists at revision 0 and empty caught-up syncs refresh server `last_seen_at`.
- [ ] Attempt acknowledgement below the history floor and above the server head; confirm structured reconciliation/rejection and no registration advance.
- [ ] Unlink online and confirm only that device/generation becomes `linked=false`; repeat offline and confirm Local Only remains usable.
- [ ] On Android, verify all initial and callback EventChannel emissions execute through the main Looper.
