# `src/minisql/admin/win32_client.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql admin win32 client facilities for this project.

Package: [`minisql.admin.win32_client`](Package-minisql-admin-win32-client-1206206668.md)

Reachable from entry: **no**

## Imports

- `minisql/admin/connection_profiles.ml` as `connection_profiles` → [src/minisql/admin/connection_profiles.ml](File-src-minisql-admin-connection-profiles-ml-390527802.md)
- `minisql/admin/fullclient.ml` as `fullclient` → [src/minisql/admin/fullclient.ml](File-src-minisql-admin-fullclient-ml-1896932593.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/config/loader.ml` as `json` → [src/minisql/config/loader.ml](File-src-minisql-config-loader-ml-616728659.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/win32_gui.ml` as `gui` → [src/minisql/platform/win32_gui.ml](File-src-minisql-platform-win32-gui-ml-1364403106.md)

## Declarations

<a id="function-function-minisql-admin-win32-client-activateworksheet-function-activateworksheet-session-index-src-minisql-admin-win32-client-ml-1363246822"></a>
### activateWorksheet

```ml
function activateWorksheet(session, index)
```

Loads one worksheet into the shared colorized RichEdit control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2049)

<a id="function-function-minisql-admin-win32-client-addworksheet-function-addworksheet-session-initialsql-src-minisql-admin-win32-client-ml-1069304628"></a>
### addWorksheet

```ml
function addWorksheet(session, initialSql)
```

Adds and activates a separately retained SQL worksheet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `initialSql` | `dynamic` | — | initialSql value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2065)

- [minisql.admin.win32_client.AdminSession](Type-minisql-admin-win32-client-adminsession-696483031.md) — struct
- [minisql.admin.win32_client.AdminWindow](Type-minisql-admin-win32-client-adminwindow-455282749.md) — struct
<a id="function-function-minisql-admin-win32-client-applyvisibility-function-applyvisibility-window-src-minisql-admin-win32-client-ml-1084268980"></a>
### applyVisibility

```ml
function applyVisibility(window)
```

Shows controls belonging to the selected sidebar and workspace tabs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1368)

<a id="function-function-minisql-admin-win32-client-clipboardeditorvalues-function-clipboardeditorvalues-details-row-src-minisql-admin-win32-client-ml-1093204672"></a>
### clipboardEditorValues

```ml
function clipboardEditorValues(details, row)
```

Converts one SELECT-ordered clipboard row into DESCRIBE-ordered editor values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — | details value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2210)

<a id="function-function-minisql-admin-win32-client-clipboardheader-function-clipboardheader-details-row-src-minisql-admin-win32-client-ml-565436040"></a>
### clipboardHeader

```ml
function clipboardHeader(details, row)
```

Tests whether a clipboard row is the exact Data-grid header.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — | details value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2199)

<a id="function-function-minisql-admin-win32-client-closeresultat-function-closeresultat-session-closingindex-src-minisql-admin-win32-client-ml-593013707"></a>
### closeResultAt

```ml
function closeResultAt(session, closingIndex)
```

Closes one structured result page selected through its tab-header glyph.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `closingIndex` | `dynamic` | — | Zero-based index of closing. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2130)

<a id="function-function-minisql-admin-win32-client-closeworksheet-function-closeworksheet-session-src-minisql-admin-win32-client-ml-2139452500"></a>
### closeWorksheet

```ml
function closeWorksheet(session)
```

Closes the worksheet currently loaded in the shared RichEdit control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2123)

<a id="function-function-minisql-admin-win32-client-closeworksheetat-function-closeworksheetat-session-closingindex-src-minisql-admin-win32-client-ml-841452163"></a>
### closeWorksheetAt

```ml
function closeWorksheetAt(session, closingIndex)
```

Closes any worksheet tab and selects the nearest surviving editor page.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `closingIndex` | `dynamic` | — | Zero-based index of closing. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2089)

<a id="function-function-minisql-admin-win32-client-componentname-function-componentname-src-minisql-admin-win32-client-ml-526938540"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2804)

- [minisql.admin.win32_client.ConnectionAttempt](Type-minisql-admin-win32-client-connectionattempt-1325310399.md) — struct
<a id="function-function-minisql-admin-win32-client-connectionfailuretext-function-connectionfailuretext-value-src-minisql-admin-win32-client-ml-1389217289"></a>
### connectionFailureText

```ml
function connectionFailureText(value)
```

Translates common WinSock failures into actionable connection guidance.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L804)

<a id="function-function-minisql-admin-win32-client-connectionlayoutprobe-function-connectionlayoutprobe-profiles-src-minisql-admin-win32-client-ml-935316222"></a>
### connectionLayoutProbe

```ml
function connectionLayoutProbe(profiles)
```

Exercises responsive geometry, editor roundtrips, checkboxes, and command delivery for supplied aliases.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L973)

<a id="function-function-minisql-admin-win32-client-connectionlayoutsmoke-function-connectionlayoutsmoke-path-src-minisql-admin-win32-client-ml-1208721263"></a>
### connectionLayoutSmoke

```ml
function connectionLayoutSmoke(path)
```

Loads aliases from a test path and runs the complete connection-layout probe.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1003)

<a id="function-function-minisql-admin-win32-client-connectionmanagersmoke-function-connectionmanagersmoke-path-src-minisql-admin-win32-client-ml-1950716661"></a>
### connectionManagerSmoke

```ml
function connectionManagerSmoke(path)
```

Runs a hidden connection-manager construction smoke test.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L924)

- [minisql.admin.win32_client.ConnectionTask](Type-minisql-admin-win32-client-connectiontask-42222287.md) — struct
- [minisql.admin.win32_client.ConnectionWindow](Type-minisql-admin-win32-client-connectionwindow-1356944590.md) — struct
<a id="function-function-minisql-admin-win32-client-connectionworker-function-connectionworker-task-src-minisql-admin-win32-client-ml-1297772807"></a>
### connectionWorker

```ml
function connectionWorker(task)
```

Opens one profile on a native worker so DNS, TCP, TLS, and authentication cannot freeze the UI.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — | task value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L727)

<a id="function-function-minisql-admin-win32-client-copyselecteddatarows-function-copyselecteddatarows-session-src-minisql-admin-win32-client-ml-343907528"></a>
### copySelectedDataRows

```ml
function copySelectedDataRows(session)
```

Copies all selected preview rows as escaped, header-bearing TSV.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2173)

<a id="function-function-minisql-admin-win32-client-createconnectionwindow-function-createconnectionwindow-visible-src-minisql-admin-win32-client-ml-302798074"></a>
### createConnectionWindow

```ml
function createConnectionWindow(visible)
```

Creates the modern alias manager used before a MiniSQL session opens.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L552)

<a id="function-function-minisql-admin-win32-client-createroweditorwindow-function-createroweditorwindow-details-updatemode-visible-src-minisql-admin-win32-client-ml-1488590624"></a>
### createRowEditorWindow

```ml
function createRowEditorWindow(details, updateMode, visible)
```

Creates the modal field-by-field editor used for inserts, copies, and updates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — | details value consumed by this operation. |
| `updateMode` | `dynamic` | — | updateMode value consumed by this operation. |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1809)

<a id="function-function-minisql-admin-win32-client-createschemaeditorwindow-function-createschemaeditorwindow-tablename-visible-src-minisql-admin-win32-client-ml-76430573"></a>
### createSchemaEditorWindow

```ml
function createSchemaEditorWindow(tableName, visible)
```

