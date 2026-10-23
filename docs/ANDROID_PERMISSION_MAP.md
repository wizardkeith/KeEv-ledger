# Android permission map — Phase 11 merged release review

The `productionRelease` merged manifest generated with Android SDK 36 targets API 36 (min API 24). The first-party main manifest declares the following:

| Permission | Source / feature | Runtime request? | User explanation / status |
|---|---|---|---|
| `INTERNET` | App, Supabase, optional ads/billing | No | Cloud, store, ads only when configured; Local Only works without cloud. |
| `ACCESS_NETWORK_STATE` | Connectivity / sync eligibility | No | Detect connectivity; no ledger data sent for this check. |
| `RECORD_AUDIO` | Explicit Voice Entry via speech plugin | Yes, on feature use | Speech recognition; no background recording by KeEv. |
| `USE_BIOMETRIC` | Optional App Lock via local_auth | Platform prompt | Platform handles biometrics; PIN fallback remains. |

The merged manifest also contains vendor permissions:

| Permission | Merged source / purpose | Release status |
|---|---|---|
| `com.android.vending.BILLING` | Play Billing / IAP | Adapter compiled against Billing 8.0.0; checkout remains disabled by default. |
| `USE_FINGERPRINT` | local_auth compatibility | Optional App Lock. |
| `com.google.android.gms.permission.AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, `ACCESS_ADSERVICES_TOPICS` | Google Mobile Ads SDK | Present even with `ADS_ENABLED=false`; reconcile with owner Play Data Safety/ads declarations before release. No live ads are requested in the RC configuration. |
| `WAKE_LOCK`, `FOREGROUND_SERVICE` | AndroidX WorkManager transitive manifest | Background worker infrastructure; device behavior remains to be verified. |
| `com.keev.ledger.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX signature-scoped receiver protection | App-defined signature permission, not a user runtime grant. |

Receipt photo/gallery and backup import/export use native picker/document flows. The merged manifest has **no broad storage, location, contacts, SMS, phone, calendar or Bluetooth permission**. The two exported activities are the launcher and Apple web sign-in callback. Exported vendor components are Google Sign-In revocation service (protected by `REVOCATION_NOTIFICATION`), WorkManager `SystemJobService` (`BIND_JOB_SERVICE`), WorkManager diagnostics receiver (`DUMP`), and Profile Installer receiver (`DUMP`). Other Ads, Billing, picker and auth components are not exported. `allowBackup=false`, `fullBackupContent=false`, and the data extraction rules remain in the merged application; no cleartext opt-in appears. Real-device permission and background behavior still require owner/CI verification.
