# 7. Storage architecture

## 7.1 Directory structure

```text
data/
  db_<database-uuid>/
    db.meta
    db.lock
    catalog/
    tables/
    indexes/
    wal/
    tmp/
```

Object files use internal numeric IDs, not user-controlled SQL names.

## 7.2 Pages

The canonical on-disk byte order for all fixed-width numeric fields is little-endian.
Every format version MUST state this explicitly and MUST NOT depend on host byte order.

Every table and index file is page-oriented. New databases default to 4096-byte
pages, with supported creation sizes 4096, 8192, 16384 and 32768. One database has
one page size.

Page headers contain at least format/type, page ID, page LSN, generation, item/free
space metadata and checksum.

## 7.3 Tables and rows

Tables use slotted pages. Rows are addressed by stable `(pageId, slotId)` references.
A row contains a schema version, NULL bitmap, fixed values, variable-value offsets
and payload. Large TEXT/BLOB values use overflow page chains and later streaming APIs.

## 7.4 Indexes

The primary index structure is a B+ tree. It supports unique and non-unique keys,
compound keys, equality/range/prefix lookup and stable row references.

## 7.5 Buffer pool

The buffer pool owns page caching, pin counts, dirty state, eviction and controlled
memory use. Durability policy remains in WAL/checkpoint code; eviction MUST NOT write
uncommitted state.

Read-only table and index generations are opened lazily and cached by the managed
database. Page misses use explicit-offset I/O on the shared immutable handle
(`ReadFile` with `OVERLAPPED` on Windows and `pread` on Linux), so parallel readers
do not serialize on a process-level file cursor. The database execution gate owns
generation lifetime and closes cached handles before a writer replaces storage.

## 7.6 Critical metadata

`db.meta` uses two independently checksummed superblocks with monotonic generations.
Updates write and flush the older slot with the next generation. Startup chooses the
highest valid supported generation.
