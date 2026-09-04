# `src/minisql/common/diagnostics.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common diagnostics facilities for this project.

Package: [`minisql.common.diagnostics`](Package-minisql-common-diagnostics-1140477375.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `std/time.ml` as `time_api` → `../MiniLangCompilerML/std/time.ml` — external dependency

## Declarations

<a id="function-function-minisql-common-diagnostics-appendaudit-function-appendaudit-log-eventtype-outcome-sessionid-principalid-detail-src-minisql-common-diagnostics-ml-393758031"></a>
### appendAudit

```ml
function appendAudit(log, eventType, outcome, sessionId, principalId, detail)
```

Appends the audit. Inputs: `log`, `eventType`, `outcome`, `sessionId`, `principalId`, `detail`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `eventType` | `dynamic` | — | eventType value consumed by this operation. |
| `outcome` | `dynamic` | — | outcome value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |
| `detail` | `dynamic` | — | detail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L429)

<a id="constant-constant-minisql-common-diagnostics-audit-backup-const-audit-backup-6-src-minisql-common-diagnostics-ml-196936567"></a>
### AUDIT_BACKUP

```ml
const AUDIT_BACKUP = 6
```

Defines the audit backup constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L47)

<a id="constant-constant-minisql-common-diagnostics-audit-dcl-const-audit-dcl-4-src-minisql-common-diagnostics-ml-1324809039"></a>
### AUDIT_DCL

```ml
const AUDIT_DCL = 4
```

Defines the audit dcl constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L43)

<a id="constant-constant-minisql-common-diagnostics-audit-ddl-const-audit-ddl-3-src-minisql-common-diagnostics-ml-528523178"></a>
### AUDIT_DDL

```ml
const AUDIT_DDL = 3
```

Defines the audit ddl constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L41)

<a id="constant-constant-minisql-common-diagnostics-audit-failure-const-audit-failure-0-src-minisql-common-diagnostics-ml-1243090743"></a>
### AUDIT_FAILURE

```ml
const AUDIT_FAILURE = 0
```

Defines the audit failure constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L58)

<a id="constant-constant-minisql-common-diagnostics-audit-hash-bytes-const-audit-hash-bytes-32-src-minisql-common-diagnostics-ml-62102258"></a>
### AUDIT_HASH_BYTES

```ml
const AUDIT_HASH_BYTES = 32
```

Defines the audit hash bytes constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L28)

<a id="constant-constant-minisql-common-diagnostics-audit-header-bytes-const-audit-header-bytes-120-src-minisql-common-diagnostics-ml-1782569486"></a>
### AUDIT_HEADER_BYTES

```ml
const AUDIT_HEADER_BYTES = 120
```

Defines the audit header bytes constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L26)

<a id="constant-constant-minisql-common-diagnostics-audit-key-bytes-const-audit-key-bytes-32-src-minisql-common-diagnostics-ml-1368745564"></a>
### AUDIT_KEY_BYTES

```ml
const AUDIT_KEY_BYTES = 32
```

Defines the audit key bytes constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L30)

<a id="constant-constant-minisql-common-diagnostics-audit-login-const-audit-login-1-src-minisql-common-diagnostics-ml-1637545180"></a>
### AUDIT_LOGIN

```ml
const AUDIT_LOGIN = 1
```

Defines the audit login constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L37)

<a id="constant-constant-minisql-common-diagnostics-audit-logout-const-audit-logout-2-src-minisql-common-diagnostics-ml-1651967103"></a>
### AUDIT_LOGOUT

```ml
const AUDIT_LOGOUT = 2
```

Defines the audit logout constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L39)

<a id="constant-constant-minisql-common-diagnostics-audit-maintenance-const-audit-maintenance-5-src-minisql-common-diagnostics-ml-1383667268"></a>
### AUDIT_MAINTENANCE

```ml
const AUDIT_MAINTENANCE = 5
```

Defines the audit maintenance constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L45)

<a id="constant-constant-minisql-common-diagnostics-audit-replication-const-audit-replication-8-src-minisql-common-diagnostics-ml-857835475"></a>
### AUDIT_REPLICATION

```ml
const AUDIT_REPLICATION = 8
```

Defines the audit replication constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L51)

<a id="constant-constant-minisql-common-diagnostics-audit-restore-const-audit-restore-7-src-minisql-common-diagnostics-ml-2039548658"></a>
### AUDIT_RESTORE

