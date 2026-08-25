# Compiler performance-fix verification (2026-08-25)

This report independently rechecks MiniLang compiler revision `21c1bea`
(`Restore optimizer performance and target parity`) against the previously
measured revision `a5597f7`. Both variants compile the same MiniSQL product
source revision `04d1d27`; the only MiniSQL working-tree differences are test
fixture and performance-documentation changes.

The compiler fix adds guarded specialization for fallible byte-buffer results,
stable 16-byte user-function alignment, package-aware integer flow, and indexed
self-hosted analyses. Fresh MiniSQL binaries were built into
`build/performance/compiler-21c1bea-retest/bin`. Raw network and capacity JSON
is retained below `build/performance/compiler-21c1bea-retest`.

## Correctness

| Suite | Result |
| --- | --- |
| MiniLang Python compiler suite | **104/104 passed**, 0 failed, 0 skipped |
| MiniSQL aggregate suite | **106/106 passed** |

The MiniSQL result archive is
`build/MiniSQL_1.0.0_RESULTS_20260825-104759.zip`. The run includes concurrent
server/client integration, lock and deadlock handling, native TLS 1.3, recovery,
crash matrices, soak and performance guardrails, deterministic distribution
building, and the Workbench GUI test.

The freshly built `minisql-check.exe` has SHA-256
`C0A226BB6E25427A9819A5F3056919515DFB1CADD99BDA577A0F2708B9E5C8E6`,
matching the compiler's published fixed-point evidence.

## 64 MiB bounded storage writes

Seven fresh databases per compiler were created in interleaved order. Every
run wrote two 32 MiB chunks, reopened the database, verified an indexed point
lookup, scanned all rows, retained a bounded WAL, and remained below the memory
guardrail.

| Metric | `a5597f7` | `21c1bea` | Change |
| --- | ---: | ---: | ---: |
| Insert engine time | 2,906 ms | 2,781 ms | **-4.3% time / +4.5% throughput** |
| Insert process wall time | 3,093 ms | 2,891 ms | **-6.5% time / +7.0% throughput** |
| Peak private memory | 263.57 MiB | 263.57 MiB | unchanged |
| Fresh verification wall time | 156 ms | 156 ms | unchanged |

One old-compiler trial was a 4,452 ms engine-time outlier; medians are reported
and the other six old values range from 2,796 to 3,093 ms. The previous storage
regression is removed. The fixed compiler is also approximately 2.2% faster
than the earlier `5d61cf7` engine-time reference of 2,844 ms.

## Allocation-heavy parallel scan

Three interleaved long trials executed 1,000 persistent
`SELECT SUM(id) AS s FROM capacity_data;` statements per client. This is the
query shape that previously showed a consistent 5-8% multi-client regression.

| Clients | `a5597f7` stmt/s | `21c1bea` stmt/s | Change |
| ---: | ---: | ---: | ---: |
| 1 | 198.88 | 186.23 | -6.4% |
| 2 | 259.70 | 275.94 | **+6.3%** |
| 4 | 483.91 | 508.56 | **+5.1%** |
| 8 | 715.60 | 730.17 | **+2.0%** |
| 16 | 797.32 | 800.78 | +0.4% |

Single-client runs had opposing outliers and remain inconclusive. Every
multi-client median improved, so the former parallel-scan regression is no
longer present. Server peak private memory remained approximately 99.57 MiB for
both compilers.

An external `qemu-system-x86_64` process began consuming approximately one CPU
core at 09:39:59, part-way through the long matrix. Trials were interleaved, but
absolute throughput after that point is not comparable to an idle-host
baseline. The consistent multi-client recovery, the independent seven-trial
storage result recorded before QEMU started, and the matched loaded-host tests
are therefore reported separately.

## Retained 1 GiB database

Seven interleaved full offline-checker runs were performed while the external
VM load was present. Every run returned
`tables=3 rows=1036 indexes=4`.

| Compiler | Median checker wall time |
| --- | ---: |
| `a5597f7` | 3,392 ms |
| `21c1bea` | 3,325 ms |

The fixed compiler is **2.0% faster** in this recheck instead of the previously
observed 3.5% regression.

## Cached count under external CPU load

After QEMU started, both compiler variants developed the same severe absolute
4-client throughput reduction. Repeating a 2,000-statement session directly
under that stable loaded-host condition produced medians of 245.72 stmt/s for
`a5597f7` and 244.42 stmt/s for `21c1bea`, a neutral -0.5% delta.

One earlier `21c1bea` matrix exceeded the benchmark's 120-second per-client
timeout. Five immediate fixed-compiler reproductions and three old-compiler
controls completed with the same 32-35 second loaded-host wall time, and the
complete MiniSQL concurrent-server suite subsequently passed. The incident is
therefore retained as a host-contention observation, not classified as a new
compiler deadlock. An idle-host absolute COUNT baseline should be rerun after
the external VM is stopped.

## Native allocation churn and binary size

The native allocation benchmark performs 24 million allocations across 12
threads. Fifteen interleaved trials per compiler produced the same 94 ms median,
checksum `2939920344`, post-GC heap usage of 66,640 bytes, and 32 MiB committed
heap. The fix does not regress TLAB allocation throughput.

The fixed binaries are smaller than their `a5597f7` equivalents:

| Binary | Size change |
| --- | ---: |
| `minisqld.exe` | -95,744 bytes (-0.25%) |
| `minisql.exe` | -89,600 bytes (-0.27%) |
| `minisql-check.exe` | -57,856 bytes (-0.24%) |
| capacity worker | -56,832 bytes (-0.18%) |
| allocation benchmark | unchanged |

## Conclusion

Revision `21c1bea` fixes the MiniSQL regressions identified for `a5597f7` while
preserving correctness and memory bounds. Bounded storage writes and the 1 GiB
checker are faster, the prior multi-client `SUM` slowdown is gone, native TLAB
allocation is unchanged, and generated MiniSQL binaries are smaller.

`21c1bea` is suitable as the new functional and performance compiler baseline.
The only follow-up is an idle-host COUNT rerun to restore an uncontaminated
absolute throughput number; the loaded-host A/B result does not indicate a
compiler regression.
