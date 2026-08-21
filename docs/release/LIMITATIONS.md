# MiniSQL 1.0 known limitations

* Windows x64 is the native target.
* Native TLS uses the Windows Schannel and CryptoAPI providers. The current
  strict profile supports TLS 1.3 with `TLS_AES_256_GCM_SHA384` and X25519 only;
  peers offering only different suites or groups are rejected.
* Replication is asynchronous and operator-managed.
* The external sort reduces peak memory but final query results are still
  materialized.
* Table, column, schema-extension, statistics, and authorization metadata are
  not constrained to one page or a fixed 1 MiB snapshot. Capacity is still
  finite at the storage format's integer representation, process address space,
  and available disk; protocol frames and individual values retain defensive
  bounds and are not schema-object-count limits.
* Recursive CTEs support an anchor and one recursive `UNION`/`UNION ALL` term;
  explicit mutual recursion is not supported and a 10,000-iteration guard
  diagnoses non-terminating statements.
* Correlated subqueries require explicitly qualified outer references and are
  supported in non-grouped projection/filter/order expressions, not join
  predicates or aggregate/window queries.
* Derived tables require aliases. Schema names are two-part only and there is no
  configurable search path or cross-database catalog qualifier.
* Window functions operate on the complete partition. Explicit `ROWS`, `RANGE`,
  `GROUPS`, frame bounds and named windows are not implemented.
* Trigger and stored-procedure bodies contain one supported DML statement and
  have no procedural control language. `OLD`/`NEW` are read-only, trigger
  recursion is bounded, and body `RETURNING`, `ON CONFLICT`, and `INSERT ...
  SELECT` forms are rejected rather than partially persisted.
* `MERGE` accepts one source table and one action per matched/not-matched branch;
  conditional branches, multiple matched clauses and a query source are not yet
  implemented.
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
