# Package `minisql.protocol.messages`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)

## Symbols

- [`minisql.protocol.messages.authBegin`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-authbegin-function-authbegin-requestid-username-src-minisql-protocol-messages-ml-861127374) — function
- [`minisql.protocol.messages.authChallenge`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-authchallenge-function-authchallenge-requestid-iterations-salt-nonce-scheme-src-minisql-protocol-messages-ml-728051046) — function
- [`minisql.protocol.messages.authOk`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-authok-function-authok-requestid-serverproof-src-minisql-protocol-messages-ml-1072171503) — function
- [`minisql.protocol.messages.authProof`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-authproof-function-authproof-requestid-proof-src-minisql-protocol-messages-ml-2129408958) — function
- [`minisql.protocol.messages.cancelRequest`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-cancelrequest-function-cancelrequest-requestid-sessionid-src-minisql-protocol-messages-ml-599710079) — function
- [`minisql.protocol.messages.closeRequest`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-closerequest-function-closerequest-requestid-src-minisql-protocol-messages-ml-29415648) — function
- [`minisql.protocol.messages.commandResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-commandresponse-function-commandresponse-command-affectedrows-message-src-minisql-protocol-messages-ml-1660127651) — function
- [`minisql.protocol.messages.componentName`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-componentname-function-componentname-src-minisql-protocol-messages-ml-1860101052) — function
- [`minisql.protocol.messages.CORRUPT_DATA`](File-src-minisql-protocol-messages-ml-1580707356.md#constant-constant-minisql-protocol-messages-corrupt-data-const-corrupt-data-9004-src-minisql-protocol-messages-ml-1538552720) — constant
- [`minisql.protocol.messages.create`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-create-function-create-messagetype-flags-requestid-payload-src-minisql-protocol-messages-ml-623699612) — function
- [`minisql.protocol.messages.decodeAuthBegin`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-decodeauthbegin-function-decodeauthbegin-payload-src-minisql-protocol-messages-ml-1797547444) — function
- [`minisql.protocol.messages.decodeAuthChallenge`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-decodeauthchallenge-function-decodeauthchallenge-payload-src-minisql-protocol-messages-ml-940584592) — function
- [`minisql.protocol.messages.decodeCancelRequest`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-decodecancelrequest-function-decodecancelrequest-payload-src-minisql-protocol-messages-ml-316471780) — function
- [`minisql.protocol.messages.decodeResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-decoderesponse-function-decoderesponse-source-src-minisql-protocol-messages-ml-1712650805) — function
- [`minisql.protocol.messages.encodeResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-encoderesponse-function-encoderesponse-response-src-minisql-protocol-messages-ml-1522164307) — function
- [`minisql.protocol.messages.errorResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-errorresponse-function-errorresponse-code-message-src-minisql-protocol-messages-ml-459743622) — function
- [`minisql.protocol.messages.fail`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-fail-function-fail-code-operation-message-src-minisql-protocol-messages-ml-2129809533) — function
- [`minisql.protocol.messages.fieldSize`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-fieldsize-function-fieldsize-value-src-minisql-protocol-messages-ml-899695487) — function
- [`minisql.protocol.messages.hello`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-hello-function-hello-requestid-src-minisql-protocol-messages-ml-556219208) — function
- [`minisql.protocol.messages.INVALID_ARGUMENT`](File-src-minisql-protocol-messages-ml-1580707356.md#constant-constant-minisql-protocol-messages-invalid-argument-const-invalid-argument-9001-src-minisql-protocol-messages-ml-749605079) — constant
- [`minisql.protocol.messages.isImplemented`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-isimplemented-function-isimplemented-src-minisql-protocol-messages-ml-306399572) — function
- [`minisql.protocol.messages.isMessage`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-ismessage-function-ismessage-value-src-minisql-protocol-messages-ml-1923200535) — function
- [`minisql.protocol.messages.isResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-isresponse-function-isresponse-value-src-minisql-protocol-messages-ml-1298240945) — function
- [`minisql.protocol.messages.Message`](Type-minisql-protocol-messages-message-1836948963.md) — struct
- [`minisql.protocol.messages.ping`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-ping-function-ping-requestid-src-minisql-protocol-messages-ml-2129148192) — function
- [`minisql.protocol.messages.query`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-query-function-query-requestid-sqltext-src-minisql-protocol-messages-ml-1391583963) — function
- [`minisql.protocol.messages.readField`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-readfield-function-readfield-source-offset-src-minisql-protocol-messages-ml-95227374) — function
- [`minisql.protocol.messages.Response`](Type-minisql-protocol-messages-response-2017586083.md) — struct
- [`minisql.protocol.messages.responsePayloadSize`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-responsepayloadsize-function-responsepayloadsize-response-src-minisql-protocol-messages-ml-2029113107) — function
- [`minisql.protocol.messages.rowResponse`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-rowresponse-function-rowresponse-columns-rows-src-minisql-protocol-messages-ml-2121890052) — function
- [`minisql.protocol.messages.stringBytes`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-stringbytes-function-stringbytes-value-src-minisql-protocol-messages-ml-1925143493) — function
- [`minisql.protocol.messages.targetMilestone`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-targetmilestone-function-targetmilestone-src-minisql-protocol-messages-ml-545061446) — function
- [`minisql.protocol.messages.writeField`](File-src-minisql-protocol-messages-ml-1580707356.md#function-function-minisql-protocol-messages-writefield-function-writefield-output-offset-value-src-minisql-protocol-messages-ml-87717419) — function