```ml
const AUDIT_RESTORE = 7
```

Defines the audit restore constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L49)

<a id="constant-constant-minisql-common-diagnostics-audit-rotation-const-audit-rotation-10-src-minisql-common-diagnostics-ml-797657186"></a>
### AUDIT_ROTATION

```ml
const AUDIT_ROTATION = 10
```

Defines the audit rotation constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L55)

<a id="constant-constant-minisql-common-diagnostics-audit-server-const-audit-server-9-src-minisql-common-diagnostics-ml-483364804"></a>
### AUDIT_SERVER

```ml
const AUDIT_SERVER = 9
```

Defines the audit server constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L53)

<a id="constant-constant-minisql-common-diagnostics-audit-success-const-audit-success-1-src-minisql-common-diagnostics-ml-1383530348"></a>
### AUDIT_SUCCESS

```ml
const AUDIT_SUCCESS = 1
```

Defines the audit success constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L60)

<a id="constant-constant-minisql-common-diagnostics-audit-version-const-audit-version-1-src-minisql-common-diagnostics-ml-1172021252"></a>
### AUDIT_VERSION

```ml
const AUDIT_VERSION = 1
```

Defines the audit version constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L24)

<a id="function-function-minisql-common-diagnostics-auditanchorpath-function-auditanchorpath-databasepath-src-minisql-common-diagnostics-ml-1501408774"></a>
### auditAnchorPath

```ml
function auditAnchorPath(databasePath)
```

Performs the audit anchor path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L336)

<a id="function-function-minisql-common-diagnostics-auditkeypath-function-auditkeypath-databasepath-src-minisql-common-diagnostics-ml-259746520"></a>
### auditKeyPath

```ml
function auditKeyPath(databasePath)
```

Performs the audit key path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L329)

- [minisql.common.diagnostics.AuditLog](Type-minisql-common-diagnostics-auditlog-1714992896.md) — struct
<a id="function-function-minisql-common-diagnostics-auditmagic-function-auditmagic-src-minisql-common-diagnostics-ml-482445402"></a>
### auditMagic

```ml
function auditMagic()
```

Performs the audit magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L120)

<a id="function-function-minisql-common-diagnostics-auditpreviousanchorpath-function-auditpreviousanchorpath-databasepath-src-minisql-common-diagnostics-ml-2015371928"></a>
### auditPreviousAnchorPath

```ml
function auditPreviousAnchorPath(databasePath)
```

Performs the audit previous anchor path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L350)

<a id="function-function-minisql-common-diagnostics-auditpreviouspath-function-auditpreviouspath-databasepath-src-minisql-common-diagnostics-ml-1755878582"></a>
### auditPreviousPath

```ml
function auditPreviousPath(databasePath)
```

Performs the audit previous path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L343)

- [minisql.common.diagnostics.AuditScan](Type-minisql-common-diagnostics-auditscan-1907606559.md) — struct
<a id="function-function-minisql-common-diagnostics-bytesequal-function-bytesequal-left-right-src-minisql-common-diagnostics-ml-2066835579"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql common diagnostics module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L134)

<a id="function-function-minisql-common-diagnostics-closeaudit-function-closeaudit-log-src-minisql-common-diagnostics-ml-1839841366"></a>
### closeAudit

```ml
function closeAudit(log)
```

Closes the audit. Inputs: `log`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L534)

<a id="constant-constant-minisql-common-diagnostics-closed-handle-const-closed-handle-9008-src-minisql-common-diagnostics-ml-879152640"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L21)

<a id="function-function-minisql-common-diagnostics-componentname-function-componentname-src-minisql-common-diagnostics-ml-969279770"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common diagnostics module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L547)

<a id="function-function-minisql-common-diagnostics-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-common-diagnostics-ml-1340720025"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Performs the copyExact operation for the minisql common diagnostics module. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L152)

<a id="constant-constant-minisql-common-diagnostics-corrupt-data-const-corrupt-data-9004-src-minisql-common-diagnostics-ml-1472857870"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L17)

- [minisql.common.diagnostics.Diagnostic](Type-minisql-common-diagnostics-diagnostic-811054624.md) — struct
<a id="function-function-minisql-common-diagnostics-encodeauditrecord-function-encodeauditrecord-key-sequence-timestamp-eventtype-outcome-sessionid-principalid-previoushash-detail-src-minisql-common-diagnostics-ml-839972068"></a>
### encodeAuditRecord

