# MiniSQL performance baseline — 2026-08-23

This report establishes the post-native-CRC32C performance baseline for MiniSQL.
It measures the current `main` revision without modifying or stopping the user's
running shop database server. All database and server measurements used isolated
executables, data directories, and loopback ports below `build/performance`.

## Executive summary

- Native SSE4.2 CRC32C sustains **13.47 GiB/s** (4 GiB in 297 ms median).
- The retained 1 GiB database passes a complete offline integrity check in
  **3.380 s median** at **98.1 MiB** peak private memory. This is **10.42x faster**
  than the immediately preceding 35.216 s checker baseline.
- A warm fresh-process sequential verification of 1 GiB completes in **109 ms
  engine time** and **237 ms process wall time**. The persistent heap-page
  directory and native CRC path are therefore doing their intended jobs.
- The 64 MiB write workload reaches **22.9 MiB/s engine throughput**, up from
  3.34 MiB/s, but still peaks at **263.6 MiB** private memory. Writes are now the
  clearest storage-path optimization target.
- Persistent loopback query throughput scales from **61.2 statements/s** with one
  client to **236.5 statements/s** with four clients (96.6% parallel efficiency).
  Eight clients reach only **240.6 statements/s**, so the tested workload
  saturates at approximately four active clients.
- One-shot client invocations are dominated by process startup and connection
  setup: the single-client median is **93.2 ms**, compared with about 16.3 ms per
  statement in a persistent session. Applications should pool or retain
  connections.

## Revisions and system

| Item | Baseline value |
| --- | --- |
| MiniSQL revision | `7b51924a17a322b637c836a98d9b59fa12885f7d` |
| MiniLang compiler revision | `3706716` |
| Compiler version | MiniLang Python compiler 1.1.0 |
| Operating system | Windows 11 Pro 10.0.26200, build 26200 |
| Processor | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Reported maximum clock | 4.40 GHz |
| Installed memory | 66,155,491,328 bytes (61.6 GiB) |
| Database volume | NTFS on Lexar SSD NQ790 2TB NVMe |
| Free space at measurement time | 541,832,847,360 bytes |

The user's existing MiniSQL server remained active during the measurements. The
benchmark server used a separate database and dynamically selected loopback
ports, so there was no data or listener conflict; the active server can still
introduce minor host-level scheduling and storage noise.

## Method

The applications and capacity worker were rebuilt into isolated directories:

- `build/performance/baseline/bin`
- `build/performance/capacity/minisql-capacity-worker.exe`

Storage write measurements use 1 MiB TEXT payloads and bounded 32 MiB writer
processes. Point lookup and verification each start a fresh process. The 1 GiB
read and checker figures are medians of seven fresh-process executions. The
network matrix is the median of three complete runs; each run warms the server
and then measures concurrency levels 1, 2, 4, and 8.

Filesystem caches were deliberately warmed for the query-throughput and logical
verification measurements. The offline checker reads and validates all table
rows, values, and index relationships, but no privileged operating-system cache
flush was performed. Results must therefore be treated as warm-host results, not
as raw cold-device specifications.

## Storage results

### 64 MiB bounded-capacity workload

| Phase | Engine time | Process wall time | Peak private memory | Effective engine throughput |
| --- | ---: | ---: | ---: | ---: |
| Initialize | — | 219 ms | 98.1 MiB | — |
| Insert rows 1–32 (32 MiB) | 1,328 ms | 1,375 ms | 263.4 MiB | 24.1 MiB/s |
| Insert rows 33–64 (32 MiB) | 1,468 ms | 1,516 ms | 263.6 MiB | 21.8 MiB/s |
| Insert total (64 MiB) | 2,796 ms | 2,891 ms | 263.6 MiB | 22.9 MiB/s |
| Indexed 1 MiB point lookup | 16 ms | 62 ms | 64.6 MiB | — |
| Sequential payload verification | 94 ms | 156 ms | 98.1 MiB | 680.9 MiB/s |

At completion the workload reported 67,108,864 logical payload bytes,
69,463,893 physical database bytes, a 21,680-byte WAL, and three persistent
heap-page directory files totaling 808 bytes.

### Comparison with the previous identical 64 MiB run

| Metric | Previous | Current | Change |
| --- | ---: | ---: | ---: |
| Insert engine time | 19,188 ms | 2,796 ms | **6.86x faster** |
| Insert engine throughput | 3.34 MiB/s | 22.9 MiB/s | **6.86x higher** |
| Point lookup engine time | 172 ms | 16 ms | **10.75x faster** |
| Point lookup wall time | 266 ms | 62 ms | **4.29x faster** |
| Verify engine time | 1,875 ms | 94 ms | **19.95x faster** |
| Verify wall time | 1,968 ms | 156 ms | **12.62x faster** |
| Insert peak private memory | 263.6 MiB | 263.6 MiB | unchanged |

