# MiniSQL 1.0 known limitations

* Windows x64 PE and Linux x64 ELF are native targets. The graphical Workbench
  remains Windows-only.
* Linux offline tools, TLS, and bounded concurrent server/client operation pass
  the portable acceptance gate. The original `EAGAIN`/`EWOULDBLOCK` multi-client
  failure is retained as historical evidence in
  `tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md`; it was resolved by
  the pthread-backed MiniLang runtime and EINTR/readiness handling in the socket
  facade. Linux performance still needs the same workload-specific qualification
  as Windows before a production rollout.
* Native TLS uses Schannel/CryptoAPI on Windows and OpenSSL 3 on Linux. Linux
  server credentials currently require an unencrypted PEM certificate/key pair.
  The current
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
  This concurrency contract is validated on both native targets.
* There is no automatic distributed failover or cross-database transaction.
* The M48 WAL stream covers committed table-page changes for an existing
  schema. DDL, DCL, VACUUM, migration or WAL rewind requires a new base archive.
* One controller owns an archive directory; there is no multi-writer archive
  coordination.
* Live archive generations retain complete WAL prefixes; rotate to a new base
  archive periodically to bound disk usage.

These are explicit scope limits, not silent fallbacks.
