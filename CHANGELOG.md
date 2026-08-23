# Changelog

All notable release-level changes are documented here. The detailed milestone
and repair-candidate log from development is preserved in
`docs/history/DEVELOPMENT_CHANGELOG.md`.

## Unreleased — 2026-08-21

- expanded the native Workbench with multiple SQL worksheets, keyboard
  accelerators, context menus, searchable history, CSV result export, and
  persistent top-level window geometry;
- replaced the fixed 100-row table preview workflow with sortable, filterable,
  paged multi-select data grids; added Unicode copy/paste, direct cell-focused
  editing, staged bulk insert/update/delete, exact SQL preview, revert, and
  atomic transaction/savepoint application;
- added a structured table/column/index/constraint schema designer with exact
  DDL preview, injection-resistant fragment validation, insert-into-worksheet,
  guarded execution, and automatic object-tree refresh;
- added model, native-control, live-server, rollback, pagination, concurrent
  reader, reconnect, and layout-persistence coverage for the extended Workbench;
- upgraded the native Workbench worksheet to a Unicode RichEdit SQL editor with
  MiniSQL keyword, literal, number, quoted-identifier, and comment highlighting;
  added distinct current/selection and quote-aware whole-script execution paths;
- corrected CRLF-to-RichEdit offset translation so syntax styles, caret
  positions, selections, and current-statement execution stay aligned after
  every Windows line break;
- persisted the selected SQL/Object Details workspace across asynchronous
  metadata completion and native control rendering;
- replaced pipe-delimited object-detail text with native Columns, Indexes,
  Data, and Row Count grids; added a resizable row editor plus safe keyed add,
  copy, update, delete, confirmation, validation, and automatic preview refresh;
- prevented Windows QuickEdit selection from suspending the daemon during
  stdout logging, persisted file records before console output, and bounded the
  client HELLO handshake so both CLI and Workbench fail stalled endpoints;
- completed six post-1.0 SQL expansion blocks: `DROP INDEX` and additional
  `ALTER TABLE` actions; text/numeric/temporal functions and aggregates;
  derived tables and correlated subqueries; recursive CTEs and navigation/
  distribution window functions; durable schemas and `INFORMATION_SCHEMA`;
  and transactional `MERGE`, trigger enable/timing controls, and typed
  single-statement stored procedures;
- added focused parser, binder, executor, durability, negative-path, and reopen
  regressions across M16, M23, M24, M34, M35, M44, and M45;
- fixed the native compiler's Windows-x64 `input()` ABI path so allocator calls
  cannot clobber the interactive line length and exhaust the 4 GiB MiniLang heap
  on the first shell command; added compiler-level and MiniSQL shell regressions;
- replaced the one-page catalog and security snapshots with checksummed,
  crash-safe multi-page generations; removed the 1 MiB schema/statistics caps,
  16-bit security collection counts, and small-backup file/count ceilings while
  preserving automatic reads and migration of legacy databases;
- eliminated quadratic client response formatting and bounded retained script
  allocations, preventing persistent shell sessions from exhausting the
  MiniLang heap on repeated or wide query results;
- added a process-wide configurable logger with DEBUG/INFO/WARNING/ERROR
  thresholds, identical stdout and rolling-file output, configurable hourly
  rotation, and an optional independently durable SQL binlog that records every
  valid UTF-8 statement before parsing or execution;
- added regression coverage for multi-page catalogs, wide client results,
  logger severity filtering and rotation, security generation recovery, and the
  end-to-end server-session binlog hook;
- replaced the cooperative multi-client polling loop with a bounded native
  MiniLang thread pool and one long-lived worker job per active connection;
- added a writer-prioritized readers/writer gate per database: read-only SELECT,
  EXPLAIN and metadata plans can execute concurrently, while DML, DDL, DCL,
  sequence access, maintenance and session mutations remain exclusive;
- made the logical lock graph thread-safe, initialized read-path sidecars before
  publishing a database, added compatible shared table/index file locks, and
  synchronized external-sort spill identifiers and UTF-16 path marshalling;
- serialized all CNG RNG, PBKDF2, SHA/HMAC and AEAD native call sequences on
  the same recursive monitor so compiler-managed native argument buffers cannot
  overlap across authentication and secure-frame workers;
- replaced the Python TLS sidecar and plaintext proxy hop with an in-process
  Windows Schannel TLS 1.3 transport; the strict current profile accepts only
  `TLS_AES_256_GCM_SHA384` and X25519, validates X.509 chains and hostnames,
  supports explicit SHA-256 leaf pinning for self-signed deployments, handles
  post-handshake messages and emits authenticated `close_notify` alerts;
- taught build and acceptance commands to include the selected Python
  compiler's standard library automatically;
- fixed restart recovery after `DROP TABLE`: historical committed WAL images
  for catalog-proven retired table IDs are skipped without weakening strict
  missing-target validation, and recovery target lookup is now hash-based;
- added crash-safe automatic current-WAL reset with persistent replay epochs,
  configurable checkpoint thresholds, batched transaction WAL appends, and
  interrupted-reset recovery;
- made `runtime.bufferPoolBytes` an operational thread-safe CLOCK read cache;
  added early LIMIT/OFFSET range scans and projection pushdown so unrelated
  external TEXT/BLOB values are not materialized;
- externalized large ordinary DML values, batched overflow/page allocation,
  maintained insert-only indexes incrementally, and replaced eager VACUUM row
  retention with a one-row streaming rewrite plus periodic garbage collection;
- added restart-aware 1/5/10 GiB capacity profiles with fresh-process point
  lookups, WAL bounds, configurable private-memory guardrails, optional
  post-VACUUM verification, and JSON reports; the accepted 1 GiB reference run
  completed eight restart chunks and ended with a zero-byte current WAL;
- added Apache-2.0 headers to every MiniLang, Python and PowerShell source file,
  documented every declaration and non-obvious implementation invariant in
  English, and aligned the README, operator guides, concurrency specifications,
  TLS specification, contribution policy and notice with the shipped behavior.

## 1.0.0 — 2026-07-30

- completed and accepted milestones M0 through M50;
- passed 106/106 cumulative Windows x64 phases;
- froze database format version 1 and wire protocol version 1;
- delivered durable paged storage, WAL, recovery, transactions, constraints,
  DDL/DML/DCL, indexes, optimizer, maintenance, backup/restore, PITR, and
  migration;
- delivered persistent client/server operation, secure authentication, audit
  logging, TLS 1.3/X.509 sidecar integration, WAL shipping, and read-only hot
  standby;
- delivered prepared statements, schema evolution, views, CTEs, subqueries,
  windows, sequences, generated columns, triggers, UPSERT, `RETURNING`,
  `AUTO_INCREMENT`, exact decimal input, hash operators, and external sort;
- added deterministic parser/wire/WAL mutation tests, crash matrix, soak tests,
  performance guardrails, and reproducible Windows-x64 release packaging;
- finalized source cleanup for the GitHub-ready 1.0.0 repository snapshot.
