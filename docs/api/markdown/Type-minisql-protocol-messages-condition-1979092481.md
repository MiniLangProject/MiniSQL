# `minisql.protocol.messages.Condition`

[Home](README.md) · [Source file](File-src-minisql-protocol-messages-ml-1580707356.md)

<a id="struct-struct-minisql-protocol-messages-condition-struct-condition-src-minisql-protocol-messages-ml-1080285569"></a>
## Condition

```ml
struct Condition
```

One structured SQL condition, independent of localized message text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L52)

## Members

<a id="field-field-minisql-protocol-messages-condition-code-code-src-minisql-protocol-messages-ml-13527920"></a>
### code

```ml
code
```

Condition error number, including application MYSQL_ERRNO values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L56)

<a id="field-field-minisql-protocol-messages-condition-message-message-src-minisql-protocol-messages-ml-194106450"></a>
### message

```ml
message
```

Human-readable diagnostic text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L58)

<a id="field-field-minisql-protocol-messages-condition-sqlstate-sqlstate-src-minisql-protocol-messages-ml-1715903816"></a>
### sqlState

```ml
sqlState
```

Five-character SQLSTATE.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L54)
