# VACUUM and REINDEX — M25

```sql
VACUUM;
VACUUM table_name;
REINDEX;
REINDEX table_or_index;
```

Both commands are autocommit-only maintenance operations and require the
`MAINTAIN` database privilege for authenticated sessions.

VACUUM scans live logical rows, materializes schema defaults, rewrites TEXT/BLOB
overflow chains into a fresh table file, validates/flushes the replacement, and
publishes it by an offline file swap. A CRC-protected maintenance journal has
PREPARED and COMMITTED states:

- PREPARED recovery restores the old generation;
- COMMITTED recovery keeps the replacement and removes obsolete files.

After a table replacement, stale physical WAL page images MUST never be replayed
into the new layout. MiniSQL flushes committed state, resets the WAL/checkpoint
redo horizon, then commits the maintenance journal. The old file already
contains every committed change, so PREPARED rollback remains complete.

REINDEX rebuilds selected or all derived B+ trees. A durable index-dirty marker
makes interrupted work repairable on the next open/use. Maintenance never edits
page size or file-format identity in place.
