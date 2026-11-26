# `minisql.protocol.messages.OutputParameter`

[Home](README.md) · [Source file](File-src-minisql-protocol-messages-ml-1580707356.md)

<a id="struct-struct-minisql-protocol-messages-outputparameter-struct-outputparameter-src-minisql-protocol-messages-ml-177034559"></a>
## OutputParameter

```ml
struct OutputParameter
```

One successful outer CALL output, identified by declaration ordinal.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L62)

## Members

<a id="field-field-minisql-protocol-messages-outputparameter-isnull-isnull-src-minisql-protocol-messages-ml-1197757351"></a>
### isNull

```ml
isNull
```

Distinguishes SQL NULL from the literal text NULL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L70)

<a id="field-field-minisql-protocol-messages-outputparameter-name-name-src-minisql-protocol-messages-ml-504755251"></a>
### name

```ml
name
```

Parameter name from the routine declaration.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L66)

<a id="field-field-minisql-protocol-messages-outputparameter-ordinal-ordinal-src-minisql-protocol-messages-ml-802275349"></a>
### ordinal

```ml
ordinal
```

One-based parameter declaration position.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L64)

<a id="field-field-minisql-protocol-messages-outputparameter-typekind-typekind-src-minisql-protocol-messages-ml-458709973"></a>
### typeKind

```ml
typeKind
```

Native SqlTypeKind code from zero through sixteen.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L68)

<a id="field-field-minisql-protocol-messages-outputparameter-value-value-src-minisql-protocol-messages-ml-368517105"></a>
### value

```ml
value
```

Canonical textual value; empty for SQL NULL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/messages.ml#L72)
