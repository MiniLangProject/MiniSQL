# 26. Transactional DDL

M14 stores extended schema metadata in `catalog/schema.history` and coordinates it with
`db.meta`, the bootstrap catalog and physical table/index files through
`catalog/ddl.pending`.

A DDL transaction collects actions, builds an isolated target catalog/schema, records
before-images and all planned temporary/final/backup paths in a checksummed PREPARED
journal, creates new files under temporary names, performs file moves, publishes metadata
and schema, changes the journal to COMMITTED, and finally removes backups/journal.

Startup recovery executes before the catalog opens. PREPARED restores before-images,
removes uncommitted final/temporary files and restores backups. COMMITTED retains the new
schema and only cleans leftovers. This ordering makes CREATE TABLE, CREATE INDEX and DROP
TABLE atomic across multiple files without relying on an unsafe rename-only assumption.

## Lock-owning handle rule

`db.meta` and `catalog/catalog.tbl` are already open under exclusive whole-file
locks while DDL is prepared. Their before-images MUST be obtained with
`paged_file.snapshotDurableBytes` through those existing handles. The DDL layer MUST
NOT reopen either path for reading, because Windows mandatory byte-range locking would
reject the overlapping read with error 33. The snapshot operation flushes before reading
and applies a bounded allocation limit.

