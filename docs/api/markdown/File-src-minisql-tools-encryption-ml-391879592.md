# `src/minisql/tools/encryption.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.tools.encryption`](Package-minisql-tools-encryption-1747363322.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/lock.ml` as `file_lock` → [src/minisql/platform/lock.ml](File-src-minisql-platform-lock-ml-271785262.md)
- `minisql/security/key_provider.ml` as `key_provider` → [src/minisql/security/key_provider.ml](File-src-minisql-security-key-provider-ml-1192998689.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)

## Declarations

<a id="function-function-minisql-tools-encryption-addifexists-function-addifexists-paths-path-src-minisql-tools-encryption-ml-859333601"></a>
### addIfExists

```ml
function addIfExists(paths, path)
```

Adds one existing physical artifact to a migration plan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `paths` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L42)

<a id="function-function-minisql-tools-encryption-componentname-function-componentname-src-minisql-tools-encryption-ml-1225962280"></a>
### componentName

```ml
function componentName()
```

Returns the stable component name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L128)

<a id="function-function-minisql-tools-encryption-contains-function-contains-values-wanted-src-minisql-tools-encryption-ml-53962951"></a>
### contains

```ml
function contains(values, wanted)
```

Tests integer membership in a bounded metadata array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L23)

<a id="function-function-minisql-tools-encryption-enable-function-enable-databasepath-keyfilepath-src-minisql-tools-encryption-ml-406033832"></a>
### enable

```ml
function enable(databasePath, keyFilePath)
```

Enables resumable TDE migration. Mixed plaintext/encrypted files are valid during conversion because every superblock carries its own feature bit. Enables or resumes offline TDE migration for one database.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `keyFilePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L58)

<a id="function-function-minisql-tools-encryption-fail-function-fail-operation-message-src-minisql-tools-encryption-ml-422168880"></a>
### fail

```ml
function fail(operation, message)
```

Creates a structured encryption-administration error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L18)

<a id="function-function-minisql-tools-encryption-generatekeyfile-function-generatekeyfile-path-src-minisql-tools-encryption-ml-1958228393"></a>
### generateKeyFile

```ml
function generateKeyFile(path)
```

Creates a durable new raw 256-bit provider key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L112)

<a id="function-function-minisql-tools-encryption-indexids-function-indexids-state-src-minisql-tools-encryption-ml-984698431"></a>
### indexIds

```ml
function indexIds(state)
```

Collects unique physical index identifiers from schema constraints.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L31)

<a id="constant-constant-minisql-tools-encryption-invalid-argument-const-invalid-argument-9001-src-minisql-tools-encryption-ml-349678837"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L15)

<a id="function-function-minisql-tools-encryption-isimplemented-function-isimplemented-src-minisql-tools-encryption-ml-51389920"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the component is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L138)

<a id="function-function-minisql-tools-encryption-releasemigrationlock-function-releasemigrationlock-locktoken-lockfile-src-minisql-tools-encryption-ml-1306300495"></a>
### releaseMigrationLock

```ml
function releaseMigrationLock(lockToken, lockFile)
```

Releases the migration's process-visible database lock and owning handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lockToken` | `dynamic` | — |  |
| `lockFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L48)

<a id="function-function-minisql-tools-encryption-rotate-function-rotate-databasepath-newkeyfilepath-src-minisql-tools-encryption-ml-1390703746"></a>
### rotate

```ml
function rotate(databasePath, newKeyFilePath)
```

Rewraps the database DEK under a new external KEK.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `newKeyFilePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L105)

<a id="function-function-minisql-tools-encryption-targetmilestone-function-targetmilestone-src-minisql-tools-encryption-ml-1739759946"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone introducing this component.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/encryption.ml#L133)
