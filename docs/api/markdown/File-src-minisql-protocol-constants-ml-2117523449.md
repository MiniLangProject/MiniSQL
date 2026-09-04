# `src/minisql/protocol/constants.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql protocol constants facilities for this project.

Package: [`minisql.protocol.constants`](Package-minisql-protocol-constants-26937015.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-protocol-constants-componentname-function-componentname-src-minisql-protocol-constants-ml-81540478"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql protocol constants module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L79)

<a id="constant-constant-minisql-protocol-constants-default-result-batch-rows-const-default-result-batch-rows-512-src-minisql-protocol-constants-ml-2071445395"></a>
### DEFAULT_RESULT_BATCH_ROWS

```ml
const DEFAULT_RESULT_BATCH_ROWS = 512
```

Defines the default result batch rows constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L24)

<a id="constant-constant-minisql-protocol-constants-flag-more-const-flag-more-2-src-minisql-protocol-constants-ml-1665571505"></a>
### FLAG_MORE

```ml
const FLAG_MORE = 2
```

Indicates that another response frame with the same request identifier follows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L28)

<a id="constant-constant-minisql-protocol-constants-flag-secure-const-flag-secure-1-src-minisql-protocol-constants-ml-397117812"></a>
### FLAG_SECURE

```ml
const FLAG_SECURE = 1
```

Defines the flag secure constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L26)

<a id="constant-constant-minisql-protocol-constants-header-bytes-const-header-bytes-32-src-minisql-protocol-constants-ml-920514532"></a>
### HEADER_BYTES

```ml
const HEADER_BYTES = 32
```

Defines the header bytes constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L14)

<a id="constant-constant-minisql-protocol-constants-header-crc-offset-const-header-crc-offset-24-src-minisql-protocol-constants-ml-1693211427"></a>
### HEADER_CRC_OFFSET

```ml
const HEADER_CRC_OFFSET = 24
```

Defines the header crc offset constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L16)

<a id="function-function-minisql-protocol-constants-isimplemented-function-isimplemented-src-minisql-protocol-constants-ml-1968317862"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql protocol constants module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L93)

<a id="function-function-minisql-protocol-constants-knowntype-function-knowntype-value-src-minisql-protocol-constants-ml-863333081"></a>
### knownType

```ml
function knownType(value)
```

Implements known type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L72)

<a id="constant-constant-minisql-protocol-constants-max-columns-const-max-columns-1024-src-minisql-protocol-constants-ml-1223641142"></a>
### MAX_COLUMNS

```ml
const MAX_COLUMNS = 1024
```

Defines the max columns constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L20)

<a id="constant-constant-minisql-protocol-constants-max-payload-bytes-const-max-payload-bytes-16777216-src-minisql-protocol-constants-ml-1088482570"></a>
### MAX_PAYLOAD_BYTES

```ml
const MAX_PAYLOAD_BYTES = 16777216
```

Hard framing guard for one exceptionally wide SQL value or SQL statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L18)

<a id="constant-constant-minisql-protocol-constants-max-rows-per-message-const-max-rows-per-message-512-src-minisql-protocol-constants-ml-1911334937"></a>
### MAX_ROWS_PER_MESSAGE

```ml
const MAX_ROWS_PER_MESSAGE = 512
```

Defines the max rows per message constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L22)

<a id="constant-constant-minisql-protocol-constants-max-secure-plaintext-bytes-const-max-secure-plaintext-bytes-max-payload-bytes-secure-overhead-bytes-src-minisql-protocol-constants-ml-212271135"></a>
### MAX_SECURE_PLAINTEXT_BYTES

```ml
const MAX_SECURE_PLAINTEXT_BYTES = MAX_PAYLOAD_BYTES - SECURE_OVERHEAD_BYTES
```

Defines the max secure plaintext bytes constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L32)

<a id="constant-constant-minisql-protocol-constants-protocol-magic-const-protocol-magic-msql-src-minisql-protocol-constants-ml-1531342008"></a>
### PROTOCOL_MAGIC

```ml
const PROTOCOL_MAGIC = "MSQL"
```

Defines the protocol magic identifier used on every MiniSQL wire frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L10)

<a id="constant-constant-minisql-protocol-constants-protocol-version-const-protocol-version-1-src-minisql-protocol-constants-ml-1607471492"></a>
### PROTOCOL_VERSION

```ml
const PROTOCOL_VERSION = 1
```

Defines the protocol version constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L12)

<a id="constant-constant-minisql-protocol-constants-secure-overhead-bytes-const-secure-overhead-bytes-24-src-minisql-protocol-constants-ml-1144830159"></a>
### SECURE_OVERHEAD_BYTES

```ml
const SECURE_OVERHEAD_BYTES = 24
```

Defines the secure overhead bytes constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L30)

