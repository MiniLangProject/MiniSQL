# ON CONFLICT DO UPDATE

Syntax:

```sql
INSERT ... ON CONFLICT (column-list)
DO UPDATE SET column = expression [, ...]
[WHERE predicate]
[RETURNING ...]
```

A target is mandatory. Unqualified columns in SET/WHERE refer to the existing
target row. `excluded.column` refers to the proposed insert row. All assignment
expressions observe the same original target/excluded pair. The final row MUST
pass every constraint before it is staged. A false/unknown WHERE predicate
performs no update and returns no row.