Creates the modal structured MiniSQL schema designer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableName` | `dynamic` | — | tableName value consumed by this operation. |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1676)

<a id="function-function-minisql-admin-win32-client-createwindow-function-createwindow-visible-src-minisql-admin-win32-client-ml-437574102"></a>
### createWindow

```ml
function createWindow(visible)
```

Creates the SQuirreL-style MiniSQL session workbench.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1011)

<a id="function-function-minisql-admin-win32-client-detailcolumnwidthdip-function-detailcolumnwidthdip-caption-src-minisql-admin-win32-client-ml-1597264138"></a>
### detailColumnWidthDip

```ml
function detailColumnWidthDip(caption)
```

Chooses readable report-column widths while keeping compact metadata flags narrow.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `caption` | `dynamic` | — | caption value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1549)

<a id="function-function-minisql-admin-win32-client-editdatarow-function-editdatarow-session-rowindex-duplicate-updatemode-initialfield-src-minisql-admin-win32-client-ml-25144921"></a>
### editDataRow

```ml
function editDataRow(session, rowIndex, duplicate, updateMode, initialField)
```

Opens an insert/update draft and stages its exact SQL after explicit preview.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `rowIndex` | `dynamic` | — | Zero-based index of row. |
| `duplicate` | `dynamic` | — | duplicate value consumed by this operation. |
| `updateMode` | `dynamic` | — | updateMode value consumed by this operation. |
| `initialField` | `dynamic` | — | initialField value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2018)

<a id="function-function-minisql-admin-win32-client-editorfieldfordatacolumn-function-editorfieldfordatacolumn-details-datacolumn-src-minisql-admin-win32-client-ml-839441452"></a>
### editorFieldForDataColumn

```ml
function editorFieldForDataColumn(details, dataColumn)
```

Resolves a SELECT-grid column to its DESCRIBE editor field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — | details value consumed by this operation. |
| `dataColumn` | `dynamic` | — | dataColumn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1992)

<a id="function-function-minisql-admin-win32-client-editorsqlforcommand-function-editorsqlforcommand-window-wholescript-src-minisql-admin-win32-client-ml-1349876078"></a>
### editorSqlForCommand

```ml
function editorSqlForCommand(window, wholeScript)
```

Reads the whole script, explicit selection, or statement under the caret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `wholeScript` | `dynamic` | — | wholeScript value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L541)

<a id="constant-constant-minisql-admin-win32-client-en-change-const-en-change-768-src-minisql-admin-win32-client-ml-1709258688"></a>
### EN_CHANGE

```ml
const EN_CHANGE = 768
```

Defines the en change constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L34)

<a id="function-function-minisql-admin-win32-client-exportactiveresult-function-exportactiveresult-session-src-minisql-admin-win32-client-ml-842252916"></a>
### exportActiveResult

```ml
function exportActiveResult(session)
```

Exports the active result grid through the native Save As dialog.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2154)

<a id="function-function-minisql-admin-win32-client-fail-function-fail-operation-message-src-minisql-admin-win32-client-ml-1188686376"></a>
### fail

```ml
function fail(operation, message)
```

Creates a namespaced GUI-controller error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L514)

<a id="function-function-minisql-admin-win32-client-fillclosabletabs-function-fillclosabletabs-hwnd-labels-selected-src-minisql-admin-win32-client-ml-1647072175"></a>
### fillClosableTabs

```ml
function fillClosableTabs(hwnd, labels, selected)
```

Renders notebook labels with a trailing multiplication-sign close target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — | hwnd value consumed by this operation. |
| `labels` | `dynamic` | — | labels value consumed by this operation. |
| `selected` | `dynamic` | — | selected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1502)

<a id="function-function-minisql-admin-win32-client-filldetailgrid-function-filldetailgrid-session-detailname-src-minisql-admin-win32-client-ml-555042"></a>
### fillDetailGrid

```ml
function fillDetailGrid(session, detailName)
```

Renders a structured object-detail response into the shared native report grid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `detailName` | `dynamic` | — | detailName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1559)

<a id="function-function-minisql-admin-win32-client-filllist-function-filllist-hwnd-values-src-minisql-admin-win32-client-ml-1870085047"></a>
### fillList

```ml
function fillList(hwnd, values)
```

Populates a list box from ordered display strings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — | hwnd value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1437)

<a id="function-function-minisql-admin-win32-client-fillobjecttree-function-fillobjecttree-window-state-src-minisql-admin-win32-client-ml-782934103"></a>
### fillObjectTree

```ml
function fillObjectTree(window, state)
```

Rebuilds the MiniSQL-only database object hierarchy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1450)

<a id="function-function-minisql-admin-win32-client-fillresultgrid-function-fillresultgrid-window-state-src-minisql-admin-win32-client-ml-2135671311"></a>
### fillResultGrid

```ml
function fillResultGrid(window, state)
```

Renders the active structured result into the native ListView grid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1513)

<a id="function-function-minisql-admin-win32-client-filltabs-function-filltabs-hwnd-labels-selected-src-minisql-admin-win32-client-ml-1187136647"></a>
### fillTabs

```ml
function fillTabs(hwnd, labels, selected)
```

Replaces tab captions and restores a valid selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — | hwnd value consumed by this operation. |
| `labels` | `dynamic` | — | labels value consumed by this operation. |
| `selected` | `dynamic` | — | selected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1484)

<a id="function-function-minisql-admin-win32-client-firstcontrolerror-function-firstcontrolerror-controls-src-minisql-admin-win32-client-ml-1571059304"></a>
### firstControlError

```ml
function firstControlError(controls)
```

Returns the first failed native-control creation from a heterogeneous handle array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controls` | `dynamic` | — | controls value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L520)

<a id="function-function-minisql-admin-win32-client-handlecommand-function-handlecommand-session-command-src-minisql-admin-win32-client-ml-1107026329"></a>
### handleCommand

```ml
function handleCommand(session, command)
```

Handles a native menu or toolbar command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `command` | `dynamic` | — | command value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2564)

<a id="function-function-minisql-admin-win32-client-handlecontextmenuevent-function-handlecontextmenuevent-session-event-src-minisql-admin-win32-client-ml-1742682236"></a>
### handleContextMenuEvent

```ml
function handleContextMenuEvent(session, event)
```

Opens the context menu appropriate for the control under the pointer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | Active Workbench session that owns the native controls. |
| `event` | `dynamic` | — | Native context-menu event to dispatch. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2652)

<a id="function-function-minisql-admin-win32-client-handlenotifyevent-function-handlenotifyevent-session-event-src-minisql-admin-win32-client-ml-1193421798"></a>
### handleNotifyEvent

```ml
function handleNotifyEvent(session, event)
```

Handles tab, list-view, and object-tree WM_NOTIFY events.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | Active Workbench session that receives the notification. |
| `event` | `dynamic` | — | Native notification event and control identifiers. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2668)

<a id="function-function-minisql-admin-win32-client-handlesessionevent-function-handlesessionevent-session-event-src-minisql-admin-win32-client-ml-920021580"></a>
### handleSessionEvent

```ml
function handleSessionEvent(session, event)
```

Routes one native event after verifying that it belongs to this workbench.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | Active Workbench session and top-level window state. |
| `event` | `dynamic` | — | Native window event to route. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2740)

<a id="function-function-minisql-admin-win32-client-handlewindowcommandevent-function-handlewindowcommandevent-session-event-src-minisql-admin-win32-client-ml-141977228"></a>
### handleWindowCommandEvent

```ml
function handleWindowCommandEvent(session, event)
```

Handles edit, filter, bookmark, history, and toolbar WM_COMMAND events.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | Active Workbench session that receives the command. |
| `event` | `dynamic` | — | Native command event and control identifiers. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2720)

<a id="function-function-minisql-admin-win32-client-highlightsqleditor-function-highlightsqleditor-window-src-minisql-admin-win32-client-ml-724917340"></a>
### highlightSqlEditor

```ml
function highlightSqlEditor(window)
```

Recomputes all presentation spans and applies them without moving the caret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L529)

<a id="constant-constant-minisql-admin-win32-client-id-begin-const-id-begin-8115-src-minisql-admin-win32-client-ml-595682946"></a>
### ID_BEGIN

```ml
const ID_BEGIN = 8115
```

Defines the id begin constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L115)

<a id="constant-constant-minisql-admin-win32-client-id-bookmark-list-const-id-bookmark-list-8103-src-minisql-admin-win32-client-ml-160259253"></a>
### ID_BOOKMARK_LIST

```ml
const ID_BOOKMARK_LIST = 8103
```

Defines the id bookmark list constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L93)

<a id="constant-constant-minisql-admin-win32-client-id-clear-const-id-clear-8119-src-minisql-admin-win32-client-ml-404794090"></a>
### ID_CLEAR

```ml
const ID_CLEAR = 8119
```

