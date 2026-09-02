# `src/minisql/admin/fullclient.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.admin.fullclient`](Package-minisql-admin-fullclient-1522338221.md)

Reachable from entry: **no**

## Imports

- `minisql/client/client.ml` as `client` → [src/minisql/client/client.ml](File-src-minisql-client-client-ml-193935498.md)
- `minisql/client/console.ml` as `console` → [src/minisql/client/console.ml](File-src-minisql-client-console-ml-931665780.md)
- `minisql/client/formatter.ml` as `formatter` → [src/minisql/client/formatter.ml](File-src-minisql-client-formatter-ml-1949327393.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)
- `minisql/sql/dialect.ml` as `dialect` → [src/minisql/sql/dialect.ml](File-src-minisql-sql-dialect-ml-1642253820.md)

## Declarations

<a id="function-function-minisql-admin-fullclient-abort-function-abort-state-src-minisql-admin-fullclient-ml-589326037"></a>
### abort

```ml
function abort(state)
```

Aborts a session after cancellation invalidated its request/response stream.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L697)

<a id="function-function-minisql-admin-fullclient-activeresulttab-function-activeresulttab-state-src-minisql-admin-fullclient-ml-415744245"></a>
### activeResultTab

```ml
function activeResultTab(state)
```

Returns the currently selected structured result tab.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1634)

<a id="function-function-minisql-admin-fullclient-addresulttab-function-addresulttab-state-sqltext-view-responses-elapsedmilliseconds-src-minisql-admin-fullclient-ml-646778377"></a>
### addResultTab

```ml
function addResultTab(state, sqlText, view, responses, elapsedMilliseconds)
```

Stores one result tab and selects it for grid rendering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |
| `view` | `dynamic` | — |  |
| `responses` | `dynamic` | — |  |
| `elapsedMilliseconds` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L758)

<a id="function-function-minisql-admin-fullclient-appendsyntaxspan-function-appendsyntaxspan-accumulator-startoffset-endoffset-kind-src-minisql-admin-fullclient-ml-1858010227"></a>
### appendSyntaxSpan

```ml
function appendSyntaxSpan(accumulator, startOffset, endOffset, kind)
```

Appends one non-empty native syntax range in constant time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `accumulator` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |
| `endOffset` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L465)

<a id="function-function-minisql-admin-fullclient-asciiupper-function-asciiupper-text-src-minisql-admin-fullclient-ml-358589501"></a>
### asciiUpper

```ml
function asciiUpper(text)
```

Converts ASCII letters to upper case for secret-bearing DCL detection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L303)

<a id="function-function-minisql-admin-fullclient-begintransaction-function-begintransaction-state-src-minisql-admin-fullclient-ml-2028554149"></a>
### beginTransaction

```ml
function beginTransaction(state)
```

Begins an explicit MiniSQL transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L886)

- [minisql.admin.fullclient.Bookmark](Type-minisql-admin-fullclient-bookmark-736301461.md) — struct
<a id="function-function-minisql-admin-fullclient-bookmarklines-function-bookmarklines-bookmarks-src-minisql-admin-fullclient-ml-89519503"></a>
### bookmarkLines

```ml
function bookmarkLines(bookmarks)
```

Returns bookmark labels for native list rendering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bookmarks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L631)

<a id="function-function-minisql-admin-fullclient-bookmarksqlforselection-function-bookmarksqlforselection-state-label-src-minisql-admin-fullclient-ml-1938199745"></a>
### bookmarkSqlForSelection

```ml
function bookmarkSqlForSelection(state, label)
```

Returns SQL for a bookmark and substitutes the selected table where required.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1670)

<a id="function-function-minisql-admin-fullclient-byteoffsetforutf16-function-byteoffsetforutf16-text-wantedunits-src-minisql-admin-fullclient-ml-255482271"></a>
### byteOffsetForUtf16

```ml
function byteOffsetForUtf16(text, wantedUnits)
```

Converts a native UTF-16 caret offset to an exact UTF-8 byte boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `wantedUnits` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L343)

<a id="function-function-minisql-admin-fullclient-clearresulttabs-function-clearresulttabs-state-src-minisql-admin-fullclient-ml-1709617881"></a>
### clearResultTabs

```ml
function clearResultTabs(state)
```

Clears result tabs while preserving SQL history.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1661)

<a id="function-function-minisql-admin-fullclient-clipboardfield-function-clipboardfield-value-src-minisql-admin-fullclient-ml-603651133"></a>
### clipboardField

```ml
function clipboardField(value)
```

Escapes tabs, line endings, and backslashes for lossless clipboard TSV.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1450)

