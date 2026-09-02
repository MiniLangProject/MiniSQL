# `src/minisql/platform/file.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.platform.file`](Package-minisql-platform-file-714344185.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file_win32.ml` as `native` → [src/minisql/platform/file_win32.ml](File-src-minisql-platform-file-win32-ml-727822533.md)
- `std/string.ml` as `string_api` → `../MiniLangCompilerML/std/string.ml` — external dependency

## Declarations

<a id="function-function-minisql-platform-file-admitinjectedwrite-function-admitinjectedwrite-count-operation-src-minisql-platform-file-ml-1452909586"></a>
### admitInjectedWrite

```ml
function admitInjectedWrite(count, operation)
```

Applies the all-or-nothing injected write budget before native I/O.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L84)

<a id="function-function-minisql-platform-file-append-function-append-file-source-sourceoffset-count-src-minisql-platform-file-ml-404046332"></a>
### append

```ml
function append(file, source, sourceOffset, count)
```

Appends the requested value. Inputs: `file`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L307)

<a id="function-function-minisql-platform-file-clearwritefault-function-clearwritefault-src-minisql-platform-file-ml-216085062"></a>
### clearWriteFault

```ml
function clearWriteFault()
```

Disarms deterministic storage exhaustion. Tests call this before cleanup so close/recovery operations use the real file system again.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L77)

<a id="function-function-minisql-platform-file-close-function-close-file-src-minisql-platform-file-ml-194667004"></a>
### close

```ml
function close(file)
```

Closes the requested value. Inputs: `file`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L341)

<a id="constant-constant-minisql-platform-file-closed-handle-const-closed-handle-9008-src-minisql-platform-file-ml-1648641084"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L20)

<a id="function-function-minisql-platform-file-closereadcontext-function-closereadcontext-context-src-minisql-platform-file-ml-741193535"></a>
### closeReadContext

```ml
function closeReadContext(context)
```

Closes a reusable read context after every dependent I/O has completed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L140)

<a id="function-function-minisql-platform-file-componentname-function-componentname-src-minisql-platform-file-ml-1704078582"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L450)

<a id="function-function-minisql-platform-file-configurewritefault-function-configurewritefault-remainingbytes-src-minisql-platform-file-ml-1320596275"></a>
### configureWriteFault

```ml
function configureWriteFault(remainingBytes)
```

