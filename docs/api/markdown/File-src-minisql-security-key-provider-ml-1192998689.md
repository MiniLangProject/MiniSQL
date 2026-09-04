# `src/minisql/security/key_provider.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql security key provider facilities for this project.

Package: [`minisql.security.key_provider`](Package-minisql-security-key-provider-68798141.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency

## Declarations

<a id="constant-constant-minisql-security-key-provider-authentication-failed-const-authentication-failed-9027-src-minisql-security-key-provider-ml-1443358425"></a>
### AUTHENTICATION_FAILED

```ml
const AUTHENTICATION_FAILED = 9027
```

Defines the authentication failed constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L23)

<a id="function-function-minisql-security-key-provider-closedatabasekey-function-closedatabasekey-material-src-minisql-security-key-provider-ml-1970086051"></a>
### closeDatabaseKey

```ml
function closeDatabaseKey(material)
```

Wipes caller-owned database key material.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `material` | `dynamic` | — | material value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L264)

<a id="function-function-minisql-security-key-provider-componentname-function-componentname-src-minisql-security-key-provider-ml-12534030"></a>
### componentName

```ml
function componentName()
```

Returns the stable component name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L271)

<a id="constant-constant-minisql-security-key-provider-corrupt-data-const-corrupt-data-9004-src-minisql-security-key-provider-ml-1207612374"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L19)

<a id="function-function-minisql-security-key-provider-createenvelope-function-createenvelope-databaseroot-databaseid-provider-src-minisql-security-key-provider-ml-644730942"></a>
### createEnvelope

```ml
function createEnvelope(databaseRoot, databaseId, provider)
```

Creates and wraps a fresh random database encryption key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `provider` | `dynamic` | — | provider value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L239)

- [minisql.security.key_provider.DatabaseKey](Type-minisql-security-key-provider-databasekey-773503171.md) — struct
<a id="function-function-minisql-security-key-provider-decodeenvelope-function-decodeenvelope-databaseroot-src-minisql-security-key-provider-ml-1453545695"></a>
### decodeEnvelope

```ml
function decodeEnvelope(databaseRoot)
```

Reads, validates and unwraps the database's current DEK envelope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L197)

<a id="function-function-minisql-security-key-provider-decodeenvelopedata-function-decodeenvelopedata-databaseroot-encoded-provideroverride-src-minisql-security-key-provider-ml-253098964"></a>
### decodeEnvelopeData

```ml
function decodeEnvelopeData(databaseRoot, encoded, providerOverride)
```

Validates and unwraps one serialized DEK envelope. A provider override lets portable backup restore use identical key bytes from a new machine-local path while the original provider identity remains part of authenticated AAD.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |
| `providerOverride` | `dynamic` | — | providerOverride value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L166)

<a id="function-function-minisql-security-key-provider-encodeenvelope-function-encodeenvelope-databaseid-provider-databasekey-src-minisql-security-key-provider-ml-584272431"></a>
### encodeEnvelope

```ml
function encodeEnvelope(databaseId, provider, databaseKey)
```

Wraps a DEK and serializes authenticated crypto-agile metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `provider` | `dynamic` | — | provider value consumed by this operation. |
| `databaseKey` | `dynamic` | — | databaseKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L129)

<a id="function-function-minisql-security-key-provider-envelopeaad-function-envelopeaad-databaseid-providerkind-provideridentifier-src-minisql-security-key-provider-ml-1609495739"></a>
### envelopeAad

```ml
function envelopeAad(databaseId, providerKind, providerIdentifier)
```

Creates domain-separated AAD for one DEK envelope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `providerKind` | `dynamic` | — | providerKind value consumed by this operation. |
| `providerIdentifier` | `dynamic` | — | providerIdentifier value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L121)

<a id="function-function-minisql-security-key-provider-fail-function-fail-code-operation-message-src-minisql-security-key-provider-ml-513296235"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured key-provider error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L60)

<a id="function-function-minisql-security-key-provider-fileprovider-function-fileprovider-path-src-minisql-security-key-provider-ml-897183909"></a>
### fileProvider

```ml
function fileProvider(path)
```

Creates the version-1 raw-file key provider descriptor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L101)

<a id="function-function-minisql-security-key-provider-finddatabaseroot-function-finddatabaseroot-path-src-minisql-security-key-provider-ml-1430569593"></a>
### findDatabaseRoot

```ml
function findDatabaseRoot(path)
```

Searches a small bounded ancestor chain so catalog, table, index, WAL and temporary paths all resolve the database-level key envelope consistently. Finds the nearest ancestor containing an encryption envelope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L89)

<a id="constant-constant-minisql-security-key-provider-invalid-argument-const-invalid-argument-9001-src-minisql-security-key-provider-ml-2135897153"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

