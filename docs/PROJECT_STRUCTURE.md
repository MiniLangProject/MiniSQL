# Project structure

```text
MiniSQL/
├── config/  # configuration schema and example
├── docs/  # specifications, formats, ADRs, release and acceptance documentation
├── src/apps/  # five executable entry points
├── src/minisql/  # 74 database-engine modules
├── src/tests/  # native MiniLang regression and integration tests
├── tests/  # single Python orchestrator, fixtures, corpora and references
├── tools/  # quality, release and replication tooling
├── README.md  # project overview and quick start
├── build.ps1  # build applications or the full native test set
├── test.ps1  # only user-facing cumulative test launcher
├── release.ps1  # build and verify the 1.0.0 binary distribution
├── clean.ps1  # remove generated build output
```

## Engine modules by subsystem

- `src/minisql/catalog/`: 4 module(s)
- `src/minisql/client/`: 3 module(s)
- `src/minisql/common/`: 9 module(s)
- `src/minisql/config/`: 3 module(s)
- `src/minisql/executor/`: 8 module(s)
- `src/minisql/planner/`: 5 module(s)
- `src/minisql/platform/`: 7 module(s)
- `src/minisql/protocol/`: 4 module(s)
- `src/minisql/server/`: 4 module(s)
- `src/minisql/sql/`: 9 module(s)
- `src/minisql/storage/`: 10 module(s)
- `src/minisql/tools/`: 3 module(s)
- `src/minisql/transaction/`: 5 module(s)

The complete package/path inventory is machine-readable in
`docs/module-catalog.json`; the repository file inventory used by the test gate is
`tests/manifest.json`.
