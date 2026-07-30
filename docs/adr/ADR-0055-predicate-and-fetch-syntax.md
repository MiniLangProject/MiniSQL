# ADR-0055: Preserve three-valued predicates and reuse limit execution

## Status

Accepted for the M36 candidate.

## Decision

Model IN, BETWEEN and truth tests explicitly so NULL semantics are not lost in
ad-hoc rewrites. Parse SQL-standard OFFSET/FETCH into the existing offset/limit
fields after rejecting ambiguous LIMIT+FETCH combinations.

## Consequences

Execution reuses proven row slicing while the binder and evaluator retain SQL
UNKNOWN semantics. IN subqueries and quantified comparisons require separate
plan nodes and remain future work.
