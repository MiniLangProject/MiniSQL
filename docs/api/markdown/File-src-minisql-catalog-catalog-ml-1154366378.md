# `src/minisql/catalog/catalog.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.catalog.catalog`](Package-minisql-catalog-catalog-89200582.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/logger.ml` as `logger` → [src/minisql/common/logger.ml](File-src-minisql-common-logger-ml-1571638233.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/config/model.ml` as `config_model` → [src/minisql/config/model.ml](File-src-minisql-config-model-ml-1120384851.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)
- `minisql/transaction/checkpoint.ml` as `checkpoint` → [src/minisql/transaction/checkpoint.ml](File-src-minisql-transaction-checkpoint-ml-1306482346.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency

## Declarations

<a id="function-function-minisql-catalog-catalog-allocateprincipalidinstate-function-allocateprincipalidinstate-state-src-minisql-catalog-catalog-ml-309874723"></a>
### allocatePrincipalIdInState

```ml
function allocatePrincipalIdInState(state)
```

Allocates the principal id in state. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L905)

<a id="function-function-minisql-catalog-catalog-allocatetransactionid-function-allocatetransactionid-database-src-minisql-catalog-catalog-ml-268903699"></a>
### allocateTransactionId

```ml
function allocateTransactionId(database)
```

Allocates the transaction id. Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L589)

<a id="function-function-minisql-catalog-catalog-authenticatepassword-function-authenticatepassword-database-name-password-src-minisql-catalog-catalog-ml-1492471785"></a>
### authenticatePassword

```ml
function authenticatePassword(database, name, password)
```

Performs the authenticate password operation for this module. Inputs: `database`, `name`, `password`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1324)

<a id="function-function-minisql-catalog-catalog-authenticationmaterial-function-authenticationmaterial-database-name-src-minisql-catalog-catalog-ml-1028851272"></a>
### authenticationMaterial

```ml
function authenticationMaterial(database, name)
```

Performs the authentication material operation for this module. Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1315)

<a id="constant-constant-minisql-catalog-catalog-blob-data-offset-const-blob-data-offset-68-src-minisql-catalog-catalog-ml-1405052427"></a>
### BLOB_DATA_OFFSET

```ml
const BLOB_DATA_OFFSET = 68
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L35)

<a id="constant-constant-minisql-catalog-catalog-blob-length-offset-const-blob-length-offset-64-src-minisql-catalog-catalog-ml-276672675"></a>
### BLOB_LENGTH_OFFSET

```ml
const BLOB_LENGTH_OFFSET = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L34)

<a id="function-function-minisql-catalog-catalog-bytesequal-function-bytesequal-left-right-src-minisql-catalog-catalog-ml-1818125623"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L154)

<a id="constant-constant-minisql-catalog-catalog-catalog-file-id-const-catalog-file-id-2-src-minisql-catalog-catalog-ml-1652712017"></a>
### CATALOG_FILE_ID

```ml
const CATALOG_FILE_ID = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L31)

<a id="function-function-minisql-catalog-catalog-clonemembership-function-clonemembership-membership-src-minisql-catalog-catalog-ml-1786313516"></a>
### cloneMembership

```ml
function cloneMembership(membership)
```

Clones the membership. Inputs: `membership`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `membership` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L834)

<a id="function-function-minisql-catalog-catalog-cloneprincipal-function-cloneprincipal-principal-src-minisql-catalog-catalog-ml-797884452"></a>
### clonePrincipal

```ml
function clonePrincipal(principal)
```

Clones the principal. Inputs: `principal`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `principal` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L828)

<a id="function-function-minisql-catalog-catalog-cloneprivilegegrant-function-cloneprivilegegrant-grant-src-minisql-catalog-catalog-ml-1781501516"></a>
### clonePrivilegeGrant

```ml
function clonePrivilegeGrant(grant)
```

Clones the privilege grant. Inputs: `grant`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `grant` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L840)

<a id="function-function-minisql-catalog-catalog-clonesecuritystate-function-clonesecuritystate-state-src-minisql-catalog-catalog-ml-674542219"></a>
### cloneSecurityState

```ml
function cloneSecurityState(state)
```

Clones the security state. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L846)

<a id="function-function-minisql-catalog-catalog-close-function-close-database-src-minisql-catalog-catalog-ml-1440119815"></a>
### close

```ml
function close(database)
```

Closes the requested value. Inputs: `database`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L600)

<a id="constant-constant-minisql-catalog-catalog-closed-handle-const-closed-handle-9008-src-minisql-catalog-catalog-ml-1470377644"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L25)

<a id="function-function-minisql-catalog-catalog-commitsecuritystate-function-commitsecuritystate-database-candidate-src-minisql-catalog-catalog-ml-638512560"></a>
### commitSecurityState

```ml
function commitSecurityState(database, candidate)
```

Commits the security state. Inputs: `database`, `candidate`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `candidate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L873)

