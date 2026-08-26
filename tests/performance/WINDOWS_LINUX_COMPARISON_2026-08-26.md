# MiniSQL Windows x64 versus Linux x64 performance — 2026-08-26

## Executive summary

This comparison measures the new Windows x64 PE and Linux x64 ELF builds from
the same MiniSQL revision and the same MiniLang Python compiler on one physical
machine. Linux ran under WSL2, not on bare metal. Each target used its native
filesystem path: Windows used NTFS and Linux used WSL2 ext4; no Linux database
traffic crossed the slower `/mnt/c` translation layer.

The stable single-client result is mixed but encouraging:

- Persistent `SUM(id)` throughput is effectively tied: Linux is **1.9% slower**.
- Persistent `COUNT(*)` is **10.2% slower** on Linux.
- Linux one-shot process/connect/query/close latency is **21.5% lower** and
  throughput is **24.0% higher**.
- Linux warm restart verification is **12.5% faster in engine time** and **54.0%
  faster in measured process wall time**.
- The 64 MiB durable insert is Linux's clearest stable regression: **18.6% less
  engine throughput**.
- Linux reports substantially less private memory, although Windows
  `PrivateUsage` and Linux private mappings are close rather than identical
  accounting definitions.

The original measurement found a Linux concurrency blocker: Windows completed
the 1/4/8-client matrix, while Linux reproducibly failed or stalled with two or
more simultaneous clients. The original numbers and symptoms remain below as
historical evidence. A same-day follow-up fixed the root cause in MiniLang's
Linux thread runtime and passed the MiniSQL 1/2/4/8-client functional matrix;
see **Resolved follow-up** below. The follow-up is a correctness validation,
not a replacement for the original multi-trial performance comparison.

## Test environment

| Item | Value |
|---|---|
| Physical CPU | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Physical RAM | 61.6 GiB |
| Windows | Windows 11 Pro, 10.0.26200, balanced power plan |
| Windows filesystem | NTFS on `C:` |
| Linux | Ubuntu under WSL2, kernel 6.6.87.2-microsoft-standard-WSL2 |
| Linux userspace | glibc 2.39, OpenSSL 3.0.13, Python 3.12.3 |
| WSL2 resources | 24 logical processors, 30.2 GiB visible RAM |
| Linux filesystem | native WSL2 ext4 under `/home/<user>` |
| Windows Python | 3.11.9 |
| Compiler | MiniLang Python compiler 1.1.0 for both targets |

This is a target-runtime comparison on the available host, not a claim about
bare-metal Linux versus bare-metal Windows. WSL2 virtualization and the
different native filesystems are part of the measured Linux environment.

## Artifacts

| Artifact | Windows bytes | Linux bytes | Linux size change |
|---|---:|---:|---:|
| `minisqld` | 39,104,512 | 38,798,656 | -0.78% |
| `minisql` | 35,088,896 | 34,787,552 | -0.86% |
| capacity worker | 31,828,992 | 32,244,272 | +1.30% |

Artifact SHA-256 values:

- Windows server: `D8CC2EB507FE04381F8887E4CDFA430A9F71B41C3227C4F25C175FE26361C116`
- Linux server: `B45C438602710E0433ABFE1DC8165C6A6EA728012F31824A8CCE4D15DE2AA71C`
- Windows client: `28220589DF485EBDE0444F97CB0EEF20E25CD72D57556FFFCAA14AFD831BCD79`
- Linux client: `1FD75943EC6CAD7A04B09B928D7EE1DF6C01179FFC6D9E3E7BE4920CA33BD701`
- Windows capacity worker: `898AA18CCBE41A14B19D8527F329DF6B8E735DB1AE5A4879A6CB20B97779B4DC`
- Linux capacity worker: `FF50E91CE534B3325CFE2C9B077BA59E580BBE66730D63B71ED241FC5F1F56A6`

## Method

The durable workload creates a fresh database for each of three trials, then
inserts 64 rows with a 1 MiB external TEXT value per row in one transaction.
The reported engine time is measured inside MiniSQL around the insert and
commit path. Wall time includes native process startup and shutdown. The first
verification builds or validates the persistent heap-page directory; five
additional independent processes measure steady restart verification.

The loopback workload uses a retained 64-row/64-MiB database. Every network
trial warms metadata and filesystem caches before measurement. One-shot
`COUNT(*)` starts a new client process and connection for every request.
Persistent sessions execute 500 `COUNT(*)` or 200 `SUM(id)` statements over one
connection. Tables report the median of three trials. Five trials are used for
restart verification.

