# M48 – Continuous hot-streaming replication

## Scope

M48 converts the M31 offline WAL archive into a continuously updated replication
source and adds an online, read-only standby service. The database and wire
formats remain version 1.

## Durable export boundary

Each `wal.log` has an adjacent `wal.log.durable` marker. The WAL data is flushed
first. Only afterwards is the marker atomically replaced. A live exporter must
copy at most the marker LSN and must verify that it is a complete WAL-record
boundary. Marker update failure may delay a replica, but never changes the
result of a successful primary commit.

## Primary streaming

`minisql-backup.exe archive-wal-live <db> <archive>` reads the durable WAL prefix
without acquiring the database-wide owner lock. Continuity against the previous
archive generation is mandatory.

`tools/replication/minisql_hot_replica.py primary` repeats this operation and
publishes an atomic JSON status file. Archive generation numbers use the full
U32 range. Each generation contains a complete validated WAL prefix. Published
generations are retained because a standby verifier may already have read an
older manifest; replacing or deleting its referenced snapshot without a shared
archive lock would create a race. Operators should create a fresh verified base
archive periodically to bound archive growth.

## Hot standby

`minisqld.exe --serve-standby` opens a database through
`database_manager.openStandby`. Reads are allowed; every write-lock statement is
rejected with error 9033 until promotion.

The Python sidecar uses two independently recovered standby slots. A loopback
TCP switch sends new connections to the newest fully validated slot. Existing
connections remain attached to the older slot until they close. An incomplete
new generation is never published.

## Limits

M48 is asynchronous. It does not provide synchronous quorum commit, automatic
leader election, or split-brain prevention. Promotion remains an explicit
operator action. The cleartext switch binds only to loopback; remote exposure
must use the M47 TLS 1.3 sidecar.

## Schema and maintenance boundary

The M48 stream replays committed table-page WAL for an existing physical schema.
DDL/DCL changes, VACUUM page-layout replacement, offline migration and other
catalog/sidecar rewrites require a new verified base archive before streaming
continues. `archive-wal-live` fails closed when WAL prefix continuity is lost.
Exactly one archive writer/controller may update an archive directory.
