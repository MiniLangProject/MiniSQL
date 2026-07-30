# MiniSQL 1.0 SQL reference

## DDL

Supported statements include `CREATE/DROP TABLE`, `CREATE/DROP INDEX`,
`ALTER TABLE` for compatible schema evolution, `CREATE/DROP VIEW`,
`CREATE/DROP SEQUENCE`, `CREATE/DROP TRIGGER`, `TRUNCATE`, `VACUUM`, `REINDEX`
and `ANALYZE`.

Column features include SQL NULL, defaults, `NOT NULL`, `CHECK`, primary and
unique keys, foreign keys, stored generated columns, identity columns and the
`AUTO_INCREMENT`/`AUTOINCREMENT` compatibility aliases.

## DML and queries

`INSERT`, `INSERT ... SELECT`, `UPDATE`, `DELETE`, `RETURNING`, `ON CONFLICT DO
NOTHING`, UPSERT, joins including full outer joins, grouping, aggregates, set
operations, non-correlated subqueries, views, nonrecursive CTEs and the documented
window functions are supported.

## Transactions

`BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `ROLLBACK TO` and `RELEASE` are
supported. Autocommit is enabled when no explicit transaction is active.

## Numeric input

SQL uses a dot as decimal separator: `3.3`, `-4.75`, `1.25e2`.
`DECIMAL(p,s)` is exact and refuses silent rounding.

## Deliberate limits

Recursive CTEs, correlated subqueries, arbitrary trigger programs, stored
procedures and user-defined functions are outside MiniSQL 1.0.
