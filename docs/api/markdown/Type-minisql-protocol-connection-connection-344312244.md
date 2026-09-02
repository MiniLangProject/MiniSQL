# `minisql.protocol.connection.Connection`

[Home](README.md) · [Source file](File-src-minisql-protocol-connection-ml-870021768.md)

<a id="struct-struct-minisql-protocol-connection-connection-struct-connection-src-minisql-protocol-connection-ml-809690549"></a>
## Connection

```ml
struct Connection
```

Owns framed-protocol state for one TCP socket. Receive buffering permits fragmented and coalesced frames; secure sequence counters must advance exactly once per authenticated frame to prevent replay or reordering.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L28)

## Members

<a id="field-field-minisql-protocol-connection-connection-bytesreceived-bytesreceived-src-minisql-protocol-connection-ml-1371061553"></a>
### bytesReceived

```ml
bytesReceived
```

Framed protocol bytes obtained from the transport.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L56)

<a id="field-field-minisql-protocol-connection-connection-bytessent-bytessent-src-minisql-protocol-connection-ml-2074676557"></a>
### bytesSent

```ml
bytesSent
```

Framed protocol bytes successfully handed to the transport.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L54)

<a id="field-field-minisql-protocol-connection-connection-closed-closed-src-minisql-protocol-connection-ml-1989738621"></a>
### closed

```ml
closed
```

Prevents operations and duplicate cleanup after close.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L32)

<a id="field-field-minisql-protocol-connection-connection-peerclosed-peerclosed-src-minisql-protocol-connection-ml-1172390969"></a>
### peerClosed

```ml
peerClosed
```

Records a clean zero-byte receive from the peer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L38)

<a id="field-field-minisql-protocol-connection-connection-receivebuffer-receivebuffer-src-minisql-protocol-connection-ml-1521958917"></a>
### receiveBuffer

```ml
receiveBuffer
```

Unconsumed bytes that may contain partial or multiple frames.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L34)

<a id="field-field-minisql-protocol-connection-connection-receivekey-receivekey-src-minisql-protocol-connection-ml-1574132713"></a>
### receiveKey

```ml
receiveKey
```

256-bit key for inbound authenticated decryption.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L44)

<a id="field-field-minisql-protocol-connection-connection-receivescratch-receivescratch-src-minisql-protocol-connection-ml-664925799"></a>
### receiveScratch

```ml
receiveScratch
```

Fixed-capacity buffer reused by nonblocking receives.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L36)

<a id="field-field-minisql-protocol-connection-connection-receivesequence-receivesequence-src-minisql-protocol-connection-ml-246762829"></a>
### receiveSequence

```ml
receiveSequence
```

Only sequence number accepted for the next inbound secure frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L48)

<a id="field-field-minisql-protocol-connection-connection-secure-secure-src-minisql-protocol-connection-ml-1370613211"></a>
### secure

```ml
secure
```

Requires every subsequent payload to use authenticated transport protection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L40)

<a id="field-field-minisql-protocol-connection-connection-sendkey-sendkey-src-minisql-protocol-connection-ml-547948001"></a>
### sendKey

```ml
sendKey
```

256-bit key for outbound authenticated encryption.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L42)

<a id="field-field-minisql-protocol-connection-connection-sendsequence-sendsequence-src-minisql-protocol-connection-ml-1743459027"></a>
### sendSequence

```ml
sendSequence
```

Sequence number bound into the next outbound secure frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L46)

<a id="field-field-minisql-protocol-connection-connection-socket-socket-src-minisql-protocol-connection-ml-146483127"></a>
### socket

```ml
socket
```

Native socket handle owned until `close`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L30)

<a id="field-field-minisql-protocol-connection-connection-tls-tls-src-minisql-protocol-connection-ml-1175102969"></a>
### tls

```ml
tls
```

Indicates that native TLS record protection is active below framing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L50)

<a id="field-field-minisql-protocol-connection-connection-tlscontext-tlscontext-src-minisql-protocol-connection-ml-829074745"></a>
### tlsContext

```ml
tlsContext
```

Schannel context that owns TLS keys and encrypted record buffers.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/connection.ml#L52)
