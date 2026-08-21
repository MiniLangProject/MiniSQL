# MiniSQL milestones

The MiniSQL 1.0 plan is frozen at **M50** and is complete.

```text
Completed: M0-M50
Open 1.0 milestones: 0
Final evidence: 106/106 phases PASS on Windows x64
Accepted source revision: M48-M50R3
```

## Development groups

| Range | Main outcome | Status |
|---|---|---|
| M0-M5 | project foundation, binary codecs, file layer, pages, buffer pool | Complete |
| M6-M10 | WAL, transactions, recovery, catalog, rows, overflow storage | Complete |
| M11-M15 | B+ tree, SQL frontend, binder, transactional DDL, basic DML | Complete |
| M16-M20 | relational execution, optimizer, protocol, savepoints, tooling | Complete |
| M21-M26 | DCL, prepared statements, index integration, schema evolution, maintenance, migration | Complete |
| M27-M32 | concurrent sessions, secret handling, secure transport, audit, PITR, operational CLI | Complete |
| M33-M37 | SQL-aware shell/scripts, introspection, scalar predicates, outer joins | Complete |
| M38-M42 | RETURNING, INSERT SELECT, conflict handling, UPSERT, TRUNCATE | Complete |
| M43-M47 | views, subqueries, CTEs, windows, sequences, triggers, optimizer v2, original TLS sidecar | Complete |
| M48-M50 | hot WAL shipping, hardening, 1.0 release freeze and distribution | Complete |

## Post-1.0 additions

| Milestone | Main outcome | Status |
|---|---|---|
| M73 | native TLS 1.3, exact AES-256-GCM/SHA-384 and X25519 profile, X.509 validation and pinning | Complete |

Historical milestone acceptance definitions remain under `docs/history/milestones/`. The final
machine-readable result is `docs/acceptance/MiniSQL-1.0.0-results.json`.

Future work belongs to a separately versioned post-1.0 roadmap.
