# MiniSQL 1.0 SQL reference

## DDL

Supported statements include `CREATE/DROP TABLE`, `CREATE/DROP INDEX`,
`ALTER TABLE` for compatible schema evolution, `CREATE/DROP SCHEMA`,
`CREATE/DROP VIEW`, `CREATE/DROP SEQUENCE`, `CREATE/DROP TRIGGER`,
`ALTER TRIGGER ... ENABLE|DISABLE`, `CREATE/DROP PROCEDURE`, `TRUNCATE`,
`VACUUM`, `REINDEX` and `ANALYZE`.

`ALTER TABLE` supports adding columns and constraints, dropping constraints,
renaming tables and columns, dropping an unreferenced column from an empty
table, and changing a column's default or `NOT NULL` property. `DROP INDEX [IF
EXISTS] name` removes an explicit index; constraint-owned indexes must be
removed through their constraint.

Explicit indexes support non-key covering columns and an optional row
predicate:

```sql
CREATE [UNIQUE] INDEX index_name ON table_name(key_column_or_expression [, ...])
  [INCLUDE (payload_column [, ...])]
  [WHERE deterministic_row_predicate];
```

INCLUDE columns do not participate in key ordering or uniqueness. They are
stored in B+ tree leaves and may satisfy projections, filters, grouping, and
ordering without a heap lookup when every referenced value is decodable from
the index. Key and INCLUDE column lists may not overlap.

A partial index stores only rows for which its `WHERE` predicate evaluates to
`TRUE`; `FALSE` and `NULL` are omitted. Predicates are Boolean, deterministic,
table-local combinations of columns, literals, unary/binary operators and `IS
NULL`; functions, aggregates, windows and subqueries are rejected. A partial
`UNIQUE` index enforces uniqueness only among qualifying rows. It cannot be
inferred by the current `ON CONFLICT(column)` syntax or used as a foreign-key
target. The optimizer uses a partial index only when every predicate conjunct
is identical to a typed single-table query conjunct or follows from a stronger
typed equality/range bound on the same column and literal domain.

A functional index accepts one deterministic row-local scalar expression:

```sql
CREATE INDEX idx_customer_lower_email ON customer(LOWER(email));
CREATE UNIQUE INDEX ux_customer_normalized_email
  ON customer(LOWER(TRIM(email))) WHERE active = TRUE;