The envelope is deliberately provider- and algorithm-tagged. Adding an OS


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L15)

<a id="constant-constant-minisql-security-key-provider-io-failure-const-io-failure-9005-src-minisql-security-key-provider-ml-2044654185"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L21)

<a id="function-function-minisql-security-key-provider-isimplemented-function-isimplemented-src-minisql-security-key-provider-ml-719277566"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L281)

- [minisql.security.key_provider.KeyProvider](Type-minisql-security-key-provider-keyprovider-1507077469.md) — struct
<a id="function-function-minisql-security-key-provider-loadforpath-function-loadforpath-path-expecteddatabaseid-src-minisql-security-key-provider-ml-2028851009"></a>
### loadForPath

```ml
function loadForPath(path, expectedDatabaseId)
```

Resolves and loads the database key associated with an artifact path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `expectedDatabaseId` | `dynamic` | — | Identifier of expected database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L206)

<a id="function-function-minisql-security-key-provider-loadproviderkey-function-loadproviderkey-provider-src-minisql-security-key-provider-ml-225745395"></a>
### loadProviderKey

```ml
function loadProviderKey(provider)
```

Loads one wipeable 256-bit KEK from the selected provider.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `provider` | `dynamic` | — | provider value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L108)

<a id="constant-constant-minisql-security-key-provider-meta-fixed-bytes-const-meta-fixed-bytes-112-src-minisql-security-key-provider-ml-683627179"></a>
### META_FIXED_BYTES

```ml
const META_FIXED_BYTES = 112
```

Defines the meta fixed bytes constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L32)

<a id="constant-constant-minisql-security-key-provider-meta-max-bytes-const-meta-max-bytes-8192-src-minisql-security-key-provider-ml-1724343917"></a>
### META_MAX_BYTES

```ml
const META_MAX_BYTES = 8192
```

Defines the meta max bytes constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L34)

<a id="constant-constant-minisql-security-key-provider-meta-version-const-meta-version-1-src-minisql-security-key-provider-ml-760014362"></a>
### META_VERSION

```ml
const META_VERSION = 1
```

Defines the meta version constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L30)

<a id="function-function-minisql-security-key-provider-metadatapath-function-metadatapath-databaseroot-src-minisql-security-key-provider-ml-226782359"></a>
### metadataPath

```ml
function metadataPath(databaseRoot)
```

Returns the fixed database envelope path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L81)

<a id="function-function-minisql-security-key-provider-parentpath-function-parentpath-path-src-minisql-security-key-provider-ml-1449840053"></a>
### parentPath

```ml
function parentPath(path)
```

Returns the UTF-8 parent path without filesystem-dependent normalization.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L66)

<a id="constant-constant-minisql-security-key-provider-provider-file-const-provider-file-1-src-minisql-security-key-provider-ml-85160500"></a>
### PROVIDER_FILE

```ml
const PROVIDER_FILE = 1
```

Defines the provider file constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L26)

<a id="function-function-minisql-security-key-provider-rotateenvelope-function-rotateenvelope-databaseroot-newprovider-src-minisql-security-key-provider-ml-1439446792"></a>
### rotateEnvelope

```ml
function rotateEnvelope(databaseRoot, newProvider)
```

Rotation rewraps the DEK atomically; data pages never become half-keyed and no full database rewrite is required. The old key remains usable until the final metadata rename, which is the online cut-over point. Atomically rewraps the existing DEK with a new provider key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |
| `newProvider` | `dynamic` | — | newProvider value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L254)

<a id="function-function-minisql-security-key-provider-targetmilestone-function-targetmilestone-src-minisql-security-key-provider-ml-1159704256"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone introducing this component.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L276)

<a id="constant-constant-minisql-security-key-provider-unsupported-format-const-unsupported-format-9003-src-minisql-security-key-provider-ml-1885905179"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L17)

<a id="constant-constant-minisql-security-key-provider-wrap-aes-256-gcm-const-wrap-aes-256-gcm-1-src-minisql-security-key-provider-ml-109791258"></a>
### WRAP_AES_256_GCM

```ml
const WRAP_AES_256_GCM = 1
```

Defines the wrap aes 256 gcm constant used by the minisql security key provider module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L28)

<a id="function-function-minisql-security-key-provider-writeenvelope-function-writeenvelope-databaseroot-databaseid-provider-databasekey-src-minisql-security-key-provider-ml-770187142"></a>
### writeEnvelope

```ml
function writeEnvelope(databaseRoot, databaseId, provider, databaseKey)
```

Atomically publishes a durable wrapped-key envelope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseRoot` | `dynamic` | — | databaseRoot value consumed by this operation. |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `provider` | `dynamic` | — | provider value consumed by this operation. |
| `databaseKey` | `dynamic` | — | databaseKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L220)
