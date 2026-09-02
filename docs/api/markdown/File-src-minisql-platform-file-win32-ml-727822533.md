# `src/minisql/platform/file_win32.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.platform.file_win32`](Package-minisql-platform-file-win32-1685320645.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `std/threading.ml` as `threading` → `../MiniLangCompilerML/std/threading.ml` — external dependency

## Declarations

<a id="extern_function-extern-function-minisql-platform-file-win32-closehandle-extern-function-closehandle-handle-as-ptr-from-kernel32-dll-symbol-closehandle-returns-bool-src-minisql-platform-file-win32-ml-643505214"></a>
### CloseHandle

```ml
extern function CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
```

Releases one Win32 kernel handle and reports whether closing succeeded.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L81)

<a id="function-function-minisql-platform-file-win32-closenative-function-closenative-handle-src-minisql-platform-file-win32-ml-1185613454"></a>
### closeNative

```ml
function closeNative(handle)
```

Closes the native. Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L303)

<a id="function-function-minisql-platform-file-win32-closereadcontext-function-closereadcontext-context-src-minisql-platform-file-win32-ml-2066302367"></a>
### closeReadContext

```ml
function closeReadContext(context)
```

Closes a query-local completion event after its final read has completed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L180)

<a id="function-function-minisql-platform-file-win32-componentname-function-componentname-src-minisql-platform-file-win32-ml-953484090"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L404)

<a id="constant-constant-minisql-platform-file-win32-create-always-const-create-always-2-src-minisql-platform-file-win32-ml-1978019479"></a>
### CREATE_ALWAYS

```ml
const CREATE_ALWAYS = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L23)

<a id="constant-constant-minisql-platform-file-win32-create-new-const-create-new-1-src-minisql-platform-file-win32-ml-1109867044"></a>
### CREATE_NEW

```ml
const CREATE_NEW = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L22)

<a id="function-function-minisql-platform-file-win32-createdirectory-synchronized-function-createdirectory-path-src-minisql-platform-file-win32-ml-1369380157"></a>
### createDirectory

```ml
synchronized function createDirectory(path)
```

Creates one directory while holding the wide-path native-call guard. Input `path` must be non-empty; an existing directory is treated as success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L357)

<a id="extern_function-extern-function-minisql-platform-file-win32-createdirectoryw-extern-function-createdirectoryw-path-as-wstr-security-as-ptr-from-kernel32-dll-symbol-createdirectoryw-returns-bool-src-minisql-platform-file-win32-ml-560404053"></a>
### CreateDirectoryW

```ml
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
```

Creates a directory at the UTF-16 path and reports Win32 success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `security` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L87)

<a id="extern_function-extern-function-minisql-platform-file-win32-createfilew-extern-function-createfilew-path-as-wstr-desiredaccess-as-u32-sharemode-as-u32-security-as-ptr-creationdisposition-as-u32-flagsandattributes-as-u32-templatefile-as-ptr-from-kernel32-dll-symbol-createfilew-returns-ptr-src-minisql-platform-file-win32-ml-104336383"></a>
### CreateFileW

```ml
extern function CreateFileW(path as wstr, desiredAccess as u32, shareMode as u32, security as ptr, creationDisposition as u32, flagsAndAttributes as u32, templateFile as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
```

Opens or creates a Win32 file and returns its native handle or INVALID_HANDLE_VALUE.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `desiredAccess` | `u32` | — |  |
| `shareMode` | `u32` | — |  |
| `security` | `ptr` | — |  |
| `creationDisposition` | `u32` | — |  |
| `flagsAndAttributes` | `u32` | — |  |
| `templateFile` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L59)

<a id="function-function-minisql-platform-file-win32-createreadcontext-function-createreadcontext-src-minisql-platform-file-win32-ml-1941187988"></a>
### createReadContext

```ml
function createReadContext()
```

Creates one reusable completion event for a query-local positioned-read lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L173)

