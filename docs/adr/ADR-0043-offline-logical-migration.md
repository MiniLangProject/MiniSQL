# ADR-0043: Physical format migration is a logical source-to-target rewrite

**Status:** candidate design for M26.

Changing page size cannot be an in-place metadata edit. MiniSQL creates a fresh
target, copies logical rows and security/schema metadata, rebuilds physical LOB
and index structures, validates the result, and only then publishes the target.
The source remains untouched and is the rollback copy by construction.
