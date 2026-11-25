# Stored-procedure development verification — 2026-11-25

This report preserves the original language-expansion evidence below.
The subsequent five-package parity expansion is recorded separately in the
`parityExpansion` object of the accompanying JSON; historical test counts,
source hashes and manual results are not relabeled as new executions.

## Five-package parity expansion

The follow-up implements the five previously identified packages across the
SQL engine, persistent routine catalog, native protocol, Python connector and
JDBC driver. It starts from `ec87e27ca0c923d5f10ffa1e2bc08592070dd8fc`.
The machine-readable `parityExpansion` record keeps its own source hashes,
run paths, platform scope and final publication/manual identity.

| Package | Delivered behavior |
|---|---|
| 1. Authorization and diagnostics | Separate metadata/source visibility; SHOW_ROUTINE, SET_ANY_DEFINER and database SELECT; mandatory CREATE ROUTINE and definer EXECUTE; configurable session-local automatic grants; retained warning/error lists and totals; SQLSTATE and warning chains in negotiated connector responses. |
| 2. Metadata and binding | Complete ROUTINES/PARAMETERS and SHOW layouts; captured execution context and timestamps; JDBC procedure discovery, callable parameter metadata, named/positional binding, typed outputs, retained results and IN-only batches. |
| 3. Trigger calls | Compound trigger programs and CALL use the invoking transaction; restrictions propagate through callees; OLD/NEW remain qualified and read-only; local trigger savepoint names cannot access the caller's level. |
| 4. Behavior details | Final-statement CALL counts; failed-statement rollback in an explicit CALL transaction; permission preflight before routine-DDL implicit commit; no automatic replay after CALL starts; omitted parentheses for zero-argument CALL; captured strictness and Unicode/binary assignment rules. |
| 5. Execution resources | Bounded simple-query streaming and explicit result boundaries; connector result spools; a 64-entry parsed-definition cache invalidated by identity/source/context changes; concurrent CALL admission only after a conservative proof of the reachable program. |

### Verification of the expansion

| Gate | Observed result |
|---|---|
| Full focused Linux x64 gate | **12/12 cases pass**, including the existing SQL regressions. |
| Final assertion suites | **127 runtime**, **21 edge**, **154 security/metadata**, and **105 parity** assertions pass. |
| Native wire regressions | M18 protocol and M21 authenticated-protocol cases pass. |
| Windows routine cross-compilation | **6/6 cases pass** PE32+ AMD64 validation; the final 105-assertion parity source is recompiled separately. No Windows image is executed. |
| Windows application cross-compilation | **3/3 pass**: server, command-line client and Workbench. PE32+ AMD64 images are validated; GUI/runtime behavior is not exercised. |
| Python connector | **18 unit tests pass**. |
| JDBC | **16 general checks and 77 procedure checks pass** on Java 21, compiled with source/target 11. This is not Java 11 runtime acceptance. |
| Rebuilt native server with connectors | **33 top-level checks pass**, including one aggregate JDBC check whose own live suite passes **25 checks**. Those counts are not additive. |
| Static acceptance | **4/4 phases pass**, including the repository manifest, single-launcher contract, 88-module catalog, source contracts and deterministic reference vectors. |

The full Linux gate is
`build/routines/gates/20261125T071351Z-bug7i3td/results.json`.
It passed the 100-assertion parity suite. Review then corrected SQLSTATE for
unsupported character set/collation errors and added five regressions; the
final 105-assertion run is
`build/routines/gates/20261125T071930Z-0z09bmru/results.json`.
That final run supersedes only the parity case. The Windows equivalent is
`build/routines/gates/20261125T072032Z-pxfobd5l/results.json`, supplementing the
six-case gate at `build/routines/gates/20261125T071456Z-g2fb1dvg/results.json`.
The three application builds pass at
`build/routines-v2/windows-apps/appresults.json`, with compile commands,
entry-point hashes, timings and image-validation results recorded separately.

The security suite additionally verifies malformed persisted creation context
cannot leak a definer identity, and that binary character declarations expose
their effective BINARY/VARBINARY/BLOB metadata. The parity suite exercises real
concurrent native reader calls, cleanup after a failing streaming sink,
cache invalidation, isolated trigger savepoints, rollback boundaries, Unicode
character lengths, byte truncation/padding and hidden sequence/subquery effects.

