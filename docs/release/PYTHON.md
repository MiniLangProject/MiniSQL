# MiniSQL Python connector

The `minisql-connector` package implements Python DB-API 2.0 (PEP 249) for
Python 3.10 and newer. It communicates directly with MiniSQL protocol v1; no
JDBC bridge, native Python extension, or external DBMS client is involved.
Authenticated secure framing uses the maintained `cryptography` package for
AES-256-GCM.

## Installation

From a MiniSQL source checkout:

```powershell
python -m pip install .\clients\python
```

The package metadata declares `cryptography>=41`, which is required for
password-authenticated sessions. TLS itself uses Python's standard `ssl`
module and negotiates only TLS 1.3; the selected suite must be
`TLS_AES_256_GCM_SHA384`.

## Basic use

```python
import minisql

connection = minisql.connect(
    host="127.0.0.1",
    port=7432,
    database="main",
)
try:
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT id, email FROM customer WHERE registered_at >= ? ORDER BY id",
            ("2026-01-01",),
        )
        for identifier, email in cursor:
            print(identifier, email)
    connection.commit()
finally:
    connection.close()
```

`paramstyle` is `qmark`. Markers inside strings, quoted identifiers, line
comments, and block comments are ignored. Values are rendered as validated SQL
literals and parameterized `SELECT`, `INSERT`, `UPDATE`, and `DELETE` operations
use a bounded 128-entry session-local `PREPARE`/`EXECUTE` LRU cache.

## DSNs and authentication

The equivalent DSN forms are:

```python
minisql.connect("minisql://127.0.0.1:7432/main")
minisql.connect(
    "minisql://admin:secret@127.0.0.1:7432/main"
)
```

Passwords in a DSN must be URL-encoded. Supplying credentials as keyword
arguments avoids placing them in application logs:

```python
minisql.connect(
    host="127.0.0.1",
    port=7432,
    user="admin",
    password=secret_from_environment,
)
```

Supported DSN query/keyword options are `tls`, `server_name`, `pin_sha256`,
`trust_server_certificate`, `ca_file`, `connect_timeout`, `socket_timeout`,
`autocommit`, and `isolation_level`. Timeouts are expressed in seconds; zero
selects the platform blocking default.

## TLS and self-signed certificates

Normal PKIX and hostname validation:

```python
connection = minisql.connect(
    host="db.example.test",
    tls=True,
    server_name="db.example.test",
)
```

A private CA can be supplied with `ca_file`. For a self-signed deployment, pin
the exact leaf certificate and explicitly enable pin-only trust:

```python
connection = minisql.connect(
    host="127.0.0.1",
    tls=True,
    server_name="localhost",
    trust_server_certificate=True,
    pin_sha256="4a...64 hexadecimal characters...9f",
    user="admin",
    password=secret,
)
```

`trust_server_certificate=True` is rejected without a valid 32-byte SHA-256
pin. The connector validates the negotiated TLS version/cipher and compares the
DER leaf digest using a constant-time comparison.

## Transactions

DB-API autocommit is disabled by default. The connector begins a transaction
lazily before the first non-DDL statement. `commit()` and `rollback()` are
no-ops when no transaction is active. `READ COMMITTED` and `SERIALIZABLE` are
available through `isolation_level`.

MiniSQL authenticated DDL is autocommit-only, and explicit MiniSQL transactions
cannot mix DDL with DML. The connector therefore commits an active DB-API
transaction immediately before `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `VACUUM`,
`REINDEX`, or `ANALYZE` and executes that operation implicitly. This behavior is
intentional and identical in trusted and authenticated sessions.

The connection context manager commits on normal exit and rolls back when an
exception escapes. It does not close the connection; call `close()` explicitly
or place that call in `finally`.

## Batches and streaming

`executemany()` accepts any iterable of parameter sequences. Compatible
single-row inserts are coalesced into requests of at most 256 rows and 768 KiB
of UTF-8 SQL. A failed coalesced request is retried entry by entry; an internal
savepoint protects explicit transactions so first-failure semantics remain
correct. Input iterables are consumed incrementally rather than materialized in
memory.

Result frames are read only as `fetchone()`, `fetchmany()`, iteration, or
`fetchall()` asks for them. Closing a cursor drains unread continuation frames
before the connection is reused. Protocol v1 is ordered and not multiplexed,
so only one cursor may have an unread result on a connection. Use one connection
per concurrent worker or a normal Python connection pool.

## Protocol-v1 limitations

Protocol v1 represents result cells as UTF-8 text without a SQL type or null
bitmap. Rows therefore contain strings and `None`; the wire token `NULL` is
interpreted as SQL NULL and cannot be distinguished from stored text containing
exactly `NULL`. Cursor descriptions conservatively use `minisql.STRING`.

Python `bytes` results can be decoded by applications from MiniSQL's `0x...`
rendering, but binary parameter binding is unavailable because SQL v1 has no
binary literal. Stored procedures, multiple result sets, scrollable cursors,
and two-phase commit are not implemented.

## Validation

Run:

```powershell
.\clients\python\test.ps1
```

The script creates an isolated virtual environment, installs the package,
checks DB-API metadata, CRC-32C, DSN validation, parameter scanning, literals,
and insert splitting, then runs 1,216 live checks in each of trusted-local,
password-authenticated, and pinned self-signed TLS modes. Live tests cover a
600-row continuation result, prepared plans, bounded batches, quote safety,
transaction rollback, DDL boundaries, cursor draining, temporal parameters,
and autocommit/transactional batch partial-failure behavior.