Arms a deterministic storage-exhaustion boundary. Complete writes whose payload fits inside the remaining budget are allowed; the first later write fails before reaching the operating system, avoiding artificial torn writes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `remainingBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L66)

<a id="function-function-minisql-platform-file-create-function-create-path-src-minisql-platform-file-ml-76522757"></a>
### create

```ml
function create(path)
```

Creates the requested value. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L169)

<a id="function-function-minisql-platform-file-createdirectory-function-createdirectory-path-src-minisql-platform-file-ml-391039311"></a>
### createDirectory

```ml
function createDirectory(path)
```

Creates the directory. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L380)

<a id="function-function-minisql-platform-file-createdurable-function-createdurable-path-src-minisql-platform-file-ml-1282355547"></a>
### createDurable

```ml
function createDurable(path)
```

Creates the durable. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L185)

<a id="function-function-minisql-platform-file-createnew-function-createnew-path-src-minisql-platform-file-ml-1084414609"></a>
### createNew

```ml
function createNew(path)
```

Creates the new. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L177)

<a id="function-function-minisql-platform-file-createnewdurable-function-createnewdurable-path-src-minisql-platform-file-ml-1765222449"></a>
### createNewDurable

```ml
function createNewDurable(path)
```

Creates the new durable. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L193)

<a id="function-function-minisql-platform-file-createreadcontext-function-createreadcontext-src-minisql-platform-file-ml-1923465644"></a>
### createReadContext

```ml
function createReadContext()
```

Creates a context reusable by sequential reads in one query or cursor lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L129)

<a id="function-function-minisql-platform-file-deletepath-function-deletepath-path-src-minisql-platform-file-ml-1747539309"></a>
### deletePath

```ml
function deletePath(path)
```

Deletes the path. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L355)

<a id="function-function-minisql-platform-file-directoryexists-function-directoryexists-path-src-minisql-platform-file-ml-1695769859"></a>
### directoryExists

```ml
function directoryExists(path)
```

Performs the directory exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L374)

<a id="function-function-minisql-platform-file-fail-function-fail-code-operation-message-src-minisql-platform-file-ml-888822391"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L59)

<a id="function-function-minisql-platform-file-fileexists-function-fileexists-path-src-minisql-platform-file-ml-628133865"></a>
### fileExists

```ml
function fileExists(path)
```

Performs the file exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L368)

- [minisql.platform.file.FileHandle](Type-minisql-platform-file-filehandle-777631733.md) — struct
<a id="function-function-minisql-platform-file-flush-function-flush-file-src-minisql-platform-file-ml-529228700"></a>
### flush

```ml
function flush(file)
```

Flushes the requested value. Inputs: `file`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L333)

<a id="constant-constant-minisql-platform-file-invalid-argument-const-invalid-argument-9001-src-minisql-platform-file-ml-1882476529"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Validated, lifetime-safe file API layered over the raw Win32 bindings. Positioned operations preserve the caller's logical cursor and reject use of closed handles before crossing the native boundary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L18)

<a id="constant-constant-minisql-platform-file-io-failure-const-io-failure-9005-src-minisql-platform-file-ml-1498379153"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L19)

<a id="function-function-minisql-platform-file-isimplemented-function-isimplemented-src-minisql-platform-file-ml-952729126"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L462)

<a id="function-function-minisql-platform-file-joinpath-function-joinpath-left-right-src-minisql-platform-file-ml-1503589553"></a>
### joinPath

```ml
function joinPath(left, right)
```

Performs the join path operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L428)

<a id="function-function-minisql-platform-file-movepath-function-movepath-source-destination-replaceexisting-src-minisql-platform-file-ml-974284334"></a>
### movePath

```ml
function movePath(source, destination, replaceExisting)
```

Performs the move path operation for this module. Inputs: `source`, `destination`, `replaceExisting`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `replaceExisting` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L392)

<a id="function-function-minisql-platform-file-openread-function-openread-path-src-minisql-platform-file-ml-1665753393"></a>
### openRead

```ml
function openRead(path)
```

Opens the read. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L123)

<a id="function-function-minisql-platform-file-openreadwrite-function-openreadwrite-path-createifmissing-src-minisql-platform-file-ml-1520217242"></a>
### openReadWrite

```ml
function openReadWrite(path, createIfMissing)
```

Opens the read write. Inputs: `path`, `createIfMissing`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `createIfMissing` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L158)

<a id="function-function-minisql-platform-file-pathexists-function-pathexists-path-src-minisql-platform-file-ml-513324869"></a>
### pathExists

```ml
function pathExists(path)
```

Performs the path exists operation for this module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L362)

- [minisql.platform.file.PositionedReadContext](Type-minisql-platform-file-positionedreadcontext-2034619142.md) — struct
<a id="function-function-minisql-platform-file-readallbytes-function-readallbytes-path-maximumbytes-src-minisql-platform-file-ml-1191943440"></a>
### readAllBytes

```ml
function readAllBytes(path, maximumBytes)
```

Reads the all bytes. Inputs: `path`, `maximumBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `maximumBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L398)

<a id="function-function-minisql-platform-file-readalltext-function-readalltext-path-maximumbytes-src-minisql-platform-file-ml-764688648"></a>
### readAllText

```ml
function readAllText(path, maximumBytes)
```

Reads the all text. Inputs: `path`, `maximumBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `maximumBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L418)

<a id="function-function-minisql-platform-file-readat-function-readat-file-fileoffset-destination-destinationoffset-count-src-minisql-platform-file-ml-809176179"></a>
### readAt

```ml
function readAt(file, fileOffset, destination, destinationOffset, count)
```

Reads without retaining setup across calls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L257)

<a id="function-function-minisql-platform-file-readatwithcontext-function-readatwithcontext-file-fileoffset-destination-destinationoffset-count-context-src-minisql-platform-file-ml-12711364"></a>
### readAtWithContext

```ml
function readAtWithContext(file, fileOffset, destination, destinationOffset, count, context)
```

Reads the at. Inputs: `file`, `fileOffset`, `destination`, `destinationOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L216)