Wire regression evidence is
`build/routines-v2/native-wire-regressions/results.json`. Its first M18
invocation omitted a required loopback-port argument. The same compiled binary
then passed with an allocated port; the record retains the invocation mistake
and rerun rather than concealing it as a source fix.

Connector evidence is in `build/routines-v2/python-unit.log`,
`jdbc-driver.log`, `jdbc-routine.log` and `live.log`. The native server was
rebuilt after the final engine changes. Live coverage includes 600 rows,
equal-schema and empty result boundaries, typed decimal and binary outputs,
exact SQL NULL, preserved warning diagnostics, prepared-CALL reuse, sequence
probe evaluation exactly once, deferred errors and connection reuse. It also
checks that application error numbers resembling lock/deadlock codes do not
cause CALL replay or unrelated transaction rollback.

### Compatibility and acceptance boundaries

Updated peers negotiate `results-v2` while retaining MiniSQL wire protocol 1.
Legacy peers receive the original payload layout. Routine metadata extends the
existing schema-history representation without changing its historical prefix;
missing legacy creation attributes remain unknown rather than invented.
The SQL reference, security guide, format specifications, client references and
manual sources describe the new contract and migration implications.

Strict/non-strict mode support applies to routine character assignment, and
the supported character sets/collations are deliberately limited. General SQL
arithmetic, table coercion, trigger timing and the wider type system retain
their documented MiniSQL behavior. Blocking query operators can still
materialize; unknown call dependencies use exclusive execution. The change
does not claim complete MySQL server or wire compatibility.

The complete **106-phase Windows release matrix was not run**. These focused
results do not establish Windows GUI, all TLS configurations, crash, replication
or soak acceptance. Historical tutorial, storage and initial procedure evidence
below remains separate from this expansion.

## Initial procedure-language expansion

