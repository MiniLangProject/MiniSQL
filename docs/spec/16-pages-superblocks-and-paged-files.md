# 16. Pages, superblocks and paged files

## 16.1 Persisted format identity

The global configuration describes defaults for newly created databases only. An
existing paged file MUST derive page size and physical identity from its own valid
superblock. Changing `databaseDefaults.pageSize` MUST NOT reinterpret an existing file.

MiniSQL v1 uses one page size per database. Every paged table/index-style file repeats
that page size together with file ID and database ID.

## 16.2 Page format v1

Each data page has a 64-byte header and a size of 4096, 8192, 16384 or 32768 bytes. The
header contains magic, format and header versions, page type, flags, file/page identity,
page LSN, generation, item/free-space metadata, payload CRC-32C and header CRC-32C.

The payload checksum covers bytes 64 through the end of the page. The header checksum
covers bytes 0 through 63 with its own field zeroed. A page MUST pass both checks before
it is exposed by `PagedFile.readPage`.

## 16.3 Redundant superblocks

Every paged file reserves two fixed 4096-byte metadata slots:

```text
slot A: offset 0
slot B: offset 4096
page data: offset 8192
```

Each slot contains its own generation and CRC-32C. On open, MiniSQL independently
validates both copies and selects the valid copy with the highest generation. If both
valid copies disagree on immutable identity, opening MUST fail. Equal generations that
disagree on committed page count are ambiguous and MUST also fail. If both are invalid,
opening MUST fail as corrupt data.

## 16.4 Append publication protocol

A new page is published in this order:

1. write the complete sealed page at the current uncommitted tail;
2. flush the file;
3. write the next generation into the inactive superblock slot with incremented page
   count; and
4. flush again.

If a crash occurs before step 4 completes, the older metadata remains authoritative.
On open, physical bytes beyond the selected committed page count are truncated and
flushed. A file shorter than its selected committed page count is corrupt.

M4 provides metadata crash consistency but is not a substitute for M6 WAL atomicity for
in-place modifications.

The data region at offset 8192 begins with logical page zero.

## Non-destructive creation

Creation uses CREATE_NEW semantics. An existing path is never truncated or replaced by `paged_file.create`; physical replacement is reserved for a future explicit migration protocol.
