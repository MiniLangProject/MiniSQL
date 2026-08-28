# MiniSQL changelog

## 1.0.0 — Python DB-API connector

- added a Python 3.10+ PEP 249 connector for trusted-local, authenticated, and
  TLS 1.3 sessions with exact SHA-256 certificate pinning;
- implemented protocol-v1 CRC-32C framing, continuation streaming, secure
  challenge/response, and inner AES-256-GCM through `cryptography`;
- added qmark parameter binding, a bounded server-side prepared-plan LRU, lazy
  transactions, automatic DDL transaction boundaries, and incremental bounded
  multi-row `executemany()` inserts with savepoint-backed failure semantics;
- added packaging, English usage/security documentation, seven unit tests, and
  1,216 live checks in each trusted, authenticated, and pinned self-signed TLS
  mode.

## 1.0.0 — JDBC latency and batching update

- moved JDBC `PreparedStatement` execution onto session-local MiniSQL
  `PREPARE`/`EXECUTE` plans, retaining a compatibility fallback for unsupported
  statements and older servers;
- coalesced compatible single-row JDBC insert batches into bounded 256-row,
  768-KiB multi-row requests while preserving per-entry update counts and
  first-failure behavior through atomic retry and internal savepoints;
- enabled `TCP_NODELAY` on native connected and accepted sockets and emitted
  complete Java protocol frames with one write, eliminating the Windows TLS
  delayed-record latency;
- expanded the trusted, authenticated, and pinned self-signed TLS integration
  suite to 1,669 checks per mode, including server-plan lifecycle and a
  quote-sensitive 600-row batch.

## 1.0.0 — optimizer and execution expansion

- propagated typed non-NULL constants through top-level INNER/CROSS equality
  graphs while retaining original predicates as semantic guards;
- added costed row-reference intersection for independently indexed conjunctions
  and deduplicating union for fully indexed disjunctions;
- upgraded the advisory statistics sidecar to format 5 with numeric/date
  equi-depth histograms, hashed text/binary/wide-decimal MCVs, and composite
  tuple MCVs while retaining readers for formats 1–4;
- added validated disk partitions for large hash joins and grouped aggregates,
  processed by up to four native intra-query workers;
- added bounded protocol-v1 continuation frames, transparent client reassembly,
  and a 1,200-row independent server/client regression;
- retained database page format 1 and wire protocol version 1.

## 1.0.0 — comma-separated FROM sources

- accepted optional-`AS` aliases on every source in a comma-separated FROM list;
- lowered comma sources to the existing typed CROSS-join representation so
  execution, WHERE filtering, qualified binding, and derived tables reuse one
  relational path;
- promoted a connecting typed WHERE equality to an INNER edge so large legacy
  joins use the existing costed hash/index algorithms instead of materializing
  their cartesian product;
- removed each promoted equality from the residual WHERE tree so execution and
  cost estimation do not apply an already guaranteed join condition twice;
- added parser and relational execution regressions for cartesian and
  WHERE-restricted equijoin forms.

## 1.0.0 — functional indexes

- added deterministic single-expression keys for `CREATE [UNIQUE] INDEX`, with
  optional INCLUDE payloads and partial predicates;
- persisted canonical keys through a reserved marker in the existing
  schema-history array, retaining format 1 and ordinary-index compatibility;
- evaluated computed keys in unique validation, inserts, rebuild, repair,
  REINDEX, VACUUM, and streaming verification;
- added exact-expression costed B+ tree probes, SHOW rendering, rename/drop
  dependencies, reopen, mutation, uniqueness, and negative-path tests.

## 1.0.0 — partial indexes

- added `CREATE [UNIQUE] INDEX ... [INCLUDE (...)] WHERE predicate` parsing,
  immutable base-expression binding, canonical durable metadata, rename/drop
  dependency handling, and `SHOW INDEXES` predicate introspection;
- filtered construction, insert deltas, unique validation, updates, deletes,
  startup repair, `REINDEX`, `VACUUM`, and streaming consistency verification
  with SQL `TRUE`/`FALSE`/`NULL` predicate semantics;
- added conservative typed-conjunct implication so only proven single-table
  plans select partial index or partial index-only scans, while joins and
  unqualified legacy paths retain complete-row access;
- extended the proof with stronger typed single-column equality/range bounds,
  strict/inclusive boundary handling, and comparison-to-`IS NOT NULL` without
  introducing general Boolean theorem proving;
- prevented partial unique indexes from being inferred as table-wide foreign
  key or predicate-free `ON CONFLICT` arbiters and added parser, DDL, DML,
  persistence, negative-path, and optimizer regression coverage.

## 1.0.0 — covering index payloads

- added `CREATE [UNIQUE] INDEX ... INCLUDE (...)` parsing, binding, durable
  catalog metadata, introspection, and key/INCLUDE overlap validation;
- added versioned covering leaf payloads after the stable row-reference prefix,
  retaining transparent reads of legacy 12-byte index values;
- extended costed `Index Only Scan` selection and typed reconstruction across
  key plus INCLUDE columns without opening heap or overflow pages;
- maintained and verified complete payloads through INSERT, UPDATE, startup
  repair, `REINDEX`, and `VACUUM`, with focused parser, persistence, planner,
  and corruption-safe fallback coverage.

## 1.0.0 — advanced optimizer statistics and access paths

- upgraded the CRC-protected advisory statistics sidecar to format 4 with
  bounded integral/date histograms, most-common values, and joint distinct
  counts for composite index keys while retaining readers for formats 1–3;
- replaced greedy join selection through eight sources with a bounded
  Selinger-style subset dynamic program and retained a deterministic fallback
  for larger or unsupported graphs;
- added costed key-covering `Index Only Scan` execution that reconstructs typed
  rows from B+ tree keys without opening heap or overflow pages;
- added skew, correlation, migration, covering-scan, and dynamic-join regression
  coverage without changing database page format 1 or wire protocol 1.

