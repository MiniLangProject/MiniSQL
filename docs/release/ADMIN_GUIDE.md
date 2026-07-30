# MiniSQL 1.0 administrator guide

Create a database with `minisqld.exe --init <root> <name> [page-size]`. Start a
loopback server with `--serve`, an authenticated server with
`--serve-authenticated`, or a read-only standby with `--serve-standby`.

Format-relevant settings are copied into `db.meta` when a database is created.
Changing global defaults never changes an existing database. A page-size change
requires `minisql-migrate.exe --rewrite`.

Run `minisql-check.exe <database>` after abnormal storage events and before
publishing a restored or migrated database. Schedule verified backups and test
restores regularly.
