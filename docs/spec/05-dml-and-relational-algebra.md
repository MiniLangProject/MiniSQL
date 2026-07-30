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

MiniSQL SQL 1.0 targets projections, aliases, WHERE, INNER/LEFT/CROSS JOIN,
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
7. batch-oriented execution

Logical operators include table scan, selection, projection, join, aggregate,
distinct, sort, limit and set operation.

Physical operators initially include sequential scan, index seek/range scan,
nested-loop join, index nested-loop join, hash join, hash/sort aggregate, in-memory
sort and external merge sort.

## 5.4 Performance rules

The executor SHOULD process reusable row batches rather than allocate one MiniLang
object per cell. The optimizer SHOULD support predicate pushdown, projection pruning,
constant folding and statistics-based scan/join selection. `EXPLAIN` and
`EXPLAIN ANALYZE` MUST expose chosen plans.
