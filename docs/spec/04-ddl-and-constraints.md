# 4. DDL and constraints

## 4.1 Commands

Initial database-level commands:

```sql
CREATE DATABASE name [WITH (...)];
DROP DATABASE name;
```

Initial transactional in-database DDL:

```sql
CREATE TABLE name (...);
ALTER TABLE name ...;
DROP TABLE name;
TRUNCATE TABLE name;
CREATE [UNIQUE] INDEX name ON table (column_or_expression [, ...])
  [INCLUDE (...)] [WHERE deterministic_row_predicate];
DROP INDEX name;
ANALYZE [table];
```

DDL inside a database MUST use the same transaction, WAL, catalog and recovery
machinery as DML.

## 4.2 Constraints

- `NOT NULL`
- `DEFAULT`
- `CHECK`
- `UNIQUE`
- `PRIMARY KEY`
- `FOREIGN KEY`
- `GENERATED ... AS IDENTITY`

A primary key implies unique and not-null semantics. Primary and unique constraints
create supporting B+ tree indexes. A foreign key targets a primary or unique key
with compatible column count and types.

Initial referential actions:

- `NO ACTION`
- `RESTRICT`
- `CASCADE`
- `SET NULL`

Constraints are initially immediate. Deferrable constraints are a later feature.
For `CHECK`, FALSE violates the constraint; TRUE and UNKNOWN pass, consistent with
SQL NULL semantics.
