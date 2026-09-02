# `src/apps/minisql_backup/main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **no**

## Imports

- `minisql/tools/backup.ml` as `backup` → [src/minisql/tools/backup.ml](File-src-minisql-tools-backup-ml-1706031693.md)

## Declarations

<a id="function-function-main-function-main-args-src-apps-minisql-backup-main-ml-1540004998"></a>
### main

```ml
function main(args)
```

Implements main for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_backup/main.ml#L31)

<a id="function-function-runpitr-function-runpitr-archivepath-databasepath-targettext-src-apps-minisql-backup-main-ml-2026942780"></a>
### runPitr

```ml
function runPitr(archivePath, databasePath, targetText)
```

Runs point-in-time recovery using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `targetText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_backup/main.ml#L12)
