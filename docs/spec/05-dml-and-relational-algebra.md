# 5. DML and relational algebra

## 5.1 Commands

```sql
SELECT ...;
INSERT INTO ...;
UPDATE ...;
DELETE FROM ...;
VALUES (...);
```

## 5.2 SELECT target

MiniSQL SQL 1.0 targets projections, optional `AS` table aliases, legacy
comma-separated FROM lists, WHERE, INNER/LEFT/CROSS JOIN,
GROUP BY, HAVING, DISTINCT, ORDER BY, LIMIT/OFFSET, FETCH FIRST, CASE, CAST,
LIKE, IN, BETWEEN and the aggregates COUNT/SUM/AVG/MIN/MAX.

Set operations, subqueries, CTEs and window functions follow after the core query
pipeline is stable.

## 5.3 Pipeline

SQL text MUST pass through distinct stages:

1. lexer
2. parser and AST
3. name binding and type checking
4. logical relational plan
5. logical rewrites
6. physical plan selection
7. hybrid batch/stream and blocking execution

Logical operators include table scan, selection, projection, join, aggregate,
distinct, sort, limit and set operation.

Physical operators initially include sequential scan, index seek/range scan,
nested-loop join, index nested-loop join, hash join, hash/sort aggregate, in-memory
sort and external merge sort.

## 5.4 Performance rules

Non-blocking single-table scans MUST use bounded row batches; blocking operators
may materialize their input when required by SQL semantics. The optimizer MUST
support safe predicate pushdown, projection pruning, constant folding and
statistics-based scan/join selection. `EXPLAIN` and `EXPLAIN ANALYZE` MUST expose
the same typed plan consumed by execution. Eligible scalar aggregates and small
single-table Top-N windows SHOULD fuse with their scan; a join aggregate MAY
consume final-edge match counts without constructing final joined rows.
