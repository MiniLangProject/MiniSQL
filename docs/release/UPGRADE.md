# MiniSQL 1.0 upgrade guide

All accepted M8–M49 databases use database format 1 and can be opened directly by
MiniSQL 1.0. The first open may create auxiliary files introduced by later
milestones, such as the security catalog or durable WAL marker.

Always make a verified backup before upgrading. Run the consistency checker
before and after. Page-size changes require an offline source-to-target rewrite;
never edit `db.meta` or file headers manually. Downgrading after using a feature
unknown to the older engine is not supported even when the physical format is
unchanged.

The native CRC-32C acceleration is an executable-only change. It preserves the
Castagnoli polynomial, initial/final XOR, and incremental state exactly, so it
requires no database rewrite and remains readable by earlier format-1 binaries.

Optimizer statistics use sidecar format 5 to persist the bounded sample count,
compact numeric/date equi-depth bounds, integral or hashed most-common values,
and joint distinct counts plus tuple MCVs for composite index keys. The
current reader accepts format 1 as an exact full-table sample, format 2 as
sampled statistics without range bounds, and format 3 as bounds without the new
distributions, plus format 4 as the legacy integral distribution layout. A
subsequent `ANALYZE` atomically writes format 5. This does not
change database page format 1 or wire protocol 1. Older MiniSQL binaries do not
understand a format-5 statistics sidecar; remove only
`catalog/statistics.tbl` and rerun `ANALYZE` after a deliberate downgrade.
