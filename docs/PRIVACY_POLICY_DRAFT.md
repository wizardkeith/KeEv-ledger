# KeEv Ledger privacy policy — DRAFT, NOT FOR PUBLICATION

**Owner/legal review required.** Product: KeEv Ledger; operator: KeEv Global Services Limited (Hong Kong). OWNER ACTION REQUIRED: registered/contact details, privacy contact, effective date, applicable rights procedure, actual processor agreements/regions, approved retention periods, final links and translations. This draft describes repository behavior and must be tested against a signed production build.

## Your choices and data

The app works in **Local Only** without a KeEv cloud account. Your profile, balances, accounts, categories, transactions, budgets, projects, notes and processed receipt JPEGs reside in the app's private device storage. SQLite is not separately encrypted; the OS app sandbox and optional PIN/biometric App Lock protect casual access. You can create an encrypted `.keevbackup` with your passphrase and choose where to save it. We cannot recover a lost backup passphrase.

If you choose cloud sign-in, Supabase processes your account UUID, email or selected Apple/Google identity and session credentials. **Encrypted Cloud Backup** stores only client-encrypted backup ciphertext and metadata in private Storage. **Live Sync**, if separately enabled, stores individual financial ledger records and receipt JPEGs in Supabase Postgres/private Storage so KeEv infrastructure can process them; it is protected by TLS, authentication and access rules but is **not end-to-end encrypted**. The planned Supabase project region is Singapore; verify the actual region before publication.

Voice Entry starts only when you use it. KeEv does not retain raw audio; platform speech recognition may process audio under OS/provider behavior. Receipt photos are resized/re-encoded, removing most original metadata, and kept in private app files; only the optional backup/sync paths transmit them. User-selected CSV and backup exports outside the app remain under your control.

If advertising is enabled, Google UMP handles applicable consent messages. The Google Mobile Ads SDK may process device identifiers, approximate location, ad interactions and diagnostics according to consent and platform settings. ATT is separate from UMP. KeEv does not intentionally send amounts, merchants, categories, notes or receipt contents to advertising services. Ads failure does not block bookkeeping.

If you purchase a subscription after checkout is enabled, Apple/Google handle payment information; KeEv's trusted billing server handles only necessary product, transaction, account-binding and entitlement proof. It does not receive ledger financial content as purchase metadata. Checkout defaults disabled until store acceptance.

## Security, retention, deletion

We use secure device storage for session credentials and App Lock verifier, and server-only secrets for store verification. Cloud account deletion in Settings requires recent authentication; for an Apple-linked identity we request fresh Apple authorization and revoke it through Apple before removing KeEv cloud data, receipt and backup objects, and Auth identity after cleanup; current device ledger remains and becomes Local Only. It does **not** cancel a store subscription. Limited private anti-replay fingerprints and deletion-job state may remain; legal retention decision pending. Supabase/Apple/Google infrastructure and user-chosen external exports can have separate retention. See `DATA_RETENTION.md`; no unapproved statutory duration is promised.

You can request cloud-account deletion in the app. OWNER ACTION REQUIRED: publish an accessible HTTPS web deletion request page, approve identity verification and contact/rights workflow, and supply exact production URLs. Supabase and platform provider subprocessors and cross-border terms require owner/legal confirmation. This document is not a legal assurance or final App Store/Play disclosure.
