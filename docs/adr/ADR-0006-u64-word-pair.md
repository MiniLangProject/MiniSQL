# ADR-0006: Represent unsigned 64-bit values as two U32 words

## Status

Accepted in M1 and refined by ADR-0007.

## Context

MiniLang immediate integer values use a tagged machine word and cannot represent the
complete U64 domain. Database formats need all U64 bit patterns for identifiers, LSNs,
checksums and protocol fields.

## Decision

MiniSQL represents a U64 value as `UInt64Words(high, low)`, where both members are
validated U32 values. Codecs read and write all 64 bits without converting the value to an
out-of-range scalar.

ADR-0007 applies the same physical two-word strategy to the complete signed I64 domain by
introducing a distinct `Int64Words` type.

## Consequences

The representation is explicit, lossless and portable. Call sites use `.high` and `.low`
or the provided conversion helpers. Later specialized ID structs may wrap the same physical
representation without changing the on-disk encoding.
