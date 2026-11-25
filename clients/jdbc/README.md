# MiniSQL JDBC Driver

The dependency-free MiniSQL JDBC 4.3 driver targets Java 11 or newer and speaks
the native MiniSQL v1 protocol directly. It supports trusted-local and password
authentication, TLS 1.3, exact SHA-256 certificate pinning, statements,
server-backed prepared statements, bounded multi-row insert batches,
transactions, forward-only streaming
result sets, and the catalog metadata commonly used by IDEs and connection
pools.

Build the driver from the repository root:

```powershell
.\clients\jdbc\build.ps1
```

The resulting JAR is `build/jdbc/minisql-jdbc-1.1.1.jar`. A conventional Maven
project descriptor is also supplied, so `mvn package` can be used in this
directory when Maven and a full JDK are installed.

Run the unit, trusted-local, continuation-frame, authenticated secure-transport,
and self-signed TLS 1.3 certificate-pinning tests with:

```powershell
.\clients\jdbc\test.ps1
```

See the [JDBC release guide](../../docs/release/JDBC.md) for URLs, examples,
properties, supported interfaces, and protocol-v1 limitations.

## Stored procedures

`Statement.execute("CALL ...")` streams separate procedure results. Use
`getMoreResults()` to advance, including the final CALL update count:

```java
boolean rows = statement.execute("CALL report_orders(100)");
while (rows || statement.getUpdateCount() != -1) {
    if (rows) {
        try (ResultSet result = statement.getResultSet()) {
            while (result.next()) System.out.println(result.getString(1));
        }
    }
    rows = statement.getMoreResults();
}
```

`Connection.prepareCall()` accepts `{call schema.procedure(?, ...)}` and direct
`CALL schema.procedure(?, ...)` syntax. Bind IN parameters with the ordinary
setters, register positional OUT parameters, and do both for INOUT parameters:

```java
try (CallableStatement call = connection.prepareCall("{call calculate_total(?, ?)}")) {
    call.setInt(1, 100);
    call.registerOutParameter(2, java.sql.Types.DECIMAL);
    call.execute();
    System.out.println(call.getBigDecimal(2));
}
```

`CallableStatement` buffers procedure results before reading output session
variables. Its result sets remain available through `getResultSet()` and
`getMoreResults()`. For large results, use ordinary streaming `Statement` calls
with explicit session variables and retrieve OUT values after draining the
CALL. Positional bindings and common scalar output getters are supported;
named parameter bindings, function-return call escapes, callable batches, and
`KEEP_CURRENT_RESULT` are explicitly unsupported. The existing protocol-v1 text
and SQL NULL representation remains unchanged.

Closing a statement drains every remaining result. Closing its current
`ResultSet` discards only that result, allowing `getMoreResults()` to advance.
`SIGNAL` and `RESIGNAL` exceptions expose their SQLSTATE through
`SQLException.getSQLState()` and their requested `MYSQL_ERRNO` through
`getErrorCode()`. A condition raised after a completed SELECT is reported by
`getMoreResults()` after that SELECT remains readable.
`DELIMITER` is a console/GUI command; JDBC submits a complete compound
`CREATE PROCEDURE` statement directly without it.
