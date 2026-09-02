# `minisql.admin.fullclient.TableDetails`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-tabledetails-struct-tabledetails-src-minisql-admin-fullclient-ml-56819441"></a>
## TableDetails

```ml
struct TableDetails
```

Captures the metadata pages shown for a selected table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L93)

## Members

<a id="field-field-minisql-admin-fullclient-tabledetails-columnsgrid-columnsgrid-src-minisql-admin-fullclient-ml-16992141"></a>
### columnsGrid

```ml
columnsGrid
```

Retains structured DESCRIBE metadata for the Columns grid and row editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L109)

<a id="field-field-minisql-admin-fullclient-tabledetails-columnstext-columnstext-src-minisql-admin-fullclient-ml-856768101"></a>
### columnsText

```ml
columnsText
```

Stores the formatted DESCRIBE response.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L99)

<a id="field-field-minisql-admin-fullclient-tabledetails-contentsgrid-contentsgrid-src-minisql-admin-fullclient-ml-482357245"></a>
### contentsGrid

```ml
contentsGrid
```

Retains structured preview data for the editable Data grid.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L113)

<a id="field-field-minisql-admin-fullclient-tabledetails-contentstext-contentstext-src-minisql-admin-fullclient-ml-1738654543"></a>
### contentsText

```ml
contentsText
```

Stores the formatted preview query response.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L103)

<a id="field-field-minisql-admin-fullclient-tabledetails-ddltext-ddltext-src-minisql-admin-fullclient-ml-2080151561"></a>
### ddlText

```ml
ddlText
```

Stores reconstructed CREATE TABLE SQL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L107)

<a id="field-field-minisql-admin-fullclient-tabledetails-indexesgrid-indexesgrid-src-minisql-admin-fullclient-ml-2042202957"></a>
### indexesGrid

```ml
indexesGrid
```

Retains structured SHOW INDEXES metadata for the Indexes grid.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L111)

<a id="field-field-minisql-admin-fullclient-tabledetails-indexestext-indexestext-src-minisql-admin-fullclient-ml-1461401365"></a>
### indexesText

```ml
indexesText
```

Stores the formatted SHOW INDEXES response.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L101)

<a id="field-field-minisql-admin-fullclient-tabledetails-rowcountgrid-rowcountgrid-src-minisql-admin-fullclient-ml-1363265407"></a>
### rowCountGrid

```ml
rowCountGrid
```

Retains the structured COUNT response for the Row Count page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L115)

<a id="field-field-minisql-admin-fullclient-tabledetails-rowcounttext-rowcounttext-src-minisql-admin-fullclient-ml-1962993469"></a>
### rowCountText

```ml
rowCountText
```

Stores the formatted row-count response.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L105)

<a id="field-field-minisql-admin-fullclient-tabledetails-summarytext-summarytext-src-minisql-admin-fullclient-ml-1334034941"></a>
### summaryText

```ml
summaryText
```

Stores the compact table summary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L97)

<a id="field-field-minisql-admin-fullclient-tabledetails-tablename-tablename-src-minisql-admin-fullclient-ml-1158346733"></a>
### tableName

```ml
tableName
```

Stores the selected table name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L95)
