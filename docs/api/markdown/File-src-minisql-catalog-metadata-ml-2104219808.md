# `src/minisql/catalog/metadata.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.catalog.metadata`](Package-minisql-catalog-metadata-1092943414.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)

## Declarations

<a id="constant-constant-minisql-catalog-metadata-catalog-format-version-const-catalog-format-version-1-src-minisql-catalog-metadata-ml-1989377858"></a>
### CATALOG_FORMAT_VERSION

```ml
const CATALOG_FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L18)

<a id="constant-constant-minisql-catalog-metadata-catalog-kind-const-catalog-kind-2-src-minisql-catalog-metadata-ml-407196559"></a>
### CATALOG_KIND

```ml
const CATALOG_KIND = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L20)

<a id="function-function-minisql-catalog-metadata-catalogmagic-function-catalogmagic-src-minisql-catalog-metadata-ml-1777944932"></a>
### catalogMagic

```ml
function catalogMagic()
```

Performs the catalog magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L122)

- [minisql.catalog.metadata.CatalogState](Type-minisql-catalog-metadata-catalogstate-859167128.md) — struct
- [minisql.catalog.metadata.ColumnMetadata](Type-minisql-catalog-metadata-columnmetadata-1108114983.md) — struct
<a id="function-function-minisql-catalog-metadata-componentname-function-componentname-src-minisql-catalog-metadata-ml-744808076"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L790)

<a id="function-function-minisql-catalog-metadata-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-catalog-metadata-ml-269281601"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Copies the exact. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L128)

<a id="constant-constant-minisql-catalog-metadata-corrupt-data-const-corrupt-data-9004-src-minisql-catalog-metadata-ml-401580248"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L15)

<a id="function-function-minisql-catalog-metadata-createcatalog-function-createcatalog-databaseid-nextobjectid-src-minisql-catalog-metadata-ml-1619316875"></a>
### createCatalog

```ml
function createCatalog(databaseId, nextObjectId)
```

Creates the catalog. Inputs: `databaseId`, `nextObjectId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |
| `nextObjectId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L268)

<a id="function-function-minisql-catalog-metadata-createcolumn-function-createcolumn-columnid-name-typecode-nullable-maxlength-precision-scale-src-minisql-catalog-metadata-ml-547273112"></a>
### createColumn

```ml
function createColumn(columnId, name, typeCode, nullable, maxLength, precision, scale)
```

Creates the column. Inputs: `columnId`, `name`, `typeCode`, `nullable`, `maxLength`, `precision`, `scale`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `typeCode` | `dynamic` | — |  |
| `nullable` | `dynamic` | — |  |
| `maxLength` | `dynamic` | — |  |
| `precision` | `dynamic` | — |  |
| `scale` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L241)

<a id="function-function-minisql-catalog-metadata-createdatabase-function-createdatabase-name-databaseid-pagesize-walsegmentbytes-databaseformatversion-tablefileformatversion-indexfileformatversion-walformatversion-rowformatversion-src-minisql-catalog-metadata-ml-1330469217"></a>
### createDatabase

```ml
function createDatabase(name, databaseId, pageSize, walSegmentBytes, databaseFormatVersion, tableFileFormatVersion, indexFileFormatVersion, walFormatVersion, rowFormatVersion)
```

Creates the database. Inputs: `name`, `databaseId`, `pageSize`, `walSegmentBytes`, `databaseFormatVersion`, `tableFileFormatVersion`, `indexFileFormatVersion`, `walFormatVersion`, `rowFormatVersion`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `walSegmentBytes` | `dynamic` | — |  |
| `databaseFormatVersion` | `dynamic` | — |  |
| `tableFileFormatVersion` | `dynamic` | — |  |
| `indexFileFormatVersion` | `dynamic` | — |  |
| `walFormatVersion` | `dynamic` | — |  |
| `rowFormatVersion` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L163)

