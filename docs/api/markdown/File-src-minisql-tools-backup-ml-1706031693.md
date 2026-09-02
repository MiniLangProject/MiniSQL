# `src/minisql/tools/backup.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.tools.backup`](Package-minisql-tools-backup-478820365.md)

Reachable from entry: **no**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/catalog/statistics.ml` as `statistics` → [src/minisql/catalog/statistics.ml](File-src-minisql-catalog-statistics-ml-1707584758.md)
- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/diagnostics.ml` as `diagnostics` → [src/minisql/common/diagnostics.ml](File-src-minisql-common-diagnostics-ml-1805539733.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/executor/dml.ml` as `dml` → [src/minisql/executor/dml.ml](File-src-minisql-executor-dml-ml-1278137778.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/security/key_provider.ml` as `key_provider` → [src/minisql/security/key_provider.ml](File-src-minisql-security-key-provider-ml-1192998689.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/storage/btree.ml` as `btree` → [src/minisql/storage/btree.ml](File-src-minisql-storage-btree-ml-1474397187.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/transaction/checkpoint.ml` as `checkpoint` → [src/minisql/transaction/checkpoint.ml](File-src-minisql-transaction-checkpoint-ml-1306482346.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency

## Declarations

<a id="function-function-minisql-tools-backup-addcapture-function-addcapture-files-relativepath-data-src-minisql-tools-backup-ml-1109410318"></a>
### addCapture

```ml
function addCapture(files, relativePath, data)
```

Adds capture using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `dynamic` | — |  |
| `relativePath` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L294)

<a id="constant-constant-minisql-tools-backup-archive-format-version-const-archive-format-version-1-src-minisql-tools-backup-ml-828499186"></a>
### ARCHIVE_FORMAT_VERSION

```ml
const ARCHIVE_FORMAT_VERSION = 1
```

M31 offline WAL archive and point-in-time recovery. Archive generations store complete, validated WAL prefixes. This is intentionally conservative: it trades archive space for simple continuity validation and deterministic PITR.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L683)

<a id="constant-constant-minisql-tools-backup-archive-kind-const-archive-kind-80-src-minisql-tools-backup-ml-1435095023"></a>
### ARCHIVE_KIND

```ml
const ARCHIVE_KIND = 80
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L684)

<a id="function-function-minisql-tools-backup-archiveinit-function-archiveinit-databasepath-archivepath-src-minisql-tools-backup-ml-1706029799"></a>
### archiveInit

```ml
function archiveInit(databasePath, archivePath)
```

Implements archive init for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L984)

<a id="function-function-minisql-tools-backup-archivemagic-function-archivemagic-src-minisql-tools-backup-ml-1272736660"></a>
### archiveMagic

```ml
function archiveMagic()
```

Implements archive magic for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L796)

- [minisql.tools.backup.ArchiveManifest](Type-minisql-tools-backup-archivemanifest-1020964600.md) — struct
<a id="function-function-minisql-tools-backup-archivemanifestpath-function-archivemanifestpath-archivepath-src-minisql-tools-backup-ml-1026152941"></a>
### archiveManifestPath

```ml
function archiveManifestPath(archivePath)
```

Implements archive manifest path for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L803)

- [minisql.tools.backup.ArchiveReport](Type-minisql-tools-backup-archivereport-574164319.md) — struct
<a id="function-function-minisql-tools-backup-archivewal-function-archivewal-databasepath-archivepath-src-minisql-tools-backup-ml-182739375"></a>
### archiveWal

```ml
function archiveWal(databasePath, archivePath)
```

Implements archive WAL for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1083)

<a id="function-function-minisql-tools-backup-archivewaldirectory-function-archivewaldirectory-archivepath-src-minisql-tools-backup-ml-321637523"></a>
### archiveWalDirectory

```ml
function archiveWalDirectory(archivePath)
```

Implements archive WAL directory for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L810)

<a id="function-function-minisql-tools-backup-archivewallive-function-archivewallive-databasepath-archivepath-src-minisql-tools-backup-ml-1178948391"></a>
### archiveWalLive

```ml
function archiveWalLive(databasePath, archivePath)
```

Implements archive WAL live for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1061)

<a id="function-function-minisql-tools-backup-archivewalname-function-archivewalname-generation-src-minisql-tools-backup-ml-181544718"></a>
### archiveWalName

```ml
function archiveWalName(generation)
```

Implements archive WAL name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `generation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L817)

