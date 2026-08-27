# Optimizer and execution expansion — 2026-08-27

This report records the focused Windows validation for transitive join
constants, multi-index access, disk-backed hash operators, bounded result
frames, and native intra-query partition workers.

## Persistent loopback results

Each access-path trial used one fresh trusted-loopback server, three warm-up
queries, 200 statements per persistent client, and the retained M75 fixture.
The controls preserve result cardinality but wrap indexed columns in `+ 0`,
which deliberately prevents direct index matching.

| Workload | Clients | Optimized statements/s | Control statements/s | Change |
| --- | ---: | ---: | ---: | ---: |
| Two-index `AND` intersection | 1 | 97.397 | 39.205 | **+148.4% (2.484x)** |
| Two-index `AND` intersection | 4 | 146.187 | 95.473 | **+53.1% (1.531x)** |
| Complete `OR` index union | 1 | 95.542 | 34.931 | **+173.5% (2.735x)** |
| Complete `OR` index union | 4 | 139.832 | 86.917 | **+60.9% (1.609x)** |
| Transitive peer constant | 1 | 86.711 | 86.930 | -0.3% |
| Transitive peer constant | 4 | 134.330 | 137.615 | -2.4% |

The first transitive trial exposed an overly pessimistic parameterized-index
cost and redundant re-evaluation of a peer predicate already guaranteed by the
join probe. Aligning the per-match cost with the shared-reader ordinary index
scan and proving that simple probe predicate removed a 2x regression. The final
single trial is at practical parity on this deliberately tiny 5-by-200-row
fixture; its main benefit is enabling selective peer access on larger tables.

Peak server private memory was 98.8 MiB for intersection and union, 115.0 MiB
for the intersection scan control, and 98.8 MiB for both final transitive
variants. These are process peaks, not operator-only allocations.

## Correctness and memory bounds

- Statistics sidecar format 5 persists equi-depth compact numeric/date
  histograms, hashed text/binary/wide-decimal MCVs, and composite tuple MCVs;
  focused migration tests read formats 1 through 4.
- M46 forces a 200-row hash build over the 128-row threshold, verifies 800
  LEFT-join matches, and groups 200 rows into 50 groups. Both operators use
  validated `MSSPILL1` partitions and up to four native workers.
- M18 transfers 1,200 ordered rows in three continuation frames and validates
  transparent client reassembly.
- The complete native Windows suite passed **106/106**. Result archive:
  `build/MiniSQL_1.0.0_RESULTS_20260827-212817.zip`.

## Test system

| Item | Value |
| --- | --- |
| MiniSQL baseline | `1d8723f1d6717fd71c1ba4f1f00ece6db7313ea3` plus this report's changes |
| MiniLang compiler revision | `62cd18f` |
| Compiler | MiniLang Compiler 1.1.0, native Windows x64 output |
| Operating system | Microsoft Windows 11 Pro 10.0.26200, build 26200 |
| Processor | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Installed memory | 66,155,491,328 bytes (61.6 GiB) |

Generated JSON reports remain under `build/performance/optimizer-expansion-*.json`
and are intentionally excluded from the source tree.
