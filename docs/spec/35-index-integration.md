# Index integration — M23

All primary-key, unique, and explicit index definitions have durable B+ tree
files. Indexes are derived structures: the heap and committed WAL are the source
of truth.

For every heap-changing commit MiniSQL MUST:

1. durably create `catalog/indexes.dirty` before publishing heap changes;
2. commit and publish the heap/WAL transaction;
3. rebuild affected indexes from committed heap rows;
4. verify/publicly use them only after successful publication;
5. remove the dirty marker only after success.

A failed rebuild MUST NOT roll back an already durable heap commit. The marker
causes repair before subsequent index use or on database attach/open.

Supported access paths are equality seeks and ordered ranges for single-column
indexes, complete-key equality seeks for compound indexes, plus index
nested-loop lookup for equality joins. Partial compound-key prefix planning is
deferred. Floating-point range
predicates deliberately use heap scans until a canonical sortable IEEE-754 key
encoding exists. Unique constraints continue to allow multiple SQL NULL values.

`EXPLAIN` reports `Index Seek rows=N` when the supported access path is chosen.
The consistency checker compares each derived tree with the logical heap rows.

Explicit indexes may be removed with `DROP INDEX [IF EXISTS] name`. The binder
resolves the database-wide index name to its owning table, and DDL publication
removes both catalog metadata and the derived file atomically. Indexes owned by
PRIMARY KEY or UNIQUE constraints must be removed by dropping that constraint.
