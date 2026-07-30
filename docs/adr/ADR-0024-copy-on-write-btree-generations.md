# ADR-0024: copy-on-write B+ tree generations

## Decision

M11 rebuilds and appends a complete sorted B+ tree generation, then atomically publishes
one of two redundant metadata pages. It does not update reachable nodes in place.

## Rationale

The approach is slower than page-local split/merge updates, but its failure states are
small and testable: either the prior metadata generation is authoritative or the new
complete graph is. It therefore establishes a correctness baseline before introducing
incremental page algorithms and reclamation. Historic pages are reclaimed only by an
explicit future rebuild/VACUUM.