Windows private memory comes from
`PROCESS_MEMORY_COUNTERS_EX.PrivateUsage`. Linux private memory is the sum of
`Private_Clean`, `Private_Dirty`, and `Private_Hugetlb` from
`/proc/PID/smaps_rollup`, with resident memory as a restricted-system fallback.
The figures are useful for large differences but are not byte-for-byte
equivalent accounting systems.

## Storage and restart results

| Measurement | Windows median | Linux median | Linux change |
|---|---:|---:|---:|
| 64 MiB insert, engine time | 3,813 ms | 4,684 ms | **+22.8% time** |
| 64 MiB insert, process wall | 3.880 s | 4.744 s | **+22.2% time** |
| 64 MiB insert throughput | 16.79 MiB/s | 13.66 MiB/s | **-18.6%** |
| Insert peak private memory | 541.25 MiB | 479.28 MiB | **-11.4%** |
| First verify, engine time | 78 ms | 73 ms | **-6.4% time** |
| First verify, process wall | 0.155 s | 0.123 s | **-20.1% time** |
| Warm restart verify, engine time | 16 ms | 14 ms | **-12.5% time** |
| Warm restart verify, process wall | 0.067 s | 0.031 s | **-54.0% time** |
| Warm restart peak private memory | 98.10 MiB | 29.24 MiB | **-70.2%** |

The insert engine-time ranges were 3,625–3,968 ms on Windows and 4,637–5,180
ms on Linux. The database tree was exactly 69,434,813 bytes on both targets, so
the comparison processed the same logical and physical format.

The Linux insert regression is large enough to be treated as real on this host.
It is most likely in the platform file/durability path or WSL2/ext4 sync cost,
not in SQL semantics: read/restart verification is neutral to faster and the
database output size is identical. A bare-metal Linux run with block-device
flush tracing is needed to separate the ELF runtime from WSL2 storage latency.

## Stable single-client loopback results

The Windows figures in this table come from separate one-client-only control
runs, matching the Linux one-client-only runs. This avoids attributing cache or
memory left by the Windows 4/8-client phases to the one-client comparison.

| Measurement | Windows median | Linux median | Linux change |
|---|---:|---:|---:|
| One-shot `COUNT(*)` throughput | 32.07 req/s | 39.76 req/s | **+24.0%** |
| One-shot median latency | 31.82 ms | 24.97 ms | **-21.5%** |
| Persistent `COUNT(*)`, one client | 232.95 stmt/s | 209.21 stmt/s | **-10.2%** |
| Persistent `SUM(id)`, one client | 125.38 stmt/s | 122.94 stmt/s | **-1.9%** |
| `COUNT(*)` server peak private memory | 98.47 MiB | 37.10 MiB | **-62.3%** |
| `SUM(id)` server peak private memory | 98.47 MiB | 50.25 MiB | **-49.0%** |

Linux one-shot results were stable at 38.894–40.314 requests/s. Persistent
Linux results were 209.107–216.245 statements/s for `COUNT(*)` and
121.394–123.313 statements/s for `SUM(id)`. The one-client steady-state result
therefore shows no broad Linux code-generation regression; the differences are
query/path specific.

## Original parallel-client result and blocker

Windows completed all three trials:

| Query | 1 client | 4 clients | 8 clients |
|---|---:|---:|---:|
| Persistent `COUNT(*)` | 217.78 stmt/s | 239.83 stmt/s | 237.76 stmt/s |
| Persistent `SUM(id)` | 124.96 stmt/s | 180.67 stmt/s | 202.84 stmt/s |

The Linux matrix has no corresponding throughput table because it did not
complete correctly. Repeated diagnostics produced all of these symptoms:

- four-client one-shot `COUNT(*)`: client timed out after 60 seconds;
- four-client persistent session with only ten statements: client timed out
  after 120 seconds;
- four-client mixed run: `platform.network.receiveExact: recv failed (11)`,
  where Linux errno 11 is `EAGAIN`/`EWOULDBLOCK`;
- two-client persistent run: one client completed six statements, then reported
  `connection closed before frame completed`.

A one-client 100-statement diagnostic completed normally at 196.286
statements/s. Shortening the sessions therefore does not remove the parallel
failure; adding the second client is the meaningful trigger.

This blocks a valid Windows/Linux parallel performance claim. Investigation
should cover accepted-socket nonblocking state, retry handling for transient
`EAGAIN`, pool job lifecycle/reaping, and connection shutdown while another
worker is active. A regression test must repeatedly connect at two, four, and
eight clients on Linux before the benchmark is repeated.