<a id="function-function-minisql-catalog-catalog-componentname-function-componentname-src-minisql-catalog-catalog-ml-1922269542"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1332)

<a id="function-function-minisql-catalog-catalog-containsid-function-containsid-values-wanted-src-minisql-catalog-catalog-ml-1817231719"></a>
### containsId

```ml
function containsId(values, wanted)
```

Performs the contains id operation for this module. Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L665)

<a id="function-function-minisql-catalog-catalog-containsprivilegecode-function-containsprivilegecode-values-wanted-src-minisql-catalog-catalog-ml-1485162013"></a>
### containsPrivilegeCode

```ml
function containsPrivilegeCode(values, wanted)
```

Performs the contains privilege code operation for this module. Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1179)

<a id="constant-constant-minisql-catalog-catalog-corrupt-data-const-corrupt-data-9004-src-minisql-catalog-catalog-ml-1130671570"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L24)

<a id="function-function-minisql-catalog-catalog-createdatabase-function-createdatabase-dataroot-name-defaults-src-minisql-catalog-catalog-ml-1827667035"></a>
### createDatabase

```ml
function createDatabase(dataRoot, name, defaults)
```

Creates the database. Inputs: `dataRoot`, `name`, `defaults`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dataRoot` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `defaults` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L313)

<a id="function-function-minisql-catalog-catalog-createpagedblobpage-function-createpagedblobpage-pagedfile-pagenumber-encoded-pagecount-src-minisql-catalog-catalog-ml-1034663317"></a>
### createPagedBlobPage

```ml
function createPagedBlobPage(pagedFile, pageNumber, encoded, pageCount)
```

Builds one independently checksummed page of the scalable catalog blob. Each page repeats the global length and page count so swapped, stale, missing, or reordered continuation pages are detected before decoding metadata. Inputs: `pagedFile`, `pageNumber`, `encoded`, `pageCount`. Returns one sealed page image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |
| `pageCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L218)

<a id="function-function-minisql-catalog-catalog-createrole-function-createrole-database-name-src-minisql-catalog-catalog-ml-832594304"></a>
### createRole

```ml
function createRole(database, name)
```

Creates the role. Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L937)

<a id="function-function-minisql-catalog-catalog-createsecuritygeneration-function-createsecuritygeneration-databasepath-slot-pagesize-databaseid-encoded-src-minisql-catalog-catalog-ml-870743968"></a>
### createSecurityGeneration

```ml
function createSecurityGeneration(databasePath, slot, pageSize, databaseId, encoded)
```

Creates one complete scalable security generation under its final path. Inputs: `databasePath`, `slot`, `pageSize`, `databaseId`, `encoded`. Returns a closed durable file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `slot` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L118)

<a id="function-function-minisql-catalog-catalog-createtable-function-createtable-database-name-definitions-src-minisql-catalog-catalog-ml-676023834"></a>
### createTable

```ml
function createTable(database, name, definitions)
```

Creates the table. Inputs: `database`, `name`, `definitions`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `definitions` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L539)

<a id="function-function-minisql-catalog-catalog-createuser-function-createuser-database-name-password-src-minisql-catalog-catalog-ml-2069260361"></a>
### createUser

```ml
function createUser(database, name, password)
```

Creates the user. Inputs: `database`, `name`, `password`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L914)

<a id="constant-constant-minisql-catalog-catalog-database-meta-file-id-const-database-meta-file-id-1-src-minisql-catalog-catalog-ml-1927861942"></a>
### DATABASE_META_FILE_ID