<a id="function-function-minisql-admin-fullclient-close-function-close-state-src-minisql-admin-fullclient-ml-528213897"></a>
### close

```ml
function close(state)
```

Closes the active protocol session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L691)

<a id="function-function-minisql-admin-fullclient-closeresulttab-function-closeresulttab-state-index-src-minisql-admin-fullclient-ml-423346437"></a>
### closeResultTab

```ml
function closeResultTab(state, index)
```

Closes one result page and keeps the nearest surviving page selected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1640)

<a id="function-function-minisql-admin-fullclient-columnmetadata-function-columnmetadata-details-columnname-src-minisql-admin-fullclient-ml-869187535"></a>
### columnMetadata

```ml
function columnMetadata(details, columnName)
```

Finds one DESCRIBE row by exact column name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L964)

<a id="function-function-minisql-admin-fullclient-committransaction-function-committransaction-state-src-minisql-admin-fullclient-ml-1152326531"></a>
### commitTransaction

```ml
function commitTransaction(state)
```

Commits the current explicit MiniSQL transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L891)

<a id="function-function-minisql-admin-fullclient-componentname-function-componentname-src-minisql-admin-fullclient-ml-176825148"></a>
### componentName

```ml
function componentName()
```

Returns the stable module name used by smoke tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1696)

- [minisql.admin.fullclient.ConnectionProfile](Type-minisql-admin-fullclient-connectionprofile-100413438.md) — struct
<a id="function-function-minisql-admin-fullclient-containstext-function-containstext-values-wanted-src-minisql-admin-fullclient-ml-1313396471"></a>
### containsText

```ml
function containsText(values, wanted)
```

Returns whether an array contains an exact string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L915)

<a id="function-function-minisql-admin-fullclient-createdatabrowseoptions-function-createdatabrowseoptions-filtertext-sortcolumn-ascending-page-pagesize-src-minisql-admin-fullclient-ml-544639304"></a>
### createDataBrowseOptions

```ml
function createDataBrowseOptions(filterText, sortColumn, ascending, page, pageSize)
```

Constructs validated table-browser paging, filter, and ordering options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filterText` | `dynamic` | — |  |
| `sortColumn` | `dynamic` | — |  |
| `ascending` | `dynamic` | — |  |
| `page` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1083)

<a id="function-function-minisql-admin-fullclient-createprofile-function-createprofile-name-address-port-servername-databasename-username-tls-pinsha256-trustedlocal-src-minisql-admin-fullclient-ml-51625135"></a>
### createProfile

```ml
function createProfile(name, address, port, serverName, databaseName, userName, tls, pinSha256, trustedLocal)
```

Constructs and validates one MiniSQL-only connection profile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `databaseName` | `dynamic` | — |  |
| `userName` | `dynamic` | — |  |
| `tls` | `dynamic` | — |  |
| `pinSha256` | `dynamic` | — |  |
| `trustedLocal` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L640)

<a id="function-function-minisql-admin-fullclient-csvfield-function-csvfield-value-src-minisql-admin-fullclient-ml-103722977"></a>
### csvField

```ml
function csvField(value)
```

Escapes one cell for RFC 4180-compatible UTF-8 CSV output.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1420)

<a id="function-function-minisql-admin-fullclient-currentstatementsql-function-currentstatementsql-text-caretoffset-src-minisql-admin-fullclient-ml-89388937"></a>
### currentStatementSql

```ml
function currentStatementSql(text, caretOffset)
```

Locates the statement containing a collapsed caret while honoring SQL lexical regions. A caret after the final delimiter selects the preceding statement, matching common worksheet behavior; semicolons inside strings, identifiers, and comments are ignored.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `caretOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L383)

- [minisql.admin.fullclient.DataBrowseOptions](Type-minisql-admin-fullclient-databrowseoptions-1859862679.md) — struct
<a id="function-function-minisql-admin-fullclient-datacolumnindex-function-datacolumnindex-details-columnname-src-minisql-admin-fullclient-ml-1705578103"></a>
### dataColumnIndex

```ml
function dataColumnIndex(details, columnName)
```

Finds a named preview column so key values can be read from a selected row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L973)

<a id="function-function-minisql-admin-fullclient-datacountsql-function-datacountsql-tablename-options-src-minisql-admin-fullclient-ml-907346689"></a>
### dataCountSql

```ml
function dataCountSql(tableName, options)
```

Builds the matching filtered row-count query used by pagination controls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableName` | `dynamic` | — |  |
| `options` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1119)

<a id="function-function-minisql-admin-fullclient-dataeditorvalues-function-dataeditorvalues-details-rowindex-duplicate-src-minisql-admin-fullclient-ml-821475761"></a>
### dataEditorValues

```ml
function dataEditorValues(details, rowIndex, duplicate)
```

Creates initial editor values for a new, copied, or existing preview row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |
| `duplicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1234)

