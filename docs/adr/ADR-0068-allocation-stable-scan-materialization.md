# ADR-0068: Allocation-stable scan materialization

Status: accepted for the M43-M47R2 candidate.

## Context

`executor.scan.decodeRecord` previously grew its row array with expressions of
this form:

```ml
output = output + [materializeStoredValue(...)]
```

MiniLang overloads `+` for numeric addition, array concatenation, byte
concatenation, and a fallback string-concatenation path. The R1 Windows M20
workload entered that fallback while the singleton contained a SQL struct and
failed with runtime error 1303.

## Decision

For stored columns, allocate `array(storedCount)` once and assign each value by
index. When a row must grow for a column introduced by schema evolution, append
with a package-local helper that:

1. validates the source as an array;
2. allocates exactly one larger array;
3. copies existing elements by indexed assignment;
4. writes the new element into the final slot.

The same helper is used when collecting `ScannedRow` values. The scan module
must not use overloaded `+` for these struct-bearing growth paths.

## Consequences

- the normal stored-column path performs one row-array allocation rather than
  one allocation per column;
- concrete SQL structs are never sent through the string-concatenation fallback;
- schema-evolution columns still see only the already materialized prefix, which
  preserves generated-column expression semantics;
- row, page, catalog, WAL, index and network formats remain unchanged.