```ml
const DATABASE_META_FILE_ID = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L30)

- [minisql.catalog.catalog.DatabaseHandle](Type-minisql-catalog-catalog-databasehandle-705083507.md) — struct
<a id="function-function-minisql-catalog-catalog-decodeblobnative-function-decodeblobnative-words-operation-name-src-minisql-catalog-catalog-ml-20339179"></a>
### decodeBlobNative

```ml
function decodeBlobNative(words, operation, name)
```

Converts a persisted unsigned 64-bit blob field to the native MiniLang range. Inputs: `words`, `operation`, `name`. Returns the native value or a corruption error when the file requests an unaddressable allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L194)

<a id="function-function-minisql-catalog-catalog-definecolumn-function-definecolumn-name-typecode-nullable-maxlength-precision-scale-src-minisql-catalog-catalog-ml-1202201127"></a>
### defineColumn

```ml
function defineColumn(name, typeCode, nullable, maxLength, precision, scale)
```

Performs the define column operation for this module. Inputs: `name`, `typeCode`, `nullable`, `maxLength`, `precision`, `scale`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `typeCode` | `dynamic` | — |  |
| `nullable` | `dynamic` | — |  |
| `maxLength` | `dynamic` | — |  |
| `precision` | `dynamic` | — |  |
| `scale` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L533)

<a id="function-function-minisql-catalog-catalog-dropprincipal-function-dropprincipal-database-name-expectedkind-ifexists-src-minisql-catalog-catalog-ml-1612898319"></a>
### dropPrincipal

```ml
function dropPrincipal(database, name, expectedKind, ifExists)
```

Drops the principal. Inputs: `database`, `name`, `expectedKind`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `expectedKind` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1012)

<a id="function-function-minisql-catalog-catalog-effectiveprincipalids-function-effectiveprincipalids-database-principalid-src-minisql-catalog-catalog-ml-1294831144"></a>
### effectivePrincipalIds

```ml
function effectivePrincipalIds(database, principalId)
```

Performs the effective principal ids operation for this module. Inputs: `database`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1137)

<a id="function-function-minisql-catalog-catalog-effectiveprincipalidsinstate-function-effectiveprincipalidsinstate-state-principalid-src-minisql-catalog-catalog-ml-1263850698"></a>
### effectivePrincipalIdsInState

```ml
function effectivePrincipalIdsInState(state, principalId)
```

Performs the effective principal ids in state operation for this module. Inputs: `state`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L674)

<a id="function-function-minisql-catalog-catalog-ensurelayout-function-ensurelayout-root-src-minisql-catalog-catalog-ml-1078060774"></a>
### ensureLayout

```ml
function ensureLayout(root)
```

Ensures the layout. Inputs: `root`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L301)

<a id="function-function-minisql-catalog-catalog-fail-function-fail-code-operation-message-src-minisql-catalog-catalog-ml-25063503"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L73)

<a id="function-function-minisql-catalog-catalog-findprincipal-function-findprincipal-database-name-src-minisql-catalog-catalog-ml-571440230"></a>
### findPrincipal

```ml
function findPrincipal(database, name)
```

Finds the principal. Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L637)

<a id="function-function-minisql-catalog-catalog-findprincipalbyidinstate-function-findprincipalbyidinstate-state-principalid-src-minisql-catalog-catalog-ml-1010707874"></a>
### findPrincipalByIdInState

```ml
function findPrincipalByIdInState(state, principalId)
```

Finds the principal by id in state. Inputs: `state`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L617)

<a id="function-function-minisql-catalog-catalog-findprincipalbynameinstate-function-findprincipalbynameinstate-state-name-src-minisql-catalog-catalog-ml-1172597600"></a>
### findPrincipalByNameInState

```ml
function findPrincipalByNameInState(state, name)
```

Finds the principal by name in state. Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L627)

<a id="function-function-minisql-catalog-catalog-findtable-function-findtable-database-name-src-minisql-catalog-catalog-ml-523071566"></a>
### findTable

```ml
function findTable(database, name)
```

Finds the table. Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L512)

<a id="function-function-minisql-catalog-catalog-findtablebyid-function-findtablebyid-database-tableid-src-minisql-catalog-catalog-ml-1373544926"></a>
### findTableById

```ml
function findTableById(database, tableId)
```

Finds the table by id. Inputs: `database`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L522)

<a id="function-function-minisql-catalog-catalog-grantprivilege-function-grantprivilege-database-granteename-grantorid-objecttype-objectid-privilege-grantoption-src-minisql-catalog-catalog-ml-396670595"></a>
### grantPrivilege

```ml
function grantPrivilege(database, granteeName, grantorId, objectType, objectId, privilege, grantOption)
```

Performs the grant privilege operation for this module. Inputs: `database`, `granteeName`, `grantorId`, `objectType`, `objectId`, `privilege`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `granteeName` | `dynamic` | — |  |
| `grantorId` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `grantOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1212)

