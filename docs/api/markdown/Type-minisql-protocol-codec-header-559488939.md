# `minisql.protocol.codec.Header`

[Home](README.md) · [Source file](File-src-minisql-protocol-codec-ml-66075884.md)

<a id="struct-struct-minisql-protocol-codec-header-struct-header-src-minisql-protocol-codec-ml-826726723"></a>
## Header

```ml
struct Header
```

Groups the header state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L17)

## Members

<a id="field-field-minisql-protocol-codec-header-flags-flags-src-minisql-protocol-codec-ml-809485596"></a>
### flags

```ml
flags
```

Stores the flags associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L21)

<a id="field-field-minisql-protocol-codec-header-messagetype-messagetype-src-minisql-protocol-codec-ml-1569695528"></a>
### messageType

```ml
messageType
```

Stores the message type associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L19)

<a id="field-field-minisql-protocol-codec-header-payloadchecksum-payloadchecksum-src-minisql-protocol-codec-ml-570964464"></a>
### payloadChecksum

```ml
payloadChecksum
```

Stores the payload checksum associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L27)

<a id="field-field-minisql-protocol-codec-header-payloadlength-payloadlength-src-minisql-protocol-codec-ml-1659069500"></a>
### payloadLength

```ml
payloadLength
```

Tracks the payload length numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L25)

<a id="field-field-minisql-protocol-codec-header-requestid-requestid-src-minisql-protocol-codec-ml-2056050428"></a>
### requestId

```ml
requestId
```

Identifies the request identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L23)
