# MiniSQL 1.0 format compatibility

MiniSQL 1.0 freezes database format version 1 and wire protocol version 1.
Individual files also carry their own magic, version, database identity, object
identity and checksums. Global configuration values are never used to reinterpret
an existing file.

The M48 `wal.log.durable` marker is auxiliary and may be recreated. It does not
change `wal.log` encoding. Unknown future versions must be rejected rather than
guessed.

Automatic HA adds auxiliary `leader.epoch` and controller-owned `leader.lease`
records. Their v1 layouts are documented in `ha-fencing-records-v1.md`. They do
not alter database pages, WAL, backup archives, or wire protocol v1. Ordinary
non-HA databases do not require either record.