## 1.0.0 — cost-based optimizer and bounded execution update

- added a typed executable plan shared by `EXPLAIN` and runtime execution;
- added constant folding, safe predicate pushdown, costed B+ tree scans,
  distinct-value join estimates, smaller-side hash builds, greedy inner-equijoin
  ordering, Top-N, streaming scalar aggregates, and 128-row scan batches;
- added exact live-row counting with bounded 8,192-row `ANALYZE` sampling and a
  backward-compatible CRC-protected statistics sidecar format 3 with compact
  integral/date bounds;
- added a 64-entry per-session plan cache with allocation-free exact-SQL hot
  keys, canonical nested-plan keys, and shared DDL/maintenance
  invalidation and richer `EXPLAIN ANALYZE` timing/buffer metrics;
- fixed non-unique B+ trees whose duplicate keys span multiple leaves;
- reused one heap/schema reader per index candidate set, streamed filtered
  scalar aggregates, fused single-table Top-N, and counted the final edge of
  reordered inner-equijoin `COUNT(*)` without materializing it;
- added the M75 optimizer regression suite and retained database page format 1
  and wire protocol 1.

## 1.0.0 — M48-M50R3 release candidate

- evaluated `MiniSQL_M48_M50R2_RESULTS_20260730-124722.zip`: 60 of 61 executed phases passed; M0-M47 remained accepted and no M48-M50 candidate phase ran;
- used the new R2 diagnostics to identify all three M27 clients failing after the cooperative server misclassified WinSock `SOCKET_ERROR` as an impossible positive byte count;
- corrected WinSock C `int` return declarations, including `send` and `recv`, to signed MiniLang `i32`;
- retained a fail-closed comparison with the zero-extended `0xFFFFFFFF` bit pattern for older compiler behavior;
- added a real loopback regression that forces non-blocking `WSAEWOULDBLOCK`, direct-offset send/receive, and blocking `receiveExact` before the M27 integration test;
- added exact invalid-count diagnostics, R2 failure evidence, R3 acceptance documentation, and ADR-0083;
- changed no database, page, row, WAL, durable-marker, catalog, schema-extension, index, security, backup, audit, archive, PITR, wire, TLS, replication, or distribution format.

## 1.0.0 — M48-M50R2 release candidate

- evaluated `MiniSQL_M48_M50R1_RESULTS_20260730-105131.zip`: 59 of 60 executed phases passed; the M0-M47 accepted baseline remained unchanged and no M48-M50 candidate phase ran;
- recorded the opaque M27 concurrent client-1 exit (`rc=1`, empty stdout/stderr) and fixed the harness so every client and the server are always captured before failure reporting;
- replaced copy-per-fragment WinSock send/receive loops with synchronous direct-offset pointers into strongly referenced MiniLang `bytes` values;
- changed `receiveExact` to fill its final result buffer in place across arbitrary partial reads;
- added one reusable 64-KiB receive scratch buffer per protocol connection and explicit bounded frame-buffer append/extract operations;
- removed unchecked `slice` and overloaded byte concatenation from the protocol connection and frame-decoder hot paths;
- added stage-specific M27 client diagnostics and equivalent complete M29 concurrent-process log capture;
- added R1 failure evidence, R2 acceptance documentation and ADR-0082;
- changed no database, page, row, WAL, durable-marker, catalog, schema-extension, index, security, backup, audit, archive, PITR, wire, TLS or distribution format.

## 1.0.0 — M48-M50R1 release candidate

- evaluated `MiniSQL_M48_M50_RESULTS_20260730-092348.zip`: 92 phases passed; M0-M47 remained accepted and the cumulative M47 TLS regression failed before any M48-M50 candidate test ran;
- confirmed TLS 1.3 negotiation, CA verification, and wrong-host rejection succeeded; the public `minisql.exe --ping` path then surfaced runtime error 1200 (`len(void)`);
- removed unchecked `slice` results from blocking WinSock send/receive framing and added explicit byte-range copies, concrete byte checks, and impossible native-count validation;
- made `receiveExact` explicitly safe for arbitrary positive TCP fragmentation;
- added deterministic 5-byte and 7-byte relay fragmentation to the existing public TLS client/server integration test while preserving production sidecar defaults;
- added failure evidence, R1 acceptance documentation, ADR-0081, and package/result revision `M48-M50R1`;
- changed no database, page, row, WAL, durable-marker, catalog, schema-extension, index, security, backup, audit, archive, PITR, wire, or release-distribution format.

## 1.0.0 — M48-M50 release candidate

- accepted M0-M47 from `MiniSQL_M43_M47R10_RESULTS_20260729-202301.zip` with 95/95 Windows phases;
- added a durable WAL-prefix marker published only after the WAL data flush, plus lock-free live archive export for a running primary;
- added double-buffer read-only standby materialization and a stable loopback switch for continuous WAL shipping;
- added deterministic parser, protocol and WAL mutation tests, a repeatable crash matrix, soak workload and explicit performance/compatibility guardrails;
- froze product version `1.0.0`, database format version 1 and wire protocol version 1;
- added deterministic Windows-x64 distribution packaging with embedded manifests and SHA-256 verification;
- added complete release, administration, security, backup/recovery, replication, limitation and upgrade documentation;
- retained all M0-M47 SQL functionality including AUTO_INCREMENT, exact DECIMAL values and scientific approximate literals;
- changed no existing database, page, row, catalog, index, security, backup, audit, archive or wire format; the new WAL durable marker is an independently versioned sidecar.

## 0.47.0-m47 — M43-M47 engine revision R10

