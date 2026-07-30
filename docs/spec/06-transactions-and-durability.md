# 6. Transactions, isolation and durability

## 6.1 Syntax

```sql
BEGIN [READ ONLY | READ WRITE];
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
COMMIT;
ROLLBACK;
SAVEPOINT name;
ROLLBACK TO SAVEPOINT name;
RELEASE SAVEPOINT name;
```

Autocommit is enabled by default. A statement outside explicit `BEGIN` is one
transaction.

## 6.2 Initial concurrency model

The first correct implementation supports multiple read sessions and at most one
writer per database. Default isolation is SERIALIZABLE through a conservative
read/write locking model. Finer locks and MVCC may replace this after recovery and
correctness are proven.

## 6.3 Transaction state

`IDLE -> ACTIVE -> COMMITTING -> IDLE`, with errors moving an explicit transaction
to `FAILED`. In FAILED state only rollback operations are permitted until the
transaction is recovered or aborted.

## 6.4 WAL protocol

Transactions modify private page images. A commit performs:

1. validate all constraints
2. append all required WAL page records
3. append transaction commit record
4. durably flush WAL through the commit record
5. publish the committed version in memory
6. acknowledge success to the client

MiniSQL MUST NOT report commit success before the required durable flush succeeds.

## 6.5 Rollback model

The initial storage manager is NO-STEAL oriented: uncommitted page images MUST NOT
be written into base table/index files. Rollback discards private images and spill
files. This intentionally simplifies correct undo behavior.

## 6.6 Checkpoint and recovery

Checkpoints write committed pages, flush object files, persist redundant checkpoint
metadata, and only then retire obsolete WAL segments. On startup, recovery validates
records, ignores incomplete tails, identifies committed transactions and idempotently
replays page changes according to page LSN.

## 6.7 Durability contract

After MiniSQL returns `COMMIT OK`, the transaction must survive process termination,
OS restart and sudden power loss, assuming the operating system and storage device
honor the requested flush. Full-device loss requires tested backup or replication.

Checksums detect corruption; they do not substitute for backup.
