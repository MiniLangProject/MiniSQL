# MiniSQL persisted formats

This index describes the **unreleased storage-v2 development state**. The
product version remains **1.1.1** for this patch; that product label alone does
not identify the database format. Earlier release evidence and milestone
documents describe their original format-1 builds.

All fixed-width numeric storage fields use little-endian encoding. Current
storage-v2 readers reject unsupported versions, noncanonical padding,
checksum failures and contradictory identities. Page sizes and format versions
come from persisted metadata, not from changed global defaults.

## Current storage generation 2

| Component | Version / contract | Specification |
|---|---|---|
| Database metadata | `MSDBM001` envelope version 2; database/table/index/WAL/row tuple `2/2/2/1/2` | [Database metadata v2](database-meta-v2.md) |
| User-table file | Mandatory identity header on page 0; data pages start at 1 | [Table file v2](table-file-v2.md) |
| Rows | Version 2; aligned fields and binary64 REAL/DOUBLE | [Row v2](row-v2.md) |
| Slotted-page payload | Eight-byte-aligned allocations, selected by table format 2 | [Slotted-page payload v2](slotted-page-v2.md) |
| Overflow | Version 2; U32 total length and separate pointer CRC | [Overflow pointer/page v2](overflow-v2.md) |
| Index keys and leaf values | Typed little-endian numeric keys; INCLUDE payload version 2 | [SQL index keys and values v2](index-file-v2.md) |
| B+ tree metadata and nodes | Version 2 | [B+ tree v2](btree-v2.md) |

Legacy database format 1 is explicitly rejected. There is no implicit
conversion, legacy import, or in-place upgrade in this development patch.
See [format compatibility](FORMAT_COMPATIBILITY.md) and the
[development upgrade guide](../release/UPGRADE.md).

## Structural wrappers that remain version 1

These versions identify their own framing. A version-1 wrapper can carry
version-2 table or row content and does not make that content readable by an
older MiniSQL binary.

| Wrapper | Current interpretation |
|---|---|
| [Protected envelope v1](protected-envelope-v1.md) | Same 32-byte CRC-protected header structure; each enclosed format selects its own version field. `db.meta` uses 2. |
| [Common page v1](page-v1.md) | Same 64-byte header; page type 6 identifies the new user-table header. |
| [Paged file / superblocks v1](paged-file-v1.md) | Same pair of 4096-byte superblocks; table/index payload versions are checked separately. The page-offset formula in the original spec is for plaintext records. |
| [WAL records v1](wal-v1.md) | Same 80-byte framing; page images contain current storage-v2 payloads. Encrypted records use the marker described in the encryption specification. |
| [Checkpoint v1](checkpoint-v1.md) | Same two 256-byte checkpoint slots. |
| [WAL durable marker v1](wal-durable-marker-v1.md) | Same optional durable-prefix record. |
| [Encryption envelope and records v1](encryption-envelope-v1.md) | Same nonce/ciphertext/tag framing; paged-file stride is `pageSize + 28` when encrypted. |
| [Heap forwarding v1](heap-forwarding-v1.md) | Same 24-byte record; row references in storage-v2 user tables must target pages 1 or later. |

## Other independently versioned formats

The catalog envelope remains `MSCAT001`, version 1, with scalable `BLB2`
continuation pages. The current relationship to `db.meta` is described in
[database metadata v2](database-meta-v2.md#catalog-companion). The original
[catalog](catalog-v1.md) and [bootstrap](catalog-bootstrap-v1.md) notes are
retained as historical M8 sketches.

- [Schema history v1](schema-history-v1.md)
- [Schema extensions v1](schema-extensions-v1.md)
- [DDL journal v1](ddl-journal-v1.md)
- [Maintenance journal v1](maintenance-journal-v1.md)
- [Security catalog v1](security-catalog-v1.md)
- [Backup manifest v1](backup-manifest-v1.md)
- [WAL archive v1](wal-archive-v1.md)
- [Audit log v1](audit-log-v1.md)
- [HA fencing records v1](ha-fencing-records-v1.md)
- [Sort-spill framing v1](sort-spill-v1.md), whose current row payloads use row format 2
- [Wire protocol v1](wire-protocol-v1.md)
- [Secure transport v1](secure-transport-v1.md)

Optimizer statistics currently write sidecar version 5; this is independent of
database storage generation 2. The [statistics-v1 note](statistics-v1.md)
describes the historical baseline, not the current writer's complete layout.
Milestone-specific limits in older sidecar notes remain historical; current
serializers are authoritative for those independently evolved formats.

## Archived storage-v1 material

[Database metadata](database-meta-v1.md), [table files](table-file-v1.md),
[rows](row-v1.md), [slotted pages](slotted-page-v1.md),
[overflow](overflow-v1.md), [index files](index-file-v1.md), and
[B+ trees](btree-v1.md) are retained for historical reference. Their presence
does not indicate legacy read or conversion support.
