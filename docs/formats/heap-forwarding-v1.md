# Heap forwarding record v1

Forwarding records are 24 bytes: magic `MSFW`, version 1, reserved zero, U64 page number,
U32 slot ID, U16 generation and U16 reserved zero. Resolution is bounded to 64 links and
rejects cycles.
