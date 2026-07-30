# 13. Fixed-width integer binary codecs

This chapter is normative from milestone M1 revision 1 onward.

## 13.1 Scope

M1 defines strict codecs for fixed-width integer fields stored in MiniLang `bytes`
buffers. It covers every signed and unsigned 8-, 16-, 32- and 64-bit bit pattern in
little-endian and big-endian byte order. IEEE-754 floating-point bit conversion is not
part of M1 and will be specified with the SQL physical value codec.

The canonical on-disk byte order is little-endian. Big-endian support exists for
interoperability and the future network protocol. A format document MUST explicitly state
its byte order and MUST NOT depend on the host CPU byte order.

## 13.2 MiniLang scalar model

The native MiniLang runtime stores immediate values in a tagged 64-bit machine word. Three
low bits identify the value kind. A MiniLang `int` therefore has a signed 61-bit payload:

```text
MIN_MINILANG_INT = -2^60 = -1152921504606846976
MAX_MINILANG_INT =  2^60 - 1 = 1152921504606846975
```

MiniSQL MUST NOT place an integer literal outside this interval in MiniLang source code.
Such a literal cannot represent a full I64 scalar after tagging. Full 64-bit values MUST be
constructed from two U32 words.

This constraint is part of the MiniSQL implementation model, not the SQL type model. SQL
`BIGINT` still has the complete signed 64-bit domain.

## 13.3 Public operation model

Read functions have the form:

```text
read<Type><Order>(buffer, offset) -> value | error
```

Write functions have the form:

```text
write<Type><Order>(buffer, offset, value) -> nextOffset | error
```

`readU8`, `readI8`, `writeU8`, and `writeI8` do not carry a byte-order suffix because one
byte has no byte order. Every successful write returns `offset + fieldWidth`.

For widths through 32 bits, reads and writes use MiniLang scalar integers. For 64-bit
fields, the complete domain uses explicit word pairs:

```text
UInt64Words {
    high: U32,
    low: U32
}

Int64Words {
    high: U32,
    low: U32
}
```

Both structures carry the raw bit pattern `(high << 32) | low`. Their different types make
signed and unsigned intent explicit and prevent accidental mixing.

## 13.4 Supported domains

| Type | Minimum | Maximum | MiniLang representation |
|---|---:|---:|---|
| U8 | 0 | 255 | `int` |
| I8 | -128 | 127 | `int` |
| U16 | 0 | 65,535 | `int` |
| I16 | -32,768 | 32,767 | `int` |
| U32 | 0 | 4,294,967,295 | `int` |
| I32 | -2,147,483,648 | 2,147,483,647 | `int` |
| U64 | 0 | 18,446,744,073,709,551,615 | `UInt64Words` |
| I64 | -9,223,372,036,854,775,808 | 9,223,372,036,854,775,807 | `Int64Words` |

The full-domain operations are:

```text
makeUInt64(high, low) -> UInt64Words
makeInt64(high, low) -> Int64Words
minInt64() -> Int64Words
maxInt64() -> Int64Words

readU64LE / readU64BE -> UInt64Words
writeU64LE / writeU64BE <- UInt64Words
readI64LE / readI64BE -> Int64Words
writeI64LE / writeI64BE <- Int64Words
```

Lossless bit reinterpretation is explicit:

```text
uint64BitsToInt64(UInt64Words) -> Int64Words
int64BitsToUInt64(Int64Words) -> UInt64Words
```

## 13.5 Scalar conversion helpers

Convenience conversion is provided only for values that fit the MiniLang signed 61-bit
payload:

```text
uint64FromInt(int) -> UInt64Words
uint64ToInt(UInt64Words) -> int | error

int64FromInt(int) -> Int64Words
int64ToInt(Int64Words) -> int | error

writeI64FromIntLE / writeI64FromIntBE
readI64AsIntLE / readI64AsIntBE
```

`uint64ToInt` succeeds only for `0..MAX_MINILANG_INT`. `int64ToInt` succeeds only for
`MIN_MINILANG_INT..MAX_MINILANG_INT`. It MUST return error code `9001` for every other raw
64-bit pattern. It MUST NOT truncate, wrap or silently reinterpret an out-of-range value.

The full-domain I64 write API intentionally rejects a scalar `int`; callers that have a
scalar MUST use `writeI64FromIntLE` or `writeI64FromIntBE`. This distinction prevents code
from accidentally assuming that a MiniLang integer spans the SQL `BIGINT` domain.

## 13.6 Strict argument and range rules

A codec MUST reject an operation with error code `9001` when:

- `buffer` is not `bytes`;
- `offset` is not an `int`;
- `offset` is negative;
- the complete field does not fit inside the buffer;
- a scalar value is not an `int`;
- an unsigned or narrow signed scalar is outside its declared range;
- a U64 value is not a valid `UInt64Words` instance;
- an I64 value is not a valid `Int64Words` instance;
- either word is outside `0..4294967295`;
- a scalar conversion would leave the MiniLang signed 61-bit domain.

Booleans are not accepted as integers. Offsets are never clamped and negative offsets do
not count from the end of a buffer.

Bounds validation MUST avoid an overflowing `offset + width` calculation. The required
predicate is equivalent to:

```text
offset >= 0 AND bufferLength >= width AND offset <= bufferLength - width
```

## 13.7 Atomic mutation rule

No partial write is permitted. A write function MUST validate the buffer, complete target
range, value type and complete value range before changing the first byte. If it returns an
error, every byte in the destination buffer MUST remain exactly as it was before the call.

This rule applies to composite U64/I64 writes and to scalar convenience writes. Conversion
must finish successfully before the first destination byte changes.

## 13.8 Signed representation

Signed values use two's-complement representation. I8, I16 and I32 reads sign-extend into a
MiniLang scalar. I64 reads return the unmodified two-word pattern as `Int64Words`; sign is
determined by bit 63, equivalently `high >= 0x80000000`.

Representative vectors:

| Operation | Value | Bytes |
|---|---|---|
| `writeU16LE` | `0x1234` | `34 12` |
| `writeU16BE` | `0x1234` | `12 34` |
| `writeI32LE` | `-2147483648` | `00 00 00 80` |
| `writeI64BE` | high=`0xffffffff`, low=`0xfffffffe` (-2) | `ff ff ff ff ff ff ff fe` |
| `writeI64LE` | high=`0x80000000`, low=`0` (I64 minimum) | `00 00 00 00 00 00 00 80` |
| `writeI64BE` | high=`0x7fffffff`, low=`0xffffffff` (I64 maximum) | `7f ff ff ff ff ff ff ff` |
| `writeU64LE` | high=`0x01234567`, low=`0x89abcdef` | `ef cd ab 89 67 45 23 01` |

## 13.9 Acceptance requirements

M1 acceptance MUST include:

- independent golden vectors for both byte orders;
- every signed minimum and maximum boundary;
- the complete U8 and U16 domains;
- deterministic randomized U32 and I32 scalar round trips;
- deterministic randomized U64 and I64 full-word round trips;
- deterministic randomized I64 scalar-subset conversions;
- explicit full I64 minimum and maximum tests without out-of-range MiniLang literals;
- non-zero offset tests with surrounding canary bytes;
- invalid type, range and bounds tests;
- explicit proof that every failed write leaves the buffer unchanged;
- a regression test for the tagged 61-bit scalar model;
- M0 build and module-graph regression checks.
