# Project instructions

## Start here

Read `PROJECT_STATE.md`, `README.md`, `docs/RELEASE_BLOCKERS.md`, and the final Native Build Fix Gate section of `checkpoints/PHASE_11.md` before continuing. Earlier checkpoint sections are historical, including failed attempts. This import's baseline is Phase 11 Native Build Fix Gate Complete, not the stale Phase 6/9 README baseline.

Confirm the current remote branch/commit and local working changes. Preserve work from other tasks. Use the repository as the code source; ChatGPT/Codex/dot memory does not replace current files.

## Scope and verification

Follow the owner's current requested scope. Importing or setting up this project does not itself authorize advancing a product phase, signing or releasing the app, or enabling purchases/ads.

Use the pinned dependency/toolchain information. Run checks appropriate to actual changes. Record historical results as historical; never present the 322-test native gate as a new run unless you really ran it. Native iOS acceptance requires the appropriate Apple toolchain. Keep actual results, constraints and evidence links distinct.

## Continuity

`PROJECT_STATE.md` on the repository's `main` branch is the canonical progress location. Every task starts by reading it. At completion, a blocker or handoff, update it with the work version/branch/commit, what was verified, what remains, and the next action. If working on a feature branch, record the branch/PR in the canonical status or explicitly report that the shared status could not be updated; do not leave multiple unlabelled copies claiming to be latest.

Save and push important source changes to the authorized remote and verify the remote result before claiming the next environment can continue. Note any local-only files or unavailable tasks. Report timestamps in Asia/Hong_Kong for the owner. Evana can coordinate using these records, but this file does not grant device access or create scheduled synchronization.

## Repository contents

Retain application code, tests, migrations, dependency lockfiles, native project files, Gradle wrapper, required assets and their licence files. Exclude generated machine configuration, build caches, signing material, real service credentials and user bookkeeping data. This repository was public when the initial import was authorized.