<a id="extern_function-extern-function-minisql-platform-file-win32-deletefilew-extern-function-deletefilew-path-as-wstr-from-kernel32-dll-symbol-deletefilew-returns-bool-src-minisql-platform-file-win32-ml-841600273"></a>
### DeleteFileW

```ml
extern function DeleteFileW(path as wstr) from "kernel32.dll" symbol "DeleteFileW" returns bool
```

Deletes the file identified by a UTF-16 path and reports Win32 success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L83)

<a id="function-function-minisql-platform-file-win32-deletepath-synchronized-function-deletepath-path-src-minisql-platform-file-win32-ml-132119661"></a>
### deletePath

```ml
synchronized function deletePath(path)
```

Deletes the path while holding the compiler-required wide-path call guard. Input `path` must be non-empty; returns success or a mapped Win32 error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L311)

<a id="function-function-minisql-platform-file-win32-directoryexists-function-directoryexists-path-src-minisql-platform-file-win32-ml-1616425587"></a>
### directoryExists

```ml
function directoryExists(path)
```

Performs the directory exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L341)

<a id="constant-constant-minisql-platform-file-win32-error-access-denied-const-error-access-denied-5-src-minisql-platform-file-win32-ml-1255226504"></a>
### ERROR_ACCESS_DENIED

```ml
const ERROR_ACCESS_DENIED = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L34)

<a id="constant-constant-minisql-platform-file-win32-error-already-exists-const-error-already-exists-183-src-minisql-platform-file-win32-ml-1053248405"></a>
### ERROR_ALREADY_EXISTS

```ml
const ERROR_ALREADY_EXISTS = 183
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L38)

<a id="constant-constant-minisql-platform-file-win32-error-file-not-found-const-error-file-not-found-2-src-minisql-platform-file-win32-ml-1106853493"></a>
### ERROR_FILE_NOT_FOUND

```ml
const ERROR_FILE_NOT_FOUND = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L36)

<a id="constant-constant-minisql-platform-file-win32-error-handle-eof-const-error-handle-eof-38-src-minisql-platform-file-win32-ml-543301920"></a>
### ERROR_HANDLE_EOF

```ml
const ERROR_HANDLE_EOF = 38
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L39)

<a id="constant-constant-minisql-platform-file-win32-error-io-pending-const-error-io-pending-997-src-minisql-platform-file-win32-ml-1750158740"></a>
### ERROR_IO_PENDING

```ml
const ERROR_IO_PENDING = 997
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L40)

<a id="constant-constant-minisql-platform-file-win32-error-lock-violation-const-error-lock-violation-33-src-minisql-platform-file-win32-ml-1969026327"></a>
### ERROR_LOCK_VIOLATION

```ml
const ERROR_LOCK_VIOLATION = 33
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L33)

<a id="constant-constant-minisql-platform-file-win32-error-path-not-found-const-error-path-not-found-3-src-minisql-platform-file-win32-ml-1853446946"></a>
### ERROR_PATH_NOT_FOUND

```ml
const ERROR_PATH_NOT_FOUND = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L37)

<a id="constant-constant-minisql-platform-file-win32-error-sharing-violation-const-error-sharing-violation-32-src-minisql-platform-file-win32-ml-1535440932"></a>
### ERROR_SHARING_VIOLATION

```ml
const ERROR_SHARING_VIOLATION = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L35)

<a id="function-function-minisql-platform-file-win32-fail-function-fail-code-operation-message-src-minisql-platform-file-win32-ml-1911791271"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L99)

<a id="constant-constant-minisql-platform-file-win32-file-attribute-directory-const-file-attribute-directory-16-src-minisql-platform-file-win32-ml-109863190"></a>
### FILE_ATTRIBUTE_DIRECTORY

