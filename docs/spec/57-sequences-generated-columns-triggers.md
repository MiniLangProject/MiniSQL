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
CREATE TRIGGER name BEFORE|AFTER INSERT|UPDATE [OF column]|DELETE
ON table FOR EACH ROW dml_statement;
ALTER TRIGGER name ENABLE|DISABLE;
DROP TRIGGER [IF EXISTS] name;
```

The body is exactly one supported INSERT, UPDATE, or DELETE statement.
`OLD.column` and `NEW.column` are replaced with typed, read-only row values for
each affected row. BEFORE bodies are ordered ahead of AFTER bodies inside the
same page/WAL transaction; the base DML has already computed and validated the
row images, so triggers cannot rewrite `NEW`. Trigger recursion is limited to
eight levels. Enable state is durable. Trigger and sequence DDL is
autocommit-only.

## MERGE and stored procedures

The core `MERGE` form uses one table source and supports matched UPDATE or
DELETE plus not-matched INSERT in one transaction. Each generated action uses
the ordinary DML constraint, index, WAL, and trigger path.

Typed, positional stored-procedure inputs are supported for one persisted
VALUES INSERT, UPDATE, or DELETE body. `CREATE OR REPLACE PROCEDURE`, `CALL`,
`DROP PROCEDURE`, schema-qualified procedure names, durable parameter type
validation, and `information_schema.routines` are supported. Multi-statement
bodies and procedural control flow are intentionally outside this contract.
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
