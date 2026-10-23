# Phase 6 final architecture

Status: **PASS — REPOSITORY IMPLEMENTATION COMPLETE**

- Drift **v8** remains the immediate local-first working store.
- Local writes and durable outbox intent are atomic; deterministic entity chains, retry timing and stable mutation IDs survive crashes/offline use.
- Generation-gated push uses optimistic server versions and idempotent receipts. There is no silent last-write-wins.
- Pull replays immutable revision snapshots strictly in server order; each page, entity baseline, conflict and cursor commit atomically.
- Conflicts preserve both candidates. Keep Local serializes current local state into a new mutation; Keep Cloud safely installs current remote state.
- Receipt sync uses private Storage, processed JPEGs, hash/size verification, spool/staging and post-commit-safe cleanup.
- Four-case onboarding, explicit destructive reconciliation, generation rotation and server-time initialization leases prevent stale-device writes and abandoned initialization wedges.
- One bounded single-flight coordinator handles manual, cold-start, resume, connectivity, retry-due, private Broadcast and optional background triggers.
- Realtime is a minimal private invalidation hint only. Missing messages are recovered by normal durable pull.
- Background execution is best effort through a UI-free bounded boundary; native scheduling is not authoritative and requires owner platform verification.
- Generation-scoped device acknowledgements protect change history. A durable pruned-through floor prevents stale cursors from skipping missing revisions and requires full reconciliation. The stale-device window is 180 days; mutation receipts retain at least 365 days; unsafe age-only tombstone deletion is absent.
- Initial link and every caught-up empty sync persist a bounded device heartbeat; floor/head validation prevents stale or impossible acknowledgements. Best-effort server unlink marks the authenticated matching registration unlinked without sacrificing offline local unlink.
- Production Android/iOS connectivity observers are owned by the runtime and feed only offline→online hints into the existing bounded single-flight coordinator.
- Android connectivity EventSink calls are explicitly marshaled to the main Looper; iOS continues dispatching on the main queue.
- Drift v8 has an authoritative generated schema snapshot and migration helper containing the onboarding/runtime tables.
- Local Only and encrypted `.keevbackup` remain independent of readable live-sync records protected by TLS, Auth, RLS and private Storage.
- Repository verification: final retention/device-lifecycle smoke and standalone Dart analysis pass with no issues. Focused Flutter tests and Flutter analysis were attempted but the bundled launcher crashes before execution with Dart VM `BUS_ADRERR`; Android compile was attempted but its uncached Gradle distribution was network-blocked. Owner/CI execution remains required and no Flutter/native pass is claimed.
- External acceptance remains: Flutter/native CI, migrations, two-user isolation, real iOS/Android multi-device matrix, private Broadcast/receipts, concurrency, and maintenance scheduling review.
- Repository status is PASS independently of the separate owner/CI/live acceptance requirement. Native builds, native background scheduling, staging migrations, real RLS/Broadcast/two-device/receipt testing, scheduled maintenance, and Flutter verification remain owner actions where this environment cannot execute them.
