# Compiler update performance report (2026-08-24)

This report measures the effect of compiling the same MiniSQL source revision
(`04d1d27`) with two MiniLang compiler revisions. It is an A/B compiler
comparison, not a comparison between different database implementations.

| Variant | Compiler revision | Relevant state |
| --- | --- | --- |
| Previous | `5d61cf7` | TLAB-enabled compiler before the latest optimizer/code-generator update |
| Current | `a5597f7` | Known-receiver method optimization, hot integer register homes, strength reduction, and subsequent optimizer hardening |

All measurements ran on the same Windows host and retained databases. Trials
were interleaved where practical to reduce thermal and background-load bias.
Reported values are medians. Raw JSON output is retained below
`build/performance/compiler-a5597f7`.

## Correctness

MiniSQL's 106 acceptance phases compiled and executed with the current
compiler. The original aggregate run reached all phases but waited on an
invisible confirmation dialog in the M74 GUI test: the test created a logically
blank worksheet while the hidden editor still contained its default
`SHOW TABLES;` text. The test now clears the editor before exercising the
close-without-confirmation path. The corrected M74 executable completes in
approximately 0.56 seconds and reports success.

The dialog was a test-fixture defect exposed by the run, not a compiler or
production GUI defect. After correcting the fixture, the complete aggregate
suite passed all 106 of 106 phases with compiler `a5597f7`. The result archive
is `build/MiniSQL_1.0.0_RESULTS_20260824-231314.zip`.

## 64 MiB storage-capacity smoke test

The capacity worker writes 64 MiB in bounded chunks and reopens the database to
verify it. Three trials were performed per compiler.

| Metric | Previous | Current | Change |
| --- | ---: | ---: | ---: |
| Insert engine time | 2,844 ms | 3,032 ms | **+6.6% slower** |
| Insert process wall time | 2,938 ms | 3,157 ms | **+7.5% slower** |
| Logical write throughput | 22.50 MiB/s | 21.11 MiB/s | **-6.2%** |
| Peak private memory | 263.6 MiB | 263.6 MiB | unchanged |
| Fresh verification wall time | 156 ms | 156 ms | unchanged |

The storage result is large enough to track as a regression, although additional
trials or a profiler are needed before attributing it to one optimizer pass.

## Loopback network query throughput

Each persistent client executed 1,000 cached `COUNT(*)` statements. Three
interleaved trials were run at every concurrency level.

| Clients | Previous stmt/s | Current stmt/s | Change |
| ---: | ---: | ---: | ---: |
| 1 | 1,290.2 | 1,338.2 | +3.7% |
| 2 | 1,827.8 | 1,877.6 | +2.7% |
| 4 | 2,108.6 | 2,103.2 | -0.3% |
| 8 | 2,197.0 | 2,118.2 | -3.6% |
| 16 | 2,176.6 | 2,159.4 | -0.8% |

These differences remain within the observed Windows run-to-run variation. The
current compiler is therefore neutral for the cached-count workload. Short
one-shot tests were noisier and are not used for the main conclusion.

An allocation-heavier `SELECT SUM(id)` scan used 300 statements per persistent
client and three interleaved trials:

| Clients | Previous stmt/s | Current stmt/s | Change |
| ---: | ---: | ---: | ---: |
| 1 | 197.4 | 208.6 | +5.7% |
| 2 | 349.2 | 330.6 | **-5.3%** |
| 4 | 520.6 | 479.7 | **-7.9%** |
| 8 | 733.2 | 692.9 | **-5.5%** |
| 16 | 848.9 | 799.2 | **-5.9%** |

The consistent multi-client result indicates a real 5–8% regression on this
query shape. Median server private memory was unchanged: 99.44 MiB for the
cached count and approximately 99.56 MiB for the sum scan with both compilers.

## Retained 1 GiB database

Seven interleaved trials used the retained 1 GiB capacity database.

| Operation | Previous | Current | Change |
| --- | ---: | ---: | ---: |
| Warm logical verifier, engine time | 78 ms | 94 ms | +20.5% |
| Warm logical verifier, wall time | 112 ms | 124 ms | +10.7% |
| Full offline checker, wall time | 2,999 ms | 3,105 ms | **+3.5% slower** |

The engine timer has approximately 15.6 ms granularity on this host, so the
logical-verifier percentage exaggerates a small absolute difference. The full
checker is the more stable result. Every run returned the expected 1,024
capacity rows and the checker result `tables=3 rows=1036 indexes=4`.

## Native allocation microbenchmark and binary size

The compiler's native thread-allocation benchmark ran 24 million allocations
across 12 threads. Both compilers had the same 110 ms median, checksum
`2939920344`, 32 MiB committed heap, and 66,672-byte post-GC heap. This suggests
that the TLAB refill primitive itself is not the source of the MiniSQL
regression.

Current-compiler binaries are modestly larger:

| Binary | Size change |
| --- | ---: |
| `minisqld.exe` | +120,832 bytes (+0.32%) |
| `minisql.exe` | +111,104 bytes (+0.33%) |
| `minisql-check.exe` | +61,952 bytes (+0.26%) |
| capacity worker | +66,048 bytes (+0.21%) |

## Conclusion

The new compiler is functionally compatible with MiniSQL and does not increase
measured process memory. It is not a performance upgrade for this MiniSQL
revision: cached `COUNT(*)` throughput is effectively neutral, while bounded
storage writes, the full checker, and allocation-heavy multi-client scans are
3–8% slower.

Before treating `a5597f7` as the new performance baseline, benchmark the
intermediate optimizer revision `e365d5b` to separate the optimizer feature
changes from the later correctness hardening, then profile the multi-client
`SUM` and capacity-write paths. In particular, inspect code-size growth,
known-receiver inlining decisions, hot-register homes, and strength-reduction
choices in the affected generated functions. Correctness hardening must not be
reverted merely to recover benchmark throughput.