<a id="function-function-minisql-catalog-metadata-createprincipal-function-createprincipal-principalid-name-principalkind-enabled-canlogin-superuser-builtin-salt-iterations-verifier-src-minisql-catalog-metadata-ml-719134777"></a>
### createPrincipal

```ml
function createPrincipal(principalId, name, principalKind, enabled, canLogin, superuser, builtin, salt, iterations, verifier)
```

Creates the principal. Inputs: `principalId`, `name`, `principalKind`, `enabled`, `canLogin`, `superuser`, `builtin`, `salt`, `iterations`, `verifier`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `principalId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `principalKind` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |
| `canLogin` | `dynamic` | — |  |
| `superuser` | `dynamic` | — |  |
| `builtin` | `dynamic` | — |  |
| `salt` | `dynamic` | — |  |
| `iterations` | `dynamic` | — |  |
| `verifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L539)

<a id="function-function-minisql-catalog-metadata-createprivilegegrant-function-createprivilegegrant-granteeid-grantorid-objecttype-objectid-privilege-grantoption-src-minisql-catalog-metadata-ml-29425238"></a>
### createPrivilegeGrant

```ml
function createPrivilegeGrant(granteeId, grantorId, objectType, objectId, privilege, grantOption)
```

Creates the privilege grant. Inputs: `granteeId`, `grantorId`, `objectType`, `objectId`, `privilege`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `granteeId` | `dynamic` | — |  |
| `grantorId` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `grantOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L596)

<a id="function-function-minisql-catalog-metadata-createrolemembership-function-createrolemembership-roleid-memberid-grantorid-adminoption-src-minisql-catalog-metadata-ml-613764946"></a>
### createRoleMembership

```ml
function createRoleMembership(roleId, memberId, grantorId, adminOption)
```

Creates the role membership. Inputs: `roleId`, `memberId`, `grantorId`, `adminOption`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `roleId` | `dynamic` | — |  |
| `memberId` | `dynamic` | — |  |
| `grantorId` | `dynamic` | — |  |
| `adminOption` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L567)

<a id="function-function-minisql-catalog-metadata-createsecurity-function-createsecurity-databaseid-src-minisql-catalog-metadata-ml-1807895268"></a>
### createSecurity

```ml
function createSecurity(databaseId)
```

Creates the security. Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L609)

<a id="function-function-minisql-catalog-metadata-createtable-function-createtable-tableid-name-schemaversion-columns-src-minisql-catalog-metadata-ml-171398742"></a>
### createTable

```ml
function createTable(tableId, name, schemaVersion, columns)
```

Creates the table. Inputs: `tableId`, `name`, `schemaVersion`, `columns`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `schemaVersion` | `dynamic` | — |  |
| `columns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L255)

<a id="constant-constant-minisql-catalog-metadata-database-format-version-const-database-format-version-1-src-minisql-catalog-metadata-ml-278093756"></a>
### DATABASE_FORMAT_VERSION

```ml
const DATABASE_FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L17)

<a id="constant-constant-minisql-catalog-metadata-database-kind-const-database-kind-1-src-minisql-catalog-metadata-ml-1469795556"></a>
### DATABASE_KIND

```ml
const DATABASE_KIND = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L19)

<a id="function-function-minisql-catalog-metadata-databasemagic-function-databasemagic-src-minisql-catalog-metadata-ml-744548052"></a>
### databaseMagic

```ml
function databaseMagic()
```

Performs the database magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L116)

- [minisql.catalog.metadata.DatabaseMetadata](Type-minisql-catalog-metadata-databasemetadata-982737264.md) — struct
<a id="function-function-minisql-catalog-metadata-decodecatalog-function-decodecatalog-encoded-src-minisql-catalog-metadata-ml-2032227764"></a>
### decodeCatalog

```ml
function decodeCatalog(encoded)
```

Decodes the catalog. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L342)

