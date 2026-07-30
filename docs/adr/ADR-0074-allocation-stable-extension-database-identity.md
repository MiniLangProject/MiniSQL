# ADR-0074: Keep schema-extension database identities in scalar snapshots

Status: accepted for the M43-M47R8 candidate.

## Context

The R7 Windows run passed M0-M44, AUTO_INCREMENT/exact-decimal compatibility,
M43, and M44. M45 then rejected a pure mixed-record extension roundtrip as
belonging to another database.

The decoder performed this comparison:

```ml
bytesEqual(slice(payload, 0, 16), databaseId)
```

The first operand allocates a new byte buffer before the second heap-backed
operand is consumed. The encoder similarly accessed `state.databaseId` after
extension-size calculation and payload allocation. Earlier native-runtime
failures showed that avoiding allocation-heavy nested/member lifetime shapes is
important for deterministic database code.

## Decision

- Validate every extension database ID as exactly 16 bytes.
- In `createState`, materialize the ID copy and all empty arrays before the
  `SchemaState` constructor call.
- Before encode sizing/allocation, read the ID into four U32 scalar words.
- Write the four words directly into the extension payload.
- Before envelope decode, snapshot the expected ID into four U32 scalar words.
- Compare the embedded identity as four scalar reads, without `slice(...)` or a
  heap-backed nested comparison.
- Construct the decoded state's ID from the verified scalar words.
- Keep the M45 pure codec test before opening a live database, materialize its
  record objects before array assignment, recreate the expected ID immediately
  before decode, and verify the exact round-tripped identity.
- Add a static recurrence guard against the old allocating comparison.

## Consequences

- Identity validation no longer depends on retaining two heap objects through an
  allocating nested expression.
- The returned schema state owns a fresh verified 16-byte identity.
- Invalid caller identities fail explicitly rather than being reported as a
  foreign database.
- `schema.extensions` version 1 is byte-for-byte unchanged.
