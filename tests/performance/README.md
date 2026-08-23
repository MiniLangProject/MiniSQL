# Performance tests

Repeatable storage and query benchmarks live here. Correctness tests remain mandatory;
performance measurements may never replace durability or semantic validation.

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
