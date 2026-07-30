# ON CONFLICT DO NOTHING

Syntax:

```sql
INSERT ... ON CONFLICT [(column-list)] DO NOTHING [RETURNING ...]
```

A supplied target MUST exactly match the ordered columns of a persisted PRIMARY
KEY or UNIQUE constraint. Without a target, any PRIMARY KEY or UNIQUE conflict
MAY suppress the candidate row. NULL-containing unique keys do not conflict.
Violations unrelated to the selected target MUST remain errors.