<a id="function-function-minisql-catalog-catalog-grantprivileges-function-grantprivileges-database-granteename-grantorid-objecttype-objectid-privileges-grantoption-src-minisql-catalog-catalog-ml-717144436"></a>
### grantPrivileges

```ml
function grantPrivileges(database, granteeName, grantorId, objectType, objectId, privileges, grantOption)
```

Performs the grant privileges operation for this module. Inputs: `database`, `granteeName`, `grantorId`, `objectType`, `objectId`, `privileges`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `granteeName` | `dynamic` | — |  |
| `grantorId` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privileges` | `dynamic` | — |  |
| `grantOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1188)

<a id="function-function-minisql-catalog-catalog-grantrole-function-grantrole-database-rolename-membername-grantorid-adminoption-src-minisql-catalog-catalog-ml-1732729593"></a>
### grantRole

```ml
function grantRole(database, roleName, memberName, grantorId, adminOption)
```

Performs the grant role operation for this module. Inputs: `database`, `roleName`, `memberName`, `grantorId`, `adminOption`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `roleName` | `dynamic` | — |  |
| `memberName` | `dynamic` | — |  |
| `grantorId` | `dynamic` | — |  |
| `adminOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1055)

<a id="function-function-minisql-catalog-catalog-granttableowner-function-granttableowner-database-tableid-principalid-src-minisql-catalog-catalog-ml-1216259925"></a>
### grantTableOwner

```ml
function grantTableOwner(database, tableId, principalId)
```

Performs the grant table owner operation for this module. Inputs: `database`, `tableId`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1289)

<a id="function-function-minisql-catalog-catalog-hasprivilege-function-hasprivilege-database-principalid-objecttype-objectid-privilege-requiregrantoption-src-minisql-catalog-catalog-ml-65049684"></a>
### hasPrivilege

```ml
function hasPrivilege(database, principalId, objectType, objectId, privilege, requireGrantOption)
```

Evaluates whether the supplied input satisfies the privilege predicate. Inputs: `database`, `principalId`, `objectType`, `objectId`, `privilege`, `requireGrantOption`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `requireGrantOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1163)

<a id="function-function-minisql-catalog-catalog-hasroleadminoption-function-hasroleadminoption-database-principalid-roleid-src-minisql-catalog-catalog-ml-102860479"></a>
### hasRoleAdminOption

```ml
function hasRoleAdminOption(database, principalId, roleId)
```

Evaluates whether the supplied input satisfies the role admin option predicate. Inputs: `database`, `principalId`, `roleId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |
| `roleId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1152)

<a id="constant-constant-minisql-catalog-catalog-invalid-argument-const-invalid-argument-9001-src-minisql-catalog-catalog-ml-2114565549"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Database catalog lifecycle and durable bootstrap layout. Opening a database validates all format identities before exposing handles; creation publishes fully initialized metadata, WAL, and checkpoint state as one logical unit.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L23)

<a id="function-function-minisql-catalog-catalog-isdatabasehandle-function-isdatabasehandle-value-src-minisql-catalog-catalog-ml-593361695"></a>
### isDatabaseHandle

```ml
function isDatabaseHandle(value)
```

Evaluates whether the supplied input satisfies the database handle predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L67)

<a id="function-function-minisql-catalog-catalog-isimplemented-function-isimplemented-src-minisql-catalog-catalog-ml-1361844558"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1344)

<a id="function-function-minisql-catalog-catalog-issuperuser-function-issuperuser-database-principalid-src-minisql-catalog-catalog-ml-329736306"></a>
### isSuperuser

```ml
function isSuperuser(database, principalId)
```