## Resolved follow-up

The compiler runtime had created Linux workers with raw `clone(2)` while the
standard library and MiniSQL called glibc, pthread synchronization, malloc, and
OpenSSL from those workers. Raw clones did not receive independent glibc TLS,
which broke recursive-mutex ownership and could corrupt libc allocator state.
The Linux runtime now uses `pthread_create`/`pthread_join`, preserves MiniLang's
Win64-compatible nonvolatile XMM register contract across SysV calls, and uses
`exit_group` for process-wide termination. MiniSQL's socket loops also retry
transient `EINTR`/`EAGAIN` readiness conditions.

Validation on the same WSL2 host completed all of the following:

- 40 short-lived queries from two simultaneous client launchers;
- the full one-shot matrix with 20 requests per client at 1/2/4/8 clients;
- 100-statement persistent sessions at 1/2/4/8 clients;
- the portable MiniSQL gate, including two successive waves of four concurrent
  native clients and exact server request draining;
- native OpenSSL trust, pin, hostname, and authenticated-session tests.

The single functional rerun produced these non-baseline throughput values:

| Clients | One-shot requests/s | Persistent statements/s |
|---:|---:|---:|
| 1 | 36.136 | 188.677 |
| 2 | 41.097 | 220.187 |
| 4 | 40.607 | 217.373 |
| 8 | 40.001 | 218.170 |

No client timed out, no connection closed early, and no `EAGAIN` escaped into
the protocol layer. A new multi-trial Windows/Linux run is still required for
comparative performance conclusions, but the concurrent Linux correctness
blocker described in the original report is closed.

## Interpretation

1. **Do not describe one target as globally faster.** Linux wins process-heavy
   startup/restart and memory measurements; Windows wins durable 64 MiB writes
   and persistent `COUNT(*)`; `SUM(id)` is essentially tied.
2. **The original Windows parallel numbers remain the only multi-trial baseline.**
   The follow-up closes Linux correctness but does not manufacture comparable
   performance evidence from a single functional run.
3. **Linux now has focused concurrent-server validation.** The stable c1 query
   numbers, identical database size, successful storage verification, 1/2/4/8
   rerun, and two-wave acceptance case establish functional viability.
4. **Keep correctness and performance gates separate.** The fixed lifecycle is
   covered by acceptance; a fresh interleaved benchmark must measure speed.
5. **Repeat on bare-metal Linux.** That run is required before making release
   claims about durable-write performance or WSL2's large apparent memory win.

## Reproduction and raw data

The common runner is `tests/performance/platform_compare.py`. The complete
Windows matrix used:

```powershell
python .\tests\performance\platform_compare.py `
  --label windows-x64 `
  --worker .\build\performance\platform-compare-20260826\bin\capacity-worker.exe `
  --server .\build\bin\minisqld.exe `
  --client .\build\bin\minisql.exe `
  --data-root .\build\performance\platform-compare-20260826\windows-data `
  --output .\build\performance\platform-compare-20260826\windows.json `
  --trials 3 --storage-mib 64 --payload-kib 1024 --verify-trials 5 `
  --concurrency 1,4,8 --one-shot-per-client 10 `
  --count-statements 500 --sum-statements 200
```

The successful Linux c1 control used the same parameters except
`--concurrency 1`, with binaries and data under native WSL2 ext4. The failed
Linux parallel attempt used `--concurrency 1,4,8`.

Generated raw files are retained locally below
`build/performance/platform-compare-20260826`:

- `windows.json` — complete Windows storage and 1/4/8-client matrix;
- `linux-c1.json` — complete Linux storage and one-client matrix;
- `windows-c1-count-*.json` and `windows-c1-sum-*.json` — isolated Windows c1
  memory controls;
- `linux-diagnostic-c1.json` — successful short Linux control;
- diagnostic `.sql` files and command output for the failed parallel attempts.

The primary raw-report hashes are:

- `windows.json`: `6AE92BDD59CB521EBCE39877E46AE7DC665496312574BD33B2AF4E78C388FB95`
- `linux-c1.json`: `BDDA23DEFF79D896D9B01145138E5F29CF6A04F3862113DBC87603263B69B677`

Generated databases remain under the corresponding Windows benchmark directory
and `/home/<user>/minisql-platform-compare-20260826` in WSL2. They are disposable
benchmark data, not production databases.
