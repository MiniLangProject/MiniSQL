# Database and bootstrap catalog format v1

`db.meta` is a paged file of type database metadata and file ID 1. The bootstrap catalog
is a table paged file with file ID 2. Page zero stores a length-prefixed protected
envelope.

Database metadata persists page size, WAL segment size, database/table/index/WAL/row
format versions, encoding/collation identifiers, next object ID, next transaction ID,
checkpoint LSN, database UUID and name.

Catalog metadata persists database UUID, next object ID and table/column records. It is a
bootstrap representation limited to one page in M8.
