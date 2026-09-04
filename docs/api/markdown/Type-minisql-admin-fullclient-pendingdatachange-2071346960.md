# `minisql.admin.fullclient.PendingDataChange`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-pendingdatachange-struct-pendingdatachange-src-minisql-admin-fullclient-ml-733735049"></a>
## PendingDataChange

```ml
struct PendingDataChange
```

Retains one unapplied row change so the grid can preview and later commit it.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L85)

## Members

<a id="field-field-minisql-admin-fullclient-pendingdatachange-kind-kind-src-minisql-admin-fullclient-ml-1308449410"></a>
### kind

```ml
kind
```

Stores INSERT, UPDATE, or DELETE for presentation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L87)

<a id="field-field-minisql-admin-fullclient-pendingdatachange-rowindex-rowindex-src-minisql-admin-fullclient-ml-1159130798"></a>
### rowIndex

```ml
rowIndex
```

Stores -1 for inserts or the original page-row index for updates/deletes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L91)

<a id="field-field-minisql-admin-fullclient-pendingdatachange-sqltext-sqltext-src-minisql-admin-fullclient-ml-1185529678"></a>
### sqlText

```ml
sqlText
```

Stores the generated, key-constrained SQL statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L89)

<a id="field-field-minisql-admin-fullclient-pendingdatachange-values-values-src-minisql-admin-fullclient-ml-1666606722"></a>
### values

```ml
values
```

Stores editor values aligned with DESCRIBE metadata when available.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L93)
