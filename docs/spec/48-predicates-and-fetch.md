# Predicate and row-limiting specification

M36 adds:

```sql
value [NOT] IN (value, ...)
value [NOT] BETWEEN lower AND upper
value NOT LIKE pattern
boolean_value IS [NOT] TRUE
boolean_value IS [NOT] FALSE
boolean_value IS [NOT] UNKNOWN
OFFSET count [ROW|ROWS]
FETCH {FIRST|NEXT} count {ROW|ROWS} ONLY
```

IN, NOT IN, BETWEEN and NOT BETWEEN implement SQL three-valued logic. In
particular, `x NOT IN (..., NULL)` is UNKNOWN when no non-NULL candidate matches.
WHERE retains only TRUE.

Truth tests always return a non-NULL BOOLEAN. `IS UNKNOWN` is true exactly when
the operand evaluates to SQL UNKNOWN/NULL.

OFFSET is applied before FETCH. FETCH maps to the existing physical limit and
cannot be combined with MiniSQL's LIMIT extension in the same SELECT.
Subquery-valued IN remains outside this milestone.
