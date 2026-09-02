# `minisql.server.listener.ConcurrentClientTask`

[Home](README.md) · [Source file](File-src-minisql-server-listener-ml-548170303.md)

<a id="struct-struct-minisql-server-listener-concurrentclienttask-struct-concurrentclienttask-src-minisql-server-listener-ml-1193034339"></a>
## ConcurrentClientTask

```ml
struct ConcurrentClientTask
```

Immutable argument bundle submitted to one thread-pool worker.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L305)

## Members

<a id="field-field-minisql-server-listener-concurrentclienttask-lockwaitms-lockwaitms-src-minisql-server-listener-ml-729619910"></a>
### lockWaitMs

```ml
lockWaitMs
```

Maximum logical-lock retry duration in milliseconds.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L311)

<a id="field-field-minisql-server-listener-concurrentclienttask-slot-slot-src-minisql-server-listener-ml-1332172506"></a>
### slot

```ml
slot
```

Connection/session pair exclusively owned by the worker.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L307)

<a id="field-field-minisql-server-listener-concurrentclienttask-state-state-src-minisql-server-listener-ml-1148592402"></a>
### state

```ml
state
```

Shared, guard-protected server accounting.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L309)

<a id="field-field-minisql-server-listener-concurrentclienttask-tlscredential-tlscredential-src-minisql-server-listener-ml-189930822"></a>
### tlsCredential

```ml
tlsCredential
```

Shared inbound Schannel credential, or void for a non-TLS listener.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L313)