<a id="function-function-minisql-tools-backup-archivewalpath-function-archivewalpath-archivepath-manifest-src-minisql-tools-backup-ml-1321738674"></a>
### archiveWalPath

```ml
function archiveWalPath(archivePath, manifest)
```

Implements archive WAL path for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `manifest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L940)

<a id="function-function-minisql-tools-backup-backupaad-function-backupaad-relativepath-src-minisql-tools-backup-ml-331299653"></a>
### backupAad

```ml
function backupAad(relativePath)
```

Creates domain-separated AAD bound to one backup-relative path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `relativePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L534)

- [minisql.tools.backup.BackupEntry](Type-minisql-tools-backup-backupentry-1021434965.md) — struct
<a id="function-function-minisql-tools-backup-backupentrylength-function-backupentrylength-manifest-relativepath-src-minisql-tools-backup-ml-421024386"></a>
### backupEntryLength

```ml
function backupEntryLength(manifest, relativePath)
```

Implements backup entry length for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manifest` | `dynamic` | — |  |
| `relativePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L919)

- [minisql.tools.backup.BackupManifest](Type-minisql-tools-backup-backupmanifest-1611147358.md) — struct
- [minisql.tools.backup.BackupReport](Type-minisql-tools-backup-backupreport-371133205.md) — struct
<a id="function-function-minisql-tools-backup-bytesequal-function-bytesequal-left-right-src-minisql-tools-backup-ml-1644894833"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Implements bytes equal for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L155)

<a id="function-function-minisql-tools-backup-capturedatabase-function-capturedatabase-database-src-minisql-tools-backup-ml-1602180609"></a>
### captureDatabase

```ml
function captureDatabase(database)
```

Implements capture database for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L333)

- [minisql.tools.backup.CapturedFile](Type-minisql-tools-backup-capturedfile-230458989.md) — struct
<a id="function-function-minisql-tools-backup-capturepath-function-capturepath-files-databasepath-relativepath-required-src-minisql-tools-backup-ml-2112230037"></a>
### capturePath

```ml
function capturePath(files, databasePath, relativePath, required)
```

Implements capture path for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `relativePath` | `dynamic` | — |  |
| `required` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L307)

<a id="function-function-minisql-tools-backup-componentname-function-componentname-src-minisql-tools-backup-ml-302176928"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1332)

<a id="function-function-minisql-tools-backup-containsint-function-containsint-values-expected-src-minisql-tools-backup-ml-1632169662"></a>
### containsInt

```ml
function containsInt(values, expected)
```

Returns whether the supplied value satisfies the int condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `expected` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L178)

<a id="function-function-minisql-tools-backup-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-tools-backup-ml-248683967"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Implements copy exact for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L167)

<a id="constant-constant-minisql-tools-backup-corrupt-data-const-corrupt-data-9004-src-minisql-tools-backup-ml-251256304"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L33)

<a id="function-function-minisql-tools-backup-createlayout-function-createlayout-root-src-minisql-tools-backup-ml-893508368"></a>
### createLayout

```ml
function createLayout(root)
```

Creates layout using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L229)

<a id="function-function-minisql-tools-backup-decodearchivemanifest-function-decodearchivemanifest-source-src-minisql-tools-backup-ml-285892889"></a>
### decodeArchiveManifest

```ml
function decodeArchiveManifest(source)
```

Decodes archive manifest using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L883)

<a id="function-function-minisql-tools-backup-decodemanifest-function-decodemanifest-source-src-minisql-tools-backup-ml-955461535"></a>
### decodeManifest

```ml
function decodeManifest(source)
```

Decodes manifest using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L435)

<a id="function-function-minisql-tools-backup-decodestandbystate-function-decodestandbystate-source-src-minisql-tools-backup-ml-1229626383"></a>
### decodeStandbyState

```ml
function decodeStandbyState(source)
```

