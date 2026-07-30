# Optimizer and executor v2

M46 adds three physical execution improvements while retaining correctness-first
fallback operators.

## Hash joins

INNER and LEFT joins whose predicate is a supported equality between one left
and one right column MAY use a deterministic hash table. Rows with SQL `NULL`
join keys do not match. Other predicates and RIGHT/FULL joins continue to use
the nested-loop implementation.

## Hash aggregation

`GROUP BY` uses a deterministic bucketed hash table with full SQL-value equality
checks inside each bucket. Output group order follows first appearance so query
results remain reproducible before an explicit `ORDER BY`.

## External merge sort

When the estimated and actual projected row count exceeds the configured
threshold, sorted chunks are written to temporary `MSSPILL1` run files and
merged pairwise. Run files are validated on read and removed on success and
handled failure paths. The final `QueryResult` is still materialized in memory;
M46 therefore bounds sort working sets but is not yet a fully streaming client
executor.
