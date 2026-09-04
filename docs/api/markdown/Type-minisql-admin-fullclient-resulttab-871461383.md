# `minisql.admin.fullclient.ResultTab`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-resulttab-struct-resulttab-src-minisql-admin-fullclient-ml-1491348203"></a>
## ResultTab

```ml
struct ResultTab
```

Retains one structured SQL result page for native grid rendering.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L173)

## Members

<a id="field-field-minisql-admin-fullclient-resulttab-columns-columns-src-minisql-admin-fullclient-ml-825080109"></a>
### columns

```ml
columns
```

Stores ordered result column names.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L185)

<a id="field-field-minisql-admin-fullclient-resulttab-elapsedmilliseconds-elapsedmilliseconds-src-minisql-admin-fullclient-ml-1429957665"></a>
### elapsedMilliseconds

```ml
elapsedMilliseconds
```

Stores elapsed wall-clock milliseconds.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L189)

<a id="field-field-minisql-admin-fullclient-resulttab-resulttext-resulttext-src-minisql-admin-fullclient-ml-1116847949"></a>
### resultText

```ml
resultText
```

Stores the formatted response text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L179)

<a id="field-field-minisql-admin-fullclient-resulttab-rowcount-rowcount-src-minisql-admin-fullclient-ml-258000639"></a>
### rowCount

```ml
rowCount
```

Counts rows retained in this result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L181)

<a id="field-field-minisql-admin-fullclient-resulttab-rows-rows-src-minisql-admin-fullclient-ml-777283487"></a>
### rows

```ml
rows
```

Stores ordered textual result rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L187)

<a id="field-field-minisql-admin-fullclient-resulttab-sqltext-sqltext-src-minisql-admin-fullclient-ml-290968125"></a>
### sqlText

```ml
sqlText
```

Stores redacted SQL suitable for history display.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L177)

<a id="field-field-minisql-admin-fullclient-resulttab-success-success-src-minisql-admin-fullclient-ml-1043905405"></a>
### success

```ml
success
```

Indicates whether execution succeeded.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L183)

<a id="field-field-minisql-admin-fullclient-resulttab-title-title-src-minisql-admin-fullclient-ml-1394016169"></a>
### title

```ml
title
```

Stores the concise tab title derived from SQL text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L175)