```ml
const FILE_ATTRIBUTE_DIRECTORY = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L42)

<a id="constant-constant-minisql-platform-file-win32-file-attribute-normal-const-file-attribute-normal-128-src-minisql-platform-file-win32-ml-1031072170"></a>
### FILE_ATTRIBUTE_NORMAL

```ml
const FILE_ATTRIBUTE_NORMAL = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L27)

<a id="constant-constant-minisql-platform-file-win32-file-begin-const-file-begin-0-src-minisql-platform-file-win32-ml-912345639"></a>
### FILE_BEGIN

```ml
const FILE_BEGIN = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L30)

<a id="constant-constant-minisql-platform-file-win32-file-flag-overlapped-const-file-flag-overlapped-1073741824-src-minisql-platform-file-win32-ml-267400008"></a>
### FILE_FLAG_OVERLAPPED

```ml
const FILE_FLAG_OVERLAPPED = 1073741824
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L29)

<a id="constant-constant-minisql-platform-file-win32-file-flag-write-through-const-file-flag-write-through-2147483648-src-minisql-platform-file-win32-ml-638820836"></a>
### FILE_FLAG_WRITE_THROUGH

```ml
const FILE_FLAG_WRITE_THROUGH = 2147483648
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L28)

<a id="constant-constant-minisql-platform-file-win32-file-share-delete-const-file-share-delete-4-src-minisql-platform-file-win32-ml-1057266813"></a>
### FILE_SHARE_DELETE

```ml
const FILE_SHARE_DELETE = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L21)

<a id="constant-constant-minisql-platform-file-win32-file-share-read-const-file-share-read-1-src-minisql-platform-file-win32-ml-97028588"></a>
### FILE_SHARE_READ

```ml
const FILE_SHARE_READ = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L19)

<a id="constant-constant-minisql-platform-file-win32-file-share-write-const-file-share-write-2-src-minisql-platform-file-win32-ml-1611920221"></a>
### FILE_SHARE_WRITE

```ml
const FILE_SHARE_WRITE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L20)

<a id="function-function-minisql-platform-file-win32-fileexists-function-fileexists-path-src-minisql-platform-file-win32-ml-1323856213"></a>
### fileExists

```ml
function fileExists(path)
```

Performs the file exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L349)

<a id="function-function-minisql-platform-file-win32-flush-function-flush-handle-src-minisql-platform-file-win32-ml-196365516"></a>
### flush

```ml
function flush(handle)
```

Flushes the requested value. Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L265)

<a id="extern_function-extern-function-minisql-platform-file-win32-flushfilebuffers-extern-function-flushfilebuffers-handle-as-ptr-from-kernel32-dll-symbol-flushfilebuffers-returns-bool-src-minisql-platform-file-win32-ml-104467789"></a>
### FlushFileBuffers

```ml
extern function FlushFileBuffers(handle as ptr) from "kernel32.dll" symbol "FlushFileBuffers" returns bool
```

Forces buffered data and metadata for `handle` to stable storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L75)

<a id="constant-constant-minisql-platform-file-win32-generic-read-const-generic-read-2147483648-src-minisql-platform-file-win32-ml-813667182"></a>
### GENERIC_READ

```ml
const GENERIC_READ = 2147483648
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L17)

<a id="constant-constant-minisql-platform-file-win32-generic-write-const-generic-write-1073741824-src-minisql-platform-file-win32-ml-2083118598"></a>
### GENERIC_WRITE

```ml
const GENERIC_WRITE = 1073741824
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L18)

<a id="extern_function-extern-function-minisql-platform-file-win32-getfileattributesw-extern-function-getfileattributesw-path-as-wstr-from-kernel32-dll-symbol-getfileattributesw-returns-u32-src-minisql-platform-file-win32-ml-1801081331"></a>
### GetFileAttributesW

```ml
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" symbol "GetFileAttributesW" returns u32
```

Returns Win32 attributes for a UTF-16 path or INVALID_FILE_ATTRIBUTES.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L85)

