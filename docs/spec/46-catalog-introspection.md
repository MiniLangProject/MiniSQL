# Catalog introspection specification

M34 adds read-only SQL metadata statements:

```sql
SHOW TABLES;
DESCRIBE table_name;
SHOW INDEXES FROM table_name;
SHOW INDEXES ON table_name;
```

## Result schemas

`SHOW TABLES` returns:

```text
table_name, column_count, schema_version
```

`DESCRIBE` returns one row per column:

```text
ordinal, column_name, data_type, nullable, default_sql, identity
```

`SHOW INDEXES` returns physical indexes represented by schema-history
constraints:

```text
index_name, index_kind, unique, columns, included_columns
```

`columns` lists ordered B+ tree key columns; `included_columns` lists ordered
non-key leaf payload columns and is empty for ordinary and constraint-owned
indexes.

The statements acquire a read lease. Authenticated users may list table names;
`DESCRIBE` and `SHOW INDEXES` require `SELECT` on the target table. Unknown
objects fail explicitly instead of producing an empty result.

Post-1.0 schema support adds durable `CREATE SCHEMA [IF NOT EXISTS]` and
restrictive `DROP SCHEMA [IF EXISTS] [RESTRICT]`, two-part `schema.object`
names, and the following read-only virtual relations:

```text
information_schema.schemata
information_schema.tables
information_schema.columns
information_schema.table_constraints
information_schema.views
information_schema.routines
```

The virtual rows are generated from the same live catalog and schema-extension
snapshot used by execution, so they cannot drift from persisted database state.
