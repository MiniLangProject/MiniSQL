# `minisql.client.client.Client`

[Home](README.md) · [Source file](File-src-minisql-client-client-ml-193935498.md)

<a id="struct-struct-minisql-client-client-client-struct-client-src-minisql-client-client-ml-393640017"></a>
## Client

```ml
struct Client
```

Groups the client state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L25)

## Members

<a id="field-field-minisql-client-client-client-activequery-activequery-src-minisql-client-client-ml-1831528504"></a>
### activeQuery

```ml
activeQuery
```

Forward-only query cursor currently owning the protocol response stream.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L37)

<a id="field-field-minisql-client-client-client-authenticated-authenticated-src-minisql-client-client-ml-1277780000"></a>
### authenticated

```ml
authenticated
```

Indicates whether the authenticated condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L33)

<a id="field-field-minisql-client-client-client-closed-closed-src-minisql-client-client-ml-559592872"></a>
### closed

```ml
closed
```

Indicates whether the closed condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L31)

<a id="field-field-minisql-client-client-client-connection-connection-src-minisql-client-client-ml-1662967272"></a>
### connection

```ml
connection
```

Stores the connection associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L27)

<a id="field-field-minisql-client-client-client-nextrequestid-nextrequestid-src-minisql-client-client-ml-198977112"></a>
### nextRequestId

```ml
nextRequestId
```

Tracks the next request identifier numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L29)

<a id="field-field-minisql-client-client-client-username-username-src-minisql-client-client-ml-951122664"></a>
### username

```ml
username
```

Stores the username associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L35)