<a id="extern_function-extern-function-minisql-platform-file-win32-getfilesizeex-extern-function-getfilesizeex-handle-as-ptr-sizeout-as-bytes-from-kernel32-dll-symbol-getfilesizeex-returns-bool-src-minisql-platform-file-win32-ml-620053496"></a>
### GetFileSizeEx

```ml
extern function GetFileSizeEx(handle as ptr, sizeOut as bytes) from "kernel32.dll" symbol "GetFileSizeEx" returns bool
```

Writes the handle's current 64-bit byte length to `sizeOut`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `sizeOut` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L71)

<a id="extern_function-extern-function-minisql-platform-file-win32-getlasterror-extern-function-getlasterror-from-kernel32-dll-symbol-getlasterror-returns-u32-src-minisql-platform-file-win32-ml-1858205198"></a>
### GetLastError

```ml
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
```

Returns the calling thread's most recent Win32 error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L93)

<a id="extern_function-extern-function-minisql-platform-file-win32-getoverlappedresult-extern-function-getoverlappedresult-handle-as-ptr-overlapped-as-bytes-bytestransferred-as-bytes-wait-as-bool-from-kernel32-dll-symbol-getoverlappedresult-returns-bool-src-minisql-platform-file-win32-ml-738058653"></a>
### GetOverlappedResult

```ml
extern function GetOverlappedResult(handle as ptr, overlapped as bytes, bytesTransferred as bytes, wait as bool) from "kernel32.dll" symbol "GetOverlappedResult" returns bool
```

Waits for one particular overlapped operation and returns its byte count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `overlapped` | `bytes` | — |  |
| `bytesTransferred` | `bytes` | — |  |
| `wait` | `bool` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L67)

<a id="constant-constant-minisql-platform-file-win32-invalid-argument-const-invalid-argument-9001-src-minisql-platform-file-win32-ml-1624181309"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Thin Win32 handle layer. The public platform.file module owns validation and object lifetime. Read-only handles can opt into offset-based overlapped reads, while serialized writers retain synchronous cursor operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L13)

<a id="constant-constant-minisql-platform-file-win32-invalid-file-attributes-const-invalid-file-attributes-4294967295-src-minisql-platform-file-win32-ml-160637406"></a>
### INVALID_FILE_ATTRIBUTES

```ml
const INVALID_FILE_ATTRIBUTES = 4294967295
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L41)

<a id="constant-constant-minisql-platform-file-win32-io-failure-const-io-failure-9005-src-minisql-platform-file-win32-ml-173812853"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L14)

<a id="function-function-minisql-platform-file-win32-isimplemented-function-isimplemented-src-minisql-platform-file-win32-ml-1720360170"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L416)

<a id="function-function-minisql-platform-file-win32-isinvalidhandle-function-isinvalidhandle-handle-src-minisql-platform-file-win32-ml-581647290"></a>
### isInvalidHandle

```ml
function isInvalidHandle(handle)
```

Evaluates whether the supplied input satisfies the invalid handle predicate. Inputs: `handle`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L112)

<a id="function-function-minisql-platform-file-win32-lasterror-function-lasterror-operation-src-minisql-platform-file-win32-ml-1834803369"></a>
### lastError

```ml
function lastError(operation)
```

Performs the last error operation for this module. Inputs: `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L105)

<a id="constant-constant-minisql-platform-file-win32-lock-conflict-const-lock-conflict-9007-src-minisql-platform-file-win32-ml-1561491483"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L15)

<a id="constant-constant-minisql-platform-file-win32-lockfile-exclusive-lock-const-lockfile-exclusive-lock-2-src-minisql-platform-file-win32-ml-1947814575"></a>
### LOCKFILE_EXCLUSIVE_LOCK