<a id="function-function-minisql-admin-fullclient-datagridwithchanges-function-datagridwithchanges-details-changes-src-minisql-admin-fullclient-ml-621112343"></a>
### dataGridWithChanges

```ml
function dataGridWithChanges(details, changes)
```

Builds an optimistic Data-page grid with explicit pending-change markers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `changes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1378)

<a id="function-function-minisql-admin-fullclient-datarowpredicate-function-datarowpredicate-details-originalrow-src-minisql-admin-fullclient-ml-1174623581"></a>
### dataRowPredicate

```ml
function dataRowPredicate(details, originalRow)
```

Builds the stable key predicate used by UPDATE and DELETE from original row values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `originalRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1261)

<a id="function-function-minisql-admin-fullclient-dataselectsql-function-dataselectsql-tablename-options-src-minisql-admin-fullclient-ml-1885093673"></a>
### dataSelectSql

```ml
function dataSelectSql(tableName, options)
```

Builds the bounded SELECT used by the editable table browser.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableName` | `dynamic` | — |  |
| `options` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1102)

<a id="function-function-minisql-admin-fullclient-ddlfromdescribe-function-ddlfromdescribe-tablename-response-src-minisql-admin-fullclient-ml-1990013888"></a>
### ddlFromDescribe

```ml
function ddlFromDescribe(tableName, response)
```

Converts validated DESCRIBE metadata into a readable CREATE TABLE preview.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableName` | `dynamic` | — |  |
| `response` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L923)

<a id="function-function-minisql-admin-fullclient-decodeclipboardfield-function-decodeclipboardfield-raw-src-minisql-admin-fullclient-ml-1994729800"></a>
### decodeClipboardField

```ml
function decodeClipboardField(raw)
```

Decodes one escaped clipboard field without interpreting SQL syntax.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1488)

<a id="constant-constant-minisql-admin-fullclient-default-data-page-size-const-default-data-page-size-100-src-minisql-admin-fullclient-ml-730053340"></a>
### DEFAULT_DATA_PAGE_SIZE

```ml
const DEFAULT_DATA_PAGE_SIZE = 100
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L19)

<a id="function-function-minisql-admin-fullclient-defaultbookmarks-function-defaultbookmarks-src-minisql-admin-fullclient-ml-1728911084"></a>
### defaultBookmarks

```ml
function defaultBookmarks()
```

Provides SQuirreL-style starter templates specialized for MiniSQL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L617)

<a id="function-function-minisql-admin-fullclient-defaultdatabrowseoptions-function-defaultdatabrowseoptions-src-minisql-admin-fullclient-ml-1621913144"></a>
### defaultDataBrowseOptions

```ml
function defaultDataBrowseOptions()
```

Returns the default first-page data-browser options.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1097)

<a id="function-function-minisql-admin-fullclient-deletedatasql-function-deletedatasql-details-originalrow-src-minisql-admin-fullclient-ml-677883943"></a>
### deleteDataSql

```ml
function deleteDataSql(details, originalRow)
```

Generates a key-constrained DELETE statement for a selected preview row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `originalRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1337)

<a id="function-function-minisql-admin-fullclient-describetable-function-describetable-state-tablename-src-minisql-admin-fullclient-ml-1205151902"></a>
### describeTable

```ml
function describeTable(state, tableName)
```

Loads the default first page while preserving the original public API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1597)

<a id="function-function-minisql-admin-fullclient-describetableview-function-describetableview-state-tablename-options-src-minisql-admin-fullclient-ml-1909196036"></a>
### describeTableView

```ml
function describeTableView(state, tableName, options)
```

Loads a filtered, ordered, and paginated set of detail pages for one table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |
| `options` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1572)

- [minisql.admin.fullclient.DetailGrid](Type-minisql-admin-fullclient-detailgrid-555760296.md) — struct
<a id="function-function-minisql-admin-fullclient-detailgridbyname-function-detailgridbyname-state-name-src-minisql-admin-fullclient-ml-173644232"></a>
### detailGridByName

```ml
function detailGridByName(state, name)
```

Returns the structured object-detail grid for a page or void for textual pages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L953)

<a id="function-function-minisql-admin-fullclient-detailgridfromresponse-function-detailgridfromresponse-response-src-minisql-admin-fullclient-ml-1962316985"></a>
### detailGridFromResponse

```ml
function detailGridFromResponse(response)
```

