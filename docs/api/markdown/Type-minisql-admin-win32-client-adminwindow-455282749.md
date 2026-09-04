# `minisql.admin.win32_client.AdminWindow`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-adminwindow-struct-adminwindow-src-minisql-admin-win32-client-ml-1923838873"></a>
## AdminWindow

```ml
struct AdminWindow
```

Owns all native controls in one MiniSQL session workbench.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L256)

## Members

<a id="field-field-minisql-admin-win32-client-adminwindow-beginbutton-beginbutton-src-minisql-admin-win32-client-ml-1433465080"></a>
### beginButton

```ml
beginButton
```

Stores the begin-transaction button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L306)

<a id="field-field-minisql-admin-win32-client-adminwindow-bookmarklist-bookmarklist-src-minisql-admin-win32-client-ml-402844432"></a>
### bookmarkList

```ml
bookmarkList
```

Stores reusable SQL bookmarks.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L266)

<a id="field-field-minisql-admin-win32-client-adminwindow-clearbutton-clearbutton-src-minisql-admin-win32-client-ml-1499153324"></a>
### clearButton

```ml
clearButton
```

Stores the clear-results button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L314)

<a id="field-field-minisql-admin-win32-client-adminwindow-closebutton-closebutton-src-minisql-admin-win32-client-ml-2794328"></a>
### closeButton

```ml
closeButton
```

Stores the close-session button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L316)

<a id="field-field-minisql-admin-win32-client-adminwindow-closesqlbutton-closesqlbutton-src-minisql-admin-win32-client-ml-1909227080"></a>
### closeSqlButton

```ml
closeSqlButton
```

Closes the active SQL worksheet while retaining at least one page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L322)

<a id="field-field-minisql-admin-win32-client-adminwindow-commitbutton-commitbutton-src-minisql-admin-win32-client-ml-1494778014"></a>
### commitButton

```ml
commitButton
```

Stores the commit button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L308)

<a id="field-field-minisql-admin-win32-client-adminwindow-connectionlabel-connectionlabel-src-minisql-admin-win32-client-ml-1240902760"></a>
### connectionLabel

```ml
connectionLabel
```

Stores the active endpoint heading.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L260)

<a id="field-field-minisql-admin-win32-client-adminwindow-dataaddbutton-dataaddbutton-src-minisql-admin-win32-client-ml-1612056580"></a>
### dataAddButton

```ml
dataAddButton
```

Starts a blank row editor on the Data page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L282)

<a id="field-field-minisql-admin-win32-client-adminwindow-dataapplybutton-dataapplybutton-src-minisql-admin-win32-client-ml-140856148"></a>
### dataApplyButton

```ml
dataApplyButton
```

Executes all previewed row changes through the background worker.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L344)

<a id="field-field-minisql-admin-win32-client-adminwindow-datacopybutton-datacopybutton-src-minisql-admin-win32-client-ml-1263238974"></a>
### dataCopyButton

```ml
dataCopyButton
```

Starts an insert editor populated from the selected row.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L284)

<a id="field-field-minisql-admin-win32-client-adminwindow-datacopyclipboardbutton-datacopyclipboardbutton-src-minisql-admin-win32-client-ml-241833400"></a>
### dataCopyClipboardButton

```ml
dataCopyClipboardButton
```

Copies every selected data row to escaped TSV clipboard text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L330)

<a id="field-field-minisql-admin-win32-client-adminwindow-datadeletebutton-datadeletebutton-src-minisql-admin-win32-client-ml-750287798"></a>
### dataDeleteButton

```ml
dataDeleteButton
```

Deletes the selected keyed row after explicit confirmation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L288)

<a id="field-field-minisql-admin-win32-client-adminwindow-dataeditbutton-dataeditbutton-src-minisql-admin-win32-client-ml-933476168"></a>
### dataEditButton

```ml
dataEditButton
```

Starts an update editor for the selected keyed row.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L286)

<a id="field-field-minisql-admin-win32-client-adminwindow-datafilterbutton-datafilterbutton-src-minisql-admin-win32-client-ml-252205128"></a>
### dataFilterButton

```ml
dataFilterButton
```

Applies the current Data-page filter and resets pagination.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L336)