```ml
const LOCKFILE_EXCLUSIVE_LOCK = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L32)

<a id="constant-constant-minisql-platform-file-win32-lockfile-fail-immediately-const-lockfile-fail-immediately-1-src-minisql-platform-file-win32-ml-616668920"></a>
### LOCKFILE_FAIL_IMMEDIATELY

```ml
const LOCKFILE_FAIL_IMMEDIATELY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L31)

<a id="extern_function-extern-function-minisql-platform-file-win32-lockfileex-extern-function-lockfileex-handle-as-ptr-flags-as-u32-reserved-as-u32-byteslow-as-u32-byteshigh-as-u32-overlapped-as-bytes-from-kernel32-dll-symbol-lockfileex-returns-bool-src-minisql-platform-file-win32-ml-1900664822"></a>
### LockFileEx

```ml
extern function LockFileEx(handle as ptr, flags as u32, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "LockFileEx" returns bool
```

Acquires the requested byte-range lock described by `overlapped` and length words.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `flags` | `u32` | — |  |
| `reserved` | `u32` | — |  |
| `bytesLow` | `u32` | — |  |
| `bytesHigh` | `u32` | — |  |
| `overlapped` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L77)

<a id="function-function-minisql-platform-file-win32-lockwhole-function-lockwhole-handle-exclusive-failimmediately-src-minisql-platform-file-win32-ml-284917206"></a>
### lockWhole

```ml
function lockWhole(handle, exclusive, failImmediately)
```

Locks the whole. Inputs: `handle`, `exclusive`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `exclusive` | `dynamic` | — |  |
| `failImmediately` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L273)

<a id="constant-constant-minisql-platform-file-win32-move-retry-attempts-const-move-retry-attempts-40-src-minisql-platform-file-win32-ml-1575941867"></a>
### MOVE_RETRY_ATTEMPTS

```ml
const MOVE_RETRY_ATTEMPTS = 40
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L45)

<a id="constant-constant-minisql-platform-file-win32-move-retry-delay-ms-const-move-retry-delay-ms-25-src-minisql-platform-file-win32-ml-2135064928"></a>
### MOVE_RETRY_DELAY_MS

```ml
const MOVE_RETRY_DELAY_MS = 25
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L46)

<a id="constant-constant-minisql-platform-file-win32-movefile-replace-existing-const-movefile-replace-existing-1-src-minisql-platform-file-win32-ml-2095325724"></a>
### MOVEFILE_REPLACE_EXISTING

```ml
const MOVEFILE_REPLACE_EXISTING = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L43)

<a id="constant-constant-minisql-platform-file-win32-movefile-write-through-const-movefile-write-through-8-src-minisql-platform-file-win32-ml-701519877"></a>
### MOVEFILE_WRITE_THROUGH

```ml
const MOVEFILE_WRITE_THROUGH = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L44)

<a id="extern_function-extern-function-minisql-platform-file-win32-movefileexw-extern-function-movefileexw-source-as-wstr-destination-as-wstr-flags-as-u32-from-kernel32-dll-symbol-movefileexw-returns-bool-src-minisql-platform-file-win32-ml-935455373"></a>
### MoveFileExW

```ml
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
```

Renames or replaces a path according to `flags` and reports Win32 success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `wstr` | — |  |
| `destination` | `wstr` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L91)

<a id="function-function-minisql-platform-file-win32-movepath-function-movepath-source-destination-replaceexisting-src-minisql-platform-file-win32-ml-123301098"></a>
### movePath

```ml
function movePath(source, destination, replaceExisting)
```

Atomically renames a path and absorbs only short-lived Windows scanner locks. Access-denied and sharing-violation errors are retried for at most one second; invalid paths and permanent permission failures remain immediately visible. Inputs identify source, destination, and replacement policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `replaceExisting` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L385)

<a id="function-function-minisql-platform-file-win32-movepathattempt-synchronized-function-movepathattempt-source-destination-flags-src-minisql-platform-file-win32-ml-361487840"></a>
### movePathAttempt