```ml
function encodeAuditRecord(key, sequence, timestamp, eventType, outcome, sessionId, principalId, previousHash, detail)
```

Encodes the audit record. Inputs: `key`, `sequence`, `timestamp`, `eventType`, `outcome`, `sessionId`, `principalId`, `previousHash`, `detail`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `sequence` | `dynamic` | — | sequence value consumed by this operation. |
| `timestamp` | `dynamic` | — | timestamp value consumed by this operation. |
| `eventType` | `dynamic` | — | eventType value consumed by this operation. |
| `outcome` | `dynamic` | — | outcome value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |
| `previousHash` | `dynamic` | — | previousHash value consumed by this operation. |
| `detail` | `dynamic` | — | detail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L224)

<a id="function-function-minisql-common-diagnostics-ensureauditkey-function-ensureauditkey-databasepath-src-minisql-common-diagnostics-ml-1533154420"></a>
### ensureAuditKey

```ml
function ensureAuditKey(databasePath)
```

Ensures the audit key. Inputs: `databasePath`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L368)

<a id="function-function-minisql-common-diagnostics-ensuredirectory-function-ensuredirectory-path-src-minisql-common-diagnostics-ml-1140432225"></a>
### ensureDirectory

```ml
function ensureDirectory(path)
```

Ensures the directory. Inputs: `path`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L321)

<a id="function-function-minisql-common-diagnostics-fail-function-fail-code-operation-message-src-minisql-common-diagnostics-ml-1222395605"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql common diagnostics module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L114)

<a id="constant-constant-minisql-common-diagnostics-invalid-argument-const-invalid-argument-9001-src-minisql-common-diagnostics-ml-257022827"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Tamper-evident diagnostics and audit-log storage. Each record incorporates


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L15)

<a id="constant-constant-minisql-common-diagnostics-io-failure-const-io-failure-9005-src-minisql-common-diagnostics-ml-77718811"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L19)

<a id="function-function-minisql-common-diagnostics-isimplemented-function-isimplemented-src-minisql-common-diagnostics-ml-432634882"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common diagnostics module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L559)

<a id="function-function-minisql-common-diagnostics-make-function-make-code-severity-message-src-minisql-common-diagnostics-ml-1350124143"></a>
### make

```ml
function make(code, severity, message)
```

Constructs the requested value. Inputs: `code`, `severity`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `severity` | `dynamic` | — | severity value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L105)

<a id="constant-constant-minisql-common-diagnostics-max-audit-detail-bytes-const-max-audit-detail-bytes-4096-src-minisql-common-diagnostics-ml-326174688"></a>
### MAX_AUDIT_DETAIL_BYTES

```ml
const MAX_AUDIT_DETAIL_BYTES = 4096
```

Defines the max audit detail bytes constant used by the minisql common diagnostics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L32)

<a id="constant-constant-minisql-common-diagnostics-max-audit-file-bytes-const-max-audit-file-bytes-4294967295-src-minisql-common-diagnostics-ml-417467654"></a>
### MAX_AUDIT_FILE_BYTES

```ml
const MAX_AUDIT_FILE_BYTES = 4294967295
```

Audit v1 snapshots are processed through one U32-sized byte buffer. Keep the


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L34)

<a id="function-function-minisql-common-diagnostics-openaudit-function-openaudit-databasepath-src-minisql-common-diagnostics-ml-1127493678"></a>
### openAudit

```ml
function openAudit(databasePath)
```

Opens the audit. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L386)

<a id="function-function-minisql-common-diagnostics-readauditkey-function-readauditkey-databasepath-src-minisql-common-diagnostics-ml-1103731928"></a>
### readAuditKey

```ml
function readAuditKey(databasePath)
```

Reads the audit key. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L357)

<a id="function-function-minisql-common-diagnostics-readwhole-function-readwhole-path-maximum-src-minisql-common-diagnostics-ml-725544275"></a>
### readWhole

```ml
function readWhole(path, maximum)
```

Reads whole for the minisql common diagnostics workflow. Inputs: `path`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L161)

<a id="function-function-minisql-common-diagnostics-recorddigest-function-recorddigest-key-header-detailbytes-src-minisql-common-diagnostics-ml-668851924"></a>
### recordDigest

```ml
function recordDigest(key, header, detailBytes)
```

