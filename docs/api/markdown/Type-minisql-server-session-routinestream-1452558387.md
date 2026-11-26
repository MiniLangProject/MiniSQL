# `minisql.server.session.RoutineStream`

[Home](README.md) · [Source file](File-src-minisql-server-session-ml-1747510267.md)

<a id="struct-struct-minisql-server-session-routinestream-struct-routinestream-src-minisql-server-session-ml-1762253581"></a>
## RoutineStream

```ml
struct RoutineStream
```

State owned by one synchronously streamed CALL while its executor runs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L85)

## Members

<a id="field-field-minisql-server-session-routinestream-connection-connection-src-minisql-server-session-ml-1113009963"></a>
### connection

```ml
connection
```

Connection receiving frames with transport backpressure.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L91)

<a id="field-field-minisql-server-session-routinestream-frames-frames-src-minisql-server-session-ml-675431643"></a>
### frames

```ml
frames
```

Number of row frames already sent; prevents unsafe whole-CALL retries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L93)

<a id="field-field-minisql-server-session-routinestream-request-request-src-minisql-server-session-ml-1553543575"></a>
### request

```ml
request
```

Original request, including negotiated metadata flag and request identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L89)

<a id="field-field-minisql-server-session-routinestream-resultcomplete-resultcomplete-src-minisql-server-session-ml-202848767"></a>
### resultComplete

```ml
resultComplete
```

True when the latest logical row result has completed successfully.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L97)

<a id="field-field-minisql-server-session-routinestream-rows-rows-src-minisql-server-session-ml-898598861"></a>
### rows

```ml
rows
```

Accumulated emitted row count across all result sets.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L95)

<a id="field-field-minisql-server-session-routinestream-session-session-src-minisql-server-session-ml-869535359"></a>
### session

```ml
session
```

Server session owning accounting, diagnostics, and resource limits.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L87)

<a id="field-field-minisql-server-session-routinestream-transportfailed-transportfailed-src-minisql-server-session-ml-1787819851"></a>
### transportFailed

```ml
transportFailed
```

True after an I/O failure makes a terminal response unsafe.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L99)