Decodes standby state using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1207)

<a id="function-function-minisql-tools-backup-decryptbackupdata-function-decryptbackupdata-key-relativepath-encoded-src-minisql-tools-backup-ml-1097415852"></a>
### decryptBackupData

```ml
function decryptBackupData(key, relativePath, encoded)
```

Authenticates and decrypts one captured backup file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `relativePath` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L551)

<a id="function-function-minisql-tools-backup-encodearchivemanifest-function-encodearchivemanifest-manifest-src-minisql-tools-backup-ml-1260606537"></a>
### encodeArchiveManifest

```ml
function encodeArchiveManifest(manifest)
```

Encodes archive manifest using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manifest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L854)

<a id="function-function-minisql-tools-backup-encodemanifest-function-encodemanifest-manifest-src-minisql-tools-backup-ml-1234638131"></a>
### encodeManifest

```ml
function encodeManifest(manifest)
```

Encodes manifest using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manifest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L401)

<a id="function-function-minisql-tools-backup-encodestandbystate-function-encodestandbystate-state-src-minisql-tools-backup-ml-1362597349"></a>
### encodeStandbyState

```ml
function encodeStandbyState(state)
```

Encodes standby state using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1190)

<a id="function-function-minisql-tools-backup-encryptbackupdata-function-encryptbackupdata-key-relativepath-plaintext-src-minisql-tools-backup-ml-1022597223"></a>
### encryptBackupData

```ml
function encryptBackupData(key, relativePath, plaintext)
```

Encrypts one captured backup file independently.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `relativePath` | `dynamic` | — |  |
| `plaintext` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L539)

<a id="function-function-minisql-tools-backup-ensuredirectory-function-ensuredirectory-path-src-minisql-tools-backup-ml-855005447"></a>
### ensureDirectory

```ml
function ensureDirectory(path)
```

Ensures directory using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L207)

<a id="function-function-minisql-tools-backup-fail-function-fail-code-operation-message-src-minisql-tools-backup-ml-1136335015"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L119)

<a id="constant-constant-minisql-tools-backup-format-version-const-format-version-1-src-minisql-tools-backup-ml-53108972"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L36)

<a id="function-function-minisql-tools-backup-indexids-function-indexids-state-src-minisql-tools-backup-ml-1849379677"></a>
### indexIds

```ml
function indexIds(state)
```

Implements index ids for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L319)

<a id="constant-constant-minisql-tools-backup-invalid-argument-const-invalid-argument-9001-src-minisql-tools-backup-ml-2019599101"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

M20 verified directory backup. A backup is a self-contained directory with byte-identical database files plus a CRC-protected manifest. The database-wide lock remains held while every owner-handle snapshot is taken.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L31)

<a id="function-function-minisql-tools-backup-isarchivemanifest-function-isarchivemanifest-value-src-minisql-tools-backup-ml-1624956835"></a>
### isArchiveManifest

```ml
function isArchiveManifest(value)
```

Returns whether the supplied value satisfies the archive manifest condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L761)

<a id="function-function-minisql-tools-backup-isarchivereport-function-isarchivereport-value-src-minisql-tools-backup-ml-392014977"></a>
### isArchiveReport

```ml
function isArchiveReport(value)
```

Returns whether the supplied value satisfies the archive report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L768)

<a id="function-function-minisql-tools-backup-isbackupmanifest-function-isbackupmanifest-value-src-minisql-tools-backup-ml-1851346601"></a>
### isBackupManifest

```ml
function isBackupManifest(value)
```

Returns whether the supplied value satisfies the backup manifest condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L126)

<a id="function-function-minisql-tools-backup-isbackupreport-function-isbackupreport-value-src-minisql-tools-backup-ml-226614049"></a>
### isBackupReport

```ml
function isBackupReport(value)
```

Returns whether the supplied value satisfies the backup report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L133)

<a id="function-function-minisql-tools-backup-isimplemented-function-isimplemented-src-minisql-tools-backup-ml-1956394640"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1346)

<a id="function-function-minisql-tools-backup-ispitrreport-function-ispitrreport-value-src-minisql-tools-backup-ml-539689693"></a>
### isPitrReport

