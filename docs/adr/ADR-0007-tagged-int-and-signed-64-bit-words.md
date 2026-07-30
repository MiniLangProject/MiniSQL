# ADR-0007: Represent full signed 64-bit values as two U32 words

## Status

Accepted in M1 revision 1. This refines ADR-0006.

## Context

The native MiniLang runtime uses a tagged 64-bit value representation. Three low bits store
the runtime tag, so an immediate MiniLang integer has a signed 61-bit payload. The usable
scalar interval is `-2^60..2^60-1`.

The initial M1 candidate treated MiniLang `int` as if it could carry the complete signed
I64 interval. Its boundary tests demonstrated wraparound: the intended I64 minimum became
zero and the intended I64 maximum became negative after tagging.

MiniSQL requires the complete SQL `BIGINT` domain and exact 64-bit bit patterns for storage,
WAL and protocol structures.

## Decision

MiniSQL represents the full signed I64 domain as `Int64Words(high, low)`, with both members
validated as U32. `readI64*` returns this structure and `writeI64*` requires it.

MiniLang scalar conversions are separate helpers and succeed only within
`-2^60..2^60-1`. Full I64 minimum and maximum values are produced by `minInt64()` and
`maxInt64()` rather than by out-of-range scalar literals.

Unsigned values continue to use `UInt64Words(high, low)`. Explicit bit-cast helpers preserve
all bits while changing signedness intent.

## Consequences

- SQL `BIGINT` remains a true signed 64-bit type.
- No MiniLang source file may use a numeric literal outside the native 61-bit scalar range.
- Arithmetic over arbitrary SQL `BIGINT` values will require dedicated word-pair operations
  in a later milestone.
- Storage codecs are lossless now and do not depend on a future compiler representation
  change.
- Call sites cannot accidentally pass a scalar to the full-domain I64 codec.
