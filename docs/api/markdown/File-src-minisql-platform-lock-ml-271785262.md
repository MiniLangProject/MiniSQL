# `src/minisql/platform/lock.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.platform.lock`](Package-minisql-platform-lock-321595408.md)

Reachable from entry: **yes**

## Imports

- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/file_win32.ml` as `native` → [src/minisql/platform/file_win32.ml](File-src-minisql-platform-file-win32-ml-727822533.md)

## Declarations

<a id="function-function-minisql-platform-lock-acquireexclusive-function-acquireexclusive-file-failimmediately-src-minisql-platform-lock-ml-908463308"></a>
### acquireExclusive

```ml
function acquireExclusive(file, failImmediately)
```

Acquires the exclusive. Inputs: `file`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `failImmediately` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L38)

<a id="function-function-minisql-platform-lock-acquireshared-function-acquireshared-file-failimmediately-src-minisql-platform-lock-ml-494139354"></a>
### acquireShared

```ml
function acquireShared(file, failImmediately)
```

Acquires the shared. Inputs: `file`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `failImmediately` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L49)

<a id="function-function-minisql-platform-lock-componentname-function-componentname-src-minisql-platform-lock-ml-822735344"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L72)

<a id="function-function-minisql-platform-lock-fail-function-fail-code-operation-message-src-minisql-platform-lock-ml-1548745065"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates the module's structured error with operation context. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L32)

- [minisql.platform.lock.FileLock](Type-minisql-platform-lock-filelock-1523501747.md) — struct
<a id="constant-constant-minisql-platform-lock-invalid-argument-const-invalid-argument-9001-src-minisql-platform-lock-ml-707634639"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Process-visible file-region locks used to coordinate database readers and writers. A FileLock owns the duplicated handle that carries the Windows lock; releasing or closing the lease must happen exactly once.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L17)

<a id="function-function-minisql-platform-lock-isimplemented-function-isimplemented-src-minisql-platform-lock-ml-1885729528"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L84)

<a id="constant-constant-minisql-platform-lock-lock-conflict-const-lock-conflict-9007-src-minisql-platform-lock-ml-1060498669"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L18)

<a id="function-function-minisql-platform-lock-release-function-release-lock-src-minisql-platform-lock-ml-796137905"></a>
### release

```ml
function release(lock)
```

Releases the requested value. Inputs: `lock`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lock` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L60)

<a id="function-function-minisql-platform-lock-targetmilestone-function-targetmilestone-src-minisql-platform-lock-ml-383365606"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L78)
