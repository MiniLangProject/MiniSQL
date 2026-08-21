# Common table expressions and window functions

M44 introduced materialized, nonrecursive CTEs:

```sql
WITH first AS (...), second AS (... FROM first ...)
SELECT ... FROM second;
```

CTE names are scoped to one statement and later CTEs may reference earlier ones.
Post-1.0 `WITH RECURSIVE` accepts an anchor `UNION`/`UNION ALL` recursive term.
The executor uses delta working rows; `UNION` deduplicates against all rows
already seen while `UNION ALL` preserves bag semantics. A 10,000-iteration
guard converts runaway recursion into an explicit error.

Supported window functions are `ROW_NUMBER`, `RANK`, `DENSE_RANK`,
`PERCENT_RANK`, `CUME_DIST`, `NTILE`, `LAG`, `LEAD`, `FIRST_VALUE`,
`LAST_VALUE`, `NTH_VALUE`, `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`:

```sql
function(args) OVER (
  [PARTITION BY expression, ...]
  [ORDER BY expression [ASC|DESC], ...]
)
```

MiniSQL uses the complete partition as the frame. Explicit `ROWS`, `RANGE`, `GROUPS`,
frame bounds, named windows, and window functions nested inside arbitrary scalar
expressions are not supported.