Converts one successful row response into a native-grid model without formatting loss.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L947)

<a id="function-function-minisql-admin-fullclient-detailtablines-function-detailtablines-state-src-minisql-admin-fullclient-ml-2104202377"></a>
### detailTabLines

```ml
function detailTabLines(state)
```

Returns names of the object-detail notebook pages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1602)

<a id="function-function-minisql-admin-fullclient-detailtextbyname-function-detailtextbyname-state-name-src-minisql-admin-fullclient-ml-890373564"></a>
### detailTextByName

```ml
function detailTextByName(state, name)
```

Returns the selected detail-page text by its tab label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1608)

<a id="function-function-minisql-admin-fullclient-editablekeycolumns-function-editablekeycolumns-details-src-minisql-admin-fullclient-ml-1487520508"></a>
### editableKeyColumns

```ml
function editableKeyColumns(details)
```

Selects a primary key, or the first unique key, for safe single-row mutations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1215)

<a id="function-function-minisql-admin-fullclient-editorsqlforexecution-function-editorsqlforexecution-text-selectionstart-selectionend-wholescript-src-minisql-admin-fullclient-ml-1929292220"></a>
### editorSqlForExecution

```ml
function editorSqlForExecution(text, selectionStart, selectionEnd, wholeScript)
```

Chooses the whole script, an explicit selection, or the caret's current statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `selectionStart` | `dynamic` | — |  |
| `selectionEnd` | `dynamic` | — |  |
| `wholeScript` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L446)

<a id="function-function-minisql-admin-fullclient-editorsqlliteral-function-editorsqlliteral-metadatarow-editorvalue-allowdefault-src-minisql-admin-fullclient-ml-658808711"></a>
### editorSqlLiteral

```ml
function editorSqlLiteral(metadataRow, editorValue, allowDefault)
```

Converts one row-editor value into a type-aware SQL literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `metadataRow` | `dynamic` | — |  |
| `editorValue` | `dynamic` | — |  |
| `allowDefault` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1025)

<a id="function-function-minisql-admin-fullclient-editorvaluefromdata-function-editorvaluefromdata-metadatarow-value-src-minisql-admin-fullclient-ml-642855600"></a>
### editorValueFromData

```ml
function editorValueFromData(metadataRow, value)
```

Converts one preview value back into the explicit row-editor sentinel form.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `metadataRow` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1228)

<a id="function-function-minisql-admin-fullclient-emptyqueryview-function-emptyqueryview-src-minisql-admin-fullclient-ml-2083799764"></a>
### emptyQueryView

```ml
function emptyQueryView()
```

Returns an empty successful query summary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L224)

<a id="function-function-minisql-admin-fullclient-emptytabledetails-function-emptytabledetails-src-minisql-admin-fullclient-ml-1122148538"></a>
### emptyTableDetails

```ml
function emptyTableDetails()
```

Returns empty table-detail pages before an object is selected.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L229)

<a id="function-function-minisql-admin-fullclient-endpointtext-function-endpointtext-profile-src-minisql-admin-fullclient-ml-1363559257"></a>
### endpointText

```ml
function endpointText(profile)
```

Formats the endpoint shown in alias and session status areas.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L657)

<a id="function-function-minisql-admin-fullclient-executablesqlfragment-function-executablesqlfragment-text-src-minisql-admin-fullclient-ml-34863353"></a>
### executableSqlFragment

```ml
function executableSqlFragment(text)
```

Returns whether one editor fragment contains executable SQL rather than comments only.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L371)

<a id="function-function-minisql-admin-fullclient-executeatomicsql-function-executeatomicsql-state-sqltext-src-minisql-admin-fullclient-ml-1370813948"></a>
### executeAtomicSql

```ml
function executeAtomicSql(state, sqlText)
```

Executes a generated mutation batch atomically, using a savepoint inside an existing transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L806)

<a id="function-function-minisql-admin-fullclient-executesql-function-executesql-state-sqltext-src-minisql-admin-fullclient-ml-1954448488"></a>
### executeSql

```ml
function executeSql(state, sqlText)
```

Executes a semicolon-delimited editor batch and retains bounded, redacted results.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L772)

<a id="function-function-minisql-admin-fullclient-explainsql-function-explainsql-state-sqltext-src-minisql-admin-fullclient-ml-121644140"></a>
### explainSql

```ml
function explainSql(state, sqlText)
```

Executes EXPLAIN for the editor selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L865)

<a id="function-function-minisql-admin-fullclient-fail-function-fail-operation-message-src-minisql-admin-fullclient-ml-1395488320"></a>
### fail

```ml
function fail(operation, message)
```

