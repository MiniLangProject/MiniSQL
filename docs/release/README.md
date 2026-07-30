# MiniSQL 1.0.0

MiniSQL is a native Windows x64 relational database management system written in
MiniLang. The distribution contains:

* `minisqld.exe` – database creation and server;
* `minisql.exe` – console, script and one-shot client;
* `minisql-check.exe` – offline consistency checker;
* `minisql-backup.exe` – backup, PITR and standby tools;
* `minisql-migrate.exe` – offline page-size rewrite;
* Python sidecars for TLS 1.3/X.509 and continuous hot replication.

Start with `docs/QUICKSTART.md`. MiniSQL 1.0 targets Windows x64. Python 3.11 or
newer is recommended when sidecars are used.
