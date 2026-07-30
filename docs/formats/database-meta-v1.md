# Database metadata format v1 envelope

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
