# 27. Basic SQL execution

M15 executes a bound single-table plan:

```text
scan -> filter -> projection -> distinct -> sort -> offset/limit
```

INSERT/UPDATE/DELETE stage complete heap-page images in an M6 transaction. Commit first
appends and durably flushes WAL, then publishes data pages with the commit LSN. The
committed private page batch is acknowledged only after every affected base file has
been flushed; a failed publication remains redoable and retryable.

Autocommit wraps each DML statement in SERIALIZABLE. Explicit transactions provide
read-your-writes, COMMIT and ROLLBACK; an error marks the transaction failed until
ROLLBACK. DDL and DML cannot yet be mixed in one explicit transaction. Immediate
constraints are evaluated by visible-row scans in M15; physical index maintenance and
index-backed plans are integrated with the optimizer in M17.
