# `minisql.protocol.messages.Response`

[Home](README.md) · [Source file](File-src-minisql-protocol-messages-ml-1580707356.md)

<a id="struct-struct-minisql-protocol-messages-response-struct-response-src-minisql-protocol-messages-ml-1145692077"></a>
## Response

```ml
struct Response
```

Groups the response state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L30)

## Members

<a id="field-field-minisql-protocol-messages-response-affectedrows-affectedrows-src-minisql-protocol-messages-ml-231502390"></a>
### affectedRows

```ml
affectedRows
```

Stores the affected rows associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L40)

<a id="field-field-minisql-protocol-messages-response-columns-columns-src-minisql-protocol-messages-ml-1224008536"></a>
### columns

```ml
columns
```

Contains the ordered columns collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L36)

<a id="field-field-minisql-protocol-messages-response-command-command-src-minisql-protocol-messages-ml-1465813600"></a>
### command

```ml
command
```

Stores the command associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L34)

<a id="field-field-minisql-protocol-messages-response-errorcode-errorcode-src-minisql-protocol-messages-ml-2051580156"></a>
### errorCode

```ml
errorCode
```

Stores the error code associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L44)

<a id="field-field-minisql-protocol-messages-response-message-message-src-minisql-protocol-messages-ml-294664752"></a>
### message

```ml
message
```

Stores the message associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L42)

<a id="field-field-minisql-protocol-messages-response-rows-rows-src-minisql-protocol-messages-ml-1427345386"></a>
### rows

```ml
rows
```

Contains the ordered rows collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L38)

<a id="field-field-minisql-protocol-messages-response-status-status-src-minisql-protocol-messages-ml-1948842184"></a>
### status

```ml
status
```

Stores the status associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L32)
