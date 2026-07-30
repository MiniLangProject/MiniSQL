# ADR-0063: Materialize nonrecursive CTEs and subqueries

Status: accepted for the M43-M44 candidate.

Subqueries and CTEs are materialized before their consumer is executed. This
keeps semantics deterministic and reuses the existing binder and executor.
Correlated and recursive evaluation are rejected until a dedicated parameterized
plan and fixpoint executor exist.
