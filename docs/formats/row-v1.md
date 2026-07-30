# Row format v1

All fixed-width fields are little-endian.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | magic `MSRW` |
| 4 | 2 | format version = 1 |
| 6 | 2 | schema version |
| 8 | 2 | column count |
| 10 | 2 | NULL-bitmap bytes |
| 12 | 2 | directory offset |
| 14 | 2 | reserved, zero |

The NULL bitmap follows. Each directory entry is 8 bytes: type code, flags, value offset and
value length, each U16. Values are packed contiguously in column order. Flags are 1 for SQL
NULL and 2 for an external TEXT/BLOB pointer. Unused bitmap bits and unknown flags are zero.

M9 floating values are stored as validated canonical UTF-8 numeric renderings because the
current MiniLang runtime has no stable float-bit cast; the format does not claim raw IEEE bits.
