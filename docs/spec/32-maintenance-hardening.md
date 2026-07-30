# Maintenance and hardening (M20)

The checker opens the database exclusively, performs recovery, validates catalog/schema identities, scans every table, verifies all constraint indexes and validates persisted statistics. Backup holds the database lock, snapshots owner handles, writes a self-contained temporary directory and a CRC-protected manifest, verifies every file, then atomically publishes the backup. Restore verifies all lengths/checksums before opening the temporary database and publishing it. Migration planning reads persisted metadata; a page-size change is refused unless a future offline copy-and-rewrite implementation is available. Existing files are never reinterpreted from global defaults.

The cumulative gate also executes a deterministic 128-row transactional workload with aggregation, repeated lookups, ANALYZE, EXPLAIN ANALYZE and reopen verification. The five-minute ceiling is a hang/runaway guard, not a comparative benchmark.
