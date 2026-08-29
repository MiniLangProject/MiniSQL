# Native concurrent indexed-read profile — 2026-08-29

## Result

The native workload confirms that MiniSQL's post-eight-client throughput decline
is inside the server and is not caused by Python's interpreter or GIL. Reusing a
query-local Windows `OVERLAPPED` completion event produces a small but repeatable
improvement. It does not remove the larger scheduler/context-switch bottleneck.

| Clients | Event per page, req/s | Query-local reuse, req/s | Change | CPU cores, reuse | Host context switches/request, before → after |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 8 | 7,473.14 | **7,529.41** | **+0.75%** | 5.422 | 19.93 → 20.05 |
| 16 | 5,505.85 | **5,657.71** | **+2.76%** | 6.225 | 39.54 → **36.87** |
| 32 | 3,396.31 | **3,442.16** | **+1.35%** | 5.005 | 58.79 → **56.60** |

The final path lends one event to each active index-handle lease. Page reads in
that lease remain sequential and reuse the event; simultaneous queries never
share it. Idle events return to a database-owned pool, bounded by peak observed
query concurrency. Linux bypasses this pool because `pread` needs no completion
event.

## Workload and method

- Host: AMD Ryzen 9 9900X, 12 cores / 24 logical processors; Windows 11 Pro.
- Compiler: MiniLang Python compiler 1.1.0, native Windows x64 target.
- Data: 10,000-row `connector_seed` table with a primary-key B+ tree.
- Query: session-local prepared `SELECT metric FROM connector_seed WHERE id = ?`.
- Connections: persistent native MiniLang clients over trusted loopback TCP.
- Warm-up: 16 reads per worker plus a separate 100-read server warm-up.
- Measurement: 2,000 reads per client, five trials at each level, median shown.
- Isolation: every trial starts a fresh server, preventing completed connection
  jobs and warm process resources from carrying into the next concurrency level.
- A/B control: both server binaries came from the same source and compiler; the
  only switch was whether the index probe requested a reusable read context.

`native_concurrent_indexed_reads.ml` aligns all workers with a native event,
validates every scalar result, and reports the protocol byte deltas around only
the measured operations. `profile_concurrent_reads.ps1` samples the server and
Windows raw counters around that interval. Context-switch counts are host-wide,
so they include a small amount of unrelated system activity.

## Final-path resource profile

| Clients | Requests/s | Physical reads/request | Read KiB/request | Protocol bytes/request | TCP segments/request | Peak working set | Peak private | Peak handles |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 8 | 7,529.41 | 5.172 | 20.69 | 158.76 | 8.091 | 88.66 MiB | 148.94 MiB | 264 |
| 16 | 5,657.71 | 5.157 | 20.63 | 158.76 | 8.112 | 124.14 MiB | 181.84 MiB | 311 |
| 32 | 3,442.16 | 5.150 | 20.60 | 158.78 | 8.127 | 224.88 MiB | 280.24 MiB | 406 |

The protocol and storage volume per request remain almost constant as
concurrency rises. Server CPU use peaks near six logical cores at 16 clients,
then falls to five while throughput also falls. At the same time, host context
switches per request rise sharply. These relationships point to connection-job
scheduling and wake-up frequency as the next optimization target, rather than
network payload size or storage amplification.

Event reuse adds at most one kernel handle per simultaneous index query. In this
run the median handle peaks increased from 259/300/381 to 264/311/406 at
8/16/32 clients. The pool retains those handles until database close; it does
not grow per request. Short-run memory peaks varied in both directions and do
not support a memory-improvement claim.

## Reproduction

Compile `tests/performance/native_concurrent_indexed_reads.ml` and a current
`minisqld`, then run:

```powershell
.\tests\performance\profile_concurrent_reads.ps1 `
  -Server .\build\bin\minisqld.exe `
  -Benchmark .\build\performance\native-concurrent-indexed-reads.exe `
  -Database .\build\performance\connector-comparison\data\db_<id> `
  -Config .\build\performance\concurrent-read-config.json `
  -Port 7551 -Clients 8,16,32 -Operations 2000 -Trials 5 `
  -Output .\build\performance\native-profile.json
```

Generated JSON and server logs remain ignored build artifacts. The committed
report retains the medians needed for regression comparisons.
