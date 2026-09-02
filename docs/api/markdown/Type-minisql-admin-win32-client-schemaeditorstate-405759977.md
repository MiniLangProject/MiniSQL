# `minisql.admin.win32_client.SchemaEditorState`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-schemaeditorstate-struct-schemaeditorstate-src-minisql-admin-win32-client-ml-294147425"></a>
## SchemaEditorState

```ml
struct SchemaEditorState
```

Retains schema-designer modal state until execution, insertion, or cancellation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L327)

## Members

<a id="field-field-minisql-admin-win32-client-schemaeditorstate-executeimmediately-executeimmediately-src-minisql-admin-win32-client-ml-1052773826"></a>
### executeImmediately

```ml
executeImmediately
```

Selects direct execution instead of worksheet insertion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L333)

<a id="field-field-minisql-admin-win32-client-schemaeditorstate-resultsql-resultsql-src-minisql-admin-win32-client-ml-173035928"></a>
### resultSql

```ml
resultSql
```

Stores generated DDL or void when cancelled.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L331)

<a id="field-field-minisql-admin-win32-client-schemaeditorstate-window-window-src-minisql-admin-win32-client-ml-626852740"></a>
### window

```ml
window
```

Owns the modal native controls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L329)
