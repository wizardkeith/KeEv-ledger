# Privacy data map — implementation target, not published policy

## Phase 7 advertising boundary

Google UMP refreshes consent information after the user enters the ledger on
each app launch when ads are enabled. UMP, not IP/VPN/locale or KeEv company
jurisdiction, decides which supported regulatory message applies. Mobile Ads
is initialized only after UMP `canRequestAds` is true. The privacy-options
entry point appears when UMP reports it required. UMP/SDK device storage,
consent strings and ATT status are device/regulatory state and are excluded
from `.keevbackup`.

Phase 7 does not intentionally send ledger records, amounts, balances,
merchant/category/project names, notes, receipts, sync metadata or cloud IDs
to advertising services. Google Mobile Ads may process ordinary advertising
SDK data such as IP-derived/coarse location, device/app identifiers,
interactions, diagnostics and consent signals depending on platform, consent,
SDK settings and ad delivery. App Store Privacy and Play Data Safety responses
must be reconciled with the production AdMob configuration and a release
network/privacy report. ATT is separate from UMP. The app does not prompt ATT
at startup; tracking-dependent behavior is disabled by default, and denial
does not block bookkeeping or non-IDFA ad requests supported by Google.

Version 0.12 / 23 September 2026. Phase 7 adds the consent-gated advertising boundary described below. Phase 6C-B adds bounded lifecycle/connectivity attempts and private Broadcast invalidation while durable push/pull remains authoritative. Local Only remains the default and authentication does not enable sync. Supabase may receive generation, app-generated device ID, acknowledged revision, server-time last-seen, and minimal invalidation metadata; Broadcast contains no ledger or receipt fields. Analytics, OCR and AI parsing remain absent. Reconcile this map with configured Supabase/Apple/Google/SMTP processors and release network capture before Policy, App Privacy or Data Safety submission. Original prototype policy must not be reused.

Retention timings below are historical planning suggestions, not implemented or approved commitments. Use `DATA_RETENTION.md` and owner/legal review for actual decisions. Verify processors and actual deployment before production collection.

| Data | Purpose | Planned storage | Leaves device? / processor | Proposed retention | Deletion behaviour |
|---|---|---|---|---|---|
| Email | OTP identity, cloud access | Supabase Auth; optional account metadata in secure session | Only after user initiates cloud signup/login; Supabase and email delivery processor (production SMTP owner action) | Account lifetime; expired challenge metadata subject to configured bounded abuse window | Trusted account-deletion backend required; justified anti-abuse records minimized |
| Optional display name | Recognizable cloud account | Local/server profile | Cloud mode; host TBD | Until changed/deleted | Remove with profile/account |
| OAuth subject / relay email | Apple/Google identity linking | Supabase Auth identity store | Apple/Google and Supabase after explicit sign-in | Until unlink/delete | Revoke/delete through trusted account service; provider may retain its own records |
| Refresh/access tokens | Session access | KeEv namespaced Keychain/Keystore secure storage plus Supabase server session; never Drift/preferences | Supabase/provider only | Session expiry/revocation | Permanent rejection/sign-out clears KeEv record; temporary outage preserves recoverable credentials |
| Transactions/merchant/notes | Personal history/reports | SQLite; cloud DB only after opt-in | API host TBD in cloud sync; backup object host if enabled | User keeps records; deletion policy/tombstones below | Remove payload, sync tombstone, purge on account deletion |
| Money accounts/categories | Balances/classification | SQLite; optional cloud | API host TBD | Until user/account deletion; archive not delete | Preserve referenced history until safe explicit removal |
| Budgets | Spending progress | SQLite; optional cloud | API host TBD | Until user/account deletion | Versioned delete/tombstone |
| Projects/tags | Optional grouping | SQLite; optional cloud | API host TBD | Until user/account deletion | Archive retains; deleted payload/links handled consistently |
| Receipts/photos | Optional transaction evidence and user-initiated recovery | Processed JPEG in private app-support files; metadata/storage key/hash in SQLite; encrypted inside optional `.keevbackup` | Live sync can send readable receipt JPEGs to private Supabase Storage; optional cloud backup sends encrypted ciphertext only | Until user removes attachment; cloud snapshot retained until user deletes it | App-owned file removed after metadata; recognized staging/orphans reconciled; original library photo never changed/deleted |
| Speech audio | Optional Quick Add transcription | Transient platform recognition session; not written by KeEv | May leave device for the OS/platform speech provider; capability varies by device and locale | KeEv does not persist audio; provider behavior/retention requires native release verification | Stop/cancel foreground session; KeEv retains no audio file |
| Voice transcript | Suggested Quick Add fields | Temporary screen memory only | KeEv sends it to no LLM, analytics or other service | Until screen/session ends | Discarded; not automatically copied to transaction note or SQLite |
| Installation/device UUID | Device sync/revocation | Local + registered server Device | API after cloud opt-in | Active device lease then approved purge | Revoke/unregister; not shared for ads |
| PIN verifier / retry state | Optional local app unlock | Versioned salted PBKDF2 verifier and throttle state in platform secure storage; never Drift/preferences | No | Until authenticated lock disable, app data removal or device erase | Authenticated disable removes the lock record; excluded from bookkeeping/export/portable backup |
| Biometric templates | Optional local app unlock | OS only, never KeEv | KeEv never receives templates; OS prompt returns status/result | OS policy | OS controls enrollment; changing availability safely falls back to the configured PIN |
| Consent/policy version | Record user choices | SQLite; optional cloud minimal record | Host only as needed | Account lifetime / justified compliance window | Withdraw optional consent; minimize retention |
| Purchase records | Entitlement and restore | Apple/Google, verification service, signed cache | Store + API verifier | Required entitlement/retention period TBD | Revoke cache; store/legally required records may remain; explain |
| Cloud backup | User-initiated phone recovery | AES-256-GCM `.keevbackup` ciphertext in private Supabase Storage; minimal metadata in Postgres | Supabase receives authenticated user ID, ciphertext, encrypted size/hash and normal network metadata; not passphrase/plaintext ledger/receipts/App Lock data | User-controlled immutable snapshots; no automatic retention in Phase 5C | User deletes one backup; account cascade/Storage cleanup requires production verification |
| Live sync (explicit opt-in) | Optional cross-device ledger continuity | Individual ledger rows and immutable revision snapshots in private Supabase Postgres; receipt objects in separate private Storage | After Enable Sync confirmation, Supabase may receive account ID, ledger/entity values, timestamps, versions/revisions, opaque dataset/device/initialization IDs, mutation metadata, conflict response state, receipt metadata and private receipt JPEGs. Private Broadcast carries only generation/revision invalidation. TLS/Auth/RLS apply; this is not backup-passphrase E2EE | Active devices seen within 180 days protect history; mutation receipts retain ≥365 days; maintenance is owner-scheduled; canonical tombstones retained in v1 | Versioned tombstones propagate deletion; unlink leaves both ledgers, Keep Local rotates generation, and account deletion cascades cloud rows after exact-prefix Storage cleanup |
| Portable backup/export | User-controlled migration/export | App temp then user-chosen destination | No KeEv upload; Share Sheet destination chosen by user | Temp ≤24h; external copy user-controlled | App clears temp; cannot delete user's shared copies |
| Crash reports | Optional diagnostics | Disabled by default | None until processor selected; no financial content | Proposed 30 days if enabled | Delete processor records per approved policy |
| Product analytics | Optional coarse usage | Disabled by default | None until selection/consent | Proposed 30 days aggregate/minimal | Withdraw, stop SDK; delete attributable data |
| Advertising SDK data / identifiers | Consent-gated banner delivery and measurement; no ledger targeting | UMP/Mobile Ads device state; no KeEv ledger table or backup | Google Mobile Ads only after UMP permits requests; IDFA unavailable unless ATT authorizes it | Google/SDK policy and configured message dependent; production disclosure review required | UMP privacy options/OS controls affect future requests; no financial targeting |
| Sync tombstones | Prevent resurrection | Local/server metadata only | API in sync mode | Proposed 90 days plus active-device acknowledgement | Purge payload promptly; old devices forced resnapshot |
| OTP challenge/abuse counters | Verification/rate limiting | Server only | Email processor receives delivered code | Code ≤10min; bounded counters e.g. 24h pending approval | Atomic consume/expire then purge; never logs |

