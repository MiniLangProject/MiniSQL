# Optimizer and executor v2

M46 establishes a typed physical-plan contract shared by optimizer and executor.
It adds costed access paths and bounded-memory execution improvements while
retaining correctness-first fallbacks.

## Rewrites and access paths

Literal expressions are folded with SQL short-circuit and NULL semantics.
Deterministic single-source WHERE conjuncts are pushed below inner joins, and
projection masks avoid reading unused overflow values. Volatile functions,
subqueries, and outer-join predicates remain at their semantic position.

The optimizer compares sequential and B+ tree scan cost. Equality and range
predicates may select indexes; complete unique equality probes have a semantic
upper bound of one row. Non-covering index candidates reuse one heap/schema
reader for the complete lookup instead of reopening it per entry. Repeated
top-level plans use their exact SQL text while nested plans use canonical AST
text in a bounded 64-entry per-session cache. A shared planning epoch invalidates every attached session
after DDL, ANALYZE, VACUUM, or REINDEX.

## Hash joins

INNER and LEFT joins whose predicate is a supported equality between one left
and one right column may use a deterministic hash table or an index nested
loop. The smaller hash input is selected as build side without changing bound
column order. Pure binary INNER equijoin graphs use a deterministic greedy
enumerator: the smallest estimated source seeds the plan, followed by the
smallest connected source. Rows with SQL `NULL` join keys do not match. Other
predicates and outer joins retain the nested-loop implementation and SQL order.

## Hash aggregation

`GROUP BY` uses a deterministic bucketed hash table with full SQL-value equality
checks inside each bucket. Output group order follows first appearance so query
results remain reproducible before an explicit `ORDER BY`.

Unfiltered `COUNT(*)` reads checksum-verified heap slot metadata without row
decoding. Eligible filtered and unfiltered scalar aggregates update fixed-size
streaming accumulators instead of retaining source rows. A reordered pure
INNER-equijoin `COUNT(*)` materializes intermediate joins only through the
penultimate edge and counts matches from the final edge directly.

## External merge sort

When the estimated and actual projected row count exceeds the configured
threshold, sorted chunks are written to temporary `MSSPILL1` run files and
merged pairwise. Run files are validated on read and removed on success and
handled failure paths. The final `QueryResult` is still materialized in memory;
M46 therefore bounds sort working sets but is not yet a fully streaming client
executor.

A small single-table `ORDER BY ... LIMIT/OFFSET` fuses scan, filter, projection,
and bounded Top-N selection, retaining at most one 128-row input batch plus the
requested window. Simple unordered single-table queries use the same bounded
cursor batches. Protocol v1 still requires the final result array for ordinary
multi-row results to be materialized.
