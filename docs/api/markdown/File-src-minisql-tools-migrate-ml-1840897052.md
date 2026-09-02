# `src/minisql/tools/migrate.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.tools.migrate`](Package-minisql-tools-migrate-1071527428.md)

Reachable from entry: **no**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/config/model.ml` as `config_model` → [src/minisql/config/model.ml](File-src-minisql-config-model-ml-1120384851.md)
- `minisql/executor/dml.ml` as `dml` → [src/minisql/executor/dml.ml](File-src-minisql-executor-dml-ml-1278137778.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/tools/check.ml` as `check` → [src/minisql/tools/check.ml](File-src-minisql-tools-check-ml-1674943447.md)

## Declarations

<a id="function-function-minisql-tools-migrate-componentname-function-componentname-src-minisql-tools-migrate-ml-1107592574"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L245)

<a id="function-function-minisql-tools-migrate-copydatabasestate-function-copydatabasestate-source-target-targetname-targetpagesize-src-minisql-tools-migrate-ml-650216265"></a>
### copyDatabaseState

```ml
function copyDatabaseState(source, target, targetName, targetPageSize)
```

Implements copy database state for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |
| `targetName` | `dynamic` | — |  |
| `targetPageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L135)

<a id="function-function-minisql-tools-migrate-fail-function-fail-code-operation-message-src-minisql-tools-migrate-ml-814689475"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L54)

<a id="constant-constant-minisql-tools-migrate-invalid-argument-const-invalid-argument-9001-src-minisql-tools-migrate-ml-1725040445"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

M20 migration planner. Format-affecting changes are never performed in place. This milestone validates and reports the required rewrite, and refuses a page- size change before touching source files. The full row/index rewrite engine is intentionally a later, separately crash-tested migration milestone.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L24)

<a id="function-function-minisql-tools-migrate-isimplemented-function-isimplemented-src-minisql-tools-migrate-ml-888021686"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L259)

<a id="function-function-minisql-tools-migrate-ismigrationplan-function-ismigrationplan-value-src-minisql-tools-migrate-ml-182064137"></a>
### isMigrationPlan

```ml
function isMigrationPlan(value)
```

Returns whether the supplied value satisfies the migration plan condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L61)

<a id="function-function-minisql-tools-migrate-ismigrationreport-function-ismigrationreport-value-src-minisql-tools-migrate-ml-217277183"></a>
### isMigrationReport

```ml
function isMigrationReport(value)
```

Returns whether the supplied value satisfies the migration report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L68)

<a id="function-function-minisql-tools-migrate-isrewritemigrationreport-function-isrewritemigrationreport-value-src-minisql-tools-migrate-ml-237193215"></a>
### isRewriteMigrationReport

```ml
function isRewriteMigrationReport(value)
```

Returns whether the supplied value satisfies the rewrite migration report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L128)

<a id="function-function-minisql-tools-migrate-m0selftestline-function-m0selftestline-src-minisql-tools-migrate-ml-1875327406"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Implements m0 self test line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L231)

- [minisql.tools.migrate.MigrationPlan](Type-minisql-tools-migrate-migrationplan-986573829.md) — struct
- [minisql.tools.migrate.MigrationReport](Type-minisql-tools-migrate-migrationreport-394208396.md) — struct
<a id="function-function-minisql-tools-migrate-plan-function-plan-databasepath-targetpagesize-src-minisql-tools-migrate-ml-1655898931"></a>
### plan

```ml
function plan(databasePath, targetPageSize)
```

Plans plan using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `targetPageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L83)

<a id="function-function-minisql-tools-migrate-rewrite-function-rewrite-sourcepath-targetroot-targetname-targetpagesize-src-minisql-tools-migrate-ml-896233668"></a>
### rewrite

```ml
function rewrite(sourcePath, targetRoot, targetName, targetPageSize)
```

Rewrites rewrite using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sourcePath` | `dynamic` | — |  |
| `targetRoot` | `dynamic` | — |  |
| `targetName` | `dynamic` | — |  |
| `targetPageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L187)

- [minisql.tools.migrate.RewriteMigrationReport](Type-minisql-tools-migrate-rewritemigrationreport-1719234532.md) — struct
<a id="function-function-minisql-tools-migrate-run-function-run-databasepath-targetpagesize-src-minisql-tools-migrate-ml-1712100661"></a>
### run

```ml
function run(databasePath, targetPageSize)
```

Runs run using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `targetPageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L98)

<a id="function-function-minisql-tools-migrate-targetmilestone-function-targetmilestone-src-minisql-tools-migrate-ml-1502003504"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L252)

<a id="constant-constant-minisql-tools-migrate-unsupported-format-const-unsupported-format-9003-src-minisql-tools-migrate-ml-1240145311"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L25)

<a id="function-function-minisql-tools-migrate-validpagesize-function-validpagesize-value-src-minisql-tools-migrate-ml-1787304839"></a>
### validPageSize

```ml
function validPageSize(value)
```

Implements valid page size for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L75)

<a id="function-function-minisql-tools-migrate-versionline-function-versionline-src-minisql-tools-migrate-ml-795340182"></a>
### versionLine

```ml
function versionLine()
```

Implements version line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/migrate.ml#L238)
