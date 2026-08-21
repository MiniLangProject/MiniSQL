# ALTER TABLE and schema evolution — M24

Supported syntax:

```sql
ALTER TABLE t ADD [COLUMN] c INTEGER DEFAULT 0;
ALTER TABLE t ADD CONSTRAINT uq_t_c UNIQUE (c);
ALTER TABLE t DROP CONSTRAINT uq_t_c;
ALTER TABLE t RENAME COLUMN c TO value;
ALTER TABLE t RENAME TO renamed_t;
ALTER TABLE t ALTER COLUMN value SET DEFAULT 1;
ALTER TABLE t ALTER COLUMN value DROP DEFAULT;
ALTER TABLE t ALTER COLUMN value SET NOT NULL;
ALTER TABLE t ALTER COLUMN value DROP NOT NULL;
ALTER TABLE empty_t DROP COLUMN obsolete;
```

All operations use the accepted transactional DDL before-image journal. They
are committed atomically with catalog and schema-history publication; explicit
DDL transactions may be rolled back.

`ADD COLUMN` is metadata-only. Existing rows retain their stored schema version
and column count. On read, missing trailing columns are materialized from the
persisted default expression or SQL NULL. A new NOT NULL column therefore MUST
have a compatible DEFAULT. Identity columns and operations requiring physical
rewrites are rejected in this milestone.

Adding CHECK, PRIMARY KEY, UNIQUE, or FOREIGN KEY constraints validates every
existing visible row before publication. New unique/primary indexes are built
from the heap. Foreign-key targets MUST be a primary or unique key. Renames
preserve object IDs and update catalog/schema references. Dropping an indexed
constraint removes its derived index through the DDL journal.

Changing nullability to `NOT NULL` scans and validates every visible row. The
current `DROP COLUMN` implementation is deliberately conservative: the table
must be empty, at least one column must remain, and the removed column must not
participate in constraints, indexes, triggers, identity ownership, generated
expressions, or other schema dependencies. Type changes and dropping columns
from non-empty tables still require a future copy-and-rewrite operation.
