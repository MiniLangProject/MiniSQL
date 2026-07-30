# ADR-0033: Savepoints snapshot private page changes

The initial no-steal transaction model stores private page images, so a savepoint is a deep copy of the current change set. This is simple and correct; later MVCC can replace the representation while preserving SQL semantics.
