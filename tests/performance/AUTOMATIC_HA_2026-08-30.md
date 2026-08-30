# Automatic HA and write-fencing qualification — 2026-08-30

This report measures the current automatic single-host HA implementation after
native write fencing was added. It is a focused availability and correctness
series, not a general SQL-throughput benchmark. The larger 1 GiB storage,
request-rate, CRC-32C, and memory baselines remain documented in the root
README and the other reports in this directory.

## Tested build and host

| Item | Value |
| --- | --- |
| MiniSQL source | working tree based on `b4cc13f`; automatic HA and fencing changes under qualification |
| Server | MiniSQL 1.0.0, SHA-256 `f6b91740e4882f70869027bc2c3937891e9fc3cb3658adb8bd4eb0d8e54e250a` |
| Processor | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Memory | 66,155,491,328 bytes installed (61.6 GiB) |
| Operating system | Windows 11 Pro x64, version 10.0.26200, build 26200 |
| Python | 3.11.9 |
| Date | 2026-08-30, Europe/Berlin |

The native applications were built before the run. Every trial used a fresh
database, fresh loopback ports, a fresh witness, and newly started server and
controller processes. Python bytecode generation was disabled.

## Method

The automatic failover test creates and seeds a database, starts the HA
controller, waits until its initial standby is materialized, kills the managed
leader, waits for a new epoch and leader, writes through the unchanged proxy
endpoint, and verifies both rows. Its controller configuration uses a 1,500 ms
lease, 100 ms maximum clock skew, and 300 ms replication interval.

The fencing drill starts two fenced terms around a stable endpoint. It proves
that a direct connection to the retired primary rejects a mutation as error
9038, verifies the promoted data, rejoins the old copy as a standby, requires
its mutation to fail as read-only error 9033, and finishes with the offline
integrity checker.

The following commands were each repeated with a distinct empty `--work-root`:

```powershell
python -B .\tests\ha\automatic_controller_live.py --work-root .\build\measure-ha-series\auto-1
python -B .\tests\ha\automatic_fencing_drill.py --work-root .\build\measure-ha-series\fencing-1
```

## Results

| Measurement | Trials | Minimum | Median | Mean | p95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| leader-kill to promoted serving leader | 10 | 1.469 s | 1.508 s | 1.583 s | 2.234 s | 2.234 s |
| complete automatic test | 10 | 3.015 s | 3.086 s | 3.233 s | 4.016 s | 4.016 s |
| complete fencing/integrity drill | 5 | 4.968 s | 5.016 s | 5.031 s | 5.078 s | 5.078 s |

All 10 automatic trials advanced epoch 1 to epoch 2 and retained both the
pre-failover and post-failover row. All five fencing trials returned 9038 from
the retired primary, returned 9033 from the rejoined standby, retained two
rows, and passed integrity validation. There were no failed trials.

### Raw seconds

| Run | Automatic recovery | Automatic total | Fencing total |
| ---: | ---: | ---: | ---: |
| 1 | 1.500 | 3.015 | 5.016 |
| 2 | 1.469 | 3.047 | 4.968 |
| 3 | 1.500 | 3.047 | 5.078 |
| 4 | 1.500 | 3.063 | 5.078 |
| 5 | 1.531 | 3.078 | 5.015 |
| 6 | 1.547 | 3.093 | — |
| 7 | 1.532 | 3.266 | — |
| 8 | 1.500 | 3.266 | — |
| 9 | 1.515 | 3.437 | — |
| 10 | 2.234 | 4.016 | — |

The p95 uses the nearest-rank observation. Recovery time begins immediately
before forced leader termination and ends when the controller has published a
new serving leader; it includes process termination, conservative lease/skew
waiting, standby promotion, native startup, and status publication.

## Interpretation and limits

The median is close to the configured 1.5-second lease by design. The 2.234 s
maximum shows host scheduling and process-start variation, so operational
budgets should use the tail rather than only the median. The series directly
qualifies single-host process failure and native split-brain rejection. It does
not measure host loss, network partitions between machines, synchronous commit
durability, consensus, storage-array fencing, or steady-state SQL throughput.
Those remain outside the file-witness design and require an external
consensus-backed authority for multi-host production use.
