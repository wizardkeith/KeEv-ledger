# Phase 6C-B checkpoint

Status: **PASS — REPOSITORY IMPLEMENTATION COMPLETE**

- Drift schema: **v8**. The authoritative generated `drift_schema_v8.json` and generated migration helper now include both v8 onboarding tables.
- Lifecycle: one coordinator performs non-blocking cold-start and 45-second-debounced resume attempts after auth/link eligibility is known.
- Connectivity: provider-neutral observer plus native Android `ConnectivityManager` and iOS `NWPathMonitor` EventChannel wiring. The runtime instantiates and disposes the observer; offline→online remains a three-second-debounced hint only.
- Single-flight: `SyncController` owns one engine pipeline and coalesces concurrent lifecycle, connectivity, Broadcast, manual and background triggers into at most one bounded follow-up.
- Realtime: existing Supabase SDK private Broadcast channel, scoped to account + generation. Payload is only event type, generation and newest revision; Drift never consumes Broadcast data.
- Foreground retry: one reschedulable timer uses the earliest persisted `next_attempt_at`; it is cancelled outside foreground or when link state becomes ineligible.
- Background: UI-free bounded worker boundary implemented. No native background plugin was added without an executable native toolchain; real iOS/Android scheduling remains owner integration/verification. Correctness is independent of it.
- Device acknowledgements: per-user acknowledgements remain monotonic within one generation and reset to the incoming revision when the device changes generation.
- Device lifecycle gate: onboarding registers even an empty dataset at its safe cursor; a caught-up empty pull heartbeats the durable cursor and refreshes server time. Acknowledgement below the floor reconciles, acknowledgement above the authoritative head is rejected, and heartbeat failure prevents a false caught-up success.
- Unlink: the production controller uses the provider-neutral server unlink contract when account/device/generation match, then completes local unlink even when the network/auth call fails. The RPC affects only `auth.uid()` and the matching device/generation.
- Android connectivity: initial and callback EventChannel emissions are posted through `Handler(Looper.getMainLooper())`; safe callback unregister remains unchanged. iOS main-thread dispatch is preserved.
- Retention: migration `202609230006_sync_retention_safety_v1.sql` records a monotonic pruned-through history floor. Pull below it returns structured reconciliation before serving events. Active devices seen within **180 days** protect history; mutation receipts retain at least **365 days**; canonical tombstones are not automatically hard-deleted. Maintenance remains unavailable to mobile roles and unscheduled.
- Security: private Broadcast authorization, `auth.uid()` ownership, empty search paths, direct canonical writes unchanged, maintenance denied to `PUBLIC`/`anon`/`authenticated`, and no client service-role secret.
- Migration: `202609230007_sync_device_lifecycle_safety_v1.sql` replaces acknowledgement/unlink RPCs without altering Drift v8 or earlier exported migrations.
- Tests: empty first-link registration, empty-pull cursor heartbeat, heartbeat-failure status, generation reset, history-floor/head bounds, own-device unlink scope, offline local-unlink ordering, Android main-Looper delivery, connectivity coalescing and stale-device history-floor coverage were added/retained. Retention/device-lifecycle pure-Dart static smoke **passed** and `dart analyze --no-fatal-warnings` **passed with no issues**.
- Flutter verification: focused tests and `flutter analyze --no-pub` were attempted; the bundled Flutter launcher terminates before execution with Dart VM `BUS_ADRERR`. No Flutter test/analyze pass is fabricated. Owner/CI must run them with a healthy SDK.
- Native verification: Android Kotlin compile was attempted, but the uncached Gradle 9.3.1 distribution could not be downloaded in the restricted network environment. iOS build was unavailable. Native compile/runtime verification remains owner/CI work.
- Native/live requirements: apply migrations through 007; validate acknowledgement bounds/heartbeats, online unlink isolation, two-user RLS/Broadcast, two-device sync, receipts, generation reset, background behavior, and scheduled maintenance in staging.
- Displayed Work usage: unavailable to the implementation environment.
- No later product/commercial phase was started.
