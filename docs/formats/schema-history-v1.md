# Schema history format v1

`catalog/schema.history` is a protected envelope containing the database UUID, format
version and an ordered collection of table-schema records. Each record stores table ID,
schema version, column rules (default SQL plus identity flag) and constraints. Constraint
records contain kind, name, local columns, CHECK expression SQL, referenced table/columns,
referential actions and optional index ID/name.

For a foreign key, the referenced-column array retains its original meaning. For an
index-backed local constraint with no referenced table, the same version-1 extension
slot stores ordered `INCLUDE` column names. This kind-discriminated use adds covering
indexes without changing or migrating the schema-history envelope.

The file is rewritten atomically through a temporary file and replace operation. It is
coordinated with catalog and physical files by the DDL journal; it is not independently
considered committed while a PREPARED journal exists.
