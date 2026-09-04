# `minisql.admin.win32_client.SchemaEditorWindow`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-schemaeditorwindow-struct-schemaeditorwindow-src-minisql-admin-win32-client-ml-1311958889"></a>
## SchemaEditorWindow

```ml
struct SchemaEditorWindow
```

Owns the structured schema designer controls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L394)

## Members

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-actionlist-actionlist-src-minisql-admin-win32-client-ml-1655910277"></a>
### actionList

```ml
actionList
```

Stores the ordered schema action list.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L398)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-cancelbutton-cancelbutton-src-minisql-admin-win32-client-ml-645911245"></a>
### cancelButton

```ml
cancelButton
```

Closes the designer without returning DDL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L414)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-definitionedit-definitionedit-src-minisql-admin-win32-client-ml-1905307887"></a>
### definitionEdit

```ml
definitionEdit
```

Edits column definitions, index columns, or constraint expressions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L404)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-executebutton-executebutton-src-minisql-admin-win32-client-ml-882122781"></a>
### executeButton

```ml
executeButton
```

Returns the generated DDL for immediate execution.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L410)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-hwnd-hwnd-src-minisql-admin-win32-client-ml-1582881199"></a>
### hwnd

```ml
hwnd
```

Stores the modal top-level schema designer handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L396)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-insertbutton-insertbutton-src-minisql-admin-win32-client-ml-1218578483"></a>
### insertButton

```ml
insertButton
```

Returns the generated DDL for insertion into a worksheet.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L412)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-labels-labels-src-minisql-admin-win32-client-ml-504759559"></a>
### labels

```ml
labels
```

Stores explanatory labels for all editable fields.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L416)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-objectedit-objectedit-src-minisql-admin-win32-client-ml-834522895"></a>
### objectEdit

```ml
objectEdit
```

Edits a column, index, or constraint name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L402)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-optionedit-optionedit-src-minisql-admin-win32-client-ml-1890609531"></a>
### optionEdit

```ml
optionEdit
```

Edits action-specific options such as UNIQUE or a rename target.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L406)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-previewedit-previewedit-src-minisql-admin-win32-client-ml-1802652137"></a>
### previewEdit

```ml
previewEdit
```

Shows the exact generated DDL before submission.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L408)

<a id="field-field-minisql-admin-win32-client-schemaeditorwindow-tableedit-tableedit-src-minisql-admin-win32-client-ml-498445065"></a>
### tableEdit

```ml
tableEdit
```

Edits the target table name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L400)