Defines the id clear constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L123)

<a id="constant-constant-minisql-admin-win32-client-id-close-const-id-close-8120-src-minisql-admin-win32-client-ml-160071084"></a>
### ID_CLOSE

```ml
const ID_CLOSE = 8120
```

Defines the id close constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L125)

<a id="constant-constant-minisql-admin-win32-client-id-close-sql-const-id-close-sql-8141-src-minisql-admin-win32-client-ml-1201790875"></a>
### ID_CLOSE_SQL

```ml
const ID_CLOSE_SQL = 8141
```

Defines the id close sql constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L167)

<a id="constant-constant-minisql-admin-win32-client-id-commit-const-id-commit-8116-src-minisql-admin-win32-client-ml-1899423339"></a>
### ID_COMMIT

```ml
const ID_COMMIT = 8116
```

Defines the id commit constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L117)

<a id="constant-constant-minisql-admin-win32-client-id-data-add-const-id-data-add-8124-src-minisql-admin-win32-client-ml-1759415846"></a>
### ID_DATA_ADD

```ml
const ID_DATA_ADD = 8124
```

Defines the id data add constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L133)

<a id="constant-constant-minisql-admin-win32-client-id-data-apply-changes-const-id-data-apply-changes-8136-src-minisql-admin-win32-client-ml-640880933"></a>
### ID_DATA_APPLY_CHANGES

```ml
const ID_DATA_APPLY_CHANGES = 8136
```

Defines the id data apply changes constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L157)

<a id="constant-constant-minisql-admin-win32-client-id-data-copy-const-id-data-copy-8125-src-minisql-admin-win32-client-ml-933449759"></a>
### ID_DATA_COPY

```ml
const ID_DATA_COPY = 8125
```

Defines the id data copy constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L135)

<a id="constant-constant-minisql-admin-win32-client-id-data-copy-clipboard-const-id-data-copy-clipboard-8129-src-minisql-admin-win32-client-ml-1097180141"></a>
### ID_DATA_COPY_CLIPBOARD

```ml
const ID_DATA_COPY_CLIPBOARD = 8129
```

Defines the id data copy clipboard constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L143)

<a id="constant-constant-minisql-admin-win32-client-id-data-delete-const-id-data-delete-8127-src-minisql-admin-win32-client-ml-939260033"></a>
### ID_DATA_DELETE

```ml
const ID_DATA_DELETE = 8127
```

Defines the id data delete constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L139)

<a id="constant-constant-minisql-admin-win32-client-id-data-edit-const-id-data-edit-8126-src-minisql-admin-win32-client-ml-584072320"></a>
### ID_DATA_EDIT

```ml
const ID_DATA_EDIT = 8126
```

Defines the id data edit constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L137)

<a id="constant-constant-minisql-admin-win32-client-id-data-filter-const-id-data-filter-8131-src-minisql-admin-win32-client-ml-1910678456"></a>
### ID_DATA_FILTER

```ml
const ID_DATA_FILTER = 8131
```

Defines the id data filter constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L147)

<a id="constant-constant-minisql-admin-win32-client-id-data-filter-apply-const-id-data-filter-apply-8132-src-minisql-admin-win32-client-ml-1217444387"></a>
### ID_DATA_FILTER_APPLY

```ml
const ID_DATA_FILTER_APPLY = 8132
```

Defines the id data filter apply constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L149)

<a id="constant-constant-minisql-admin-win32-client-id-data-next-page-const-id-data-next-page-8134-src-minisql-admin-win32-client-ml-522503039"></a>
### ID_DATA_NEXT_PAGE

```ml
const ID_DATA_NEXT_PAGE = 8134
```

Defines the id data next page constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L153)

<a id="constant-constant-minisql-admin-win32-client-id-data-page-label-const-id-data-page-label-8135-src-minisql-admin-win32-client-ml-271632300"></a>
### ID_DATA_PAGE_LABEL

```ml
const ID_DATA_PAGE_LABEL = 8135
```

Defines the id data page label constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L155)

<a id="constant-constant-minisql-admin-win32-client-id-data-paste-const-id-data-paste-8130-src-minisql-admin-win32-client-ml-1452825815"></a>
### ID_DATA_PASTE

```ml
const ID_DATA_PASTE = 8130
```

Defines the id data paste constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L145)

<a id="constant-constant-minisql-admin-win32-client-id-data-preview-changes-const-id-data-preview-changes-8138-src-minisql-admin-win32-client-ml-1091745671"></a>
### ID_DATA_PREVIEW_CHANGES

```ml
const ID_DATA_PREVIEW_CHANGES = 8138
```

Defines the id data preview changes constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L161)

<a id="constant-constant-minisql-admin-win32-client-id-data-previous-page-const-id-data-previous-page-8133-src-minisql-admin-win32-client-ml-1889705434"></a>
### ID_DATA_PREVIOUS_PAGE

```ml
const ID_DATA_PREVIOUS_PAGE = 8133
```

Defines the id data previous page constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L151)

<a id="constant-constant-minisql-admin-win32-client-id-data-refresh-const-id-data-refresh-8128-src-minisql-admin-win32-client-ml-298682690"></a>
### ID_DATA_REFRESH

```ml
const ID_DATA_REFRESH = 8128
```

Defines the id data refresh constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L141)

<a id="constant-constant-minisql-admin-win32-client-id-data-revert-changes-const-id-data-revert-changes-8137-src-minisql-admin-win32-client-ml-200001254"></a>
### ID_DATA_REVERT_CHANGES

```ml
const ID_DATA_REVERT_CHANGES = 8137
```

Defines the id data revert changes constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L159)

<a id="constant-constant-minisql-admin-win32-client-id-detail-grid-const-id-detail-grid-8123-src-minisql-admin-win32-client-ml-1666061361"></a>
### ID_DETAIL_GRID

```ml
const ID_DETAIL_GRID = 8123
```

Defines the id detail grid constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L131)

<a id="constant-constant-minisql-admin-win32-client-id-detail-tabs-const-id-detail-tabs-8106-src-minisql-admin-win32-client-ml-144422296"></a>
### ID_DETAIL_TABS

```ml
const ID_DETAIL_TABS = 8106
```

Defines the id detail tabs constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L99)

<a id="constant-constant-minisql-admin-win32-client-id-execute-const-id-execute-8113-src-minisql-admin-win32-client-ml-715440444"></a>
### ID_EXECUTE

```ml
const ID_EXECUTE = 8113
```

Defines the id execute constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L111)

<a id="constant-constant-minisql-admin-win32-client-id-execute-script-const-id-execute-script-8121-src-minisql-admin-win32-client-ml-773701549"></a>
### ID_EXECUTE_SCRIPT

```ml
const ID_EXECUTE_SCRIPT = 8121
```

Defines the id execute script constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L127)

<a id="constant-constant-minisql-admin-win32-client-id-explain-const-id-explain-8114-src-minisql-admin-win32-client-ml-1098852845"></a>
### ID_EXPLAIN

```ml
const ID_EXPLAIN = 8114
```

Defines the id explain constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L113)

<a id="constant-constant-minisql-admin-win32-client-id-export-csv-const-id-export-csv-8140-src-minisql-admin-win32-client-ml-1033460848"></a>
### ID_EXPORT_CSV

```ml
const ID_EXPORT_CSV = 8140
```

Defines the id export csv constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L165)

<a id="constant-constant-minisql-admin-win32-client-id-history-filter-const-id-history-filter-8143-src-minisql-admin-win32-client-ml-1624912537"></a>
### ID_HISTORY_FILTER

```ml
const ID_HISTORY_FILTER = 8143
```

Defines the id history filter constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L171)

<a id="constant-constant-minisql-admin-win32-client-id-history-list-const-id-history-list-8104-src-minisql-admin-win32-client-ml-385633740"></a>
### ID_HISTORY_LIST

```ml
const ID_HISTORY_LIST = 8104
```

Defines the id history list constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L95)

<a id="constant-constant-minisql-admin-win32-client-id-new-sql-const-id-new-sql-8112-src-minisql-admin-win32-client-ml-1525881923"></a>
### ID_NEW_SQL

