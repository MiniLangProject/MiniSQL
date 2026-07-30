# ADR-0013: NO-STEAL transaction pages and durable commit acknowledgement

Status: accepted for M6.

Uncommitted page images remain transaction-private and are never written to base files. A
commit becomes successful only after begin, all page images and commit are appended and the
WAL flush succeeds. This conservative NO-STEAL design makes rollback simple and keeps recovery
focused on redo.
