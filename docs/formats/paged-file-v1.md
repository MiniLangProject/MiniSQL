# Paged file format v1

A paged file has a fixed 8192-byte metadata region independent of its persisted page
size.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4096 | superblock slot A |
| 4096 | 4096 | superblock slot B |
| 8192 | pageSize × pageCount | committed pages |

## Superblock slot

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | magic `MSQLSB01` |
| 8 | 2 | format version = 1 |
| 10 | 2 | header size = 128 |
| 12 | 2 | file type |
| 14 | 2 | reserved, zero |
| 16 | 8 | generation |
| 24 | 4 | page size |
| 28 | 4 | reserved, zero |
| 32 | 8 | file ID |
| 40 | 8 | committed page count |
| 48 | 16 | database ID |
| 64 | 4 | feature flags |
| 68 | 4 | reserved, zero |
| 72 | 4 | slot CRC-32C |
| 76 | 52 | reserved header bytes |
| 128 | 3968 | reserved slot bytes |

The CRC covers all 4096 bytes with the CRC field zeroed. Unknown non-zero reserved data
is rejected by the current version after the slot checksum has been validated.