<a id="field-field-minisql-admin-win32-client-adminwindow-datafilteredit-datafilteredit-src-minisql-admin-win32-client-ml-1617603588"></a>
### dataFilterEdit

```ml
dataFilterEdit
```

Stores the server-side WHERE predicate used by the Data page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L334)

<a id="field-field-minisql-admin-win32-client-adminwindow-datanextbutton-datanextbutton-src-minisql-admin-win32-client-ml-577432722"></a>
### dataNextButton

```ml
dataNextButton
```

Loads the next bounded Data page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L340)

<a id="field-field-minisql-admin-win32-client-adminwindow-datapagelabel-datapagelabel-src-minisql-admin-win32-client-ml-2064775436"></a>
### dataPageLabel

```ml
dataPageLabel
```

Shows current page, page size, and pending-change count.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L342)

<a id="field-field-minisql-admin-win32-client-adminwindow-datapastebutton-datapastebutton-src-minisql-admin-win32-client-ml-2147325252"></a>
### dataPasteButton

```ml
dataPasteButton
```

Stages clipboard TSV rows as INSERT changes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L332)

<a id="field-field-minisql-admin-win32-client-adminwindow-datapreviewbutton-datapreviewbutton-src-minisql-admin-win32-client-ml-284632376"></a>
### dataPreviewButton

```ml
dataPreviewButton
```

Shows the exact generated SQL for pending changes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L348)

<a id="field-field-minisql-admin-win32-client-adminwindow-datapreviousbutton-datapreviousbutton-src-minisql-admin-win32-client-ml-1780646082"></a>
### dataPreviousButton

```ml
dataPreviousButton
```

Loads the preceding bounded Data page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L338)

<a id="field-field-minisql-admin-win32-client-adminwindow-datarefreshbutton-datarefreshbutton-src-minisql-admin-win32-client-ml-370399716"></a>
### dataRefreshButton

```ml
dataRefreshButton
```

Reloads table metadata and preview rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L290)

<a id="field-field-minisql-admin-win32-client-adminwindow-datarevertbutton-datarevertbutton-src-minisql-admin-win32-client-ml-1238959620"></a>
### dataRevertButton

```ml
dataRevertButton
```

Discards every unapplied row change.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L346)

<a id="field-field-minisql-admin-win32-client-adminwindow-detailedit-detailedit-src-minisql-admin-win32-client-ml-1964004502"></a>
### detailEdit

```ml
detailEdit
```

Stores read-only table-detail text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L278)

<a id="field-field-minisql-admin-win32-client-adminwindow-detailgrid-detailgrid-src-minisql-admin-win32-client-ml-1443094850"></a>
### detailGrid

```ml
detailGrid
```

Stores structured Columns, Indexes, Data, and Row Count detail pages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L280)

<a id="field-field-minisql-admin-win32-client-adminwindow-detailtabs-detailtabs-src-minisql-admin-win32-client-ml-93101122"></a>
### detailTabs

```ml
detailTabs
```

Stores table-detail page tabs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L272)

<a id="field-field-minisql-admin-win32-client-adminwindow-executebutton-executebutton-src-minisql-admin-win32-client-ml-909067192"></a>
### executeButton

```ml
executeButton
```

Stores the execute button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L300)

<a id="field-field-minisql-admin-win32-client-adminwindow-executescriptbutton-executescriptbutton-src-minisql-admin-win32-client-ml-1405027364"></a>
### executeScriptButton

```ml
executeScriptButton
```

Stores the whole-script execution button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L302)

<a id="field-field-minisql-admin-win32-client-adminwindow-explainbutton-explainbutton-src-minisql-admin-win32-client-ml-1622076900"></a>
### explainButton

```ml
explainButton
```

Stores the explain button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L304)

<a id="field-field-minisql-admin-win32-client-adminwindow-exportcsvbutton-exportcsvbutton-src-minisql-admin-win32-client-ml-277887752"></a>
### exportCsvButton

```ml
exportCsvButton
```

Exports the active structured result page as UTF-8 CSV.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L324)

<a id="field-field-minisql-admin-win32-client-adminwindow-historyfilteredit-historyfilteredit-src-minisql-admin-win32-client-ml-421068024"></a>
### historyFilterEdit

