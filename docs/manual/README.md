# MiniSQL User Manual

An English, implementation-based course and reference for MiniSQL, supplied as
editable LaTeX and a compiled PDF.

**[Read the PDF](minisql-user-manual.pdf)** ·
**[Main LaTeX source](minisql-user-manual.tex)** ·
**[Executable examples](examples/)**

## Implementation identity

This edition describes source revision
[`139eb3c096fe4db9640f730aa8722647485dac29`](https://github.com/MiniLangProject/MiniSQL/commit/139eb3c096fe4db9640f730aa8722647485dac29),
including the November 25 stored-procedure implementation. Source links in the
PDF resolve to this exact implementation commit.
The application banner is **1.1.1**, the current development **storage format
is 2**, and the **wire protocol remains 1**. Format-1 databases are rejected;
the page-size migration tool is not a format-1 converter.

The book distinguishes supported syntax, executable behavior, deliberate
restrictions, and observed defects. It does not present the older release
acceptance results as a new certification of the development tree.

## Contents

| Part | Chapters |
|---|---|
| Learn MiniSQL | Relational foundations; installation and database creation; a complete guided shop tutorial |
| The SQL language | Tokens, expressions, NULL and predicates; schemas, types and constraints; DML and conflicts; joins, grouping, subqueries and CTEs; scalar/aggregate/window functions, views, prepared statements, sequences, triggers and procedures |
| Operate and protect | Transactions and isolation; users, roles, grants, authentication, TLS and TDE; complete configuration and administration; backup, restore, PITR, migration, standby and failover |
| Build and diagnose | Native console, Windows Workbench, Python DB-API, JDBC and MiniLang integration; performance and indexes; physical storage and byte layouts; practice workshops and solutions; troubleshooting, error codes, capability matrix and glossary |
| Appendix and navigation | Validation scope, reproducible checks, source map, contents, figures, tables and a subject index |

Ten editable vector illustrations explain the architecture, teaching schema,
query reasoning, savepoints, database lifecycle, recovery chain, Workbench
navigation, index access, concurrency and slotted pages. The Workbench drawing
is explicitly a conceptual navigation map, not a live Windows screenshot.

## Build the PDF

Install Python 3 and a normal **TeX Live or MiKTeX** installation with
pdfLaTeX and MakeIndex. Required packages are listed in `preamble.tex` and in
the validation appendix; TeX Live's recommended/extra LaTeX packages, fonts
and pictures collections cover them.

From the repository root:

```sh
python3 docs/manual/tools/build_manual.py
```

On Windows use `python` instead of `python3` if appropriate. The final PDF is
`docs/manual/minisql-user-manual.pdf`; temporary TeX files stay under the ignored
`build/manual/` directory. No shell escape or network download is used by
the build script. An optional `--output PATH` selects another final location.

## Run and verify the examples

Build matching native MiniSQL executables first. The validation runners create
fresh temporary databases, start their own server on a free loopback port,
perform the checks, shut down, and remove the temporary databases. They never
open an existing application database.

```sh
python3 docs/manual/tools/validate_examples.py \
  --bin-dir build/bin-linux \
  --output build/manual-validation.json

python3 docs/manual/tools/validate_recovery.py \
  --bin-dir build/bin-linux \
  --output build/manual-recovery-validation.json
```

Use `--bin-dir build/bin` for Windows. The example runner requires `minisqld`
and `minisql`; the recovery runner also requires `minisql-check` and
`minisql-backup`. The in-repository Python connector is loaded automatically.

The original tutorial/recovery verification used source baseline `9bedab0`
and MiniLangCompilerPy 1.3.10 at commit
`8e64c9cfda92199b68ac5d3974fea445f12f6c39`. Its **four SQL scripts and 53 focused
checks**, plus the separate backup/restore/check/reopen recipe, passed. Those
historical records remain in [`validation.json`](validation.json) and
[`recovery-validation.json`](recovery-validation.json).

The procedure updates have separate [verification evidence](../acceptance/STORED_PROCEDURES_2026-11-25.md):
the initial language expansion remains recorded at `139eb3c`, followed by a
five-package parity expansion with 12 native Linux cases, six Windows
cross-compilation cases, targeted follow-up regressions, Python/JDBC unit
checks and a rebuilt-server connector fixture. The older tutorial and initial
procedure records have not been relabeled as new executions against the
current implementation. Windows compilation does not establish Windows
runtime acceptance.

Some checks intentionally confirm a documented limitation. A passing test of
incorrect DECIMAL arithmetic or a rejected query means the book describes the
observed behavior accurately; it does not endorse that behavior as correct SQL.
Windows Workbench, full TLS matrices, long-running soak and all replication
failure paths were reviewed from source rather than executed for this edition.

## Maintain the book

- `edition.tex` pins the implementation identity.
- `chapters/` contains the teaching and reference text.
- `figures/` contains the editable TikZ drawings.
- `examples/` contains runnable SQL and its usage notes.
- `source-map.json` maps chapters to verified repository source references.
- `tools/audit_manual.py` verifies structural links and regenerates the source map.
- `tools/build_manual.py` builds the PDF and index.
- The two validation runners preserve machine-readable evidence.

After an implementation change, inspect the affected chapters, rerun the
relevant examples and probes, review changed limits, update the source identity,
and rebuild and visually review the PDF. Do not change the source SHA alone and
assume the content has been revalidated.

The manual and its original diagrams use the repository's Apache-2.0 license.
