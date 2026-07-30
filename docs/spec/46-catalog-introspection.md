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
index_name, index_kind, unique, columns
```

The statements acquire a read lease. Authenticated users may list table names;
`DESCRIBE` and `SHOW INDEXES` require `SELECT` on the target table. Unknown
objects fail explicitly instead of producing an empty result.
