# App Store privacy answer worksheet — owner review required

This is not a submitted privacy label. “Collected” means transmitted off device in the indicated optional mode. Final answers depend on enabled SDKs, Xcode aggregated privacy report and App Store Connect definitions.

| Category | Collected / linked / tracking | Purpose and recipient | Retention / decision |
|---|---|---|---|
| Financial information; user content (notes, receipts) | No in Local Only; yes and linked to UUID with live sync; no advertising tracking | Supabase cloud sync, private receipt Storage; backup ciphertext only in separate encrypted-backup mode | Until user removes/account deletion; processor backup retention owner review |
| Email, user ID, provider identity | Optional cloud account; linked; not used for ad targeting | Supabase Auth; Apple/Google sign-in when chosen | Auth lifecycle; provider's own policy applies |
| Audio/transcript | KeEv does not retain raw audio; OS speech processing may leave device | Explicit Voice Entry | Verify OS/provider behavior on native builds |
| Purchases/product and entitlement | Only after store purchase; linked to KeEv account UUID, not financial ledger | Apple/Google store and Supabase private verification | Minimum fraud replay fingerprint remains after deletion pending legal decision |
| Identifiers, advertising/usage signals, coarse location, diagnostics | **Conditional SDK collection** when ads enabled; possible link/tracking depends UMP, ATT, SDK setting | Google Mobile Ads / UMP ad delivery and consent | Reconcile Google's current SDK disclosure with actual production network capture; IDFA only if authorized when tracking enabled |
| Crash/analytics SDK telemetry | No KeEv crash/analytics SDK installed | None presently | Recheck native transitive SDK behavior |

Runner `ios/Runner/PrivacyInfo.xcprivacy` declares the following **first-party** categories, each linked to identity, not used for tracking, with `App Functionality` as purpose. Optional cloud features still collect data when enabled; Local Only data that stays on-device is not cloud collection. It is included in Runner resources.

| Manifest category | KeEv first-party flow |
|---|---|
| Name, Email Address, User ID | Optional cloud profile, authentication and account UUID |
| Device ID | App-generated per-installation ID in optional account-linked live sync metadata |
| Other Financial Info | Account/transaction/budget ledger fields in optional live sync (not ad targeting) |
| Photos or Videos | Optional receipt JPEGs in private sync Storage |
| Other User Content | Optional notes/descriptions in live sync |
| Purchase History | Store product/transaction and verified entitlement bound to cloud account once purchases are enabled |

`NSPrivacyTracking=false` describes KeEv's first-party collection; third-party ad SDK tracking/consent has its own disclosure and UMP/ATT boundary. The first-party Runner Swift/Obj-C source currently uses no covered Required Reason API, so the Runner manifest has no `NSPrivacyAccessedAPITypes`. This is not a vendor manifest substitute. Owner/CI must inspect the resolved archived app's aggregated Xcode privacy report, vendor manifests/signatures, and final App Store Connect answers; revise declarations if production behavior differs.
