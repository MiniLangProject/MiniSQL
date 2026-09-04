# `src/minisql/protocol/connection.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql protocol connection facilities for this project.

Package: [`minisql.protocol.connection`](Package-minisql-protocol-connection-498153730.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/network.ml` as `network` → [src/minisql/platform/network.ml](File-src-minisql-platform-network-ml-77221021.md)
- `minisql/platform/tls_schannel.ml` as `tls_schannel` → [src/minisql/platform/tls_schannel.ml](File-src-minisql-platform-tls-schannel-ml-61867785.md)
- `minisql/protocol/codec.ml` as `codec` → [src/minisql/protocol/codec.ml](File-src-minisql-protocol-codec-ml-66075884.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)

## Declarations

<a id="function-function-minisql-protocol-connection-abort-function-abort-connection-src-minisql-protocol-connection-ml-1501340348"></a>
### abort

```ml
function abort(connection)
```

Aborts a potentially desynchronized transport without sending TLS or protocol shutdown data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L505)

<a id="function-function-minisql-protocol-connection-appendreceivebytes-function-appendreceivebytes-connection-incoming-src-minisql-protocol-connection-ml-409761652"></a>
### appendReceiveBytes

```ml
function appendReceiveBytes(connection, incoming)
```

Appends plaintext obtained from Schannel while preserving the frame memory bound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `incoming` | `dynamic` | — | incoming value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L210)

<a id="function-function-minisql-protocol-connection-appendreceivescratch-function-appendreceivescratch-connection-count-src-minisql-protocol-connection-ml-22295363"></a>
### appendReceiveScratch

```ml
function appendReceiveScratch(connection, count)
```

Appends receive scratch using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L192)

<a id="function-function-minisql-protocol-connection-close-function-close-connection-src-minisql-protocol-connection-ml-371202104"></a>
### close

```ml
function close(connection)
```

Closes close owned by the minisql protocol connection module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L478)

<a id="constant-constant-minisql-protocol-connection-closed-handle-const-closed-handle-9008-src-minisql-protocol-connection-ml-463517886"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql protocol connection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L24)

<a id="function-function-minisql-protocol-connection-componentname-function-componentname-src-minisql-protocol-connection-ml-233166304"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql protocol connection module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L529)

<a id="function-function-minisql-protocol-connection-connectaddress-function-connectaddress-address-port-src-minisql-protocol-connection-ml-430820979"></a>
### connectAddress

```ml
function connectAddress(address, port)
```

Connects address using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L106)

- [minisql.protocol.connection.Connection](Type-minisql-protocol-connection-connection-344312244.md) — struct
<a id="function-function-minisql-protocol-connection-connectloopback-function-connectloopback-port-src-minisql-protocol-connection-ml-473957737"></a>
### connectLoopback

```ml
function connectLoopback(port)
```

Connects loopback using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | port value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L145)

<a id="function-function-minisql-protocol-connection-connecttlsaddress-function-connecttlsaddress-address-port-servername-src-minisql-protocol-connection-ml-362774277"></a>
### connectTlsAddress

```ml
function connectTlsAddress(address, port, serverName)
```

Connects a TCP socket and completes native TLS with Windows root-store trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L114)

<a id="function-function-minisql-protocol-connection-connecttlspinnedaddress-function-connecttlspinnedaddress-address-port-servername-pintext-src-minisql-protocol-connection-ml-1005533091"></a>
### connectTlsPinnedAddress

```ml
function connectTlsPinnedAddress(address, port, serverName, pinText)
```

Connects native TLS using an exact SHA-256 leaf pin for private certificates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L130)

<a id="function-function-minisql-protocol-connection-copyrange-function-copyrange-source-offset-count-operation-src-minisql-protocol-connection-ml-1748581154"></a>
### copyRange

```ml
function copyRange(source, offset, count, operation)
```

Implements copy range for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L179)

<a id="constant-constant-minisql-protocol-connection-corrupt-data-const-corrupt-data-9004-src-minisql-protocol-connection-ml-879765828"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql protocol connection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L26)

<a id="function-function-minisql-protocol-connection-create-function-create-sockethandle-src-minisql-protocol-connection-ml-1434457539"></a>
### create

```ml
function create(socketHandle)
```

Creates create for the minisql protocol connection module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L96)

<a id="function-function-minisql-protocol-connection-decodeinbound-function-decodeinbound-connection-frame-src-minisql-protocol-connection-ml-633926463"></a>
### decodeInbound

```ml
function decodeInbound(connection, frame)
```

Decodes inbound using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `frame` | `dynamic` | — | frame value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L358)

<a id="function-function-minisql-protocol-connection-enablesecure-function-enablesecure-connection-sendkey-receivekey-src-minisql-protocol-connection-ml-395214409"></a>
### enableSecure

```ml
function enableSecure(connection, sendKey, receiveKey)
```

Implements enable secure for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `sendKey` | `dynamic` | — | sendKey value consumed by this operation. |
| `receiveKey` | `dynamic` | — | receiveKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L258)

<a id="function-function-minisql-protocol-connection-enabletls-function-enabletls-connection-tlscontext-src-minisql-protocol-connection-ml-532141020"></a>
### enableTls

```ml
function enableTls(connection, tlsContext)
```

Attaches a completed Schannel context below the MiniSQL framed protocol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `tlsContext` | `dynamic` | — | tlsContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L273)

<a id="function-function-minisql-protocol-connection-extractbufferedmessage-function-extractbufferedmessage-connection-src-minisql-protocol-connection-ml-1657465084"></a>
### extractBufferedMessage

```ml
function extractBufferedMessage(connection)
```

Implements extract buffered message for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L227)

<a id="function-function-minisql-protocol-connection-fail-function-fail-code-operation-message-src-minisql-protocol-connection-ml-250590469"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql protocol connection module. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L80)

<a id="constant-constant-minisql-protocol-connection-invalid-argument-const-invalid-argument-9001-src-minisql-protocol-connection-ml-55962339"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql protocol connection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L22)

<a id="function-function-minisql-protocol-connection-isconnection-function-isconnection-value-src-minisql-protocol-connection-ml-398223009"></a>
### isConnection

```ml
function isConnection(value)
```

Returns whether the supplied value satisfies the connection condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L88)

<a id="function-function-minisql-protocol-connection-isimplemented-function-isimplemented-src-minisql-protocol-connection-ml-743716744"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql protocol connection module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L543)

<a id="function-function-minisql-protocol-connection-ispollresult-function-ispollresult-value-src-minisql-protocol-connection-ml-962966921"></a>
### isPollResult

```ml
function isPollResult(value)
```

Returns whether the supplied value satisfies the poll result condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L366)

<a id="function-function-minisql-protocol-connection-makenonblocking-function-makenonblocking-connection-src-minisql-protocol-connection-ml-122501172"></a>
### makeNonBlocking

```ml
function makeNonBlocking(connection)
```

Creates non blocking using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L374)

<a id="constant-constant-minisql-protocol-connection-poll-receive-bytes-const-poll-receive-bytes-65536-src-minisql-protocol-connection-ml-1375018834"></a>
### POLL_RECEIVE_BYTES

```ml
const POLL_RECEIVE_BYTES = 65536
```

Defines the poll receive bytes constant used by the minisql protocol connection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L30)

<a id="function-function-minisql-protocol-connection-pollmessage-function-pollmessage-connection-src-minisql-protocol-connection-ml-562205644"></a>
### pollMessage

```ml
function pollMessage(connection)
```

Attempts one nonblocking framed receive. Returns PollResult when a complete frame or clean EOF is available, void when more bytes are needed, or an error for malformed/truncated/transport input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L384)

- [minisql.protocol.connection.PollResult](Type-minisql-protocol-connection-pollresult-314322152.md) — struct
<a id="function-function-minisql-protocol-connection-protectmessage-function-protectmessage-connection-message-src-minisql-protocol-connection-ml-950709283"></a>
### protectMessage

```ml
function protectMessage(connection, message)
```

Implements protect message for this module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L303)

<a id="function-function-minisql-protocol-connection-protocolbytesreceived-function-protocolbytesreceived-connection-src-minisql-protocol-connection-ml-1019780388"></a>
### protocolBytesReceived

```ml
function protocolBytesReceived(connection)
```

Returns framed protocol bytes read by this connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L468)

<a id="function-function-minisql-protocol-connection-protocolbytessent-function-protocolbytessent-connection-src-minisql-protocol-connection-ml-1201636758"></a>
### protocolBytesSent

```ml
function protocolBytesSent(connection)
```

Returns framed protocol bytes written by this connection. TLS record overhead is deliberately excluded so plain and protected protocol workloads compare.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L461)

<a id="function-function-minisql-protocol-connection-receivemessage-function-receivemessage-connection-src-minisql-protocol-connection-ml-211292584"></a>
### receiveMessage

```ml
function receiveMessage(connection)
```

Receives message using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L442)

<a id="constant-constant-minisql-protocol-connection-secure-transport-const-secure-transport-9030-src-minisql-protocol-connection-ml-2120036559"></a>
### SECURE_TRANSPORT

```ml
const SECURE_TRANSPORT = 9030
```

Defines the secure transport constant used by the minisql protocol connection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L28)

<a id="function-function-minisql-protocol-connection-secureactive-function-secureactive-connection-src-minisql-protocol-connection-ml-246226912"></a>
### secureActive

```ml
function secureActive(connection)
```

Implements secure active for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L286)

<a id="function-function-minisql-protocol-connection-sendmessage-function-sendmessage-connection-message-src-minisql-protocol-connection-ml-978925877"></a>
### sendMessage

```ml
function sendMessage(connection, message)
```

Sends message using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L425)

<a id="function-function-minisql-protocol-connection-settimeouts-function-settimeouts-connection-receivems-sendms-src-minisql-protocol-connection-ml-50564487"></a>
### setTimeouts

```ml
function setTimeouts(connection, receiveMs, sendMs)
```

Applies bounded socket I/O while a caller performs a protocol phase such as the initial HELLO exchange. Passing zero restores normal unbounded query I/O.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `receiveMs` | `dynamic` | — | receiveMs value consumed by this operation. |
| `sendMs` | `dynamic` | — | sendMs value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L154)

<a id="function-function-minisql-protocol-connection-targetmilestone-function-targetmilestone-src-minisql-protocol-connection-ml-652479078"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql protocol connection module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L536)

<a id="function-function-minisql-protocol-connection-tlsactive-function-tlsactive-connection-src-minisql-protocol-connection-ml-117327562"></a>
### tlsActive

```ml
function tlsActive(connection)
```

Reports whether native TLS record protection is active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L293)

<a id="function-function-minisql-protocol-connection-unprotectmessage-function-unprotectmessage-connection-message-src-minisql-protocol-connection-ml-2084867119"></a>
### unprotectMessage

```ml
function unprotectMessage(connection, message)
```

Implements unprotect message for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L329)

<a id="function-function-minisql-protocol-connection-validateopen-function-validateopen-connection-operation-src-minisql-protocol-connection-ml-518685321"></a>
### validateOpen

```ml
function validateOpen(connection, operation)
```

Validates open for the minisql protocol connection workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — | connection value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L165)
