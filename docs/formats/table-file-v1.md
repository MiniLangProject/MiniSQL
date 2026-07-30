# Table file format v1 envelope

Page zero contains redundant/validated table identity metadata:

- table magic and table-file format version
- database UUID
- object/table ID
- database page size
- checksum algorithm ID
- physical row format version
- creation and current generation
- first free page and page count hints
- header checksum

Every data page contains page type, page ID, page LSN, generation, slot/free-space data
and checksum. Catalog metadata must agree with the file header.