```ml
synchronized function movePathAttempt(source, destination, flags)
```

Performs one atomic rename attempt while protecting compiler-managed UTF-16 path buffers. Returns zero on success or the captured Win32 error code. Inputs: `source`, `destination`, and native move flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L376)

<a id="constant-constant-minisql-platform-file-win32-open-always-const-open-always-4-src-minisql-platform-file-win32-ml-7513385"></a>
### OPEN_ALWAYS

```ml
const OPEN_ALWAYS = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L25)

<a id="constant-constant-minisql-platform-file-win32-open-existing-const-open-existing-3-src-minisql-platform-file-win32-ml-930292170"></a>
### OPEN_EXISTING

```ml
const OPEN_EXISTING = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L24)

<a id="function-function-minisql-platform-file-win32-opennative-function-opennative-path-desiredaccess-sharemode-creationdisposition-writethrough-src-minisql-platform-file-win32-ml-788032449"></a>
### openNative

```ml
function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
```

Opens a conventional synchronous handle used by serialized write paths.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `desiredAccess` | `dynamic` | — |  |
| `shareMode` | `dynamic` | — |  |
| `creationDisposition` | `dynamic` | — |  |
| `writeThrough` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L137)

<a id="function-function-minisql-platform-file-win32-opennativepositionedread-function-opennativepositionedread-path-desiredaccess-sharemode-creationdisposition-writethrough-src-minisql-platform-file-win32-ml-1475852481"></a>
### openNativePositionedRead

```ml
function openNativePositionedRead(path, desiredAccess, shareMode, creationDisposition, writeThrough)
```

Opens a read-only handle whose operations carry explicit byte offsets and can safely overlap on the same kernel file object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `desiredAccess` | `dynamic` | — |  |
| `shareMode` | `dynamic` | — |  |
| `creationDisposition` | `dynamic` | — |  |
| `writeThrough` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L143)

<a id="function-function-minisql-platform-file-win32-opennativewithflags-synchronized-function-opennativewithflags-path-desiredaccess-sharemode-creationdisposition-writethrough-extraflags-src-minisql-platform-file-win32-ml-1432077756"></a>
### openNativeWithFlags

```ml
synchronized function openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, extraFlags)
```

