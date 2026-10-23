# Data retention decision register

No statutory duration or processing agreement has been approved. Do not publish a fixed deletion deadline until owner/legal and provider backup behavior are confirmed.

| Data | Current trigger / implementation | Open retention decision |
|---|---|---|
| Local ledger, receipts, PIN | User manages device data; cloud account deletion deliberately retains local ledger/App Lock | OS iCloud/device backup and uninstall handling review |
| Cloud canonical ledger, revisions, devices, conflicts, backup metadata, sanitized entitlement | `auth.admin.deleteUser` cascades user-owned Postgres rows after approved Storage cleanup | Supabase physical database backup/PITR retention owner/provider review |
| Private cloud backup and sync receipt objects | Delete exact authenticated UUID prefix before Auth deletion; retry on failure | Verify deployed bucket contents and orphan handling |
| Billing purchase proof and events | Purchase/source rows cascade on deletion after minimal identity fingerprint tombstone is committed; no raw Play token retained | Owner/legal decide fingerprint/job retention and store-side obligations |
| Deletion job | Server-private UUID/status retained to deny stale JWT uploads and retry until Auth deletion | Owner/legal set purge policy after JWT expiry and audit window |
| Provider events | Private event IDs/status, no raw payload; current implementation retains | Owner approves support/idempotency retention then implements safe cleanup |
| Consent/ATT/ad SDK state | Managed by UMP/OS/SDK | Google/Apple policies and production disclosures |
| Exported `.keevbackup` / CSV | User-selected external location | User controls external deletion; app cannot remove copies |
| Temporary restore safety files | Cleaned on success/handled failure; safety copy intentionally retained if rollback fails | Recovery workflow and crash/orphan cleanup native QA |