```ml
function isPitrReport(value)
```

Returns whether the supplied value satisfies the point-in-time recovery report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L775)

<a id="function-function-minisql-tools-backup-isrestorereport-function-isrestorereport-value-src-minisql-tools-backup-ml-2105247993"></a>
### isRestoreReport

```ml
function isRestoreReport(value)
```

Returns whether the supplied value satisfies the restore report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L140)

<a id="function-function-minisql-tools-backup-isstandbyreport-function-isstandbyreport-value-src-minisql-tools-backup-ml-1504452719"></a>
### isStandbyReport

```ml
function isStandbyReport(value)
```

Returns whether the supplied value satisfies the standby report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L789)

<a id="function-function-minisql-tools-backup-isstandbystate-function-isstandbystate-value-src-minisql-tools-backup-ml-1313417777"></a>
### isStandbyState

```ml
function isStandbyState(value)
```

Returns whether the supplied value satisfies the standby state condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L782)

<a id="function-function-minisql-tools-backup-livewalpath-function-livewalpath-databasepath-src-minisql-tools-backup-ml-275085540"></a>
### liveWalPath

```ml
function liveWalPath(databasePath)
```

Implements live WAL path for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1028)

<a id="function-function-minisql-tools-backup-m0selftestline-function-m0selftestline-src-minisql-tools-backup-ml-2042363976"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Implements m0 self test line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1318)

<a id="constant-constant-minisql-tools-backup-manifest-kind-const-manifest-kind-60-src-minisql-tools-backup-ml-280252713"></a>
### MANIFEST_KIND

```ml
const MANIFEST_KIND = 60
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L37)

<a id="function-function-minisql-tools-backup-manifestfromfiles-function-manifestfromfiles-databaseid-pagesize-files-src-minisql-tools-backup-ml-641542261"></a>
### manifestFromFiles

```ml
function manifestFromFiles(databaseId, pageSize, files)
```

Implements manifest from files for this module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `files` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L386)

<a id="function-function-minisql-tools-backup-manifestmagic-function-manifestmagic-src-minisql-tools-backup-ml-2137322480"></a>
### manifestMagic

```ml
function manifestMagic()
```

Implements manifest magic for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L147)

<a id="function-function-minisql-tools-backup-materializestandby-function-materializestandby-archivepath-databasepath-src-minisql-tools-backup-ml-811618635"></a>
### materializeStandby

```ml
function materializeStandby(archivePath, databasePath)
```

Implements materialize standby for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1239)

<a id="constant-constant-minisql-tools-backup-max-archive-generations-const-max-archive-generations-4294967295-src-minisql-tools-backup-ml-2132066168"></a>
### MAX_ARCHIVE_GENERATIONS

```ml
const MAX_ARCHIVE_GENERATIONS = 4294967295
```

Archive generations use an on-disk U32. M48 live shipping may run for a long-lived server, so the implementation accepts the full representable range instead of the original M31 test-oriented cap of 1024 snapshots.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L690)

<a id="constant-constant-minisql-tools-backup-max-file-bytes-const-max-file-bytes-4294967295-src-minisql-tools-backup-ml-728368892"></a>
### MAX_FILE_BYTES

```ml
const MAX_FILE_BYTES = 4294967295
```

Backup v1 encodes file lengths as U64 and entry counts as U32. Snapshot and CRC APIs accept one U32-sized byte buffer at a time, while aggregate backup size uses the native address-space domain. These guards therefore express persisted/API representation limits rather than arbitrary database caps.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L43)

<a id="constant-constant-minisql-tools-backup-max-file-count-const-max-file-count-4294967295-src-minisql-tools-backup-ml-1829748272"></a>
### MAX_FILE_COUNT

```ml
const MAX_FILE_COUNT = 4294967295
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L45)

<a id="constant-constant-minisql-tools-backup-max-path-bytes-const-max-path-bytes-240-src-minisql-tools-backup-ml-149356933"></a>
### MAX_PATH_BYTES

