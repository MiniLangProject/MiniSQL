# Heap forwarding record v1

Storage generation 2 retains this record layout. Its target page must be at
least 1 because [user-table page zero](table-file-v2.md) is reserved for the
immutable identity header. The 24-byte record fits the v2 aligned slot contract.

Forwarding records are 24 bytes: magic `MSFW`, version 1, reserved zero, U64 page number,
U32 slot ID, U16 generation and U16 reserved zero. Resolution is bounded to 64 links and
rejects cycles.
