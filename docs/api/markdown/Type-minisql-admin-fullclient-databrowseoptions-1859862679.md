# `minisql.admin.fullclient.DataBrowseOptions`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-databrowseoptions-struct-databrowseoptions-src-minisql-admin-fullclient-ml-904229167"></a>
## DataBrowseOptions

```ml
struct DataBrowseOptions
```

Describes one stable server-side page of a table data browser.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L71)

## Members

<a id="field-field-minisql-admin-fullclient-databrowseoptions-ascending-ascending-src-minisql-admin-fullclient-ml-1450532553"></a>
### ascending

```ml
ascending
```

Selects ascending ordering when a sort column is present.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L77)

<a id="field-field-minisql-admin-fullclient-databrowseoptions-filtertext-filtertext-src-minisql-admin-fullclient-ml-1766416379"></a>
### filterText

```ml
filterText
```

Stores an optional SQL predicate entered in the WHERE filter box.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L73)

<a id="field-field-minisql-admin-fullclient-databrowseoptions-page-page-src-minisql-admin-fullclient-ml-955718619"></a>
### page

```ml
page
```

Stores the zero-based page number.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L79)

<a id="field-field-minisql-admin-fullclient-databrowseoptions-pagesize-pagesize-src-minisql-admin-fullclient-ml-4982401"></a>
### pageSize

```ml
pageSize
```

Stores the bounded number of rows requested per page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L81)

<a id="field-field-minisql-admin-fullclient-databrowseoptions-sortcolumn-sortcolumn-src-minisql-admin-fullclient-ml-1631357597"></a>
### sortColumn

```ml
sortColumn
```

Stores an optional exact result-column name used for ORDER BY.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L75)
