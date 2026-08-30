# HA fencing records v1

All integers are unsigned little-endian. CRC fields contain CRC-32C Castagnoli
over the complete record with the CRC field set to zero. Readers reject every
unknown magic, version, size, non-native integer, truncated record, trailing
byte, or checksum mismatch.

`leader.epoch` is 32 bytes:

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | ASCII `MSHAE001` |
| 8 | 2 | version `1` |
| 10 | 2 | record size `32` |
| 12 | 8 | leadership epoch |
| 20 | 8 | node identifier |
| 28 | 4 | CRC-32C |

`leader.lease` is 64 bytes:

| Offset | Size | Field |
|---:|---:|---|
| 0 | 8 | ASCII `MSHAL001` |
| 8 | 2 | version `1` |
| 10 | 2 | record size `64` |
| 12 | 8 | leadership epoch |
| 20 | 8 | node identifier |
| 28 | 8 | expiry as Unix milliseconds UTC |
| 36 | 24 | reserved zero bytes |
| 60 | 4 | CRC-32C |

These files add HA coordination metadata; they do not change database pages,
WAL records, backup manifests, or the network protocol.