```ml
const ID_NEW_SQL = 8112
```

Defines the id new sql constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L109)

<a id="constant-constant-minisql-admin-win32-client-id-object-tree-const-id-object-tree-8102-src-minisql-admin-win32-client-ml-26344484"></a>
### ID_OBJECT_TREE

```ml
const ID_OBJECT_TREE = 8102
```

Defines the id object tree constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L91)

<a id="constant-constant-minisql-admin-win32-client-id-open-object-const-id-open-object-8111-src-minisql-admin-win32-client-ml-538804368"></a>
### ID_OPEN_OBJECT

```ml
const ID_OPEN_OBJECT = 8111
```

Defines the id open object constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L107)

<a id="constant-constant-minisql-admin-win32-client-id-profile-address-const-id-profile-address-8003-src-minisql-admin-win32-client-ml-2032184028"></a>
### ID_PROFILE_ADDRESS

```ml
const ID_PROFILE_ADDRESS = 8003
```

Defines the id profile address constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L60)

<a id="constant-constant-minisql-admin-win32-client-id-profile-close-const-id-profile-close-8016-src-minisql-admin-win32-client-ml-1693314614"></a>
### ID_PROFILE_CLOSE

```ml
const ID_PROFILE_CLOSE = 8016
```

Defines the id profile close constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L86)

<a id="constant-constant-minisql-admin-win32-client-id-profile-connect-const-id-profile-connect-8013-src-minisql-admin-win32-client-ml-1423254889"></a>
### ID_PROFILE_CONNECT

```ml
const ID_PROFILE_CONNECT = 8013
```

Defines the id profile connect constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L80)

<a id="constant-constant-minisql-admin-win32-client-id-profile-database-const-id-profile-database-8006-src-minisql-admin-win32-client-ml-1416042289"></a>
### ID_PROFILE_DATABASE

```ml
const ID_PROFILE_DATABASE = 8006
```

Defines the id profile database constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L66)

<a id="constant-constant-minisql-admin-win32-client-id-profile-delete-const-id-profile-delete-8014-src-minisql-admin-win32-client-ml-1337289134"></a>
### ID_PROFILE_DELETE

```ml
const ID_PROFILE_DELETE = 8014
```

Defines the id profile delete constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L82)

<a id="constant-constant-minisql-admin-win32-client-id-profile-list-const-id-profile-list-8001-src-minisql-admin-win32-client-ml-1050484340"></a>
### ID_PROFILE_LIST

```ml
const ID_PROFILE_LIST = 8001
```

Defines the id profile list constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L56)

<a id="constant-constant-minisql-admin-win32-client-id-profile-name-const-id-profile-name-8002-src-minisql-admin-win32-client-ml-1015869253"></a>
### ID_PROFILE_NAME

```ml
const ID_PROFILE_NAME = 8002
```

Defines the id profile name constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L58)

<a id="constant-constant-minisql-admin-win32-client-id-profile-new-const-id-profile-new-8015-src-minisql-admin-win32-client-ml-502655667"></a>
### ID_PROFILE_NEW

```ml
const ID_PROFILE_NEW = 8015
```

Defines the id profile new constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L84)

<a id="constant-constant-minisql-admin-win32-client-id-profile-password-const-id-profile-password-8008-src-minisql-admin-win32-client-ml-1960664511"></a>
### ID_PROFILE_PASSWORD

```ml
const ID_PROFILE_PASSWORD = 8008
```

Defines the id profile password constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L70)

<a id="constant-constant-minisql-admin-win32-client-id-profile-pin-const-id-profile-pin-8011-src-minisql-admin-win32-client-ml-38961425"></a>
### ID_PROFILE_PIN

```ml
const ID_PROFILE_PIN = 8011
```

Defines the id profile pin constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L76)

<a id="constant-constant-minisql-admin-win32-client-id-profile-port-const-id-profile-port-8004-src-minisql-admin-win32-client-ml-1505599975"></a>
### ID_PROFILE_PORT

```ml
const ID_PROFILE_PORT = 8004
```

Defines the id profile port constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L62)

<a id="constant-constant-minisql-admin-win32-client-id-profile-save-const-id-profile-save-8012-src-minisql-admin-win32-client-ml-692213112"></a>
### ID_PROFILE_SAVE

```ml
const ID_PROFILE_SAVE = 8012
```

Defines the id profile save constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L78)

<a id="constant-constant-minisql-admin-win32-client-id-profile-server-const-id-profile-server-8005-src-minisql-admin-win32-client-ml-998411152"></a>
### ID_PROFILE_SERVER

```ml
const ID_PROFILE_SERVER = 8005
```

Defines the id profile server constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L64)

<a id="constant-constant-minisql-admin-win32-client-id-profile-tls-const-id-profile-tls-8009-src-minisql-admin-win32-client-ml-1147812672"></a>
### ID_PROFILE_TLS

```ml
const ID_PROFILE_TLS = 8009
```

Defines the id profile tls constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L72)

<a id="constant-constant-minisql-admin-win32-client-id-profile-trusted-const-id-profile-trusted-8010-src-minisql-admin-win32-client-ml-485853278"></a>
### ID_PROFILE_TRUSTED

```ml
const ID_PROFILE_TRUSTED = 8010
```

Defines the id profile trusted constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L74)

<a id="constant-constant-minisql-admin-win32-client-id-profile-user-const-id-profile-user-8007-src-minisql-admin-win32-client-ml-349842670"></a>
### ID_PROFILE_USER

```ml
const ID_PROFILE_USER = 8007
```

Defines the id profile user constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L68)

<a id="constant-constant-minisql-admin-win32-client-id-query-edit-const-id-query-edit-8122-src-minisql-admin-win32-client-ml-1174144444"></a>
### ID_QUERY_EDIT

```ml
const ID_QUERY_EDIT = 8122
```

Defines the id query edit constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L129)

<a id="constant-constant-minisql-admin-win32-client-id-refresh-const-id-refresh-8110-src-minisql-admin-win32-client-ml-1406769281"></a>
### ID_REFRESH

```ml
const ID_REFRESH = 8110
```

Defines the id refresh constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L105)

<a id="constant-constant-minisql-admin-win32-client-id-result-grid-const-id-result-grid-8108-src-minisql-admin-win32-client-ml-1768949738"></a>
### ID_RESULT_GRID

```ml
const ID_RESULT_GRID = 8108
```

Defines the id result grid constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L103)

<a id="constant-constant-minisql-admin-win32-client-id-result-tabs-const-id-result-tabs-8107-src-minisql-admin-win32-client-ml-148535967"></a>
### ID_RESULT_TABS

```ml
const ID_RESULT_TABS = 8107
```

Defines the id result tabs constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L101)

<a id="constant-constant-minisql-admin-win32-client-id-rollback-const-id-rollback-8117-src-minisql-admin-win32-client-ml-1784157292"></a>
### ID_ROLLBACK

```ml
const ID_ROLLBACK = 8117
```

Defines the id rollback constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L119)

<a id="constant-constant-minisql-admin-win32-client-id-row-cancel-const-id-row-cancel-8206-src-minisql-admin-win32-client-ml-1119194923"></a>
### ID_ROW_CANCEL

```ml
const ID_ROW_CANCEL = 8206
```

Defines the id row cancel constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L184)

<a id="constant-constant-minisql-admin-win32-client-id-row-next-const-id-row-next-8204-src-minisql-admin-win32-client-ml-1957913829"></a>
### ID_ROW_NEXT

```ml
const ID_ROW_NEXT = 8204
```

Defines the id row next constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L180)

<a id="constant-constant-minisql-admin-win32-client-id-row-previous-const-id-row-previous-8203-src-minisql-admin-win32-client-ml-1283440004"></a>
### ID_ROW_PREVIOUS

```ml
const ID_ROW_PREVIOUS = 8203
```

Defines the id row previous constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L178)

<a id="constant-constant-minisql-admin-win32-client-id-row-save-const-id-row-save-8205-src-minisql-admin-win32-client-ml-915524446"></a>
### ID_ROW_SAVE

```ml
const ID_ROW_SAVE = 8205
```

Defines the id row save constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L182)