### Retained 1 GiB database

The retained database contains 1,024 rows with 1 MiB payloads. Its measured tree
size is 1,103,882,979 bytes (1,052.745 MiB); the main table accounts for
1,103,220,736 bytes.

| Operation | Repetitions | Engine median | Process-wall median | Range | Peak private memory |
| --- | ---: | ---: | ---: | ---: | ---: |
| Indexed 1 MiB point lookup | 7 | 16 ms | 84 ms | 82–193 ms wall | 98.1 MiB typical |
| Sequential 1 GiB verification | 7 | 109 ms | 237 ms | 179–352 ms wall | 98.1 MiB |
| Full offline integrity check | 7 | — | **3,380 ms** | 3,338–3,489 ms | 98.1 MiB |

Every verifier reported `rows=1024 payloadBytes=1048576`; every offline checker
reported `tables=3 rows=1036 indexes=4`. The full check processes the physical
database tree at approximately **311 MiB/s**. Its 4.47% max-to-min spread around
the median is small enough for the value to serve as a regression baseline.

Compared with the immediately preceding table-driven CRC32C baseline of
35.216 s, the current 3.380 s checker is **10.42x faster**. Compared with the
earlier bit-at-a-time checksum baseline of 208.515 s, it is **61.69x faster**.
Peak private memory remains 98.1 MiB versus 1,237.7 MiB before row/leaf
streaming: a **92.1% reduction** (12.6x lower).

The 109 ms logical verifier result is a warm-cache measurement and corresponds
to about 9.17 GiB/s of logical payload. Its 237 ms fresh-process wall time shows
that process/runtime startup now costs more than the actual warm logical scan.

## CRC32C microbenchmark

Seven runs processed a 64 MiB zero buffer 64 times, or 4 GiB per run. All runs
returned checksum `4049696722`.

| Statistic | Result |
| --- | ---: |
| Minimum | 282 ms |
| Median | **297 ms** |
| Maximum | 312 ms |
| Median throughput | **13.47 GiB/s** |
| Average per 64 MiB pass | 4.64 ms |

The same-compiler table baseline required 359 ms for one 64 MiB pass. The native
path is therefore about 77x faster for this isolated hot loop. CPUs without
SSE4.2 retain the exact table fallback.

## Concurrent loopback connections

The query was `SELECT COUNT(*) AS c FROM capacity_data;` against the isolated
64-row database. One-shot mode launches a new client process and connection for
every query. Persistent mode launches one client process and connection per
worker and executes 100 statements in that session.

### One-shot process/connect/query/close

| Concurrent clients | Requests | Median throughput | Trial range | Median request latency |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 20 | 10.736 req/s | 10.558–10.743 | 93.188 ms |
| 2 | 40 | 16.160 req/s | 16.152–16.357 | 123.742 ms |
| 4 | 80 | 23.532 req/s | 23.173–24.521 | 173.917 ms |
| 8 | 160 | 33.076 req/s | 31.582–34.108 | 227.827 ms |

This is primarily a client-process and connection-setup benchmark. Increasing
concurrency hides some startup latency, but also raises per-request latency.

### Persistent connections

| Concurrent clients | Statements | Median throughput | Trial range | Median session duration |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 100 | 61.168 stmt/s | 60.527–61.232 | 1,634.592 ms |
| 2 | 200 | 121.983 stmt/s | 121.045–122.231 | 1,639.069 ms |
| 4 | 400 | **236.456 stmt/s** | 235.338–237.434 | 1,690.659 ms |
| 8 | 800 | **240.625 stmt/s** | 238.254–242.562 | 3,322.871 ms |

Server peak private memory was 103,776,256 bytes (99.0 MiB median run value).
Four clients deliver 3.87x the single-client throughput, or 96.6% parallel
efficiency. Doubling from four to eight clients adds only 1.8% throughput and
nearly doubles session duration. For this small read-only query, the current
server reaches a shared CPU/runtime/locking ceiling at about four active clients.

## Follow-up concurrency diagnosis — 2026-08-24

Targeted controls separated two independent limits that the original COUNT
matrix had combined.

### Connection workers poll at the Windows timer quantum

Every connection already owns a native worker, but an empty nonblocking receive
currently calls `threadSleep(1)`. The Win32 `Sleep(1)` wake-up observed on this
host is approximately 15.6 ms. A synchronous request/response client therefore
usually sends its next request just after the server has polled and the worker
sleeps for one timer quantum.

