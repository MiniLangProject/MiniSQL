# MiniSQL JDBC Driver

The dependency-free MiniSQL JDBC 4.3 driver targets Java 11 or newer and speaks
the native MiniSQL v1 protocol directly. It supports trusted-local and password
authentication, TLS 1.3, exact SHA-256 certificate pinning, statements,
client-side prepared statements, batches, transactions, forward-only streaming
result sets, and the catalog metadata commonly used by IDEs and connection
pools.

Build the driver from the repository root:

```powershell
.\clients\jdbc\build.ps1
```

The resulting JAR is `build/jdbc/minisql-jdbc-1.0.0.jar`. A conventional Maven
project descriptor is also supplied, so `mvn package` can be used in this
directory when Maven and a full JDK are installed.

Run the unit, trusted-local, continuation-frame, authenticated secure-transport,
and self-signed TLS 1.3 certificate-pinning tests with:

```powershell
.\clients\jdbc\test.ps1
```

See the [JDBC release guide](../../docs/release/JDBC.md) for URLs, examples,
properties, supported interfaces, and protocol-v1 limitations.
