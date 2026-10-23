# Actual/conditional production processors

| Processor | Purpose and data when enabled | Boundary |
|---|---|---|
| Supabase | Optional Auth, cloud-readable live ledger, private receipt Storage, encrypted backup ciphertext, Edge billing and deletion | Preferred owner project region Singapore; verify actual deployment, DPA and backup retention |
| Apple | Optional Apple sign-in, App Store purchase/notifications, OS biometrics/ATT and StoreKit | Store billing not cancelled by deleting KeEv account |
| Google | Optional Google sign-in, Play Billing/Developer API/RTDN, Mobile Ads/UMP, Google-hosted Pub/Sub | Advertising receives SDK signals, never KeEv financial targeting; feature gated |
| Platform speech provider | Voice Entry speech recognition on explicit use | Native behavior may vary; no raw audio retained by KeEv |

No Firebase backend, behavioral analytics or crash SDK is added. Owner must identify any actual production email delivery/hosting subprocessors and legal agreements before publishing the privacy policy.
