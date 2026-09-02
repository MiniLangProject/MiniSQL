# `minisql.admin.win32_client.RowEditorState`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-roweditorstate-struct-roweditorstate-src-minisql-admin-win32-client-ml-329876433"></a>
## RowEditorState

```ml
struct RowEditorState
```

Retains modal row-editor state independently from the connected session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L283)

## Members

<a id="field-field-minisql-admin-win32-client-roweditorstate-details-details-src-minisql-admin-win32-client-ml-75581457"></a>
### details

```ml
details
```

References the immutable table metadata used for validation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L287)

<a id="field-field-minisql-admin-win32-client-roweditorstate-fieldindex-fieldindex-src-minisql-admin-win32-client-ml-522824621"></a>
### fieldIndex

```ml
fieldIndex
```

Selects the field presented in the single-line value editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L291)

<a id="field-field-minisql-admin-win32-client-roweditorstate-originalrowindex-originalrowindex-src-minisql-admin-win32-client-ml-354481847"></a>
### originalRowIndex

```ml
originalRowIndex
```

Stores -1 for inserts or the preview row index for updates.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L293)

<a id="field-field-minisql-admin-win32-client-roweditorstate-resultsql-resultsql-src-minisql-admin-win32-client-ml-71714037"></a>
### resultSql

```ml
resultSql
```

Stores the generated SQL after Save or void after cancellation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L297)

<a id="field-field-minisql-admin-win32-client-roweditorstate-updatemode-updatemode-src-minisql-admin-win32-client-ml-1214862217"></a>
### updateMode

```ml
updateMode
```

Selects update generation instead of insert generation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L295)

<a id="field-field-minisql-admin-win32-client-roweditorstate-values-values-src-minisql-admin-win32-client-ml-1901633001"></a>
### values

```ml
values
```

Stores mutable editor values aligned with DESCRIBE rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L289)

<a id="field-field-minisql-admin-win32-client-roweditorstate-window-window-src-minisql-admin-win32-client-ml-1410697365"></a>
### window

```ml
window
```

Owns the native editor controls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L285)
