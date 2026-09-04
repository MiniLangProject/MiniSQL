# `src/minisql/client/client.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql client client facilities for this project.

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
| `client` | `dynamic` | — | client value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L516)

<a id="constant-constant-minisql-client-client-authentication-failed-const-authentication-failed-9027-src-minisql-client-client-ml-1531040535"></a>
### AUTHENTICATION_FAILED

```ml
const AUTHENTICATION_FAILED = 9027
```

Defines the authentication failed constant used by the minisql client client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L20)

<a id="function-function-minisql-client-client-authenticationfailure-function-authenticationfailure-operation-src-minisql-client-client-ml-1506524669"></a>
### authenticationFailure

```ml
function authenticationFailure(operation)
```

Implements authentication failure for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L82)

<a id="function-function-minisql-client-client-beginquery-function-beginquery-client-sqltext-src-minisql-client-client-ml-1192851786"></a>
### beginQuery

```ml
function beginQuery(client, sqlText)
```

Sends one SQL request and transfers ownership of its response stream to a cursor. A connection permits one active query because protocol v1 preserves response ordering and intentionally does not interleave request frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L409)

<a id="function-function-minisql-client-client-cancelsession-function-cancelsession-client-sessionid-src-minisql-client-client-ml-172062904"></a>
### cancelSession

```ml
function cancelSession(client, sessionId)
```

Requests cooperative cancellation through a separate administrative client. The target query connection remains protocol-aligned and receives error 9035.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L477)

<a id="function-function-minisql-client-client-clearauthchallenge-function-clearauthchallenge-challenge-src-minisql-client-client-ml-1612296957"></a>
### clearAuthChallenge

```ml
function clearAuthChallenge(challenge)
```

Implements clear auth challenge for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `challenge` | `dynamic` | — | challenge value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L190)

- [minisql.client.client.Client](Type-minisql-client-client-client-823929285.md) — struct
<a id="function-function-minisql-client-client-close-function-close-client-src-minisql-client-client-ml-668924311"></a>
### close

```ml
function close(client)
```

Closes close owned by the minisql client client module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L498)

<a id="constant-constant-minisql-client-client-closed-handle-const-closed-handle-9008-src-minisql-client-client-ml-2144123018"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql client client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L18)

<a id="function-function-minisql-client-client-closefailedopen-function-closefailedopen-client-result-src-minisql-client-client-ml-1944491628"></a>
### closeFailedOpen

```ml
function closeFailedOpen(client, result)
```

Closes failed open using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L166)

<a id="function-function-minisql-client-client-componentname-function-componentname-src-minisql-client-client-ml-1317600272"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql client client module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L536)

<a id="function-function-minisql-client-client-fail-function-fail-code-operation-message-src-minisql-client-client-ml-989672033"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql client client module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L74)

<a id="function-function-minisql-client-client-failquerycursor-function-failquerycursor-cursor-failure-src-minisql-client-client-ml-1587789780"></a>
### failQueryCursor

```ml
function failQueryCursor(cursor, failure)
```

Invalidates a connection after a response-stream failure. Once a frame has been lost or rejected, protocol v1 cannot safely locate the next request boundary, so the original error is returned and the socket is not reused.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |
| `failure` | `dynamic` | — | failure value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L426)

<a id="constant-constant-minisql-client-client-handshake-timeout-ms-const-handshake-timeout-ms-5000-src-minisql-client-client-ml-1224901564"></a>
### HANDSHAKE_TIMEOUT_MS

```ml
const HANDSHAKE_TIMEOUT_MS = 5000
```

Defines the handshake timeout ms constant used by the minisql client client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L22)

<a id="function-function-minisql-client-client-hellohandshake-function-hellohandshake-client-operation-src-minisql-client-client-ml-485860268"></a>
### helloHandshake

```ml
function helloHandshake(client, operation)
```

Implements hello handshake for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L147)

<a id="constant-constant-minisql-client-client-invalid-argument-const-invalid-argument-9001-src-minisql-client-client-ml-259307175"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql client client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L16)

<a id="function-function-minisql-client-client-isclient-function-isclient-value-src-minisql-client-client-ml-1198377377"></a>
### isClient

```ml
function isClient(value)
```

Returns whether the supplied value satisfies the client condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L90)

<a id="function-function-minisql-client-client-isimplemented-function-isimplemented-src-minisql-client-client-ml-1419889272"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql client client module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L550)

<a id="function-function-minisql-client-client-isquerycursor-function-isquerycursor-value-src-minisql-client-client-ml-1805107421"></a>
### isQueryCursor

```ml
function isQueryCursor(value)
```

Reports whether a value is a forward-only client query cursor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L96)

<a id="function-function-minisql-client-client-m0selftestline-function-m0selftestline-src-minisql-client-client-ml-723425184"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Performs the m0SelfTestLine operation for the minisql client client module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L57)

<a id="function-function-minisql-client-client-nextquerybatch-function-nextquerybatch-cursor-src-minisql-client-client-ml-248124294"></a>
### nextQueryBatch

```ml
function nextQueryBatch(cursor)
```

Receives and decodes one bounded continuation frame. Returning void denotes end-of-stream; the final response itself is returned before that sentinel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L438)

<a id="function-function-minisql-client-client-openauthenticatedaddress-function-openauthenticatedaddress-address-port-username-password-src-minisql-client-client-ml-980594830"></a>
### openAuthenticatedAddress

```ml
function openAuthenticatedAddress(address, port, username, password)
```

Opens authenticated address using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `password` | `dynamic` | — | password value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L329)