<a id="function-function-minisql-catalog-metadata-decodedatabase-function-decodedatabase-encoded-src-minisql-catalog-metadata-ml-1083821150"></a>
### decodeDatabase

```ml
function decodeDatabase(encoded)
```

Decodes the database. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L214)

<a id="function-function-minisql-catalog-metadata-decodenative-function-decodenative-words-operation-name-src-minisql-catalog-metadata-ml-1213217795"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes the native. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L207)

<a id="function-function-minisql-catalog-metadata-decodesecurity-function-decodesecurity-encoded-src-minisql-catalog-metadata-ml-2035380910"></a>
### decodeSecurity

```ml
function decodeSecurity(encoded)
```

Decodes the security. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L705)

<a id="function-function-minisql-catalog-metadata-encodecatalog-function-encodecatalog-catalog-src-minisql-catalog-metadata-ml-200282927"></a>
### encodeCatalog

```ml
function encodeCatalog(catalog)
```

Encodes the catalog. Inputs: `catalog`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `catalog` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L286)

<a id="function-function-minisql-catalog-metadata-encodedatabase-function-encodedatabase-value-src-minisql-catalog-metadata-ml-1676417943"></a>
### encodeDatabase

```ml
function encodeDatabase(value)
```

Encodes the database. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L176)

<a id="function-function-minisql-catalog-metadata-encodedtablesize-function-encodedtablesize-table-src-minisql-catalog-metadata-ml-1579679928"></a>
### encodedTableSize

```ml
function encodedTableSize(table)
```

Encodes the d table size. Inputs: `table`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L276)

<a id="function-function-minisql-catalog-metadata-encodesecurity-function-encodesecurity-state-src-minisql-catalog-metadata-ml-108350591"></a>
### encodeSecurity

```ml
function encodeSecurity(state)
```

Encodes the security. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L624)

<a id="function-function-minisql-catalog-metadata-fail-function-fail-code-operation-message-src-minisql-catalog-metadata-ml-942437783"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L110)

<a id="constant-constant-minisql-catalog-metadata-invalid-argument-const-invalid-argument-9001-src-minisql-catalog-metadata-ml-1794613597"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Versioned catalog metadata codecs. Decoders validate kind, version, bounds, and checksum envelopes before constructing in-memory database, table, or authorization records.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L13)

<a id="function-function-minisql-catalog-metadata-iscatalogstate-function-iscatalogstate-value-src-minisql-catalog-metadata-ml-432863031"></a>
### isCatalogState

```ml
function isCatalogState(value)
```

Evaluates whether the supplied input satisfies the catalog state predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L98)

<a id="function-function-minisql-catalog-metadata-iscolumnmetadata-function-iscolumnmetadata-value-src-minisql-catalog-metadata-ml-2011794655"></a>
### isColumnMetadata

```ml
function isColumnMetadata(value)
```

Evaluates whether the supplied input satisfies the column metadata predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L104)

<a id="function-function-minisql-catalog-metadata-isimplemented-function-isimplemented-src-minisql-catalog-metadata-ml-793295028"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L802)

<a id="function-function-minisql-catalog-metadata-isprincipalmetadata-function-isprincipalmetadata-value-src-minisql-catalog-metadata-ml-395950837"></a>
### isPrincipalMetadata

```ml
function isPrincipalMetadata(value)
```

Evaluates whether the supplied input satisfies the principal metadata predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L500)

<a id="function-function-minisql-catalog-metadata-isprivilegegrant-function-isprivilegegrant-value-src-minisql-catalog-metadata-ml-381527227"></a>
### isPrivilegeGrant

```ml
function isPrivilegeGrant(value)
```

Evaluates whether the supplied input satisfies the privilege grant predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L512)

<a id="function-function-minisql-catalog-metadata-isrolemembership-function-isrolemembership-value-src-minisql-catalog-metadata-ml-1991883659"></a>
### isRoleMembership

```ml
function isRoleMembership(value)
```

Evaluates whether the supplied input satisfies the role membership predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L506)

