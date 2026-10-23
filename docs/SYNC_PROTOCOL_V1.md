# Sync protocol v1

Phase 6 keeps Drift as the immediate working store. Login does not enable sync, and unavailable authentication/network never blocks ordinary local bookkeeping. Phase 6C-B adds bounded lifecycle/connectivity/retry triggers and private Broadcast invalidation; durable push/pull remains authoritative.

Automatic cold-start/resume, connectivity, retry, manual, Broadcast and optional background requests feed one single-flight coordinator. Resume has a 45-second minimum interval and connectivity restoration is debounced for three seconds. Broadcast contains only generation/revision control metadata and is never applied directly.

Device acknowledgements are monotonic only within one dataset generation; moving a device to a new generation resets its acknowledgement to that generation's incoming revision. Devices seen within 180 days protect history. `history_floor_revision` is the highest revision safely pruned for the active generation, and incremental pull is rejected with structured `RECONCILIATION_REQUIRED / HISTORY_UNAVAILABLE` whenever the client cursor is below it—even when no newer events exist. Such a stale device must use full reconciliation. Mutation receipts retain at least 365 days. Canonical tombstones remain retained until a separately reviewed FK-aware compactor exists.

Acknowledgement is also the device heartbeat. Onboarding registers the installation at its finalized durable cursor, and every genuinely caught-up cycle acknowledges the current cursor even when pull returns no events. The server rejects acknowledgements below the history floor and above the authoritative generation head. Online unlink marks only the authenticated owner's matching device/generation registration unlinked; failed offline unlink never blocks Local Only use. Android connectivity callbacks marshal every EventChannel emission through the main Looper.

## Dataset generation and onboarding

Every active cloud dataset has an opaque server-generated UUID generation. The linked device persists it and includes it in push/pull. A reset rotates the generation; an old device or outbox receives `RECONCILIATION_REQUIRED` and cannot write into the replacement dataset.

Enable Sync first performs read-only local/cloud discovery. Empty/empty links directly; local-only uses a confirmed dependency-ordered, idempotent initialization upload; cloud-only uses a confirmed bounded canonical snapshot with receipt verification; data on both sides requires explicit Keep Local, Keep Cloud, or Cancel. Keep Local uses an authenticated trusted reset and new generation. Keep Cloud stages and validates the complete snapshot before replacing local user data. Initialization uses one stable operation ID, an authenticated per-user advisory lock, and a 30-minute PostgreSQL-server-time lease. The same operation resumes and refreshes its lease; another operation cannot take over until expiry. Trusted abort is best-effort on unlink, while an offline unlink remains recoverable through lease expiry. Login alone never enables sync.

Unresolved conflicts remain whole-entity choices. Keep Cloud refreshes and applies current remote state without an outbox mutation. Keep Local reads the authoritative current business row—not the historical conflict candidate—retires the old entity chain, and creates one new durable whole-entity mutation based on the current remote version. Delete/edit state is shown explicitly. Receipt choices use private authenticated download/spool and the Phase 6B staging/compensation rules. New edits on an unresolved-conflict entity are captured as blocked, while unrelated eligible entity chains continue.

Initialization completion activates the link but is not caught-up proof. It clears `lastSuccessfulSyncAt`; only a later successful bounded Phase 6B cycle for the current generation may record the timestamp and show Up to date.

## Synchronized user data

One authenticated Supabase account owns at most one v1 cloud profile/ledger root, enforced by `UNIQUE(user_id)`. A different local profile cannot create a second root and must use the Phase 6C reconciliation flow. Stable existing UUIDs are retained for the local profile, accounts, categories, income/expense transactions, transfers, projects, budgets and receipt metadata. Money remains integer minor units with explicit currency codes. Cloud receipt positions are unique among active rows only, so a tombstone does not permanently reserve a reusable position; storage paths remain unique. Receipt path length, account opening amount and same-currency transfer rules match Drift. Reports, caches, credentials, App Lock state, backup passphrases, cloud tokens, temporary files and all sync-control state are excluded.

An app-generated random UUID identifies the installation for mutation origin/diagnostics. It is not hardware-derived, tracking identity or authorization, and is excluded from `.keevbackup`; another device keeps its own ID after restore.

## Durable protocol

