# `minisql.admin.win32_client.AdminSession`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-adminsession-struct-adminsession-src-minisql-admin-win32-client-ml-1443164689"></a>
## AdminSession

```ml
struct AdminSession
```

Combines one native window, client state, and optional running query worker.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L474)

## Members

<a id="field-field-minisql-admin-win32-client-adminsession-aborted-aborted-src-minisql-admin-win32-client-ml-1286166726"></a>
### aborted

```ml
aborted
```

Requires transport abort because cancellation invalidated protocol framing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L486)

<a id="field-field-minisql-admin-win32-client-adminsession-busy-busy-src-minisql-admin-win32-client-ml-1995401704"></a>
### busy

```ml
busy
```

Indicates whether SQL is currently executing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L482)

<a id="field-field-minisql-admin-win32-client-adminsession-dataoptions-dataoptions-src-minisql-admin-win32-client-ml-465969714"></a>
### dataOptions

```ml
dataOptions
```

Stores the active Data-page filter, order, and pagination settings.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L502)

<a id="field-field-minisql-admin-win32-client-adminsession-highlightaftermilliseconds-highlightaftermilliseconds-src-minisql-admin-win32-client-ml-1389598338"></a>
### highlightAfterMilliseconds

```ml
highlightAfterMilliseconds
```

Stores the monotonic idle deadline used to debounce worksheet recoloring.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L490)

<a id="field-field-minisql-admin-win32-client-adminsession-highlightdirty-highlightdirty-src-minisql-admin-win32-client-ml-756883922"></a>
### highlightDirty

```ml
highlightDirty
```

Requests one deferred full-editor syntax recolor after text changes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L488)

<a id="field-field-minisql-admin-win32-client-adminsession-historyfilter-historyfilter-src-minisql-admin-win32-client-ml-2098434202"></a>
### historyFilter

```ml
historyFilter
```

Stores the case-insensitive History sidebar filter.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L504)

<a id="field-field-minisql-admin-win32-client-adminsession-layoutpath-layoutpath-src-minisql-admin-win32-client-ml-1620288028"></a>
### layoutPath

```ml
layoutPath
```

Stores the optional per-user window-layout file path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L506)

<a id="field-field-minisql-admin-win32-client-adminsession-nextworksheetnumber-nextworksheetnumber-src-minisql-admin-win32-client-ml-1182362330"></a>
### nextWorksheetNumber

```ml
nextWorksheetNumber
```

Allocates monotonically increasing worksheet labels.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L498)

<a id="field-field-minisql-admin-win32-client-adminsession-pendingchanges-pendingchanges-src-minisql-admin-win32-client-ml-746403762"></a>
### pendingChanges

```ml
pendingChanges
```

Retains unapplied INSERT, UPDATE, and DELETE previews.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L500)

<a id="field-field-minisql-admin-win32-client-adminsession-selectedworksheetindex-selectedworksheetindex-src-minisql-admin-win32-client-ml-602553296"></a>
### selectedWorksheetIndex

```ml
selectedWorksheetIndex
```

Selects the worksheet currently loaded in the RichEdit control.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L496)

<a id="field-field-minisql-admin-win32-client-adminsession-sensitivesql-sensitivesql-src-minisql-admin-win32-client-ml-1496549058"></a>
### sensitiveSql

```ml
sensitiveSql
```

Records whether the editor currently contains a submitted secret-bearing DCL statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L484)

<a id="field-field-minisql-admin-win32-client-adminsession-state-state-src-minisql-admin-win32-client-ml-1869558550"></a>
### state

```ml
state
```

Owns the protocol and result model.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L478)

<a id="field-field-minisql-admin-win32-client-adminsession-window-window-src-minisql-admin-win32-client-ml-147996818"></a>
### window

```ml
window
```

Owns the native workbench controls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L476)

<a id="field-field-minisql-admin-win32-client-adminsession-windowrect-windowrect-src-minisql-admin-win32-client-ml-1577520302"></a>
### windowRect

```ml
windowRect
```

Retains the last live top-level rectangle for persistence after WM_CLOSE.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L508)

<a id="field-field-minisql-admin-win32-client-adminsession-worker-worker-src-minisql-admin-win32-client-ml-1197296762"></a>
### worker

```ml
worker
```

Stores the active native worker or void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L480)

<a id="field-field-minisql-admin-win32-client-adminsession-worksheets-worksheets-src-minisql-admin-win32-client-ml-1947758484"></a>
### worksheets

```ml
worksheets
```

Retains every independent SQL worksheet.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L494)

<a id="field-field-minisql-admin-win32-client-adminsession-workspacepage-workspacepage-src-minisql-admin-win32-client-ml-2003794770"></a>
### workspacePage

```ml
workspacePage
```

Persists the selected SQL/details workspace across asynchronous renders.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L492)