- evaluated `MiniSQL_M43_M47R9_RESULTS_20260729-191128.zip`: 90 of 91 executed phases passed; M0-M44 remained green and M45 failed while parsing the first row-trigger body;
- traced SQL error 9019 to `NEW` and `OLD` being correctly tokenized as reserved keywords while `parsePrimary` had no dedicated qualified pseudo-row rule;
- added a narrow parser path for `NEW.column` and `OLD.column` that creates canonical qualified column expressions without making bare `NEW` or `OLD` general identifiers;
- extended the M12 parser regression with trigger-body AST, canonicalization, formatting, and bare-keyword rejection checks;
- retained the existing M45 typed-literal replacement and event-availability validation paths;
- added R9 failure evidence, R10 candidate documentation, and ADR-0076;
- changed package/result revision to `M43-M47R10`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, schema-extension, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.


## 0.47.0-m47 — M43-M47 engine revision R9

- evaluated `MiniSQL_M43_M47R8_RESULTS_20260729-182026.zip`: 90 of 91 executed phases passed; M0-M44 remained green and M45 failed before trigger execution;
- traced SQL error 9019 to the lexer correctly tokenizing `ACTION` as a keyword while the explicit contextual-identifier list omitted it;
- added `ACTION` to the non-reserved identifier keyword policy without changing `NO ACTION` referential-action parsing;
- extended the M12 parser regression to cover CREATE/INSERT/SELECT with an unquoted `action` column and both `ON DELETE NO ACTION` and `ON UPDATE NO ACTION`;
- added R8 failure evidence, R9 candidate documentation and ADR-0075;
- changed package/result revision to `M43-M47R9`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, schema-extension, index, security, backup, audit, archive, wire, secure-transport or TLS-sidecar format.


## 0.47.0-m47 — M43-M47 engine revision R8

- evaluated `MiniSQL_M43_M47R7_RESULTS_20260729-163344.zip`: 90 of 91 executed phases passed; M0-M44, AUTO_INCREMENT/exact-decimal compatibility, M43, and M44 remained green;
- traced M45 error `extensions belong to another database` to the schema-extension identity path retaining heap-backed IDs through allocation-heavy sizing/envelope work and comparing `slice(payload, 0, 16)` with the expected ID in one nested expression;
- materialized `SchemaState` constructor arguments before construction, snapshot extension database identities into four U32 scalar words before encode/decode allocations, compare the embedded identity without an allocating slice, and construct the decoded state from a fresh verified ID;
- made the mixed codec test materialize its record inputs and recreate the expected ID immediately before decode;
- added explicit 16-byte identity validation, an exact round-tripped identity assertion, static recurrence guards, R7 failure evidence, and ADR-0074;
- changed package/result revision to `M43-M47R8`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, schema-extension, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.


## 0.47.0-m47 — M43-M47 engine/test revision R7

- evaluated `MiniSQL_M43_M47R6_RESULTS_20260729-154847.zip`: 90 phases passed and phase 91, the M45 schema-extension test, failed; M0-M44, compatibility, M43, and M44 remained green;
- traced the failure to the mixed codec regression's nested expression encoding its first argument before dereferencing `managed.catalogHandle` for the second argument, where the receiver was observed as `void`;
- isolated the pure codec roundtrip from the live database owner by using a deterministic standalone database ID, separate encode/decode statements, and creating the real database only after codec assertions;
- added a static recurrence guard, R6 failure evidence, ADR-0073, and package/result revision `M43-M47R7`;
- changed no SQL semantics and no persisted database, page, row, WAL, catalog, schema-extension, index, security, backup, audit, archive, transport, wire, or TLS-sidecar format.


## 0.47.0-m47 — M43-M47 engine/test revision R6

- evaluated `MiniSQL_M43_M47R5_RESULTS_20260729-135756.zip`: 90 of 91 executed phases passed; M0-M44 passed, M45 failed, and M46-M47 were not executed;
- accepted M44 nonrecursive CTEs and window functions from that cumulative Windows evidence;
- traced the M45 `len(void)` failure to the large monolithic `decodeExtensions` lifetime shape: a valid sequence payload was observed as `void` only at the final post-block length check;
- split view, sequence, generated-column, and trigger decoding into isolated cursor functions and captured the immutable payload length before entering record blocks;
- replaced extension-decoder struct-array concatenation with explicit fixed-array append;
- added a direct mixed-record extension roundtrip covering all four record families before the M45 SQL scenario;
- added static recurrence guards, failure evidence, M44 status evidence, and ADR-0072;
- changed package/result revision to `M43-M47R6`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, schema-extension, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.

## 0.47.0-m47 — M43-M47 test revision R5

- evaluated `MiniSQL_M43_M47R4_RESULTS_20260729-125719.zip`: 89 of 90 executed phases passed; M0-M43 passed, M44 failed, and M45-M47 were not executed;
- accepted M43 persisted views and non-correlated subqueries from that cumulative Windows evidence;
- traced both M44 failures to direct comparison of window `SUM` result `Int64Words` structs with native integers;
- changed the two assertions to use the existing `endian.int64ToInt`-based helper, matching `COUNT`, ranking, and sequence tests;
- added static recurrence guards, failure evidence, M43 status evidence, and ADR-0071;
- changed package/result revision to `M43-M47R5`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no engine behavior and no persisted database, page, row, WAL, catalog, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.

## 0.47.0-m47 — M43-M47 test revision R4

- evaluated `MiniSQL_M43_M47R3_RESULTS_20260729-102002.zip`: 88 of 89 executed phases passed; M0-M42 and the AUTO_INCREMENT/decimal compatibility phase passed, M43 failed, and M44-M47 were not executed;
- confirmed that the dropped view was removed successfully and the engine correctly returned `ObjectNotFound` (`9014`) when it was queried afterward;
- corrected the M43 test, which had incorrectly expected generic `BindingError` (`9020`);
- documented the missing-relation error contract and added a static recurrence guard;
- changed package/result revision to `M43-M47R4`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no engine behavior and no persisted database, page, row, WAL, catalog, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.

## 0.47.0-m47 — M43-M47 engine/test revision R3

