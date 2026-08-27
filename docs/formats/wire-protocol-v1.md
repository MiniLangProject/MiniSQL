# MiniSQL wire protocol v1

Header size: 32 bytes, little endian.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | ASCII `MSQL` |
| 4 | 2 | protocol version = 1 |
| 6 | 2 | message type |
| 8 | 4 | flags |
| 12 | 4 | request ID |
| 16 | 4 | payload length, defensive maximum 16,777,216 |
| 20 | 4 | payload CRC-32C |
| 24 | 4 | header CRC-32C with this field zeroed |
| 28 | 4 | reserved, zero |

Unknown versions/types, non-zero reserved fields, length mismatch and either checksum mismatch are rejected. The original plaintext M18 service remains loopback-only. M29 permits non-loopback binding only through MiniSQL Secure Transport v1; that authenticated AES-GCM layer is deliberately not represented as standards-compatible TLS.

Response bit `0x00000002` (`FLAG_MORE`) means another response frame with the
same request identifier follows. Every row frame repeats the column schema and
normally contains at most 512 rows and targets less than one MiB. One row that
cannot be split across frames may occupy a frame up to the 16 MiB defensive
transport maximum.
Clients validate request identifiers and schemas before appending a continuation.
The final frame clears `FLAG_MORE`. Bit `0x00000001` remains the authenticated
MiniSQL framing flag used beneath deployments that enable that transport.

Cursor-aware clients consume one continuation frame at a time. The legacy
convenience query API appends batches for compatibility and is therefore not a
bounded-memory API. Only one cursor may own a protocol-v1 connection because
responses are ordered and not multiplexed.
