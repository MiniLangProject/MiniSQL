# WAL record format v1

All fields are little-endian. M6 stores records consecutively in one physical file. The
configured segment size defines logical segment number and offset only.

## Header — 80 bytes

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | magic `MSQLWAL1` |
| 8 | 2 | format version = 1 |
| 10 | 2 | header size = 80 |
| 12 | 2 | record type |
| 14 | 2 | flags |
| 16 | 4 | total record length |
| 20 | 4 | payload length |
| 24 | 8 | LSN |
| 32 | 8 | transaction ID |
| 40 | 8 | file ID |
| 48 | 8 | page number |
| 56 | 8 | pageLSN |
| 64 | 4 | payload CRC-32C |
| 68 | 4 | header CRC-32C with this field zeroed |
| 72 | 8 | reserved, zero |

Payload bytes immediately follow. M6 types are 1 `TX_BEGIN`, 2 `PAGE_IMAGE`, 3 `TX_COMMIT`
and 4 `TX_ABORT`; 5/6 reserve checkpoint begin/end. Non-page records use zero file/page IDs.
A page-image payload is a complete verified page whose identity and pageLSN match the header.