- evaluated `MiniSQL_M43_M47R2_RESULTS_20260729-080226.zip`: 87 phases passed and phase 88, the dedicated AUTO_INCREMENT/decimal compatibility test, failed; M0-M42 remained green and no M43-M47 feature phase ran;
- traced `sql.values.literalFloat: invalid floating literal` to the approximate-number path delegating `1.25e2` to MiniLang `toNumber`, whose native grammar accepts ordinary integers/decimals but not exponent notation;
- added an explicit finite scientific-notation parser for SQL REAL/DOUBLE literals and text-to-approximate-numeric CAST operations while retaining the direct native conversion path for ordinary spellings;
- extended the compatibility test with positive and negative scientific exponents and retained exact token-based DECIMAL conversion;
- changed package/result revision to `M43-M47R3`, retained exactly one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, index, security, backup, audit, archive, wire, secure-transport, or TLS-sidecar format.

## 0.47.0-m47 — M43-M47 engine/test revision R2

- evaluated `MiniSQL_M43_M47R1_RESULTS_20260728-220057.zip`: 42 phases passed and phase 43, the accepted M20 deterministic workload regression, failed before any M43-M47 functional phase ran;
- retained the accepted M0-M42 baseline and left M43-M47 as candidates;
- traced runtime error 1303 at `executor.scan.decodeRecord` to the nested row-value append using MiniLang's overloaded `+` and entering its string-concatenation fallback;
- replaced scan-row materialization with a pre-sized array and indexed assignment, plus an explicit array copy-and-append helper for schema-evolution values and scanned-row collection;
- added a static recurrence guard and documented the exact R1 evidence;
- retained `AUTO_INCREMENT`, `AUTOINCREMENT`, exact `3.3` input for REAL/DOUBLE, and exact token-based `DECIMAL(p,s)` conversion;
- changed the package/result revision to `M43-M47R2`, retained one root `test.ps1`, and kept the cumulative gate at 95 phases;
- changed no persisted database, page, row, WAL, catalog, index, security, backup, audit, archive, transport or wire format.

## 0.47.0-m47 — M43-M47 engine/test revision R1

- evaluated `MiniSQL_M43_M47_RESULTS_20260728-184742.zip`: four static phases passed and application compilation failed in phase 5; no M43-M47 functional phase ran;
- retained the accepted M0-M42 baseline and left M43-M47 as candidates;
- repaired the `EXISTS (SELECT ...)` and nested-CTE parser paths by defining `query` in their enclosing MiniLang lexical scopes before branch assignment;
- added `AUTO_INCREMENT` and `AUTOINCREMENT` as compatibility aliases for the existing `GENERATED ALWAYS AS IDENTITY` semantics;
- added target-directed decimal-point INSERT literals for REAL and DOUBLE PRECISION;
- added exact token-to-scaled-integer conversion for DECIMAL(p,s), with no silent rounding or truncation;
- added end-to-end compatibility, persistence, prepared-statement and negative tests;
- changed the package/result revision to `M43-M47R1`, retained exactly one root `test.ps1`, and expanded the cumulative gate to 95 phases;
- changed no persisted database, page, WAL, catalog, index, security, backup, audit, archive, transport or wire format.

## 0.47.0-m47 — M43-M47 acceptance candidate

- accepted M0-M42 from `MiniSQL_M38_M42R1_RESULTS_20260728-162828.zip` with 87/87 Windows phases;
- added persisted views and non-correlated scalar, EXISTS and IN/NOT IN subqueries;
- added materialized nonrecursive CTEs and ROW_NUMBER/RANK/DENSE_RANK plus aggregate windows;
- added protected schema-extension storage for views, sequences, generated columns and triggers;
- added durable NEXTVAL/CURRVAL, stored generated columns and basic AFTER-row DML triggers;
- integrated deterministic hash joins, hash grouping and strictly validated external merge-sort runs;
- added a Python-standard-library TLS 1.3/X.509 server terminator, verified client proxy and real public-application integration test;
- retained exactly one root `test.ps1` and expanded the cumulative gate to 94 phases;
- left all previously accepted database, page, WAL, catalog, security, backup, audit, archive and wire formats unchanged; new sidecars/runs are separately versioned.

# Changelog

## 0.42.0-m42 — M38-M42 engine/test revision R1

- evaluated `MiniSQL_M38_M42_RESULTS_20260728-153809.zip`: M0-M38 passed, M39 failed, and M40-M42 were not executed;
- accepted M38 DML RETURNING from that cumulative Windows evidence;
- traced zero-row `INSERT ... SELECT` results to iterating the `QueryResult` wrapper instead of `QueryResult.rows`;
- changed `materializeInsertSelect` to validate the query result and materialize its row array before any target mutation;
- guarded M39 indexed assertions so a cardinality failure cannot be hidden by a secondary array-bounds exception;
- added a static recurrence guard and package/result revision `M38-M42R1`;
- changed no persisted database, WAL, catalog, index, security, backup, audit, archive, transport or wire format.

## 0.31.0-m31 — M27-M31 test revision R4

- evaluated `MiniSQL_M27_M31R3_RESULTS_20260727-222150.zip`: 62 of 63 executed phases passed; M0-M28 and the direct M29 AES-GCM phase passed, the encrypted process phase failed, and M30-M31 were not executed;
- confirmed client 1 returned exit code zero and printed `MiniSQL M29 secure concurrent client worker: SUCCESS id=1`;
- traced the failure to the shared Python harness constructing an expected line from the shorter prefix `MiniSQL M29 secure`;
- aligned the M29 parallel-client verifier with the worker's exact `secure concurrent` output contract;
- added a static recurrence guard, R3 failure evidence and package/result revision `M27-M31R4`;
- changed no engine feature behavior and no persisted, audit, archive, secure-transport or wire format.

## 0.31.0-m31 — M27-M31 test revision R3

