# `minisql.client.client.QueryCursor`

[Home](README.md) · [Source file](File-src-minisql-client-client-ml-193935498.md)

<a id="struct-struct-minisql-client-client-querycursor-struct-querycursor-src-minisql-client-client-ml-1971019415"></a>
## QueryCursor

```ml
struct QueryCursor
```

Owns one request's continuation frames. Only the current batch is exposed, allowing callers such as the GUI to render or export large results without combining every row in the MiniLang heap.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L43)

## Members

<a id="field-field-minisql-client-client-querycursor-client-client-src-minisql-client-client-ml-544795469"></a>
### client

```ml
client
```

Client whose connection supplies the response frames.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L45)

<a id="field-field-minisql-client-client-querycursor-columns-columns-src-minisql-client-client-ml-989375487"></a>
### columns

```ml
columns
```

Column schema established by the first row frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L49)

<a id="field-field-minisql-client-client-querycursor-finished-finished-src-minisql-client-client-ml-1521147323"></a>
### finished

```ml
finished
```

True after the frame without FLAG_MORE has been consumed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L51)

<a id="field-field-minisql-client-client-querycursor-requestid-requestid-src-minisql-client-client-ml-864496843"></a>
### requestId

```ml
requestId
```

Request identifier repeated by every continuation frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/client.ml#L47)