MiniLang's extern wstr conversion currently uses process-wide UTF-16 scratch buffers. Serialize only path-bearing native calls; positioned file I/O stays parallel because it uses independent handles and byte buffers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `desiredAccess` | `dynamic` | — |  |
| `shareMode` | `dynamic` | — |  |
| `creationDisposition` | `dynamic` | — |  |
| `writeThrough` | `dynamic` | — |  |
| `extraFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L120)

<a id="function-function-minisql-platform-file-win32-pathattributes-synchronized-function-pathattributes-path-src-minisql-platform-file-win32-ml-1128890081"></a>
### pathAttributes

```ml
synchronized function pathAttributes(path)
```

Reads Win32 attributes while serializing access to the compiler's path buffer. Input `path` must be non-empty; returns attributes, -1 when absent, or an error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L322)

<a id="function-function-minisql-platform-file-win32-pathexists-function-pathexists-path-src-minisql-platform-file-win32-ml-1166825817"></a>
### pathExists

```ml
function pathExists(path)
```

Performs the path exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L335)

- [minisql.platform.file_win32.PositionedReadContext](Type-minisql-platform-file-win32-positionedreadcontext-1624883970.md) — struct
<a id="function-function-minisql-platform-file-win32-readat-function-readat-handle-fileoffset-destination-count-src-minisql-platform-file-win32-ml-439297218"></a>
### readAt

```ml
function readAt(handle, fileOffset, destination, count)
```

Compatibility positioned read whose temporary context owns exactly one read.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L222)

<a id="function-function-minisql-platform-file-win32-readatwithcontext-function-readatwithcontext-handle-fileoffset-destination-count-context-src-minisql-platform-file-win32-ml-1196300727"></a>
### readAtWithContext

```ml
function readAtWithContext(handle, fileOffset, destination, count, context)
```

Reads at an explicit byte offset with one caller-owned completion event. The OVERLAPPED record remains unique to the operation while event creation is amortized across every page read in the owning query lease.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L191)

<a id="function-function-minisql-platform-file-win32-readcurrent-function-readcurrent-handle-destination-count-src-minisql-platform-file-win32-ml-1605255773"></a>
### readCurrent

```ml
function readCurrent(handle, destination, count)
```

Reads the current. Inputs: `handle`, `destination`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L160)

<a id="extern_function-extern-function-minisql-platform-file-win32-readfile-extern-function-readfile-handle-as-ptr-buffer-as-bytes-count-as-u32-bytesread-as-bytes-overlapped-as-ptr-from-kernel32-dll-symbol-readfile-returns-bool-src-minisql-platform-file-win32-ml-1150378554"></a>
### ReadFile

```ml
extern function ReadFile(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as ptr) from "kernel32.dll" symbol "ReadFile" returns bool
```

Reads synchronously into `buffer`, writing the transferred count to `bytesRead`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `buffer` | `bytes` | — |  |
| `count` | `u32` | — |  |
| `bytesRead` | `bytes` | — |  |
| `overlapped` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L61)

<a id="extern_function-extern-function-minisql-platform-file-win32-readfilepositioned-extern-function-readfilepositioned-handle-as-ptr-buffer-as-bytes-count-as-u32-bytesread-as-bytes-overlapped-as-bytes-from-kernel32-dll-symbol-readfile-returns-bool-src-minisql-platform-file-win32-ml-424283845"></a>
### ReadFilePositioned

```ml
extern function ReadFilePositioned(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as bytes) from "kernel32.dll" symbol "ReadFile" returns bool
```

Starts one read at the offset stored in a unique OVERLAPPED structure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `buffer` | `bytes` | — |  |
| `count` | `u32` | — |  |
| `bytesRead` | `bytes` | — |  |
| `overlapped` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L63)

<a id="function-function-minisql-platform-file-win32-removedirectory-synchronized-function-removedirectory-path-src-minisql-platform-file-win32-ml-684082569"></a>
### removeDirectory

```ml
synchronized function removeDirectory(path)
```

Removes an empty directory while holding the wide-path native-call guard. Input `path` must be non-empty; returns success or a mapped Win32 error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L367)

<a id="extern_function-extern-function-minisql-platform-file-win32-removedirectoryw-extern-function-removedirectoryw-path-as-wstr-from-kernel32-dll-symbol-removedirectoryw-returns-bool-src-minisql-platform-file-win32-ml-1644331531"></a>
### RemoveDirectoryW

```ml
extern function RemoveDirectoryW(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
```

Removes an empty directory at the UTF-16 path and reports Win32 success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L89)

<a id="function-function-minisql-platform-file-win32-seek-function-seek-handle-offset-src-minisql-platform-file-win32-ml-305643019"></a>
### seek

```ml
function seek(handle, offset)
```

Performs the seek operation for this module. Inputs: `handle`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L149)

<a id="extern_function-extern-function-minisql-platform-file-win32-setendoffile-extern-function-setendoffile-handle-as-ptr-from-kernel32-dll-symbol-setendoffile-returns-bool-src-minisql-platform-file-win32-ml-1026639720"></a>
### SetEndOfFile

```ml
extern function SetEndOfFile(handle as ptr) from "kernel32.dll" symbol "SetEndOfFile" returns bool
```

Truncates or extends the file at its current cursor position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L73)

<a id="extern_function-extern-function-minisql-platform-file-win32-setfilepointerex-extern-function-setfilepointerex-handle-as-ptr-distance-as-i64-newposition-as-ptr-movemethod-as-u32-from-kernel32-dll-symbol-setfilepointerex-returns-bool-src-minisql-platform-file-win32-ml-342901687"></a>
### SetFilePointerEx

```ml
extern function SetFilePointerEx(handle as ptr, distance as i64, newPosition as ptr, moveMethod as u32) from "kernel32.dll" symbol "SetFilePointerEx" returns bool
```

Repositions the file cursor by `distance` relative to `moveMethod`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `distance` | `i64` | — |  |
| `newPosition` | `ptr` | — |  |
| `moveMethod` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L69)

<a id="function-function-minisql-platform-file-win32-size-function-size-handle-src-minisql-platform-file-win32-ml-838488576"></a>
### size

```ml
function size(handle)
```

Computes the size of the requested value. Inputs: `handle`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L248)

<a id="extern_function-extern-function-minisql-platform-file-win32-sleep-extern-function-sleep-milliseconds-as-u32-from-kernel32-dll-symbol-sleep-returns-void-src-minisql-platform-file-win32-ml-1172765451"></a>
### Sleep

```ml
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void
```

Suspends the calling thread for the requested number of milliseconds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L95)

<a id="function-function-minisql-platform-file-win32-targetmilestone-function-targetmilestone-src-minisql-platform-file-win32-ml-1902589668"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L410)

<a id="function-function-minisql-platform-file-win32-truncate-function-truncate-handle-newsize-src-minisql-platform-file-win32-ml-540867053"></a>
### truncate

```ml
function truncate(handle, newSize)
```

Performs the truncate operation for this module. Inputs: `handle`, `newSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `newSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L257)

<a id="constant-constant-minisql-platform-file-win32-truncate-existing-const-truncate-existing-5-src-minisql-platform-file-win32-ml-1582766192"></a>
### TRUNCATE_EXISTING

```ml
const TRUNCATE_EXISTING = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L26)

