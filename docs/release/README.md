# MiniSQL 1.0.0

MiniSQL is a native Windows x64 and Linux x64 relational database management
system written in MiniLang. The Windows distribution contains:

* `minisqld.exe` – database creation and server;
* `minisql.exe` – console, script and one-shot client;
* `minisql-check.exe` – offline consistency checker;
* `minisql-backup.exe` – backup, PITR and standby tools;
* `minisql-migrate.exe` – offline page-size rewrite;
* `minisql-admin.exe` – native Windows MiniSQL Workbench;
* native Windows Schannel TLS 1.3/X.509 transport;
* a Python sidecar for continuous hot replication.

Linux source builds provide the same five command-line applications without an
`.exe` suffix and use OpenSSL 3 for native TLS; the Win32 Workbench is omitted.
Offline tools and single-client server/client operation are validated on Linux.
The Linux server is not yet supported for concurrent production traffic because
tests with two or more simultaneous clients can fail or stall. Windows remains
the fully accepted concurrent-server and binary-distribution target. See
[known limitations](LIMITATIONS.md) and the dated
[Windows/Linux performance report](../../tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md)
before deploying Linux builds.

Start with the [client/server quickstart](../quickstart-client-server.md).
Python 3.11 or newer is recommended when replication or the development tooling
is used.

Source builds require MiniLangCompilerPy or MiniLangCompilerML 1.1.0 or newer.
Both compilers provide the CPU-dispatched native CRC-32C primitive, SIMD
string/byte built-ins, conditional target compilation, and portable native
services used by the current MiniSQL sources.
