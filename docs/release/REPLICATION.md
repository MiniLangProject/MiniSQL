# MiniSQL 1.0 replication

Initialize a WAL archive while the primary is offline or before its server is
started. Then run the M48 primary sidecar to export durable WAL prefixes while
the primary remains online. The standby sidecar materializes alternating slots
and exposes the current read-only generation through a loopback TCP switch.

Replication is asynchronous. Monitor generation and LSN in the atomic status
files. Generation numbers use the full U32 range. Each generation stores a
complete WAL prefix and remains on disk so a concurrent verifier that already
read an older manifest cannot lose its referenced file. Recreate the verified
base archive periodically to bound storage use. Promotion is explicit. MiniSQL
1.0 does not implement automatic consensus, fencing or synchronous quorum
commits; operators must prevent split brain.

MiniSQL 1.0 WAL shipping is intended for DML on an already archived schema.
After DDL, DCL, VACUUM, page-size migration or any operation that rewrites or
rewinds physical state, stop replication and create a new base archive. Run only
one primary archive writer per archive directory.
