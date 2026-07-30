# WAL durable marker v1

Path: `wal/wal.log.durable`

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | ASCII magic `MSWDL001` |
| 8 | 2 | version = 1, little endian |
| 10 | 2 | size = 32 |
| 12 | 4 | reserved = 0 |
| 16 | 8 | durable WAL prefix LSN |
| 24 | 4 | CRC-32C of all 32 bytes with this field zero |
| 28 | 4 | reserved = 0 |

The marker is a replication aid, not part of WAL recovery correctness. It is
atomically replaced after `FlushFileBuffers(wal.log)` succeeds.
