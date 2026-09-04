# `src/minisql/protocol/messages.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql protocol messages facilities for this project.

Package: [`minisql.protocol.messages`](Package-minisql-protocol-messages-884679746.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)

## Declarations

<a id="function-function-minisql-protocol-messages-authbegin-function-authbegin-requestid-username-src-minisql-protocol-messages-ml-861127374"></a>
### authBegin

```ml
function authBegin(requestId, username)
```

Implements auth begin for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L114)

<a id="function-function-minisql-protocol-messages-authchallenge-function-authchallenge-requestid-iterations-salt-nonce-scheme-src-minisql-protocol-messages-ml-728051046"></a>
### authChallenge

```ml
function authChallenge(requestId, iterations, salt, nonce, scheme)
```

Implements auth challenge for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `iterations` | `dynamic` | — | iterations value consumed by this operation. |
| `salt` | `dynamic` | — | salt value consumed by this operation. |
| `nonce` | `dynamic` | — | nonce value consumed by this operation. |
| `scheme` | `dynamic` | — | scheme value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L146)

<a id="function-function-minisql-protocol-messages-authok-function-authok-requestid-serverproof-src-minisql-protocol-messages-ml-1072171503"></a>
### authOk

```ml
function authOk(requestId, serverProof)
```

Implements auth ok for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `serverProof` | `dynamic` | — | serverProof value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L193)

<a id="function-function-minisql-protocol-messages-authproof-function-authproof-requestid-proof-src-minisql-protocol-messages-ml-2129408958"></a>
### authProof

```ml
function authProof(requestId, proof)
```

Implements auth proof for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `proof` | `dynamic` | — | proof value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L182)

<a id="function-function-minisql-protocol-messages-cancelrequest-function-cancelrequest-requestid-sessionid-src-minisql-protocol-messages-ml-599710079"></a>
### cancelRequest

```ml
function cancelRequest(requestId, sessionId)
```

Creates an administrative cancellation request for one active session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L217)

<a id="function-function-minisql-protocol-messages-closerequest-function-closerequest-requestid-src-minisql-protocol-messages-ml-29415648"></a>
### closeRequest

```ml
function closeRequest(requestId)
```

Closes request using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L210)

<a id="function-function-minisql-protocol-messages-commandresponse-function-commandresponse-command-affectedrows-message-src-minisql-protocol-messages-ml-1660127651"></a>
### commandResponse

```ml
function commandResponse(command, affectedRows, message)
```

Implements command response for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | command value consumed by this operation. |
| `affectedRows` | `dynamic` | — | affectedRows value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L239)

<a id="function-function-minisql-protocol-messages-componentname-function-componentname-src-minisql-protocol-messages-ml-1860101052"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql protocol messages module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L413)

<a id="constant-constant-minisql-protocol-messages-corrupt-data-const-corrupt-data-9004-src-minisql-protocol-messages-ml-1538552720"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql protocol messages module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L15)

<a id="function-function-minisql-protocol-messages-create-function-create-messagetype-flags-requestid-payload-src-minisql-protocol-messages-ml-623699612"></a>
### create

```ml
function create(messageType, flags, requestId, payload)
```

