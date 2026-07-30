# 18. Write-ahead log and transaction core

## 18.1 Scope

M6 provides the first durable transaction substrate. It does not yet expose SQL
transactions, MVCC or fine-grained row locks.

## 18.2 WAL record v1

Records MUST be append-only and MUST contain an 80-byte little-endian header followed by
the payload. Header and payload MUST have independent CRC-32C values. The record LSN is its
byte offset in the logical WAL stream. Supported record kinds are `TX_BEGIN`, `PAGE_IMAGE`,
`TX_COMMIT`, `TX_ABORT`, `CHECKPOINT_BEGIN`, and `CHECKPOINT_END`.

A `PAGE_IMAGE` payload MUST be one complete, valid MiniSQL page. Its file ID, page number
and `pageLSN` MUST agree with the WAL header. Unknown versions, non-zero reserved fields,
inconsistent lengths or failed checksums MUST be rejected.

The configured segment size defines logical segment number and segment-relative offset.
M6 stores logical segments in one physical durable file. Physical segment rotation is not
claimed by this milestone and may be added without changing record v1.

## 18.3 Append and invalid tail

The writer MUST append records at `nextLsn`. Opening an existing WAL MUST scan its valid
prefix. A final partial record caused by process termination MAY be truncated to the last
validated byte. Corruption within a complete record or before the final incomplete record
MUST be treated as fatal rather than silently skipped.

## 18.4 Transaction-private page images

A write transaction owns private page copies. Staging the same `(fileId,pageNumber)` more
than once replaces its previous private image. Uncommitted pages MUST NOT be written to base
paged files. A read-only transaction MUST reject page staging.

The state machine is `ACTIVE -> COMMITTING -> COMMITTED` or
`ACTIVE/FAILED -> ABORTED`. A transaction in `FAILED` MUST NOT be committed again.

## 18.5 Commit ordering

A successful commit MUST perform, in order:

1. append `TX_BEGIN`;
2. append every private full-page image;
3. append `TX_COMMIT`;
4. durably flush the WAL through the commit record;
5. mark the transaction committed and retain its page batch for normal publication;
6. only then report success.

A client-visible success before step 4 is forbidden. Failed writes or flushes MUST NOT be
reported as a commit. If normal page publication is interrupted after acknowledgement, M7
recovery restores the committed pages from WAL.

## 18.6 Rollback and locks

Rollback discards all private page images. If a begin record was written, the engine SHOULD
append and flush `TX_ABORT`; rollback correctness does not depend on the abort record because
NO-STEAL prevents uncommitted base-page publication.

M6 uses a conservative database-level lock manager. Multiple readers MAY coexist. Exactly
one writer MAY exist, and a reader may upgrade only when it is the sole reader. Finer lock
granularity and MVCC are later milestones.