Creates a namespaced structured error for the workbench model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L219)

<a id="function-function-minisql-admin-fullclient-filterhistory-function-filterhistory-history-searchtext-src-minisql-admin-fullclient-ml-152071015"></a>
### filterHistory

```ml
function filterHistory(history, searchText)
```

Filters redacted worksheet history case-insensitively for the sidebar search box.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `history` | `dynamic` | — |  |
| `searchText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1545)

- [minisql.admin.fullclient.FullClientState](Type-minisql-admin-fullclient-fullclientstate-729553152.md) — struct
<a id="function-function-minisql-admin-fullclient-gridclipboardtext-function-gridclipboardtext-grid-selectedrows-includeheader-src-minisql-admin-fullclient-ml-414241811"></a>
### gridClipboardText

```ml
function gridClipboardText(grid, selectedRows, includeHeader)
```

Serializes selected grid rows as escaped tab-separated clipboard text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `grid` | `dynamic` | — |  |
| `selectedRows` | `dynamic` | — |  |
| `includeHeader` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1467)

<a id="function-function-minisql-admin-fullclient-gridcsv-function-gridcsv-grid-src-minisql-admin-fullclient-ml-473494056"></a>
### gridCsv

```ml
function gridCsv(grid)
```

Serializes a structured grid as deterministic CRLF-terminated CSV.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `grid` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1434)

<a id="function-function-minisql-admin-fullclient-historysql-function-historysql-sqltext-src-minisql-admin-fullclient-ml-147719435"></a>
### historySql

```ml
function historySql(sqlText)
```

Redacts account DCL so passwords never enter result, history, or query state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L601)

<a id="function-function-minisql-admin-fullclient-insertdatasql-function-insertdatasql-details-values-src-minisql-admin-fullclient-ml-95793424"></a>
### insertDataSql

```ml
function insertDataSql(details, values)
```

Generates an INSERT statement while omitting identity/default sentinel fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1283)

<a id="constant-constant-minisql-admin-fullclient-invalid-argument-const-invalid-argument-9001-src-minisql-admin-fullclient-ml-1857669857"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L16)

<a id="function-function-minisql-admin-fullclient-isimplemented-function-isimplemented-src-minisql-admin-fullclient-ml-629536108"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the workbench model is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1706)

<a id="function-function-minisql-admin-fullclient-issensitivesql-function-issensitivesql-sqltext-src-minisql-admin-fullclient-ml-626425691"></a>
### isSensitiveSql

```ml
function isSensitiveSql(sqlText)
```

Conservatively identifies account DCL before it can enter long-lived UI state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L591)

<a id="function-function-minisql-admin-fullclient-keepnewest-function-keepnewest-values-maximum-src-minisql-admin-fullclient-ml-1955515702"></a>
### keepNewest

```ml
function keepNewest(values, maximum)
```

Bounds an array by retaining its newest entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `maximum` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L748)

<a id="function-function-minisql-admin-fullclient-lastrowresponse-function-lastrowresponse-responses-src-minisql-admin-fullclient-ml-1991197924"></a>
### lastRowResponse

```ml
function lastRowResponse(responses)
```

Returns the final row response in a multi-statement batch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `responses` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L737)

<a id="function-function-minisql-admin-fullclient-linejoin-function-linejoin-values-src-minisql-admin-fullclient-ml-1922014054"></a>
### lineJoin

```ml
function lineJoin(values)
```

Joins display lines using Windows edit-control newlines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L607)

<a id="constant-constant-minisql-admin-fullclient-max-data-page-size-const-max-data-page-size-1000-src-minisql-admin-fullclient-ml-416460502"></a>
### MAX_DATA_PAGE_SIZE

```ml
const MAX_DATA_PAGE_SIZE = 1000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L20)

<a id="constant-constant-minisql-admin-fullclient-max-history-items-const-max-history-items-100-src-minisql-admin-fullclient-ml-1282346738"></a>
### MAX_HISTORY_ITEMS

```ml
const MAX_HISTORY_ITEMS = 100
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L18)

<a id="constant-constant-minisql-admin-fullclient-max-result-tabs-const-max-result-tabs-32-src-minisql-admin-fullclient-ml-1556495558"></a>
### MAX_RESULT_TABS

```ml
const MAX_RESULT_TABS = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L17)

<a id="function-function-minisql-admin-fullclient-newworksheet-function-newworksheet-index-sqltext-src-minisql-admin-fullclient-ml-1317041773"></a>
### newWorksheet

```ml
function newWorksheet(index, sqlText)
```

Creates a sequentially named independent SQL worksheet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1557)