Evaluates whether the supplied input satisfies the superuser predicate. Inputs: `database`, `principalId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1144)

<a id="function-function-minisql-catalog-catalog-joinpath-function-joinpath-left-right-src-minisql-catalog-catalog-ml-298339947"></a>
### joinPath

```ml
function joinPath(left, right)
```

Performs the join path operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L79)

<a id="function-function-minisql-catalog-catalog-loadsecuritystate-function-loadsecuritystate-securityfiles-databaseid-src-minisql-catalog-catalog-ml-1373162197"></a>
### loadSecurityState

```ml
function loadSecurityState(securityFiles, databaseId)
```

Loads the newest valid scalable security generation and retains the older snapshot as a fallback after a torn or checksummed write failure. Inputs: `securityFiles`, `databaseId`. Returns the selected security state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `securityFiles` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L809)

<a id="constant-constant-minisql-catalog-catalog-object-exists-const-object-exists-9013-src-minisql-catalog-catalog-ml-448333668"></a>
### OBJECT_EXISTS

```ml
const OBJECT_EXISTS = 9013
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L26)

<a id="constant-constant-minisql-catalog-catalog-object-not-found-const-object-not-found-9014-src-minisql-catalog-catalog-ml-787398161"></a>
### OBJECT_NOT_FOUND

```ml
const OBJECT_NOT_FOUND = 9014
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L27)

<a id="function-function-minisql-catalog-catalog-opendatabase-function-opendatabase-path-src-minisql-catalog-catalog-ml-650288485"></a>
### openDatabase

```ml
function openDatabase(path)
```

Opens the database. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L415)

<a id="function-function-minisql-catalog-catalog-opensecuritygenerationfiles-function-opensecuritygenerationfiles-databasepath-legacyfile-pagesize-databaseid-src-minisql-catalog-catalog-ml-402780269"></a>
### openSecurityGenerationFiles

```ml
function openSecurityGenerationFiles(databasePath, legacyFile, pageSize, databaseId)
```

Opens or migrates the two independently durable scalable security snapshots. The marker distinguishes a legacy database from a damaged v2 database: after publication, either missing generation is corruption rather than a downgrade. Inputs: `databasePath`, `legacyFile`, `pageSize`, `databaseId`. Returns two open paged files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `legacyFile` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L779)

<a id="constant-constant-minisql-catalog-catalog-paged-blob-data-offset-const-paged-blob-data-offset-104-src-minisql-catalog-catalog-ml-471463972"></a>
### PAGED_BLOB_DATA_OFFSET

```ml
const PAGED_BLOB_DATA_OFFSET = 104
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L39)

<a id="constant-constant-minisql-catalog-catalog-paged-blob-header-offset-const-paged-blob-header-offset-64-src-minisql-catalog-catalog-ml-1973308325"></a>
### PAGED_BLOB_HEADER_OFFSET

```ml
const PAGED_BLOB_HEADER_OFFSET = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L38)

<a id="constant-constant-minisql-catalog-catalog-paged-blob-magic-const-paged-blob-magic-843205698-src-minisql-catalog-catalog-ml-148564608"></a>
### PAGED_BLOB_MAGIC

```ml
const PAGED_BLOB_MAGIC = 843205698
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L36)

<a id="constant-constant-minisql-catalog-catalog-paged-blob-version-const-paged-blob-version-1-src-minisql-catalog-catalog-ml-1430381340"></a>
### PAGED_BLOB_VERSION

