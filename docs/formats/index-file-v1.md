# Index file format v1 envelope

Page zero contains:

- index magic and index-file format version
- database UUID
- index ID and referenced table ID
- database page size
- checksum algorithm ID
- B+ tree format version
- root page ID and tree generation
- header checksum

Index key schema is catalog-owned and cross-validated by object IDs and schema versions.
