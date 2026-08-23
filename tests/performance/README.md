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
