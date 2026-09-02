# `minisql.config.model.ServerConfig`

[Home](README.md) · [Source file](File-src-minisql-config-model-ml-1120384851.md)

<a id="struct-struct-minisql-config-model-serverconfig-struct-serverconfig-src-minisql-config-model-ml-748884883"></a>
## ServerConfig

```ml
struct ServerConfig
```

Groups the server config state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L18)

## Members

<a id="field-field-minisql-config-model-serverconfig-bindaddress-bindaddress-src-minisql-config-model-ml-431573004"></a>
### bindAddress

```ml
bindAddress
```

Stores the bind address associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L20)

<a id="field-field-minisql-config-model-serverconfig-idletimeoutms-idletimeoutms-src-minisql-config-model-ml-312974048"></a>
### idleTimeoutMs

```ml
idleTimeoutMs
```

Disconnects inactive clients after this many milliseconds.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L34)

<a id="field-field-minisql-config-model-serverconfig-maxconnections-maxconnections-src-minisql-config-model-ml-1243267766"></a>
### maxConnections

```ml
maxConnections
```

Stores the max connections associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L24)

<a id="field-field-minisql-config-model-serverconfig-maxframebytes-maxframebytes-src-minisql-config-model-ml-2004772328"></a>
### maxFrameBytes

```ml
maxFrameBytes
```

Tracks the max frame bytes numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L28)

<a id="field-field-minisql-config-model-serverconfig-maxresultbytes-maxresultbytes-src-minisql-config-model-ml-1800387992"></a>
### maxResultBytes

```ml
maxResultBytes
```

Caps the aggregate encoded response bytes returned by one statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L32)

<a id="field-field-minisql-config-model-serverconfig-maxresultrows-maxresultrows-src-minisql-config-model-ml-36726728"></a>
### maxResultRows

```ml
maxResultRows
```

Caps rows returned by one statement before the server rejects the result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L30)

<a id="field-field-minisql-config-model-serverconfig-maxstatementbytes-maxstatementbytes-src-minisql-config-model-ml-1945360984"></a>
### maxStatementBytes

```ml
maxStatementBytes
```

Tracks the max statement bytes numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L26)

<a id="field-field-minisql-config-model-serverconfig-port-port-src-minisql-config-model-ml-58333258"></a>
### port

```ml
port
```

Tracks the port numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L22)