<a id="function-function-minisql-admin-fullclient-numericcolumntype-function-numericcolumntype-typetext-src-minisql-admin-fullclient-ml-1673098235"></a>
### numericColumnType

```ml
function numericColumnType(typeText)
```

Returns whether a DESCRIBE type must be emitted as an unquoted numeric literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L984)

<a id="function-function-minisql-admin-fullclient-numericeditorvalue-function-numericeditorvalue-value-src-minisql-admin-fullclient-ml-56401961"></a>
### numericEditorValue

```ml
function numericEditorValue(value)
```

Performs a conservative lexical check before passing a numeric literal to MiniSQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L991)

<a id="function-function-minisql-admin-fullclient-openprofile-function-openprofile-profile-passwordbytes-src-minisql-admin-fullclient-ml-1723806739"></a>
### openProfile

```ml
function openProfile(profile, passwordBytes)
```

Opens a profile and eagerly loads the table tree.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L677)

<a id="function-function-minisql-admin-fullclient-opentransport-function-opentransport-profile-passwordbytes-src-minisql-admin-fullclient-ml-1414584071"></a>
### openTransport

```ml
function openTransport(profile, passwordBytes)
```

Opens the transport selected by a profile and wipes no caller-owned secret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L666)

<a id="function-function-minisql-admin-fullclient-parseclipboardrows-function-parseclipboardrows-text-src-minisql-admin-fullclient-ml-445398937"></a>
### parseClipboardRows

```ml
function parseClipboardRows(text)
```

Parses escaped TSV clipboard rows into a rectangular array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1513)

<a id="function-function-minisql-admin-fullclient-pendingdatachange-function-pendingdatachange-kind-sqltext-rowindex-values-src-minisql-admin-fullclient-ml-1131535285"></a>
### pendingDataChange

```ml
function pendingDataChange(kind, sqlText, rowIndex, values)
```

Creates one validated pending row change for preview and deferred application.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1346)

- [minisql.admin.fullclient.PendingDataChange](Type-minisql-admin-fullclient-pendingdatachange-2071346960.md) — struct
<a id="function-function-minisql-admin-fullclient-pendingdatasql-function-pendingdatasql-changes-src-minisql-admin-fullclient-ml-1784552505"></a>
### pendingDataSql

```ml
function pendingDataSql(changes)
```

