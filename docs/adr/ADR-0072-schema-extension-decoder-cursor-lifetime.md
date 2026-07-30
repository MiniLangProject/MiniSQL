# ADR-0072: Decode schema-extension records in isolated cursor functions

Status: accepted for the M43-M47R6 candidate.

## Context

`schema_history.decodeExtensions(...)` originally decoded views, sequences,
generated columns, and triggers in one large function. Each lexical branch
introduced many temporary locals while sharing the same `payload` bytes local.
The R5 Windows run decoded a sequence record successfully, then observed
`payload` as `void` only when the function executed its final
`len(payload)` trailing-byte check.

The persisted bytes and envelope checksum were valid; prior view-only decoding
had also passed. The fragile part was therefore the lifetime shape of one shared
heap-value local across several large record blocks, not the extension format.

## Decision

- Capture `payloadLength` exactly once before record decoding.
- Decode each record family in a dedicated cursor function receiving the
  payload, current offset, and captured length.
- Return a `DecodedExtensionEntry(value, nextOffset)` from each cursor.
- Append decoded structs through explicit fixed-array allocation rather than an
  overloaded concatenation expression.
- Perform the final exact-consumption check with `offset != payloadLength`.
- Add a mixed-record codec regression containing a view, sequence, generated
  column, and trigger in one extension payload.

## Consequences

- The decoder has smaller lexical scopes and deterministic cursor ownership.
- The R5 `len(void)` failure path is removed.
- Mixed record-family transitions receive direct test coverage.
- `schema.extensions` format version 1 remains byte-for-byte unchanged.
