# Statistics and optimizer (M17)

ANALYZE scans a table and persists row count, page count, null count, distinct estimate and average width per column in `catalog/statistics.tbl`. The file is a versioned CRC-32C protected envelope tied to the database identity. The cost model uses integer arithmetic for deterministic plans. EXPLAIN reports logical/physical operators and whether defaults or analyzed statistics were used; EXPLAIN ANALYZE also executes the query and reports actual rows. Corrupt or cross-database statistics are rejected, never guessed.
