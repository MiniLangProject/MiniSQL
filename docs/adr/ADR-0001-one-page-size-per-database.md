# ADR-0001: One page size per database

Status: accepted in M0.

MiniSQL 1.0 uses one page size per database. The value is persisted in redundant
database metadata and repeated in every table/index header for validation.

Per-table page sizes were rejected for the initial design because they complicate buffer
pool classes, WAL/recovery, checkpoints and B+ tree code without sufficient early value.