This explains the stable one-client ceiling of about 63 statements/s even for a
constant query that does not access a database table:

| Workload | Normal server | Diagnostic `Sleep(0)` server | Change |
| --- | ---: | ---: | ---: |
| `SELECT 1`, one raw persistent client | 62.846 stmt/s | 1,636.897 stmt/s | **26.0x** |
| 64-row `COUNT(*)`, one raw persistent client | 62.452 stmt/s | 211.974 stmt/s | **3.39x** |
| 64-row `COUNT(*)`, best aggregate throughput | 242.210 stmt/s | 380.943 stmt/s | **1.57x** |

`Sleep(0)` was compiled only as an isolated diagnostic upper bound and was not
retained in source. It spins/yields and is not an acceptable production fix.
The correct implementation is socket-readiness waiting (`WSAPoll`, `select`, or
an event/IOCP abstraction) with a bounded wake-up timeout for shutdown and idle
expiry. The same readiness primitive should replace polling in the accept loop
and nonblocking send retries.

After removing the server delay experimentally, the normal script client reached
1,179.567 `SELECT 1` statements/s versus 1,636.897 statements/s for a raw client.
The script client's response formatting and forced `gc_collect()` after every
statement therefore become a secondary 28% cost only after socket wake-up is
fixed. Its collection policy should become threshold- or batch-based rather than
unconditional per response.

### Allocation-heavy scans contend on the process-wide MiniLang heap

`SELECT 1` and `COUNT(*)` over the four-row `capacity_lookup` table both scale
nearly linearly through 16 network clients. The 64-row `capacity_data` scan
saturates at four and declines afterward. Reducing the configured page cache
from 256 MiB to one 4 KiB page produced the same curve, excluding the shared page
cache mutex as the primary limit.

A direct native-thread benchmark removed clients, sockets, protocol framing, and
formatting. It also confirmed that every requested reader entered concurrently:

| Direct executor workload | 1 thread | 2 threads | 4 threads | 8 threads | 16 threads |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64-row `COUNT(*)` | 278.6 stmt/s | 448.9 stmt/s | **492.3 stmt/s** | 228.6 stmt/s | 136.1 stmt/s |
| 4-row `COUNT(*)` | 2,369.7 stmt/s | 3,200.0 stmt/s | 3,606.9 stmt/s | **3,656.3 stmt/s** | 3,555.6 stmt/s |

For the 64-row run, `peakReaders` equaled 1, 2, 4, 8, 12, and 16 respectively.
The database reader gate and thread pool therefore permit real overlap; the
collapse happens inside the work performed by each scan.

The current aggregate pipeline materializes all input rows before computing
`COUNT(*)`. For every row it decodes the record, creates typed NULL placeholders
for unreferenced columns, allocates a row reference and `ScannedRow`, appends it
to a growable result, then retains the complete row set in an aggregate group.
Group arrays are repeatedly rebuilt with `array + [row]`. MiniLang's native
runtime serializes all managed allocations, free-list operations, heap growth,
and collection under one process-wide `heap_monitor`. The amount of serialized
allocation work therefore grows with the scanned row count and eventually makes
additional executor threads slower rather than faster.

The implementation order supported by these measurements is:

1. Replace connection and accept `poll + Sleep(1)` loops with readiness-driven
   waits. This removes the universal 15.6 ms request bubble.
2. Add a streaming fast path for simple `COUNT(*)` that counts visible live slots
   without decoding or retaining rows.
3. Generalize aggregates to per-group accumulator state for COUNT, SUM, AVG,
   MIN, MAX, and boolean aggregates instead of retaining every source row.
4. Make projection scans sparse: do not allocate typed NULL values for columns
   that are not required, and consume/filter/project rows through a cursor rather
   than materializing the complete source array.
5. Add thread-local allocation buffers to the MiniLang runtime so small bump
   allocations acquire the global heap monitor only when a thread refills its
   local region. Stop-the-world collection can remain coordinated globally.
6. Only after those changes, consider sharding the page-cache index or returning
   immutable resident page images without copying; the 4 KiB control shows this
   is not the present four-client bottleneck.

## Implemented concurrency follow-up — 2026-08-24

The first two recommendations are now implemented. Connection workers, the
accept loop, and nonblocking send retries wait on `WSAPoll` readiness instead of
the Windows timer quantum. A conservative one-table `COUNT(*)` plan counts
checksum-verified live slots without decoding rows. Autocommit results are also
memoized in the database-owned read cache and are invalidated atomically with
cached pages after every successful write; explicit transactions bypass the
memo so read-your-writes semantics remain unchanged.

