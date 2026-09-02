# `src/minisql/protocol/connection.ml`

[Home](README.md) · [Files](Files.md)

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
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L446)

<a id="function-function-minisql-protocol-connection-appendreceivebytes-function-appendreceivebytes-connection-incoming-src-minisql-protocol-connection-ml-409761652"></a>
### appendReceiveBytes

```ml
function appendReceiveBytes(connection, incoming)
```

Appends plaintext obtained from Schannel while preserving the frame memory bound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `incoming` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L175)

<a id="function-function-minisql-protocol-connection-appendreceivescratch-function-appendreceivescratch-connection-count-src-minisql-protocol-connection-ml-22295363"></a>
### appendReceiveScratch

```ml
function appendReceiveScratch(connection, count)
```

Appends receive scratch using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L159)

<a id="function-function-minisql-protocol-connection-close-function-close-connection-src-minisql-protocol-connection-ml-371202104"></a>
### close

```ml
function close(connection)
```

Closes close using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L420)

<a id="constant-constant-minisql-protocol-connection-closed-handle-const-closed-handle-9008-src-minisql-protocol-connection-ml-463517886"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L20)

<a id="function-function-minisql-protocol-connection-componentname-function-componentname-src-minisql-protocol-connection-ml-233166304"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L470)

<a id="function-function-minisql-protocol-connection-connectaddress-function-connectaddress-address-port-src-minisql-protocol-connection-ml-430820979"></a>
### connectAddress

```ml
function connectAddress(address, port)
```

Connects address using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L92)

- [minisql.protocol.connection.Connection](Type-minisql-protocol-connection-connection-344312244.md) — struct
<a id="function-function-minisql-protocol-connection-connectloopback-function-connectloopback-port-src-minisql-protocol-connection-ml-473957737"></a>
### connectLoopback

```ml
function connectLoopback(port)
```

Connects loopback using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L123)

<a id="function-function-minisql-protocol-connection-connecttlsaddress-function-connecttlsaddress-address-port-servername-src-minisql-protocol-connection-ml-362774277"></a>
### connectTlsAddress

```ml
function connectTlsAddress(address, port, serverName)
```

Connects a TCP socket and completes native TLS with Windows root-store trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L97)

<a id="function-function-minisql-protocol-connection-connecttlspinnedaddress-function-connecttlspinnedaddress-address-port-servername-pintext-src-minisql-protocol-connection-ml-1005533091"></a>
### connectTlsPinnedAddress

```ml
function connectTlsPinnedAddress(address, port, serverName, pinText)
```

Connects native TLS using an exact SHA-256 leaf pin for private certificates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `pinText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L109)

<a id="function-function-minisql-protocol-connection-copyrange-function-copyrange-source-offset-count-operation-src-minisql-protocol-connection-ml-1748581154"></a>
### copyRange

```ml
function copyRange(source, offset, count, operation)
```

Implements copy range for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L148)

<a id="constant-constant-minisql-protocol-connection-corrupt-data-const-corrupt-data-9004-src-minisql-protocol-connection-ml-879765828"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L21)

<a id="function-function-minisql-protocol-connection-create-function-create-sockethandle-src-minisql-protocol-connection-ml-1434457539"></a>
### create

```ml
function create(socketHandle)
```

Creates create using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L84)

<a id="function-function-minisql-protocol-connection-decodeinbound-function-decodeinbound-connection-frame-src-minisql-protocol-connection-ml-633926463"></a>
### decodeInbound

```ml
function decodeInbound(connection, frame)
```

Decodes inbound using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L309)

<a id="function-function-minisql-protocol-connection-enablesecure-function-enablesecure-connection-sendkey-receivekey-src-minisql-protocol-connection-ml-395214409"></a>
### enableSecure

```ml
function enableSecure(connection, sendKey, receiveKey)
```

Implements enable secure for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `sendKey` | `dynamic` | — |  |
| `receiveKey` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L219)

<a id="function-function-minisql-protocol-connection-enabletls-function-enabletls-connection-tlscontext-src-minisql-protocol-connection-ml-532141020"></a>
### enableTls

```ml
function enableTls(connection, tlsContext)
```

Attaches a completed Schannel context below the MiniSQL framed protocol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `tlsContext` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L232)

<a id="function-function-minisql-protocol-connection-extractbufferedmessage-function-extractbufferedmessage-connection-src-minisql-protocol-connection-ml-1657465084"></a>
### extractBufferedMessage

```ml
function extractBufferedMessage(connection)
```

Implements extract buffered message for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L191)

<a id="function-function-minisql-protocol-connection-fail-function-fail-code-operation-message-src-minisql-protocol-connection-ml-250590469"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L70)

<a id="constant-constant-minisql-protocol-connection-invalid-argument-const-invalid-argument-9001-src-minisql-protocol-connection-ml-55962339"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L19)

<a id="function-function-minisql-protocol-connection-isconnection-function-isconnection-value-src-minisql-protocol-connection-ml-398223009"></a>
### isConnection

```ml
function isConnection(value)
```

Returns whether the supplied value satisfies the connection condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L77)

<a id="function-function-minisql-protocol-connection-isimplemented-function-isimplemented-src-minisql-protocol-connection-ml-743716744"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L484)

<a id="function-function-minisql-protocol-connection-ispollresult-function-ispollresult-value-src-minisql-protocol-connection-ml-962966921"></a>
### isPollResult

```ml
function isPollResult(value)
```

Returns whether the supplied value satisfies the poll result condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L316)

<a id="function-function-minisql-protocol-connection-makenonblocking-function-makenonblocking-connection-src-minisql-protocol-connection-ml-122501172"></a>
### makeNonBlocking

```ml
function makeNonBlocking(connection)
```

Creates non blocking using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L323)

<a id="constant-constant-minisql-protocol-connection-poll-receive-bytes-const-poll-receive-bytes-65536-src-minisql-protocol-connection-ml-1375018834"></a>
### POLL_RECEIVE_BYTES

```ml
const POLL_RECEIVE_BYTES = 65536
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L23)

