# Owner decisions and minimal external actions

No need to ask whether Flutter/local-first/five locales/Apple+Google+email/native billing are wanted: these are already specified. We chose repository boundaries, integer money, exact transfer sides, archived-history preservation, ARB, outbox/version conflict rules and passwordless email OTP without delaying for preference questions.

## Immediate execution blocker

Automatic approval review rejected the Flutter SDK version command after the attempted SDK setup. Stated reason: unexpected access to cloud instance metadata could expose environment credentials. Do not rerun, wrap or route that same action indirectly to bypass review. Initial `flutter analyze` / `flutter test` were unavailable (`flutter: command not found`). The SDK release manifest download attempt returned HTTP 404. Flutter toolchain verification is therefore not established.

Minimum next arrangement: authorize a clean Flutter build environment that does not access instance metadata, or supply an already verified Flutter/Dart toolchain/build workspace. No Apple/Google production credentials are needed for Phase 1. This is an environment gate, not a request to reapprove product scope. The rejected action is not a request to allow reading cloud metadata.

## Later decisions (do not block local foundations)

| Decision / exact input | Needed by | Why owner input is required | Prepared default |
|---|---|---|---|
| Cloud hosting/data region, processors and monthly operating budget | Before Phase 5 provisioning | Financial data residency, costs/contracts and retention promise | Provider-neutral API+private PostgreSQL+object storage; no service subscribed |
| Email sending domain and privacy/support contact | Phase 5 / privacy publication | Domain control, delivery and customer support ownership | OTP service contract prepared; no fake sender |
| Production bundle/package ID ownership, legal store entity/team | Before registering platform/OAuth apps | IDs/ownership are external durable commitments | `com.keev.ledger` provisional from prototype |
| Premium bundle vs separate purchases, prices, cloud charging model | Before Phase 8 catalog registration | Commercial promise and recurring service cost | Support given two non-consumable IDs; recommend simple bundle for local advanced features, cloud cost separate |
| Advertising provider and launch markets/audience | Before Phase 7 SDK enablement | Regional consent, age restrictions, processors and terms | AdService design; SDK off until settled |
| Final retention/deletion timing, controller address/policy/Terms | Before Phase 9 publication | Operational/legal commitments need real accountable owner | Draft data map with bounded proposed times, not published policy |
| Apple/Google/OAuth/signing/backend secrets securely configured | Phase 5/8/11/12 | Requires owner-controlled credentials and external accounts | Credential checklist, no secret in source/chat |
| TestFlight/Play invitations and submissions | Phases 13–16 | External actions involving testers/store accounts | Prepare concrete build/package first; obtain minimal required authorization |

Optional secure QR migration, Facebook and PDF are post-v1 backlog. This reconciles the “three migration paths” roadmap with the explicitly optional third workflow. If three paths are a launch condition, move QR into release scope before the Phase 6 gate; no current implementation depends on pretending it exists.
