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