<a id="function-function-minisql-catalog-metadata-issecuritystate-function-issecuritystate-value-src-minisql-catalog-metadata-ml-1278516393"></a>
### isSecurityState

```ml
function isSecurityState(value)
```

Evaluates whether the supplied input satisfies the security state predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L518)

<a id="function-function-minisql-catalog-metadata-istablemetadata-function-istablemetadata-value-src-minisql-catalog-metadata-ml-180201009"></a>
### isTableMetadata

```ml
function isTableMetadata(value)
```

Evaluates whether the supplied input satisfies the table metadata predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L92)

<a id="constant-constant-minisql-catalog-metadata-membership-bytes-const-membership-bytes-32-src-minisql-catalog-metadata-ml-1676643668"></a>
### MEMBERSHIP_BYTES

```ml
const MEMBERSHIP_BYTES = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L418)

<a id="constant-constant-minisql-catalog-metadata-object-database-const-object-database-1-src-minisql-catalog-metadata-ml-972562504"></a>
### OBJECT_DATABASE

```ml
const OBJECT_DATABASE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L400)

<a id="constant-constant-minisql-catalog-metadata-object-table-const-object-table-2-src-minisql-catalog-metadata-ml-270961631"></a>
### OBJECT_TABLE

```ml
const OBJECT_TABLE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L401)

<a id="constant-constant-minisql-catalog-metadata-principal-admin-id-const-principal-admin-id-1-src-minisql-catalog-metadata-ml-572958034"></a>
### PRINCIPAL_ADMIN_ID

```ml
const PRINCIPAL_ADMIN_ID = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L397)

<a id="constant-constant-minisql-catalog-metadata-principal-header-bytes-const-principal-header-bytes-24-src-minisql-catalog-metadata-ml-1598207063"></a>
### PRINCIPAL_HEADER_BYTES

```ml
const PRINCIPAL_HEADER_BYTES = 24
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L417)

<a id="constant-constant-minisql-catalog-metadata-principal-public-id-const-principal-public-id-2-src-minisql-catalog-metadata-ml-627966197"></a>
### PRINCIPAL_PUBLIC_ID

```ml
const PRINCIPAL_PUBLIC_ID = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L398)

<a id="constant-constant-minisql-catalog-metadata-principal-role-const-principal-role-2-src-minisql-catalog-metadata-ml-504593165"></a>
### PRINCIPAL_ROLE

```ml
const PRINCIPAL_ROLE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L396)

<a id="constant-constant-minisql-catalog-metadata-principal-user-const-principal-user-1-src-minisql-catalog-metadata-ml-1166974974"></a>
### PRINCIPAL_USER

```ml
const PRINCIPAL_USER = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L395)

<a id="function-function-minisql-catalog-metadata-principalencodedsize-function-principalencodedsize-principal-src-minisql-catalog-metadata-ml-1437467230"></a>
### principalEncodedSize

```ml
function principalEncodedSize(principal)
```

Performs the principal encoded size operation for this module. Inputs: `principal`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `principal` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L618)

- [minisql.catalog.metadata.PrincipalMetadata](Type-minisql-catalog-metadata-principalmetadata-1691173151.md) — struct
<a id="constant-constant-minisql-catalog-metadata-privilege-admin-const-privilege-admin-4-src-minisql-catalog-metadata-ml-1071156723"></a>
### PRIVILEGE_ADMIN

```ml
const PRIVILEGE_ADMIN = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L406)

<a id="constant-constant-minisql-catalog-metadata-privilege-alter-const-privilege-alter-16-src-minisql-catalog-metadata-ml-1230377320"></a>
### PRIVILEGE_ALTER

```ml
const PRIVILEGE_ALTER = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L413)

<a id="constant-constant-minisql-catalog-metadata-privilege-connect-const-privilege-connect-1-src-minisql-catalog-metadata-ml-596488064"></a>
### PRIVILEGE_CONNECT