Creates create for the minisql protocol messages module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messageType` | `dynamic` | — | messageType value consumed by this operation. |
| `flags` | `dynamic` | — | Bit flags controlling the operation. |
| `requestId` | `dynamic` | — | Identifier of request. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L81)

<a id="function-function-minisql-protocol-messages-decodeauthbegin-function-decodeauthbegin-payload-src-minisql-protocol-messages-ml-1797547444"></a>
### decodeAuthBegin

```ml
function decodeAuthBegin(payload)
```

Decodes auth begin using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L128)

<a id="function-function-minisql-protocol-messages-decodeauthchallenge-function-decodeauthchallenge-payload-src-minisql-protocol-messages-ml-940584592"></a>
### decodeAuthChallenge

```ml
function decodeAuthChallenge(payload)
```

Decodes auth challenge using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L163)

<a id="function-function-minisql-protocol-messages-decodecancelrequest-function-decodecancelrequest-payload-src-minisql-protocol-messages-ml-316471780"></a>
### decodeCancelRequest

```ml
function decodeCancelRequest(payload)
```

Decodes and validates an administrative cancellation target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L226)

<a id="function-function-minisql-protocol-messages-decoderesponse-function-decoderesponse-source-src-minisql-protocol-messages-ml-1712650805"></a>
### decodeResponse

```ml
function decodeResponse(source)
```

Decodes response using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L370)

<a id="function-function-minisql-protocol-messages-encoderesponse-function-encoderesponse-response-src-minisql-protocol-messages-ml-1522164307"></a>
### encodeResponse

```ml
function encodeResponse(response)
```

Encodes response using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — | response value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L330)

<a id="function-function-minisql-protocol-messages-errorresponse-function-errorresponse-code-message-src-minisql-protocol-messages-ml-459743622"></a>
### errorResponse

```ml
function errorResponse(code, message)
```

Creates an error for response using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L257)

<a id="function-function-minisql-protocol-messages-fail-function-fail-code-operation-message-src-minisql-protocol-messages-ml-2129809533"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql protocol messages module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L53)

<a id="function-function-minisql-protocol-messages-fieldsize-function-fieldsize-value-src-minisql-protocol-messages-ml-899695487"></a>
### fieldSize

```ml
function fieldSize(value)
```

Implements field size for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L275)

<a id="function-function-minisql-protocol-messages-hello-function-hello-requestid-src-minisql-protocol-messages-ml-556219208"></a>
### hello

```ml
function hello(requestId)
```

Implements hello for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L93)

<a id="constant-constant-minisql-protocol-messages-invalid-argument-const-invalid-argument-9001-src-minisql-protocol-messages-ml-749605079"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql protocol messages module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L13)

<a id="function-function-minisql-protocol-messages-isimplemented-function-isimplemented-src-minisql-protocol-messages-ml-306399572"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql protocol messages module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L427)

<a id="function-function-minisql-protocol-messages-ismessage-function-ismessage-value-src-minisql-protocol-messages-ml-1923200535"></a>
### isMessage

```ml
function isMessage(value)
```

Returns whether the supplied value satisfies the message condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L61)

<a id="function-function-minisql-protocol-messages-isresponse-function-isresponse-value-src-minisql-protocol-messages-ml-1298240945"></a>
### isResponse

```ml
function isResponse(value)
```

Returns whether the supplied value satisfies the response condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L69)

- [minisql.protocol.messages.Message](Type-minisql-protocol-messages-message-1836948963.md) — struct
<a id="function-function-minisql-protocol-messages-ping-function-ping-requestid-src-minisql-protocol-messages-ml-2129148192"></a>
### ping

```ml
function ping(requestId)
```

Implements ping for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L202)

<a id="function-function-minisql-protocol-messages-query-function-query-requestid-sqltext-src-minisql-protocol-messages-ml-1391583963"></a>
### query

```ml
function query(requestId, sqlText)
```

Implements query for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestId` | `dynamic` | — | Identifier of request. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L103)

<a id="function-function-minisql-protocol-messages-readfield-function-readfield-source-offset-src-minisql-protocol-messages-ml-95227374"></a>
### readField

```ml
function readField(source, offset)
```

Reads field using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L299)

- [minisql.protocol.messages.Response](Type-minisql-protocol-messages-response-2017586083.md) — struct
<a id="function-function-minisql-protocol-messages-responsepayloadsize-function-responsepayloadsize-response-src-minisql-protocol-messages-ml-2029113107"></a>
### responsePayloadSize

```ml
function responsePayloadSize(response)
```

Implements response payload size for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — | response value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L312)

<a id="function-function-minisql-protocol-messages-rowresponse-function-rowresponse-columns-rows-src-minisql-protocol-messages-ml-2121890052"></a>
### rowResponse

```ml
function rowResponse(columns, rows)
```

Implements row response for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columns` | `dynamic` | — | columns value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L248)

<a id="function-function-minisql-protocol-messages-stringbytes-function-stringbytes-value-src-minisql-protocol-messages-ml-1925143493"></a>
### stringBytes

```ml
function stringBytes(value)
```

Implements string bytes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L266)

<a id="function-function-minisql-protocol-messages-targetmilestone-function-targetmilestone-src-minisql-protocol-messages-ml-545061446"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql protocol messages module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L420)

<a id="function-function-minisql-protocol-messages-writefield-function-writefield-output-offset-value-src-minisql-protocol-messages-ml-87717419"></a>
### writeField

```ml
function writeField(output, offset, value)
```

Writes field using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — | Output collection or buffer populated by the operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L286)
