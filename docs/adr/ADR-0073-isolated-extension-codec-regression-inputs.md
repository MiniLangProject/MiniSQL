# ADR-0073: Isolate schema-extension codec regressions from live database owners

Status: accepted for the M43-M47R7 candidate.

## Context

The R6 Windows run passed M0-M44, the compatibility phase, M43, and M44. M45
then failed before `decodeExtensions(...)` was entered. Its regression used one
nested expression whose first argument encoded a mixed extension payload and
whose second argument dereferenced `managed.catalogHandle.metadata.databaseId`.
After the allocation-heavy encode, the live owner receiver was observed as
`void`.

The mixed roundtrip is a pure serialization test and does not need a catalog
handle or a real database identity. Keeping those concerns coupled made the
regression sensitive to call-argument and heap-local lifetime shape rather than
only to codec correctness.

## Decision

- Run the mixed extension codec regression before creating the real database.
- Use a deterministic standalone 16-byte database ID.
- Store the encoded payload in a named local before calling the decoder.
- Pass only precomputed locals to `decodeExtensions(...)`.
- Create and attach the M45 SQL test database after all codec assertions.
- Add a static recurrence guard against the old nested encode/decode expression
  and against using `managed.catalogHandle` as the codec identity source.

## Consequences

- The codec regression measures only encode/decode behavior.
- The live database owner has a shorter and clearer lifetime.
- A future codec failure cannot be hidden by a nested member-access failure.
- `schema.extensions` format version 1 remains byte-for-byte unchanged.
