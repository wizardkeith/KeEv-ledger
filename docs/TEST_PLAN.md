# Test plan and evidence policy

Every result must identify source version, command, environment, date and pass/fail/blocked status. A screenshot or mocked API never proves live authentication, billing, cloud restore or native hardware functionality. Current results are in checkpoints/PHASE_0.md.

## Mandatory suites

| Level | Meaningful cases | Gate |
|---|---|---|
| Unit: money | HKD 0.10+0.20 exact; JPY/VND precision; invalid/grouped localized inputs; overflow; half-even ties; absent FX; changed base currency | Phase 2/3 |
| Unit: transfers | Bank→cash conserves value; card purchase increases owed; card repayment excluded from expense; HKD 780→USD 100; self-transfer rejected; fee separate; edit/delete affects both sides | Phase 2 |
| Unit: accounts | Opening effective date; currency/kind mutation blocked after use; reorder persists; archive retains net worth; zero/negative debt displayed | Phase 2 |
| Unit: budget | Month/time-zone edges; category+total uniqueness; no transfer spend; 80% warning; overspend; missing FX incomplete; base-currency change review | Phase 3 |
| Unit: report | Ranges including prior account balance; as-of future exclusion; comparison zero; archived inclusion; totals identical across UI and export | Phase 3 |
| Unit: export | CSV quote/newline/formula/control prefix; locale vs machine-readable fields; no mixed-currency nominal sum; temporary file cleanup | Phase 3 |
| Unit: backup | Version migration; future-version reject; malformed bounds; bad tag/hash; wrong passphrase; malicious KDF parameters/path traversal; interrupted restore rolls back; no secret/entitlement trust | Phase 3/5/6 |
| Unit: sync | Duplicate op, concurrent edit during push, stale tombstone, device cursor expiry, clock skew, transfer conflict, 401/429/backoff, deletion race | Phase 6 |
| Unit: entitlements | forged local flag/cache, pending/cancel/refund, signed expiry, restore replay, cross-user claim | Phase 8 |
| Widget | onboarding acceptance version; local route without login; quick entry/keyboard/double tap; localized validation; login OTP state; settings; report gating; deletion confirmation | Each relevant phase |
| Widget accessibility | Five locales, light/dark, 200% text, semantics, focus order, minimum touch targets, contrast; long names, Thai/Japanese breaks | Phase 1 onward |
| Integration local | Clean install offline→accept→save→kill process→relaunch; DB upgrade; low disk; receipts intact; no background processor network before consent | Phase 2/4/10 |
| Integration identity | Delivered email OTP expiry/rate limit/replay; Apple/Google sign-in/cancel/revoke; identity linking; reauth deletion; no credentials logged | Phase 5/9 |
| Integration cloud | Offline writes→online; record+receipt restore; account switching isolation; full interruption recovery; sign-out worker stop | Phase 6 |
| Integration native | Real camera/gallery denial/restricted/limited state; EXIF; speech offline capability+review; biometric enrolled/none/lockout; lifecycle cover | Phase 4/10 |
| Integration stores | Purchase pending/cancel/fail/success; acknowledge; reinstall restore; refund notification; no network; sandbox vs production receipt rejection | Phase 8 |
| Backend adversarial | Two user IDs, foreign references/object keys, token audience/expiry, OTP races, deletion retries, input limits | Phase 5–9 |

## Migration matrix

| Journey | Required observation |
|---|---|
| Local-only→cloud empty | All UUIDs/counts/money/attachments retained; no forced destructive source removal |
| Local-only→existing cloud | Both datasets preserved, collision preview and resumable idempotent attach |
| Cloud→new phone | Verified login; identical record counts, balances and attachment hashes |
| Android→Android | Encrypted backup and cloud restore both tested |
| iOS→iOS | Encrypted backup and cloud restore both tested |
| Android→iOS | Versioned format independent of filesystem/Keystore; lock re-enrolled |
| iOS→Android | Same; no imported trusted purchase cache |
| Old backup→new version | Deterministic migrations; unsupported future version rejected |
| Offline→online | Outbox resumes once; edits during sync remain queued |
| Two devices same record | Both edits retained until explicit resolution; no duplicate spending |
| Deleted cloud account + stale device | Upload refused; local retain choice honoured |

Run automated unit/widget/database tests at the phase that introduces each risk, not postponed to Phase 10. Phase 10 combines QA/accessibility/physical devices. No passing dummy “cloud sync” test against an always-successful fake is an integration pass.

Prototype characterization uses Node's TS stripping with a UID-only shim for unused constructors. It runs original computational functions without React dependencies. Results assert **observed defects** and two behaviours worth preserving, not production correctness. Run `node tools/characterize_prototype.mjs /path/to/extracted/prototype`. Old suite failures remain reference evidence and are not altered in the supplied workspace.
