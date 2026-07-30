# 1. Goals and scope

## 1.1 Product goal

MiniSQL is a native relational DBMS implemented in MiniLang. It provides a
long-running server, a console client, transactional DDL and DML, durable
on-disk storage, relational query processing, indexing, recovery, consistency
checking, backup and later DCL.

## 1.2 Priority order

1. correctness and recoverability
2. no acknowledged transaction loss under the stated durability contract
3. security and strict input validation
4. deterministic behavior and testability
5. performance and controlled memory use
6. increasing concurrency

Performance optimizations MUST NOT weaken correctness without an explicit,
documented non-default mode.

## 1.3 Initial SQL scope

The first functional release implements a documented dialect named
**MiniSQL SQL 1.0**. It is inspired by standard SQL but does not claim complete
ISO SQL conformance.

DDL and DML are implemented before DCL. Until DCL exists, the server MUST bind
to loopback only and MUST reject unauthenticated remote binding.

## 1.4 Process architecture

- `minisqld.exe`: database server
- `minisql.exe`: interactive console client
- `minisql-check.exe`: offline/controlled consistency checker
- `minisql-backup.exe`: backup and restore tool
- `minisql-migrate.exe`: explicit offline physical-format migration

## 1.5 Database layout principle

Every database owns one directory. Tables and indexes have separate files, while
all objects in one database share one transactional WAL so a transaction touching
multiple objects commits atomically.
