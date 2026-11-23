# `src/minisql/platform/file_linux.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform file linux facilities for this project.

Package: [`minisql.platform.file_linux`](Package-minisql-platform-file-linux-1190311064.md)

Reachable from entry: **no**

## Imports

- `std/io/file.ml` as `portable` → `../MiniLangCompilerML/std/io/file.ml` — external dependency

## Declarations

<a id="function-function-minisql-platform-file-linux-closenative-function-closenative-handle-src-minisql-platform-file-linux-ml-977730280"></a>
### closeNative

```ml
function closeNative(handle)
```

Closes the portable descriptor after its caller has released any lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L207)

<a id="function-function-minisql-platform-file-linux-componentname-function-componentname-src-minisql-platform-file-linux-ml-448394684"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name used by the module catalog.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L249)

<a id="function-function-minisql-platform-file-linux-convert-function-convert-result-operation-src-minisql-platform-file-linux-ml-1622425904"></a>
### convert

```ml
function convert(result, operation)
```

Converts a portable file result to MiniSQL's stable storage error codes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L61)

<a id="constant-constant-minisql-platform-file-linux-create-always-const-create-always-2-src-minisql-platform-file-linux-ml-998114759"></a>
### CREATE_ALWAYS

```ml
const CREATE_ALWAYS = 2
```

Defines the create always constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L30)

<a id="constant-constant-minisql-platform-file-linux-create-new-const-create-new-1-src-minisql-platform-file-linux-ml-454671736"></a>
### CREATE_NEW

```ml
const CREATE_NEW = 1
```

Defines the create new constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L28)

<a id="function-function-minisql-platform-file-linux-createdirectory-function-createdirectory-path-src-minisql-platform-file-linux-ml-2095257749"></a>
### createDirectory

```ml
function createDirectory(path)
```

Creates one directory and retains the failing path in diagnostic errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L226)

<a id="function-function-minisql-platform-file-linux-deletepath-function-deletepath-path-src-minisql-platform-file-linux-ml-1817964023"></a>
### deletePath

```ml
function deletePath(path)
```

Deletes one file-system path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L214)

<a id="function-function-minisql-platform-file-linux-directoryexists-function-directoryexists-path-src-minisql-platform-file-linux-ml-1317266457"></a>
### directoryExists

```ml
function directoryExists(path)
```

Reports whether a directory exists at the path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L220)

<a id="function-function-minisql-platform-file-linux-fail-function-fail-code-operation-message-src-minisql-platform-file-linux-ml-1578255401"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a MiniSQL platform error with consistent Linux component context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L54)

<a id="constant-constant-minisql-platform-file-linux-file-attribute-directory-const-file-attribute-directory-16-src-minisql-platform-file-linux-ml-2059999084"></a>
### FILE_ATTRIBUTE_DIRECTORY

```ml
const FILE_ATTRIBUTE_DIRECTORY = 16
```

Defines the file attribute directory constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L38)

<a id="constant-constant-minisql-platform-file-linux-file-share-delete-const-file-share-delete-4-src-minisql-platform-file-linux-ml-1311964861"></a>
### FILE_SHARE_DELETE

```ml
const FILE_SHARE_DELETE = 4
```

Defines the file share delete constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L26)

<a id="constant-constant-minisql-platform-file-linux-file-share-read-const-file-share-read-1-src-minisql-platform-file-linux-ml-319679744"></a>
### FILE_SHARE_READ

```ml
const FILE_SHARE_READ = 1
```

Defines the file share read constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L22)

<a id="constant-constant-minisql-platform-file-linux-file-share-write-const-file-share-write-2-src-minisql-platform-file-linux-ml-49486429"></a>
### FILE_SHARE_WRITE

```ml
const FILE_SHARE_WRITE = 2
```

Defines the file share write constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L24)

<a id="function-function-minisql-platform-file-linux-fileexists-function-fileexists-path-src-minisql-platform-file-linux-ml-763414651"></a>
### fileExists

```ml
function fileExists(path)
```

Reports whether a regular file exists at the path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L223)

<a id="function-function-minisql-platform-file-linux-flush-function-flush-handle-src-minisql-platform-file-linux-ml-34187698"></a>
### flush

```ml
function flush(handle)
```

Forces writable data and metadata to stable storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L182)

