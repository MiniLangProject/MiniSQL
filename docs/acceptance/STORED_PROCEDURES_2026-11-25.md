# Stored-procedure development verification — 2026-11-25

The focused **Linux x64 native gate passed all 11 registered cases** with
MiniLangCompilerPy 1.3.10, compiler commit
`8e64c9cfda92199b68ac5d3974fea445f12f6c39`. This verifies the expanded procedure
language and the affected SQL, persistence, authorization, and client framing
paths. Machine-readable results and the exact incremental provenance are in
[stored-procedures-2026-11-25.json](stored-procedures-2026-11-25.json).

## Native coverage

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

## Windows compilation

All five new routine suites also pass Windows x64 cross-compilation and PE32+
AMD64 image validation. The final 21-assertion edge suite was rebuilt against
the frozen executor/routine-state source hashes. The command-line client and
Workbench entry points also cross-compile successfully with valid PE images.
The GUI-specific modules stayed unchanged during those builds; shared client
error-flow code changed during the application builds and is verified
separately through native/client integration checks. The evidence preserves
that source-timing distinction. **No Windows executable was run.**

## Connector and live-server checks

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

## Reproduce and maintain the gate

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

## Static and documentation checks

All four static acceptance phases pass. The exact repository manifest now
includes the existing user manual and the new procedure sources/tests. The
module catalog contains 88 engine modules. Existing source-header,
documentation, generated-API inventory/quality, reference-vector, and
one-launcher checks remain enforced.

The SQL reference, security and durable-format documentation, client reference,
and manual describe the expanded behavior. The manual source audit passes for
32 TeX files, 115 cited source files, and 50 labels. The complete **193-page PDF**
was rebuilt with zero overfull boxes and no unresolved references. Its cover,
procedure syntax/example page, Python callproc page, and JDBC callable example
page were rendered and visually inspected.

## Scope of the result

The complete 106-phase Windows release matrix was not executed for this change.
Focused native results do not establish new Windows GUI, full TLS, crash,
replication, or soak acceptance. Historical release evidence remains separate.

The procedure language targets MySQL semantics within MiniSQL's underlying SQL,
data types, namespace, and transaction model. This change does not claim MySQL
server, wire-protocol, collation, replication, or `sql_mode` equivalence. The
[procedure reference](../sql/stored-procedures.md) records the supported forms
and compatibility boundaries.
