# ADR-0029: Capture DDL before-images through the lock-owning paged-file handle

## Status

Accepted for M11-M15R1.

## Context

A MiniSQL `PagedFile` acquires an exclusive whole-file `LockFileEx` range and keeps the
native handle open for its lifetime. A database handle therefore already owns locked
handles for `db.meta` and `catalog/catalog.tbl` while transactional DDL is running.

The DDL journal requires byte-exact before-images of both files. Opening either path a
second time is not a valid snapshot mechanism on Windows: an overlapping `ReadFile`
through that second handle fails with `ERROR_LOCK_VIOLATION` (33), even when both
handles belong to the same process.

## Decision

The paged-file layer exposes:

```ml
snapshotDurableBytes(pagedFile, maxBytes)
```

The operation:

1. validates that the supplied `PagedFile` is open;
2. validates a caller-provided safety limit;
3. flushes the existing writable handle;
4. obtains the file size through that same handle;
5. reads the complete file through that same handle;
6. returns a byte-for-byte image without changing handle ownership or lock state.

Transactional DDL uses this operation for `db.meta` and `catalog.tbl`. Path-based
`readWhole(path)` remains valid only for files not already held under an exclusive
MiniSQL paged-file lock, such as the schema sidecar and the startup DDL journal.

## Consequences

- M14 obeys the accepted mandatory-locking model from M3 and M4.
- Before-images represent a flushed durable state.
- No temporary unlock window permits another process to observe or mutate metadata.
- Handle lifetime remains owned by `DatabaseHandle`/`PagedFile`.
- DDL journal v1 and every other persisted format remain unchanged.
- Static and native tests protect the owner-handle snapshot rule.
