# `src/apps/minisql_admin/main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **no**

## Imports

- `minisql/admin/fullclient.ml` as `fullclient` → [src/minisql/admin/fullclient.ml](File-src-minisql-admin-fullclient-ml-1896932593.md)
- `minisql/admin/win32_client.ml` as `win32_client` → [src/minisql/admin/win32_client.ml](File-src-minisql-admin-win32-client-ml-1780719346.md)
- `minisql/client/console.ml` as `console` → [src/minisql/client/console.ml](File-src-minisql-client-console-ml-931665780.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/platform/win32_gui.ml` as `gui` → [src/minisql/platform/win32_gui.ml](File-src-minisql-platform-win32-gui-ml-1364403106.md)

## Declarations

<a id="function-function-main-function-main-args-src-apps-minisql-admin-main-ml-1915762313"></a>
### main

```ml
function main(args)
```

Dispatches GUI launch, smoke diagnostics, and explicit connection command lines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_admin/main.ml#L46)

<a id="function-function-printapperror-function-printapperror-value-src-apps-minisql-admin-main-ml-850792063"></a>
### printAppError

```ml
function printAppError(value)
```

Prints one structured application error and returns a failing exit code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_admin/main.ml#L26)

<a id="function-function-printusage-function-printusage-src-apps-minisql-admin-main-ml-1188410192"></a>
### printUsage

```ml
function printUsage()
```

Prints command-line entry points for the native MiniSQL Workbench.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_admin/main.ml#L13)

<a id="function-function-recoverconnectionfailure-function-recoverconnectionfailure-value-src-apps-minisql-admin-main-ml-1601801615"></a>
### recoverConnectionFailure

```ml
function recoverConnectionFailure(value)
```

Converts a direct-connect failure into a GUI error followed by a retryable manager.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_admin/main.ml#L40)

<a id="function-function-runprofile-function-runprofile-profile-password-src-apps-minisql-admin-main-ml-1490807802"></a>
### runProfile

```ml
function runProfile(profile, password)
```

Opens a profile in the native workbench and wipes the supplied password bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_admin/main.ml#L32)
