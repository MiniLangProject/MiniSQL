# 23. B+ tree indexes

## Contract

MiniSQL index files are paged files of type INDEX. Pages 0 and 1 are redundant metadata
pages; tree nodes begin at page 2. Keys and payloads are opaque byte strings. The M11
format limits keys to 256 bytes and payloads to 64 bytes so every v1 entry has a bounded
physical representation.

## Ordering and uniqueness

Ordering is unsigned lexicographic byte order. A unique tree permits at most one entry
per key. A non-unique tree orders duplicate keys by payload, so lookup and range output
remain deterministic. Point lookup returns all payloads for a key; range lookup accepts
independent inclusive/exclusive bounds and an optional maximum result count.

## Publication and recovery

Updates build a complete new tree generation in appended pages. Only after all node
pages are present does MiniSQL write and flush the inactive metadata page with generation
`old+1`. The prior metadata generation therefore remains a complete fallback after a
torn publication. Historic unreachable pages are retained until a later VACUUM/rebuild;
M11 never reuses a page whose reachability may be ambiguous after a crash.

## Verification

Open and explicit verify operations check metadata checksums, leaf links, global key
order, separator keys, child levels, cycles/duplicate child references, entry counts and
root/leaf boundaries. Unknown versions or inconsistent redundant metadata are rejected.
