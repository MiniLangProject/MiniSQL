# `minisql.admin.fullclient.FullClientState`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-fullclientstate-struct-fullclientstate-src-minisql-admin-fullclient-ml-1647362049"></a>
## FullClientState

```ml
struct FullClientState
```

Owns the state shared by the MiniSQL object browser and SQL worksheet.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L189)

## Members

<a id="field-field-minisql-admin-fullclient-fullclientstate-bookmarks-bookmarks-src-minisql-admin-fullclient-ml-1744698610"></a>
### bookmarks

```ml
bookmarks
```

Contains built-in reusable SQL templates.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L213)

<a id="field-field-minisql-admin-fullclient-fullclientstate-history-history-src-minisql-admin-fullclient-ml-745114798"></a>
### history

```ml
history
```

Retains bounded, redacted SQL history.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L211)

<a id="field-field-minisql-admin-fullclient-fullclientstate-profile-profile-src-minisql-admin-fullclient-ml-582247478"></a>
### profile

```ml
profile
```

Stores the immutable connection profile.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L191)

<a id="field-field-minisql-admin-fullclient-fullclientstate-querytext-querytext-src-minisql-admin-fullclient-ml-1484656906"></a>
### queryText

```ml
queryText
```

Stores the latest editor text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L201)

<a id="field-field-minisql-admin-fullclient-fullclientstate-queryview-queryview-src-minisql-admin-fullclient-ml-1394902630"></a>
### queryView

```ml
queryView
```

Stores the latest execution summary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L203)

<a id="field-field-minisql-admin-fullclient-fullclientstate-remoteclient-remoteclient-src-minisql-admin-fullclient-ml-945687220"></a>
### remoteClient

```ml
remoteClient
```

Owns the active protocol client.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L193)

<a id="field-field-minisql-admin-fullclient-fullclientstate-resulttabs-resulttabs-src-minisql-admin-fullclient-ml-15386148"></a>
### resultTabs

```ml
resultTabs
```

Retains bounded structured result tabs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L207)

<a id="field-field-minisql-admin-fullclient-fullclientstate-selectedresultindex-selectedresultindex-src-minisql-admin-fullclient-ml-1607999758"></a>
### selectedResultIndex

```ml
selectedResultIndex
```

Selects the result tab rendered in the grid.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L209)

<a id="field-field-minisql-admin-fullclient-fullclientstate-selectedtable-selectedtable-src-minisql-admin-fullclient-ml-1255945358"></a>
### selectedTable

```ml
selectedTable
```

Stores the object-browser selection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L197)

<a id="field-field-minisql-admin-fullclient-fullclientstate-statustext-statustext-src-minisql-admin-fullclient-ml-655625684"></a>
### statusText

```ml
statusText
```

Stores a concise user-facing state message.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L205)

<a id="field-field-minisql-admin-fullclient-fullclientstate-tabledetails-tabledetails-src-minisql-admin-fullclient-ml-1331496522"></a>
### tableDetails

```ml
tableDetails
```

Stores details for the selected table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L199)

<a id="field-field-minisql-admin-fullclient-fullclientstate-tables-tables-src-minisql-admin-fullclient-ml-2054046468"></a>
### tables

```ml
tables
```

Contains table names reported by SHOW TABLES.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L195)

<a id="field-field-minisql-admin-fullclient-fullclientstate-transactionactive-transactionactive-src-minisql-admin-fullclient-ml-1376552698"></a>
### transactionActive

```ml
transactionActive
```

Tracks an explicit transaction started by the workbench.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L215)
