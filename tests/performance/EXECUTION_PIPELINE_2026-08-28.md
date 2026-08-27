# Execution-pipeline performance report — 2026-08-28

This report records the six-part execution and storage optimization pass:

1. a retained 1 GiB baseline plus a high-cardinality narrow-row stress case;
2. forward-only client/server cursors with bounded backpressure;
3. page-range parallel scans and partial scalar aggregation;
4. batch-at-a-time aggregate execution and SIMD-backed byte search for common
   `LIKE` shapes;
5. a configurable, byte-aware query-memory manager with spill diagnostics; and
6. contiguous base-page and B+ tree generation publication on top of the
   existing transaction-sized WAL append and single-flush commit path.

All values below are measured results, not optimizer cost estimates. The
before/after 1 GiB runs used one trial because each creates a fresh durable
database. Restart verification used three fresh processes. Network figures use
one warmed server and persistent loopback connections. Host filesystem caches
were not forcibly evicted.

## Revisions and system

| Item | Value |
| --- | --- |
| MiniSQL baseline | `1af5ed15ebeaf15b0ce8247891361dc1f2233b2b` |
| MiniLangCompilerPy | `62cd18fdd8108169318137cabcabcec3e3976987`, version 1.1.0 |
| OS | Windows 11 Pro x64, 10.0.26200 |
| Python driver | 3.11.9 |
| CPU | AMD Ryzen 9 9900X, 12 cores / 24 logical processors, reported 4.40 GHz maximum |
| Memory | 66,155,491,328 bytes (61.6 GiB) |
| Storage | 2 TB NVMe, NTFS |

The workload contains 1,024 rows with one 1 MiB external `TEXT` value per row:
exactly 1 GiB logical payload and 1,115,584,941 bytes on disk. Inserts use 32
MiB restart-sized transactions. The raw reports remain under the ignored
`build/performance` directory; their SHA-256 values are:

| Report | SHA-256 |
| --- | --- |
| `windows-1g-before.json` | `4F71CB33856A2040943143C8869188C88E928621B20E7697682EAEF8F5CA23FA` |
| `windows-1g-after.json` | `9F833BC378937440140FF554F05C0CD9B8B261C88D8CA31750F3B18DC9A11DDC` |
| `windows-1g-after-adaptive-sum.json` | `DB2A95DF47419FAC1819240A4C009916CB31FF9BE44E2D88B08A7A1B43347788` |

## 1 GiB storage and restart result

| Measurement | Before | After | Change |
| --- | ---: | ---: | ---: |
| Durable insert, engine | 89.419 s | **66.485 s** | **1.345x faster** |
| Durable insert, wall | 92.610 s | **69.689 s** | **1.329x faster** |
| Effective engine throughput | 11.45 MiB/s | **15.40 MiB/s** | **+34.5%** |
| Cold semantic verify, engine | 1,157 ms | **187 ms** | **6.19x faster** |
| Cold semantic verify, wall | 1.228 s | **0.262 s** | **4.69x faster** |
| Warm restart verify, median engine | 1,094 ms | **125 ms** | **8.75x faster** |
| Warm restart verify, median wall | 1.172 s | **0.184 s** | **6.38x faster** |
| Insert peak private memory | 332.59 MiB | **332.59 MiB** | unchanged |
| Verify peak private memory | 130.85 MiB | **130.70 MiB** | -0.1% |

The durable-write improvement comes primarily from publishing consecutive base
pages and complete copy-on-write B+ tree generations in bounded contiguous I/O.
WAL records for one transaction were already appended as one bounded byte
stream and flushed once before acknowledgement. MiniSQL still has one physical
writer per database; this pass does not claim cross-transaction group commit.

## Scan and request throughput

The scalar aggregate path divides sufficiently large persistent heap-page
ranges among at most four native workers, accumulates in 256-row vectors, and
merges fixed-size partial states. Internal scan parallelism is used when one
reader owns the database. After concurrent readers have been observed, MiniSQL
keeps each statement serial internally to avoid multiplying client concurrency
by intra-query concurrency.

