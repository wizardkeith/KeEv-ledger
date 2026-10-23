# Drift v8 sync onboarding schema

Schema v6 introduced device/transport state. Schema v7 keeps the ledger model unchanged and makes the outbox executable: an SQLite-generated `queue_sequence`, immutable mutation/payload/base, pending/processing/blocked state, attempt count, last/next attempt times and safe failure code. `sync_conflicts` retains remote revision, while `sync_receipt_spool_entries` and `sync_attachment_cleanup` track private file transport recovery.

The v5→v6 migration preserves every ledger/receipt row, creates a random installation UUID, starts unlinked and disabled with cursor zero, and creates no historical outbox or fake cloud account. The device ID is app-private diagnostics/idempotency origin, not authentication or tracking identity.

The v6→v7 migration preserves existing mutation identity/payload, initializes runtime fields conservatively, and never fabricates an attempt or acknowledgement. Per-entity queue order is durable; unresolved successors have a null base until the predecessor result supplies it. Processing is persisted before an RPC and recovered without changing mutation meaning.

The v7→v8 migration adds one `sync_onboarding_state` control row containing the cloud dataset generation, initialization operation ID/stage, manual pause flag, and last safe caught-up timestamp. Existing linked v7 state has no trustworthy generation, so it becomes `needsReconciliation`; the migration never invents one. Business rows, receipt metadata, device ID, conflicts, and outbox rows are preserved. Pause stops remote execution while capture continues for the same healthy link. Unlink retains user ledger/device ID but clears transport association and future capture.

Sync metadata and receipt spool bytes are excluded from logical backup. Full restore clears stale cursor/entity/outbox/conflict/cleanup assumptions, removes spool bytes, and marks an existing cloud link `needsReconciliation`; it never uploads automatically. Authentication, capture eligibility and remote execution remain separate.

A never-attempted receipt create→delete chain may compact to no remote operation. Its spool metadata is removed atomically with the chain, then an idempotent post-commit check removes the physical JPEG only when no spool reference remains. Attempted or uncertain creates keep both metadata and bytes. Local hash/metadata corruption blocks the mutation for intervention; network, rate-limit and backend transport failures retain durable retry timing.
