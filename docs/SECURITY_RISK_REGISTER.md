# Material residual risks — Phase 9

| Risk / impact | Current mitigation | Blocker? / next action |
|---|---|---|
| Flutter IAP packages absent from `pubspec.lock`; native purchase adapter never compiled here | Checkout defaults off; server proof required | **Yes before checkout**: compatible Dart ≥3.13.4, `flutter pub get`, full suite/analyze and native builds |
| Live billing/webhooks and deletion Edge runtime not exercised | Deterministic Node tests, private SQL, no production checkout | **Yes before billing/deletion release**: staging Edge imports, SQL migrations and Apple/Google sandbox/live tests |
| SQLite and receipts are plaintext in app sandbox; iOS file class/OS backup unverified | App Lock, sandbox, explicit encrypted backup; Android OS backup disabled | **Native QA**: inspect on-device iOS protection and iCloud backup, decide whether narrower exclusion is needed |
| Apple revocation not yet verified on live Sandbox; processor backup/anti-replay retention undecided | Fresh Apple reauth, server JWKS identity check and code exchange/revoke before cloud cleanup; stale JWT upload denied | **Yes for account-deletion release**: live Apple/Supabase acceptance; owner/legal decide retained metadata and backup lifecycle |
| Supabase Storage or canonical RLS rules not live-tested in this environment | Own-user policies, private buckets, service-only billing/deletion RPC | **Yes**: apply migration, inspect grants, two-account attack tests, deletion retry and object scope |
| Native SDK manifests/signatures, Xcode aggregated report and final ad data disclosure unresolved | First-party manifest exists; ads/ATT gated off by default | **Yes for submission**: signed archive privacy report, dependency review, final disclosures |
| Published privacy policy/terms and Play web deletion link missing | Development links hidden in release without valid HTTPS config | **Yes**: owner/legal approve and publish exact URLs; provide support contact |

Root/jailbreak checks and blanket screenshot bans are not introduced; they could harm access without changing the cloud/account trust boundary. No certificate pinning is added without a rotation/recovery plan.
