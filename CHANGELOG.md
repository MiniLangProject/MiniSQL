# Changelog

All notable release-level changes are documented here. The detailed milestone
and repair-candidate log from development is preserved in
`docs/history/DEVELOPMENT_CHANGELOG.md`.

## Unreleased — 2026-08-20

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
- made bounded TLS sidecars drain every accepted relay before process exit and
  replaced selector-based `SSLSocket` reads with directional blocking pumps, so
  post-handshake wakeups and fragmented final connections cannot reset clients;
- taught build and acceptance commands to include the selected Python
  compiler's standard library automatically;
- fixed restart recovery after `DROP TABLE`: historical committed WAL images
  for catalog-proven retired table IDs are skipped without weakening strict
  missing-target validation, and recovery target lookup is now hash-based;
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
