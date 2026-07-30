# Protected envelope v1

All fields are little-endian.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | caller-defined magic |
| 8 | 2 | version |
| 10 | 2 | kind |
| 12 | 4 | flags |
| 16 | 4 | payload length |
| 20 | 4 | payload CRC-32C |
| 24 | 4 | header CRC-32C |
| 28 | 4 | reserved, zero |
| 32 | variable | payload |

The header CRC covers bytes 0-31 with bytes 24-27 zero. The payload CRC covers exactly
the declared payload. The physical source length MUST equal `32 + payload length`.
