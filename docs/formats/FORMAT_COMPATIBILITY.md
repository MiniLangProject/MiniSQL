# MiniSQL 1.0 format compatibility

MiniSQL 1.0 freezes database format version 1 and wire protocol version 1.
Individual files also carry their own magic, version, database identity, object
identity and checksums. Global configuration values are never used to reinterpret
an existing file.

The M48 `wal.log.durable` marker is auxiliary and may be recreated. It does not
change `wal.log` encoding. Unknown future versions must be rejected rather than
guessed.