```ml
const PRIVILEGE_CONNECT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L403)

<a id="constant-constant-minisql-catalog-metadata-privilege-create-const-privilege-create-2-src-minisql-catalog-metadata-ml-346611787"></a>
### PRIVILEGE_CREATE

```ml
const PRIVILEGE_CREATE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L404)

<a id="constant-constant-minisql-catalog-metadata-privilege-delete-const-privilege-delete-13-src-minisql-catalog-metadata-ml-1426713823"></a>
### PRIVILEGE_DELETE

```ml
const PRIVILEGE_DELETE = 13
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L410)

<a id="constant-constant-minisql-catalog-metadata-privilege-drop-const-privilege-drop-17-src-minisql-catalog-metadata-ml-1625824287"></a>
### PRIVILEGE_DROP

```ml
const PRIVILEGE_DROP = 17
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L414)

<a id="constant-constant-minisql-catalog-metadata-privilege-grant-bytes-const-privilege-grant-bytes-40-src-minisql-catalog-metadata-ml-666941591"></a>
### PRIVILEGE_GRANT_BYTES

```ml
const PRIVILEGE_GRANT_BYTES = 40
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L419)

<a id="constant-constant-minisql-catalog-metadata-privilege-index-const-privilege-index-15-src-minisql-catalog-metadata-ml-1752643405"></a>
### PRIVILEGE_INDEX

```ml
const PRIVILEGE_INDEX = 15
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L412)

<a id="constant-constant-minisql-catalog-metadata-privilege-insert-const-privilege-insert-11-src-minisql-catalog-metadata-ml-1211999113"></a>
### PRIVILEGE_INSERT

```ml
const PRIVILEGE_INSERT = 11
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L408)

<a id="constant-constant-minisql-catalog-metadata-privilege-maintain-const-privilege-maintain-3-src-minisql-catalog-metadata-ml-996348006"></a>
### PRIVILEGE_MAINTAIN

```ml
const PRIVILEGE_MAINTAIN = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L405)

<a id="constant-constant-minisql-catalog-metadata-privilege-owner-const-privilege-owner-18-src-minisql-catalog-metadata-ml-1623454086"></a>
### PRIVILEGE_OWNER

```ml
const PRIVILEGE_OWNER = 18
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L415)

<a id="constant-constant-minisql-catalog-metadata-privilege-references-const-privilege-references-14-src-minisql-catalog-metadata-ml-119502128"></a>
### PRIVILEGE_REFERENCES

```ml
const PRIVILEGE_REFERENCES = 14
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L411)

<a id="constant-constant-minisql-catalog-metadata-privilege-select-const-privilege-select-10-src-minisql-catalog-metadata-ml-1793953028"></a>
### PRIVILEGE_SELECT

```ml
const PRIVILEGE_SELECT = 10
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L407)

<a id="constant-constant-minisql-catalog-metadata-privilege-update-const-privilege-update-12-src-minisql-catalog-metadata-ml-1691325448"></a>
### PRIVILEGE_UPDATE

```ml
const PRIVILEGE_UPDATE = 12
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L409)

- [minisql.catalog.metadata.PrivilegeGrant](Type-minisql-catalog-metadata-privilegegrant-539883459.md) — struct
<a id="function-function-minisql-catalog-metadata-requirerange-function-requirerange-payload-offset-count-operation-src-minisql-catalog-metadata-ml-1176764591"></a>
### requireRange

```ml
function requireRange(payload, offset, count, operation)
```

Performs the require range operation for this module. Inputs: `payload`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L333)

- [minisql.catalog.metadata.RoleMembership](Type-minisql-catalog-metadata-rolemembership-247159248.md) — struct
<a id="constant-constant-minisql-catalog-metadata-security-extended-counts-flag-const-security-extended-counts-flag-1-src-minisql-catalog-metadata-ml-376133828"></a>
### SECURITY_EXTENDED_COUNTS_FLAG