<a id="constant-constant-minisql-admin-win32-client-id-row-value-const-id-row-value-8202-src-minisql-admin-win32-client-ml-1651047877"></a>
### ID_ROW_VALUE

```ml
const ID_ROW_VALUE = 8202
```

Defines the id row value constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L176)

<a id="constant-constant-minisql-admin-win32-client-id-row-values-const-id-row-values-8201-src-minisql-admin-win32-client-ml-375438454"></a>
### ID_ROW_VALUES

```ml
const ID_ROW_VALUES = 8201
```

Defines the id row values constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L174)

<a id="constant-constant-minisql-admin-win32-client-id-schema-actions-const-id-schema-actions-8301-src-minisql-admin-win32-client-ml-126643749"></a>
### ID_SCHEMA_ACTIONS

```ml
const ID_SCHEMA_ACTIONS = 8301
```

Defines the id schema actions constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L187)

<a id="constant-constant-minisql-admin-win32-client-id-schema-cancel-const-id-schema-cancel-8309-src-minisql-admin-win32-client-ml-424554407"></a>
### ID_SCHEMA_CANCEL

```ml
const ID_SCHEMA_CANCEL = 8309
```

Defines the id schema cancel constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L203)

<a id="constant-constant-minisql-admin-win32-client-id-schema-definition-const-id-schema-definition-8304-src-minisql-admin-win32-client-ml-406862886"></a>
### ID_SCHEMA_DEFINITION

```ml
const ID_SCHEMA_DEFINITION = 8304
```

Defines the id schema definition constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L193)

<a id="constant-constant-minisql-admin-win32-client-id-schema-designer-const-id-schema-designer-8139-src-minisql-admin-win32-client-ml-1468349140"></a>
### ID_SCHEMA_DESIGNER

```ml
const ID_SCHEMA_DESIGNER = 8139
```

Defines the id schema designer constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L163)

<a id="constant-constant-minisql-admin-win32-client-id-schema-execute-const-id-schema-execute-8307-src-minisql-admin-win32-client-ml-1458086531"></a>
### ID_SCHEMA_EXECUTE

```ml
const ID_SCHEMA_EXECUTE = 8307
```

Defines the id schema execute constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L199)

<a id="constant-constant-minisql-admin-win32-client-id-schema-insert-const-id-schema-insert-8308-src-minisql-admin-win32-client-ml-1044091542"></a>
### ID_SCHEMA_INSERT

```ml
const ID_SCHEMA_INSERT = 8308
```

Defines the id schema insert constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L201)

<a id="constant-constant-minisql-admin-win32-client-id-schema-object-const-id-schema-object-8303-src-minisql-admin-win32-client-ml-685033871"></a>
### ID_SCHEMA_OBJECT

```ml
const ID_SCHEMA_OBJECT = 8303
```

Defines the id schema object constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L191)

<a id="constant-constant-minisql-admin-win32-client-id-schema-option-const-id-schema-option-8305-src-minisql-admin-win32-client-ml-1537253105"></a>
### ID_SCHEMA_OPTION

```ml
const ID_SCHEMA_OPTION = 8305
```

Defines the id schema option constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L195)

<a id="constant-constant-minisql-admin-win32-client-id-schema-preview-const-id-schema-preview-8306-src-minisql-admin-win32-client-ml-1049173600"></a>
### ID_SCHEMA_PREVIEW

```ml
const ID_SCHEMA_PREVIEW = 8306
```

Defines the id schema preview constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L197)

<a id="constant-constant-minisql-admin-win32-client-id-schema-table-const-id-schema-table-8302-src-minisql-admin-win32-client-ml-1881089156"></a>
### ID_SCHEMA_TABLE

```ml
const ID_SCHEMA_TABLE = 8302
```

Defines the id schema table constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L189)

<a id="constant-constant-minisql-admin-win32-client-id-sidebar-tabs-const-id-sidebar-tabs-8101-src-minisql-admin-win32-client-ml-1823581955"></a>
### ID_SIDEBAR_TABS

```ml
const ID_SIDEBAR_TABS = 8101
```

Defines the id sidebar tabs constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L89)

<a id="constant-constant-minisql-admin-win32-client-id-stop-const-id-stop-8118-src-minisql-admin-win32-client-ml-1689573189"></a>
### ID_STOP

```ml
const ID_STOP = 8118
```

Defines the id stop constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L121)

<a id="constant-constant-minisql-admin-win32-client-id-worksheet-tabs-const-id-worksheet-tabs-8142-src-minisql-admin-win32-client-ml-49044430"></a>
### ID_WORKSHEET_TABS

```ml
const ID_WORKSHEET_TABS = 8142
```

Defines the id worksheet tabs constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L169)

<a id="constant-constant-minisql-admin-win32-client-id-workspace-tabs-const-id-workspace-tabs-8105-src-minisql-admin-win32-client-ml-1590897239"></a>
### ID_WORKSPACE_TABS

```ml
const ID_WORKSPACE_TABS = 8105
```

Defines the id workspace tabs constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L97)

<a id="function-function-minisql-admin-win32-client-insertselectedbookmark-function-insertselectedbookmark-session-src-minisql-admin-win32-client-ml-1181370088"></a>
### insertSelectedBookmark

```ml
function insertSelectedBookmark(session)
```

Inserts a selected bookmark into the SQL worksheet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2526)

<a id="function-function-minisql-admin-win32-client-insertselectedhistory-function-insertselectedhistory-session-src-minisql-admin-win32-client-ml-1644606160"></a>
### insertSelectedHistory

```ml
function insertSelectedHistory(session)
```

Reopens a redacted history item in the SQL worksheet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2538)

<a id="constant-constant-minisql-admin-win32-client-invalid-argument-const-invalid-argument-9001-src-minisql-admin-win32-client-ml-198925529"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L18)

<a id="function-function-minisql-admin-win32-client-isimplemented-function-isimplemented-src-minisql-admin-win32-client-ml-135580628"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the native workbench is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2814)

<a id="function-function-minisql-admin-win32-client-launchconnectionmanager-function-launchconnectionmanager-src-minisql-admin-win32-client-ml-1118419156"></a>
### launchConnectionManager

```ml
function launchConnectionManager()
```

Launches the per-user connection manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L916)

<a id="function-function-minisql-admin-win32-client-layoutconnectionwindow-function-layoutconnectionwindow-window-src-minisql-admin-win32-client-ml-925064736"></a>
### layoutConnectionWindow

```ml
function layoutConnectionWindow(window)
```

Reflows the alias list and all connection fields in logical DPI-independent units.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L600)

<a id="function-function-minisql-admin-win32-client-layoutroweditor-function-layoutroweditor-window-src-minisql-admin-win32-client-ml-1012955674"></a>
### layoutRowEditor

```ml
function layoutRowEditor(window)
```

Reflows the modal row editor for DPI changes and user-driven resizing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1838)

<a id="function-function-minisql-admin-win32-client-layoutschemaeditor-function-layoutschemaeditor-window-src-minisql-admin-win32-client-ml-2103639000"></a>
### layoutSchemaEditor

```ml
function layoutSchemaEditor(window)
```

Reflows the schema designer at its current DPI and client size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1711)

<a id="function-function-minisql-admin-win32-client-layoutsmoke-function-layoutsmoke-src-minisql-admin-win32-client-ml-1109601154"></a>
### layoutSmoke

```ml
function layoutSmoke()
```

Runs both responsive native-window probes against the per-user profile location.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1360)

<a id="function-function-minisql-admin-win32-client-layoutwindow-function-layoutwindow-window-src-minisql-admin-win32-client-ml-904508552"></a>
### layoutWindow

```ml
function layoutWindow(window)
```

Reflows every workbench pane after a top-level resize.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1098)

<a id="constant-constant-minisql-admin-win32-client-lbn-dblclk-const-lbn-dblclk-2-src-minisql-admin-win32-client-ml-1047463921"></a>
### LBN_DBLCLK

```ml
const LBN_DBLCLK = 2
```

Defines the lbn dblclk constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L22)

<a id="constant-constant-minisql-admin-win32-client-lbn-selchange-const-lbn-selchange-1-src-minisql-admin-win32-client-ml-1091275580"></a>
### LBN_SELCHANGE