- evaluated `MiniSQL_M27_M31R2_RESULTS_20260727-213948.zip`: 62 of 63 executed phases passed; M0-M28 are PASS, M29 failed, and M30-M31 were not executed;
- accepted M27 and M28 from that cumulative Windows evidence;
- confirmed the M29 AES-GCM test completed all twelve assertions with exactly one failure and that every assertion after packet construction passed;
- traced the sole failure to comparing a concrete cross-package struct through `typeName(packet) == "AeadPacket"`;
- replaced the string comparison with the existing package-local predicate `uuid.isAeadPacket(packet)`;
- added a static recurrence guard, R2 failure evidence and package/result revision `M27-M31R3`;
- changed no engine feature behavior and no persisted, audit, archive, secure-transport or wire format.

## 0.31.0-m31 — M27-M31 test revision R2

- evaluated `MiniSQL_M27_M31R1_RESULTS_20260727-182611.zip`: all 59 phases through M26 passed and phase 60, the first M27 phase, failed;
- confirmed that the accepted M0-M26 baseline remains valid and that M28-M31 were not executed;
- traced the failure to an M27 test comparing an internal `SqlValue(Int64Words)` COUNT result directly with an integer;
- identified two latent representation mismatches before rerun: numeric wire values are UTF-8 fields and the M31 direct COUNT helper also returned an unwrapped `SqlValue`;
- changed direct executor COUNT assertions to unwrap `SqlValue.value` and convert `Int64Words` losslessly;
- changed M27 network assertions to parse numeric wire fields with `toNumber`;
- made `testkit.equal` render structs, enums, arrays, bytes, errors and `void` without triggering a second runtime failure;
- added static recurrence guards and package/result revision `M27-M31R2`;
- left all 71 engine modules except the package revision marker unchanged and changed no persisted or wire format.

## 0.31.0-m31 — M27-M31 engine/test revision R1

- evaluated `MiniSQL_M27_M31_RESULTS_20260727-173107.zip`: 47 phases passed and phase 48 failed in the M21 authentication protocol regression;
- confirmed the accepted M0-M26 baseline and that no M27-M31 candidate phase was executed;
- traced `audit sequence is not continuous` to `appendAudit` validating a later one-record suffix with the complete-segment scanner that requires sequence 1;
- added predecessor-sequence-aware suffix validation while retaining strict complete-segment validation;
- moved suffix validation before durable publication and derives the next in-memory sequence from the validated result;
- added direct suffix, strict segment and repeated durable append regressions;
- changed package/result revision to `M27-M31R1` and retained one 68-phase `test.ps1` gate;
- left audit-log v1 and every other persisted database, WAL, catalog, index, security, backup, archive and transport format unchanged.

## 0.31.0-m31 — M27-M31 acceptance candidate

- added cooperative multi-session server scheduling with shared database ownership
- added reader/writer wait graph, deadlock victim selection and bounded lock waits
- added no-echo password prompting, byte-oriented secret APIs, wiping and login hardening
- added directional AES-256-GCM MiniSQL Secure Transport v1 and controlled remote binding
- added keyed durable audit chain, audit rotation, backup/check integration
- added grantor-aware REVOKE RESTRICT and CASCADE for roles and privileges
- added complete-prefix WAL archive generations and exact-LSN point-in-time recovery
- added offline standby materialization, refresh, normal-open refusal and promotion
- added one cumulative 68-phase launcher and one M27-M31 result archive

# MiniSQL changelog

## 0.26.0-m26 — M22-M26 test revision R1

- evaluated `MiniSQL_M22_M26_RESULTS_20260727-095704.zip`: 50 phases passed and phase 51 failed in the legacy M21 71-module smoke test;
- confirmed that all functional M0-M21 phases reached before the smoke test still passed and that no M22-M26 functional test ran;
- traced the failure to exact package-global assertions for `0.21.0-m21` and `M21` inside the cumulative M21 regression;
- made the M21 and M26 module smoke tests monotonic while retaining exact current version coverage in five application `--version` tests and the static manifest gate;
- added a generic static recurrence guard for every cumulative all-module smoke test;
- changed package/result revision to `M22-M26R1` and retained one 59-phase `test.ps1` gate;
- left engine feature behavior and every persisted database, WAL, catalog, index, security, backup, maintenance and migration format unchanged.

## 0.26.0-m26 — M22-M26 acceptance candidate

- accepted M0-M21 from `MiniSQL_M21R1_RESULTS_20260727-074940.zip` with 52/52 phases;
- added session-local PREPARE/EXECUTE/DEALLOCATE with positional AST parameters;
- added index-aware DML repair, equality/range/compound seeks, indexed joins and checker verification;
- added transactional ALTER TABLE for compatible column/schema operations and constraints;
- added VACUUM, REINDEX, a two-state maintenance swap journal and WAL-horizon reset;
- added source-to-target page-size migration with logical row/LOB rewrite, security transfer, index rebuild and pre-publication checking;
- added one cumulative 59-phase launcher and one result ZIP;
- retained all existing persisted formats except the new `MSMAINT1` maintenance journal.

## 0.21.0-m21 packaging revision R1

- evaluated `MiniSQL_M21_RESULTS_20260727-071423.zip`: 49/52 phases passed; M0-M20 were reconfirmed and the first four M21 phases passed
- fixed the SQL parser so supported type and aggregate keywords are contextual rather than fully reserved in identifier positions
- retained the original `audit_item.text` security-tools workload as an end-to-end regression
- added CREATE TABLE, INSERT, SELECT and ANALYZE parser regressions for `text`, `date` and `count` identifiers
- documented the reserved/contextual keyword policy in ADR-0038 and the SQL front-end specification
- changed only parser behavior and acceptance packaging; all persisted and wire formats remain unchanged
- changed the evidence archive to `MiniSQL_M21R1_RESULTS_<timestamp>.zip` and retained one root `test.ps1` launcher

## 0.21.0-m21

