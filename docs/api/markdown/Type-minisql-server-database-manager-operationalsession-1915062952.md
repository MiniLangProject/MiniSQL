# `minisql.server.database_manager.OperationalSession`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-operationalsession-struct-operationalsession-src-minisql-server-database-manager-ml-718651097"></a>
## OperationalSession

```ml
struct OperationalSession
```

Mutable process-list entry protected by the database execution-state lock.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L53)

## Members

<a id="field-field-minisql-server-database-manager-operationalsession-cancelrequested-cancelrequested-src-minisql-server-database-manager-ml-1379913021"></a>
### cancelRequested

```ml
cancelRequested
```

Cooperatively asks the executor owning this session to stop at its next poll.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L75)

<a id="field-field-minisql-server-database-manager-operationalsession-createdat-createdat-src-minisql-server-database-manager-ml-1246861105"></a>
### createdAt

```ml
createdAt
```

Monotonic connection creation time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L63)

<a id="field-field-minisql-server-database-manager-operationalsession-lastactivity-lastactivity-src-minisql-server-database-manager-ml-141647183"></a>
### lastActivity

```ml
lastActivity
```

Monotonic time of the most recent request transition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L65)

<a id="field-field-minisql-server-database-manager-operationalsession-peerendpoint-peerendpoint-src-minisql-server-database-manager-ml-1544493439"></a>
### peerEndpoint

```ml
peerEndpoint
```

Remote endpoint or the literal "embedded" for local API users.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L57)

<a id="field-field-minisql-server-database-manager-operationalsession-principalid-principalid-src-minisql-server-database-manager-ml-232401217"></a>
### principalId

```ml
principalId
```

Current authenticated principal identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L61)

<a id="field-field-minisql-server-database-manager-operationalsession-requestcount-requestcount-src-minisql-server-database-manager-ml-1324123645"></a>
### requestCount

```ml
requestCount
```

Number of statements completed by this session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L73)

<a id="field-field-minisql-server-database-manager-operationalsession-secure-secure-src-minisql-server-database-manager-ml-1767351563"></a>
### secure

```ml
secure
```

Indicates whether native TLS protects the connection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L59)

<a id="field-field-minisql-server-database-manager-operationalsession-sessionid-sessionid-src-minisql-server-database-manager-ml-1227573241"></a>
### sessionId

```ml
sessionId
```

Stable identifier allocated with the executor engine.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L55)

<a id="field-field-minisql-server-database-manager-operationalsession-state-state-src-minisql-server-database-manager-ml-922079065"></a>
### state

```ml
state
```

Human-readable connection state such as IDLE or EXECUTING.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L71)

<a id="field-field-minisql-server-database-manager-operationalsession-statementstartedat-statementstartedat-src-minisql-server-database-manager-ml-858685703"></a>
### statementStartedAt

```ml
statementStartedAt
```

Monotonic start time of the active statement, or zero while idle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L67)

<a id="field-field-minisql-server-database-manager-operationalsession-statementtext-statementtext-src-minisql-server-database-manager-ml-1101691477"></a>
### statementText

```ml
statementText
```

Bounded statement summary suitable for an administrative process list.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L69)
