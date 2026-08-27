# Comma-FROM join residual evaluation — 2026-08-27

This report measures the optimization that promotes a safe top-level equality
from a legacy comma-separated `FROM` list to an INNER-join edge and removes the
same, already guaranteed equality from the residual `WHERE` filter.

## Result

The optimized comma spelling is at throughput parity with the equivalent
explicit `INNER JOIN`. Compared with the three retained pre-fix comma trials,
its median throughput increased by 29.91% at one client, 13.97% at four clients,
and 20.41% at eight clients. Peak server private memory remained 115.3 MiB.

| Persistent clients | Explicit INNER JOIN | Optimized comma FROM | Comma vs. explicit | Old comma FROM | New vs. old comma |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 51.594 statements/s | 51.293 statements/s | -0.58% | 39.482 statements/s | +29.91% |
| 4 | 102.431 statements/s | 102.277 statements/s | -0.15% | 89.744 statements/s | +13.97% |
| 8 | 115.335 statements/s | 118.821 statements/s | +3.02% | 98.677 statements/s | +20.41% |

The three optimized-comma trials were 49.734/51.844/51.293 statements/s at one
client, 102.277/102.353/102.060 at four clients, and
116.038/119.519/118.821 at eight clients. The narrow spread at four and eight
clients and the small bidirectional difference from explicit syntax indicate
parity rather than a syntax-specific advantage.

Median amortized wall time per statement was 19.496 ms, 9.777 ms, and 8.416 ms
for optimized comma syntax at 1/4/8 clients. The corresponding explicit values
were 19.382 ms, 9.763 ms, and 8.670 ms. Median peak server private memory was
115.305 MiB for comma syntax and 115.312 MiB for explicit syntax.

## Method

The benchmark used fresh `build/acceptance` server and client executables from
the complete successful 106-test build. Each trial started an isolated trusted
loopback server on a dynamically selected port, warmed it with three queries,
and ran 300 statements per persistent client at concurrency 1, 4, and 8. There
were no one-shot client processes in the measured matrix.

The six trials used the mirrored `A-B-B-A-A-B` order to reduce drift, where A
was explicit syntax and B was comma syntax. Every trial used a fresh server
process but the same retained M75 database: five rows in `optimizer_small`, 200
rows in `optimizer_large`, and 200 equality matches. Windows filesystem caches
were warm; no privileged cache flush was performed.

The compared statements were:

```sql
SELECT COUNT(*)
FROM (
  SELECT s.id AS sid, l.id AS lid
  FROM optimizer_small s
  INNER JOIN optimizer_large l ON s.join_key = l.join_key
) q;

SELECT COUNT(*)
FROM (
  SELECT s.id AS sid, l.id AS lid
  FROM optimizer_small s, optimizer_large l
  WHERE s.join_key = l.join_key
) q;
```

`EXPLAIN` and the M75 regression verify that the second query contains a costed
`Hash Join` and no residual `Filter`. Separate regressions prove that unrelated
AND conjuncts remain active and that an equality below OR is neither promoted
nor removed.

The raw reports are generated below `build/performance/comma-join` as
`optimized-explicit-{1,2,3}.json` and `optimized-comma-{1,2,3}.json`. They can be
reproduced with `tests/performance/network_baseline.py`, `--concurrency 1,4,8`,
`--one-shot-per-client 0`, and `--statements-per-session 300`.

## Test system

| Item | Value |
| --- | --- |
| Baseline MiniSQL revision | `8a4a8e7ee1ca7a4fd75f4addd44bbf1434c00f17` plus the residual-elimination change in this report |
| MiniLang compiler revision | `86dc320` |
| Compiler | MiniLang Compiler 1.1.0, native Windows x64 output |
| Operating system | Microsoft Windows 11 Pro 10.0.26200, build 26200 |
| Processor | AMD Ryzen 9 9900X, 12 cores / 24 logical processors |
| Installed memory | 66,155,491,328 bytes (61.6 GiB) |

## Correctness gate

Before measurement, focused M12, M16, and M75 tests passed, static validation
passed, and the complete suite finished 106/106 with result archive
`MiniSQL_1.0.0_RESULTS_20260827-121742.zip`.