```ml
historyFilterEdit
```

Filters the History sidebar without changing retained history.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L328)

<a id="field-field-minisql-admin-win32-client-adminwindow-historylist-historylist-src-minisql-admin-win32-client-ml-718961728"></a>
### historyList

```ml
historyList
```

Stores redacted SQL history.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L268)

<a id="field-field-minisql-admin-win32-client-adminwindow-hwnd-hwnd-src-minisql-admin-win32-client-ml-528223770"></a>
### hwnd

```ml
hwnd
```

Stores the top-level workbench handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L258)

<a id="field-field-minisql-admin-win32-client-adminwindow-newsqlbutton-newsqlbutton-src-minisql-admin-win32-client-ml-1512089604"></a>
### newSqlButton

```ml
newSqlButton
```

Stores the new-worksheet button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L298)

<a id="field-field-minisql-admin-win32-client-adminwindow-objecttree-objecttree-src-minisql-admin-win32-client-ml-1489228978"></a>
### objectTree

```ml
objectTree
```

Stores the hierarchical database object browser.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L264)

<a id="field-field-minisql-admin-win32-client-adminwindow-openbutton-openbutton-src-minisql-admin-win32-client-ml-70539976"></a>
### openButton

```ml
openButton
```

Stores the open-object button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L296)

<a id="field-field-minisql-admin-win32-client-adminwindow-queryedit-queryedit-src-minisql-admin-win32-client-ml-1722670860"></a>
### queryEdit

```ml
queryEdit
```

Stores the multiline SQL editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L276)

<a id="field-field-minisql-admin-win32-client-adminwindow-refreshbutton-refreshbutton-src-minisql-admin-win32-client-ml-654920244"></a>
### refreshButton

```ml
refreshButton
```

Stores the object-tree refresh button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L294)

<a id="field-field-minisql-admin-win32-client-adminwindow-resultgrid-resultgrid-src-minisql-admin-win32-client-ml-917996850"></a>
### resultGrid

```ml
resultGrid
```

Stores structured SQL result rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L292)

<a id="field-field-minisql-admin-win32-client-adminwindow-resulttabs-resulttabs-src-minisql-admin-win32-client-ml-544747762"></a>
### resultTabs

```ml
resultTabs
```

Stores SQL result tabs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L274)

<a id="field-field-minisql-admin-win32-client-adminwindow-rollbackbutton-rollbackbutton-src-minisql-admin-win32-client-ml-798079112"></a>
### rollbackButton

```ml
rollbackButton
```

Stores the rollback button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L310)

<a id="field-field-minisql-admin-win32-client-adminwindow-schemabutton-schemabutton-src-minisql-admin-win32-client-ml-147475202"></a>
### schemaButton

```ml
schemaButton
```

Opens the structured MiniSQL schema designer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L326)

<a id="field-field-minisql-admin-win32-client-adminwindow-sidebartabs-sidebartabs-src-minisql-admin-win32-client-ml-1563702580"></a>
### sidebarTabs

```ml
sidebarTabs
```

Stores the sidebar tab control.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L262)

<a id="field-field-minisql-admin-win32-client-adminwindow-statuslabel-statuslabel-src-minisql-admin-win32-client-ml-2072791772"></a>
### statusLabel

```ml
statusLabel
```

Stores the workbench status line.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L318)

<a id="field-field-minisql-admin-win32-client-adminwindow-stopbutton-stopbutton-src-minisql-admin-win32-client-ml-1318326792"></a>
### stopButton

```ml
stopButton
```

Stores the stop-worker button.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L312)

<a id="field-field-minisql-admin-win32-client-adminwindow-worksheettabs-worksheettabs-src-minisql-admin-win32-client-ml-369462908"></a>
### worksheetTabs

```ml
worksheetTabs
```

Stores independent SQL worksheet tabs above the active editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L320)

<a id="field-field-minisql-admin-win32-client-adminwindow-workspacetabs-workspacetabs-src-minisql-admin-win32-client-ml-298292584"></a>
### workspaceTabs

```ml
workspaceTabs
```

Stores the SQL/details workspace tab control.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L270)
