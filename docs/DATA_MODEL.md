# Data model — proposed v1

Design only. No applied database migration exists at Phase 0. Drift schema and fixture migrations are implementation Phase 2 deliverables.

## Common record envelope

Syncable records use `id` UUIDv4 from cryptographic randomness, `profile_id`, nullable `user_id` (null for Local Only), `created_at_utc`, `updated_at_utc`, nullable `deleted_at_utc`, local revision and server `version`. `user_id` is assigned/validated by server on upload; it is never authentication evidence. Use local profile scope even after cloud attach. Reference ownership is checked server-side and with profile-scoped foreign keys locally. `created_at` does not change on edit or restore. Server monotonic change cursor determines synchronization order; device clocks never choose winners.

| Entity | Fields beyond envelope | Constraints / lifecycle |
|---|---|---|
| User (server) | email, optional display name, status, verified timestamp | Unique normalized email/identity binding; pending OTP challenge is not active User |
| AuthIdentity (server) | provider, provider_subject, user_id | Unique provider+subject; linking needs fresh proof |
| Device | installation UUID, platform, revoked_at, last_seen, acknowledged_cursor | Random scoped identifier, not advertising/hardware ID; refresh credential stored separately |
| Profile | base_currency, locale, timezone, theme, cloud_mode | One personal book initially; identity separate from money accounts |
| Account | type, kind money/debt, name, currency, opening_minor, opening_effective_date, archived, sort_key | Currency/kind fixed once referenced; balance derived; archive not deletion |
| Transaction | type, amount_minor, currency, account_id, account_amount_minor, destination_account_id?, destination_amount_minor?, category_id?, occurred_at_utc, occurred_local_date, timezone_id, merchant?, note?, confirmed_voice_text?, primary_project_id? | Amounts positive within bounds; transfer source ≠ destination; income/expense category required; transfer category null |
| TransactionRate | transaction_id, from_currency, to_currency, numerator, denominator, rate_date, source, user_confirmed | denominator >0; exact decimal/rational; stable historical snapshot; same currency implicit 1 |
| Category | stable seed ID or UUID, type, localized_label_key or user_label, archived, sort_key | Income/expense type; references retained; no accounting codes |
| Budget | month YYYY-MM, timezone, currency, category_id nullable, amount_minor, warning_percent | Positive; unique profile/month/category-or-total; explicit total sentinel avoids SQL NULL uniqueness gap |
| ProjectTag | name, note, kind project/tag, archived | One primary project and optional tag links; used deletion restricted |
| TransactionTag | transaction_id, tag_id | Unique pair, same profile; tombstoned relation for sync |
| Attachment | transaction_id, file_id, relative_path, object_key?, mime, bytes, width, height, sha256, upload_state | Non-guessable file IDs; no Base64; allowlisted image type; no absolute imported path |
| PrivacyConsent | policy_version, terms_version, purpose, accepted_at, withdrawn_at?, locale | Required acceptance distinct from optional tracking/speech/analytics choices |
| SyncState | profile_id, device_id, pull_cursor, last_success_at, resnapshot_generation | Transactionally persisted with applied batch |
| OutboxOperation | operation_id, entity_id/type, base_version, local_revision, payload, dependency IDs, attempts, next_attempt_at, state | Write with entity; per-operation ACK only; never clear whole queue |
| SyncConflict | entity, base/server/local versions, reason, resolution, resolved_at | Preserve both; immutable conflict evidence until resolved and retention policy allows cleanup |
| Entitlement | store, product, transaction reference, state, signed_payload, verified_at, valid_until, linked_user? | Server/store-authoritative, cache only; excluded from backup trust |
| BackupManifest | format_version, schema_version, created_at, profile_id, record_counts, file_hashes, encryption parameters | Authenticated; no credentials; bound size and expansion limits |
| DeletionJob (server) | user_id, state, requested_at, recent_auth_ref, completed_at, processor_tasks | Idempotent, prevents further upload; no full finance payload in job logs |

## Money and currency invariants

Native integer minor amounts are bounded to 9,000,000,000,000,000 (and aggregate checked within signed 64-bit bounds); JSON uses decimal strings. Parse locale decimal text into integers without intermediate double. Keep currency exponent alongside currency metadata version in backup. No money addition across currencies without explicit conversion. Rounding is half-even at final target minor unit, not at intermediate multiplication. Cash physical rounding (e.g. tendering coins) is outside v1.

Income/expense stores both original amount and account-currency effect if currencies differ. Transfer stores source in source account currency and destination in destination account currency; an original-amount field is source currency for transfer. No user-visible debit/credit columns.

| Action | Money account effect | Debt account effect | Income/expense report |
|---|---|---|---|
| Income in selected account | +account amount | −account amount owed | Income original amount converted by recorded rate |
| Expense in selected account | −account amount | +account amount owed | Expense original amount converted by recorded rate |
| Transfer from selected account | −source amount | +source amount owed | Excluded |
| Transfer to destination | +destination amount | −destination amount owed | Excluded |

Debt is positive when owed; overpayment can be negative and must not be discarded. Net worth = money balances − debt balances, including archived but non-deleted accounts. Future entries excluded by as-of date. Opening balance is not income. A transfer and its optional fee save atomically as linked records.

## Referential and migration rules

Do not reuse deleted IDs. Tombstones retain owner/version and enough reference identity to prevent stale resurrection, not indefinitely retain deleted note/receipt content. Archive used accounts/categories/projects; no dangling transaction references. Attachments stage in file storage, database commits references, durable cleanup jobs remove abandoned files.

Migration fixtures include empty/local-only/cloud-linked/archived/multi-currency/pending-outbox/conflict books. Migrations preserve all original money and UUIDs, run transactionally, and fail to recovery without loading an empty book. Forward-only schema upgrades with app-version gate; preserve source backup during upgrade. Legacy prototype amounts validated as decimal text; date-only records remain date-only with an explicit precision flag rather than inventing a historical time. Legacy startingBalance converts to a dated opening balance only if not already represented in accounts; preview ambiguous cases.
