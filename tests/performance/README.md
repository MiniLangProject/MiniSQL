# Performance tests

Repeatable storage and query benchmarks live here. Correctness tests remain mandatory;
performance measurements may never replace durability or semantic validation.

The current 1 GiB Windows/Linux reference, test-system description, storage and
checker speed, CRC-32C throughput, SQL request rates, and memory peaks are in the
root README's [Performance evaluation](../../README.md#performance-evaluation).
[`PERFORMANCE_BASELINE_2026-08-23.md`](PERFORMANCE_BASELINE_2026-08-23.md)
retains the earlier optimization baseline and implementation history.

The current availability series is documented in
[`AUTOMATIC_HA_2026-08-30.md`](AUTOMATIC_HA_2026-08-30.md). It records ten
forced automatic promotions and five destructive write-fencing/integrity
drills, including raw recovery times, distribution statistics, host details,
methodology, and the limits of the single-host file-witness design.

The current compiler performance-fix verification is documented in
[`COMPILER_UPDATE_21C1BEA_2026-08-25.md`](COMPILER_UPDATE_21C1BEA_2026-08-25.md).
It confirms full compiler and MiniSQL correctness and rechecks bounded storage,
the retained 1 GiB database, allocation-heavy multi-client scans, native
allocation churn, memory, and binary size. The preceding regression report is
retained in
[`COMPILER_UPDATE_A5597F7_2026-08-24.md`](COMPILER_UPDATE_A5597F7_2026-08-24.md).

The legacy comma-FROM equality promotion and residual-filter elimination are
measured in
[`COMMA_JOIN_RESIDUAL_2026-08-27.md`](COMMA_JOIN_RESIDUAL_2026-08-27.md).
The optimized spelling is at parity with an explicit `INNER JOIN` in the
persistent loopback workload while avoiding the former duplicate predicate
evaluation.

The six-part optimizer/executor expansion and its focused multi-index,
transitive-join, spill, intra-query-worker, and continuation-frame results are
documented in
[`OPTIMIZER_EXPANSION_2026-08-27.md`](OPTIMIZER_EXPANSION_2026-08-27.md).

The subsequent execution-pipeline pass, including the before/after 1 GiB
storage result, page-range scalar aggregates, true 1 GiB cursor transport,
query-memory accounting, contiguous B+ tree publication, and high-cardinality
findings, is documented in
[`EXECUTION_PIPELINE_2026-08-28.md`](EXECUTION_PIPELINE_2026-08-28.md).

`platform_compare.py` runs the same bounded storage, restart, one-shot and
persistent loopback workloads for one already-built native target. Invoke it
once from Windows Python and once from Linux Python, using target-native data
directories, then retain the two raw JSON files with the comparison report.
Large storage workloads are split into restart-sized processes with
`--storage-chunk-mib` (32 MiB by default), so a 1/5/10 GiB comparison does not
construct one multi-gigabyte SQL statement or confuse statement-building memory
with database capacity. Each report retains the per-chunk timings as well as
their total engine time, wall time, and maximum private-memory usage.
The Linux memory sampler uses private mappings from `/proc/PID/smaps_rollup`;
Windows continues to use `PROCESS_MEMORY_COUNTERS_EX.PrivateUsage`.
The measured 2026-08-26 Windows/WSL2 comparison retains the original Linux
multi-client blocker and documents its subsequent pthread-runtime fix and
successful 1/2/4/8-client functional rerun. It also contains the completed
three-trial 1/4/8-client Windows/Linux performance follow-up in
[`WINDOWS_LINUX_COMPARISON_2026-08-26.md`](WINDOWS_LINUX_COMPARISON_2026-08-26.md).
The parent runner and its network subprocess disable local Python bytecode before
importing their memory sampler so documented benchmark runs do not leave
source-tree cache artifacts that would invalidate the release hygiene gate.

`capacity_regression.py` provides restart-aware `1`, `5`, and `10` GiB profiles
plus a fast `smoke` profile. Each process writes a bounded chunk, so the test
does not confuse process-heap growth with database capacity. The driver checks
large TEXT overflow storage, grouped and paginated reads, page-cache reuse,
recovery after every chunk, a fresh-process indexed point lookup, and the
configured WAL checkpoint bound. Sequential verification also exercises the
persistent heap-page directory: a fresh process must reuse or tail-extend the
CRC-protected map instead of re-reading every overflow page. The default 32 MiB
write chunks and every
read/maintenance phase must remain below the 512 MiB private-memory guardrail;
both values are configurable. Add `--vacuum` to verify bounded-memory
compaction and a second post-VACUUM reopen. Each run writes timings, per-phase
memory peaks, physical/logical sizes, WAL size, and native output to one JSON
report below `build/performance/capacity`.

```powershell
python .\tests\performance\capacity_regression.py --profile 1
python .\tests\performance\capacity_regression.py --profile 5
python .\tests\performance\capacity_regression.py --profile 10
```

Useful overrides:

```powershell
python .\tests\performance\capacity_regression.py --profile 1 --vacuum
python .\tests\performance\capacity_regression.py --profile 5 --chunk-mib 16 --max-private-mib 384
```

For legacy timing, stop the database, remove only the relevant
`tables\tN.tbl.heap-pages` file, and run the native capacity worker's `verify`
mode twice. The first process performs a complete classification and publishes
the map; the second demonstrates persistent restart performance. On the retained
1 GiB reference database the measured engine times were 71,453 ms cold and
1,093 ms warm, versus 1,368,140 ms before page-type indexing.