```ml
const PAGED_BLOB_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L37)

<a id="function-function-minisql-catalog-catalog-pagedblobpagecount-function-pagedblobpagecount-length-capacity-src-minisql-catalog-catalog-ml-390177782"></a>
### pagedBlobPageCount

```ml
function pagedBlobPageCount(length, capacity)
```

Computes the number of catalog pages required by a byte payload without a fixed metadata ceiling. The persisted representation is limited only by the paged-file and native address ranges. Inputs: `length`, `capacity`. Returns a positive page count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `length` | `dynamic` | — |  |
| `capacity` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L203)

<a id="function-function-minisql-catalog-catalog-persistmetadata-function-persistmetadata-database-src-minisql-catalog-catalog-ml-1867807009"></a>
### persistMetadata

```ml
function persistMetadata(database)
```

Performs the persist metadata operation for this module. Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L502)

<a id="function-function-minisql-catalog-catalog-persistsecurity-function-persistsecurity-database-src-minisql-catalog-catalog-ml-304872899"></a>
### persistSecurity

```ml
function persistSecurity(database)
```

Performs the persist security operation for this module. Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L899)

<a id="function-function-minisql-catalog-catalog-privilegecascadegrantees-function-privilegecascadegrantees-state-rootgranteeid-objecttype-objectid-privilege-src-minisql-catalog-catalog-ml-620050812"></a>
### privilegeCascadeGrantees

```ml
function privilegeCascadeGrantees(state, rootGranteeId, objectType, objectId, privilege)
```

Performs the privilege cascade grantees operation for this module. Inputs: `state`, `rootGranteeId`, `objectType`, `objectId`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `rootGranteeId` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1223)

<a id="function-function-minisql-catalog-catalog-publishsecuritygenerationmarker-function-publishsecuritygenerationmarker-databasepath-src-minisql-catalog-catalog-ml-1862248942"></a>
### publishSecurityGenerationMarker

```ml
function publishSecurityGenerationMarker(databasePath)
```

Publishes the marker only after both scalable security generations are durable. Inputs: `databasePath`. Returns true after durable marker creation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L131)

<a id="function-function-minisql-catalog-catalog-readblobpage-function-readblobpage-pagedfile-pagenumber-src-minisql-catalog-catalog-ml-1398574303"></a>
### readBlobPage

```ml
function readBlobPage(pagedFile, pageNumber)
```

Reads the blob page. Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L183)

<a id="function-function-minisql-catalog-catalog-readpagedblob-function-readpagedblob-pagedfile-src-minisql-catalog-catalog-ml-1947852557"></a>
### readPagedBlob

```ml
function readPagedBlob(pagedFile)
```

Reads the scalable catalog snapshot and transparently accepts the original one-page layout. This makes the first metadata update an online format migration for existing databases. Inputs: `pagedFile`. Returns the exact encoded catalog payload.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L267)

<a id="function-function-minisql-catalog-catalog-removetableprivileges-function-removetableprivileges-database-tableid-src-minisql-catalog-catalog-ml-1827605700"></a>
### removeTablePrivileges

```ml
function removeTablePrivileges(database, tableId)
```

Removes the table privileges. Inputs: `database`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1298)

<a id="function-function-minisql-catalog-catalog-requireprincipal-function-requireprincipal-database-name-operation-src-minisql-catalog-catalog-ml-1585408905"></a>
### requirePrincipal

```ml
function requirePrincipal(database, name, operation)
```

Performs the require principal operation for this module. Inputs: `database`, `name`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L644)

<a id="function-function-minisql-catalog-catalog-revokeprivilege-function-revokeprivilege-database-granteename-objecttype-objectid-privilege-src-minisql-catalog-catalog-ml-558655616"></a>
### revokePrivilege

```ml
function revokePrivilege(database, granteeName, objectType, objectId, privilege)
```

Performs the revoke privilege operation for this module. Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `granteeName` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1283)

<a id="function-function-minisql-catalog-catalog-revokeprivileges-function-revokeprivileges-database-granteename-objecttype-objectid-privileges-src-minisql-catalog-catalog-ml-669725303"></a>
### revokePrivileges

```ml
function revokePrivileges(database, granteeName, objectType, objectId, privileges)
```

M21 compatibility entry point: RESTRICT is the safe default. Performs the revoke privileges operation for this module. Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privileges`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `granteeName` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privileges` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1277)

<a id="function-function-minisql-catalog-catalog-revokeprivilegeswithbehavior-function-revokeprivilegeswithbehavior-database-granteename-objecttype-objectid-privileges-cascade-src-minisql-catalog-catalog-ml-2123037275"></a>
### revokePrivilegesWithBehavior

```ml
function revokePrivilegesWithBehavior(database, granteeName, objectType, objectId, privileges, cascade)
```

Performs the revoke privileges with behavior operation for this module. Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privileges`, `cascade`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `granteeName` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privileges` | `dynamic` | — |  |
| `cascade` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1242)

<a id="function-function-minisql-catalog-catalog-revokerole-function-revokerole-database-rolename-membername-src-minisql-catalog-catalog-ml-941939029"></a>
### revokeRole

```ml
function revokeRole(database, roleName, memberName)
```

M21 compatibility entry point: RESTRICT is the safe default. Performs the revoke role operation for this module. Inputs: `database`, `roleName`, `memberName`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `roleName` | `dynamic` | — |  |
| `memberName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1131)

