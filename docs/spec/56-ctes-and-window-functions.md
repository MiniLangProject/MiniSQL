# Common table expressions and window functions

M44 supports materialized, nonrecursive CTEs:

```sql
WITH first AS (...), second AS (... FROM first ...)
SELECT ... FROM second;
```

CTE names are scoped to one statement and later CTEs may reference earlier ones.
`WITH RECURSIVE` MUST fail closed.

Supported window functions are `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `COUNT`,
`SUM`, `AVG`, `MIN`, and `MAX`:

```sql
function(args) OVER (
  [PARTITION BY expression, ...]
  [ORDER BY expression [ASC|DESC], ...]
)
```

M44 uses the complete partition as the frame. Explicit `ROWS`, `RANGE`, `GROUPS`,
frame bounds, named windows, and window functions nested inside arbitrary scalar
expressions are outside this milestone.
