# Table file format v2

Every user/heap table reserves logical page **0** for an immutable table header.
Heap and overflow pages begin at page 1. An empty table therefore consists of
the two 4096-byte paged-file superblocks and one logical page. Catalog and
security files use their own page formats despite sharing the paged-file table
type; they do not contain this user-table header.

The paged-file superblock and common page-header formats remain version 1.
Database, table and physical row formats are version 2. A table with no header,
heap data on page zero, or an older table/row version is rejected; there is no
implicit upgrade or legacy decoder.

## Immutable page-zero layout

All multibyte integers are little-endian. Offsets below are relative to the
decrypted logical page, whose size is `P`.

| Offset | Bytes | Field |
|---:|---:|---|
| 0 | 64 | Common page header: type 6 (`TABLE_META`), file ID, page number 0, page LSN 0, creation generation, item count 0, free-start 128, free-end `P`, flags 0 |
| 64 | 4 | ASCII magic `MSTB` |
| 68 | 2 | Table format version = 2 |
| 70 | 2 | Occupied table-header bytes = 128 |
| 72 | 16 | Database UUID, raw bytes |
| 88 | 8 | Table/file object ID |
| 96 | 4 | Database page size `P` |
| 100 | 2 | Checksum algorithm ID = 1 (CRC-32C) |
| 102 | 2 | Physical row format version = 2 |
| 104 | 8 | Nonzero immutable creation generation |
| 112 | 8 | First permitted heap/overflow page = 1 |
| 120 | 8 | Reserved, zero |
| 128 | `P - 128` | Reserved, zero |

The common page header contains the payload CRC-32C at offset 56 and header
CRC-32C at offset 60. Its payload CRC covers bytes 64 through `P - 1`, including
all table metadata and the reserved tail. No duplicate checksum is necessary.
The table ID, database UUID and page size must match the selected superblock.
The common header generation must equal the persisted creation generation,
which cannot exceed the current superblock generation.

Page zero is created and made durable before any data allocation. It does not
store mutable page-count or free-page hints: the selected superblock owns the
physical allocation frontier, while derived heap-page directories exclude
page zero. This avoids a second potentially stale allocation authority.

## Physical offsets and encryption

For unencrypted paged files, page zero begins at file offset 8192, and logical
page `n` begins at `8192 + n * P`. With page encryption enabled, the superblocks
remain plaintext and each logical page is stored in a record of `P + 28` bytes:
12-byte nonce, `P` bytes of ciphertext, and 16-byte GCM tag. The table header is
inside the encrypted page-zero payload and is checked after authentication.

## Open and maintenance requirements

Writable, shared read-only and database-managed read-only user-table opens all
verify page-zero checksums, identity, versions and reserved fields. Catalog
startup validation additionally compares the physical table identity with the
database/catalog identity. DDL creation, heap creation, VACUUM/rewrite and
offline page-size migration create a fresh valid page-zero header before
inserting rows. Row IDs and heap-page directories cannot reference page zero.
