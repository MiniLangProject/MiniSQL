# ADR-0035: Two-generation security sidecar

**Status:** accepted for M21.

Security changes are stored in `catalog/security.tbl` as two alternating, CRC-protected snapshots. This keeps DCL persistence independent of the older catalog format, allows an M20 database to be upgraded atomically under its database lock, and permits deterministic fallback after a torn write. A failed write makes the in-process security handle fail closed until reopen resolves the winning generation.