Joins pending statements into the exact SQL preview submitted by Apply Changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `changes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1408)

<a id="function-function-minisql-admin-fullclient-previeweditorvalue-function-previeweditorvalue-value-src-minisql-admin-fullclient-ml-508934853"></a>
### previewEditorValue

```ml
function previewEditorValue(value)
```

Converts editor sentinels into the text shown by the optimistic data grid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1356)

<a id="function-function-minisql-admin-fullclient-previewrowfromvalues-function-previewrowfromvalues-details-values-src-minisql-admin-fullclient-ml-2136424298"></a>
### previewRowFromValues

```ml
function previewRowFromValues(details, values)
```

Aligns DESCRIBE-ordered editor values with SELECT result-column order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1363)

<a id="function-function-minisql-admin-fullclient-queryfortable-function-queryfortable-state-tablename-src-minisql-admin-fullclient-ml-1942406862"></a>
### queryForTable

```ml
function queryForTable(state, tableName)
```

Returns a SELECT template for the selected table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1689)

<a id="function-function-minisql-admin-fullclient-queryone-function-queryone-state-sqltext-src-minisql-admin-fullclient-ml-1735480708"></a>
### queryOne

```ml
function queryOne(state, sqlText)
```

Executes exactly one statement without changing editor history.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L710)

- [minisql.admin.fullclient.QueryView](Type-minisql-admin-fullclient-queryview-557506874.md) — struct
<a id="function-function-minisql-admin-fullclient-quotedcolumnlist-function-quotedcolumnlist-text-src-minisql-admin-fullclient-ml-18880321"></a>
### quotedColumnList

```ml
function quotedColumnList(text)
```

Quotes a comma-separated identifier list for CREATE INDEX generation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1134)

<a id="function-function-minisql-admin-fullclient-quotedidentifier-function-quotedidentifier-value-src-minisql-admin-fullclient-ml-484319457"></a>
### quotedIdentifier

```ml
function quotedIdentifier(value)
```

Quotes any non-empty MiniSQL identifier and doubles embedded quote characters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L235)

<a id="function-function-minisql-admin-fullclient-quotedobjectname-function-quotedobjectname-value-src-minisql-admin-fullclient-ml-1472274217"></a>
### quotedObjectName

```ml
function quotedObjectName(value)
```

Quotes a one- or two-part MiniSQL object name without treating a dot as data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L249)

<a id="function-function-minisql-admin-fullclient-quotedtextliteral-function-quotedtextliteral-value-src-minisql-admin-fullclient-ml-1864574461"></a>
### quotedTextLiteral

```ml
function quotedTextLiteral(value)
```

Quotes user-entered text as one SQL string literal and doubles embedded apostrophes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L272)

<a id="function-function-minisql-admin-fullclient-refresh-function-refresh-state-src-minisql-admin-fullclient-ml-1951105243"></a>
### refresh

```ml
function refresh(state)
```

Refreshes the object browser from SHOW TABLES without creating a result tab.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L901)

<a id="function-function-minisql-admin-fullclient-renderresponse-function-renderresponse-response-src-minisql-admin-fullclient-ml-1422798917"></a>
### renderResponse

```ml
function renderResponse(response)
```

Renders a response for detail pages and result messages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L718)

<a id="function-function-minisql-admin-fullclient-responsefailure-function-responsefailure-response-operation-src-minisql-admin-fullclient-ml-590184484"></a>
### responseFailure

```ml
function responseFailure(response, operation)
```

Converts a protocol response into an operation error when the server rejected SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L703)

- [minisql.admin.fullclient.ResultTab](Type-minisql-admin-fullclient-resulttab-871461383.md) — struct
<a id="function-function-minisql-admin-fullclient-resulttablines-function-resulttablines-tabs-src-minisql-admin-fullclient-ml-94531060"></a>
### resultTabLines

```ml
function resultTabLines(tabs)
```

Returns compact result-tab labels including status, rows, and elapsed time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1620)

<a id="function-function-minisql-admin-fullclient-rollbacktransaction-function-rollbacktransaction-state-src-minisql-admin-fullclient-ml-97778449"></a>
### rollbackTransaction

```ml
function rollbackTransaction(state)
```

Rolls back the current explicit MiniSQL transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L896)

<a id="function-function-minisql-admin-fullclient-schemaactionlines-function-schemaactionlines-src-minisql-admin-fullclient-ml-1308653676"></a>
### schemaActionLines

```ml
function schemaActionLines()
```

Returns the schema-designer actions in stable native-list order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1129)

<a id="function-function-minisql-admin-fullclient-schemaeditorsql-function-schemaeditorsql-action-tablename-objectname-definition-optiontext-src-minisql-admin-fullclient-ml-1808676032"></a>
### schemaEditorSql

```ml
function schemaEditorSql(action, tableName, objectName, definition, optionText)
```

Generates one previewable schema mutation from the structured designer fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `action` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |
| `objectName` | `dynamic` | — |  |
| `definition` | `dynamic` | — |  |
| `optionText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1148)

<a id="function-function-minisql-admin-fullclient-splitindexcolumns-function-splitindexcolumns-text-src-minisql-admin-fullclient-ml-462366051"></a>
### splitIndexColumns

```ml
function splitIndexColumns(text)
```

Splits the SHOW INDEXES comma-separated key column list into trimmed identifiers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1050)

<a id="constant-constant-minisql-admin-fullclient-sql-style-comment-const-sql-style-comment-4-src-minisql-admin-fullclient-ml-1549272917"></a>
### SQL_STYLE_COMMENT

```ml
const SQL_STYLE_COMMENT = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L25)

<a id="constant-constant-minisql-admin-fullclient-sql-style-keyword-const-sql-style-keyword-1-src-minisql-admin-fullclient-ml-177611606"></a>
### SQL_STYLE_KEYWORD

```ml
const SQL_STYLE_KEYWORD = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L22)

<a id="constant-constant-minisql-admin-fullclient-sql-style-number-const-sql-style-number-3-src-minisql-admin-fullclient-ml-922169666"></a>
### SQL_STYLE_NUMBER

```ml
const SQL_STYLE_NUMBER = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L24)

<a id="constant-constant-minisql-admin-fullclient-sql-style-quoted-identifier-const-sql-style-quoted-identifier-5-src-minisql-admin-fullclient-ml-441943134"></a>
### SQL_STYLE_QUOTED_IDENTIFIER

```ml
const SQL_STYLE_QUOTED_IDENTIFIER = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L26)

<a id="constant-constant-minisql-admin-fullclient-sql-style-string-const-sql-style-string-2-src-minisql-admin-fullclient-ml-1111678285"></a>
### SQL_STYLE_STRING

