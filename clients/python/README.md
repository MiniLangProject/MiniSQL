# MiniSQL Python Connector

The MiniSQL Python connector implements Python DB-API 2.0 (PEP 249) for Python
3.10 or newer. It speaks MiniSQL protocol v1 directly and supports trusted-local
and password authentication, TLS 1.3, SHA-256 certificate pinning, lazy
transactions, server-side prepared plans, streaming results, and bounded
multi-row `executemany()` inserts.

Install the connector from the repository:

```powershell
python -m pip install .\clients\python
```

Use it like any other DB-API module:

```python
import minisql

with minisql.connect("minisql://127.0.0.1:7432/main") as connection:
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, name FROM customer WHERE id >= ?", (100,))
        for row in cursor:
            print(row)
```

Run the unit and disposable trusted/authenticated/TLS live suites after building
the MiniSQL applications:

```powershell
.\clients\python\test.ps1
```

See the [Python connector guide](../../docs/release/PYTHON.md) for all connection
options, transaction behavior, security settings, and protocol-v1 limitations.


## Stored procedures

Use `execute()` and `nextset()` to stream procedure results without merging
consecutive SELECTs that happen to have the same column names:

```python
cursor.execute("CALL report_orders(?)", (100,))
while True:
    if cursor.description is not None:
        for row in cursor:
            print(row)
    if cursor.nextset() is None:
        break
```

`callproc(name, parameters)` supports IN, OUT, and INOUT parameters. Pass an
initial value for each argument (`None` for an OUT parameter); the return tuple
preserves IN arguments and contains updated OUT/INOUT values. Procedure result sets remain available
through `fetchone()` / iteration and `nextset()`.

```python
updated = cursor.callproc("calculate_total", (100, None))
print("total:", updated[1])
```

`callproc()` consumes the CALL before returning output parameters. It retains
results in a private temporary spool, spilling to disk after one MiB instead of
keeping the complete result in memory. Closing or exhausting the cursor removes
the spool. Use `execute("CALL ...")` and `nextset()` when results should be read as
the procedure runs. Simple procedure SELECTs stream in bounded batches; blocking
SQL operators may still materialize their own result.

Current clients and servers negotiate the optional `results-v2` extension while
retaining protocol version 1. OUT/INOUT values then use Python `bool`, `int`,
`float`, `Decimal`, `bytes`, `date`, `time`, `datetime`, `str`, or `None` according
to their declared type. Decimal outputs preserve their declared scale, and the
literal text `"NULL"` is distinct from SQL NULL. Ordinary result rows retain the
compatible string/`None` API; cursor descriptions expose NUMBER, BINARY,
DATETIME, or STRING when type information is available.

`callproc()` accepts quoted identifiers such as `"MyProcedure"` and
`schema.\`MyProcedure\`` and preserves their case. Negotiated calls receive output
values in their final response without a follow-up SQL query. Private session
variables are reused per connection until it closes; their count is bounded by
the largest parameter list used on that connection. CALL statements participate
in the session-local prepared-plan cache.

An older server still works through the legacy protocol path, with textual
OUT/INOUT values and the historical ambiguous `NULL` token. That path performs
the compatibility output lookup and cleanup queries.
`nextset()` discards unread rows of the current result only. Closing a cursor
drains all remaining results before allowing connection reuse.

Errors expose `.code` and `.sqlstate`. With structured diagnostics, the DB-API
exception subclass follows SQLSTATE, so an application error number cannot be
mistaken for a native integrity error merely because the numbers overlap.
`cursor.messages` and `connection.messages` expose `(minisql.Warning, warning)`
pairs; each warning contains `.code` and `.sqlstate`. The warning list becomes
available when its terminal response is consumed. Internal output retrieval does
not overwrite the CALL's server diagnostics.

`DELIMITER` belongs to MiniSQL console/GUI script input; pass a complete
`CREATE PROCEDURE ... BEGIN ... END` SQL string directly to `execute()` without
that client command.
