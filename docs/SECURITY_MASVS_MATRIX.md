# Targeted OWASP MASVS alignment — Phase 9

This is an internal control mapping, not MASVS certification or a full penetration test. “Partially Verified” means repository inspection/tests passed but deployed/native behavior is outstanding.

| Group | KeEv control/evidence | Status / remaining verification |
|---|---|---|
| MASVS-STORAGE | Secure storage namespaced session, lock verifier, purchase journal; SQLite/receipts app-private; Android OS backup disabled; encrypted explicit export | **Partially Verified** — SQLite plaintext inside sandbox; iOS file protection and OS backup native QA |
| MASVS-CRYPTO | Argon2id 19,456 KiB/2 iterations/parallelism 1; AES-256-GCM authenticated header, random salt/nonce, 64 MiB bound; no custom primitive | **Partially Verified** — focused backup tamper tests exist; native restore/large-file QA |
| MASVS-AUTH | Supabase Auth with secure persistence boundary, App Lock independent, billing account binding and deletion recent sign-in | **Partially Verified** — Apple provider revocation, live account-switch/deletion tests |
| MASVS-NETWORK | HTTPS Supabase config, no global ATS/cleartext bypass, platform TLS; no pinning | **Implemented in repository**; signed release network inspection required |
| MASVS-PLATFORM | Contextual camera/microphone/photos; Android exported activity/callback reviewed; iOS purpose strings, privacy cover | **Partially Verified** — merged manifest and Xcode report/native permission prompts pending |
| MASVS-CODE | Auth-scoped RLS/RPC/Storage, server-private billing, JWS/OIDC webhooks, fail-closed checkout and ads | **Partially Verified** — apply migrations and two-user adversarial RLS tests; Edge runtime smoke |
| MASVS-RESILIENCE | Store entitlement server authoritative, encrypted backup tamper rejection, no debug bypass; no root blocking | **Accepted Risk** for rooted devices, screenshots and no obfuscation as security boundary; release signing still pending |
| MASVS-PRIVACY | Inventory/maps; Local Only/cloud distinction; UMP/ATT separation; no financial ad targeting; deletion flow | **Partially Verified** — policy/legal URLs, SDK privacy report, Play Data Safety and deletion web page owner actions |
