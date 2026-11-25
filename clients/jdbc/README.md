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
CALL syntax, including quoted names and mixtures of parameter markers and SQL
argument expressions. Bind IN parameters with ordinary setters, register OUT
parameters, and do both for INOUT parameters. Parameter names and numeric JDBC
marker positions are supported:

```java
try (CallableStatement call = connection.prepareCall("{call calculate_total(?, ?)}")) {
    call.setInt(1, 100);
    call.registerOutParameter(2, java.sql.Types.DECIMAL);
    call.execute();
    System.out.println(call.getBigDecimal(2));
}
```

`CallableStatement` consumes a CALL before publishing output parameters and
retains its results in a private temporary-file spool. Replay keeps a bounded
number of frames in memory. Closing or exhausting results removes their files.
For incremental results as the procedure executes, use ordinary `Statement`
CALLs. Simple procedure SELECTs stream in bounded batches; blocking SQL operators
may still materialize their own result.

Current peers negotiate the optional `results-v2` extension. Its final CALL
response carries typed OUT/INOUT values, including exact SQL NULL and decimal
scale, without a subsequent output SELECT. Private session variables are reused
per connection until it closes, bounded by its largest CALL parameter list.
`getObject()` uses the registered output type, and typed scalar getters remain
available. Older servers retain the compatible text output lookup path.

`DatabaseMetaData.getProcedures()` and `getProcedureColumns()` expose live
routine metadata. Callable `getParameterMetaData()` reports declared parameter
modes, types, length, precision, and scale. Named setters, output registration,
and getters use these parameter definitions.

`getMoreResults(Statement.KEEP_CURRENT_RESULT)` retains the previous result in a
bounded-memory disk spool while advancing. Callable batches support IN-only
procedures and report partial update counts on failure. OUT/INOUT registration
is rejected for batches; a result-producing batch entry is an error. Function
return call escapes remain outside the stored-procedure API.

Closing a statement drains every remaining result. Closing its current
`ResultSet` discards only that result, allowing `getMoreResults()` to advance.
`SIGNAL` and `RESIGNAL` exceptions expose their SQLSTATE through
`SQLException.getSQLState()` and their requested `MYSQL_ERRNO` through
`getErrorCode()`. A condition raised after a completed SELECT is reported by
`getMoreResults()` after that SELECT remains readable.
Negotiated responses carry SQLSTATE directly, including native errors, and
expose SQLWarning chains on the connection, statement, and result set. Exact NULL
bits distinguish SQL NULL from a stored `"NULL"` string. Ordinary result type
metadata uses the supplied native type kind; unknown types remain conservative.
`DELIMITER` is a console/GUI command; JDBC submits a complete compound
`CREATE PROCEDURE` statement directly without it.