<a id="constant-constant-minisql-platform-file-linux-generic-read-const-generic-read-2147483648-src-minisql-platform-file-linux-ml-1586461252"></a>
### GENERIC_READ

```ml
const GENERIC_READ = 2147483648
```

Defines the generic read constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L18)

<a id="constant-constant-minisql-platform-file-linux-generic-write-const-generic-write-1073741824-src-minisql-platform-file-linux-ml-2121150068"></a>
### GENERIC_WRITE

```ml
const GENERIC_WRITE = 1073741824
```

Defines the generic write constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L20)

<a id="constant-constant-minisql-platform-file-linux-invalid-argument-const-invalid-argument-9001-src-minisql-platform-file-linux-ml-278067799"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

POSIX adapter matching the historical file_win32 contract. Keeping this


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L11)

<a id="constant-constant-minisql-platform-file-linux-invalid-file-attributes-const-invalid-file-attributes-4294967295-src-minisql-platform-file-linux-ml-1044748620"></a>
### INVALID_FILE_ATTRIBUTES

```ml
const INVALID_FILE_ATTRIBUTES = 4294967295
```

Defines the invalid file attributes constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L40)

<a id="constant-constant-minisql-platform-file-linux-io-failure-const-io-failure-9005-src-minisql-platform-file-linux-ml-799484071"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L13)

<a id="function-function-minisql-platform-file-linux-isimplemented-function-isimplemented-src-minisql-platform-file-linux-ml-1004817796"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the Linux backend is complete.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L259)

