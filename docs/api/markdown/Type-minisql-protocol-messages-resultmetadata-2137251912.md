# `minisql.protocol.messages.ResultMetadata`

[Home](README.md) · [Source file](File-src-minisql-protocol-messages-ml-1580707356.md)

<a id="struct-struct-minisql-protocol-messages-resultmetadata-struct-resultmetadata-src-minisql-protocol-messages-ml-1230103705"></a>
## ResultMetadata

```ml
struct ResultMetadata
```

Optional response trailer negotiated through the results-v2 capability.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L76)

## Members

<a id="field-field-minisql-protocol-messages-resultmetadata-columntypes-columntypes-src-minisql-protocol-messages-ml-157343501"></a>
### columnTypes

```ml
columnTypes
```

Native column SqlTypeKind codes; zero denotes an unknown type.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L84)

<a id="field-field-minisql-protocol-messages-resultmetadata-nullbitmap-nullbitmap-src-minisql-protocol-messages-ml-228268985"></a>
### nullBitmap

```ml
nullBitmap
```

Row-major SQL NULL bits, least-significant bit first.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L82)

<a id="field-field-minisql-protocol-messages-resultmetadata-outputs-outputs-src-minisql-protocol-messages-ml-2109482553"></a>
### outputs

```ml
outputs
```

Successful outer CALL output values, emitted on its final command.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L86)

<a id="field-field-minisql-protocol-messages-resultmetadata-sqlstate-sqlstate-src-minisql-protocol-messages-ml-393241931"></a>
### sqlState

```ml
sqlState
```

Statement SQLSTATE; successful responses use 00000.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L78)

<a id="field-field-minisql-protocol-messages-resultmetadata-warnings-warnings-src-minisql-protocol-messages-ml-1047376035"></a>
### warnings

```ml
warnings
```

Ordered statement warnings, emitted on the terminal response only.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L80)
