# ADR-0050: Result-representation-aware acceptance tests

## Status

Accepted for M27-M31R2.

## Context

The executor exposes rows as `SqlValue` objects. Aggregate integers such as
`COUNT` use `Int64Words` inside `SqlValue.value`. Wire protocol v1 deliberately
serializes result values as UTF-8 text. A test compared an internal result cell
directly with an integer and another test compared a wire text field directly
with an integer. The generic equality diagnostic then tried to stringify a
struct and masked the original assertion failure.

## Decision

Acceptance tests must compare values at the abstraction boundary they use:

- direct executor tests unwrap `SqlValue` and use lossless 64-bit helpers;
- network tests parse textual numeric fields explicitly;
- shared assertion diagnostics render every runtime value category without
  relying on implicit struct/array string concatenation.

Static package validation rejects known raw comparison forms in M27 and M31.

## Consequences

A failed assertion reports its label and safe type-oriented values instead of
terminating the test program. No database or wire format is changed.
