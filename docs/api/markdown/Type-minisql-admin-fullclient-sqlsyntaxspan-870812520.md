# `minisql.admin.fullclient.SqlSyntaxSpan`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-sqlsyntaxspan-struct-sqlsyntaxspan-src-minisql-admin-fullclient-ml-1631777381"></a>
## SqlSyntaxSpan

```ml
struct SqlSyntaxSpan
```

Describes one syntax-colored UTF-16 range in the native SQL worksheet.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L145)

## Members

<a id="field-field-minisql-admin-fullclient-sqlsyntaxspan-endoffset-endoffset-src-minisql-admin-fullclient-ml-2078998126"></a>
### endOffset

```ml
endOffset
```

Stores the exclusive UTF-16 end offset used by the RichEdit control.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L149)

<a id="field-field-minisql-admin-fullclient-sqlsyntaxspan-kind-kind-src-minisql-admin-fullclient-ml-1079389262"></a>
### kind

```ml
kind
```

Selects one of the SQL_STYLE_* presentation categories.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L151)

<a id="field-field-minisql-admin-fullclient-sqlsyntaxspan-startoffset-startoffset-src-minisql-admin-fullclient-ml-1157669558"></a>
### startOffset

```ml
startOffset
```

Stores the inclusive UTF-16 start offset used by the RichEdit control.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L147)