<a id="constant-constant-minisql-platform-file-linux-lock-conflict-const-lock-conflict-9007-src-minisql-platform-file-linux-ml-2078806877"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```

Defines the lock conflict constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L15)

<a id="function-function-minisql-platform-file-linux-lockwhole-function-lockwhole-handle-exclusive-failimmediately-src-minisql-platform-file-linux-ml-1635179700"></a>
### lockWhole

```ml
function lockWhole(handle, exclusive, failImmediately)
```

Acquires a shared or exclusive whole-file lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `exclusive` | `dynamic` | — | exclusive value consumed by this operation. |
| `failImmediately` | `dynamic` | — | failImmediately value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L191)

<a id="function-function-minisql-platform-file-linux-movepath-function-movepath-source-destination-replaceexisting-src-minisql-platform-file-linux-ml-500088980"></a>
### movePath

```ml
function movePath(source, destination, replaceExisting)
```

Atomically renames a path and optionally replaces the destination.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `replaceExisting` | `dynamic` | — | replaceExisting value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L238)

- [minisql.platform.file_linux.NativeFile](Type-minisql-platform-file-linux-nativefile-1048246571.md) — struct
<a id="constant-constant-minisql-platform-file-linux-open-always-const-open-always-4-src-minisql-platform-file-linux-ml-1142852665"></a>
### OPEN_ALWAYS

```ml
const OPEN_ALWAYS = 4
```

Defines the open always constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L34)

<a id="constant-constant-minisql-platform-file-linux-open-existing-const-open-existing-3-src-minisql-platform-file-linux-ml-1313640974"></a>
### OPEN_EXISTING

```ml
const OPEN_EXISTING = 3
```

Defines the open existing constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L32)

<a id="function-function-minisql-platform-file-linux-opennative-function-opennative-path-desiredaccess-sharemode-creationdisposition-writethrough-src-minisql-platform-file-linux-ml-1573037969"></a>
### openNative

```ml
function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
```

Opens a portable descriptor using the established Win32-like facade contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `desiredAccess` | `dynamic` | — | desiredAccess value consumed by this operation. |
| `shareMode` | `dynamic` | — | shareMode value consumed by this operation. |
| `creationDisposition` | `dynamic` | — | creationDisposition value consumed by this operation. |
| `writeThrough` | `dynamic` | — | writeThrough value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L73)

<a id="function-function-minisql-platform-file-linux-opennativepositionedread-function-opennativepositionedread-path-desiredaccess-sharemode-creationdisposition-writethrough-src-minisql-platform-file-linux-ml-1550033345"></a>
### openNativePositionedRead

```ml
function openNativePositionedRead(path, desiredAccess, shareMode, creationDisposition, writeThrough)
```

Linux descriptors already use pread for explicit-offset reads, so the positioned-read constructor is identical to the ordinary native open.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `desiredAccess` | `dynamic` | — | desiredAccess value consumed by this operation. |
| `shareMode` | `dynamic` | — | shareMode value consumed by this operation. |
| `creationDisposition` | `dynamic` | — | creationDisposition value consumed by this operation. |
| `writeThrough` | `dynamic` | — | writeThrough value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L105)

<a id="function-function-minisql-platform-file-linux-pathattributes-function-pathattributes-path-src-minisql-platform-file-linux-ml-586789523"></a>
### pathAttributes

```ml
function pathAttributes(path)
```

Returns the directory attribute bit, zero for files, or the invalid sentinel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L242)

<a id="function-function-minisql-platform-file-linux-pathexists-function-pathexists-path-src-minisql-platform-file-linux-ml-2056048423"></a>
### pathExists

```ml
function pathExists(path)
```

Reports whether either a file or directory exists at the path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L217)

<a id="function-function-minisql-platform-file-linux-readat-function-readat-handle-fileoffset-destination-destinationoffset-count-src-minisql-platform-file-linux-ml-1983300039"></a>
### readAt

```ml
function readAt(handle, fileOffset, destination, destinationOffset, count)
```

Positioned operations avoid a shared logical cursor when database readers use the same handle concurrently.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `fileOffset` | `dynamic` | — | fileOffset value consumed by this operation. |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L137)

<a id="function-function-minisql-platform-file-linux-readcurrent-function-readcurrent-handle-destination-count-src-minisql-platform-file-linux-ml-879143787"></a>
### readCurrent

```ml
function readCurrent(handle, destination, count)
```

Reads from the compatibility cursor and advances it by the transferred count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L122)

<a id="function-function-minisql-platform-file-linux-removedirectory-function-removedirectory-path-src-minisql-platform-file-linux-ml-133995665"></a>
### removeDirectory

```ml
function removeDirectory(path)
```

Removes one empty directory, including portable error translation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L233)

<a id="function-function-minisql-platform-file-linux-seek-function-seek-handle-offset-src-minisql-platform-file-linux-ml-567928533"></a>
### seek

```ml
function seek(handle, offset)
```

Moves the compatibility cursor without changing the native descriptor offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L112)

<a id="function-function-minisql-platform-file-linux-size-function-size-handle-src-minisql-platform-file-linux-ml-2090204638"></a>
### size

```ml
function size(handle)
```

Returns the current physical file size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L167)

<a id="function-function-minisql-platform-file-linux-targetmilestone-function-targetmilestone-src-minisql-platform-file-linux-ml-2018362690"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the first MiniSQL milestone whose file contract this adapter implements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L254)

<a id="function-function-minisql-platform-file-linux-truncate-function-truncate-handle-newsize-src-minisql-platform-file-linux-ml-1544441121"></a>
### truncate

```ml
function truncate(handle, newSize)
```

Changes the physical file size through the portable backend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `newSize` | `dynamic` | — | newSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L175)

<a id="constant-constant-minisql-platform-file-linux-truncate-existing-const-truncate-existing-5-src-minisql-platform-file-linux-ml-1555764564"></a>
### TRUNCATE_EXISTING

```ml
const TRUNCATE_EXISTING = 5
```

Defines the truncate existing constant used by the minisql platform file linux module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L36)

<a id="function-function-minisql-platform-file-linux-unlockwhole-function-unlockwhole-handle-src-minisql-platform-file-linux-ml-1639338244"></a>
### unlockWhole

```ml
function unlockWhole(handle)
```

Releases the whole-file lock owned by this descriptor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L200)

<a id="function-function-minisql-platform-file-linux-writeat-function-writeat-handle-fileoffset-source-sourceoffset-count-src-minisql-platform-file-linux-ml-264313635"></a>
### writeAt

```ml
function writeAt(handle, fileOffset, source, sourceOffset, count)
```

Writes a source range at an explicit file offset without changing the cursor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `fileOffset` | `dynamic` | — | fileOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L160)

<a id="function-function-minisql-platform-file-linux-writecurrent-function-writecurrent-handle-source-count-src-minisql-platform-file-linux-ml-1686483018"></a>
### writeCurrent

```ml
function writeCurrent(handle, source, count)
```

Writes from the compatibility cursor and advances it by the transferred count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L146)
