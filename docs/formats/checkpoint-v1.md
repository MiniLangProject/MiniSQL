# Checkpoint metadata format v1

The file is exactly 512 bytes and contains slots A and B, each 256 bytes. Fields are
little-endian.

| Offset in slot | Size | Field |
|---:|---:|---|
| 0 | 8 | magic `MSQLCKP1` |
| 8 | 2 | version = 1 |
| 10 | 2 | slot size = 256 |
| 12 | 4 | reserved, zero |
| 16 | 8 | generation |
| 24 | 8 | checkpoint LSN |
| 32 | 8 | redo-start LSN |
| 40 | 8 | WAL record count |
| 48 | 16 | database UUID |
| 64 | 4 | slot CRC-32C with this field zeroed |
| 68 | 188 | reserved, zero |

Slot A begins at file offset 0 and slot B at 256. The valid highest generation wins.
