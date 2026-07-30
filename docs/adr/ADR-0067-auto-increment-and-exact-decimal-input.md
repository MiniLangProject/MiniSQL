# ADR-0067: AUTO_INCREMENT aliases and exact decimal input

Status: accepted for the M43-M47R1 candidate.

## Context

MiniSQL already had `GENERATED ALWAYS AS IDENTITY`, but common SQL users expect
`AUTO_INCREMENT` or `AUTOINCREMENT`. The SQL lexer already recognized numeric
spellings such as `3.3`, but INSERT binding treated every approximate literal as
`DOUBLE`, which rejected a `REAL` target and could route a `DECIMAL` target
through binary floating point.

## Decision

`AUTO_INCREMENT` and `AUTOINCREMENT` are parser aliases for the existing
identity flag. No new physical sequence or row format is introduced.

INSERT binding is target directed for numeric literals:

- `REAL`/`DOUBLE PRECISION` receive an approximate numeric value of the target
  type;
- `DECIMAL(p,s)` receives a value parsed from the original token spelling into
  the exact signed scaled integer;
- non-zero digits beyond the declared scale and precision overflow are errors;
- no implicit rounding or truncation occurs.

## Consequences

The compatibility syntax remains consistent with MiniSQL durability and
identity behavior rather than attempting to emulate every vendor-specific
AUTO_INCREMENT option. Exact DECIMAL input avoids an avoidable binary-float
round trip. Persisted formats are unchanged.
