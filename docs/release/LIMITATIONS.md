# MiniSQL 1.0 known limitations

* Windows x64 is the native target.
* TLS and hot replication use Python sidecars rather than in-process MiniLang
  bindings.
* Replication is asynchronous and operator-managed.
* The external sort reduces peak memory but final query results are still
  materialized.
* Table, column, schema-extension, statistics, and authorization metadata are
  not constrained to one page or a fixed 1 MiB snapshot. Capacity is still
  finite at the storage format's integer representation, process address space,
  and available disk; protocol frames and individual values retain defensive
  bounds and are not schema-object-count limits.
* CTEs are nonrecursive and subqueries are non-correlated.
* Trigger bodies contain one supported DML statement and have bounded recursion.
* DCL is autocommit-only.
* Connections, framing, SQL parsing and read-only query plans are threaded.
  Multiple reads can execute against one database simultaneously; mutations,
  maintenance, sequence consumption and session-state changes are serialized by
  a writer-prioritized per-database gate. There is still only one active physical
  writer per database. Long-running readers can delay a waiting writer until the
  current reader set completes; new readers do not bypass that writer.
* There is no automatic distributed failover or cross-database transaction.

These are explicit scope limits, not silent fallbacks.
* The M48 WAL stream covers committed table-page changes for an existing
  schema. DDL, DCL, VACUUM, migration or WAL rewind requires a new base archive.
* One controller owns an archive directory; there is no multi-writer archive
  coordination.
* Live archive generations retain complete WAL prefixes; rotate to a new base
  archive periodically to bound disk usage.
