# Sequences, generated columns and triggers

## Sequences

```sql
CREATE SEQUENCE name
  [START WITH n] [INCREMENT BY n]
  [MINVALUE n] [MAXVALUE n] [CYCLE];
DROP SEQUENCE [IF EXISTS] name;
SELECT NEXTVAL('name'), CURRVAL('name');
```

`NEXTVAL` durably advances the sequence outside transaction rollback semantics.
`CURRVAL` is session-local and is undefined until that session calls `NEXTVAL`.
M45 sequence parameters are restricted to the native MiniLang integer domain.

## Stored generated columns

```sql
column type GENERATED ALWAYS AS (expression) STORED
```

Generated expressions MUST be deterministic, MUST NOT contain aggregates,
windows, or subqueries, and may reference only earlier ordinary columns.
Explicit INSERT/UPDATE assignment is rejected. Legacy rows created before a
metadata-only `ADD COLUMN` materialize the generated value when read.

## Triggers

```sql
CREATE TRIGGER name AFTER INSERT|UPDATE [OF column]|DELETE
ON table FOR EACH ROW dml_statement;
DROP TRIGGER [IF EXISTS] name;
```

M45 supports `AFTER` row triggers only. The body is exactly one INSERT, UPDATE,
or DELETE statement. `OLD.column` and `NEW.column` are replaced with typed row
values for each affected row. Trigger recursion is limited to eight levels.
Trigger and sequence DDL is autocommit-only.
## Contextual trigger/audit identifiers

`ACTION` is a contextual, non-reserved keyword. It retains its referential-action grammar
meaning in `ON DELETE NO ACTION` and `ON UPDATE NO ACTION`, but is also legal unquoted
where the grammar expects an identifier. Audit tables may therefore use an ordinary
column such as `action VARCHAR(20)` without double quotes.


## `OLD` and `NEW` parser contract

`OLD` and `NEW` are reserved trigger pseudo-row qualifiers. They are legal in trigger-body
expressions only as `OLD.column` and `NEW.column`; they are not general unquoted
identifiers. The parser emits canonical qualified column expressions, and the trigger
executor replaces them with typed row values before binding the body. Referencing an
unavailable pseudo-row for an event is a binding error at trigger execution.