<a id="function-function-minisql-catalog-catalog-revokerolewithbehavior-function-revokerolewithbehavior-database-rolename-membername-cascade-src-minisql-catalog-catalog-ml-545483361"></a>
### revokeRoleWithBehavior

```ml
function revokeRoleWithBehavior(database, roleName, memberName, cascade)
```

Performs the revoke role with behavior operation for this module. Inputs: `database`, `roleName`, `memberName`, `cascade`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `roleName` | `dynamic` | — |  |
| `memberName` | `dynamic` | — |  |
| `cascade` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1104)

<a id="function-function-minisql-catalog-catalog-rolecascademembers-function-rolecascademembers-state-roleid-rootmemberid-src-minisql-catalog-catalog-ml-790293405"></a>
### roleCascadeMembers

```ml
function roleCascadeMembers(state, roleId, rootMemberId)
```

Performs the role cascade members operation for this module. Inputs: `state`, `roleId`, `rootMemberId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `roleId` | `dynamic` | — |  |
| `rootMemberId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1081)

<a id="function-function-minisql-catalog-catalog-rolewouldcycle-function-rolewouldcycle-state-roleid-memberid-src-minisql-catalog-catalog-ml-470033301"></a>
### roleWouldCycle

```ml
function roleWouldCycle(state, roleId, memberId)
```

Performs the role would cycle operation for this module. Inputs: `state`, `roleId`, `memberId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `roleId` | `dynamic` | — |  |
| `memberId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1046)

<a id="constant-constant-minisql-catalog-catalog-security-file-id-const-security-file-id-0-src-minisql-catalog-catalog-ml-1695136583"></a>
### SECURITY_FILE_ID

```ml
const SECURITY_FILE_ID = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L32)

<a id="constant-constant-minisql-catalog-catalog-security-generation-file-id-const-security-generation-file-id-0-src-minisql-catalog-catalog-ml-1441131395"></a>
### SECURITY_GENERATION_FILE_ID

```ml
const SECURITY_GENERATION_FILE_ID = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L33)

<a id="constant-constant-minisql-catalog-catalog-security-state-const-security-state-9030-src-minisql-catalog-catalog-ml-1881915543"></a>
### SECURITY_STATE

```ml
const SECURITY_STATE = 9030
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L28)

<a id="function-function-minisql-catalog-catalog-securityarrayslice-function-securityarrayslice-values-offset-count-src-minisql-catalog-catalog-ml-1040969070"></a>
### securityArraySlice

```ml
function securityArraySlice(values, offset, count)
```

Performs the security array slice operation for this module. Inputs: `values`, `offset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L652)

<a id="function-function-minisql-catalog-catalog-securityfilepath-function-securityfilepath-databasepath-src-minisql-catalog-catalog-ml-357173640"></a>
### securityFilePath

```ml
function securityFilePath(databasePath)
```

Performs the security file path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L99)

<a id="function-function-minisql-catalog-catalog-securitygenerationfilepath-function-securitygenerationfilepath-databasepath-slot-src-minisql-catalog-catalog-ml-214824500"></a>
### securityGenerationFilePath

```ml
function securityGenerationFilePath(databasePath, slot)
```

Returns the scalable security generation path for slot zero or one. Inputs: `databasePath`, `slot`. Returns a path inside the catalog directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `slot` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L105)

<a id="function-function-minisql-catalog-catalog-securitygenerationmarkerpath-function-securitygenerationmarkerpath-databasepath-src-minisql-catalog-catalog-ml-795124716"></a>
### securityGenerationMarkerPath

```ml
function securityGenerationMarkerPath(databasePath)
```

Returns the durable marker proving that scalable security generations were published. Inputs: `databasePath`. Returns a path inside the catalog directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L112)

<a id="function-function-minisql-catalog-catalog-setuserenabled-function-setuserenabled-database-name-enabled-src-minisql-catalog-catalog-ml-138587169"></a>
### setUserEnabled

```ml
function setUserEnabled(database, name, enabled)
```

Updates the user enabled. Inputs: `database`, `name`, `enabled`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L997)

<a id="function-function-minisql-catalog-catalog-setuserpassword-function-setuserpassword-database-name-password-src-minisql-catalog-catalog-ml-5123377"></a>
### setUserPassword

```ml
function setUserPassword(database, name, password)
```

Updates the user password. Inputs: `database`, `name`, `password`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L951)

