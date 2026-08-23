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
