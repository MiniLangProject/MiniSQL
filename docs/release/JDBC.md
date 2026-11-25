# MiniSQL JDBC driver

## Requirements and build

The MiniSQL JDBC driver requires Java 11 or newer and has no runtime
dependencies. Build it on Windows from the repository root:

```powershell
.\clients\jdbc\build.ps1
```

This creates `build/jdbc/minisql-jdbc-1.1.1.jar`. The JAR contains the
`java.sql.Driver` service entry, so modern Java applications discover it
automatically when it is on the class path. Calling
`Class.forName("org.minilang.minisql.jdbc.MiniSqlDriver")` remains supported for
older frameworks.

## Connection URLs

The URL format is:

```text
jdbc:minisql://host[:port]/database[?property=value&...]
```

The default port is 7432. The database component is the JDBC catalog label;
the actual database is selected by the `minisqld` process listening on that
port.

Trusted-local example:

```java
try (Connection connection = DriverManager.getConnection(
        "jdbc:minisql://127.0.0.1:7432/main")) {
    try (PreparedStatement statement = connection.prepareStatement(
            "SELECT id, name FROM customer WHERE id >= ? ORDER BY id")) {
        statement.setInt(1, 100);
        try (ResultSet rows = statement.executeQuery()) {
            while (rows.next()) {
                System.out.println(rows.getInt("id") + ": " + rows.getString("name"));
            }
        }
    }
}
```

Authenticated example:

```java
Properties properties = new Properties();
properties.setProperty("user", "application");
properties.setProperty("password", System.getenv("MINISQL_PASSWORD"));
try (Connection connection = DriverManager.getConnection(
        "jdbc:minisql://127.0.0.1:7432/main", properties)) {
    // Password authentication also activates MiniSQL's inner AES-256-GCM transport.
}
```

## TLS and certificate pinning

TLS connections use TLS 1.3 and `TLS_AES_256_GCM_SHA384`. Normal connections
validate the X.509 chain and endpoint name through the JVM trust store:

```text
jdbc:minisql://db.example:7432/main?tls=true&user=application&password=...
```

`serverName` overrides the name used for SNI and endpoint validation. Add an
exact SHA-256 leaf-certificate pin with `pinSha256`. Colons and dashes in the
64-digit hexadecimal pin are accepted.

For a self-signed certificate, set both `trustServerCertificate=true` and a
valid `pinSha256`. The driver deliberately refuses unverified trust-all TLS:

```text
jdbc:minisql://127.0.0.1:7432/main?tls=true&serverName=minisql.local&
  trustServerCertificate=true&pinSha256=<64-hex-digits>&user=application&password=...
```

## Properties

| Property | Default | Meaning |
| --- | --- | --- |
| `user` | none | MiniSQL principal; omission selects trusted-local mode. |
| `password` | empty | UTF-8 MiniSQL password. Prefer a `Properties` object over embedding secrets in a URL. |
| `tls` | `false` | Enable TLS 1.3 below the MiniSQL protocol. |
| `serverName` | URL host | X.509 endpoint name and TLS SNI value. |
| `pinSha256` | none | Exact SHA-256 digest of the leaf certificate. |
| `trustServerCertificate` | `false` | Permit a self-signed chain; requires `pinSha256`. |
| `connectTimeoutMs` | `10000` | TCP connect timeout; zero means the platform default. |
| `socketTimeoutMs` | `30000` | Socket read timeout; zero disables it. |

URL query properties take precedence over a supplied `Properties` object.

## JDBC behavior

- `Connection`, `Statement`, `PreparedStatement`, `ResultSet`,
  `ResultSetMetaData`, `DatabaseMetaData`, and `ParameterMetaData` implement the
  core read/write paths. Unsupported optional operations report
  `SQLFeatureNotSupportedException`.
- Result sets are forward-only and read-only. Continuation frames are fetched
  lazily and closing a result drains pending frames before the connection is
  reused.
- `READ_COMMITTED` and `SERIALIZABLE` map to MiniSQL transaction modes.
- Prepared statements lazily create a session-local MiniSQL `PREPARE` plan and
  execute it through `EXECUTE ... USING`. Older servers and statement kinds
  that cannot be prepared retain the safe quoted-literal fallback. Parameter
  markers inside strings, quoted identifiers, and comments are ignored.
