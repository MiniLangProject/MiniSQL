# `minisql.admin.win32_client.RowEditorWindow`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-roweditorwindow-struct-roweditorwindow-src-minisql-admin-win32-client-ml-1822131477"></a>
## RowEditorWindow

```ml
struct RowEditorWindow
```

Owns the bounded modal editor used for arbitrary-width table rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L352)

## Members

<a id="field-field-minisql-admin-win32-client-roweditorwindow-cancelbutton-cancelbutton-src-minisql-admin-win32-client-ml-793160186"></a>
### cancelButton

```ml
cancelButton
```

Discards the row draft.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L372)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-fieldlabel-fieldlabel-src-minisql-admin-win32-client-ml-1458216506"></a>
### fieldLabel

```ml
fieldLabel
```

Shows the currently edited column name, type, and null/default policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L358)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-hintlabel-hintlabel-src-minisql-admin-win32-client-ml-1625852734"></a>
### hintLabel

```ml
hintLabel
```

Documents the explicit NULL and DEFAULT sentinel values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L364)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-hwnd-hwnd-src-minisql-admin-win32-client-ml-387976512"></a>
### hwnd

```ml
hwnd
```

Stores the modal top-level window handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L354)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-nextbutton-nextbutton-src-minisql-admin-win32-client-ml-456239240"></a>
### nextButton

```ml
nextButton
```

Applies the value and moves to the following field.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L368)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-previousbutton-previousbutton-src-minisql-admin-win32-client-ml-1029385936"></a>
### previousButton

```ml
previousButton
```

Moves to the preceding field.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L366)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-savebutton-savebutton-src-minisql-admin-win32-client-ml-1771474296"></a>
### saveButton

```ml
saveButton
```

Validates the draft and returns a mutation statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L370)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-titlelabel-titlelabel-src-minisql-admin-win32-client-ml-1857324382"></a>
### titleLabel

```ml
titleLabel
```

Describes the table and insert/update mode.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L356)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-valueedit-valueedit-src-minisql-admin-win32-client-ml-1111294090"></a>
### valueEdit

```ml
valueEdit
```

Edits the current field without truncating long text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L362)

<a id="field-field-minisql-admin-win32-client-roweditorwindow-valuesgrid-valuesgrid-src-minisql-admin-win32-client-ml-1847584674"></a>
### valuesGrid

```ml
valuesGrid
```

Shows all column values in a structured review grid.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L360)
