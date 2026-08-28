# MiniSQL 1.0.0

MiniSQL is a native Windows x64 and Linux x64 relational database management
system written in MiniLang. The Windows distribution contains:

* `minisqld.exe` – database creation and server;
* `minisql.exe` – console, script and one-shot client;
* `minisql-check.exe` – offline consistency checker;
* `minisql-backup.exe` – backup, PITR and standby tools;
* `minisql-migrate.exe` – offline page-size rewrite;
* `minisql-admin.exe` – native Windows MiniSQL Workbench;
* `clients/jdbc` – source and build scripts for the portable Java 11+ JDBC driver;
* native Windows Schannel TLS 1.3/X.509 transport;
* a Python sidecar for continuous hot replication.

Linux source builds provide the same five command-line applications without an
`.exe` suffix and use OpenSSL 3 for native TLS; the Win32 Workbench is omitted.
Offline tools, TLS, and bounded concurrent server/client operation are validated
on Linux. The portable gate runs consecutive multi-client waves to exercise
parallel dispatch, connection cleanup, and reuse of the worker pool. Windows
remains the packaged binary-distribution target. See
[known limitations](LIMITATIONS.md) and the dated
[Windows/Linux performance report](../../tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md)
before deploying Linux builds.

Start with the [client/server quickstart](../quickstart-client-server.md).
Java applications should also read the [JDBC driver guide](JDBC.md).
Python 3.11 or newer is recommended when replication or the development tooling
is used.

Source builds require MiniLangCompilerPy or MiniLangCompilerML 1.1.0 or newer.
Both compilers provide the CPU-dispatched native CRC-32C primitive, SIMD
string/byte built-ins, conditional target compilation, and portable native
services used by the current MiniSQL sources.

## Validation status

The current tree was validated on 2026-08-26. The Windows x64 gate passed all
106 cumulative phases. The focused Linux x64 gate built every public CLI and
passed storage, offline-tool, authentication, scheduler, native-TLS, and two-wave
concurrent-client checks under WSL2. The Linux gate is intentionally smaller
than the Windows release matrix and does not include the Win32 Workbench,
Windows crash injection, or deterministic Windows packaging.

Run the same public entry point for either target:

```powershell
.\test.ps1 -Compiler C:\path\to\MiniLangCompilerPy\mlc_win64.py -Target windows-x64
.\test.ps1 -Compiler C:\path\to\MiniLangCompilerPy\mlc_win64.py -Target linux-x64
```

Use `.\test.ps1 -StaticOnly` for the source, documentation, format-vector, and
repository-hygiene gate. Performance claims, raw-report hashes, methodology,
and WSL2 caveats are documented in the
[Windows/Linux comparison](../../tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md).