- `DatabaseMetaData.getTables`, `getColumns`, and `getIndexInfo` use live
  `SHOW TABLES`, `DESCRIBE`, and `SHOW INDEXES` results.
- Consecutive compatible single-row `INSERT` batches are coalesced into bounded
  multi-row statements (at most 256 rows and 768 KiB of UTF-8 SQL per request).
  Other batches execute in order, and every path returns one update count per
  original batch entry. A failed coalesced statement is retried entry by entry;
  explicit transactions use an internal savepoint so JDBC partial-success and
  first-failure semantics remain intact.
- TCP uses `TCP_NODELAY`, and each protocol frame is emitted with one Java
  socket write. This avoids splitting small TLS requests into separate header
  and payload records.
- `Statement.cancel()` opens a separate control connection and cooperatively
  cancels the executing server session. Trusted-local connections work without
  credentials; authenticated deployments require the same principal to hold
  database `ADMIN`. Servers predating the cancellable session field report the
  feature as unsupported instead of pretending cancellation succeeded.

## Structured results and stored procedures

Current peers negotiate `results-v2` within protocol version 1. The extension
distinguishes SQL NULL from the text `"NULL"`, supplies native column type kinds,
and carries SQLSTATE and warning diagnostics directly. Typed getters continue
to parse row values on request. `ResultSetMetaData` uses known native type kinds;
unknown or empty-result types remain conservative. The row extension does not
include declared precision, scale, or character set. Catalog and routine
metadata instead report declared types from the live catalog.

`DatabaseMetaData.getProcedures()` and `getProcedureColumns()` expose procedures
and their parameter definitions. Callable `getParameterMetaData()` reports
declared modes, types, lengths, precision, and scale. `prepareCall()` accepts
direct CALL and JDBC call escapes, quoted identifiers, and mixtures of markers
and SQL expressions. Parameter setters, OUT registration, and getters support
both JDBC marker positions and declared names.

Callable statements consume the CALL before exposing its output values and
retain results in a private temporary-file spool with bounded replay buffers.
Current servers include typed OUT/INOUT values in the final response, preserving
SQL NULL and decimal scale without a follow-up SELECT. Private argument variables
are reused per connection, bounded by the largest CALL parameter list. Ordinary
`Statement` CALLs stream as the procedure runs; blocking SQL operators may still
materialize their own result. `getMoreResults(KEEP_CURRENT_RESULT)` retains the
previous result in a disk spool. Exhausting or closing results removes their
temporary files.

Callable batches support IN-only procedures and return partial update counts on
failure. OUT/INOUT registration is rejected for batches, and a result-producing
batch entry is an error. Connection, statement, and result-set warning chains
retain the CALL's warnings; server errors expose SQLSTATE and their numeric code.
See the [procedure examples](../../clients/jdbc/README.md#stored-procedures).

## Compatibility and remaining limits

Peers that do not negotiate `results-v2` retain the original text payload, the
ambiguous `NULL` token, conservative ordinary-query metadata, and the legacy
procedure-output lookup. New clients fall back automatically when an older
server does not advertise the extension.

The SQL grammar currently has no binary literal, so prepared statements cannot
safely implement `setBytes`; that method reports
`SQLFeatureNotSupportedException`. Binary query results remain readable through
`getBytes` because the server renders them as `0x` followed by hexadecimal
digits. Generic DECIMAL rows still lack declared scale in their wire metadata;
typed routine outputs preserve that scale in their normalized value. Generated
keys, scrollable/updatable result sets, XA, JDBC savepoint objects, and function
return call escapes remain unavailable.

## Validation

`clients/jdbc/test.ps1` compiles the driver with `--release 11`, checks URL and
property validation, a PBKDF2-HMAC-SHA-256 test vector, and SQL parameter
scanning. It then creates a disposable MiniSQL database and runs the same live
integration suite in trusted-local, authenticated, and self-signed TLS modes.
Each live run crosses the 512-row continuation boundary and verifies
transactions and rollback, server-plan allocation/deallocation, a 600-row
coalesced insert batch, typed getters, catalog metadata, and safe connection
reuse. The authenticated runs additionally prove
password/server proofs and inner AES-256-GCM framing; the TLS run creates a
disposable certificate and verifies TLS 1.3 plus its exact SHA-256 leaf pin.
