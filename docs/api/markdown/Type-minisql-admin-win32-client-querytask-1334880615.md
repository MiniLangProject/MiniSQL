# `minisql.admin.win32_client.QueryTask`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-querytask-struct-querytask-src-minisql-admin-win32-client-ml-1741827893"></a>
## QueryTask

```ml
struct QueryTask
```

Bundles immutable input for any protocol operation executed off the UI thread.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L337)

## Members

<a id="field-field-minisql-admin-win32-client-querytask-browseoptions-browseoptions-src-minisql-admin-win32-client-ml-442023406"></a>
### browseOptions

```ml
browseOptions
```

Stores the immutable page/filter/sort request for table description refreshes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L347)

<a id="field-field-minisql-admin-win32-client-querytask-operation-operation-src-minisql-admin-win32-client-ml-1576748994"></a>
### operation

```ml
operation
```

Selects execute, transaction, refresh, or table-description behavior.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L341)

<a id="field-field-minisql-admin-win32-client-querytask-sqltext-sqltext-src-minisql-admin-win32-client-ml-139836534"></a>
### sqlText

```ml
sqlText
```

Stores SQL submitted to execute or explain operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L343)

<a id="field-field-minisql-admin-win32-client-querytask-state-state-src-minisql-admin-win32-client-ml-1778449206"></a>
### state

```ml
state
```

Stores the fullclient state owned by the session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L339)

<a id="field-field-minisql-admin-win32-client-querytask-tablename-tablename-src-minisql-admin-win32-client-ml-1198965770"></a>
### tableName

```ml
tableName
```

Stores the table selected for an asynchronous description operation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L345)