<a id="extern_function-extern-function-minisql-platform-file-win32-unlockfileex-extern-function-unlockfileex-handle-as-ptr-reserved-as-u32-byteslow-as-u32-byteshigh-as-u32-overlapped-as-bytes-from-kernel32-dll-symbol-unlockfileex-returns-bool-src-minisql-platform-file-win32-ml-1098240638"></a>
### UnlockFileEx

```ml
extern function UnlockFileEx(handle as ptr, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "UnlockFileEx" returns bool
```

Releases the byte-range lock described by `overlapped` and length words.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `reserved` | `u32` | — |  |
| `bytesLow` | `u32` | — |  |
| `bytesHigh` | `u32` | — |  |
| `overlapped` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L79)

<a id="function-function-minisql-platform-file-win32-unlockwhole-function-unlockwhole-handle-src-minisql-platform-file-win32-ml-857128918"></a>
### unlockWhole

```ml
function unlockWhole(handle)
```

Unlocks the whole. Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L294)

<a id="function-function-minisql-platform-file-win32-writecurrent-function-writecurrent-handle-source-count-src-minisql-platform-file-win32-ml-1443831950"></a>
### writeCurrent

```ml
function writeCurrent(handle, source, count)
```

Writes the current. Inputs: `handle`, `source`, `count`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L234)

<a id="extern_function-extern-function-minisql-platform-file-win32-writefile-extern-function-writefile-handle-as-ptr-buffer-as-bytes-count-as-u32-byteswritten-as-bytes-overlapped-as-ptr-from-kernel32-dll-symbol-writefile-returns-bool-src-minisql-platform-file-win32-ml-609178060"></a>
### WriteFile

```ml
extern function WriteFile(handle as ptr, buffer as bytes, count as u32, bytesWritten as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
```

Writes synchronously from `buffer`, storing the transferred count in `bytesWritten`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `buffer` | `bytes` | — |  |
| `count` | `u32` | — |  |
| `bytesWritten` | `bytes` | — |  |
| `overlapped` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L65)
