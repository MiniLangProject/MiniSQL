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

Leaf values begin with the stable 12-byte physical row reference used by all
version-1 indexes. Indexes without INCLUDE columns end there. Covering indexes
append the bytes `MSI`, payload version `1`, and one self-delimiting typed value
for each catalog-ordered INCLUDE column. Readers therefore accept legacy
12-byte values without a file-format migration; if catalog metadata expects a
payload that is absent, execution falls back to the heap. Invalid markers,
truncation, trailing bytes, and catalog-shape mismatches are corruption errors.

Keys are bounded at 256 bytes. Leaf values are bounded at 3,584 bytes, which
leaves enough space for the largest key plus fixed headers on the minimum 4 KiB
page. Larger database page sizes retain the same portable entry contract.
