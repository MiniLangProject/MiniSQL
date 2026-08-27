# Optimizer and executor v2

M46 establishes a typed physical-plan contract shared by optimizer and executor.
It adds costed access paths and bounded-memory execution improvements while
retaining correctness-first fallbacks.

## Rewrites and access paths

Literal expressions are folded with SQL short-circuit and NULL semantics.
Deterministic single-source WHERE conjuncts are pushed below inner joins, and
projection masks avoid reading unused overflow values. Volatile functions,
subqueries, and outer-join predicates remain at their semantic position.
Top-level inner equality graphs propagate typed non-NULL constants between
equivalent columns. Inferred source predicates improve access selection while
the original predicate remains the final semantic guard.

The optimizer compares sequential and B+ tree scan cost. Equality and range
predicates may select indexes; complete unique equality probes have a semantic
upper bound of one row. Non-covering index candidates reuse one heap/schema
reader for the complete lookup instead of reopening it per entry. Independent
indexable `AND` terms may intersect row references before one heap
read. An `OR` uses a deduplicating union only when every disjunct is independently
indexable; partial coverage falls back to a complete semantic scan. When every
column referenced by the predicate, projection, grouping, aggregate, and order
key belongs to the selected B+ tree key, an `Index Only Scan` decodes those key
values directly and does not open heap or overflow pages. Floating-point key
encodings conservatively retain the heap fallback. Repeated
top-level plans use their exact SQL text while nested plans use canonical AST
text in a bounded 64-entry per-session cache. A shared planning epoch invalidates every attached session
after DDL, ANALYZE, VACUUM, or REINDEX.

## Hash joins

INNER and LEFT joins whose predicate is a supported equality between one left
and one right column may use a deterministic hash table or an index nested
loop. The smaller hash input is selected as build side without changing bound
column order. Connected INNER equijoin graphs through eight sources use a
Selinger-style subset dynamic program that retains the cheapest left-deep plan
for each source mask. Larger connected graphs use a deterministic greedy
fallback. Rows with SQL `NULL` join keys do not match. Other
predicates and outer joins retain the nested-loop implementation and SQL order.
Build inputs above the working threshold use grace-style hash partitions encoded
as validated `MSSPILL1` runs. Up to four native workers process disjoint
partitions concurrently, so no mutable hash table is shared.

## Hash aggregation

`GROUP BY` uses a deterministic bucketed hash table with full SQL-value equality
checks inside each bucket. Output group order follows first appearance so query
results remain reproducible before an explicit `ORDER BY`.
Large grouped inputs use the same validated partition format and up to four
native partition workers. An explicit `ORDER BY` restores requested ordering
after partition outputs are combined.

Unfiltered `COUNT(*)` reads checksum-verified heap slot metadata without row
decoding. Eligible filtered and unfiltered scalar aggregates update fixed-size
streaming accumulators instead of retaining source rows. A reordered pure
INNER-equijoin `COUNT(*)` materializes intermediate joins only through the
penultimate edge and counts matches from the final edge directly.

## External merge sort

When the estimated and actual projected row count exceeds the configured
threshold, sorted chunks are written to temporary `MSSPILL1` run files and
merged pairwise. Run files are validated on read and removed on success and
handled failure paths. Blocking working sets use the byte-derived threshold
configured by `runtime.temporaryMemoryBytes`; `EXPLAIN ANALYZE` reports the
estimated peak, spill bytes, and spill-run count. The final `QueryResult` for
blocking shapes is still materialized in memory, independently from the bounded
operator working set.

A small single-table `ORDER BY ... LIMIT/OFFSET` fuses scan, filter, projection,
and bounded Top-N selection, retaining at most one 128-row input batch plus the
requested window. Simple unordered single-table queries use a forward-only
storage cursor. The server retains one 16-row executor batch plus one look-ahead
frame and sends it before producing more rows. Protocol v1 targets continuation
frames below one MiB, with a 16 MiB exceptional-row guard. Cursor-aware clients
therefore avoid the executor's typed final row array; the compatibility client
API and ineligible query shapes still materialize it.

Eligible persistent scalar aggregates divide the heap-page directory into at
most four ranges, run fixed-size partial accumulators on the native thread pool,
and merge them deterministically. Each worker evaluates values in 256-row
vectors. When the database has already observed concurrent readers, statements
remain serial internally to avoid nested client/query oversubscription.
