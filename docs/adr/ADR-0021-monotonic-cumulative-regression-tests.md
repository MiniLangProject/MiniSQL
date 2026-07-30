# ADR-0021: Cumulative regressions are monotonic

Status: accepted

## Context

MiniSQL packages rerun all accepted milestones. An earlier smoke test asserted not only
that its own feature was implemented, but also that a later feature was still a stub.
Once that later feature was implemented, the old regression failed despite the earlier
feature remaining correct. Similar negative checks existed in later module smoke tests.

## Decision

A regression for milestone `Mn` may assert:

- identities and target milestone metadata;
- that features delivered by `M0..Mn` remain implemented;
- the functional behavior accepted for `M0..Mn`.

It must not assert:

- that a feature assigned to a later milestone is unimplemented;
- an old global product version, release revision or current milestone;
- repository state that is expected to change as development proceeds.

Exact implementation-marker state for the current package is validated by the current
manifest/catalog static gate and the newest milestone smoke test. Older regressions remain
forward-compatible.

## Consequences

Accepted tests can be reused unchanged in later cumulative packages. A later feature may
no longer invalidate an earlier milestone. Static acceptance checks reject known forms of
negative future-state assertions.

## R1 enforcement after the M22-M26 first run

`MiniSQL_M22_M26_RESULTS_20260727-095704.zip` showed that the M21 module
regression still pinned `0.21.0-m21` and `M21`. The cumulative gate therefore
stopped before M22 even though M21 functionality remained correct.

Every cumulative module smoke now treats product version and current milestone
as package metadata whose exact values belong to the newest static manifest and
application `--version` tests. The static gate scans all `m*_all_modules.ml`
files and rejects exact package-global version or milestone comparisons.
