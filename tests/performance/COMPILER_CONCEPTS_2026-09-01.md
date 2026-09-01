# MiniLang compiler-concept evaluation — 2026-09-01

## Outcome

The current compiler features were evaluated as independent MiniSQL candidates,
then repeated against retained databases. Only native `copyArray` in the shared
`List` implementation remains: it is a clear **6.03x** microbenchmark win and
preserves the existing API and test behavior. The attempted executor rewrites,
persistent query pool, non-default heap/GC profiles, and broad predicate
inlining were reverted because their end-to-end results were neutral or slower.

This is intentionally a negative-results report as well as a performance report.
Compiler primitives are not automatically database optimizations; cache shape,
GC pressure, synchronization, and allocation lifetime still decide the complete
query cost.

## Test system and revisions

| Item | Value |
| --- | --- |
| CPU | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Memory | 61.6 GiB installed |
| OS | Windows 11 Pro x64, 10.0.26200 build 26200 |
| Python | 3.11.9 |
| MiniSQL base | `ef1bfb5df3cd3ae02e8678a609ba1ad7be4c407f` |
| Python compiler base | `2c2f87e06f473d3852a30c3b760eb5631ecf3075`, version 1.1.0 |
| Self-hosted compiler base | `f2f32a37ce045f705286ddd92eccbe6bf07ad63c` |

The operator fixture contains 3,000 rows in each of two retained tables. Every
server variant executes repeated high-cardinality sort, group, and hash-join
queries against exactly that fixture. Short comparisons alternate baseline and
candidate processes. Longer heap comparisons use 15 statements per operator.
The large-scan control repeatedly executes `SUM(id)` against the retained
64-MiB `capacity_data` database through one persistent loopback connection.
Windows private memory is `PROCESS_MEMORY_COUNTERS_EX.PrivateUsage`.

## Native array copy and `List`

`compiler_primitives.ml` performs 500 two-copy round trips over 65,536-element
arrays. Five fresh-process trials produced these medians:

| Implementation | Median | Relative speed |
| --- | ---: | ---: |
| Two MiniLang element loops | 187 ms | 1.00x |
| Two native `copyArray` calls | 31 ms | **6.03x** |
| `List.fromArray(...).toArray()` after the change | 31 ms | **6.03x** |

All modes returned checksum `124750`. `List.fromArray`, growth, `addAll`, and
`toArray` now use the overlap-safe, bounds-checked runtime primitive in both
compiler standard-library trees. The complete standard-library unit program,
including every List assertion and its TCP/UDP tail, passed once with the Python
compiler and once with the freshly bootstrapped self-hosted compiler.

## Rejected executor array rewrites

Preallocating sort/projection merge buffers looked attractive in isolation but
did not survive repeated end-to-end measurement. The combined variant changed
sort by about -3.0% elapsed time while making `GROUP BY` about 7.4% and hash
join about 3.6% slower. After isolating sort, a 15-trial median was 245.95 ms
versus 238.76 ms, a 3.0% regression. Both MiniSQL rewrites were reverted.

Cardinality-sized hash directories and indexed collision chains reduced peak
private memory from 240,267,264 to 223,195,136 bytes (**-7.1%**), but changed
the group median from 253.353 to 342.066 ms (**+35.0%**) and the join median
from 575.291 to 792.761 ms (**+37.8%**). This representation was also reverted.
The result identifies a useful future direction—compact native bucket storage—
but object/array traffic in the tested MiniLang representation costs too much.

## Persistent query-worker pool

The compiler's generic persistent pool is much faster than creating raw threads
in a synthetic dispatch test (31 versus 125 ms). Reusing one lazy four-worker
pool per database nevertheless reduced the real retained `SUM(id)` median from
160.53 to 118.59 statements/s (**-26.1%**) with essentially unchanged private
memory. The current query-local operator lifecycle is therefore retained. A
future scheduler needs operator-aware batching and completion, not merely a
longer-lived generic queue.

## Heap and GC profiles

The default executable reserves 4 GiB of virtual address space, initially
commits 32 MiB, uses a 64-MiB periodic threshold plus an 8-MiB young-allocation
threshold, and does not decommit after collection. Candidate builds used a
64-GiB reserve and the options shown below.

| Profile | Sort median | Group median | Join median | `SUM(id)` median | Operator peak / final private |
| --- | ---: | ---: | ---: | ---: | ---: |
| Default | **266.24 ms** | 362.67 ms | 823.60 ms | **148.49 stmt/s** | 229.13 / 229.13 MiB |
| 16-MiB GC + shrink | 326.04 ms | 374.35 ms | 889.78 ms | 148.26 stmt/s | **193.97 / 178.21 MiB** |
| 64-MiB GC + shrink | 375.86 ms | 404.89 ms | 896.22 ms | 123.02 stmt/s | 237.48 / 217.84 MiB |
| 256-MiB GC + shrink | 349.88 ms | **335.95 ms** | **591.83 ms** | 135.31 stmt/s | 406.06 / 378.34 MiB |

The lower-memory 16-MiB profile is useful as an explicit constrained-host mode,
but not as the default because sort/group/join latency regresses. Higher limits
retain too much garbage. A separately interleaved 500-statement scan measured
109.91 / 99.60 / 101.00 statements/s for default / 64-GiB-reserve-only /
64-GiB-reserve-with-shrink. Consequently no production build flag changed.

## Inlining and typed hot paths

Broadly inlining small value/type/expression predicates changed the interleaved
medians as follows:

| Variant | Sort | Group | Join |
| --- | ---: | ---: | ---: |
| Baseline | 235.50 ms | **278.49 ms** | **586.59 ms** |
| Broad inline predicates | **231.29 ms** | 290.61 ms | 696.19 ms |

Inlining only `isScannedRow` improved group by about 3.0% and join by 1.4%, but
regressed sort/scan by 6.4%. Both variants were reverted. The compiler already
specializes inferred arithmetic, and earlier typed-versus-dynamic arithmetic
was tied; annotations should therefore document and enforce contracts, not be
sprinkled through MiniSQL as speculative optimization hints.

## Retained changes and next work

The final clean application build was measured once more after all rejected
patches had been removed. Fifteen trials produced 235.00 ms sort, 286.29 ms
high-cardinality group, and 557.58 ms hash-join medians. Server private memory
was 98.61 MiB after startup and 229.14 MiB both at the sampled peak and after
the operator sequence. A final primitive run returned the same checksum and
measured 203 / 16 / 31 ms for manual / native / production-List copying; the
five-process medians above remain the less noise-sensitive comparison.

1. Keep native `copyArray` in both compiler `List` implementations.
2. Keep `compiler_primitives.ml` and `compiler_concepts.py` as reproducible
   gates for future compiler/runtime changes.
3. Keep current MiniSQL operator data structures, query-local scheduling, and
   default heap/GC profile.
4. Revisit hash storage only after MiniLang exposes compact primitive arrays or
   a native hash-table building block.
5. Revisit persistent scheduling with query-aware batches, work stealing, and
   one completion per operator rather than one synchronized job per partition.
