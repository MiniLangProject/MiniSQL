# 17. Buffer pool

## 17.1 Capacity and identity

M5 uses a fixed number of page frames. A resident page is identified by the live paged-file handle identity and page number.
A path alone is insufficient because a file can be closed, replaced or reopened while clean
frames still exist. Reopening therefore creates a distinct cache identity and cannot return a
stale path-only frame. The pool MUST never contain more valid frames than its configured
capacity.

## 17.2 Pinning

`pin` returns a `PageGuard` and increments the frame's pin count. The page buffer remains
resident until every guard is released. A released guard MUST NOT be used or released a
second time. Closing or invalidating a file with matching pinned frames MUST fail.

If every frame is pinned, a cache miss MUST return error code 9009 rather than evicting
live data.

## 17.3 CLOCK replacement

Unpinned frames use a CLOCK second-chance policy. A referenced frame first has its
reference bit cleared; a later scan may select it. Pinned frames are skipped.

## 17.4 Dirty pages

Callers explicitly mark modified guards dirty. Before a dirty frame is evicted,
invalidated or closed, MiniSQL MUST:

1. reseal the page so payload and header checksums match;
2. write it through the owning paged file; and
3. flush the paged file.

M5 intentionally uses synchronous flushing for correctness. WAL-aware write ordering and
background checkpoint policies begin in later milestones.

## Capacity from a byte budget

`createForBytes(maxBytes, pageSize)` converts the configured page-payload budget into a fixed frame count using the persisted database page size. The budget never changes an existing file format.
