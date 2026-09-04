# `src/apps/minisql_backup/main.ml`

[Home](README.md) · [Files](Files.md)

Provides apps minisql backup main facilities for this project.

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

Performs the main operation for the apps minisql backup main module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line or caller-supplied arguments. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_backup/main.ml#L37)

<a id="function-function-runpitr-function-runpitr-archivepath-databasepath-targettext-src-apps-minisql-backup-main-ml-2026942780"></a>
### runPitr

```ml
function runPitr(archivePath, databasePath, targetText)
```

Runs point-in-time recovery using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — | Path associated with archive. |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `targetText` | `dynamic` | — | targetText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_backup/main.ml#L17)