```ml
const MAX_PATH_BYTES = 240
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L38)

<a id="constant-constant-minisql-tools-backup-max-total-bytes-const-max-total-bytes-1152921504606846975-src-minisql-tools-backup-ml-1879201580"></a>
### MAX_TOTAL_BYTES

```ml
const MAX_TOTAL_BYTES = 1152921504606846975
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L44)

<a id="function-function-minisql-tools-backup-movepathreliably-function-movepathreliably-source-destination-replaceexisting-src-minisql-tools-backup-ml-738649356"></a>
### movePathReliably

```ml
function movePathReliably(source, destination, replaceExisting)
```

Publishes a staged file or directory despite short-lived Windows scanner or indexer handles. Each attempt is still the same atomic MoveFileEx operation; permanent errors remain visible after a bounded one-second retry window. Inputs: `source`, `destination`, and replacement policy. Returns true after publication.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `replaceExisting` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L216)

<a id="constant-constant-minisql-tools-backup-object-exists-const-object-exists-9013-src-minisql-tools-backup-ml-1971002162"></a>
### OBJECT_EXISTS

```ml
const OBJECT_EXISTS = 9013
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L34)

<a id="function-function-minisql-tools-backup-overwritewhole-function-overwritewhole-path-data-src-minisql-tools-backup-ml-607497545"></a>
### overwriteWhole

```ml
function overwriteWhole(path, data)
```

Implements overwrite whole for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L825)

- [minisql.tools.backup.PitrReport](Type-minisql-tools-backup-pitrreport-949770206.md) — struct
<a id="function-function-minisql-tools-backup-prefixmatches-function-prefixmatches-previous-current-src-minisql-tools-backup-ml-1543387970"></a>
### prefixMatches

```ml
function prefixMatches(previous, current)
```

Implements prefix matches for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previous` | `dynamic` | — |  |
| `current` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1015)

<a id="function-function-minisql-tools-backup-promotestandby-function-promotestandby-databasepath-src-minisql-tools-backup-ml-1852820714"></a>
### promoteStandby

```ml
function promoteStandby(databasePath)
```

Implements promote standby for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1293)

<a id="function-function-minisql-tools-backup-readarchivemanifest-function-readarchivemanifest-archivepath-src-minisql-tools-backup-ml-1214907131"></a>
### readArchiveManifest

```ml
function readArchiveManifest(archivePath)
```

Reads archive manifest using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L910)

<a id="function-function-minisql-tools-backup-readhandle-function-readhandle-handle-maxbytes-operation-src-minisql-tools-backup-ml-1029672802"></a>
### readHandle

```ml
function readHandle(handle, maxBytes, operation)
```

Reads handle using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `maxBytes` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L243)

<a id="function-function-minisql-tools-backup-readmanifest-function-readmanifest-backuppath-src-minisql-tools-backup-ml-391514703"></a>
### readManifest

```ml
function readManifest(backupPath)
```

Reads manifest using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backupPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L642)

<a id="function-function-minisql-tools-backup-readstandbystate-function-readstandbystate-databasepath-src-minisql-tools-backup-ml-1015451342"></a>
### readStandbyState

```ml
function readStandbyState(databasePath)
```

Reads standby state using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1222)

<a id="function-function-minisql-tools-backup-readwhole-function-readwhole-path-maxbytes-src-minisql-tools-backup-ml-119353600"></a>
### readWhole

```ml
function readWhole(path, maxBytes)
```

