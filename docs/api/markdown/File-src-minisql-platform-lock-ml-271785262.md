# `src/minisql/platform/lock.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform lock facilities for this project.

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
| `file` | `dynamic` | — | file value consumed by this operation. |
| `failImmediately` | `dynamic` | — | failImmediately value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L44)

<a id="function-function-minisql-platform-lock-acquireshared-function-acquireshared-file-failimmediately-src-minisql-platform-lock-ml-494139354"></a>
### acquireShared

```ml
function acquireShared(file, failImmediately)
```

Acquires the shared. Inputs: `file`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `failImmediately` | `dynamic` | — | failImmediately value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L57)

<a id="function-function-minisql-platform-lock-componentname-function-componentname-src-minisql-platform-lock-ml-822735344"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql platform lock module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L81)

<a id="function-function-minisql-platform-lock-fail-function-fail-code-operation-message-src-minisql-platform-lock-ml-1548745065"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql platform lock module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L36)

- [minisql.platform.lock.FileLock](Type-minisql-platform-lock-filelock-1523501747.md) — struct
<a id="constant-constant-minisql-platform-lock-invalid-argument-const-invalid-argument-9001-src-minisql-platform-lock-ml-707634639"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Process-visible file-region locks used to coordinate database readers and


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L17)

<a id="function-function-minisql-platform-lock-isimplemented-function-isimplemented-src-minisql-platform-lock-ml-1885729528"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql platform lock module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L93)

<a id="constant-constant-minisql-platform-lock-lock-conflict-const-lock-conflict-9007-src-minisql-platform-lock-ml-1060498669"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```

Defines the lock conflict constant used by the minisql platform lock module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L19)

<a id="function-function-minisql-platform-lock-release-function-release-lock-src-minisql-platform-lock-ml-796137905"></a>
### release

```ml
function release(lock)
```

Performs the release operation for the minisql platform lock module. Inputs: `lock`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lock` | `dynamic` | — | lock value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L69)

<a id="function-function-minisql-platform-lock-targetmilestone-function-targetmilestone-src-minisql-platform-lock-ml-383365606"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql platform lock module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/lock.ml#L87)
