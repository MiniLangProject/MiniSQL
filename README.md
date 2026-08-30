# MiniSQL 1.0.0

MiniSQL is a transactional relational database management system written in
[MiniLang](https://github.com/MiniLangProject/MiniLangCompilerPy) and compiled
to native Windows x64 PE or Linux x64 ELF applications.

The frozen M0-M50 plan is complete. The accepted 1.0 source revision is
`M48-M50R3`. The current tree was revalidated on 2026-08-26: Windows passed all
**106/106 cumulative phases**, including crash recovery, genuinely parallel
same-database reads, concurrent clients, TLS integration, replication, fuzzing,
soak tests, and deterministic release packaging; the focused Linux gate passed
all storage, client/server, concurrent scheduling, authentication, and native
TLS checks under WSL2.

> MiniSQL is an independently developed database engine. Version 1.0 has a
> substantial project-specific test suite, but it has not received an
> independent security or production audit. Validate it against your own
> availability, durability, and security requirements before using it for
> irreplaceable data.

## Platform status

| Target | Build and validated use | Current restriction |
| --- | --- | --- |
| Windows x64 | Complete 106-phase release gate, all six applications, concurrent server, native TLS | The Workbench and deterministic release archive are Windows-specific. |
| Linux x64 | Five command-line applications, offline storage tools, concurrent server/client operation, native TLS | The focused gate is validated under WSL2; the Win32 Workbench, Windows crash injection, packaging, and full 106-phase release matrix remain Windows-specific. |

The original Linux multi-client failure and its verified pthread-runtime fix are
tracked in the [Windows/Linux performance report](tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md).
Persisted database and wire formats remain shared across both targets.

## Highlights

- durable paged storage, CRC-32C checksums, redundant metadata, WAL, checkpoints,
  crash recovery, transactions, savepoints, and isolation-aware locking;
- heap files with persistent physical heap-page directories, overflow values,
  B+ tree indexes, buffer pool, VACUUM, REINDEX, backup/restore, PITR,
  consistency checking, and offline page-size migration;
- DDL, DML, and DCL with schemas, `INFORMATION_SCHEMA`, constraints, roles,
  grants, prepared statements, views, recursive CTEs, correlated subqueries,
  window functions, `MERGE`, triggers, typed single-statement procedures,
  sequences, and generated columns;
- joins (including aliased comma-separated `FROM` lists), aggregates, set operations,
  sampled optimizer statistics, transitive constant propagation, predicate
  pushdown, constant folding, projection pruning, costed index/sequential scans,
  index intersection/union,
  inner-equijoin reordering, hash/index/nested-loop joins, streaming scalar
  aggregates, spillable and parallel hash operators, Top-N, external merge-sort
  runs, and a generation-safe plan cache;
- `AUTO_INCREMENT` / `AUTOINCREMENT`, exact `DECIMAL(p,s)` input, and floating
  literals such as `3.3`, `-4.75`, and `1.25e2`;
- persistent server, stateful shell, script client, authenticated transport,
  native TLS 1.3/X.509 transport, audit chain, WAL shipping, and read-only hot standby;
- a dependency-free Java 11+ JDBC 4.3 driver with trusted/password sessions,
  TLS and certificate pinning, prepared statements, transactions, streaming
  results, batches, and live catalog metadata;
- a Python 3.10+ DB-API 2.0 connector with trusted/password sessions, TLS and
  certificate pinning, lazy transactions, prepared-plan caching, streaming
  cursors, and bounded `executemany()` inserts;
- scalable multi-page catalog and security metadata, a thread-safe singleton
  logger with stdout plus time-rolled files, and an optional complete SQL binlog;
- native per-connection concurrency through a bounded MiniLang thread pool, with
  bounded multi-frame result delivery, parallel network/framing work, parallel
  read-only query plans on one database, intra-query hash-partition workers, and
  exclusive, writer-prioritized mutation execution;
- a native Windows MiniSQL Workbench with saved aliases, TLS/pinning, object
  browsing, multiple syntax-colored SQL worksheets, current/selection and
  whole-script execution, searchable history, CSV export, native metadata/data
  grids, paged filtering and sorting, staged bulk row changes, and a guarded
  schema designer with exact DDL previews;
- deterministic 106-phase cumulative Windows test suite, a portable Linux
  acceptance suite, and reproducible Windows-x64 release packaging.

## Concurrency model

`minisqld` accepts connections on one dedicated acceptor and dispatches each
connection to a bounded native MiniLang thread pool. A worker owns its socket,
framing buffers and SQL session for the connection lifetime, so a slow client
does not block unrelated clients.

Each open database owns a writer-prioritized readers/writer execution gate.
Read-only `SELECT`, `EXPLAIN` and metadata operations may execute concurrently
on independent shared-locked file handles. DML, DDL, DCL, maintenance,
sequence-consuming queries and session mutations execute exclusively. Waiting
writers close the reader turnstile to prevent writer starvation. The logical
lock graph has a separate mutex and retains its transaction timeout and
deadlock-detection semantics.

This is real parallel query execution for independent reads, not only parallel
socket handling. The M27 acceptance scenario starts two connections, executes
100 indexed queries per connection and requires a measured overlap greater than
one. This behavior is fully validated on Windows. The Linux gate additionally
runs two consecutive waves of four simultaneous native clients, proving both
parallel execution and completed-connection job reaping. The design
intentionally retains a single physical writer per database.

## Query optimizer

Every bound `SELECT` is lowered to a typed executable plan; `EXPLAIN` renders
that same plan, so execution does not independently guess a different operator.
The cost model uses persisted `ANALYZE` row/page counts, per-column null,
distinct-value and width estimates, equi-depth numeric/date histograms, integral
and hashed text most-common values, plus joint distinct counts and tuple MCVs
for composite index keys to choose sequential or B+ tree access,
nested-loop, index nested-loop or hash joins, hash aggregation, Top-N,
in-memory sort or external merge sort. Connected inner-equijoin graphs of up to
eight sources use a bounded Selinger-style subset search; larger graphs use the
deterministic connected greedy fallback while outer joins retain SQL order.

Deterministic predicates are folded and pushed to their single source;
unreferenced external `TEXT`/`BLOB` columns are not materialized. A B+ tree key
plus optional `CREATE INDEX ... INCLUDE (...)` leaf payloads that contain every
referenced column execute as an index-only scan without opening heap or overflow
pages. Included values use a versioned, backwards-compatible leaf format and
are maintained through insert, update, recovery, `REINDEX`, and `VACUUM`. Simple
`CREATE INDEX ... WHERE predicate` definitions physically retain only rows for
which the immutable row-local predicate is `TRUE`. The optimizer admits a
partial index only for a single-table plan whose query predicate proves every
typed index-predicate conjunct. Proofs cover identical conjuncts and stronger
single-column literal bounds, preventing rows outside the index from being
silently omitted. Partial predicates and INCLUDE payloads may be combined.
Deterministic functional keys such as `CREATE INDEX ... ON customer
(LOWER(email))` are evaluated from complete typed rows during every maintenance
path and selected only for an exact typed expression/literal comparison.
Functional keys may be combined with `INCLUDE`, `WHERE`, and `UNIQUE`; the
current implementation supports one expression key and a heap-backed scan.
Simple single-table queries flow through bounded 128-row scan batches. `COUNT(*)`
reads verified live-slot metadata and scalar `COUNT`/`SUM`/`AVG`/`MIN`/`MAX`/
`BOOL_AND`/`BOOL_OR` use fixed-size streaming accumulators, including eligible
filtered index/scan inputs. Small ordered limits fuse scan, projection, and
Top-N retention; reordered inner-equijoin `COUNT(*)` plans count final matches
without retaining the final joined rowset. A per-session 64-entry plan cache
uses exact top-level SQL keys and canonical nested-AST keys and is invalidated across all
attached sessions by DDL, `ANALYZE`, `VACUUM`, or `REINDEX`.

Independent indexed conjunctions and fully indexable disjunctions may use row-reference
intersection or deduplicating union before one shared heap read. Inner equality
graphs propagate typed non-NULL constants to peer sources without changing the
residual correctness predicate. Large grouped aggregates and eligible hash joins
are partitioned into validated spill runs and processed on up to four native
workers. Result rows travel as bounded continuation frames; clients reassemble
them transparently while each wire payload remains below the protocol limit.

`ANALYZE` counts the exact live population but samples at most 8,192 uniformly
spaced rows for column distributions. `EXPLAIN ANALYZE` adds actual row count,
elapsed milliseconds and buffer-cache hit/read deltas. Statistics remain
advisory and CRC-32C protected; the version-5 reader accepts versions 1–4.

## Requirements

- MiniLangCompilerPy or MiniLangCompilerML 1.1.0 or newer;
- Windows x64 with Schannel TLS 1.3 support, or Linux x64 with glibc and
  OpenSSL 3 (`libssl.so.3`, `libcrypto.so.3`);
- Python 3.11 or newer when using the Python compiler, cumulative Windows test
  tooling, release tooling, or the optional hot-replication controller;
- WSL when cross-compiling and running Linux acceptance from Windows.

TLS always runs in-process. Windows builds use Schannel and CryptoAPI; Linux
builds use the OpenSSL 3 system libraries through MiniLang's native `std.tls`,
`std.crypto`, and `std.uuid` interfaces. Python is not in the TLS data path.

## Build

```powershell
$compiler = "C:\path\to\MiniLangCompilerPy\mlc_win64.py"
.\build.ps1 -Compiler $compiler -Target windows-x64 -AppsOnly
.\build.ps1 -Compiler $compiler -Target linux-x64 -AppsOnly
```

`-Compiler` also accepts the native
`MiniLangCompilerML\build\mlc_win64.exe`. The build and acceptance launchers
discover its repository-level `std/` automatically and select the canonical
object pipeline for large self-hosted builds, bounding the live code-generation
graph without changing target bytes.

Windows applications are written to `build\bin`:

```text
minisqld.exe
minisql.exe
minisql-check.exe
minisql-backup.exe
minisql-migrate.exe
minisql-admin.exe
```

Linux applications are written to `build\bin-linux` without an `.exe`
suffix. `minisql-admin` is omitted because the native Workbench is Win32-only;
the server, console client, checker, backup tool, and migration tool are
available on both platforms.

## Quick start

Create a database:

```powershell
.\build\bin\minisqld.exe --init .\data demo 4096
```

Use the reported `db_<uuid>` directory to start a local server:

```powershell
.\build\bin\minisqld.exe --serve .\data\db_<uuid> 7432 32
```

To use the logger and SQL-binlog settings from the supplied JSON configuration:

```powershell
.\build\bin\minisqld.exe --serve-config .\data\db_<uuid> .\config\minisql.example.json
```

The default configuration writes INFO-and-higher records both to stdout and to
`logs/minisql.log`, rolling the file every 24 hours. Set `runtime.logLevel` to
`debug`, `info`, `warning`, or `error`; enable `binlog.enabled` to durably record
every received SQL statement in the independent binlog.

On Windows the daemon disables console QuickEdit at process start. Accidental
mouse selection can therefore no longer suspend stdout logging and freeze new
connection handshakes. Clients also abandon an unanswered initial handshake
after five seconds instead of waiting indefinitely.

Open a stateful client in another terminal:

```powershell
.\build\bin\minisql.exe --shell 7432
```

Or open the graphical MiniSQL Workbench:

```powershell
.\build\bin\minisql-admin.exe
```

See [`docs/release/WORKBENCH.md`](docs/release/WORKBENCH.md) for its
SQuirreL-style MiniSQL workflow, data and schema editors, aliases, native TLS,
and certificate pinning.

Java applications can build and use the JDBC driver as follows:

```powershell
.\clients\jdbc\build.ps1
```

```java
try (Connection connection = DriverManager.getConnection(
        "jdbc:minisql://127.0.0.1:7432/main")) {
    try (ResultSet rows = connection.createStatement().executeQuery("SHOW TABLES")) {
        while (rows.next()) System.out.println(rows.getString("table_name"));
    }
}
```

The JAR is written to `build/jdbc/minisql-jdbc-1.0.0.jar`. See the
[`JDBC driver guide`](docs/release/JDBC.md) for authenticated/TLS URLs,
certificate pinning, supported interfaces, and protocol-v1 limitations.

Python applications can install and use the DB-API 2.0 connector directly from
the checkout:

```powershell
python -m pip install .\clients\python
```

```python
import minisql

with minisql.connect("minisql://127.0.0.1:7432/main") as connection:
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, name FROM customer WHERE id >= ?", (100,))
        for row in cursor:
            print(row)
```

See the [`Python connector guide`](docs/release/PYTHON.md) for password/TLS
configuration, self-signed certificate pinning, transaction boundaries,
batches, and protocol-v1 limitations.

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

On Linux, use the equivalent ELF paths, for example:

```bash
./build/bin-linux/minisqld --init ./data demo 4096
./build/bin-linux/minisqld --serve ./data/db_<uuid> 7432 32
./build/bin-linux/minisql --shell 7432
```

## Test

There is one user-facing test entry point:

```powershell
.\test.ps1 -Compiler $compiler -Target windows-x64
.\test.ps1 -Compiler $compiler -Target linux-x64
```

The Windows target runs the complete M0-M50 suite and creates one archive under
`build/`. The Linux target builds every public ELF application and runs
representative storage, loopback protocol, workload, authentication, scheduler,
secure-transport, concurrent two-wave server/client, and release-contract tests
through WSL. It remains a focused portable gate rather than the complete Windows
release matrix.
Successful runs end with the platform-specific `SUCCESS` gate.

```text
MiniSQL 1.0.0 test suite: SUCCESS
```

A source-only static validation is available with:

```powershell
.\test.ps1 -StaticOnly
```

Restart-aware capacity and memory regressions are available separately for
`1`, `5`, and `10` GiB logical payloads. They use the same Python compiler,
default to 32 MiB write processes and enforce a 512 MiB private-memory ceiling:

```powershell
python .\tests\performance\capacity_regression.py --profile 1 --vacuum
```

The profile validates automatic WAL reset, recovery between every chunk,
indexed restart latency, projection/range pushdown, the configured read cache,
large overflow values, and post-`VACUUM` data integrity. See
[`tests/performance/README.md`](tests/performance/README.md) for the `5` and
`10` GiB commands and tunable guardrails. The earlier optimization history is in
[`PERFORMANCE_BASELINE_2026-08-23.md`](tests/performance/PERFORMANCE_BASELINE_2026-08-23.md).

### Production operations

Configured servers enforce `server.maxConnections`, `maxStatementBytes`,
`maxFrameBytes`, `maxResultRows`, `maxResultBytes`, and `idleTimeoutMs`. Result
row and aggregate wire-byte limits cover materialized and streaming paths;
oversized work fails with resource error `9037` instead of growing without
bound. `runtime.queryTimeoutMs` is an absolute cooperative statement deadline,
including physical-gate waits and streamed execution. Python
`Connection.cancel()` and JDBC `Statement.cancel()` automatically open a
separate control connection; native and operational clients can cancel a
session shown by `SHOW PROCESSLIST`. Cancellation and timeout report `9035`
and `9036`.

`runtime.processMemoryBytes` rejects new statements and cooperatively aborts
active work when live managed-heap use reaches the configured ceiling.
`runtime.temporaryStorageBytes`
is a hard process-wide reservation ceiling for concurrent operator spills,
while `runtime.temporaryMemoryBytes` remains the soft per-query threshold that
triggers those spills. The managed-heap ceiling is admission control, not an OS
RSS/container limit; use an operating-system job, service, or container limit as
the final whole-process guard.

Administrators can query `SHOW STATUS` for uptime, sessions, statement/error and
row counters, cancellation/timeouts, slow queries, result bytes, heap and spill
usage, checkpoint resets, and the active limits. `SHOW PROCESSLIST`
returns the authenticated principal, peer, TLS state, current state/statement,
age, and request count for every live session. `SHUTDOWN` acknowledges the
request, completes the protocol close handshake, stops new accepts, drains the
bounded worker pool, and closes the database.

Statements reaching `runtime.slowQueryMs` produce a warning with session,
duration, row count, result bytes and success state. A loopback-only Prometheus
bridge exposes the same `SHOW STATUS` values and a health probe:

```powershell
python .\tools\monitoring\minisql_exporter.py --database-port 7432 --listen-port 9107
```

Scrape `http://127.0.0.1:9107/metrics`; credentials are read only from the
environment variable named by `--password-env`.

The systemd unit template is in [`deploy/systemd/minisql.service`](deploy/systemd/minisql.service).
Windows Task Scheduler or a service wrapper can invoke the paired
[`Start-MiniSQL.ps1`](deploy/windows/Start-MiniSQL.ps1) and
[`Stop-MiniSQL.ps1`](deploy/windows/Stop-MiniSQL.ps1) scripts. The paired
templates use trusted loopback so graceful stop needs no stored password. A release
candidate should also pass the 24-hour resource-drift runner:

```powershell
python .\tests\soak\production_soak.py --pid $serverPid --duration-minutes 1440 -- `
  .\build\performance\native-concurrent-final.exe 7551 32 2000 1
```

Run a non-destructive restore drill into new paths with:

```powershell
python .\tools\recovery\production_recovery_drill.py <database> <new-backup> <new-restore>
```

Exercise live WAL export, concurrent standby reads, explicit promotion,
post-promotion writes, allocator continuity, and offline integrity checking:

```powershell
python .\tests\ha\production_failover_drill.py --work-root .\build\ha-drill
```

## Performance evaluation

The production-operations smoke on 2026-08-29 completed 13 measured waves of
eight freshly connected clients and 100 indexed reads per client (10,400 SQL
requests after warm-up). Throughput was 8,511-10,256 requests/s, server threads
remained constant at 44, RSS median drift was 4.47 MiB, and handle median drift
was 16 while the final samples stabilized. This short guard validates the soak
runner and repeated connection cleanup; the documented 24-hour run remains a
release gate, not a claim made by the short smoke.

### 2026-08-29 native concurrent-read profile

A native MiniLang load generator now separates server scaling from Python
interpreter effects. On the Windows reference system, persistent prepared
primary-key reads reached **7,529 / 5,658 / 3,442 requests/s** at 8 / 16 / 32
clients. Each median covers five fresh-server trials with 2,000 measured reads
per client after warm-up.

Windows query-local `OVERLAPPED` completion-event reuse improved the matched
throughput by **0.75% / 2.76% / 1.35%**. At 16 clients it also reduced host
context switches from 39.54 to 36.87 per request. The workload transfers 158.76
framed-protocol bytes and performs about 5.16 physical reads (20.63 KiB) per
request, so the continuing decline beyond eight clients is a scheduler/context-
switch problem rather than network volume or Python's GIL. Methodology, CPU,
memory, handle and I/O measurements are in the
[`native concurrency report`](tests/performance/NATIVE_CONCURRENCY_2026-08-29.md).

### 2026-08-28 execution-pipeline update

The latest Windows execution pass retains the exact 1 GiB workload below and
adds bounded forward-only result cursors, page-range parallel scalar
aggregation, vector batches, byte-aware query memory/spill decisions, SIMD byte
search for common `LIKE` patterns, and contiguous base/B+ tree publication.
Against revision `1af5ed15ebeaf15b0ce8247891361dc1f2233b2b`, durable insert
wall time fell from 92.610 s to **69.689 s (1.329x)**, cold semantic verification
from 1.228 s to **0.262 s (4.69x)**, and warm restart verification from a 1.172 s
median to **0.184 s (6.38x)**. Single-client `SUM(id)` rose from 8.723 to
**28.794 statements/s (3.30x)**.

A complete `SELECT id, payload` transported all 1,024 one-MiB rows through the
new cursor in **6.048 s (169.3 MiB/s)** while peaking at **146.99 MiB** client
and **212.29 MiB** server private memory. The full methodology, before/after
tables, multi-client regressions, narrow-row findings, raw-report hashes, and
next actions are in the
[`2026-08-28 execution-pipeline report`](tests/performance/EXECUTION_PIPELINE_2026-08-28.md).
The Windows/Linux table below remains the most recent matched cross-platform
reference; it predates this Windows-only execution pass.

### 2026-08-28 JDBC latency update

The dependency-free Java driver now uses server-side `PREPARE`/`EXECUTE`,
bounded multi-row insert batching, `TCP_NODELAY`, and one TLS application record
per MiniSQL request frame. On the Windows reference system below, the matched
loopback JDBC benchmark improved a prepared 200-row transactional batch from
**50.36 to 513.37 rows/s (10.19x)**. TLS `SELECT 1` improved from **16.01 to
198.91 statements/s (12.42x)** and its median latency fell from **105.4 to
6.33 ms**. Trusted `SELECT 1` reached **265.44 statements/s**, prepared random
primary-key lookup reached **25.13 statements/s**, and a 100,000-row streaming
scan reached **5,459.69 rows/s** with a **32.50 MiB** measured Java-heap delta.

These values use OpenJDK 21.0.10 with a 512 MiB heap and the same 5,000-row
loopback dataset before and after the change. They isolate JDBC/protocol
overhead and complement, rather than replace, the 1-GiB native Windows/Linux
storage reference below.

The current reference was measured on 2026-08-26 from MiniSQL revision
`12997258408e27ab2f4839f52782b844eeade5a5` and MiniLangCompilerPy revision
`21dbc2e99097099ee1d8e9e8168e46836e49b6a3` (compiler version 1.1.0). Both
PE and ELF applications were rebuilt immediately before measurement.

### Test system

| Item | Reference system |
| --- | --- |
| Processor | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Reported maximum clock | 4.40 GHz |
| Host memory | 61.6 GiB installed |
| Windows | Windows 11 Pro x64, version 10.0.26200, build 26200; Python 3.11.9 |
| Windows storage | Lexar SSD NQ790 2 TB NVMe, NTFS |
| Power policy | Windows `Balanced` |
| Linux | Ubuntu 24.04.4 LTS under WSL2, kernel 6.6.87.2, glibc 2.39; Python 3.12.3 |
| Linux resources | 24 logical processors, 30.2 GiB visible memory, ext4 data volume |

The large-data workload contains 1,024 rows with one 1 MiB external `TEXT`
value per row: exactly 1 GiB of logical payload and 1,115,584,941 bytes
(1,063.90 MiB) on disk. Each platform created three complete databases using
32 MiB transactions with a close/reopen between chunks. Seven independent
processes measured restart verification, point lookup, and the full offline
checker. Network figures are medians of three server runs at 1, 4, and 8
clients; each persistent client executed 500 `COUNT(*)` or 200 `SUM(id)`
statements. Host filesystem caches were warm and were not force-flushed.

Linux data lived on native WSL2 ext4, not `/mnt/c`. These figures therefore
compare the current Windows PE and Linux ELF implementations on one host, but
they are not a bare-metal Linux comparison or a production performance
guarantee.

### Large-data storage, verification, and CRC-32C

| Measurement, median | Windows x64 | Linux x64 under WSL2 |
| --- | ---: | ---: |
| Durable 1 GiB insert, engine time | 78.636 s | 120.453 s |
| Durable 1 GiB insert throughput | **13.02 MiB/s** | **8.50 MiB/s** |
| Durable 1 GiB insert, process wall time | 81.505 s | 124.494 s |
| First fresh-process semantic verification, engine / wall | 188 ms / 290 ms | 230 ms / 344 ms |
| Warm restart semantic verification, engine / wall | **110 ms / 172 ms** | **223 ms / 367 ms** |
| Indexed 1 MiB value lookup, engine / wall | **16 ms / 100 ms** | **83 ms / 214 ms** |
| Full 1,063.90 MiB offline integrity check | **4.666 s / 228.0 MiB/s** | **3.902 s / 272.6 MiB/s** |
| Native CRC-32C over 4 GiB | **313 ms / 12.78 GiB/s** | **320 ms / 12.50 GiB/s** |

The CRC result is the median of seven runs over a 64 MiB buffer repeated 64
times. Both targets returned checksum `4049696722`. The production primitive
uses SSE4.2 qword processing on this CPU and retains the exact Castagnoli table
fallback for CPUs without SSE4.2. The offline checker is stricter than the
semantic verifier: it reads every external value, validates every overflow
chain and checksum, and cross-checks all active B+ tree entries.

### SQL request throughput

Persistent throughput includes protocol framing and result handling over
loopback but excludes process startup and reconnect per statement.

| Query | Clients | Windows stmt/s | Linux/WSL2 stmt/s |
| --- | ---: | ---: | ---: |
| `COUNT(*)` | 1 | **225.650** | **172.870** |
| `COUNT(*)` | 4 | **243.199** | **204.813** |
| `COUNT(*)` | 8 | **248.125** | **204.569** |
| `SUM(id)` | 1 | **12.056** | **12.088** |
| `SUM(id)` | 4 | **25.826** | **22.723** |
| `SUM(id)` | 8 | **17.718** | **14.568** |

`COUNT(*)` uses MiniSQL's validated row-count fast path. `SUM(id)` scans and
decodes the projected integer column across all 1,024 rows; projection pushdown
correctly avoids loading the unrelated 1 MiB payload. The scan-heavy workload
peaks at four clients on both targets and regresses at eight, while the cheap
count path plateaus around four to eight clients.

One-shot `COUNT(*)`, including client process startup, connect, request, result,
and close, measured:

| Concurrent clients | Windows requests/s | Linux/WSL2 requests/s |
| ---: | ---: | ---: |
| 1 | 27.019 | 29.834 |
| 4 | 47.600 | 35.968 |
| 8 | 49.743 | 36.917 |

Applications should retain or pool connections when latency matters.

### Optimizer access-path microbenchmark

The advanced optimizer revision was additionally measured on Windows against
the same warm persistent-loopback fixture used during optimizer development:
8,000 rows, one client, 200 statements per session, three independent server
runs, and identical 200-row integer result shapes. Selecting only the filtered
B+ tree key (`SELECT category ... WHERE category = 3`) used `Index Only Scan`
and reached a median **98.899 statements/s**. Selecting `id` through the same
filter required heap dereference and reached **80.140 statements/s**. Avoiding
heap and overflow access was therefore **1.234x faster (+23.4%)** in this
focused workload. This microbenchmark isolates access-path cost and is not a
replacement for the 1 GiB end-to-end figures above.

The `INCLUDE` extension was measured separately on Windows with three fresh
native in-process database runs: 4,000 rows, a 108-byte `TEXT` payload, 200
identical result rows, 10 warm-ups, and 30 measured statements per access path.
`SELECT payload ... WHERE category = 3` reached a median **22.866 statements/s**
with `CREATE INDEX ... (category) INCLUDE (payload)`, versus **14.881
statements/s** through the same non-covering category index and heap/overflow
lookups. The covering leaf payload was therefore **1.537x faster (+53.7%)** in
this deliberately payload-sensitive microbenchmark.

### Peak private memory

| Process/phase, median peak | Windows x64 | Linux x64 under WSL2 |
| --- | ---: | ---: |
| One 32 MiB durable insert worker | 332.52 MiB | 270.11 MiB |
| First fresh-process semantic verification | 130.67 MiB | 65.62 MiB |
| Warm restart semantic verification | 114.39 MiB | 54.94 MiB |
| Indexed 1 MiB value lookup | 98.11 MiB | 31.82 MiB |
| Full offline integrity checker | 146.91 MiB | 81.36 MiB |
| Server during persistent `COUNT(*)` | 115.21 MiB | 58.52 MiB |
| Server during persistent `SUM(id)` | 164.05 MiB | 119.98 MiB |

Windows memory is `PROCESS_MEMORY_COUNTERS_EX.PrivateUsage`; Linux is the sum
of private mappings from `/proc/<pid>/smaps_rollup`. They are the closest
practical per-process counters available to the harness, not identical kernel
accounting definitions. Every phase remained below the 512 MiB regression
ceiling.

The reproducible driver is
[`tests/performance/platform_compare.py`](tests/performance/platform_compare.py).
It accepts `--storage-mib 1024 --storage-chunk-mib 32` for this workload. The
raw reference reports had SHA-256
`0651EE2E78E80DF4478211F63BADD5806C1E045AFE5608B3C9356902592FDE60`
(Windows) and
`FBFE55085946D36D4C1BA4AEF184D2BBE8F671CE68198806081B916F308B1E5B`
(Linux). See the dated
[`Windows/Linux comparison`](tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md)
for the earlier 64 MiB baseline, historical Linux transport failure, its
verified fix, and additional WSL2 limitations.

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
src/minisql/           78 database-engine and workbench modules
src/tests/             native MiniLang tests
config/                example configuration and JSON schema
docs/spec/             behavioral specifications
docs/formats/          persistent and wire-format specifications
docs/adr/              architecture decision records
docs/release/          operator and SQL documentation
tests/                 cumulative runner, fixtures, corpora, and references
tools/                 replication, quality, and release tooling
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
exposing a server outside a trusted local environment. The native TLS tests
generate an ephemeral localhost identity at runtime; production certificates
and private keys remain operator-managed secrets.

## License

MiniSQL is distributed under the Apache License 2.0. See [`LICENSE`](LICENSE)
and [`NOTICE.md`](NOTICE.md). Every MiniLang, Python and PowerShell source file
contains an Apache-2.0 header; public APIs, data structures, invariants and
non-obvious algorithms are documented in English alongside the implementation.