- accepted M0-M20 from `MiniSQL_M16_M20R1_RESULTS_20260726-215231.zip` with 45/45 phases passing;
- added users, roles, PUBLIC, role inheritance, ADMIN OPTION and cycle rejection;
- added database and table privileges with GRANT OPTION and owner semantics;
- added CREATE/ALTER/DROP USER, CREATE/DROP ROLE, GRANT and REVOKE SQL;
- added two-generation CRC-protected `catalog/security.tbl` with automatic M20 bootstrap;
- added PBKDF2-HMAC-SHA-256 password verifiers through Windows CNG;
- added nonce-based mutual challenge-response authentication and generic failure responses;
- added authenticated loopback server/client modes and statement authorization;
- added security-aware consistency checking and verified backup/restore;
- added one cumulative 52-phase M0-M21 acceptance gate and one result archive.

## 0.20.0-m20 engine/test revision R1

- evaluated `MiniSQL_M16_M20_RESULTS_20260726-211756.zip`: phases 1-36 passed and phase 37 failed in M17
- accepted M16 joins, grouping, aggregates, sort and set operations from that cumulative Windows run
- traced `Cannot access member 'databaseId' on non-struct value` to the statistics loader's unqualified internal `decode(...)` call
- retained the public qualified API `statistics.decode(...)` and renamed the internal implementation to `decodeCatalog(...)`
- changed `statistics.loadOrCreate` to call `decodeCatalog(...)` and added a concrete `StatisticsCatalog` guard
- added an M17 regression assertion that loading persisted statistics returns the concrete catalog type
- extended ADR-0022 and added a static source guard that rejects the failed ambiguous call form
- changed the package and result revision to `M16-M20R1`
- recorded M0-M16 as the accepted baseline and left M17-M20 as candidates
- left statistics v1 and every other persisted database, wire and backup format unchanged
- retained exactly one user-facing test launcher, `test.ps1`, and all 45 cumulative phases

## 0.15.0-m15 engine/test revision R1

- evaluated `MiniSQL_M11_M15_RESULTS_20260726-143135.zip`: phases 1-32 passed and phase 33 failed in M14
- accepted M11 persistent B+ tree, M12 SQL front end and M13 binder/type/value semantics from that cumulative Windows run
- traced Win32 error 33 to DDL before-image reads reopening `db.meta` and `catalog.tbl` while their paged-file owner handles held exclusive whole-file locks
- added `paged_file.snapshotDurableBytes(pagedFile, maxBytes)`, which flushes and reads through the existing lock-owning handle
- changed M14 to use that operation for both physical metadata before-images and retained path-based reads only for unlocked sidecars
- added native owner-handle regression checks plus static guards against path-based reopening of the two locked metadata files
- documented the failure, accepted M11-M13 evidence and ADR-0029
- changed the package/result revision to `M11-M15R1`
- left every persisted DDL, catalog, database, table, index, WAL, row and overflow format unchanged
- retained exactly one user-facing test launcher, `test.ps1`, and all 36 cumulative phases

## 0.15.0-m15 candidate

- accepted M0 through M10 from `MiniSQL_M6_M10R3_RESULTS_20260726-122529.zip` with 30/30 Windows phases passing
- implemented persistent unique and non-unique B+ tree index files with copy-on-write generation publication
- implemented SQL tokenization, parsing and ASTs for the first documented MiniSQL SQL subset
- implemented catalog binding, SQL type descriptors, full-domain BIGINT values and three-valued logic
- kept all full-domain BIGINT decimal parsing integer-only, including exact `-9223372036854775808` binding
- made the schema-history decoder use an unambiguous package-local helper rather than MiniLang's `decode` builtin
- made DML scans reuse the already-open exclusive table handle instead of reopening the same file
- implemented transactional `CREATE TABLE`, `CREATE INDEX` and `DROP TABLE` with a recoverable before-image DDL journal
- implemented metadata for identity, defaults, primary keys, unique, check and foreign-key constraints
- implemented multi-row `INSERT`, `UPDATE`, `DELETE` and basic single-table `SELECT`
- implemented autocommit and explicit `BEGIN`/`COMMIT`/`ROLLBACK`, read-your-writes and read-only enforcement
- made committed page publication retain its pending batch until every base file write and flush succeeds
- added M11-M15 native tests plus a monotonic 71-module implementation smoke test
- retained exactly one user-facing test launcher, `test.ps1`, which executes all 36 cumulative phases
- changed the single result archive to `MiniSQL_M11_M15_RESULTS_<timestamp>.zip`
- documented current limitations: scan-based query/constraint execution, no joins/aggregation/optimizer/network/DCL yet

## 0.10.0-m10 engine/test revision R3

- evaluated `MiniSQL_M6_M10R2_RESULTS_20260726-115108.zip`: phases 1-20 passed and phase 21 failed in M7 recovery
- confirmed M6 as `PASS`; M7 checkpoint passed, while M8-M10 were not yet executed
- traced the failure to an unqualified `typeName` short-name comparison that rejected a valid concrete struct
- audited and removed the same latent pattern from configuration, catalog, row-codec and overflow paths
- added package-local predicates using `value is LocalStruct` for cross-package concrete-type validation
- changed the M9 external-LOB test to use the owning package predicate
- added a static recurrence guard that rejects short-name `typeName` comparisons in engine and test sources
- left every persisted binary format unchanged
- changed the single result archive to `MiniSQL_M6_M10R3_RESULTS_<timestamp>.zip`

## 0.10.0-m10 engine/test revision R2

