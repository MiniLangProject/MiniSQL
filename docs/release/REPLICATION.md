# MiniSQL 1.0 replication

Initialize a WAL archive while the primary is offline or before its server is
started. Then run the M48 primary sidecar to export durable WAL prefixes while
the primary remains online. The standby sidecar materializes alternating slots
and exposes the current read-only generation through a loopback TCP switch.

Replication is asynchronous. Monitor `healthy`, generation, `sourceLsn`,
`standbyLsn`, `lagBytes`, and `cycleDurationMs` in the atomic status files.
Generation numbers use the full U32 range. Each generation stores a
complete WAL prefix and remains on disk so a concurrent verifier that already
read an older manifest cannot lose its referenced file. Recreate the verified
base archive periodically to bound storage use. Promotion is explicit. MiniSQL
1.0 does not implement automatic consensus, fencing or synchronous quorum
commits; operators must prevent split brain.

MiniSQL 1.0 WAL shipping is intended for DML on an already archived schema.
After DDL, DCL, VACUUM, page-size migration or any operation that rewrites or
rewinds physical state, stop replication and create a new base archive. Run only
one primary archive writer per archive directory.

The production drill creates an isolated primary, writes concurrently, exports
multiple durable live-WAL prefixes while those writers remain active, serves
concurrent standby reads, stops the old primary, promotes the materialized
standby, performs a post-promotion write, and runs the offline checker:

```powershell
python .\tests\ha\production_failover_drill.py --work-root .\build\ha-drill
```

Promotion advances the next transaction identifier beyond every transaction
observed during recovery. This is required because live WAL shipping transfers
committed table pages while catalog metadata belongs to the base archive; a
promoted writer must never reuse an archived transaction identifier.

The 2026-08-30 Windows qualification wrote 1,000 rows from four concurrent
writers (1,024,000 payload bytes), served 800 aggregate reads from eight standby
clients, promoted in 0.719 seconds, retained 1,001 pre-promotion rows, accepted a
post-promotion write, and passed `minisql-check` with 1,002 rows. The measured
rates were 8.57 durable writes/s and 44.76 standby reads/s on that intentionally
durability-heavy drill; they are test evidence, not a general throughput claim.
