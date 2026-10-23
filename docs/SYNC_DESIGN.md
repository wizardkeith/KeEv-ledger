# Sync and migration design

Target architecture; backend/native integration not implemented. Local write is authoritative for immediate UI; server acknowledges synchronization, not local save success.

## States and API contract

Local / backup enabled / sync enabled are separate profile states. Authentication expiration pauses cloud work, not local entry. Status: idle, pending, syncing, authRequired, networkUnavailable, conflicted, failed. Last successful sync timestamp is distinct from last attempt and pending attachment count.

Proposed API surface: POST `/v1/devices`; POST `/v1/sync/push`; GET `/v1/sync/pull?cursor=…`; POST `/v1/attachments/upload-intent`; POST `/v1/attachments/complete`; POST `/v1/backups`; GET `/v1/backups`; DELETE `/v1/account`. API contracts and implementations require backend tests in Phases 5–6. TLS only; errors stable machine codes localized in app, no raw SQL/errors.

Push operation: operation UUID, entity type/id, base server version, local revision, payload and dependencies. User inferred from token. Same operation replay returns same acknowledgement without duplicate financial effects. Server transaction checks ownership, references and expected version, commits record+tombstone+change event. A conflict returns current server version and typed reason; no automatic last-write wins for money.

Pull: ordered change stream with opaque cursor and consistent batch boundary. Apply all data plus new cursor in local DB transaction. An entity with dirty local version creates conflict rather than overwriting local work. Pull includes tombstones and attachment metadata. If device cursor is too old, server demands resnapshot; keep unsent operations and reconcile against new snapshot before upload.

## Worker protocol

1. Commit validated entity mutation and outbox operation in one SQLite transaction.
2. Worker claims bounded batch with lease, dependency order (accounts/categories/projects before transactions, attachment links after uploaded object).
3. Push idempotently. Acknowledgement removes/marks **only** that operation revision. New edits during request remain pending.
4. Pull/apply server changes transactionally. Cursor advances only after success.
5. Complete receipt tasks and surface progress. Record successful sync only when current record batch acknowledged/applied; expose remaining receipt work separately and do not call full backup complete until files are verified.
6. Retry transient failures with exponential backoff+jitter and Retry-After. Authorization failures pause and request login; invalid data fails visibly without infinite retry; rate limits observed.

Foreground app resume and Sync Now run this same worker. Android/iOS background adapters are best effort and can be delayed/terminated; correctness never depends on exact background timing. Multiple worker triggers use one DB lease. No financial payloads in logs.

## Conflict rules

| Case | Resolution |
|---|---|
| Same op retried | Return original ACK |
| Two edits at same base version | First committed version accepted; second retained in conflict with both versions |
| Independent entities | Merge normally |
| Edit versus delete | Tombstone remains authoritative remotely; preserve unsent edit for user to restore as new record after confirmation |
| Two transfer edits | Conflict whole transfer, never independently merge source/destination amounts |
| Category/account archive versus new transaction | Existing historical references valid; stale new entry to archived account rejected for user review |
| Device clock skew | No clock winner; server versions/cursor decide ordering |
| Server data deletion/account deletion | Revoke tokens/leases, purge authorized cloud data, reject all later replay |

Tombstone retention proposal: active device acknowledgements plus minimum 90-day window; expired device leases force full resnapshot. Exact retention is owner/privacy-policy gate, not current implementation. Purge deleted payload promptly; retain only minimum tombstone metadata within approved window.

## Cloud attach and sign-out

Local→cloud: authenticated owner confirms local book and cloud book counts. Download cloud snapshot; map compatible seeded categories; keep original IDs, detect collisions, stage non-destructive import and pre-import backup. Upload in resumable idempotent batches. Do not remove source local book or claim completion before all records/files acknowledged. Signing into a different identity never silently merges the previous user's local book. Sign-out stops workers, removes identity tokens, and asks whether to keep protected local copy; deletion of local financial content needs explicit confirmation.

Cloud→new phone: verify identity; register device; fetch consistent snapshot and files; validate counts/hashes; apply atomically, then incremental catch-up. Show receipt-download progress. Android↔iOS uses same JSON model/currency arithmetic, no platform paths/keys.

## Backup format

Portable backup is `.keevbackup` with versioned outer header, authenticated encryption parameters, encrypted manifest/JSON and receipt files. Candidate construction: AES-256-GCM with cryptographic random salt/nonce and vetted passphrase KDF; KDF/library/parameters must be reviewed and benchmarked before implementation, never custom cryptography. Header fields authenticated as associated data, validate bounded KDF parameters before deriving key. Independent unpredictable nonce per encryption under a key; never derive key from 4–6 digit PIN.

Import: reject excessive compressed/decompressed size, entry count, traversal/symlinks, wrong signature/tag, hash mismatch, invalid references/currencies and unsupported future version. Decrypt in private temporary directory; validate into staging DB; preview; take rollback snapshot; atomic swap/transaction; remove decrypted temporary files on completion/error. Passphrase is not recoverable by KeEv. JSON data export, if separately chosen, is plaintext and clearly labelled; never default for migration.

Cloud snapshots include all records+receipts and server encryption-at-rest; providers may process plaintext in authorized backend operations. Do not claim end-to-end encryption. Device QR transfer is post-v1: pairing authentication, high-entropy secret, ten-minute maximum provisional TTL, atomic single redemption, sender approval, encrypted transport/payload, brute-force limits. Existing eight-character endpoint is not reused.
