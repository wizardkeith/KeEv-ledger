# Backup and restore

Phase 5C implements explicit snapshot backup, not synchronization. Local Only users can create and restore `.keevbackup` files without an account or network. Authenticated users may upload the same encrypted container to the private Supabase backup store.

## Format v1

- The logical snapshot serializes local profile, accounts, categories, projects, budgets, income/expense transactions, transfers, and receipt metadata. Money remains integer minor units; IDs and UTC timestamps are preserved.
- A ZIP archive (`archive` 4.3.0) contains `manifest.json`, `ledger-data.json`, and `receipts/<storage-key>.jpg`. Absolute paths are never serialized.
- The outer container has a small authenticated header, Argon2id KDF parameters, random 16-byte salt and random 12-byte nonce. The archive is encrypted using AES-256-GCM; the header is additional authenticated data.
- Production Argon2id parameters: version 19, 19,456 KiB memory, 2 iterations, parallelism 1, 32-byte derived key. Tests may use 1,024 KiB/one iteration.
- The dedicated, case-sensitive Unicode passphrase is never trimmed, persisted, uploaded, logged, or recoverable by KeEv. It is unrelated to App Lock and cloud authentication.

Format v1 caps the **final encrypted container** at 64 MiB. Plaintext archive input is capped at 67,104,740 bytes (64 MiB minus a reserved 4,096-byte header and 28 bytes of fixed framing/authentication overhead); the actual encrypted result is checked again before it is returned. Expanded archive data uses the same plaintext bound and is limited to 1,024 entries. These limits exist because the approved AEAD API processes a bounded container in memory. A future format may add chunked authenticated encryption. Plaintext archive data only exists in memory in v1; completed ciphertext is written to private temporary storage before export/upload.

## Restore

Import validates the magic/version/KDF bounds, AEAD authentication, ZIP paths/types/count/size, manifest, logical schema, duplicate IDs/relationships, receipt presence/size/SHA-256, and supported entity values before mutation. Restore is full replacement, never merge.

New receipts are first staged and verified without touching live data. The complete live receipt set is then copied and verified in a private safety directory. Only after that safety snapshot succeeds may the live receipt directory be mutated. Database or file-install failure restores the safety copy; a failed rollback deliberately preserves that copy for recovery. Best-effort staging cleanup cannot turn an otherwise successful restore into a failure. The logical database replacement remains one Drift transaction. App Lock and cloud-session secure storage are outside the snapshot and remain unchanged.

## Cloud

Supabase stores only immutable encrypted objects at `<auth.uid()>/<backup-uuid>.keevbackup` and minimal `ledger_backups` metadata. The private bucket and metadata table are protected by own-user RLS. Upload creates the object first, then metadata; metadata failure triggers best-effort object cleanup. No automatic backup, live FX, billing, or Phase 6 synchronization is present.