```ml
const LBN_SELCHANGE = 1
```

Defines the lbn selchange constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L20)

<a id="constant-constant-minisql-admin-win32-client-lvn-columnclick-const-lvn-columnclick-108-src-minisql-admin-win32-client-ml-1609725041"></a>
### LVN_COLUMNCLICK

```ml
const LVN_COLUMNCLICK = -108
```

Defines the lvn columnclick constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L32)

<a id="function-function-minisql-admin-win32-client-moveroweditor-function-moveroweditor-editor-delta-src-minisql-admin-win32-client-ml-1799907627"></a>
### moveRowEditor

```ml
function moveRowEditor(editor, delta)
```

Commits the active value and navigates by one bounded field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `editor` | `dynamic` | — | editor value consumed by this operation. |
| `delta` | `dynamic` | — | delta value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1906)

<a id="constant-constant-minisql-admin-win32-client-nm-click-const-nm-click-2-src-minisql-admin-win32-client-ml-2072555566"></a>
### NM_CLICK

```ml
const NM_CLICK = -2
```

Defines the nm click constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L28)

<a id="constant-constant-minisql-admin-win32-client-nm-dblclk-const-nm-dblclk-3-src-minisql-admin-win32-client-ml-8784575"></a>
### NM_DBLCLK

```ml
const NM_DBLCLK = -3
```

Defines the nm dblclk constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L30)

<a id="function-function-minisql-admin-win32-client-openprofile-function-openprofile-profile-passwordbytes-visible-src-minisql-admin-win32-client-ml-1682134331"></a>
### openProfile

```ml
function openProfile(profile, passwordBytes, visible)
```

Opens a profile directly for command-line and network smoke workflows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — | profile value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2339)

<a id="function-function-minisql-admin-win32-client-openschemadesigner-function-openschemadesigner-session-src-minisql-admin-win32-client-ml-2139628768"></a>
### openSchemaDesigner

```ml
function openSchemaDesigner(session)
```

Opens the schema designer and either executes or inserts its generated DDL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1794)

<a id="function-function-minisql-admin-win32-client-openselectedobject-function-openselectedobject-session-src-minisql-admin-win32-client-ml-2102983192"></a>
### openSelectedObject

```ml
function openSelectedObject(session)
```

Opens table details for the current object-tree selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2503)

<a id="function-function-minisql-admin-win32-client-openstate-function-openstate-state-visible-src-minisql-admin-win32-client-ml-618151237"></a>
### openState

```ml
function openState(state, visible)
```

Wraps an existing connected state in a native workbench window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2317)

<a id="function-function-minisql-admin-win32-client-parkcontrol-function-parkcontrol-hwnd-src-minisql-admin-win32-client-ml-1787773427"></a>
### parkControl

```ml
function parkControl(hwnd)
```

Parks one inactive notebook page outside the client area without destroying it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — | hwnd value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1092)

<a id="function-function-minisql-admin-win32-client-passwordfromwindow-function-passwordfromwindow-window-profile-src-minisql-admin-win32-client-ml-42055843"></a>
### passwordFromWindow

```ml
function passwordFromWindow(window, profile)
```

Reads transient credentials, allowing password-free trusted-local sessions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L717)

<a id="function-function-minisql-admin-win32-client-pastedatarows-function-pastedatarows-session-src-minisql-admin-win32-client-ml-1790265248"></a>
### pasteDataRows

```ml
function pasteDataRows(session)
```

Stages clipboard TSV rows as validated INSERT statements.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2228)

<a id="function-function-minisql-admin-win32-client-pollconnection-function-pollconnection-attempt-src-minisql-admin-win32-client-ml-375594067"></a>
### pollConnection

```ml
function pollConnection(attempt)
```

Returns void while connecting, then publishes the state or error and wipes credentials.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attempt` | `dynamic` | — | attempt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L771)

<a id="function-function-minisql-admin-win32-client-pollquery-function-pollquery-session-src-minisql-admin-win32-client-ml-1712659998"></a>
### pollQuery

```ml
function pollQuery(session)
```

Publishes a completed worker result without performing network I/O on the UI thread.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2455)

<a id="function-function-minisql-admin-win32-client-profilebyname-function-profilebyname-profiles-name-src-minisql-admin-win32-client-ml-599482117"></a>
### profileByName

```ml
function profileByName(profiles, name)
```

Finds an alias by exact user-visible name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L650)

<a id="function-function-minisql-admin-win32-client-profilefromwindow-function-profilefromwindow-window-src-minisql-admin-win32-client-ml-621351630"></a>
### profileFromWindow

```ml
function profileFromWindow(window)
```

Validates connection-manager fields into a secret-free profile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L694)

<a id="constant-constant-minisql-admin-win32-client-query-begin-const-query-begin-3-src-minisql-admin-win32-client-ml-718815106"></a>
### QUERY_BEGIN

```ml
const QUERY_BEGIN = 3
```

Defines the query begin constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L41)

<a id="constant-constant-minisql-admin-win32-client-query-commit-const-query-commit-4-src-minisql-admin-win32-client-ml-844516149"></a>
### QUERY_COMMIT

```ml
const QUERY_COMMIT = 4
```

Defines the query commit constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L43)

<a id="constant-constant-minisql-admin-win32-client-query-data-mutation-const-query-data-mutation-8-src-minisql-admin-win32-client-ml-1590452935"></a>
### QUERY_DATA_MUTATION

```ml
const QUERY_DATA_MUTATION = 8
```

Defines the query data mutation constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L51)

<a id="constant-constant-minisql-admin-win32-client-query-describe-const-query-describe-7-src-minisql-admin-win32-client-ml-1596361776"></a>
### QUERY_DESCRIBE

```ml
const QUERY_DESCRIBE = 7
```

Defines the query describe constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L49)

<a id="constant-constant-minisql-admin-win32-client-query-execute-const-query-execute-1-src-minisql-admin-win32-client-ml-48185344"></a>
### QUERY_EXECUTE

```ml
const QUERY_EXECUTE = 1
```

Defines the query execute constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L37)

<a id="constant-constant-minisql-admin-win32-client-query-explain-const-query-explain-2-src-minisql-admin-win32-client-ml-1937022825"></a>
### QUERY_EXPLAIN

```ml
const QUERY_EXPLAIN = 2
```

Defines the query explain constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L39)

<a id="constant-constant-minisql-admin-win32-client-query-refresh-const-query-refresh-6-src-minisql-admin-win32-client-ml-1011399901"></a>
### QUERY_REFRESH

```ml
const QUERY_REFRESH = 6
```

Defines the query refresh constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L47)

<a id="constant-constant-minisql-admin-win32-client-query-rollback-const-query-rollback-5-src-minisql-admin-win32-client-ml-1950604620"></a>
### QUERY_ROLLBACK

```ml
const QUERY_ROLLBACK = 5
```

Defines the query rollback constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L45)

<a id="constant-constant-minisql-admin-win32-client-query-schema-mutation-const-query-schema-mutation-9-src-minisql-admin-win32-client-ml-260775668"></a>
### QUERY_SCHEMA_MUTATION

```ml
const QUERY_SCHEMA_MUTATION = 9
```

Defines the query schema mutation constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L53)

- [minisql.admin.win32_client.QueryCompletion](Type-minisql-admin-win32-client-querycompletion-69551328.md) — struct
<a id="function-function-minisql-admin-win32-client-queryselectedobject-function-queryselectedobject-session-src-minisql-admin-win32-client-ml-658762384"></a>
### querySelectedObject

```ml
function querySelectedObject(session)
```

Inserts a table preview query for the selected object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2513)

- [minisql.admin.win32_client.QueryTask](Type-minisql-admin-win32-client-querytask-1334880615.md) — struct
<a id="function-function-minisql-admin-win32-client-queryworker-function-queryworker-task-src-minisql-admin-win32-client-ml-1740301927"></a>
### queryWorker

```ml
function queryWorker(task)
```

Executes one protocol operation and any dependent refresh on the same worker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — | task value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2349)

<a id="function-function-minisql-admin-win32-client-rectangleinside-function-rectangleinside-rectangle-width-height-src-minisql-admin-win32-client-ml-1741440870"></a>
### rectangleInside

```ml
function rectangleInside(rectangle, width, height)
```

Returns true when a child rectangle is positive and fully contained by a client area.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rectangle` | `dynamic` | — | rectangle value consumed by this operation. |
| `width` | `dynamic` | — | Width in the coordinate or storage units used by the caller. |
| `height` | `dynamic` | — | Height in the coordinate or storage units used by the caller. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L932)

