# `minisql.server.listener.ClientSlot`

[Home](README.md) · [Source file](File-src-minisql-server-listener-ml-548170303.md)

<a id="struct-struct-minisql-server-listener-clientslot-struct-clientslot-src-minisql-server-listener-ml-1442688311"></a>
## ClientSlot

```ml
struct ClientSlot
```

Owns one accepted connection and its attached session for the lifetime of a worker-pool job. Only that worker mutates the slot.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L195)

## Members

<a id="field-field-minisql-server-listener-clientslot-activesession-activesession-src-minisql-server-listener-ml-1767991198"></a>
### activeSession

```ml
activeSession
```

Database session attached to the listener's shared ManagedDatabase.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L199)

<a id="field-field-minisql-server-listener-clientslot-client-client-src-minisql-server-listener-ml-1493927052"></a>
### client

```ml
client
```

Framed protocol connection used for request polling and response writes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L197)

<a id="field-field-minisql-server-listener-clientslot-closed-closed-src-minisql-server-listener-ml-437203206"></a>
### closed

```ml
closed
```

Prevents duplicate session and socket cleanup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L203)

<a id="field-field-minisql-server-listener-clientslot-handled-handled-src-minisql-server-listener-ml-1030531110"></a>
### handled

```ml
handled
```

Number of responses successfully sent for this client.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L201)

<a id="field-field-minisql-server-listener-clientslot-lastactivity-lastactivity-src-minisql-server-listener-ml-1303876244"></a>
### lastActivity

```ml
lastActivity
```

Monotonic timestamp used to enforce listener idle limits.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L209)

<a id="field-field-minisql-server-listener-clientslot-peerendpoint-peerendpoint-src-minisql-server-listener-ml-176030788"></a>
### peerEndpoint

```ml
peerEndpoint
```

Human-readable remote endpoint captured before worker ownership transfer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L211)

<a id="field-field-minisql-server-listener-clientslot-pendingrequest-pendingrequest-src-minisql-server-listener-ml-1232462790"></a>
### pendingRequest

```ml
pendingRequest
```

Request retained while its logical database lock is unavailable.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L205)

<a id="field-field-minisql-server-listener-clientslot-waitstarted-waitstarted-src-minisql-server-listener-ml-1209722518"></a>
### waitStarted

```ml
waitStarted
```

Monotonic timestamp at which the pending lock wait began.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L207)
