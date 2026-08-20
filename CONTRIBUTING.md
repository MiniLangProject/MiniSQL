# Contributing

## Development prerequisites

- Windows x64
- Python 3.11 or newer
- MiniLangCompilerPy with `mlc_win64.py`

## Build

```powershell
$compiler = "C:\path\to\MiniLangCompilerPy\mlc_win64.py"
.\build.ps1 -Compiler $compiler -AppsOnly
```

## Test

Use the single repository entry point:

```powershell
.\test.ps1 -Compiler $compiler
```

The complete run is cumulative and intentionally long. Source-only changes can
first be checked with:

```powershell
.\test.ps1 -StaticOnly
```

A contribution is ready for review when:

1. the source tree contains no generated executables, logs, databases, or cache
   files;
2. relevant unit/integration tests are added or updated;
3. the full cumulative suite ends with `MiniSQL 1.0.0 test suite: SUCCESS`;
4. persistent or wire-format changes include specification, compatibility, and
   upgrade documentation;
5. security-sensitive changes update `SECURITY.md` or the security guide.

## Style

- Retain the Apache-2.0 copyright/SPDX header in every MiniLang, Python and
  PowerShell source file.
- Keep `package ...` as physical line 1 in importable MiniLang modules and place
  the license header immediately after it; the current compiler discovers
  imported package identities before normal comment skipping. Executable
  entry-point files without a package keep the header at the top.
- Document every function, method, structure, enumeration and member in English.
  Describe contracts, ownership, side effects, errors and invariants where they
  matter; do not merely paraphrase individual statements.
- Explain non-obvious algorithms at the decision or invariant they depend on,
  especially storage layouts, recovery ordering, lock transitions, parser state,
  query planning and concurrent ownership.
- Keep MiniLang packages aligned with their paths.
- Preserve the existing two-space MiniLang indentation.
- Prefer explicit validation and structured MiniSQL errors over unchecked
  `void`-producing operations.
- Keep the one-launcher test contract: do not add additional root `test*.ps1`
  files.
- Do not commit `build/`, `data/`, `logs/`, `tmp/`, generated ZIP files, or local
  configuration containing secrets.