Mandatory policy acceptance is separate from optional advertising tracking. Camera/microphone/photo requests contextual. Local Only does not require Auth or sync; ads may operate if explicitly configured and UMP permits them. FX reference request reveals network metadata even without finances; fetch only when requested/enabled and disclose proxy/processor.

Final publishable policy needs owner contact/privacy email, controller address, markets/age audience, named processors/regions, retention/deletion commitments, store purchase implications and user rights handling. Legal/wording review is a release gate, not a claim that a draft ensures compliance.

## Subscription purchase metadata (Phase 8A)
Apple/Google process store account, payment and transaction data under their policies. KeEv captures the store product identifier, opaque transaction identifier/token or verification material and KeEv account UUID in secure device storage for later server verification. The Phase 8B server receives this account-level purchase proof, separate from ledger content. Ledger balances, notes, merchants, receipts and other financial content are never supplied as purchase metadata. Purchase state and tokens are excluded from `.keevbackup` and ledger sync.

## Phase 8B-A billing metadata

The server processes Apple signed transaction identifiers and `appAccountToken`, or Google purchase token, subscription product/base-plan and obfuscated account ID. Only a token fingerprint and minimal source status are needed for lookup; raw Play token is private server data for later API refresh. A sanitized capability/expiry snapshot is readable by its owner. No ledger transaction, receipt, balance or note is sent to the stores. KeEv account deletion is separate from App Store/Play subscription cancellation.

## Phase 8B-B provider events

The server receives signed Apple Notifications V2 and authenticated Google Pub/Sub RTDN. It stores event UUID/message ID, provider, environment, event type/time, source fingerprint and processing status in a server-private table; the raw JWS, OIDC bearer, RTDN body and Play token are not stored there. The existing server-private purchase table retains only the Play token necessary for trusted status refresh. An hourly trusted reconciliation reads current subscription status from Apple/Google without Flutter or ledger data. Proposed event-ID/audit retention is 400 days subject to owner privacy/legal approval; no automatic event deletion is enabled. Financial ledger contents are never sent to store APIs.

## Phase 9 account deletion

The authenticated server operation requires recent sign-in, clears only the caller UUID prefixes in private backup/receipt Storage, writes minimal private billing identity tombstones, removes raw purchase tokens and user-owned billing sources, then deletes the Auth identity so user-owned SQL rows cascade. A server-private deletion job blocks stale-JWT Storage uploads. The current device ledger remains and sync is unlinked after success. Apple/Google subscriptions are not cancelled. Legal retention, Apple identity-provider revocation, live migration/RLS tests and processor backup retention remain release actions; see `DATA_RETENTION.md`.

Phase 9 Fix Gate: Apple-linked deletion uses an ephemeral native authorization code and identity token sent only to the authenticated deletion Edge endpoint. The server verifies linked identity, exchanges the code, revokes Apple authorization, and discards returned Apple tokens in memory before account cleanup. The Runner manifest reports linked first-party optional cloud and purchase categories; vendor ad SDK disclosures remain separate.