<a id="function-function-minisql-protocol-connection-pollmessage-function-pollmessage-connection-src-minisql-protocol-connection-ml-562205644"></a>
### pollMessage

```ml
function pollMessage(connection)
```

Attempts one nonblocking framed receive. Returns PollResult when a complete frame or clean EOF is available, void when more bytes are needed, or an error for malformed/truncated/transport input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L332)

- [minisql.protocol.connection.PollResult](Type-minisql-protocol-connection-pollresult-314322152.md) — struct
<a id="function-function-minisql-protocol-connection-protectmessage-function-protectmessage-connection-message-src-minisql-protocol-connection-ml-950709283"></a>
### protectMessage

```ml
function protectMessage(connection, message)
```

Implements protect message for this module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L258)

<a id="function-function-minisql-protocol-connection-protocolbytesreceived-function-protocolbytesreceived-connection-src-minisql-protocol-connection-ml-1019780388"></a>
### protocolBytesReceived

```ml
function protocolBytesReceived(connection)
```

Returns framed protocol bytes read by this connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L411)

<a id="function-function-minisql-protocol-connection-protocolbytessent-function-protocolbytessent-connection-src-minisql-protocol-connection-ml-1201636758"></a>
### protocolBytesSent

```ml
function protocolBytesSent(connection)
```

Returns framed protocol bytes written by this connection. TLS record overhead is deliberately excluded so plain and protected protocol workloads compare.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L405)

<a id="function-function-minisql-protocol-connection-receivemessage-function-receivemessage-connection-src-minisql-protocol-connection-ml-211292584"></a>
### receiveMessage

```ml
function receiveMessage(connection)
```

Receives message using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L387)

<a id="constant-constant-minisql-protocol-connection-secure-transport-const-secure-transport-9030-src-minisql-protocol-connection-ml-2120036559"></a>
### SECURE_TRANSPORT

```ml
const SECURE_TRANSPORT = 9030
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L22)

<a id="function-function-minisql-protocol-connection-secureactive-function-secureactive-connection-src-minisql-protocol-connection-ml-246226912"></a>
### secureActive

```ml
function secureActive(connection)
```

Implements secure active for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L244)

<a id="function-function-minisql-protocol-connection-sendmessage-function-sendmessage-connection-message-src-minisql-protocol-connection-ml-978925877"></a>
### sendMessage

```ml
function sendMessage(connection, message)
```

Sends message using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L371)

<a id="function-function-minisql-protocol-connection-settimeouts-function-settimeouts-connection-receivems-sendms-src-minisql-protocol-connection-ml-50564487"></a>
### setTimeouts

```ml
function setTimeouts(connection, receiveMs, sendMs)
```

Applies bounded socket I/O while a caller performs a protocol phase such as the initial HELLO exchange. Passing zero restores normal unbounded query I/O.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `receiveMs` | `dynamic` | — |  |
| `sendMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L129)

<a id="function-function-minisql-protocol-connection-targetmilestone-function-targetmilestone-src-minisql-protocol-connection-ml-652479078"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L477)

<a id="function-function-minisql-protocol-connection-tlsactive-function-tlsactive-connection-src-minisql-protocol-connection-ml-117327562"></a>
### tlsActive

```ml
function tlsActive(connection)
```

Reports whether native TLS record protection is active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L250)

<a id="function-function-minisql-protocol-connection-unprotectmessage-function-unprotectmessage-connection-message-src-minisql-protocol-connection-ml-2084867119"></a>
### unprotectMessage

```ml
function unprotectMessage(connection, message)
```

Implements unprotect message for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L282)

<a id="function-function-minisql-protocol-connection-validateopen-function-validateopen-connection-operation-src-minisql-protocol-connection-ml-518685321"></a>
### validateOpen

```ml
function validateOpen(connection, operation)
```

Validates open using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connection` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L138)
