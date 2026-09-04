# `minisql.server.session.Session`

[Home](README.md) · [Source file](File-src-minisql-server-session-ml-1747510267.md)

<a id="struct-struct-minisql-server-session-session-struct-session-src-minisql-server-session-ml-2145851477"></a>
## Session

```ml
struct Session
```

Groups the session state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L43)

## Members

<a id="field-field-minisql-server-session-session-attempts-attempts-src-minisql-server-session-ml-701775775"></a>
### attempts

```ml
attempts
```

Stores the attempts associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L63)

<a id="field-field-minisql-server-session-session-authenticated-authenticated-src-minisql-server-session-ml-328360343"></a>
### authenticated

```ml
authenticated
```

Indicates whether the authenticated condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L53)

<a id="field-field-minisql-server-session-session-closed-closed-src-minisql-server-session-ml-1865297271"></a>
### closed

```ml
closed
```

Indicates whether the closed condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L47)

<a id="field-field-minisql-server-session-session-closerequested-closerequested-src-minisql-server-session-ml-1540294359"></a>
### closeRequested

```ml
closeRequested
```

Stores the close requested associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L49)

<a id="field-field-minisql-server-session-session-createdat-createdat-src-minisql-server-session-ml-625964307"></a>
### createdAt

```ml
createdAt
```

Stores the created at associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L71)

<a id="field-field-minisql-server-session-session-engine-engine-src-minisql-server-session-ml-375616663"></a>
### engine

```ml
engine
```

Stores the engine associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L45)

<a id="field-field-minisql-server-session-session-lastactivity-lastactivity-src-minisql-server-session-ml-1261204437"></a>
### lastActivity

```ml
lastActivity
```

Stores the last activity associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L73)

<a id="field-field-minisql-server-session-session-pendingnonce-pendingnonce-src-minisql-server-session-ml-1012511215"></a>
### pendingNonce

```ml
pendingNonce
```

Indicates whether the pending nonce condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L59)

<a id="field-field-minisql-server-session-session-pendingprincipalid-pendingprincipalid-src-minisql-server-session-ml-800731"></a>
### pendingPrincipalId

```ml
pendingPrincipalId
```

Indicates whether the pending principal identifier condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L57)

<a id="field-field-minisql-server-session-session-pendingusername-pendingusername-src-minisql-server-session-ml-2014460155"></a>
### pendingUsername

```ml
pendingUsername
```

Indicates whether the pending username condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L55)

<a id="field-field-minisql-server-session-session-pendingverifier-pendingverifier-src-minisql-server-session-ml-1231865187"></a>
### pendingVerifier

```ml
pendingVerifier
```

Indicates whether the pending verifier condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L61)

<a id="field-field-minisql-server-session-session-secure-secure-src-minisql-server-session-ml-2056680057"></a>
### secure

```ml
secure
```

Indicates whether the secure condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L51)

<a id="field-field-minisql-server-session-session-statementresultbytes-statementresultbytes-src-minisql-server-session-ml-500208733"></a>
### statementResultBytes

```ml
statementResultBytes
```

Complete encoded response bytes accumulated by the tracked statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L79)

<a id="field-field-minisql-server-session-session-statementstartedat-statementstartedat-src-minisql-server-session-ml-1367736193"></a>
### statementStartedAt

```ml
statementStartedAt
```

Monotonic timestamp at which the tracked statement began.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L77)

<a id="field-field-minisql-server-session-session-statementtracked-statementtracked-src-minisql-server-session-ml-876950641"></a>
### statementTracked

```ml
statementTracked
```

Prevents lock-wait retries from double-counting one logical statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L75)

<a id="field-field-minisql-server-session-session-transportpending-transportpending-src-minisql-server-session-ml-805964503"></a>
### transportPending

```ml
transportPending
```

Stores the transport pending associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L69)

<a id="field-field-minisql-server-session-session-transportreceivekey-transportreceivekey-src-minisql-server-session-ml-1475105455"></a>
### transportReceiveKey

```ml
transportReceiveKey
```

Stores the transport receive key associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L67)

<a id="field-field-minisql-server-session-session-transportsendkey-transportsendkey-src-minisql-server-session-ml-2066473451"></a>
### transportSendKey

```ml
transportSendKey
```

Stores the transport send key associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L65)
