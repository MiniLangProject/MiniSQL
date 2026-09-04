# `src/apps/minisqld/main.ml`

[Home](README.md) · [Files](Files.md)

Provides apps minisqld main facilities for this project.

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/client/console.ml` as `console` → [src/minisql/client/console.ml](File-src-minisql-client-console-ml-931665780.md)
- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)
- `minisql/common/logger.ml` as `logger` → [src/minisql/common/logger.ml](File-src-minisql-common-logger-ml-1571638233.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/config/loader.ml` as `config_loader` → [src/minisql/config/loader.ml](File-src-minisql-config-loader-ml-616728659.md)
- `minisql/config/model.ml` as `config_model` → [src/minisql/config/model.ml](File-src-minisql-config-model-ml-1120384851.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/server/server.ml` as `server` → [src/minisql/server/server.ml](File-src-minisql-server-server-ml-618711306.md)
- `minisql/tools/encryption.ml` as `encryption` → [src/minisql/tools/encryption.ml](File-src-minisql-tools-encryption-ml-391879592.md)

## Declarations

<a id="function-function-announceserver-function-announceserver-mode-databasepath-address-port-maximumclients-maximumrequests-src-apps-minisqld-main-ml-71667032"></a>
### announceServer

```ml
function announceServer(mode, databasePath, address, port, maximumClients, maximumRequests)
```

Implements announce server for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | Mode selecting the requested behavior. |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `maximumClients` | `dynamic` | — | maximumClients value consumed by this operation. |
| `maximumRequests` | `dynamic` | — | maximumRequests value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L177)

<a id="function-function-configuredefaultlogger-function-configuredefaultlogger-src-apps-minisqld-main-ml-1683914818"></a>
### configureDefaultLogger

```ml
function configureDefaultLogger()
```

Enables documented default logging for legacy explicit-argument server modes. Takes no caller inputs. Returns true after the singleton is configured.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L120)

<a id="function-function-configurelogger-function-configurelogger-config-src-apps-minisqld-main-ml-1205204756"></a>
### configureLogger

```ml
function configureLogger(config)
```

Applies validated configuration to the process-wide logger singleton. Inputs: `config`. Returns true after stdout, rolling file, threshold and binlog settings are active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `config` | `dynamic` | — | Configuration used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L85)

<a id="function-function-initializedatabase-function-initializedatabase-dataroot-databasename-pagesize-src-apps-minisqld-main-ml-1052956018"></a>
### initializeDatabase

```ml
function initializeDatabase(dataRoot, databaseName, pageSize)
```

Implements initialize database for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dataRoot` | `dynamic` | — | dataRoot value consumed by this operation. |
| `databaseName` | `dynamic` | — | databaseName value consumed by this operation. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L131)

<a id="function-function-main-function-main-args-src-apps-minisqld-main-ml-2134402565"></a>
### main

```ml
function main(args)
```

Performs the main operation for the apps minisqld main module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line or caller-supplied arguments. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L196)

<a id="function-function-printapperror-function-printapperror-value-src-apps-minisqld-main-ml-434686879"></a>
### printAppError

```ml
function printAppError(value)
```

Prints app error using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L59)

<a id="function-function-printusage-function-printusage-src-apps-minisqld-main-ml-12091406"></a>
### printUsage

```ml
function printUsage()
```

Prints usage using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L21)

<a id="function-function-runconfiguredserver-function-runconfiguredserver-mode-databasepath-configpath-src-apps-minisqld-main-ml-950097766"></a>
### runConfiguredServer

```ml
function runConfiguredServer(mode, databasePath, configPath)
```

Starts an operational server entirely from a JSON configuration file. Inputs: `mode`, `databasePath`, `configPath`. Returns the public process exit code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | Mode selecting the requested behavior. |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `configPath` | `dynamic` | — | Path associated with config. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L94)

<a id="function-function-serverresult-function-serverresult-result-src-apps-minisqld-main-ml-1149522853"></a>
### serverResult

```ml
function serverResult(result)
```

Implements server result for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L69)

<a id="function-function-setuserpassword-function-setuserpassword-databasepath-username-src-apps-minisqld-main-ml-113352856"></a>
### setUserPassword

```ml
function setUserPassword(databasePath, username)
```

Implements set user password for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisqld/main.ml#L154)
