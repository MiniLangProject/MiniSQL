# MiniSQL test suite

The repository exposes exactly one user-facing launcher:

```powershell
.\test.ps1 -Compiler C:\path\to\mlc_win64.py -Target windows-x64
.\test.ps1 -Compiler C:\path\to\mlc_win64.py -Target linux-x64
```

Dynamic acceptance requires MiniLangCompilerPy or MiniLangCompilerML 1.1.0 or
newer so both targets, native `std.checksum.crc32c`, CPU dispatch, SIMD, and the
portable standard-library services used by the current source tree are
available.

The final cumulative Windows gate also executes the M78 production fault drill.
It uses a new isolated database and covers deterministic storage exhaustion,
committed/uncommitted native crash cases, incomplete TCP frames, a hard server
kill during acknowledged concurrent writes, restart and continued operation,
offline integrity, and fail-closed corruption detection on a cloned WAL.

The suite contains **106 cumulative phases** covering M0 through M50. It builds
and runs native Windows x64 applications and tests, process-level crash cases,
concurrent clients, TLS proxy integration, replication, fuzz/mutation inputs,
soak workloads, and deterministic release packaging.

That complete release gate is `windows-x64`. The `linux-x64` profile builds the
five command-line ELF applications and runs a focused portable suite through
WSL. It covers storage, a loopback protocol session, workload, authentication,
scheduler, two consecutive waves of four concurrent clients, OpenSSL TLS, and
release contracts, but omits the Win32 Workbench, Windows ABI/crash injection,
and Windows packaging. The second client wave is a regression gate for worker
job disposal and later connection acceptance; see
`tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md`.

A successful run ends with:

```text
MiniSQL 1.1.0 test suite: SUCCESS
```

and creates one archive:

```text
build\MiniSQL_1.1.0_RESULTS_<timestamp>.zip
```

Source-only validation:

```powershell
.\test.ps1 -StaticOnly
```

Internal native test programs live under `src/tests/`; fixtures, corpora,
reference layouts, and the Python orchestrator live under `tests/`. Do not run
internal test programs manually unless debugging a failure.
