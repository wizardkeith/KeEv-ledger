# Initial GitHub import — 24 October 2026

Prepared at 2026-10-24T00:27:03+08:00 from the complete Phase 11 Native Build Fix Gate source archive. Archive SHA-256: `582fbcb1ddd60f159abdbd07220bcbd81adc3a6d9cd09a81c7d4aa4b6280afcb`.

The source archive contains 532 files. This import retains 519 original source files and omits exactly 13 generated or machine-local files listed in [the immutable source manifest](imports/2026-10-24-source-manifest.json). It adds current project/agent/import documentation, updates the stale README, adjusts ignore rules for portable checkouts, and marks Gradle/shell entry scripts executable. Application source, tests, dependencies, native build configuration, assets and licences are unchanged.

Historical `CHECKPOINT_SHA256.json` and other phase manifests remain evidence for their original checkpoints. They are not claims about the current Git tree.

The original native-build evidence was inspected during recovery. Its final test log has 322 successful testDone events, zero skipped events, and done.success=true. Analyze/build/lint/alignment results are historical records from that gate, not executions performed in the recovery workspace. The retained GitHub quality gate started automatically after the import; its separate run is linked in PROJECT_STATE.md and must not be confused with those historical results.

Required five font files and their five OFL licences are included. Real environment values, signing keys, customer/user databases and build binaries are not included. The published unsigned APK/AAB are separately retained artifacts.

Source transfer does not automatically create Codex Cloud environments, connect Evana to a computer, enable ongoing synchronization, or publish the app. Use `PROJECT_STATE.md` as the shared progress entry.

## Remote transfer verification

The complete import commit is `f7cb8d5f385393c7fdccc61f0dad80554572ba9f`. All 523 prepared files matched the remote Git tree by path, blob hash, byte size and executable mode, and `main` was read back after publication of the commit. The source's original Noto Sans SC font exceeded the connector's single-request transport size; a temporary, hash-checked GitHub Actions import restored its exact bytes from an XZ transfer. Both temporary transfer files were removed from the completed source tree. This did not replace, subset or modify the font.