<a id="function-function-minisql-admin-win32-client-rectanglesoverlap-function-rectanglesoverlap-first-second-src-minisql-admin-win32-client-ml-677457368"></a>
### rectanglesOverlap

```ml
function rectanglesOverlap(first, second)
```

Detects whether two parent-relative rectangles consume the same layout area.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | first value consumed by this operation. |
| `second` | `dynamic` | — | second value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L940)

<a id="function-function-minisql-admin-win32-client-render-function-render-session-src-minisql-admin-win32-client-ml-11788184"></a>
### render

```ml
function render(session)
```

Renders all workbench panes from the current fullclient model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1635)

<a id="function-function-minisql-admin-win32-client-renderconnectionprofile-function-renderconnectionprofile-window-profile-src-minisql-admin-win32-client-ml-1144626597"></a>
### renderConnectionProfile

```ml
function renderConnectionProfile(window, profile)
```

Copies an alias into connection-manager controls and clears the password.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L660)

<a id="function-function-minisql-admin-win32-client-renderconnectionprofiles-function-renderconnectionprofiles-window-profiles-src-minisql-admin-win32-client-ml-2045087882"></a>
### renderConnectionProfiles

```ml
function renderConnectionProfiles(window, profiles)
```

Rebuilds the alias list while keeping the first row selected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L677)

<a id="function-function-minisql-admin-win32-client-rendernewprofile-function-rendernewprofile-window-src-minisql-admin-win32-client-ml-442346804"></a>
### renderNewProfile

```ml
function renderNewProfile(window)
```

Clears fields to a sensible new local alias template.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L688)

<a id="function-function-minisql-admin-win32-client-renderroweditor-function-renderroweditor-editor-src-minisql-admin-win32-client-ml-1124740969"></a>
### renderRowEditor

```ml
function renderRowEditor(editor)
```

Rebuilds the row-editor review table and focuses the active field value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `editor` | `dynamic` | — | editor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1864)

<a id="function-function-minisql-admin-win32-client-renderschemaeditor-function-renderschemaeditor-editor-src-minisql-admin-win32-client-ml-1829843227"></a>
### renderSchemaEditor

```ml
function renderSchemaEditor(editor)
```

Rebuilds the exact DDL preview from all current schema-designer fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `editor` | `dynamic` | — | editor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1745)

<a id="function-function-minisql-admin-win32-client-reportconnectionfailure-function-reportconnectionfailure-window-value-showdialog-src-minisql-admin-win32-client-ml-426732456"></a>
### reportConnectionFailure

```ml
function reportConnectionFailure(window, value, showDialog)
```

Reports a failed handshake without closing the manager so the user can retry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `showDialog` | `dynamic` | — | showDialog value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L815)

<a id="function-function-minisql-admin-win32-client-restorewindowlayout-function-restorewindowlayout-path-hwnd-src-minisql-admin-win32-client-ml-158536848"></a>
### restoreWindowLayout

```ml
function restoreWindowLayout(path, hwnd)
```

Restores a previously persisted workbench rectangle when every field is valid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `hwnd` | `dynamic` | — | hwnd value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2299)

<a id="function-function-minisql-admin-win32-client-restoreworkspace-function-restoreworkspace-session-src-minisql-admin-win32-client-ml-574812612"></a>
### restoreWorkspace

```ml
function restoreWorkspace(session)
```

Restores the session-owned page after native controls were repopulated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1428)

<a id="function-function-minisql-admin-win32-client-roweditorsql-function-roweditorsql-editor-src-minisql-admin-win32-client-ml-1049704563"></a>
### rowEditorSql

```ml
function rowEditorSql(editor)
```

Validates the complete draft and builds its INSERT or keyed UPDATE statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `editor` | `dynamic` | — | editor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1918)

- [minisql.admin.win32_client.RowEditorState](Type-minisql-admin-win32-client-roweditorstate-1300666988.md) — struct
- [minisql.admin.win32_client.RowEditorWindow](Type-minisql-admin-win32-client-roweditorwindow-1716256787.md) — struct
<a id="function-function-minisql-admin-win32-client-rowhaspendingchange-function-rowhaspendingchange-session-rowindex-src-minisql-admin-win32-client-ml-908392774"></a>
### rowHasPendingChange

```ml
function rowHasPendingChange(session, rowIndex)
```

Returns whether one preview row already has an unapplied update or delete.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `rowIndex` | `dynamic` | — | Zero-based index of row. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2005)

<a id="function-function-minisql-admin-win32-client-runconnectionmanagerwithpath-function-runconnectionmanagerwithpath-path-visible-src-minisql-admin-win32-client-ml-1882746917"></a>
### runConnectionManagerWithPath

```ml
function runConnectionManagerWithPath(path, visible)
```

Runs the native alias manager using an explicit profile path for tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `visible` | `dynamic` | — | visible value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L828)

<a id="function-function-minisql-admin-win32-client-runroweditor-function-runroweditor-session-rowindex-duplicate-updatemode-initialfield-src-minisql-admin-win32-client-ml-279230085"></a>
### runRowEditor

```ml
function runRowEditor(session, rowIndex, duplicate, updateMode, initialField)
```

Runs one modal row editor and returns generated SQL plus its preview values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `rowIndex` | `dynamic` | — | Zero-based index of row. |
| `duplicate` | `dynamic` | — | duplicate value consumed by this operation. |
| `updateMode` | `dynamic` | — | updateMode value consumed by this operation. |
| `initialField` | `dynamic` | — | initialField value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1934)

<a id="function-function-minisql-admin-win32-client-runschemaeditor-function-runschemaeditor-session-src-minisql-admin-win32-client-ml-1624694086"></a>
### runSchemaEditor

```ml
function runSchemaEditor(session)
```

Runs the modal schema designer and returns generated SQL plus execution intent.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1759)

<a id="function-function-minisql-admin-win32-client-runsession-function-runsession-session-src-minisql-admin-win32-client-ml-68003060"></a>
### runSession

```ml
function runSession(session)
```

Runs the responsive Win32 event loop for one connected session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2762)

<a id="function-function-minisql-admin-win32-client-savewindowlayout-function-savewindowlayout-path-rectangle-src-minisql-admin-win32-client-ml-1463754788"></a>
### saveWindowLayout

```ml
function saveWindowLayout(path, rectangle)
```

Persists one validated physical window rectangle as a tiny JSON document.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `rectangle` | `dynamic` | — | rectangle value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2290)

- [minisql.admin.win32_client.SchemaEditorState](Type-minisql-admin-win32-client-schemaeditorstate-405759977.md) — struct
- [minisql.admin.win32_client.SchemaEditorWindow](Type-minisql-admin-win32-client-schemaeditorwindow-1426118472.md) — struct
<a id="function-function-minisql-admin-win32-client-selecteddatarow-function-selecteddatarow-session-src-minisql-admin-win32-client-ml-1149612086"></a>
### selectedDataRow

```ml
function selectedDataRow(session)
```

Returns the selected Data-grid row index or a descriptive validation error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1983)

<a id="function-function-minisql-admin-win32-client-selectworkspace-function-selectworkspace-session-page-src-minisql-admin-win32-client-ml-1013328635"></a>
### selectWorkspace

```ml
function selectWorkspace(session, page)
```

Selects and persists one main workspace page before updating child visibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `page` | `dynamic` | — | page value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1406)

<a id="function-function-minisql-admin-win32-client-setbusycontrols-function-setbusycontrols-session-src-minisql-admin-win32-client-ml-429217454"></a>
### setBusyControls

```ml
function setBusyControls(session)
```

Enables query actions only when no native SQL worker owns the client session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1589)

