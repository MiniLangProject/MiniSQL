# MiniSQL test suite

The repository exposes exactly one user-facing launcher:

```powershell
.\test.ps1 -Compiler C:\path\to\mlc_win64.py
```

The suite contains **106 cumulative phases** covering M0 through M50. It builds
and runs native Windows x64 applications and tests, process-level crash cases,
concurrent clients, TLS proxy integration, replication, fuzz/mutation inputs,
soak workloads, and deterministic release packaging.

A successful run ends with:

```text
MiniSQL 1.0.0 test suite: SUCCESS
```

and creates one archive:

```text
build\MiniSQL_1.0.0_RESULTS_<timestamp>.zip
```

Source-only validation:

```powershell
.\test.ps1 -StaticOnly
```

Internal native test programs live under `src/tests/`; fixtures, corpora,
reference layouts, and the Python orchestrator live under `tests/`. Do not run
internal test programs manually unless debugging a failure.
