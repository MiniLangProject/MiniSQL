# Views and subqueries

M43 defines the following SQL additions.

## Views

```sql
CREATE VIEW name AS select_statement;
CREATE OR REPLACE VIEW name AS select_statement;
DROP VIEW [IF EXISTS] name;
```

A view stores canonical SQL plus its output column names in the schema-extension
catalog. It is rebound against the current catalog when referenced. A view MUST
NOT silently shadow a physical table with the same name. M43 view DDL is
autocommit-only.

## Subqueries

M43 supports:

```sql
SELECT (SELECT value FROM t WHERE id = 1);
SELECT EXISTS (SELECT 1 FROM t WHERE predicate);
value [NOT] IN (SELECT candidate FROM t);
```

Scalar subqueries MUST return exactly one column, MUST fail if they produce more
than one row, and yield SQL `NULL` for zero rows. `IN` and `NOT IN` preserve SQL
three-valued semantics, including `NULL` values in the candidate result.

Post-1.0 execution supports derived tables and correlated scalar, `EXISTS`,
`IN`, and `NOT IN` subqueries. A derived table requires an alias. Correlation
uses explicitly qualified outer references; an inner alias or local table name
shadows the same outer qualifier. Correlated expressions are evaluated per
outer row and are currently limited to non-grouped outer projection, filter,
and ordering expressions.

## Missing-view error contract

After `DROP VIEW` succeeds, the removed name is no longer a relation. A later
query that references it MUST return `ObjectNotFound` (`9014`), the same error
used for a missing physical table. `BindingError` (`9020`) is reserved for
semantic binding failures involving an otherwise resolvable statement/object.
