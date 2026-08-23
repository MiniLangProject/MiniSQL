# 14. Varints, CRC-32C and protected envelopes

## 14.1 Canonical variable-length integers

MiniSQL uses unsigned LEB128 for compact non-negative values. U32 values use at most
five bytes and U64 values use at most ten bytes. The complete U64 domain is represented
by `UInt64Words(high, low)`; it is never narrowed to MiniLang's native signed 61-bit
integer payload.

A decoder MUST reject:

- a sequence ending before a terminating byte;
- more than five bytes for U32 or ten bytes for U64;
- high payload bits outside the target width; and
- non-canonical encodings whose final payload group is zero after one or more preceding
  groups.

A write MUST validate its complete destination range and value before changing the
first byte. Failed writes MUST be atomic with respect to the destination buffer.

Signed I32 and I64 varints use ZigZag mapping before unsigned LEB128. Full-domain I64
values use `Int64Words(high, low)`.

## 14.2 CRC-32C

The checksum algorithm is CRC-32C (Castagnoli), reflected polynomial `0x82F63B78`,
initial register `0xFFFFFFFF`, and final XOR `0xFFFFFFFF`. The reference check value for
ASCII `123456789` is `0xE3069283`.

The API supports complete-buffer, range and incremental computation. An empty buffer
has checksum zero. CRC-32C detects accidental corruption; it is not an authentication
mechanism.

An implementation MAY use lookup tables, loop unrolling, or processor
instructions, but it MUST produce exactly the same state after every incremental
update boundary. The current native build uses the canonical 256-entry reflected
Castagnoli table and an eight-byte unrolled loop; this changes no serialized value.

## 14.3 Protected envelope

The generic v1 envelope has a 32-byte little-endian header, an exact payload length, a
CRC-32C over the payload and a CRC-32C over the header with the header-checksum field
zeroed. Magic, version and kind are caller-supplied expectations and MUST match.

A reader MUST reject an unknown algorithm/version, a magic/kind mismatch, a length
mismatch, a header checksum mismatch or a payload checksum mismatch. No partially
validated payload may be exposed as valid data.
