# B+ tree format v1

An index is a standard paged file with `FILE_TYPE_INDEX`. Page 0 and page 1 are redundant
metadata pages. Their payload begins at byte 64 with magic `MSBM`, version 1, uniqueness
flags, generation, root/first-leaf/last-leaf page numbers, entry count and height.

Leaf payload begins at byte 96 with magic `MSBL`, version, previous/next leaf links and a
sequence of U16 key length, U16 value length, key bytes and value bytes. Internal payload
begins at byte 88 with magic `MSBI`, version, level, child count, child page references and
separator keys. Every page uses the common page-v1 header and CRC-32C sealing.

Metadata is published alternately to page 0 or 1. Nodes are copy-on-write and append-only
within a generation. Readers choose the valid highest generation and may fall back to the
older independently valid generation if the newest referenced graph is torn.
