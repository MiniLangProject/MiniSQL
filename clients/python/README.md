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

`callproc()` buffers all procedure results so it can fetch output parameters
before returning. Use explicit `SET @name = ...`, `CALL ...(@name)`, and a later
`SELECT @name` with `execute()` when streaming large results matters. As with
other protocol-v1 values, OUT/INOUT parameter outputs arrive as text (or `None` for SQL
NULL); the protocol's historical text/null representation is unchanged.
`nextset()` discards unread rows of the current result only. Closing a cursor
drains all remaining results before allowing connection reuse.

`DELIMITER` belongs to MiniSQL console/GUI script input; pass a complete
`CREATE PROCEDURE ... BEGIN ... END` SQL string directly to `execute()` without
that client command.