- evaluated `MiniSQL_M6_M10R1_RESULTS_20260726-113304.zip`: phases 1-17 passed and phase 18 failed in the M6 WAL scan
- confirmed the accepted M0-M5 baseline again; M7-M10 were not executed after the M6 failure
- traced `Cannot access member 'lsn' on non-struct value` to an unqualified internal `decode(encoded)` call
- retained the public qualified API `wal.decode(...)` but renamed the internal implementation to `decodeRecord(...)`
- changed `scanFile` to call `decodeRecord(...)`, preventing collision with MiniLang's builtin `decode(bytes[, encoding])`
- added a static source contract that requires the unambiguous helper and rejects the failed R1 call form
- left WAL v1 and all other persisted binary formats unchanged
- changed the single result archive to `MiniSQL_M6_M10R2_RESULTS_<timestamp>.zip`

## 0.10.0-m10 packaging/test revision R1

- evaluated `MiniSQL_M6_M10_RESULTS_20260726-093636.zip`: phases 1-6 passed and phase 7 failed before any M6 test
- removed the M1 assertion that M2 varint must still be a stub
- audited and removed equivalent negative future-state assertions from the M5 and M10 module regressions
- removed old global product-version and milestone pinning from cumulative regression payloads
- added a static monotonic-regression contract to prevent recurrence
- corrected the documented cumulative phase count from 32 to 30
- changed the result archive to `MiniSQL_M6_M10R1_RESULTS_<timestamp>.zip`
- left all MiniLang engine modules and persisted file formats unchanged

## 0.10.0-m10 candidate

- accepted M2, M3, M4 and M5 from `MiniSQL_M2_M5R2_RESULTS_20260726-020415.zip` with 19/19 phases passing
- retained exactly one user-facing cumulative acceptance launcher, `test.ps1`
- implemented WAL record format v1, transaction-private page images, durable commit ordering and rollback
- implemented a conservative database-level read/write lock manager
- implemented redundant checkpoint metadata and committed-only idempotent full-page redo
- added real process-termination tests for committed and uncommitted recovery paths
- implemented strict JSON configuration loading and immutable persisted database format defaults
- implemented database directories, UUID identity, db metadata, catalog metadata and physical table-file checks
- implemented slotted pages, generation-protected RowIds, row codec v1 and heap files
- implemented multi-page overflow chains, ranged reads, corruption detection, free-page reuse and two-phase replacement
- hardened failed commits to rewind every unacknowledged WAL append region and bounded hostile WAL record lengths
- rejected unknown configuration keys and non-canonical JSON integers; capped configuration input to 1 MiB
- made object/transaction high-water marks monotonic and enforced global catalog object-ID uniqueness
- integrated committed table-page recovery into database-manager startup before sessions are exposed
- made heap deletion durably remove the externally visible root before reclaiming forwarding records
- added a cumulative 30-phase M0-M10 Windows acceptance runner and one result archive
- documented current boundaries: one physical WAL file with logical segment geometry, provisional textual float encoding, and no SQL/DDL/DML yet

## 0.10.0-m10

- accepted M2 through M5 from the uploaded 19/19-phase Windows result archive;
- implemented checksummed append-only WAL records and transaction-private full page images;
- implemented commit-before-acknowledgement ordering, rollback and WAL fault injection;
- retained committed page batches for post-commit publication;
- implemented conservative database reader/writer locks;
- implemented redundant checkpoint metadata and committed-only, pageLSN-idempotent recovery;
- added separate-process committed and uncommitted crash-recovery tests;
- implemented strict JSON configuration loading and validation;
- implemented UUID-backed database directories, immutable persisted defaults and bootstrap catalogs;
- implemented durable object/transaction ID high-water marks and physical table-file validation;
- implemented slotted pages, generation-safe RowIds, forwarding heap records and row format v1;
- prevented slot-generation wraparound by permanently retiring saturated slots;
- implemented multi-page TEXT/BLOB overflow chains, range reads, full validation and page reuse;
- implemented two-phase LOB replacement so the old chain is reclaimed only after pointer publication;
- added one cumulative M0-M10 test launcher and one cumulative result archive.

## 0.5.0-m5 packaging revision R2

- reviewed all four uploaded R1 result archives; each failed before compilation because `build/.gitkeep` was missing
- replaced four milestone wrapper scripts with one cumulative `test.ps1`
- made the launcher always run every regression and candidate test through M5
- made the launcher remove download markers after its one user approval
- removed acceptance dependence on hidden `.gitkeep` files
- made both PowerShell and Python layers create runtime directories explicitly
- added a regression contract requiring exactly one root PowerShell test launcher
- changed the cumulative result name to `MiniSQL_M2_M5R2_RESULTS_<timestamp>.zip`
- left all MiniLang engine code and persisted format versions unchanged

## 0.5.0-m5 packaging revision R1

- corrected `test-m2.ps1` through `test-m5.ps1` to use named hashtable splatting
- removed positional array forwarding that bound `-Python` to the `Through` parameter
- added a static regression contract that rejects the defective wrapper pattern
- gave generated acceptance archives an `R1` suffix
- documented that the original wrapper failure occurred before acceptance phase 1
- left all MiniLang engine code and persisted format versions unchanged

## 0.5.0-m5

- accepted M1R1 from the uploaded 12/12-phase Windows result archive
- implemented canonical U32/U64 LEB128 and ZigZag I32/I64 varints
- implemented CRC-32C and protected envelope v1
- implemented synchronous Win32 random-access files, explicit flush, truncate and locks
- implemented page format v1 with independent header and payload checksums
- implemented two-generation superblocks and fixed 8192-byte metadata region
- implemented paged-file append publication, tail cleanup and generation fallback
- implemented fixed-capacity CLOCK buffer pool with pinning and dirty flushing
- added M2, M3, M4 and M5 independent cumulative acceptance gates
- added cross-process durability and lock tests plus paged-file crash simulations
- added deterministic buffer-pool stress tests and an updated 71-module smoke gate

## 0.1.0-m1r1

- recorded the uploaded initial M1 acceptance result: phases 1-7 passed and the
  I64 golden-vector phase failed
- identified the root cause: native MiniLang immediate integers use a signed
  61-bit payload because three low bits are reserved for runtime tags
