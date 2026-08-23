# Performance tests

Repeatable storage and query benchmarks live here. Correctness tests remain mandatory;
performance measurements may never replace durability or semantic validation.

`capacity_regression.py` provides restart-aware `1`, `5`, and `10` GiB profiles
plus a fast `smoke` profile. Each process writes a bounded chunk, so the test
does not confuse process-heap growth with database capacity. The driver checks
large TEXT overflow storage, grouped and paginated reads, page-cache reuse,
recovery after every chunk, a fresh-process indexed point lookup, and the
configured WAL checkpoint bound. The default 32 MiB write chunks and every
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