```ml
const SQL_STYLE_STRING = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L23)

- [minisql.admin.fullclient.SqlSyntaxAccumulator](Type-minisql-admin-fullclient-sqlsyntaxaccumulator-563422550.md) — struct
- [minisql.admin.fullclient.SqlSyntaxNode](Type-minisql-admin-fullclient-sqlsyntaxnode-1758912868.md) — struct
- [minisql.admin.fullclient.SqlSyntaxSpan](Type-minisql-admin-fullclient-sqlsyntaxspan-870812520.md) — struct
<a id="function-function-minisql-admin-fullclient-sqlsyntaxspans-function-sqlsyntaxspans-text-src-minisql-admin-fullclient-ml-302622013"></a>
### sqlSyntaxSpans

```ml
function sqlSyntaxSpans(text)
```

Lexes presentation-only SQL spans without invoking the parser or changing text. The scanner deliberately colors incomplete input and therefore remains useful while the user is typing. Offsets are UTF-16 units expected by RichEdit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L492)

<a id="function-function-minisql-admin-fullclient-sqltitle-function-sqltitle-sqltext-src-minisql-admin-fullclient-ml-400153671"></a>
### sqlTitle

```ml
function sqlTitle(sqlText)
```

Derives a compact result-tab title from the submitted SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L726)

<a id="function-function-minisql-admin-fullclient-syntaxspanarray-function-syntaxspanarray-accumulator-src-minisql-admin-fullclient-ml-1041055040"></a>
### syntaxSpanArray

```ml
function syntaxSpanArray(accumulator)
```

Materializes a linked syntax sequence into the array consumed by native code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `accumulator` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L476)

- [minisql.admin.fullclient.TableDetails](Type-minisql-admin-fullclient-tabledetails-664579555.md) — struct
<a id="function-function-minisql-admin-fullclient-targetmilestone-function-targetmilestone-src-minisql-admin-fullclient-ml-676595358"></a>
### targetMilestone

```ml
function targetMilestone()
```

Identifies the GUI integration milestone.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1701)

<a id="function-function-minisql-admin-fullclient-textcontains-function-textcontains-text-wanted-src-minisql-admin-fullclient-ml-1916470088"></a>
### textContains

```ml
function textContains(text, wanted)
```

Performs a byte-safe substring search without relying on host helpers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L286)

<a id="function-function-minisql-admin-fullclient-textforutf16range-function-textforutf16range-text-startoffset-endoffset-src-minisql-admin-fullclient-ml-1208955362"></a>
### textForUtf16Range

```ml
function textForUtf16Range(text, startOffset, endOffset)
```

Decodes one byte range whose boundaries were validated against UTF-16 offsets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |
| `endOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L359)

<a id="function-function-minisql-admin-fullclient-transactioncommand-function-transactioncommand-state-sqltext-activeafter-src-minisql-admin-fullclient-ml-400501634"></a>
### transactionCommand

```ml
function transactionCommand(state, sqlText, activeAfter)
```

Executes a transaction-control statement and updates toolbar state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |
| `activeAfter` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L878)

<a id="function-function-minisql-admin-fullclient-updatedatasql-function-updatedatasql-details-originalrow-values-src-minisql-admin-fullclient-ml-1552837669"></a>
### updateDataSql

```ml
function updateDataSql(details, originalRow, values)
```

Generates a key-constrained UPDATE statement for a selected preview row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `details` | `dynamic` | — |  |
| `originalRow` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1308)

<a id="function-function-minisql-admin-fullclient-utf16length-function-utf16length-text-src-minisql-admin-fullclient-ml-200871601"></a>
### utf16Length

```ml
function utf16Length(text)
```

Counts native RichEdit UTF-16 code units without losing supplementary characters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L329)

<a id="function-function-minisql-admin-fullclient-utf8step-function-utf8step-raw-index-src-minisql-admin-fullclient-ml-1948964850"></a>
### utf8Step

```ml
function utf8Step(raw, index)
```

Returns the UTF-8 byte width and UTF-16 code-unit width of one valid scalar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L319)

<a id="function-function-minisql-admin-fullclient-validatedsqlfragment-function-validatedsqlfragment-value-description-allowempty-src-minisql-admin-fullclient-ml-1330857609"></a>
### validatedSqlFragment

```ml
function validatedSqlFragment(value, description, allowEmpty)
```

Rejects statement separators and SQL comments from a user-entered SQL fragment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |
| `allowEmpty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1070)

- [minisql.admin.fullclient.Worksheet](Type-minisql-admin-fullclient-worksheet-1254434151.md) — struct
<a id="function-function-minisql-admin-fullclient-worksheetlines-function-worksheetlines-worksheets-src-minisql-admin-fullclient-ml-356885119"></a>
### worksheetLines

```ml
function worksheetLines(worksheets)
```

Returns stable worksheet labels for the native tab strip.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worksheets` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L1563)
