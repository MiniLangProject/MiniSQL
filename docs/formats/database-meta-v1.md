# Database metadata format v1 envelope

> Archived format-1 design note. The current unreleased engine requires
> [database metadata v2](database-meta-v2.md); this historical sketch is not its
> byte-level specification and does not imply legacy read or upgrade support.

`db.meta` contains two fixed-capacity superblock slots. Each slot contains:

- magic and metadata format version
- database UUID and creation identity
- generation number
- database/table/index/WAL/row format versions
- page size
- checksum algorithm ID
- WAL segment size
- text encoding and default collation IDs
- current catalog generation
- checkpoint LSN
- next object and transaction identifiers
- feature flags
- checksum covering the complete occupied slot

Startup selects the highest valid supported generation. Unknown mandatory feature flags
cause open failure.