Performs the record digest operation for this module. Inputs: `key`, `header`, `detailBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `header` | `dynamic` | — | header value consumed by this operation. |
| `detailBytes` | `dynamic` | — | detailBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L203)

<a id="function-function-minisql-common-diagnostics-rotateaudit-function-rotateaudit-log-databasepath-sessionid-principalid-src-minisql-common-diagnostics-ml-489282528"></a>
### rotateAudit

```ml
function rotateAudit(log, databasePath, sessionId, principalId)
```

Performs the rotate audit operation for this module. Inputs: `log`, `databasePath`, `sessionId`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L486)

<a id="function-function-minisql-common-diagnostics-scanauditbytes-function-scanauditbytes-source-key-expectedprevioushash-allowtorntail-src-minisql-common-diagnostics-ml-879285385"></a>
### scanAuditBytes

```ml
function scanAuditBytes(source, key, expectedPreviousHash, allowTornTail)
```

Scans the audit bytes. Inputs: `source`, `key`, `expectedPreviousHash`, `allowTornTail`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `expectedPreviousHash` | `dynamic` | — | expectedPreviousHash value consumed by this operation. |
| `allowTornTail` | `dynamic` | — | allowTornTail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L314)

<a id="function-function-minisql-common-diagnostics-scanauditbytesfromsequence-function-scanauditbytesfromsequence-source-key-expectedprevioushash-expectedprevioussequence-allowtorntail-src-minisql-common-diagnostics-ml-280036069"></a>
### scanAuditBytesFromSequence

```ml
function scanAuditBytesFromSequence(source, key, expectedPreviousHash, expectedPreviousSequence, allowTornTail)
```

Scans the audit bytes from sequence. Inputs: `source`, `key`, `expectedPreviousHash`, `expectedPreviousSequence`, `allowTornTail`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `expectedPreviousHash` | `dynamic` | — | expectedPreviousHash value consumed by this operation. |
| `expectedPreviousSequence` | `dynamic` | — | expectedPreviousSequence value consumed by this operation. |
| `allowTornTail` | `dynamic` | — | allowTornTail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L260)

<a id="function-function-minisql-common-diagnostics-snapshotauditbytes-function-snapshotauditbytes-log-maximum-src-minisql-common-diagnostics-ml-592378366"></a>
### snapshotAuditBytes

```ml
function snapshotAuditBytes(log, maximum)
```

Performs the snapshot audit bytes operation for this module. Inputs: `log`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L512)

<a id="function-function-minisql-common-diagnostics-snapshotauditkey-function-snapshotauditkey-log-src-minisql-common-diagnostics-ml-1892794714"></a>
### snapshotAuditKey

```ml
function snapshotAuditKey(log)
```

Performs the snapshot audit key operation for this module. Inputs: `log`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L526)

<a id="function-function-minisql-common-diagnostics-targetmilestone-function-targetmilestone-src-minisql-common-diagnostics-ml-900211436"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql common diagnostics module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L553)

<a id="function-function-minisql-common-diagnostics-validateauditopen-function-validateauditopen-log-operation-src-minisql-common-diagnostics-ml-1633996677"></a>
### validateAuditOpen

```ml
function validateAuditOpen(log, operation)
```

Validates the audit open. Inputs: `log`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L415)

<a id="function-function-minisql-common-diagnostics-validatedetail-function-validatedetail-detail-operation-src-minisql-common-diagnostics-ml-1221848562"></a>
### validateDetail

```ml
function validateDetail(detail, operation)
```

Validates the detail. Inputs: `detail`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `detail` | `dynamic` | — | detail value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L188)

<a id="function-function-minisql-common-diagnostics-verifyaudit-function-verifyaudit-databasepath-src-minisql-common-diagnostics-ml-543372824"></a>
### verifyAudit

```ml
function verifyAudit(databasePath)
```

Verifies the audit. Inputs: `databasePath`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L452)

<a id="function-function-minisql-common-diagnostics-writewholedurable-function-writewholedurable-path-data-src-minisql-common-diagnostics-ml-923831429"></a>
### writeWholeDurable

```ml
function writeWholeDurable(path, data)
```

Writes the whole durable. Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L176)

<a id="function-function-minisql-common-diagnostics-zerohash-function-zerohash-src-minisql-common-diagnostics-ml-2130281410"></a>
### zeroHash

```ml
function zeroHash()
```

Performs the zero hash operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/diagnostics.ml#L126)
