# MiniSQL wire protocol v1

Header size: 32 bytes, little endian.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | ASCII `MSQL` |
| 4 | 2 | protocol version = 1 |
| 6 | 2 | message type |
| 8 | 4 | flags |
| 12 | 4 | request ID |
| 16 | 4 | payload length, max 1,048,576 |
| 20 | 4 | payload CRC-32C |
| 24 | 4 | header CRC-32C with this field zeroed |
| 28 | 4 | reserved, zero |

Unknown versions/types, non-zero reserved fields, length mismatch and either checksum mismatch are rejected. The original plaintext M18 service remains loopback-only. M29 permits non-loopback binding only through MiniSQL Secure Transport v1; that authenticated AES-GCM layer is deliberately not represented as standards-compatible TLS.

Response bit `0x00000002` (`FLAG_MORE`) means another response frame with the
same request identifier follows. Every row frame repeats the column schema and
contains at most 512 rows while also respecting the one-MiB payload ceiling.
Clients validate request identifiers and schemas before appending a continuation.
The final frame clears `FLAG_MORE`. Bit `0x00000001` remains the authenticated
MiniSQL framing flag used beneath deployments that enable that transport.
