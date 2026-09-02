# `src/minisql/client/client.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.client.client`](Package-minisql-client-client-1899571164.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/protocol/connection.ml` as `connection` → [src/minisql/protocol/connection.ml](File-src-minisql-protocol-connection-ml-870021768.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)

## Declarations

<a id="function-function-minisql-client-client-abort-function-abort-client-src-minisql-client-client-ml-614055763"></a>
### abort

```ml
function abort(client)
```

Aborts a client whose request/response framing may have been interrupted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L439)

<a id="constant-constant-minisql-client-client-authentication-failed-const-authentication-failed-9027-src-minisql-client-client-ml-1531040535"></a>
### AUTHENTICATION_FAILED

```ml
const AUTHENTICATION_FAILED = 9027
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L15)

<a id="function-function-minisql-client-client-authenticationfailure-function-authenticationfailure-operation-src-minisql-client-client-ml-1506524669"></a>
### authenticationFailure

```ml
function authenticationFailure(operation)
```

Implements authentication failure for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L72)

<a id="function-function-minisql-client-client-beginquery-function-beginquery-client-sqltext-src-minisql-client-client-ml-1192851786"></a>
### beginQuery

```ml
function beginQuery(client, sqlText)
```

Sends one SQL request and transfers ownership of its response stream to a cursor. A connection permits one active query because protocol v1 preserves response ordering and intentionally does not interleave request frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L341)

<a id="function-function-minisql-client-client-cancelsession-function-cancelsession-client-sessionid-src-minisql-client-client-ml-172062904"></a>
### cancelSession

```ml
function cancelSession(client, sessionId)
```

Requests cooperative cancellation through a separate administrative client. The target query connection remains protocol-aligned and receives error 9035.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L403)

<a id="function-function-minisql-client-client-clearauthchallenge-function-clearauthchallenge-challenge-src-minisql-client-client-ml-1612296957"></a>
### clearAuthChallenge

```ml
function clearAuthChallenge(challenge)
```

Implements clear auth challenge for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `challenge` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L166)

- [minisql.client.client.Client](Type-minisql-client-client-client-823929285.md) — struct
<a id="function-function-minisql-client-client-close-function-close-client-src-minisql-client-client-ml-668924311"></a>
### close

```ml
function close(client)
```

Closes close using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L422)

<a id="constant-constant-minisql-client-client-closed-handle-const-closed-handle-9008-src-minisql-client-client-ml-2144123018"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L14)

<a id="function-function-minisql-client-client-closefailedopen-function-closefailedopen-client-result-src-minisql-client-client-ml-1944491628"></a>
### closeFailedOpen

```ml
function closeFailedOpen(client, result)
```

Closes failed open using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L144)

<a id="function-function-minisql-client-client-componentname-function-componentname-src-minisql-client-client-ml-1317600272"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L459)

<a id="function-function-minisql-client-client-fail-function-fail-code-operation-message-src-minisql-client-client-ml-989672033"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L65)

<a id="function-function-minisql-client-client-failquerycursor-function-failquerycursor-cursor-failure-src-minisql-client-client-ml-1587789780"></a>
### failQueryCursor

```ml
function failQueryCursor(cursor, failure)
```

Invalidates a connection after a response-stream failure. Once a frame has been lost or rejected, protocol v1 cannot safely locate the next request boundary, so the original error is returned and the socket is not reused.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — |  |
| `failure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L356)

<a id="constant-constant-minisql-client-client-handshake-timeout-ms-const-handshake-timeout-ms-5000-src-minisql-client-client-ml-1224901564"></a>
### HANDSHAKE_TIMEOUT_MS

```ml
const HANDSHAKE_TIMEOUT_MS = 5000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L16)

<a id="function-function-minisql-client-client-hellohandshake-function-hellohandshake-client-operation-src-minisql-client-client-ml-485860268"></a>
### helloHandshake

```ml
function helloHandshake(client, operation)
```

Implements hello handshake for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L127)

<a id="constant-constant-minisql-client-client-invalid-argument-const-invalid-argument-9001-src-minisql-client-client-ml-259307175"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L13)

<a id="function-function-minisql-client-client-isclient-function-isclient-value-src-minisql-client-client-ml-1198377377"></a>
### isClient

```ml
function isClient(value)
```

Returns whether the supplied value satisfies the client condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L79)

<a id="function-function-minisql-client-client-isimplemented-function-isimplemented-src-minisql-client-client-ml-1419889272"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L473)

<a id="function-function-minisql-client-client-isquerycursor-function-isquerycursor-value-src-minisql-client-client-ml-1805107421"></a>
### isQueryCursor

```ml
function isQueryCursor(value)
```

Reports whether a value is a forward-only client query cursor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L84)

<a id="function-function-minisql-client-client-m0selftestline-function-m0selftestline-src-minisql-client-client-ml-723425184"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Implements m0 self test line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L51)

<a id="function-function-minisql-client-client-nextquerybatch-function-nextquerybatch-cursor-src-minisql-client-client-ml-248124294"></a>
### nextQueryBatch

```ml
function nextQueryBatch(cursor)
```

Receives and decodes one bounded continuation frame. Returning void denotes end-of-stream; the final response itself is returned before that sentinel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L367)

<a id="function-function-minisql-client-client-openauthenticatedaddress-function-openauthenticatedaddress-address-port-username-password-src-minisql-client-client-ml-980594830"></a>
### openAuthenticatedAddress

```ml
function openAuthenticatedAddress(address, port, username, password)
```

Opens authenticated address using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L279)

<a id="function-function-minisql-client-client-openauthenticatedaddressbytes-function-openauthenticatedaddressbytes-address-port-username-passwordbytes-src-minisql-client-client-ml-591594365"></a>
### openAuthenticatedAddressBytes

```ml
function openAuthenticatedAddressBytes(address, port, username, passwordBytes)
```

Opens authenticated address bytes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L247)

<a id="function-function-minisql-client-client-openauthenticatedconnection-function-openauthenticatedconnection-connectionvalue-username-passwordbytes-operation-src-minisql-client-client-ml-412718330"></a>
### openAuthenticatedConnection

```ml
function openAuthenticatedConnection(connectionValue, username, passwordBytes, operation)
```

Opens authenticated connection using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connectionValue` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L177)