- Each mutation has one stable random `mutation_id`; retries reuse it.
- Create carries base version `0`; update/delete carries the last observed `server_version`.
- The server accepts update/delete only when the current version equals the base version, then increments it. A mismatch returns `CONFLICT`; it never silently applies last-write-wins.
- Postgres assigns the monotonic `server_revision` from a sequence. Client clocks and `updated_at` are not ordering authorities.
- Every applied mutation writes an immutable post-mutation canonical snapshot, mutation ID and origin device ID into the user-owned change log. Pull reads these exact historical events at `sequence > cursor`, ascending and bounded to 200; it never reconstructs an older revision from a newer canonical row. Business-row application, entity baselines, conflicts/outbox blocking and cursor advancement share one Drift transaction.
- Delete is a versioned tombstone (`deleted_at`), not immediate hard deletion.
- Mutation receipts make retries deterministic (`APPLIED`/`ALREADY_APPLIED`/`CONFLICT`/`REJECTED`). Conflict receipts retain the remote version, revision, tombstone flag and canonical snapshot, so retrying one mutation ID returns the same historical conflict result.
- Transaction-scoped advisory locks serialize the same mutation ID and the same user/entity. Receipts are rechecked after locking, so retries cannot duplicate effects and competing creates resolve as replay or conflict rather than overwrite.
- Canonical rows validate stable ID, entity type, version, revision, tombstone state and page boundary before local application. Normal payload constraint/type/range failures return structured `REJECTED / VALIDATION_FAILED` without raw database details.
- Cloud writes enforce `updated_at >= created_at` and, for tombstones, `deleted_at >= created_at` even when a client creation timestamp is ahead; timestamps remain descriptive while `server_revision` remains authoritative ordering.
- Local conflicts preserve both JSON candidates, base/remote versions, mutation identity and resolution status. Phase 6C-A exposes explicit Keep Local/Keep Cloud resolution; there is no automatic resolution.
- Delete is accepted only for transactions, transfers and receipt attachments. Accounts, categories, projects and budgets archive by update; the profile root is not deleted by ledger sync.

## Runtime execution

When a healthy linked dataset is enabled, the user write and immutable outbox intent commit in the same Drift transaction; network work never occurs inside it. Queue sequence, not wall-clock time, orders mutations. A successor waits with a deferred base until its predecessor is acknowledged. Before each RPC the row is durably marked processing and its attempt count incremented; interrupted processing is retried with the same mutation ID, payload and base. Transient failures use persisted bounded backoff, while conflicts and permanent rejections block that entity chain.

Receipt creates retain a processed-JPEG sync spool, upload an immutable private object, then mutate metadata. Receipt metadata is immutable in v1: only create and delete are supported; update is rejected by both RPC and pull validation. Deletes tombstone metadata before best-effort object cleanup. Pull pre-classifies stale events, conflicts and own-device echoes before download. Applicable bytes are size/hash verified into an independent staging directory and promoted only after the local apply decision; compensation never deletes an existing local candidate. A malformed event or attachment failure prevents page/cursor commit. Own-device echoes advance the remote baseline without overwriting newer local edits; another-device events colliding with pending local work preserve both candidates as a conflict.

The exact resolved base version used for an attempted deferred mutation is retained in any conflict record. Pull bounding is based on fetched page fullness: reaching the configured page cap with a full final page reports more work even when every event was an echo, duplicate or preserved conflict.

Realtime is not authoritative. Phase 6C-B private Broadcast carries only generation/revision invalidation metadata and merely schedules durable pull. A native Android/iOS connectivity EventChannel likewise emits only potentially-offline/potentially-online hints; the production runtime owns and disposes its subscription, and only offline-to-online transitions reach the coordinator's debounce/coalescing path.

## Backup, restore and privacy

Backup and sync are separate. `.keevbackup` is a user-passphrase-encrypted snapshot. Live sync is incremental readable application data protected by TLS, Supabase Auth, RLS and private Storage; it is not claimed as end-to-end encrypted and never reuses the backup passphrase.

Sync controls are Drift v8 device/transport metadata and never enter backups. A successful full restore atomically clears stale outbox/entity/conflict/cursor/cleanup metadata, removes the receipt sync spool, disables sync, and marks an existing link `needsReconciliation`. The user then explicitly chooses local primary, cloud primary, or Local Only. Signing into a different account likewise cannot activate the old link. No restored data is uploaded automatically.
