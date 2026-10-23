# Google Play Data Safety worksheet — not submitted

| Data category / processor | Collection or sharing | Required? / encryption in transit | Deletion / validation |
|---|---|---|---|
| Ledger financial fields, notes, receipt JPEG / Supabase | No cloud transfer in Local Only; optional live sync transfers cloud-readable records/receipt JPEG | Optional; HTTPS/TLS and own-user access | Account deletion removes cloud rows and approved Storage prefixes; local ledger remains; verify deployed RLS |
| Encrypted `.keevbackup` / Supabase | Optional private ciphertext upload; metadata includes user ID and size/hash | Optional; HTTPS/TLS; passphrase never transmitted | Cloud objects removed on deletion; exported external copies user-controlled |
| Email, user ID, OAuth profile / Supabase, Apple, Google | Optional authentication/identity exchange | Required only for cloud account; HTTPS/TLS | Auth identity removed last; provider retention separate |
| Voice audio / OS speech | Explicit speech feature; OS provider processing depends on device | Optional | No KeEv audio file retained; native validation needed |
| Ad device identifiers, approximate location, interactions, diagnostics, consent / Google Mobile Ads + UMP | Conditional third-party SDK collection/sharing when ads enabled; no financial targeting | Ads optional; SDK network TLS; UMP/ATT gate | UMP privacy options and OS settings; verify final SDK disclosure and consent region cases |
| Product, transaction ID/token, entitlement / Apple, Google, Supabase | Optional subscription flow; store payment data handled by store | Optional; HTTPS/TLS; checkout disabled by default | Private source removed on KeEv account deletion with minimal unlinked anti-replay fingerprint; store subscription remains separate |

Data Safety “collected/shared/ephemeral” answers must be checked against Google's current definitions and an instrumented signed build. KeEv does not currently add analytics or crash-reporting SDKs. The public account deletion URL, privacy URL and contact remain owner actions.
