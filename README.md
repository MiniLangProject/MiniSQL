# MiniSQL 1.0.0

MiniSQL is a transactional relational database management system written in
[MiniLang](https://github.com/MiniLangProject/MiniLangCompilerPy) and compiled
to native Windows x64 applications.

The frozen M0-M50 plan is complete. The final Windows run passed all
**106/106 cumulative phases**, including crash recovery, concurrent clients,
TLS integration, replication, fuzzing, soak tests, and deterministic release
packaging. The accepted source revision is `M48-M50R3`.

> MiniSQL is an independently developed database engine. Version 1.0 has a
> substantial project-specific test suite, but it has not received an
> independent security or production audit. Validate it against your own
> availability, durability, and security requirements before using it for
> irreplaceable data.

## Highlights

- durable paged storage, CRC-32C checksums, redundant metadata, WAL, checkpoints,
  crash recovery, transactions, savepoints, and isolation-aware locking;
- heap files, overflow values, B+ tree indexes, buffer pool, VACUUM, REINDEX,
  backup/restore, PITR, consistency checking, and offline page-size migration;
- DDL, DML, and DCL with constraints, roles, grants, prepared statements, views,
  CTEs, subqueries, window functions, triggers, sequences, and generated columns;
- joins, aggregates, set operations, optimizer statistics, hash operators, and
  external merge-sort runs;
- `AUTO_INCREMENT` / `AUTOINCREMENT`, exact `DECIMAL(p,s)` input, and floating
  literals such as `3.3`, `-4.75`, and `1.25e2`;
- persistent server, stateful shell, script client, authenticated transport,
  TLS 1.3/X.509 sidecar, audit chain, WAL shipping, and read-only hot standby;
- deterministic 106-phase cumulative test suite and reproducible Windows-x64
  release packaging.

## Requirements

- Windows x64
- Python 3.11 or newer
- `mlc_win64.py` from MiniLangCompilerPy

The Python TLS and replication sidecars use only the Python standard library.

## Build

```powershell
$compiler = "C:\path\to\MiniLangCompilerPy\mlc_win64.py"
.\build.ps1 -Compiler $compiler -AppsOnly
```

Applications are written to `build\bin`:

```text
minisqld.exe
minisql.exe
minisql-check.exe
minisql-backup.exe
minisql-migrate.exe
```

## Quick start

Create a database:

```powershell
.\build\bin\minisqld.exe --init .\data demo 4096
```

Use the reported `db_<uuid>` directory to start a local server:

```powershell
.\build\bin\minisqld.exe --serve .\data\db_<uuid> 7432 32
```

Open a stateful client in another terminal:

```powershell
.\build\bin\minisql.exe --shell 7432
```

Example SQL:

```sql
CREATE TABLE reading (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    approximate_value DOUBLE PRECISION,
    exact_value DECIMAL(10,2)
);

INSERT INTO reading(approximate_value, exact_value)
VALUES (3.3, 4.75)
RETURNING id, approximate_value, exact_value;
```

SQL decimal literals use a dot. A comma separates values.

See [`docs/quickstart-client-server.md`](docs/quickstart-client-server.md) for
server modes, authenticated sessions, scripts, and operational examples.

## Test

There is one user-facing test entry point:

```powershell
.\test.ps1 -Compiler $compiler
```

It runs the complete M0-M50 suite and creates one archive under `build/`. A
successful run ends with:

```text
MiniSQL 1.0.0 test suite: SUCCESS
```

A source-only static validation is available with:

```powershell
.\test.ps1 -StaticOnly
```

## Build the binary distribution

```powershell
.\release.ps1 -Compiler $compiler
```

Output:

```text
build\release\MiniSQL-1.0.0-windows-x64.zip
build\release\MiniSQL-1.0.0-windows-x64.zip.sha256
```

## Repository layout

```text
src/apps/              executable entry points
src/minisql/           71 database-engine modules
src/tests/             native MiniLang tests
config/                example configuration and JSON schema
docs/spec/             behavioral specifications
docs/formats/          persistent and wire-format specifications
docs/adr/              architecture decision records
docs/release/          operator and SQL documentation
tests/                 cumulative runner, fixtures, corpora, and references
tools/                 TLS, replication, quality, and release sidecars
```

A generated overview is available in
[`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md).

## Compatibility and limitations

Global settings such as page size are defaults for **new databases only**. An
existing database reads its actual page size, format version, checksums, and
object identity from durable metadata and self-describing file headers.

The frozen compatibility contract and known limitations are documented in:

- [`docs/formats/FORMAT_COMPATIBILITY.md`](docs/formats/FORMAT_COMPATIBILITY.md)
- [`docs/release/UPGRADE.md`](docs/release/UPGRADE.md)
- [`docs/release/LIMITATIONS.md`](docs/release/LIMITATIONS.md)
- [`docs/release/feature-matrix.json`](docs/release/feature-matrix.json)
- [`docs/release/upgrade-matrix.json`](docs/release/upgrade-matrix.json)

## Security

Read [`SECURITY.md`](SECURITY.md) and
[`docs/release/SECURITY_GUIDE.md`](docs/release/SECURITY_GUIDE.md) before
exposing a server outside a trusted local environment. Test certificates and
the private test key under `tests/fixtures/tls/` are public fixtures and must
never be used in production.

## License

This repository snapshot intentionally does not select an open-source license.
Add the license you want before publishing the project for third-party reuse.
Without a license, normal copyright rules apply.
