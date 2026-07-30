# 22. Overflow storage for TEXT and BLOB

## 22.1 Pointer

An external-value pointer is a 48-byte checksummed structure containing format version,
file ID, first page, total byte length, owner ID and whole-value CRC-32C. Zero-length values
use no page chain.

## 22.2 Chain pages

Overflow pages use the common 64-byte page header plus a 40-byte overflow header. Every
chain page stores magic/version, owner ID, next page, chunk length, total length and sequence
number. The payload starts at byte 104.

Reads MUST validate common page checksums and identity, overflow page type, owner, total
length, monotonic sequence, chunk bounds, expected terminal next-page value and whole-value
checksum. Repeated page numbers are cycles and MUST be rejected.

## 22.3 Ranged reads

A ranged read MAY copy only the requested interval, but it MUST still validate the complete
chain and whole-value checksum. Returning bytes from a partially validated chain is forbidden.

## 22.4 Allocation and reclamation

Free overflow pages SHOULD be reused before extending the paged file. Freeing a chain marks
all pages free only after the entire chain has been validated.

## 22.5 Two-phase replacement

Replacing a stored large value is explicitly two-phase:

1. prepare and durably write the new chain;
2. publish the new pointer in its owning row/catalog record under transaction control;
3. only after publication succeeds, reclaim the old chain.

`prepareReplace` MUST leave the old value readable. `abortReplace` reclaims only the new
chain. `commitReplace` reclaims only the old chain. A convenience operation MUST NOT pretend
to provide transaction atomicity when the owner pointer has not been durably published.