<a id="function-function-minisql-client-client-openauthenticatedaddressbytes-function-openauthenticatedaddressbytes-address-port-username-passwordbytes-src-minisql-client-client-ml-591594365"></a>
### openAuthenticatedAddressBytes

```ml
function openAuthenticatedAddressBytes(address, port, username, passwordBytes)
```

Opens authenticated address bytes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L279)

<a id="function-function-minisql-client-client-openauthenticatedconnection-function-openauthenticatedconnection-connectionvalue-username-passwordbytes-operation-src-minisql-client-client-ml-412718330"></a>
### openAuthenticatedConnection

```ml
function openAuthenticatedConnection(connectionValue, username, passwordBytes, operation)
```

Opens authenticated connection using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connectionValue` | `dynamic` | — | connectionValue value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L205)

<a id="function-function-minisql-client-client-openauthenticatedloopback-function-openauthenticatedloopback-port-username-password-src-minisql-client-client-ml-58507610"></a>
### openAuthenticatedLoopback

```ml
function openAuthenticatedLoopback(port, username, password)
```

Opens authenticated loopback using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `password` | `dynamic` | — | password value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L375)

<a id="function-function-minisql-client-client-openauthenticatedloopbackbytes-function-openauthenticatedloopbackbytes-port-username-passwordbytes-src-minisql-client-client-ml-1968197861"></a>
### openAuthenticatedLoopbackBytes

```ml
function openAuthenticatedLoopbackBytes(port, username, passwordBytes)
```

Opens authenticated loopback bytes using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L317)

<a id="function-function-minisql-client-client-openloopback-function-openloopback-port-src-minisql-client-client-ml-1824962151"></a>
### openLoopback

```ml
function openLoopback(port)
```

Opens loopback using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | port value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L177)

<a id="function-function-minisql-client-client-opentlsauthenticatedaddress-function-opentlsauthenticatedaddress-address-port-servername-username-password-src-minisql-client-client-ml-1615902426"></a>
### openTlsAuthenticatedAddress

```ml
function openTlsAuthenticatedAddress(address, port, serverName, username, password)
```

Opens native TLS with Windows trust while wiping the temporary password bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `password` | `dynamic` | — | password value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L344)

<a id="function-function-minisql-client-client-opentlsauthenticatedaddressbytes-function-opentlsauthenticatedaddressbytes-address-port-servername-username-passwordbytes-src-minisql-client-client-ml-397211281"></a>
### openTlsAuthenticatedAddressBytes

```ml
function openTlsAuthenticatedAddressBytes(address, port, serverName, username, passwordBytes)
```

Opens authenticated MiniSQL over native TLS with Windows X.509 trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L290)

<a id="function-function-minisql-client-client-opentlspinnedauthenticatedaddress-function-opentlspinnedauthenticatedaddress-address-port-servername-pintext-username-password-src-minisql-client-client-ml-823596012"></a>
### openTlsPinnedAuthenticatedAddress

```ml
function openTlsPinnedAuthenticatedAddress(address, port, serverName, pinText, username, password)
```

Opens pinned native TLS while wiping the temporary password bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `password` | `dynamic` | — | password value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L360)

<a id="function-function-minisql-client-client-opentlspinnedauthenticatedaddressbytes-function-opentlspinnedauthenticatedaddressbytes-address-port-servername-pintext-username-passwordbytes-src-minisql-client-client-ml-203989315"></a>
### openTlsPinnedAuthenticatedAddressBytes

```ml
function openTlsPinnedAuthenticatedAddressBytes(address, port, serverName, pinText, username, passwordBytes)
```

Opens authenticated MiniSQL over native TLS with exact SHA-256 leaf pinning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L304)

<a id="function-function-minisql-client-client-ping-function-ping-client-src-minisql-client-client-ml-110245255"></a>
### ping

```ml
function ping(client)
```

Implements ping for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L467)

<a id="function-function-minisql-client-client-protocolbytecounts-function-protocolbytecounts-client-src-minisql-client-client-ml-101902387"></a>
### protocolByteCounts

```ml
function protocolByteCounts(client)
```

Returns sent and received framed-protocol byte counters for diagnostics and reproducible connector benchmarks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L488)

<a id="function-function-minisql-client-client-query-function-query-client-sqltext-src-minisql-client-client-ml-1364786922"></a>
### query

```ml
function query(client, sqlText)
```

Implements query for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L384)

- [minisql.client.client.QueryCursor](Type-minisql-client-client-querycursor-914568424.md) — struct
<a id="function-function-minisql-client-client-request-function-request-client-message-src-minisql-client-client-ml-193922988"></a>
### request

```ml
function request(client, message)
```

Implements request for this module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L117)

<a id="function-function-minisql-client-client-runinteractive-function-runinteractive-src-minisql-client-client-ml-1017933156"></a>
### runInteractive

```ml
function runInteractive()
```

Runs interactive using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L529)

<a id="function-function-minisql-client-client-samecolumns-function-samecolumns-left-right-src-minisql-client-client-ml-254800823"></a>
### sameColumns

```ml
function sameColumns(left, right)
```

Compares response schemas across continuation frames without relying on aggregate-array identity semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L131)

<a id="function-function-minisql-client-client-targetmilestone-function-targetmilestone-src-minisql-client-client-ml-1718323014"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql client client module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L543)

<a id="function-function-minisql-client-client-validateopen-function-validateopen-client-operation-src-minisql-client-client-ml-2002670152"></a>
### validateOpen

```ml
function validateOpen(client, operation)
```

Validates open for the minisql client client workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | client value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L106)

<a id="function-function-minisql-client-client-versionline-function-versionline-src-minisql-client-client-ml-537341400"></a>
### versionLine

```ml
function versionLine()
```

Performs the versionLine operation for the minisql client client module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L64)