<a id="function-function-minisql-catalog-catalog-setuserpasswordbytes-function-setuserpasswordbytes-database-name-passwordbytes-src-minisql-catalog-catalog-ml-999074184"></a>
### setUserPasswordBytes

```ml
function setUserPasswordBytes(database, name, passwordBytes)
```

Updates the user password bytes. Inputs: `database`, `name`, `passwordBytes`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L974)

<a id="function-function-minisql-catalog-catalog-tablefilename-function-tablefilename-tableid-src-minisql-catalog-catalog-ml-336406005"></a>
### tableFileName

```ml
function tableFileName(tableId)
```

Performs the table file name operation for this module. Inputs: `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L86)

<a id="function-function-minisql-catalog-catalog-tablefilepath-function-tablefilepath-databasepath-tableid-src-minisql-catalog-catalog-ml-689721395"></a>
### tableFilePath

```ml
function tableFilePath(databasePath, tableId)
```

Performs the table file path operation for this module. Inputs: `databasePath`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L93)

<a id="function-function-minisql-catalog-catalog-targetmilestone-function-targetmilestone-src-minisql-catalog-catalog-ml-1997716340"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L1338)

<a id="function-function-minisql-catalog-catalog-validatecatalogsemantics-function-validatecatalogsemantics-databasemetadata-catalogstate-src-minisql-catalog-catalog-ml-1155572186"></a>
### validateCatalogSemantics

```ml
function validateCatalogSemantics(databaseMetadata, catalogState)
```

Validates the catalog semantics. Inputs: `databaseMetadata`, `catalogState`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseMetadata` | `dynamic` | — |  |
| `catalogState` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L377)

<a id="function-function-minisql-catalog-catalog-validatename-function-validatename-name-operation-src-minisql-catalog-catalog-ml-366392894"></a>
### validateName

```ml
function validateName(name, operation)
```

Validates the name. Inputs: `name`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L142)

<a id="function-function-minisql-catalog-catalog-validateopen-function-validateopen-database-operation-src-minisql-catalog-catalog-ml-1145009964"></a>
### validateOpen

```ml
function validateOpen(database, operation)
```

Validates the open. Inputs: `database`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L494)

<a id="function-function-minisql-catalog-catalog-validatesecuritysemantics-function-validatesecuritysemantics-state-databaseid-tables-src-minisql-catalog-catalog-ml-681811532"></a>
### validateSecuritySemantics

```ml
function validateSecuritySemantics(state, databaseId, tables)
```

Validates the security semantics. Inputs: `state`, `databaseId`, `tables`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `tables` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L693)

<a id="function-function-minisql-catalog-catalog-validatesecuritywritable-function-validatesecuritywritable-database-operation-src-minisql-catalog-catalog-ml-1621227660"></a>
### validateSecurityWritable

```ml
function validateSecurityWritable(database, operation)
```

Validates the security writable. Inputs: `database`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L865)

<a id="function-function-minisql-catalog-catalog-validatetablefiles-function-validatetablefiles-path-databasemetadata-catalogstate-src-minisql-catalog-catalog-ml-464650505"></a>
### validateTableFiles

```ml
function validateTableFiles(path, databaseMetadata, catalogState)
```

Validates the table files. Inputs: `path`, `databaseMetadata`, `catalogState`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `databaseMetadata` | `dynamic` | — |  |
| `catalogState` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L401)

<a id="function-function-minisql-catalog-catalog-writeblobpage-function-writeblobpage-pagedfile-pagenumber-encoded-src-minisql-catalog-catalog-ml-1542913733"></a>
### writeBlobPage

```ml
function writeBlobPage(pagedFile, pageNumber, encoded)
```

Writes the blob page. Inputs: `pagedFile`, `pageNumber`, `encoded`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L165)

<a id="function-function-minisql-catalog-catalog-writepagedblob-function-writepagedblob-pagedfile-encoded-src-minisql-catalog-catalog-ml-543264341"></a>
### writePagedBlob

```ml
function writePagedBlob(pagedFile, encoded)
```

Persists an arbitrarily large catalog snapshot across as many pages as it needs. Continuations become durable before page zero publishes the new blob; stale tail pages are removed only after that publication is durable. Inputs: `pagedFile`, `encoded`. Returns true after a complete durable snapshot is published.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/catalog.ml#L242)