Reads whole using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `maxBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L257)

<a id="function-function-minisql-tools-backup-refreshstandby-function-refreshstandby-archivepath-databasepath-src-minisql-tools-backup-ml-412727603"></a>
### refreshStandby

```ml
function refreshStandby(archivePath, databasePath)
```

Implements refresh standby for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1258)

<a id="function-function-minisql-tools-backup-repairrecoveredindexes-function-repairrecoveredindexes-database-required-operation-src-minisql-tools-backup-ml-1399968009"></a>
### repairRecoveredIndexes

```ml
function repairRecoveredIndexes(database, required, operation)
```

WAL archives contain authoritative table-page images, while B+ tree files remain derived from the base backup. Rebuild them before publishing any recovered generation that applied post-base WAL records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `required` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L50)

<a id="function-function-minisql-tools-backup-replacewholeatomic-function-replacewholeatomic-path-data-src-minisql-tools-backup-ml-259514697"></a>
### replaceWholeAtomic

```ml
function replaceWholeAtomic(path, data)
```

Implements replace whole atomic for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L842)

<a id="function-function-minisql-tools-backup-restore-function-restore-backuppath-databasepath-src-minisql-tools-backup-ml-321429073"></a>
### restore

```ml
function restore(backupPath, databasePath)
```

Implements restore for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backupPath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L652)

<a id="function-function-minisql-tools-backup-restoreencrypted-function-restoreencrypted-backuppath-databasepath-keyfilepath-src-minisql-tools-backup-ml-308789863"></a>
### restoreEncrypted

```ml
function restoreEncrypted(backupPath, databasePath, keyFilePath)
```

Restores and validates an encrypted backup before atomic publication.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backupPath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `keyFilePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L604)

<a id="function-function-minisql-tools-backup-restorelatest-function-restorelatest-archivepath-databasepath-src-minisql-tools-backup-ml-1735680365"></a>
### restoreLatest

```ml
function restoreLatest(archivePath, databasePath)
```

Implements restore latest for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1160)

- [minisql.tools.backup.RestoreReport](Type-minisql-tools-backup-restorereport-1235503011.md) — struct
<a id="function-function-minisql-tools-backup-restoretolsn-function-restoretolsn-archivepath-databasepath-targetlsn-src-minisql-tools-backup-ml-227964921"></a>
### restoreToLsn

```ml
function restoreToLsn(archivePath, databasePath, targetLsn)
```

Implements restore to LSN for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `targetLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1128)

<a id="function-function-minisql-tools-backup-run-function-run-databasepath-backuppath-src-minisql-tools-backup-ml-1458970659"></a>
### run

```ml
function run(databasePath, backupPath)
```

Runs run using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `backupPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L520)

<a id="function-function-minisql-tools-backup-runencrypted-function-runencrypted-databasepath-backuppath-keyfilepath-src-minisql-tools-backup-ml-1084426691"></a>
### runEncrypted

```ml
function runEncrypted(databasePath, backupPath, keyFilePath)
```

Opens a database and creates a verified encrypted backup export.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `backupPath` | `dynamic` | — |  |
| `keyFilePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L589)

<a id="function-function-minisql-tools-backup-runopen-function-runopen-database-backuppath-src-minisql-tools-backup-ml-244007794"></a>
### runOpen

```ml
function runOpen(database, backupPath)
```

Runs open using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `backupPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L501)

<a id="function-function-minisql-tools-backup-runopenencrypted-function-runopenencrypted-database-backuppath-key-provider-src-minisql-tools-backup-ml-439077384"></a>
### runOpenEncrypted

```ml
function runOpenEncrypted(database, backupPath, key, provider)
```

Captures and publishes an encrypted backup from an open database.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `backupPath` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `provider` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L559)

<a id="function-function-minisql-tools-backup-snapshotdurablewallive-function-snapshotdurablewallive-databasepath-src-minisql-tools-backup-ml-949565154"></a>
### snapshotDurableWalLive

```ml
function snapshotDurableWalLive(databasePath)
```

Implements snapshot durable WAL live for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1037)

<a id="function-function-minisql-tools-backup-snapshotwal-function-snapshotwal-database-src-minisql-tools-backup-ml-616823259"></a>
### snapshotWal

```ml
function snapshotWal(database)
```

Implements snapshot WAL for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L929)

<a id="constant-constant-minisql-tools-backup-standby-format-version-const-standby-format-version-1-src-minisql-tools-backup-ml-1474826772"></a>
### STANDBY_FORMAT_VERSION

```ml
const STANDBY_FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L685)

<a id="constant-constant-minisql-tools-backup-standby-kind-const-standby-kind-81-src-minisql-tools-backup-ml-1484241170"></a>
### STANDBY_KIND

```ml
const STANDBY_KIND = 81
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L686)

<a id="function-function-minisql-tools-backup-standbymagic-function-standbymagic-src-minisql-tools-backup-ml-834893560"></a>
### standbyMagic

