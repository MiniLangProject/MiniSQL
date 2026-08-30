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
base archive periodically to bound storage use. The original M48 sidecar keeps
promotion explicit. The newer single-host controller adds automatic promotion,
a stable endpoint, and native write fencing; it does not add distributed
consensus or synchronous quorum commits.

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

## Automatic single-host failover

`tools/replication/minisql_ha_controller.py` is the operational reference for
one controller-owned host. Its file witness serializes leadership terms, renews
a 64-byte CRC-32C protected lease on a dedicated thread, and writes a 32-byte
persistent epoch into a database before starting that term. The native server
checks both records before every mutation and immediately before DML or DDL
commit. A missing, malformed, expired, or foreign record rejects the write as
9038. Reads and rollback remain available for diagnosis.

```powershell
python .\tools\replication\minisql_ha_controller.py run `
  --primary-db .\data\db_<id> `
  --archive .\ha\archive `
  --slot-root .\ha\slots `
  --witness-dir .\ha\witness `
  --server-exe .\build\bin\minisqld.exe `
  --backup-exe .\build\bin\minisql-backup.exe `
  --proxy-port 7432 `
  --status-file .\ha\status.json
```

The controller waits through the previous lease expiry plus the configured
clock-skew allowance before promotion. New proxy connections then use the new
leader; connections already established against the retired backend are not
silently migrated and must reconnect. The default lease is five seconds and
the default skew allowance is 250 milliseconds. Lease renewal is independent
of archive materialization so a large standby copy cannot accidentally expire
an otherwise healthy leader.

Run both destructive qualification drills in new empty directories:

```powershell
python .\tests\ha\automatic_fencing_drill.py --work-root .\build\ha-fencing-drill
python .\tests\ha\automatic_controller_live.py --work-root .\build\ha-controller-live
```

The first deliberately leaves the old primary online, proves direct write
rejection, switches the endpoint, and rebuilds the retired node as a standby.
The second kills the controller-owned leader and verifies automatic promotion.

The file witness is not a consensus algorithm. Its directory must have one
controller writer and filesystem semantics that guarantee atomic replacement.
For multiple machines, place leadership behind a quorum-based external lease
service and enforce the term at shared storage or another authoritative write
boundary. Do not present isolated copies of the witness to different nodes.

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
