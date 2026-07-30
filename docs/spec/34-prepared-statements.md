# Prepared statements and positional parameters — M22

## Scope

MiniSQL supports session-local prepared DML and SELECT statements:

```sql
PREPARE find_item AS SELECT * FROM item WHERE id = ?;
EXECUTE find_item USING 42;
DEALLOCATE PREPARE find_item;
```

`PREPARE` accepts `SELECT`, `INSERT`, `UPDATE`, and `DELETE`. Parameter markers
are numbered left-to-right from zero in the AST. `EXECUTE ... USING` MUST supply
exactly the declared count. Arguments MUST be constant SQL expressions and are
substituted as AST values, never concatenated into SQL text.

Prepared statements belong to one `Engine`/session and disappear on close. A
name MUST be unique in that session. DDL generation changes do not retain a
stale bound plan: MiniSQL retains the parsed AST and binds it again against the
current catalog at execution time. This is parse-once, bind/plan-on-execute;
a reusable physical plan cache is deliberately deferred.

Authorization is performed on the expanded statement at each execution, so
preparing a statement does not confer privileges.
