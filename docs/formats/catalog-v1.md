# Database metadata and catalog envelope v1

> Historical M8 note. The database envelope now uses version 2; see
> [database metadata v2](database-meta-v2.md). The separate catalog envelope
> remains version 1 and uses scalable continuation pages as described in that
> document. Its retained version does not permit opening format-1 databases.

M8 stores `db.meta` and `catalog/catalog.tbl` as MiniSQL paged files. Page 0 contains a
protected envelope.

Database metadata envelope magic is `MSDBM001`, version 1, kind 1. It persists page size,
WAL segment bytes, database/table/index/WAL/row format versions, encoding/collation IDs,
database name, UUID, next object ID, next transaction ID and checkpoint LSN.

Catalog envelope magic is `MSCAT001`, version 1, kind 2. It persists the database UUID,
next object ID and canonical table/column metadata. Object names are UTF-8 and bounded.

The envelope and page checksums both apply. `db.meta` is authoritative for format and ID
high-water marks; catalog identity and physical table headers must agree with it.