```

Supported trees use columns, deterministic scalar functions, casts, literals
inside a row-dependent expression, and unary/binary operators. Aggregate,
window, subquery, parameter, constant-only, and mixed expression/composite keys
are rejected. Access requires the same typed expression compared with a
literal. Functional scans currently fetch matching heap rows. Before catalog
persistence, MiniSQL formats, reparses, and rebinds the expression; identifiers
whose meaning depends on SQL quoting are rejected rather than stored ambiguously.

Column features include SQL NULL, defaults, `NOT NULL`, `CHECK`, primary and
unique keys, foreign keys, stored generated columns, identity columns and the
`AUTO_INCREMENT`/`AUTOINCREMENT` compatibility aliases.

## DML and queries

`INSERT`, `INSERT ... SELECT`, `UPDATE`, `DELETE`, `MERGE`, `RETURNING`, `ON
CONFLICT DO NOTHING`, UPSERT, joins including full outer joins, grouping,
aggregates, set operations, derived tables, correlated subqueries, views,
recursive CTEs and window functions are supported.

Table aliases accept both `FROM customer c` and `FROM customer AS c`.
Comma-separated sources are the legacy spelling of a cartesian product, so
`FROM customers c, orders o WHERE o.customer_id = c.id` has the same result
semantics as an explicit cross join followed by the same `WHERE` predicate. A
typed column equality connecting the new source to an earlier source is
promoted to the normal costed inner/hash/index-join path. That guaranteed
equality is removed from the residual filter; all other `WHERE` conjuncts
remain unchanged.

Derived tables require an alias. Scalar, `EXISTS`, `IN` and `NOT IN` subqueries
may use explicitly qualified outer references. Recursive CTEs use an anchor
followed by `UNION` or `UNION ALL` and a recursive term. `UNION` terminates at a
deduplicated fixpoint; runaway recursion is diagnosed after 10,000 iterations.

Scalar functions include `LOWER`, `UPPER`, `LENGTH`, `CHAR_LENGTH`,
`SUBSTRING`, `TRIM`, `REPLACE`, `CONCAT`, `ABS`, `ROUND`, `CEIL`, `FLOOR`,
`POWER` and `DATE_PART`. Aggregates also include `STRING_AGG`, `BOOL_AND` and
`BOOL_OR`. Window functions include aggregate windows, `ROW_NUMBER`, `RANK`,
`DENSE_RANK`, `PERCENT_RANK`, `CUME_DIST`, `NTILE`, `LAG`, `LEAD`,
`FIRST_VALUE`, `LAST_VALUE` and `NTH_VALUE`.

The core `MERGE` form accepts one source table, a match predicate, one matched
`UPDATE` or `DELETE` action and one not-matched `INSERT` action. All actions run
in one database transaction and use the ordinary constraint, index and trigger
paths.

## Query planning and diagnostics

`ANALYZE [table]` refreshes exact row/page counts, bounded sampled column
histograms/most-common values, and joint distinct counts for composite index
keys. `EXPLAIN SELECT ...` returns the chosen executable operator tree.
`EXPLAIN ANALYZE SELECT ...` executes it and appends elapsed milliseconds,
buffer-cache hit/read deltas, and actual row count. Plans may contain
`Index Scan`, `Index Only Scan`, `Dynamic Join Order`, `Hash Join`, `Index Nested Loop Join`, `Streaming Aggregate`,
`Streaming Join Count`, `Count Slots`, `Top-N`, or `External Merge Sort` operators.

`SHOW INDEXES FROM table_name` returns `index_name`, `index_kind`, `unique`,
`columns`, `included_columns`, and `predicate`. `predicate` is empty for a full
index.

`SHOW STATUS` returns process-local operational counters and configured hard
limits as `variable_name` / `value` rows. `SHOW PROCESSLIST` returns one row per
active session with principal, peer, TLS state, current state and bounded SQL
summary. Authenticated users require database `ADMIN` for both statements.

`SHUTDOWN` is an administrative statement that acknowledges the request and
cooperatively drains the listener. It requires database `ADMIN` outside trusted
local mode.

## Schemas and metadata

Two-part `schema.object` names are supported for database objects. `public` and
`information_schema` always exist. `DROP SCHEMA` has restrictive semantics and
rejects non-empty schemas. The virtual metadata relations are
`information_schema.schemata`, `tables`, `columns`, `table_constraints`,
`views`, and `routines`.

## Triggers and procedures

Row triggers support `BEFORE` and `AFTER` timing for `INSERT`, `UPDATE [OF
column]` and `DELETE`, plus durable enable/disable state. `OLD` and `NEW` are
read-only row images. A trigger body is one `VALUES`-based `INSERT`, `UPDATE` or
`DELETE` without `RETURNING` or `ON CONFLICT`.

Stored procedures use typed positional input parameters and one persisted DML
body:

```sql
CREATE [OR REPLACE] PROCEDURE name(p_id INTEGER, p_name VARCHAR(80))
AS INSERT INTO item(id, name) VALUES (p_id, p_name);
CALL name(1, 'example');
DROP PROCEDURE [IF EXISTS] name;
```

Declared parameter types are durably stored and enforced by `CALL`. Procedure
DDL is autocommit-only.

## Transactions

`BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `ROLLBACK TO` and `RELEASE` are
supported. Autocommit is enabled when no explicit transaction is active.

## Numeric input

SQL uses a dot as decimal separator: `3.3`, `-4.75`, `1.25e2`.
`DECIMAL(p,s)` is exact and refuses silent rounding.

## Deliberate limits

Three-part catalog names, schema search paths, explicit window-frame syntax,
unqualified outer references, multi-statement procedural programs and
user-defined functions are not supported. Correlated subqueries are limited to
non-grouped outer projection/filter/order expressions and are not accepted in
join predicates or aggregate/window queries.