```ml
function standbyMagic()
```

Implements standby magic for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1168)

<a id="function-function-minisql-tools-backup-standbypromotedpath-function-standbypromotedpath-databasepath-src-minisql-tools-backup-ml-1651985182"></a>
### standbyPromotedPath

```ml
function standbyPromotedPath(databasePath)
```

Implements standby promoted path for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1182)

- [minisql.tools.backup.StandbyReport](Type-minisql-tools-backup-standbyreport-1489782280.md) — struct
- [minisql.tools.backup.StandbyState](Type-minisql-tools-backup-standbystate-1928784087.md) — struct
<a id="function-function-minisql-tools-backup-standbystatepath-function-standbystatepath-databasepath-src-minisql-tools-backup-ml-828170686"></a>
### standbyStatePath

```ml
function standbyStatePath(databasePath)
```

Implements standby state path for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1175)

<a id="function-function-minisql-tools-backup-standbystatus-function-standbystatus-databasepath-src-minisql-tools-backup-ml-402635228"></a>
### standbyStatus

```ml
function standbyStatus(databasePath)
```

Implements standby status for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1311)

<a id="function-function-minisql-tools-backup-targetmilestone-function-targetmilestone-src-minisql-tools-backup-ml-1164184786"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1339)

<a id="constant-constant-minisql-tools-backup-unsupported-format-const-unsupported-format-9003-src-minisql-tools-backup-ml-466346591"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L32)

<a id="function-function-minisql-tools-backup-validaterelativepath-function-validaterelativepath-relativepath-operation-src-minisql-tools-backup-ml-22637890"></a>
### validateRelativePath

```ml
function validateRelativePath(relativePath, operation)
```

Validates relative path using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `relativePath` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L189)

<a id="function-function-minisql-tools-backup-verifyarchive-function-verifyarchive-archivepath-src-minisql-tools-backup-ml-1451850835"></a>
### verifyArchive

```ml
function verifyArchive(archivePath)
```

Verifies archive using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archivePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L967)

<a id="function-function-minisql-tools-backup-verifybackupfiles-function-verifybackupfiles-backuppath-manifest-src-minisql-tools-backup-ml-1167208972"></a>
### verifyBackupFiles

```ml
function verifyBackupFiles(backupPath, manifest)
```

Verifies backup files using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backupPath` | `dynamic` | — |  |
| `manifest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L483)

<a id="function-function-minisql-tools-backup-verifywalsnapshot-function-verifywalsnapshot-manifest-walbytes-src-minisql-tools-backup-ml-2059858408"></a>
### verifyWalSnapshot

```ml
function verifyWalSnapshot(manifest, walBytes)
```

Verifies WAL snapshot using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manifest` | `dynamic` | — |  |
| `walBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L948)

<a id="function-function-minisql-tools-backup-versionline-function-versionline-src-minisql-tools-backup-ml-157854552"></a>
### versionLine

```ml
function versionLine()
```

Implements version line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1325)

<a id="function-function-minisql-tools-backup-walprefixat-function-walprefixat-walbytes-targetlsn-src-minisql-tools-backup-ml-210293209"></a>
### walPrefixAt

```ml
function walPrefixAt(walBytes, targetLsn)
```

Implements WAL prefix at for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `walBytes` | `dynamic` | — |  |
| `targetLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1109)

<a id="function-function-minisql-tools-backup-writecapturedfiles-function-writecapturedfiles-root-files-src-minisql-tools-backup-ml-158876291"></a>
### writeCapturedFiles

```ml
function writeCapturedFiles(root, files)
```

Writes captured files using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — |  |
| `files` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L472)

<a id="function-function-minisql-tools-backup-writestandbystate-function-writestandbystate-databasepath-state-src-minisql-tools-backup-ml-2099569541"></a>
### writeStandbyState

```ml
function writeStandbyState(databasePath, state)
```

Writes standby state using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L1231)

<a id="function-function-minisql-tools-backup-writewhole-function-writewhole-path-data-src-minisql-tools-backup-ml-999603721"></a>
### writeWhole

```ml
function writeWhole(path, data)
```

Writes whole using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L276)
