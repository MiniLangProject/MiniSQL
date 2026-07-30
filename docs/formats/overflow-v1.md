# Overflow pointer and page format v1

## External pointer — 48 bytes

The pointer stores magic/version, file ID, first page, total length (U32), owner ID,
whole-value CRC-32C, reserved fields and pointer CRC-32C. All fixed-width fields are
little-endian. A zero-length value has no page chain.

## Overflow page

Bytes 0-63 use common page format v1. The overflow header occupies bytes 64-103:

| Offset | Size | Field |
|---:|---:|---|
| 64 | 4 | overflow magic |
| 68 | 2 | format version = 1 |
| 70 | 2 | reserved, zero |
| 72 | 8 | owner ID |
| 80 | 8 | next page number |
| 88 | 4 | chunk length |
| 92 | 4 | total value length |
| 96 | 4 | sequence number |
| 100 | 4 | reserved, zero |

Chunk data starts at byte 104. Every page is also covered by the common header/payload
checksums. The terminal page uses the defined no-next-page sentinel.
