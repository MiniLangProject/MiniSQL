# MiniSQL persisted format index

All fixed-width fields use canonical little-endian encoding unless a format
explicitly says otherwise. Unknown versions, non-zero reserved fields, checksum
failures, and contradictory identities are fail-closed.

- [Protected envelope v1](protected-envelope-v1.md) — M2
- [Common page v1](page-v1.md) — M4
- [Paged file v1](paged-file-v1.md) — M4
- [Database metadata v1](database-meta-v1.md) — M8
- [Table file v1](table-file-v1.md) — M8
- [Index file v1](index-file-v1.md) — M11
- [WAL record v1](wal-v1.md) — M6
- [Checkpoint metadata v1](checkpoint-v1.md) — M7
- [Database/catalog envelope v1](catalog-v1.md) — M8
- [Catalog bootstrap v1](catalog-bootstrap-v1.md) — M8
- [Row v1](row-v1.md) — M9
- [Slotted-page payload v1](slotted-page-v1.md) — M9
- [Heap forwarding v1](heap-forwarding-v1.md) — M9
- [Overflow pointer/page v1](overflow-v1.md) — M10
- [B+ tree index v1](btree-v1.md) — M11
- [Schema history v1](schema-history-v1.md) — M14/M24
- [DDL journal v1](ddl-journal-v1.md) — M14/M24
- [Statistics v1](statistics-v1.md) — M17
- [Wire protocol v1](wire-protocol-v1.md) — M18/M21
- [Backup manifest v1](backup-manifest-v1.md) — M20
- [Security catalog v1](security-catalog-v1.md) — M21
- [Maintenance journal v1](maintenance-journal-v1.md) — M25

Existing paged files MUST derive page size and format identity from persisted
metadata and file headers, never from changed global defaults. M22-M24 do not
change page, WAL, or wire format. M25 introduces only the maintenance journal;
M26 rewrites into a fresh database rather than mutating format identity.

- `audit-log-v1.md`

- `secure-transport-v1.md`

- `wal-archive-v1.md`
- [WAL durable marker v1](wal-durable-marker-v1.md) — M48
- [MiniSQL 1.0 format compatibility](FORMAT_COMPATIBILITY.md) — M50
