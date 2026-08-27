# Statistics and optimizer (M17)

`ANALYZE [table]` counts checksum-verified live slots exactly and samples at
most 8,192 uniformly spaced decoded rows. It persists row count, page count,
sample count, estimated null count, estimated distinct count, average width,
and sampled signed-32-bit minimum/maximum for compact integral, `DECIMAL`, and
`DATE` values in `catalog/statistics.tbl`. Version 5 stores eight equi-depth
histogram boundaries and up to eight population-scaled most-common values.
Text, binary, and wide decimal equality distributions use stable hashed MCVs
without persisting unbounded values. Composite index keys of two through eight
columns receive an ordered joint distinct count plus bounded tuple-hash MCVs. Small tables remain exact. The bounded
sample prevents large tables or overflow values from making optimizer analysis
consume unbounded memory.

The version-5 file is a database-identified, CRC-32C-protected envelope. The
reader accepts version 1 (treated as an exact full-table sample), version 2
(sample count but no persisted range bounds), and version 3 (compact bounds but
no distributions or column groups), plus version 4 (legacy integral
distributions and joint distinct counts). Corrupt, unsupported, or cross-database statistics fail closed and are
never used for query correctness.

The deterministic integer cost model consumes these statistics for scan
selectivity, histogram-based integral/date range estimation, MCV-aware equality
estimation, correlated composite-key equality, equality-join cardinality, hash
build-side choice, bounded dynamic inner-equijoin order, and sort strategy.
Missing statistics use documented defaults.
`EXPLAIN` renders the typed plan that the executor consumes and states whether
defaults or analyzed statistics were used. `EXPLAIN ANALYZE` additionally
reports actual rows, elapsed milliseconds, and buffer-cache hits and reads.
