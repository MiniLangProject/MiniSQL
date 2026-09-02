# `minisql.admin.fullclient.QueryView`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-queryview-struct-queryview-src-minisql-admin-fullclient-ml-1589026313"></a>
## QueryView

```ml
struct QueryView
```

Summarizes the outcome of one editor execution.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L119)

## Members

<a id="field-field-minisql-admin-fullclient-queryview-commandcount-commandcount-src-minisql-admin-fullclient-ml-1007508332"></a>
### commandCount

```ml
commandCount
```

Counts command responses returned by the server.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L123)

<a id="field-field-minisql-admin-fullclient-queryview-resulttext-resulttext-src-minisql-admin-fullclient-ml-1625522880"></a>
### resultText

```ml
resultText
```

Stores the combined human-readable server output.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L129)

<a id="field-field-minisql-admin-fullclient-queryview-rowcount-rowcount-src-minisql-admin-fullclient-ml-1807126006"></a>
### rowCount

```ml
rowCount
```

Counts rows in the final row-producing response.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L125)

<a id="field-field-minisql-admin-fullclient-queryview-statementcount-statementcount-src-minisql-admin-fullclient-ml-297402384"></a>
### statementCount

```ml
statementCount
```

Counts statements submitted by the editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L121)

<a id="field-field-minisql-admin-fullclient-queryview-success-success-src-minisql-admin-fullclient-ml-1432819564"></a>
### success

```ml
success
```

Indicates whether every response completed successfully.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L127)