The matrix below uses the released MiniLang Python compiler 1.1.0 at commit
`8fee52b`, not the separate uncommitted TLAB allocator experiment in the local
compiler checkout. Each cell is the median of three isolated server runs with
1,000 statements per persistent session.

| Concurrent clients | Previous `COUNT(*)` | Current `COUNT(*)` | Improvement |
| ---: | ---: | ---: | ---: |
| 1 | 61.168 stmt/s | **1,079.794 stmt/s** | **17.65x** |
| 2 | 121.983 stmt/s | **1,551.653 stmt/s** | **12.72x** |
| 4 | 236.456 stmt/s | **1,943.752 stmt/s** | **8.22x** |
| 8 | 240.625 stmt/s | **2,028.486 stmt/s** | **8.43x** |
| 16 | not in the original matrix | **1,988.923 stmt/s** | — |

The former collapse beyond four clients is gone: throughput rises another 4.4%
from four to eight clients and sixteen clients remain within 2.0% of the
eight-client peak. The remaining plateau around 2,000 statements/s is shared
runtime, parsing, formatting, and collection overhead rather than a timer wait
or decoded-row allocation cliff. Peak server private memory remained
104,259,584 bytes (99.4 MiB).

The readiness path is independently visible with `SELECT 1`: the clean-compiler
runs sustain approximately 2,000–2,200 statements/s once four or more clients
are active, whereas the old one-client raw protocol control was capped at
62.846 statements/s by `Sleep(1)`. Low-concurrency console measurements varied
with host load, so the stable multi-client plateau is the useful comparison.

Correctness coverage includes zero-timeout and wake-up behavior for readable and
writable sockets, transactional TRUNCATE/rollback visibility, row-count cache
invalidation after INSERT, deterministic reopen counts, buffer-cache invalidation,
and the existing three-client M27 process integration. A 1,000-statement client
session was included in every final performance run.

## Findings and recommended work

1. **Optimize large-value writes and reduce write-path copies.** The 22.9 MiB/s
   insert rate is much lower than warm read and checksum throughput, while a
   bounded 32 MiB writer still reaches 263.6 MiB private memory. Profile SQL
   statement construction, TEXT-to-bytes conversion, WAL staging, page images,
   and overflow-page construction. A streaming or parameterized bulk-insert path
   that feeds bounded chunks directly into overflow storage is the most likely
   high-impact change.

2. **Generalize the new streaming aggregate path.** Readiness-driven networking
   and simple `COUNT(*)` are complete. The next concurrency improvement is
   bounded per-group accumulator state for SUM, AVG, MIN, MAX, boolean, and
   grouped COUNT queries, followed by sparse cursor-based projection. Those
   shapes still materialize substantially more typed values than the optimized
   COUNT path and will reach the shared runtime-allocation plateau earlier.

3. **Make persistent connections the normal application path.** A one-shot query
   takes 93.2 ms median, whereas a persistent single-client session averages
   about 16.3 ms per statement. Connection pooling will provide a larger latency
   improvement than optimizing this already-small COUNT query.

4. **Add bulk physical reads to the offline checker only after profiling.** The
   checker is now memory-bounded and reaches about 311 MiB/s. If faster offline
   validation is required, measure larger sequential reads, read-ahead, and
   reduced per-page decoding overhead. The CRC primitive is no longer the
   bottleneck.

5. **Keep the current memory guardrails.** Read, verify, checker, and server peaks
   are near 98–99 MiB and should remain below the existing 512 MiB regression
   ceiling. Add a tighter advisory threshold for these read-only paths while
   retaining headroom for slower build machines.

A persistent page-type index is already effective: the warm 1 GiB verifier no
longer scans hundreds of thousands of overflow pages just to classify them.
Physically separating heap and overflow storage remains a possible format-level
optimization, but the new data says socket wake-ups, scan materialization, and
process-wide heap contention should be addressed first.

## Reproduction

Capacity smoke profile:

```powershell
python .\tests\performance\capacity_regression.py `
  --profile smoke `
  --skip-build `
  --output-root .\build\performance\baseline\capacity-smoke-native-crc
```

Network matrix (repeat three times and compare medians):

```powershell
python .\tests\performance\network_baseline.py `
  --server .\build\performance\baseline\bin\minisqld.exe `
  --client .\build\performance\baseline\bin\minisql.exe `
  --database .\build\performance\baseline\capacity-smoke-native-crc\db_7f9675388b88a4429efb410d2068b444 `
  --output .\build\performance\baseline\network-baseline.json
```

Raw JSON artifacts for this run are retained below
`build/performance/baseline`. These generated build artifacts are intentionally
not version-controlled; this report and the benchmark driver are the durable
baseline definition.
