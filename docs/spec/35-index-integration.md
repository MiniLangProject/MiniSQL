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

Explicit `CREATE [UNIQUE] INDEX ... INCLUDE (...)` definitions persist ordered
non-key columns in each leaf entry. The key alone controls ordering and unique
enforcement. A covering plan may reconstruct a table-width typed row from both
the key and payload and skip heap/overflow access. DML maintenance, startup
repair, `REINDEX`, `VACUUM`, and the consistency checker compare the complete
leaf value so stale payload data cannot remain valid silently.

Explicit `CREATE [UNIQUE] INDEX ... WHERE predicate` definitions are partial
indexes. Construction, INSERT delta maintenance, UPDATE/DELETE rebuilds,
startup repair, `REINDEX`, `VACUUM`, and streaming verification evaluate the
same persisted canonical predicate with SQL WHERE semantics: only `TRUE` rows
have leaf entries. Partial UNIQUE checks compare qualifying rows only. Partial
predicates may use deterministic bound base-expression nodes and may be
combined with INCLUDE columns.

The optimizer proves eligibility conservatively. For a single-table plan, each
typed conjunct of the persisted index predicate must be binding-identical to a
query conjunct or follow from a stronger equality/range bound on the same
column. Strict/inclusive boundaries are compared explicitly; a comparison also
proves `IS NOT NULL` for its column. Additional and reordered query conjuncts
are allowed. IEEE floating-point bounds are excluded because NaN is not totally
ordered. Partial indexes are not selected for joins or legacy unnamed
lookup paths. This bounded contract prefers a heap plan over any access path
that could omit a legal row.

One explicit index key may instead be a deterministic row-local expression.
Canonical SQL is stored with a reserved marker inside the existing key array,
preserving schema-history format 1 and byte-identical metadata for ordinary
indexes. Construction and every mutation, recovery, and maintenance path bind
the expression once per operation and evaluate it against complete typed rows.
UNIQUE compares computed non-NULL keys; a partial functional index applies its
predicate before key insertion.

Planning requires an identical typed expression on one side of an equality or
range comparison with a literal. The B+ tree probe returns heap references;
expression statistics, functional joins, composite expression keys, and
expression-aware index-only reconstruction are deferred. Rename and DROP
COLUMN dependency analysis recursively traverses functions, casts, unary, and
binary nodes.

`EXPLAIN` reports `Index Seek rows=N` when the supported access path is chosen
and `Index Only Scan` when no heap fetch is required.
The consistency checker compares each derived tree with the logical heap rows.

Explicit indexes may be removed with `DROP INDEX [IF EXISTS] name`. The binder
resolves the database-wide index name to its owning table, and DDL publication
removes both catalog metadata and the derived file atomically. Indexes owned by
PRIMARY KEY or UNIQUE constraints must be removed by dropping that constraint.
