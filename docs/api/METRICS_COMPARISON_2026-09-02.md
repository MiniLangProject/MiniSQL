# MiniSQL metrics refactoring comparison

This report compares the MiniDoc baseline generated from MiniSQL revision
`ea0aca002b05` before the metrics-driven refactoring with the regenerated
documentation from the working tree on 2026-09-02. The implementation was
compiled with MiniLang Compiler 1.2.0 and documented with MiniDoc 0.4.0 for
`windows-x64`.

## Outcome

The refactoring substantially reduced the worst control-flow hotspots without
changing SQL behavior, persistent formats, or public APIs. All 106 cumulative
release phases passed on the final source state. Focused statistics, DCL,
optimizer/executor, and Workbench tests also passed.

| Project metric | Before | After | Change |
| --- | ---: | ---: | ---: |
| Project files | 89 | 89 | 0 |
| Functions | 3,280 | 3,315 | +35 focused helpers |
| Source lines | 42,851 | 42,868 | +17 |
| Comment lines | 10,675 | 10,842 | +167 |
| Cyclomatic complexity, total | 18,008 | 18,026 | +0.10% |
| Cyclomatic complexity, average | 5.49 | 5.44 | -0.05 |
| Cyclomatic complexity, maximum | 113 | 84 | -25.7% |
| Cognitive complexity, total | 21,262 | 20,755 | -2.38% |
| Cognitive complexity, maximum | 290 | 150 | -48.3% |
| Duplicated lines | 2,181 / 5.09% | 2,125 / 4.96% | -56 / -0.13 percentage points |
| Clone groups | 380 | 367 | -13 |
| Maintainability index | 2.05 | 2.05 | unchanged |

The small increase in functions is intentional: action-specific schema,
statistics, binder, authorization, join, and Win32 event helpers replaced
large multi-purpose functions. Total cyclomatic complexity is therefore nearly
unchanged, while the maximums and cognitive nesting fell sharply.

## Refactored hotspots

| Function | Before cyclomatic / cognitive | After cyclomatic / cognitive |
| --- | ---: | ---: |
| `schema_history.buildAlterTable` | 108 / 290 | 12 / 11 |
| `statistics.decodeCatalog` | 83 / 278 | 24 / 49 |
| `binder.bindExpressionInternal` | 113 / 166 | 20 / 21 |
| `win32_client.runSession` | 82 / 214 | 14 / 19 |
| `executor.canonicalHashJoinCount` | cognitive 89 | 3 / 2 |
| `executor.authorizeStatement` | cyclomatic 54 | 22 / 21 |

The project-wide maximum now comes from a different, unchanged function. This
is why the project maximum is 84 even though each targeted function is below
that value.

## Documentation coverage note

MiniDoc 0.4.0 expands coverage from declaration summaries to separate API,
parameter, return-value, field, constant, global, and enum contracts. To avoid
comparing different denominators, both revisions were regenerated with the
same MiniDoc 0.4.0 executable and identical output settings.

| Documentation contract | Before | After |
| --- | ---: | ---: |
| API declarations | 3,774 / 3,774 (100%) | 3,809 / 3,809 (100%) |
| Fields | 1,628 / 1,628 (100%) | 1,628 / 1,628 (100%) |
| Enum variants | 86 / 86 (100%) | 86 / 86 (100%) |
| Parameters | 0 / 7,150 (0%) | 142 / 7,276 (1.95%) |
| Overall | 5,565 / 13,838 (40.22%) | 5,742 / 13,999 (41.02%) |
| Diagnostics | 3,293 warnings | 3,289 warnings |

The new action-specific helpers carry explicit `@param` contracts, so overall
coverage improves despite the larger API. Remaining diagnostics primarily
request parameter and return-value tags for pre-existing internal functions.
The acceptance test ratchets 100% declaration coverage and the improved 41.02%
overall floor.

## Performance and memory validation

The deterministic M20 workload was compiled twice with the same MiniLang 1.2.0
compiler: once from the unchanged `ea0aca002b05` source and once from the
refactored working tree. Fresh database directories were used for every run.

| M20 process workload | Before | After | Interpretation |
| --- | ---: | ---: | --- |
| 21-run wall-time median | 1,114.038 ms | 1,132.329 ms | +1.64%, inside observed host variance |
| 21-run wall-time p10 / p90 | 1,025.162 / 1,192.331 ms | 1,010.800 / 1,209.590 ms | overlapping distributions |
| 21-run median peak working set | 98.262 MiB | 98.461 MiB | +0.199 MiB (+0.20%) |
| 31 paired, CPU-affined median delta | - | -0.001% | no directional regression |

The CPU-affined series deliberately alternated the old and new executable for
31 pairs. Its paired median was effectively zero; its paired mean was +2.4%
while the per-process distributions continued to overlap. Taken together, the
measurements do not show a repeatable performance regression.

Persistent trusted-loopback `SELECT COUNT(*)` sessions used 1,000 statements
per client, three trials, and the same retained capacity database. Values below
are medians of the three throughput results.

| Concurrent clients | Before statements/s | After statements/s | Change |
| ---: | ---: | ---: | ---: |
| 1 | 262.833 | 260.002 | -1.08% |
| 4 | 582.763 | 572.418 | -1.78% |
| 8 | 738.904 | 742.781 | +0.52% |

All deltas are within the run-to-run spread and do not form a worsening trend
with concurrency. Median server peak private memory changed from 115.320 MiB
to 115.309 MiB.

The current-tree capacity guardrail additionally inserted 64 rows with 1 MiB
payloads (64 MiB logical data), restarted the database, performed a point
lookup, and fully verified all rows. It passed with a 331.8 MiB insertion peak
and about 98.1 MiB for point lookup and verification, below the configured
512 MiB limit.

## Test system and commands

- Microsoft Windows 11 Pro 10.0.26200, build 26200
- AMD Ryzen 9 9900X, 12 cores / 24 logical processors
- 61.61 GiB physical memory
- Windows Balanced power plan
- Python 3.11.9
- MiniLang Compiler 1.2.0
- MiniDoc 0.4.0

Validation commands:

```powershell
.\test.ps1 -KeepArtifacts
python .\tests\performance\capacity_regression.py --profile smoke
python .\tests\performance\network_baseline.py --concurrency 1,4,8 `
  --one-shot-per-client 0 --statements-per-session 1000 ...
..\MiniDoc\build\minidoc.exe --config .\minidoc.toml
```

The complete regenerated API reports are available in
[`markdown/Metrics.md`](markdown/Metrics.md) and
[`html/metrics.html`](html/metrics.html).