<a id="function-function-minisql-platform-file-readcontextoperations-function-readcontextoperations-context-src-minisql-platform-file-ml-1369871121"></a>
### readContextOperations

```ml
function readContextOperations(context)
```

Reports successful positioned operations performed through this context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L151)

<a id="function-function-minisql-platform-file-readexactat-function-readexactat-file-fileoffset-destination-destinationoffset-count-src-minisql-platform-file-ml-280244823"></a>
### readExactAt

```ml
function readExactAt(file, fileOffset, destination, destinationOffset, count)
```

Reads the exact at. Inputs: `file`, `fileOffset`, `destination`, `destinationOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L263)

<a id="function-function-minisql-platform-file-readexactatwithcontext-function-readexactatwithcontext-file-fileoffset-destination-destinationoffset-count-context-src-minisql-platform-file-ml-1112220952"></a>
### readExactAtWithContext

```ml
function readExactAtWithContext(file, fileOffset, destination, destinationOffset, count, context)
```

Reads one exact range through a caller-owned query-local context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L270)

<a id="function-function-minisql-platform-file-removedirectory-function-removedirectory-path-src-minisql-platform-file-ml-2116911231"></a>
### removeDirectory

```ml
function removeDirectory(path)
```

Removes the directory. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L386)

<a id="function-function-minisql-platform-file-shareall-function-shareall-src-minisql-platform-file-ml-2020273142"></a>
### shareAll

```ml
function shareAll()
```

Performs the share all operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L117)

<a id="function-function-minisql-platform-file-size-function-size-file-src-minisql-platform-file-ml-299421568"></a>
### size

```ml
function size(file)
```

Computes the size of the requested value. Inputs: `file`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L315)

<a id="function-function-minisql-platform-file-targetmilestone-function-targetmilestone-src-minisql-platform-file-ml-1127409804"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L456)

<a id="function-function-minisql-platform-file-truncate-function-truncate-file-newsize-src-minisql-platform-file-ml-770243553"></a>
### truncate

```ml
function truncate(file, newSize)
```

Performs the truncate operation for this module. Inputs: `file`, `newSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `newSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L322)

<a id="function-function-minisql-platform-file-validatefilerange-function-validatefilerange-fileoffset-count-operation-src-minisql-platform-file-ml-167451537"></a>
### validateFileRange

```ml
function validateFileRange(fileOffset, count, operation)
```

Validates the file range. Inputs: `fileOffset`, `count`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L201)

<a id="function-function-minisql-platform-file-validateopen-function-validateopen-file-operation-src-minisql-platform-file-ml-770869255"></a>
### validateOpen

```ml
function validateOpen(file, operation)
```

Validates the open. Inputs: `file`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L96)

<a id="function-function-minisql-platform-file-validateslice-function-validateslice-buffer-offset-count-operation-src-minisql-platform-file-ml-1697818811"></a>
### validateSlice

```ml
function validateSlice(buffer, offset, count, operation)
```

Validates the slice. Inputs: `buffer`, `offset`, `count`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L104)

<a id="function-function-minisql-platform-file-writeat-function-writeat-file-fileoffset-source-sourceoffset-count-src-minisql-platform-file-ml-216703943"></a>
### writeAt

```ml
function writeAt(file, fileOffset, source, sourceOffset, count)
```

Writes the at. Inputs: `file`, `fileOffset`, `source`, `sourceOffset`, `count`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `fileOffset` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L278)

<a id="global-global-minisql-platform-file-writefaultremainingbytes-writefaultremainingbytes-src-minisql-platform-file-ml-2080116284"></a>
### writeFaultRemainingBytes

```ml
writeFaultRemainingBytes
```

Process-local deterministic write-failure state used exclusively by native fault-injection tests. Production code never enables it, and no environment variable or server configuration can activate it accidentally.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L25)
