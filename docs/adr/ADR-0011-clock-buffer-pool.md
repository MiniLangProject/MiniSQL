# ADR-0011: CLOCK buffer pool

Status: accepted for M5.

MiniSQL begins with a fixed-capacity CLOCK buffer pool. CLOCK provides bounded metadata,
constant-space scanning and a simple second chance without maintaining a linked LRU
list in MiniLang. Explicit guards make non-evictability visible. Dirty eviction is
synchronous until WAL and checkpoint ordering are introduced.