<a id="constant-constant-minisql-protocol-constants-status-command-const-status-command-1-src-minisql-protocol-constants-ml-998580638"></a>
### STATUS_COMMAND

```ml
const STATUS_COMMAND = 1
```

Defines the status command constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L62)

<a id="constant-constant-minisql-protocol-constants-status-error-const-status-error-3-src-minisql-protocol-constants-ml-667005958"></a>
### STATUS_ERROR

```ml
const STATUS_ERROR = 3
```

Defines the status error constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L66)

<a id="constant-constant-minisql-protocol-constants-status-rows-const-status-rows-2-src-minisql-protocol-constants-ml-2046826845"></a>
### STATUS_ROWS

```ml
const STATUS_ROWS = 2
```

Defines the status rows constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L64)

<a id="constant-constant-minisql-protocol-constants-target-result-frame-bytes-const-target-result-frame-bytes-1048576-secure-overhead-bytes-src-minisql-protocol-constants-ml-1795813315"></a>
### TARGET_RESULT_FRAME_BYTES

```ml
const TARGET_RESULT_FRAME_BYTES = 1048576 - SECURE_OVERHEAD_BYTES
```

Preferred response payload size used for backpressure-friendly batching.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L34)

<a id="function-function-minisql-protocol-constants-targetmilestone-function-targetmilestone-src-minisql-protocol-constants-ml-1084465700"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql protocol constants module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L86)

<a id="constant-constant-minisql-protocol-constants-type-auth-begin-const-type-auth-begin-5-src-minisql-protocol-constants-ml-1380817360"></a>
### TYPE_AUTH_BEGIN

```ml
const TYPE_AUTH_BEGIN = 5
```

Defines the type auth begin constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L45)

<a id="constant-constant-minisql-protocol-constants-type-auth-challenge-const-type-auth-challenge-6-src-minisql-protocol-constants-ml-1564149625"></a>
### TYPE_AUTH_CHALLENGE

```ml
const TYPE_AUTH_CHALLENGE = 6
```

Defines the type auth challenge constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L47)

<a id="constant-constant-minisql-protocol-constants-type-auth-ok-const-type-auth-ok-8-src-minisql-protocol-constants-ml-813839781"></a>
### TYPE_AUTH_OK

```ml
const TYPE_AUTH_OK = 8
```

Defines the type auth ok constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L51)

<a id="constant-constant-minisql-protocol-constants-type-auth-proof-const-type-auth-proof-7-src-minisql-protocol-constants-ml-295309054"></a>
### TYPE_AUTH_PROOF

```ml
const TYPE_AUTH_PROOF = 7
```

Defines the type auth proof constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L49)

<a id="constant-constant-minisql-protocol-constants-type-cancel-const-type-cancel-9-src-minisql-protocol-constants-ml-696391004"></a>
### TYPE_CANCEL

```ml
const TYPE_CANCEL = 9
```

Administrative request that cooperatively cancels another session's query.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L53)

<a id="constant-constant-minisql-protocol-constants-type-close-const-type-close-4-src-minisql-protocol-constants-ml-1516115895"></a>
### TYPE_CLOSE

```ml
const TYPE_CLOSE = 4
```

Defines the type close constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L43)

<a id="constant-constant-minisql-protocol-constants-type-error-const-type-error-102-src-minisql-protocol-constants-ml-383791990"></a>
### TYPE_ERROR

```ml
const TYPE_ERROR = 102
```

Defines the type error constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L59)

<a id="constant-constant-minisql-protocol-constants-type-hello-const-type-hello-1-src-minisql-protocol-constants-ml-487702100"></a>
### TYPE_HELLO

```ml
const TYPE_HELLO = 1
```

Defines the type hello constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L37)

<a id="constant-constant-minisql-protocol-constants-type-ping-const-type-ping-3-src-minisql-protocol-constants-ml-1271965598"></a>
### TYPE_PING

```ml
const TYPE_PING = 3
```

Defines the type ping constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L41)

<a id="constant-constant-minisql-protocol-constants-type-pong-const-type-pong-101-src-minisql-protocol-constants-ml-1972033923"></a>
### TYPE_PONG

```ml
const TYPE_PONG = 101
```

Defines the type pong constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L57)

<a id="constant-constant-minisql-protocol-constants-type-query-const-type-query-2-src-minisql-protocol-constants-ml-512817589"></a>
### TYPE_QUERY

```ml
const TYPE_QUERY = 2
```

Defines the type query constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L39)

<a id="constant-constant-minisql-protocol-constants-type-response-const-type-response-100-src-minisql-protocol-constants-ml-1293345052"></a>
### TYPE_RESPONSE

```ml
const TYPE_RESPONSE = 100
```

Defines the type response constant used by the minisql protocol constants module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/constants.ml#L55)