The offline `minisql-check.exe` path is intentionally stricter than the warm
logical scan: it validates every row value and derived index relationship. Its
row/leaf streaming implementation reduced the same retained 1 GiB database from
1,237.7 MiB to 98.1 MiB peak private memory. Full-check wall time remains a
physical overflow-I/O measurement and should be compared separately from the
heap-directory-assisted warm scan.

CRC-32C has a separate deterministic 64 MiB zero-buffer microbenchmark during
performance work. The table-driven implementation measured 375 ms versus 3,125
ms for the former bit-at-a-time loop, with the identical checksum `843410269`.
The retained 1 GiB full-check wall time correspondingly fell from 208,515 ms to
35,216 ms while retaining the 98.1 MiB private-memory bound.

With MiniLang's native SSE4.2 CRC-32C primitive, a 64-iteration run over the
same 64 MiB buffer processed 4 GiB in 297 ms, about 13.5 GiB/s or an average
4.64 ms per 64 MiB. The controlled table baseline compiled by the same compiler
was 359 ms per 64 MiB. The retained 1 GiB full checker completed in 3,683 ms
with the identical `tables=3 rows=1036 indexes=4` result and 98.1 MiB peak
private memory. CPUs without SSE4.2 use the exact table fallback.

`network_baseline.py` starts an isolated trusted-loopback server and compares
one-shot process/connect/query/close latency with persistent multi-statement
sessions. It warms the server before measuring, samples server private memory,
and writes raw JSON for concurrency levels 1, 2, 4, and 8 by default. Always use
a disposable or retained benchmark database rather than a production database.
Use `--query` to isolate a plan shape, `--one-shot-per-client 0` for a
persistent-only matrix, and `--buffer-pool-bytes` to generate an isolated server
configuration for cache-size controls.

The 2026-08-24 readiness and simple-COUNT implementation removes the earlier
four-client collapse. On the retained 64-row workload, median persistent
`COUNT(*)` throughput is now 1,079.8 / 1,551.7 / 1,943.8 / 2,028.5 / 1,988.9
statements/s at 1 / 2 / 4 / 8 / 16 clients. Use at least 1,000 statements per
session and three trials when comparing this plateau; short low-concurrency runs
are sensitive to Windows host activity.

`concurrent_indexed_reads.py` isolates persistent prepared primary-key lookups
across 1, 2, 4, 8, 16, and 32 sessions. On the 2026-08-29 Windows reference run,
replacing the cached-handle cursor lock with native positioned reads changed the
median matrix from 2,022 / 3,810 / 4,860 / 4,612 / 3,777 / 2,595 requests/s to
1,971 / 3,821 / 5,551 / 8,343 / 6,737 / 4,339 requests/s. The eight-client peak
improved by 71.7%; 16 and 32 clients improved by 78.4% and 67.2% respectively.
The one-client delta was -2.5%, within the run-to-run variation observed on the
host. A per-file completion-event pool was rejected because its semaphore and
registry traffic reduced eight-client throughput by 5.6%. The subsequently
measured query-local pool avoids synchronization on every page read and is
documented separately in
[`NATIVE_CONCURRENCY_2026-08-29.md`](NATIVE_CONCURRENCY_2026-08-29.md).

The same run sampled the server at 78.6 MiB working set / 132.3 MiB private bytes
when idle and 168.3 / 215.1 MiB during 32-client load. The settled memory remained
at the warm-cache level rather than returning to cold-start residency. Read-only
storage retained one table and one index handle; transient completion and client
job handles remained bounded by active or configured concurrency.

```powershell
$env:PYTHONPATH = (Resolve-Path .\clients\python).Path
python .\tests\performance\concurrent_indexed_reads.py `
  minisql://127.0.0.1:7551/main `
  --clients 1,2,4,8,16,32 --operations 250 --trials 3
```

`native_concurrent_indexed_reads.ml` runs the same prepared lookup entirely in
native MiniLang workers and reports exact framed-protocol byte counts. The
Windows profiler starts a fresh server for every trial and records throughput,
server CPU, host context switches, process I/O, TCP segments, memory and handle
peaks. Its port and maximum concurrency are validated against the supplied
server configuration.

```powershell
python ..\MiniLangCompilerPy\mlc_win64.py `
  .\tests\performance\native_concurrent_indexed_reads.ml `
  .\build\performance\native-concurrent-indexed-reads.exe `
  -I .\src -I ..\MiniLangCompilerPy --target windows-x64

.\tests\performance\profile_concurrent_reads.ps1 `
  -Server .\build\bin\minisqld.exe `
  -Benchmark .\build\performance\native-concurrent-indexed-reads.exe `
  -Database .\build\performance\connector-comparison\data\db_<id> `
  -Config .\build\performance\concurrent-read-config.json `
  -Port 7551 -Clients 8,16,32 -Operations 2000 -Trials 5 `
  -Output .\build\performance\native-profile.json
```

```powershell
python .\tests\performance\network_baseline.py `
  --server .\build\performance\baseline\bin\minisqld.exe `
  --client .\build\performance\baseline\bin\minisql.exe `
  --database .\build\performance\baseline\capacity-smoke-native-crc\db_<id> `
  --output .\build\performance\baseline\network-baseline.json
```