The focused **Linux x64 native gate passed all 11 registered cases** with
MiniLangCompilerPy 1.3.10, compiler commit
`8e64c9cfda92199b68ac5d3974fea445f12f6c39`. This verifies the expanded procedure
language and the affected SQL, persistence, authorization, and client framing
paths. Machine-readable results and the exact incremental provenance are in
[stored-procedures-2026-11-25.json](stored-procedures-2026-11-25.json).
The implementation is committed as
[`139eb3c096fe4db9640f730aa8722647485dac29`](https://github.com/MiniLangProject/MiniSQL/commit/139eb3c096fe4db9640f730aa8722647485dac29).
That manual edition's immutable source links were pinned to that code revision.

### Native coverage

| Test | Main contract exercised |
|---|---|
| `stored_procedure_parser` | Compound grammar, parameters, labels, declaration rules, characteristics, invalid syntax, and canonical format/reparse. |
| `stored_procedure_runtime` | 127 assertions covering parameter copyback, lexical scopes, control flow, cursors, handlers, diagnostics, dynamic SQL, recursion, transactions, result sets, metadata, definer/invoker authorization, and reopen. |
| `stored_procedure_edges` | 21 assertions across seven groups: REPEAT/ITERATE, declaration-time cursor scope, prepared schema capture, chained CTE scope, handler/RESIGNAL diagnostics, and handled SELECT failure inside an explicit transaction. |
| `routines_client` | Custom DELIMITER handling, separate equal-schema/empty results, bounded row framing, result boundaries, and request alignment. |
| `routine_security` | Routine privilege codec, database/object scopes, inherited roles and grant options, durable identity high-water mark, drop/recreate isolation, cleanup, and reopen. |
| `m12_sql_frontend` | Existing lexer/parser/AST contract, including trigger identifier formatting. |
| `m15_sql_engine` | Existing core engine and SQL execution behavior. |
| `m22_prepared_statements` | Existing prepare/bind/execute behavior after session-variable and schema-context changes. |
| `m33_sql_batch` | Existing quote/comment-aware SQL client statement splitting. |
| `m37_outer_joins` | Existing join projection and row behavior after routine expression rewriting. |
| `m45_sequences_generated_triggers` | Existing schema extensions, legacy typed AS procedures, RETURNING rows/counts and per-statement diagnostics, SELECT-only zero mutation counts, and persistence across reopen. |

Every native case compiles into an isolated build directory, verifies ELF
format, executes against a fresh data directory when required, and must both
exit successfully and print its exact success marker. The M45 RETURNING check
verifies the projected identifier and inserted row before and after database
reopen; the former rejection assertion was replaced with successful-behavior
coverage.

Verification was incremental. The first run exposed a branch-local variable
used outside its compiler scope in diagnostics and an incorrect INTEGER test
unwrapping helper. Both were corrected. Successful independent cases were
retained; the affected cases and updated parser assertions were recompiled and
executed successfully. The evidence file records which run supplies each
passing case, rather than relabeling the original failed run.
The edge suite was expanded during review and its final 21-assertion version
was compiled and executed separately; that successful final run supersedes
the focused runner's earlier 17-assertion result for this case.
A final targeted M45 run passes after correcting RETURNING mutation accounting;
it checks CALL totals and final status before/after reopen, diagnostics row
count, and the exclusion of SELECT result rows from mutation counts.

### Windows compilation

All five new routine suites also pass Windows x64 cross-compilation and PE32+
AMD64 image validation. The final 21-assertion edge suite was rebuilt against
the frozen executor/routine-state source hashes. The command-line client and
Workbench entry points also cross-compile successfully with valid PE images.
The GUI-specific modules stayed unchanged during those builds; shared client
error-flow code changed during the application builds and is verified
separately through native/client integration checks. The evidence preserves
that source-timing distinction. **No Windows executable was run.**

### Connector and live-server checks

The final Python connector suite passes **14 unit tests**. Java passes the
existing **16 JDBC checks** and **25 routine-specific checks**. A rebuilt native
Linux server passes **17 end-to-end checks**, including a JDBC live suite of
**14 checks**. The machine-readable evidence identifies each log and the exact
server rebuild used for this final live run.

The live fixture verifies 600 rows across continuation frames, successive
SELECTs with identical schemas, empty results, output parameter copyback,
Python `callproc`, JDBC `CallableStatement`, and connection reuse after errors.
It also verifies a completed SELECT remains readable before a later SIGNAL,
with the error raised by `nextset`/`getMoreResults` at the correct boundary.
Application error numbers 9007 and 9031 are checked explicitly: they must not
trigger native lock retry or an unrelated server transaction rollback.

### Reproduce and maintain the gate

The repository retains its single public launcher:

```powershell
.\test.ps1 -Compiler C:\path\to\MiniLangCompilerPy\mlc_win64.py -Routines -Target windows-x64
.\test.ps1 -Compiler /path/to/MiniLangCompilerPy/mlc_win64.py -Routines -Target linux-x64
```

Use the target matching the host. `-CompileOnly` checks a cross-target build
without claiming that the produced image was executed. The internal CI runner
can be invoked directly on a Linux host without PowerShell:

```sh
python -B tests/run_routines.py \
  --compiler /path/to/MiniLangCompilerPy/mlc_win64.py \
  --target linux-x64 --jobs 2
```

It accepts repeated `--case` selections and writes compiler logs, native logs,
and `results.json` below `build/routines/gates/`. The cumulative M45 phase runs
the five new routine suites and the existing M45 test; the other SQL regressions
retain their existing cumulative phases. The portable WSL acceptance runner
also includes the routine suites. No additional root test launcher was added.

### Static and documentation checks

All four static acceptance phases pass. The exact repository manifest now
includes the existing user manual and the new procedure sources/tests. The
module catalog contains 88 engine modules. Existing source-header,
documentation, generated-API inventory/quality, reference-vector, and
one-launcher checks remain enforced.

The SQL reference, security and durable-format documentation, client reference,
and manual describe the expanded behavior. The manual source audit passes for
32 TeX files, 115 cited source files, and 50 labels. The complete **192-page PDF**
was rebuilt with zero overfull boxes and no unresolved references. Its cover,
procedure syntax/example and diagnostics pages, Python callproc page, JDBC
callable example page, and evidence appendix were rendered and visually inspected.
All 254 embedded repository source links use the exact implementation revision;
the 115 cited source paths are present in that commit.

### Scope of the result

The complete 106-phase Windows release matrix was not executed for this change.
Focused native results do not establish new Windows GUI, full TLS, crash,
replication, or soak acceptance. Historical release evidence remains separate.

The procedure language targets MySQL semantics within MiniSQL's underlying SQL,
data types, namespace, and transaction model. This change does not claim MySQL
server, wire-protocol, collation, replication, or `sql_mode` equivalence. The
[procedure reference](../sql/stored-procedures.md) records the supported forms
and compatibility boundaries.