| Query | Clients | Before stmt/s | After stmt/s | Change |
| --- | ---: | ---: | ---: | ---: |
| `SUM(id)` | 1 | 8.723 | **28.794** | **3.301x** |
| `SUM(id)` | 4 | 28.997 | 28.502 | -1.7% |
| `SUM(id)` | 8 | 43.173 | 34.735 | -19.5% |
| `COUNT(*)` | 1 | **215.210** | 205.985 | -4.3% |
| `COUNT(*)` | 4 | **241.410** | 229.466 | -4.9% |
| `COUNT(*)` | 8 | **244.373** | 228.104 | -6.7% |

The single-query scan win is material. The multi-client values are not an
across-the-board win: the original independent-reader implementation scales
better at eight clients on this small 1,024-row projected scan. The adaptive
policy prevents the much worse oversubscription observed during development,
but future work should use a shared query scheduler with CPU tokens rather than
the current peak-reader heuristic. `COUNT(*)` already uses a page-metadata fast
path and does not benefit from row-vector aggregation.

One-shot `COUNT(*)`, including process startup and connection setup, improved
from 20.238 / 39.681 / 49.501 to **30.067 / 52.264 / 51.033 requests/s** at
1 / 4 / 8 concurrent clients.

## True 1 GiB result streaming

`SELECT id, payload FROM capacity_data` was consumed through the new
forward-only cursor. The result contained 1,024 rows and exactly 1 GiB of cell
payload. Because each row is itself 1 MiB, every returned batch contained one
row. A monitored repeat completed in **6.048 s (169.3 MiB/s)**:

| Measurement | Result |
| --- | ---: |
| Rows / logical payload | 1,024 / 1 GiB |
| Protocol batches | 1,024 |
| Maximum batch rows | 1 |
| Client peak private memory | **146.99 MiB** |
| Server peak private memory | **212.29 MiB** |

The compatibility `client.query` API still combines all batches for existing
callers. Memory-bounded applications must use `beginQuery` and
`nextQueryBatch`, render/export each batch, and then discard it. Protocol v1
targets frames below 1 MiB but permits one exceptional row frame up to 16 MiB;
this is a transport corruption guard, not a schema-object-count limit.

## High-cardinality and memory findings

A 32,768-row narrow-value stress database (2 KiB payload per row) completed and
reopened successfully. Its fresh-process verification returned all 32,768 rows
and 64 MiB of logical payload in 9,828 ms. The run exposed two distinct issues:

- per-page copy-on-write B+ tree publication caused excessive flush barriers;
  complete generations are now appended in bounded contiguous chunks with one
  data flush and one page-count publication;
- very large multi-`VALUES` statements still retain the parser AST, row array,
  and index delta simultaneously, reaching roughly 530–615 MiB in the stress
  driver. Applications should continue to batch inserts. A future executor
  should incrementally consume `VALUES` rows and compact retired B+ tree
  generations.

The query-memory manager samples actual row widths and converts
`runtime.temporaryMemoryBytes` into per-operator row thresholds. Hash joins,
grouped aggregation, and external sort record estimated peak/spill bytes and
spill-run counts; `EXPLAIN ANALYZE` exposes those counters. The limit is soft:
sources required by unsupported blocking shapes and the compatibility result
API can still materialize beyond it.

## SIMD and correctness

Exact, prefix, suffix, and single-contains `LIKE` patterns now use the standard
library's native byte primitives, which dispatch to the compiler/runtime SIMD
implementation where available. General `%`/`_` patterns use a constant-memory
greedy matcher and no longer have the former 4,096-byte subject ceiling. The
existing production CRC-32C implementation remains SSE4.2 accelerated at the
previous reference **12.78 GiB/s** on this host; the execution pass does not
change checksum semantics or its benchmark.

Correctness coverage includes large-pattern matching, B+ tree generations with
more than 128 leaf pages, cursor ownership and connection reuse, multi-frame
compatibility, bounded streaming of 1,200 rows, all existing SQL semantics, and
the manual full-1-GiB cursor run. The final unmodified candidate passed all
**106/106** cumulative acceptance phases and produced
`MiniSQL_1.0.0_RESULTS_20260828-012616.zip`.

## Next highest-value work

1. Replace the reader-history heuristic with database-wide CPU tokens and
   calibrated scan-size decisions.
2. Stream large `VALUES` lists into DML and compact retired append-only B+ tree
   generations to improve high-cardinality writes and physical amplification.
3. Extend cursor execution to filtered/index scans and blocking operators whose
   final output can be yielded incrementally.
4. Decouple WAL reservation/durability from the exclusive writer gate before
   implementing real cross-transaction group commit.