- replaced scalar full-domain I64 handling with `Int64Words(high, low)`
- retained `UInt64Words(high, low)` for the complete unsigned 64-bit domain
- made `readI64LE/BE` and `writeI64LE/BE` lossless for every signed 64-bit bit pattern
- added explicit scalar conversion helpers restricted to `-2^60..2^60-1`
- added explicit U64/I64 bit-cast helpers without truncation or reinterpretation ambiguity
- removed all out-of-range signed 64-bit MiniLang source literals
- added a dedicated tagged-integer/I64 representation regression program
- expanded golden, invalid-input, atomicity, full-domain and randomized round-trip tests
- upgraded the reference-vector envelope to document the scalar model
- added the M1R1 acceptance runner and machine-readable result archive

## 0.1.0-m1 (rejected candidate)

- accepted M0 from a complete Windows compile-and-run result archive
- implemented strict U8/I8, U16/I16, U32/I32 and initial U64/I64 codecs
- implemented little-endian and big-endian read/write operations
- defined `UInt64Words(high, low)` for the complete unsigned 64-bit domain
- attempted scalar signed-I64 conversion beyond the native MiniLang integer payload
- added golden vectors, invalid-input tests and deterministic round-trip tests
- retained all five M0 executable self-tests and the 71-module smoke test as regressions
- specified little-endian as the canonical on-disk byte order
- rejected after the Windows acceptance test exposed I64 boundary wrapping

## 0.0.0-m0

- established the complete MiniSQL repository layout
- added the normative DDL, DML, type, transaction, storage and protocol concepts
- separated mutable runtime configuration from immutable persisted format identity
- added MiniLang package stubs for all planned subsystems
- added server/client/tool entry points
- added a compile-and-run M0 acceptance suite
- added reserved unit, integration, recovery, fuzz, performance, fixture and reference test areas
- added package-creation validation documentation and stricter manifest/catalog checks

## 0.20.0-m20 — M16–M20 acceptance candidate

- Added multi-table joins, GROUP BY/HAVING, SQL aggregates and set operations.
- Added persisted table/column statistics, ANALYZE and EXPLAIN/EXPLAIN ANALYZE.
- Added protocol v1 with bounded CRC-protected frames and loopback TCP server/client.
- Added transaction savepoints and isolation-aware read leases.
- Added offline consistency checking, verified backup/restore and fail-closed migration planning.
- Added one cumulative 45-phase M0–M20 acceptance runner and one result archive.

## M32 – operational public client/server workflow

- Accepted M0–M31 from the 68/68 Windows R4 result.
- Added `minisqld --init` for safe database creation.
- Added no-echo `--set-admin-password` and `--set-user-password` bootstrap.
- Added persistent `--serve` and `--serve-authenticated` daemon modes.
- Defined request budget zero as unlimited and removed the global idle exit in
  that mode while retaining per-session timeouts.
- Added stateful `minisql --shell` and `--script` modes, plus authenticated and
  encrypted variants.
- Added bounded whole-file UTF-8 script input and byte-password catalog update.
- Added `build.ps1 -AppsOnly`.
- Added direct end-to-end tests of the actual public executables.

## 0.37.0-m37 — M33-M37R1 acceptance candidate

- recorded the uploaded first M33-M37 Windows run: 77/78 executed phases
  passed, M0-M36 were PASS and M37 stopped on one EXPLAIN assertion;
- confirmed that all RIGHT/FULL OUTER JOIN result-semantics checks passed;
- identified the failure as a test-harness issue: physical-plan child nodes are
  intentionally indented, while the assertion checked the raw line prefix;
- normalized EXPLAIN plan lines with `console.trimAscii(...)` before checking
  for `Full Outer Join`;
- added a static recurrence guard rejecting the obsolete untrimmed assertion;
- accepted M33-M36 from the cumulative Windows evidence;
- changed no engine behavior or persisted/wire format.

## 0.37.0-m37 — M33-M37 acceptance candidate

- accepted M32 from the uploaded 72/72-phase Windows result archive;
- replaced line-based client script framing with a quote/comment-aware SQL batch scanner;
- added multiline shell buffering, `\g`, `\reset`, `\source`, `\tables`, `\describe` and `\indexes`;
- added `SHOW TABLES`, `DESCRIBE`, and `SHOW INDEXES FROM/ON`;
- added searched/simple CASE, CAST, COALESCE and NULLIF with typed binding and aggregate-safe evaluation;
- added IN, NOT IN, BETWEEN, NOT BETWEEN, NOT LIKE and boolean truth tests;
- added SQL-standard OFFSET/FETCH row limiting;
- added RIGHT and FULL OUTER JOIN with correct NULL-extension and EXPLAIN operators;
- retained all persisted and wire format versions unchanged;
- added one cumulative 80-phase M0-M37 acceptance runner and one result archive.

## 0.42.0-m42 — M38-M42 acceptance candidate

- accepted M37 from `MiniSQL_M33_M37R1_RESULTS_20260728-140631.zip` with 80/80 phases passing;
- added INSERT/UPDATE/DELETE RETURNING with typed expressions, aliases and transaction-safe result rows;
- added INSERT INTO ... SELECT with complete pre-write materialization and self-insert safety;
- added ON CONFLICT DO NOTHING with exact persisted PK/UNIQUE targets and untargeted suppression;
- added ON CONFLICT DO UPDATE with an unambiguous synthetic `excluded` source, optional WHERE and final-row constraint validation;
- added transactional TRUNCATE TABLE with rollback, FK protection, affected-row reporting and identity restart;
- deliberately rejects CONTINUE IDENTITY until persistent sequences in M45;
- froze the MiniSQL 1.0 roadmap at M50: 13 milestones were open before this package and 8 remain after acceptance;
- retained all persisted and wire format versions unchanged;
- added one cumulative 87-phase M0-M42 acceptance runner and one result archive.
