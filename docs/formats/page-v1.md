# Page format v1

All fields are little-endian. Header size is 64 bytes.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | magic `MSPG` |
| 4 | 2 | format version = 1 |
| 6 | 2 | header size = 64 |
| 8 | 2 | page type |
| 10 | 2 | flags |
| 12 | 4 | reserved, zero |
| 16 | 8 | file ID |
| 24 | 8 | page number |
| 32 | 8 | page LSN |
| 40 | 8 | page generation |
| 48 | 2 | item count |
| 50 | 2 | free-start offset |
| 52 | 2 | free-end offset |
| 54 | 2 | reserved, zero |
| 56 | 4 | payload CRC-32C |
| 60 | 4 | header CRC-32C |
| 64 | remaining | page payload |

The payload CRC covers the remaining page. The header CRC covers the complete header with
the header CRC field zeroed.
