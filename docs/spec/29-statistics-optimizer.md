# Statistics and optimizer (M17)

`ANALYZE [table]` counts checksum-verified live slots exactly and samples at
most 8,192 uniformly spaced decoded rows. It persists row count, page count,
sample count, estimated null count, estimated distinct count, average width,
and sampled signed-32-bit minimum/maximum for `SMALLINT`, `INTEGER`, and `DATE`
columns in `catalog/statistics.tbl`. Small tables remain exact. The bounded
sample prevents large tables or overflow values from making optimizer analysis
consume unbounded memory.

The version-3 file is a database-identified, CRC-32C-protected envelope. The
reader accepts version 1 (treated as an exact full-table sample) and version 2
(sample count but no persisted range bounds). Corrupt, unsupported, or cross-database statistics fail closed and are
never used for query correctness.

The deterministic integer cost model consumes these statistics for scan
selectivity, uniform integral/date range estimation, equality-join cardinality, hash build-side choice, inner-equijoin
order, and sort strategy. Missing statistics use documented defaults.
`EXPLAIN` renders the typed plan that the executor consumes and states whether
defaults or analyzed statistics were used. `EXPLAIN ANALYZE` additionally
reports actual rows, elapsed milliseconds, and buffer-cache hits and reads.
