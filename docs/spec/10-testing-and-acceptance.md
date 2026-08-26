# 10. Testing and acceptance

## 10.1 One cumulative launcher

Every delivered source archive exposes exactly one user-facing root acceptance launcher:

```powershell
.\test.ps1 -Compiler C:\path\to\mlc_win64.py -Target windows-x64
.\test.ps1 -Compiler C:\path\to\mlc_win64.py -Target linux-x64
```

The accepted compiler baseline is MiniLangCompilerPy or MiniLangCompilerML
1.1.0 or newer. It supplies both native targets, CRC-32C, SIMD, and the portable
standard-library contracts referenced by the source package; using an older
compiler is not a valid acceptance run.

There are no milestone-specific PowerShell wrappers. After this one launcher is approved,
it removes the Windows download marker from the rest of the tree, creates all runtime
directories and executes every accepted regression plus every test through the highest
milestone in the archive.

A Windows release milestone is accepted only when:

1. every mandatory source compiles to a valid native Windows x64 executable;
2. every process exits with its expected code and exact success output;
3. positive, negative, corruption and failure-injection paths pass;
4. no mandatory test is skipped;
5. the machine-readable result marks the candidate milestone `PASS`;
6. the launcher exits with code 0; and
7. the final output line is the exact cumulative `SUCCESS` line.

The launcher emits exactly one result ZIP. A static-only run validates source/package
contracts but is never milestone acceptance. Tests MUST NOT depend on hidden placeholder
files surviving extraction.

The `linux-x64` profile is a portable target gate, not the historical M0-M50
release gate. It cross-builds all five command-line applications and runs
representative native storage, protocol, workload, authentication, scheduler,
TLS, and release-contract tests through WSL. The Win32 Workbench, Windows ABI,
crash injection, packaging, and the complete 106-phase matrix remain in the
Windows profile.

A successful Linux gate proves the covered application and component contracts;
it does not currently prove sustained concurrent-server readiness. A separate
two-or-more-client regression remains mandatory before the Linux server can be
promoted beyond single-client evaluation.

## 10.2 Test classes

- deterministic unit and golden-vector tests;
- randomized reference-model tests;
- independent binary-layout calculations;
- process-level durability and lock tests;
- process termination and startup recovery tests;
- I/O failure injection;
- corruption, identity and checksum tests;
- later SQL differential tests, parser/protocol fuzzing, concurrency, disk-full, soak,
  performance and backup/restore verification.

## 10.3 Cumulative M6-M10R3 gate

The M6-M10R3 archive runs 30 ordered phases: repository/config/evidence checks; all application,
M0, M1, M2, M3, M4 and M5 regressions; WAL and transaction tests; checkpoint, recovery and
two crash scenarios; config/catalog tests; row/slotted/heap tests; overflow tests; and the
71-module M10 smoke gate.

The exact success line is:

```text
MiniSQL M6-M10R3 acceptance test: SUCCESS
```


## 10.4 Monotonic regression rule

An accepted milestone regression verifies the behavior and positive implementation state
introduced up to that milestone. It must not require later modules to remain stubs and must
not pin the current product version or global milestone to an old release. Exact current
package state is checked by the newest manifest/catalog gate.


## 10.5 Builtin-name collision rule

Internal engine calls must not use an unqualified identifier that can bind to a MiniLang
builtin when a package function of the same name exists. Public qualified APIs may retain
their stable name, but internal implementations use an unambiguous helper and the cumulative
static gate checks the exact call path. This rule was added after the M6-M10R1 WAL decoder
failure.


## 10.6 Package-safe concrete-type validation

Cross-package code must not compare `typeName(value)` with an unqualified concrete-struct
name. The package that defines a struct exposes a predicate implemented with the local
`value is StructType` form; callers invoke that predicate through their import alias. The
cumulative static gate rejects the short-name string comparison pattern. This rule was added
after the M6-M10R2 recovery failure.
