# MiniSQL 1.0 known limitations

* Windows x64 is the native target.
* TLS and hot replication use Python sidecars rather than in-process MiniLang
  bindings.
* Replication is asynchronous and operator-managed.
* The external sort reduces peak memory but final query results are still
  materialized.
* CTEs are nonrecursive and subqueries are non-correlated.
* Trigger bodies contain one supported DML statement and have bounded recursion.
* DCL is autocommit-only.
* There is no automatic distributed failover or cross-database transaction.

These are explicit scope limits, not silent fallbacks.
* The M48 WAL stream covers committed table-page changes for an existing
  schema. DDL, DCL, VACUUM, migration or WAL rewind requires a new base archive.
* One controller owns an archive directory; there is no multi-writer archive
  coordination.
* Live archive generations retain complete WAL prefixes; rotate to a new base
  archive periodically to bound disk usage.
