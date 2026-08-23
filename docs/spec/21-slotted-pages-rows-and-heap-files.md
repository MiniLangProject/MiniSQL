# 21. Slotted pages, row format and heap files

## 21.1 Slotted pages

The common MiniSQL page header occupies the first 64 bytes. An 8-byte slot directory grows
upward while record bodies grow downward. Compaction may move record bodies but MUST preserve
slot indices. Every mutation MUST be assembled and validated on a working copy before the
caller-visible page buffer is replaced; a failed mutation MUST leave it byte-identical.

Each slot stores offset, length, state flags and a 16-bit generation. Deleting a live slot
advances its generation. A RowId contains `(pageNumber, slotId, generation)`. A mismatched
generation is stale, not a reference to a replacement row. Generation 65535 is saturated:
the deleted slot is permanently retired and MUST NOT be reused, preventing wraparound aliasing.

## 21.2 Forwarding records

A growing update may write a moved row into a new internal slot and replace the stable root
slot with a forwarding record. The new copy MUST be written before pointer publication.
Scans expose logical root/live rows only, not internal moved rows. Forwarding chains MUST be
bounded and validated to prevent loops, stale generations and invalid targets. A crash may
leak an unreachable moved copy but MUST leave the prior visible row readable.

## 21.3 Row format v1

A row contains magic, format version, schema version, column count, NULL-bitmap length,
directory offset, reserved fields, the NULL bitmap, 8-byte typed column-directory entries
and canonical contiguous value bytes.

SQL NULL is represented by a dedicated `SqlNull` value. MiniLang `void` MUST NOT be silently
stored as SQL NULL. Type codes and directory flags must agree with the schema, reserved bits
must be zero, offsets must be canonical and trailing/unreachable bytes are corruption.

M9 supports BOOLEAN, SMALLINT, INTEGER, BIGINT, REAL, DOUBLE, DECIMAL, CHAR, VARCHAR, TEXT,
BINARY, VARBINARY, BLOB, DATE, TIME and TIMESTAMP at the physical codec level. BIGINT,
DECIMAL, TIME and TIMESTAMP use `Int64Words` for the complete 64-bit bit domain. TEXT/BLOB
may contain an external M10 overflow pointer.

MiniLang currently has no stable float-bit cast. Row format v1 therefore stores REAL and
DOUBLE as validated canonical UTF-8 numeric renderings rather than claiming raw IEEE-754
bits. This choice requires an explicit format migration if a future format adopts bitwise
IEEE storage.

The row codec is a physical codec. M9 bounds text by encoded UTF-8 byte length. Logical SQL
character-count semantics, collations, casts and coercion rules belong to M13-M14.

## 21.4 Heap files

A heap file stores slotted pages in a paged file and supports insert, read, update, delete,
scan/count and reopen. Deleted space SHOULD be reused before file growth. Page identities,
checksums, slot state and RowId generation are verified on each read path.

## 21.5 Persistent heap-page directory

Every table may have a derived `<table>.heap-pages` sidecar. Its versioned
CRC-32C envelope binds the database ID, table file ID, page size, classified
page count, source superblock generation, and a strictly increasing list of
physical `TYPE_HEAP` page numbers. The sidecar is not authoritative database
content and MUST NOT impose a fixed table-size policy limit.

A scan with an exact page-count/generation match reads only listed heap pages.
When the table grows monotonically, the implementation MUST preserve the
validated prefix, checksum and classify only the new tail, then atomically
replace the sidecar. A smaller frontier, inconsistent generation, invalid
identity, malformed ordering, unsupported fields, truncation, or checksum
failure MUST trigger reconstruction from authoritative checksummed pages.
Failure to publish derived state MUST NOT make a valid table unreadable.

Physical replacement protocols such as `VACUUM` MUST invalidate the directory
before publishing their replacement journal. Transactional `DROP TABLE` cleanup
removes it, and interrupted maintenance recovery invalidates it before choosing
the authoritative generation. Backup, restore, migration, and consistency
checking operate on authoritative paged files; a missing sidecar is rebuilt on
the next heap scan.