```ml
const SECURITY_EXTENDED_COUNTS_FLAG = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L422)

<a id="constant-constant-minisql-catalog-metadata-security-format-version-const-security-format-version-1-src-minisql-catalog-metadata-ml-1103571876"></a>
### SECURITY_FORMAT_VERSION

```ml
const SECURITY_FORMAT_VERSION = 1
```

M21 security catalog. The sidecar is a CRC-protected, self-identifying snapshot. catalog.catalog stores two alternating generations so a torn DCL write can always fall back to the previous durable state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L392)

<a id="constant-constant-minisql-catalog-metadata-security-header-bytes-const-security-header-bytes-48-src-minisql-catalog-metadata-ml-364671191"></a>
### SECURITY_HEADER_BYTES

```ml
const SECURITY_HEADER_BYTES = 48
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L421)

<a id="constant-constant-minisql-catalog-metadata-security-kind-const-security-kind-70-src-minisql-catalog-metadata-ml-248554276"></a>
### SECURITY_KIND

```ml
const SECURITY_KIND = 70
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L393)

<a id="constant-constant-minisql-catalog-metadata-security-legacy-header-bytes-const-security-legacy-header-bytes-40-src-minisql-catalog-metadata-ml-1687848729"></a>
### SECURITY_LEGACY_HEADER_BYTES

```ml
const SECURITY_LEGACY_HEADER_BYTES = 40
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L420)

<a id="function-function-minisql-catalog-metadata-securitymagic-function-securitymagic-src-minisql-catalog-metadata-ml-440814434"></a>
### securityMagic

```ml
function securityMagic()
```

Performs the security magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L494)

- [minisql.catalog.metadata.SecurityState](Type-minisql-catalog-metadata-securitystate-575353923.md) — struct
- [minisql.catalog.metadata.TableMetadata](Type-minisql-catalog-metadata-tablemetadata-1410088233.md) — struct
<a id="function-function-minisql-catalog-metadata-targetmilestone-function-targetmilestone-src-minisql-catalog-metadata-ml-1503604794"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L796)

<a id="constant-constant-minisql-catalog-metadata-unsupported-format-const-unsupported-format-9003-src-minisql-catalog-metadata-ml-1456727271"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L14)

<a id="function-function-minisql-catalog-metadata-validatedatabaseid-function-validatedatabaseid-value-operation-src-minisql-catalog-metadata-ml-119144518"></a>
### validateDatabaseId

```ml
function validateDatabaseId(value, operation)
```

Validates the database id. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L156)

<a id="function-function-minisql-catalog-metadata-validateid-function-validateid-value-operation-name-src-minisql-catalog-metadata-ml-1849710967"></a>
### validateId

```ml
function validateId(value, operation, name)
```

Validates the id. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L138)

<a id="function-function-minisql-catalog-metadata-validatename-function-validatename-value-operation-name-src-minisql-catalog-metadata-ml-1613074843"></a>
### validateName

```ml
function validateName(value, operation, name)
```

Validates the name. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L147)

<a id="function-function-minisql-catalog-metadata-validatesecurityname-function-validatesecurityname-value-operation-src-minisql-catalog-metadata-ml-880736414"></a>
### validateSecurityName

```ml
function validateSecurityName(value, operation)
```

Validates the security name. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L524)

<a id="function-function-minisql-catalog-metadata-validobjecttype-function-validobjecttype-value-src-minisql-catalog-metadata-ml-426449761"></a>
### validObjectType

```ml
function validObjectType(value)
```

Performs the valid object type operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L578)

<a id="function-function-minisql-catalog-metadata-validprivilege-function-validprivilege-objecttype-privilege-src-minisql-catalog-metadata-ml-821741098"></a>
### validPrivilege

```ml
function validPrivilege(objectType, privilege)
```

Performs the valid privilege operation for this module. Inputs: `objectType`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectType` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/metadata.ml#L584)
