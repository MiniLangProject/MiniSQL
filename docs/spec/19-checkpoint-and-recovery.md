# 19. Checkpoint and recovery

## 19.1 Checkpoint metadata

Checkpoint metadata uses two fixed 256-byte slots in one 512-byte file. Each slot stores
magic, version, generation, checkpoint LSN, redo-start LSN, WAL record count, database UUID
and CRC-32C. The inactive slot MUST be written and durably flushed before it becomes current.

The valid slot with the highest generation is selected. If the newest slot is damaged, the
previous valid generation is used. Slots with different database UUIDs, or equal generations
with divergent metadata, MUST be rejected. `redoStartLsn` MUST NOT exceed `checkpointLsn`.

## 19.2 Analysis

Recovery scans the valid WAL prefix and groups records by transaction ID. A transaction is
redo-eligible only if it has a valid begin and commit record and no later abort. Page images
from incomplete or aborted transactions MUST be ignored.

## 19.3 Redo

M7 performs full-page redo. A target is identified by file ID. Before applying a page image,
its page identity and checksum are verified. The image is applied only when its WAL pageLSN
is newer than the current pageLSN. This rule makes redo idempotent.

Redo may overwrite an existing page or append exactly the next page. Gaps, missing target
files and inconsistent identities MUST fail recovery.

## 19.4 Durability outcomes

After a process or operating-system restart:

- a transaction without a durably readable commit record MUST be invisible;
- a transaction with a durably readable commit record MUST be completely recoverable;
- no subset of a committed transaction may be exposed as the final recovered state; and
- recovery MUST be safely repeatable.

M7 validates process termination after both committed and uncommitted WAL
sequences. Full power-loss guarantees still depend on the host operating system,
filesystem, and storage hardware honoring the native flush requests (`FlushFileBuffers`
on Windows and `fsync` on Linux).