<a id="function-function-minisql-admin-win32-client-setconnectionbusy-function-setconnectionbusy-window-busy-src-minisql-admin-win32-client-ml-1259971749"></a>
### setConnectionBusy

```ml
function setConnectionBusy(window, busy)
```

Prevents profile edits while the worker reads its immutable profile snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `busy` | `dynamic` | — | busy value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L734)

<a id="function-function-minisql-admin-win32-client-stageselecteddeletes-function-stageselecteddeletes-session-src-minisql-admin-win32-client-ml-2014064532"></a>
### stageSelectedDeletes

```ml
function stageSelectedDeletes(session)
```

Stages safe key-constrained DELETE statements for all selected rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2256)

<a id="function-function-minisql-admin-win32-client-startconnection-function-startconnection-window-profile-src-minisql-admin-win32-client-ml-1659150907"></a>
### startConnection

```ml
function startConnection(window, profile)
```

Starts an asynchronous connection attempt and transfers password ownership to it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L757)

<a id="function-function-minisql-admin-win32-client-startdatamutation-function-startdatamutation-session-sqltext-src-minisql-admin-win32-client-ml-1943982223"></a>
### startDataMutation

```ml
function startDataMutation(session, sqlText)
```

Starts a generated INSERT, UPDATE, or DELETE and reloads the edited table preview.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2440)

<a id="function-function-minisql-admin-win32-client-startdatapage-function-startdatapage-session-options-src-minisql-admin-win32-client-ml-863009860"></a>
### startDataPage

```ml
function startDataPage(session, options)
```

Applies a new filter/page/sort request only when pending row indices remain stable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `options` | `dynamic` | — | Options controlling the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2280)

<a id="function-function-minisql-admin-win32-client-startdescribe-function-startdescribe-session-tablename-src-minisql-admin-win32-client-ml-895554475"></a>
### startDescribe

```ml
function startDescribe(session, tableName)
```

Starts background metadata loading for one validated tree selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `tableName` | `dynamic` | — | tableName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2433)

<a id="function-function-minisql-admin-win32-client-starteditorcommand-function-starteditorcommand-session-wholescript-explain-src-minisql-admin-win32-client-ml-1242818285"></a>
### startEditorCommand

```ml
function startEditorCommand(session, wholeScript, explain)
```

Resolves the requested editor scope and starts its background execution.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `wholeScript` | `dynamic` | — | wholeScript value consumed by this operation. |
| `explain` | `dynamic` | — | explain value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2551)

<a id="function-function-minisql-admin-win32-client-startoperation-function-startoperation-session-operation-sqltext-tablename-src-minisql-admin-win32-client-ml-2104103481"></a>
### startOperation

```ml
function startOperation(session, operation, sqlText, tableName)
```

Starts one responsive background protocol operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |
| `tableName` | `dynamic` | — | tableName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2392)

<a id="function-function-minisql-admin-win32-client-startquery-function-startquery-session-sqltext-explain-src-minisql-admin-win32-client-ml-1559530070"></a>
### startQuery

```ml
function startQuery(session, sqlText, explain)
```

Starts normal or EXPLAIN SQL while preserving the established public API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |
| `explain` | `dynamic` | — | explain value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2415)

<a id="function-function-minisql-admin-win32-client-startrefresh-function-startrefresh-session-src-minisql-admin-win32-client-ml-1468632536"></a>
### startRefresh

```ml
function startRefresh(session)
```

Starts a background object-tree refresh.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2426)

<a id="function-function-minisql-admin-win32-client-startschemamutation-function-startschemamutation-session-sqltext-src-minisql-admin-win32-client-ml-163182345"></a>
### startSchemaMutation

```ml
function startSchemaMutation(session, sqlText)
```

Starts one generated schema mutation and reloads the object tree on success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2448)

<a id="function-function-minisql-admin-win32-client-statesmoke-function-statesmoke-state-src-minisql-admin-win32-client-ml-550053599"></a>
### stateSmoke

```ml
function stateSmoke(state)
```

Runs a hidden workbench construction smoke test against an existing state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2794)

<a id="function-function-minisql-admin-win32-client-stopconnection-function-stopconnection-attempt-src-minisql-admin-win32-client-ml-2103161987"></a>
### stopConnection

```ml
function stopConnection(attempt)
```

Cancels a handshake without wiping bytes until the native worker has terminated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attempt` | `dynamic` | — | attempt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L785)

<a id="function-function-minisql-admin-win32-client-stopquery-function-stopquery-session-src-minisql-admin-win32-client-ml-89904500"></a>
### stopQuery

```ml
function stopQuery(session)
```

Stops the native worker before disconnecting the affected session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2485)

<a id="function-function-minisql-admin-win32-client-storeactiveworksheet-function-storeactiveworksheet-session-src-minisql-admin-win32-client-ml-1605572360"></a>
### storeActiveWorksheet

```ml
function storeActiveWorksheet(session)
```

Saves the RichEdit contents into the selected worksheet model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2038)

<a id="function-function-minisql-admin-win32-client-storeroweditorvalue-function-storeroweditorvalue-editor-src-minisql-admin-win32-client-ml-629035533"></a>
### storeRowEditorValue

```ml
function storeRowEditorValue(editor)
```

Copies the active text box into its aligned row-editor draft slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `editor` | `dynamic` | — | editor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1895)

<a id="function-function-minisql-admin-win32-client-synchronizeworkspace-function-synchronizeworkspace-session-src-minisql-admin-win32-client-ml-1747303476"></a>
### synchronizeWorkspace

```ml
function synchronizeWorkspace(session)
```

Reconciles a user-driven native tab selection before asynchronous rendering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1415)

<a id="function-function-minisql-admin-win32-client-targetmilestone-function-targetmilestone-src-minisql-admin-win32-client-ml-1323333326"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2809)

<a id="constant-constant-minisql-admin-win32-client-tcn-selchange-const-tcn-selchange-551-src-minisql-admin-win32-client-ml-813421003"></a>
### TCN_SELCHANGE

```ml
const TCN_SELCHANGE = -551
```

Defines the tcn selchange constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L24)

<a id="constant-constant-minisql-admin-win32-client-tvn-selchangedw-const-tvn-selchangedw-451-src-minisql-admin-win32-client-ml-565708252"></a>
### TVN_SELCHANGEDW

```ml
const TVN_SELCHANGEDW = -451
```

Defines the tvn selchangedw constant used by the minisql admin win32 client module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L26)

<a id="function-function-minisql-admin-win32-client-verifyconnectionlayout-function-verifyconnectionlayout-window-width-height-src-minisql-admin-win32-client-ml-610306141"></a>
### verifyConnectionLayout

```ml
function verifyConnectionLayout(window, width, height)
```

Verifies one responsive connection-manager size through actual Win32 child rectangles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `width` | `dynamic` | — | Width in the coordinate or storage units used by the caller. |
| `height` | `dynamic` | — | Height in the coordinate or storage units used by the caller. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L949)

<a id="function-function-minisql-admin-win32-client-verifyworkbenchlayout-function-verifyworkbenchlayout-window-width-height-src-minisql-admin-win32-client-ml-1124749413"></a>
### verifyWorkbenchLayout

```ml
function verifyWorkbenchLayout(window, width, height)
```

Verifies one workbench size through actual native child rectangles and pane separation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `window` | `dynamic` | — | window value consumed by this operation. |
| `width` | `dynamic` | — | Width in the coordinate or storage units used by the caller. |
| `height` | `dynamic` | — | Height in the coordinate or storage units used by the caller. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1257)

<a id="function-function-minisql-admin-win32-client-workbenchlayoutsmoke-function-workbenchlayoutsmoke-src-minisql-admin-win32-client-ml-1924028508"></a>
### workbenchLayoutSmoke

```ml
function workbenchLayoutSmoke()
```

Exercises geometry, native SQL coloring, selection stability, and both execution commands.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L1285)

<a id="function-function-minisql-admin-win32-client-writetextfile-function-writetextfile-path-text-src-minisql-admin-win32-client-ml-851607704"></a>
### writeTextFile

```ml
function writeTextFile(path, text)
```

Writes a complete UTF-8 text artifact and flushes it before returning success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L2139)
