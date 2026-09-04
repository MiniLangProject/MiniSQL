# `src/minisql/client/formatter.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql client formatter facilities for this project.

Package: [`minisql.client.formatter`](Package-minisql-client-formatter-1915397479.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/executor/executor.ml` as `executor` → [src/minisql/executor/executor.ml](File-src-minisql-executor-executor-ml-1548110730.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency
- `std/string_builder.ml` as `string_builder` → `../MiniLangCompilerML/std/string_builder.ml` — external dependency

## Declarations

<a id="function-function-minisql-client-formatter-componentname-function-componentname-src-minisql-client-formatter-ml-1424201070"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql client formatter module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L140)

<a id="function-function-minisql-client-formatter-fail-function-fail-operation-message-src-minisql-client-formatter-ml-1783362182"></a>
### fail

```ml
function fail(operation, message)
```

Performs the fail operation for the minisql client formatter module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L25)

<a id="function-function-minisql-client-formatter-formatresponse-function-formatresponse-response-src-minisql-client-formatter-ml-1721415347"></a>
### formatResponse

```ml
function formatResponse(response)
```

Formats response using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — | response value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L112)

<a id="constant-constant-minisql-client-formatter-invalid-argument-const-invalid-argument-9001-src-minisql-client-formatter-ml-1234415967"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql client formatter module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L18)

<a id="function-function-minisql-client-formatter-isimplemented-function-isimplemented-src-minisql-client-formatter-ml-1855313398"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql client formatter module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L154)

<a id="function-function-minisql-client-formatter-responsefromresult-function-responsefromresult-result-src-minisql-client-formatter-ml-1767604357"></a>
### responseFromResult

```ml
function responseFromResult(result)
```

Implements response from result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L56)

<a id="function-function-minisql-client-formatter-responsesfromresult-function-responsesfromresult-result-src-minisql-client-formatter-ml-332183251"></a>
### responsesFromResult

```ml
function responsesFromResult(result)
```

Converts a query result into bounded protocol responses. Row conversion and payload construction are limited to one transport batch at a time, avoiding the former second full-result string representation on the server heap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L79)

<a id="function-function-minisql-client-formatter-targetmilestone-function-targetmilestone-src-minisql-client-formatter-ml-1425316000"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql client formatter module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L147)

<a id="function-function-minisql-client-formatter-valuetext-function-valuetext-value-src-minisql-client-formatter-ml-290748291"></a>
### valueText

```ml
function valueText(value)
```

Implements value text for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/formatter.ml#L34)
