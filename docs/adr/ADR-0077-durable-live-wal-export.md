# ADR-0077: Durable live WAL export marker

**Decision:** publish `wal.log.durable` only after the WAL file flush succeeds.
A live exporter copies no bytes beyond that marker.

Returning a commit error after WAL durability would permit unsafe retries.
Therefore marker-write failure is replication lag, not commit failure. Reopening
the WAL reconstructs the marker from the valid on-disk prefix.

**Archive retention:** live generation numbers use the complete U32 field.
Published complete-prefix generations are retained in 1.0. A concurrent reader
may have read an older manifest immediately before a new one is published; without
a shared archive lock, deleting that older snapshot would be unsafe. Periodic
base-archive rotation bounds storage use.
