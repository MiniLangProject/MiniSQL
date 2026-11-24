# Row format v2

Version 2 is intentionally incompatible with row format v1. Readers reject an
`MSRW` record whose row format version is not 2. All fixed-width integers and
floating-point values use little-endian byte order. Every row starts at an
eight-byte-aligned offset in its containing slotted page, and its encoded length
is a multiple of eight bytes.

## Header

Offsets below are relative to the start of the row.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | ASCII magic `MSRW` |
| 4 | 2 | U16 row format version = 2 |
| 6 | 2 | U16 schema version, 1..65535 |
| 8 | 2 | U16 stored column count, 1..4095 |
| 10 | 2 | U16 NULL-bitmap byte count: `ceil(columnCount / 8)` |
| 12 | 2 | U16 directory offset: `align8(16 + nullBitmapBytes)` |
| 14 | 2 | Reserved zero |

The NULL bitmap begins at byte 16. Column `i` uses bit `i % 8`, least-significant
bit first, in bitmap byte `i / 8`. Unused bitmap bits are zero. Zero bytes fill
the gap between the bitmap and the aligned directory.

## Column directory and value alignment

Each directory entry is eight bytes: U16 type code, U16 flags, U16 value offset,
and U16 value length. Value offsets are relative to the row start. The directory
is followed by the values in column order. Immediately before each non-NULL
value, its offset is rounded up to the alignment below; the introduced padding
must be zero.

| Type code | SQL type | Width / representation | Alignment |
|---:|---|---|---:|
| 1 | BOOLEAN | One byte, 0 or 1 | 1 |
| 2 | SMALLINT | Signed 16-bit | 2 |
| 3 | INTEGER | Signed 32-bit | 4 |
| 4 | BIGINT | Signed 64-bit, two's complement | 8 |
| 5 | REAL | IEEE-754 binary64 | 8 |
| 6 | DOUBLE | IEEE-754 binary64 | 8 |
| 7 | DECIMAL | Signed 64-bit coefficient; scale comes from schema | 8 |
| 8 | CHAR | UTF-8, padded with ASCII spaces to declared byte length | 1 |
| 9 | VARCHAR | UTF-8 | 1 |
| 10 | TEXT | UTF-8 or external pointer | 1 / 8 |
| 11 | BINARY | Exact-length raw bytes | 1 |
| 12 | VARBINARY | Raw bytes | 1 |
| 13 | BLOB | Raw bytes or external pointer | 1 / 8 |
| 14 | DATE | Signed 32-bit epoch-day count | 4 |
| 15 | TIME | Signed 64-bit microsecond count | 8 |
| 16 | TIMESTAMP | Signed 64-bit epoch-microsecond count | 8 |

Flags are exactly 0 for an inline value, 1 for SQL NULL, or 2 for an external
TEXT/BLOB pointer. Other values, including the combination 3, are invalid. A NULL
must agree with the bitmap, have length zero, and use the current value cursor
without adding padding. External pointers use eight-byte alignment regardless
of whether the logical column is TEXT or BLOB. An empty inline string has length
zero, flag 0, and a clear NULL bit.

The row ends at the next eight-byte boundary after its last value. All tail
padding is zero. Readers reject noncanonical value offsets, nonzero directory,
inter-value or tail padding, extra tail blocks, truncated values, and rows whose
length is not a multiple of eight. The U16 fields limit encoded row size to
65528 bytes; the containing page imposes the smaller practical inline limit.

## Floating-point values

Both REAL and DOUBLE retain MiniSQL's existing logical binary64 precision. Each
uses eight binary bytes, rather than v1's decimal text rendering. The codec
preserves positive and negative zero, subnormals, and the entire 53-bit
significand. NaN and infinities are rejected on input and when decoding stored
bytes, giving SQL comparisons and indexes a defined finite-value domain.

The implementation uses native `frexp`, `ldexp`, and `copysign` with exact
integer mantissa packing. It does not inspect MiniLang's tagged-value object
layout or convert through decimal text. Linux uses libm and Windows uses the
CRT. The same byte layout is produced on both targets.

## Example

For schema version 1 with `(BIGINT 1, TEXT 'Nils', BOOLEAN true)`, the directory
begins at 24, values are at offsets 48, 56 and 60, and total row length is 64:

```text
4d 53 52 57 02 00 01 00 03 00 01 00 18 00 00 00
00 00 00 00 00 00 00 00 04 00 00 00 30 00 08 00
0a 00 00 00 38 00 04 00 01 00 00 00 3c 00 01 00
01 00 00 00 00 00 00 00 4e 69 6c 73 01 00 00 00
```

The 16-byte header is followed by the one-byte bitmap and seven zero alignment
bytes, three directory entries, thirteen value bytes, and three zero tail bytes.
Schema-compatible decoding still accepts an older stored column prefix; missing
trailing columns are materialized by the executor from schema defaults.
