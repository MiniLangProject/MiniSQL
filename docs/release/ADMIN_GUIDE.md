# MiniSQL 1.0 administrator guide

Create a database with `minisqld.exe --init <root> <name> [page-size]`. Start a
loopback server with `--serve`, an authenticated server with
`--serve-authenticated`, or a read-only standby with `--serve-standby`.

For production-style operational settings, use `--serve-config <database>
<config-file>`, `--serve-authenticated-config`, or `--serve-standby-config`.
`runtime.logLevel` accepts `debug`, `info`, `warning`, or `error`. The `logging`
section enables stdout and/or the same records in a file under
`paths.logDirectory`; `rotationHours` rolls non-empty active files by elapsed
time. The logger is one process-wide synchronized singleton, so records from
connection workers cannot interleave at the file boundary.

The Windows daemon disables QuickEdit before it emits operational records.
Legacy console hosts otherwise suspend a process while selected text remains in
mark mode (`Select`/`Auswählen` in the window title), which can stop handshakes
at the connection log line. File destinations are written before stdout, and
clients fail an unanswered initial handshake after five seconds. With an older
running daemon, press `Esc` to leave mark mode before reconnecting.

Enable the independent `binlog` section to flush every complete SQL statement
before execution. Binlog capture ignores the ordinary severity threshold.
Protect it as sensitive data because SQL literals can contain credentials,
personal information, or application secrets.

The optional `max-clients` argument bounds native MiniLang thread-pool workers
and live sessions. Each worker owns one connection, so slow clients do not stall
other sockets. Read-only plans can execute in parallel on the same database;
mutations remain exclusive behind a writer-prioritized gate. Size the limit for
the expected connection count, read parallelism and available memory. Increasing
it does not add write parallelism.

The execution classifier treats ordinary read-only `SELECT`, `EXPLAIN` and
metadata requests as shared operations. DML, DDL, DCL, explicit transaction and
session state, maintenance, and sequence consumption are conservative exclusive
operations. A waiting writer prevents new readers from entering. Existing
readers finish before the writer proceeds; this bounds writer starvation without
aborting valid reads.

Each read scan owns an independent table/index handle and holds a compatible
shared Win32 byte-range lock. Writers retain exclusive locks. If a durable index
dirty marker appears, the reader leaves the shared gate and performs repair only
after acquiring the exclusive gate.

Table scans maintain small `<table>.heap-pages` files next to table storage.
These CRC-protected files are derived acceleration metadata, not user data: a
legacy database creates them lazily, growth extends only the new page tail, and
missing, stale, or damaged copies rebuild automatically. Do not copy or restore
one independently of its table. It is safe to delete while the database is
stopped; the next scan performs one complete classification pass.

Format-relevant settings are copied into `db.meta` when a database is created.
Changing global defaults never changes an existing database. A page-size change
requires `minisql-migrate.exe --rewrite`.

Run `minisql-check.exe <database>` after abnormal storage events and before
publishing a restored or migrated database. Schedule verified backups and test
restores regularly. The checker is memory-bounded by the largest individual row:
it streams heap rows, external TEXT/BLOB chains, and active B+ tree leaves, then
proves heap/index equality with exact entry probes and count equality. Runtime
still scales with all authoritative payload bytes because no checksum or overflow
validation is skipped.

CRC-32C calculation is table-driven and processes eight bytes per loop body.
This is an implementation-only acceleration: the reflected Castagnoli
polynomial, initial state, final XOR, incremental-update behavior, and every
persisted checksum remain unchanged, so no migration or rebuild is required.
