# Acceptance evidence

This directory contains the final MiniSQL 1.0.0 acceptance summary and the
machine-readable 106-phase Windows result.

- `FINAL_STATUS.md` — human-readable release acceptance summary.
- `MiniSQL-1.0.0-results.json` — complete phase and milestone result.

Milestone-level acceptance definitions from the iterative M0-M50 development
process are preserved under `docs/history/milestones/`. The accepted
architectural decisions remain under `docs/adr/`.

The repository test entry point is `test.ps1`. It executes the complete M0-M50
suite and creates one result archive under `build/`.
