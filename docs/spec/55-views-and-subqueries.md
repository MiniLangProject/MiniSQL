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

Subqueries are non-correlated. A scalar subquery MUST return exactly one column,
MUST fail if it produces more than one row, and yields SQL `NULL` for zero rows.
`IN` and `NOT IN` preserve SQL three-valued semantics, including `NULL` values in
the candidate result.

## Missing-view error contract

After `DROP VIEW` succeeds, the removed name is no longer a relation. A later
query that references it MUST return `ObjectNotFound` (`9014`), the same error
used for a missing physical table. `BindingError` (`9020`) is reserved for
semantic binding failures involving an otherwise resolvable statement/object.

