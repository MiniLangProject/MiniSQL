# MiniSQL 1.0 known limitations

* Windows x64 PE and Linux x64 ELF are native targets. The graphical Workbench
  remains Windows-only.
* The portable Java 11+ JDBC driver implements core connections, statements,
  prepared statements, transactions, forward-only results, and catalog
  metadata. Protocol v1 carries result cells as text without SQL type or NULL
  metadata, so ordinary result metadata is conservative, the text token `NULL`
  is ambiguous, and `setBytes` is unavailable until the SQL grammar gains a
  binary literal or the wire protocol gains typed parameter binding. Callable
  statements, generated keys, scrollable/updatable results, XA, and JDBC
  savepoint objects are not implemented in driver 1.0.
* The Python 3.10+ DB-API connector exposes forward-only string/`None` rows,
  because protocol v1 has no SQL type or null bitmap. Text containing exactly
  `NULL` is ambiguous, binary parameter binding is unavailable, and one
  connection can own only one unread result stream. Stored procedures, multiple
  result sets, scrollable cursors, and two-phase commit are not implemented.
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
* External sort and partitioned hash operators reduce working-set memory. The
  configured `runtime.temporaryMemoryBytes` value supplies a soft per-session,
  per-query budget and `EXPLAIN ANALYZE` reports estimated peak and spill
  counters. Eligible simple single-table queries stream directly from a storage
  cursor; blocking and unsupported shapes plus the compatibility client API
  still materialize the final `QueryResult` array.
* The cost optimizer uses row/page/null/distinct/width estimates, eight-bucket
  equi-depth histograms for compact numeric/date values, integral or hashed
  most-common values, plus joint distinct counts and tuple MCVs for composite
  index keys through eight columns. It does not yet persist full wide-value
  ordering, expression distributions, or functional-dependency statistics.
  Inner-equijoin ordering uses bounded left-deep dynamic programming
  through eight sources and a deterministic greedy fallback above that limit;
  bushy trees and outer-join reordering are not implemented. Index-only scans
  cover B+ tree key columns and explicit `INCLUDE` payload columns. Partial
  indexes support immutable base expressions. Predicate implication is
  deliberately bounded to identical typed conjuncts and stronger typed
  single-column literal bounds in single-table plans; equivalent general
  expressions and floating-point bounds are not yet proven. Top-level inner
  equality graphs propagate non-NULL constants, while outer-join inference is
  deliberately excluded. The current `ON CONFLICT(column)` syntax cannot
  name a partial predicate, so it does not infer a partial unique index.
  Functional indexes currently accept exactly one deterministic expression key;
  mixed/composite expression keys, expression statistics, expression-aware
  index-only decoding, and functional join probes are not implemented. The
  query expression must have an identical typed binding. Expression identifiers
  that lose their meaning without SQL quoting are rejected until expression ASTs
  preserve quoting in canonical catalog SQL. One encoded
  B+ tree key is limited to 256 bytes and one leaf payload to 3,584 bytes so an
  individual entry always fits the minimum supported 4 KiB database page. Execution
  uses bounded batches and streaming fast paths where supported, including
  filtered scalar aggregates, page-range parallel scalar aggregates, fused
  single-table Top-N, and the final edge of
  reordered inner-equijoin `COUNT(*)`. Large eligible hash joins and grouped
  aggregates use disk-backed partitions on up to four native workers. Other
  blocking operators and the final result array may still materialize large row
  sets; protocol-v1 sends that array in bounded continuation frames. The query
  memory budget is a spill policy, not a hard process-memory cap.
* Configured servers hard-limit live connections, SQL payload bytes, response
  frame bytes, result rows, and idle lifetime. They do not yet enforce a single
  global heap/RSS ceiling or a shared on-disk temporary-space quota. Statement
  execution is cooperatively bounded by lock waits and operator-specific guards;
  `runtime.queryTimeoutMs` is currently the logical lock-wait timeout rather
  than an asynchronous kill timer for arbitrary CPU work.
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
