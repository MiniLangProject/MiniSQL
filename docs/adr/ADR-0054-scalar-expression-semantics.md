# ADR-0054: Bind scalar expressions into explicit typed nodes

## Status

Accepted for the M35 candidate.

## Decision

Represent CASE, CAST, COALESCE and NULLIF as dedicated AST/bound nodes rather
than rewriting them to fragile combinations of existing operators. Common
result types are selected by the binder and evaluation performs explicit
conversion to that result type.

## Consequences

NULL behavior, grouped evaluation and diagnostics remain deterministic. New
scalar functions can extend the same bound-scalar contract without overloading
the aggregate path.