<a id="function-function-minisql-client-client-openauthenticatedloopback-function-openauthenticatedloopback-port-username-password-src-minisql-client-client-ml-58507610"></a>
### openAuthenticatedLoopback

```ml
function openAuthenticatedLoopback(port, username, password)
```

Opens authenticated loopback using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L311)

<a id="function-function-minisql-client-client-openauthenticatedloopbackbytes-function-openauthenticatedloopbackbytes-port-username-passwordbytes-src-minisql-client-client-ml-1968197861"></a>
### openAuthenticatedLoopbackBytes

```ml
function openAuthenticatedLoopbackBytes(port, username, passwordBytes)
```

Opens authenticated loopback bytes using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L271)

<a id="function-function-minisql-client-client-openloopback-function-openloopback-port-src-minisql-client-client-ml-1824962151"></a>
### openLoopback

```ml
function openLoopback(port)
```

Opens loopback using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L154)

<a id="function-function-minisql-client-client-opentlsauthenticatedaddress-function-opentlsauthenticatedaddress-address-port-servername-username-password-src-minisql-client-client-ml-1615902426"></a>
### openTlsAuthenticatedAddress

```ml
function openTlsAuthenticatedAddress(address, port, serverName, username, password)
```

Opens native TLS with Windows trust while wiping the temporary password bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L289)

<a id="function-function-minisql-client-client-opentlsauthenticatedaddressbytes-function-opentlsauthenticatedaddressbytes-address-port-servername-username-passwordbytes-src-minisql-client-client-ml-397211281"></a>
### openTlsAuthenticatedAddressBytes

```ml
function openTlsAuthenticatedAddressBytes(address, port, serverName, username, passwordBytes)
```

Opens authenticated MiniSQL over native TLS with Windows X.509 trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L253)

<a id="function-function-minisql-client-client-opentlspinnedauthenticatedaddress-function-opentlspinnedauthenticatedaddress-address-port-servername-pintext-username-password-src-minisql-client-client-ml-823596012"></a>
### openTlsPinnedAuthenticatedAddress

```ml
function openTlsPinnedAuthenticatedAddress(address, port, serverName, pinText, username, password)
```

Opens pinned native TLS while wiping the temporary password bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `pinText` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L299)

<a id="function-function-minisql-client-client-opentlspinnedauthenticatedaddressbytes-function-opentlspinnedauthenticatedaddressbytes-address-port-servername-pintext-username-passwordbytes-src-minisql-client-client-ml-203989315"></a>
### openTlsPinnedAuthenticatedAddressBytes

```ml
function openTlsPinnedAuthenticatedAddressBytes(address, port, serverName, pinText, username, passwordBytes)
```

Opens authenticated MiniSQL over native TLS with exact SHA-256 leaf pinning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `pinText` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L261)

<a id="function-function-minisql-client-client-ping-function-ping-client-src-minisql-client-client-ml-110245255"></a>
### ping

```ml
function ping(client)
```

Implements ping for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L395)

<a id="function-function-minisql-client-client-protocolbytecounts-function-protocolbytecounts-client-src-minisql-client-client-ml-101902387"></a>
### protocolByteCounts

```ml
function protocolByteCounts(client)
```

Returns sent and received framed-protocol byte counters for diagnostics and reproducible connector benchmarks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L413)

<a id="function-function-minisql-client-client-query-function-query-client-sqltext-src-minisql-client-client-ml-1364786922"></a>
### query

```ml
function query(client, sqlText)
```

Implements query for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L318)

- [minisql.client.client.QueryCursor](Type-minisql-client-client-querycursor-914568424.md) — struct
<a id="function-function-minisql-client-client-request-function-request-client-message-src-minisql-client-client-ml-193922988"></a>
### request

```ml
function request(client, message)
```

Implements request for this module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L101)

<a id="function-function-minisql-client-client-runinteractive-function-runinteractive-src-minisql-client-client-ml-1017933156"></a>
### runInteractive

```ml
function runInteractive()
```

Runs interactive using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L452)

<a id="function-function-minisql-client-client-samecolumns-function-samecolumns-left-right-src-minisql-client-client-ml-254800823"></a>
### sameColumns

```ml
function sameColumns(left, right)
```

Compares response schemas across continuation frames without relying on aggregate-array identity semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L113)

<a id="function-function-minisql-client-client-targetmilestone-function-targetmilestone-src-minisql-client-client-ml-1718323014"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L466)

<a id="function-function-minisql-client-client-validateopen-function-validateopen-client-operation-src-minisql-client-client-ml-2002670152"></a>
### validateOpen

```ml
function validateOpen(client, operation)
```

Validates open using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L92)

<a id="function-function-minisql-client-client-versionline-function-versionline-src-minisql-client-client-ml-537341400"></a>
### versionLine

```ml
function versionLine()
```

Implements version line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L58)
