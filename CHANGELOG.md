# Changelog

All notable release-level changes are documented here. The detailed milestone
and repair-candidate log from development is preserved in
`docs/history/DEVELOPMENT_CHANGELOG.md`.

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
