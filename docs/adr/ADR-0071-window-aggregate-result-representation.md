# ADR-0071: Window aggregate tests must decode full-domain integer values

Status: accepted for the M43-M47R5 candidate.

## Context

MiniSQL represents SQL `BIGINT` and integer aggregate results over the complete
signed 64-bit domain as `Int64Words`. Query rows wrap that value in `SqlValue`.
A native MiniLang integer cannot represent the entire SQL 64-bit domain.

The M44 R4 test correctly decoded `COUNT`, ranking functions, and sequence
values, but compared two `SUM` values by reading `.value` and comparing the
resulting `Int64Words` struct directly with native integers.

## Decision

Acceptance tests that expect a small native integer from a full-domain SQL
integer result must explicitly convert through `endian.int64ToInt` after
unwrapping the `SqlValue`. They must not compare an `Int64Words` object directly
with an integer.

## Consequences

- The window-`SUM` assertions use the existing `int64(SqlValue)` helper.
- The engine and on-disk representation remain unchanged.
- A static acceptance guard rejects recurrence of the two direct `.value`
  comparisons.
