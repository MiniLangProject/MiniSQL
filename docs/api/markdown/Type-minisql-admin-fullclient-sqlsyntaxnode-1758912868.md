# `minisql.admin.fullclient.SqlSyntaxNode`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-sqlsyntaxnode-struct-sqlsyntaxnode-src-minisql-admin-fullclient-ml-487509565"></a>
## SqlSyntaxNode

```ml
struct SqlSyntaxNode
```

Links presentation spans during a linear-time lexer pass.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L143)

## Members

<a id="field-field-minisql-admin-fullclient-sqlsyntaxnode-next-next-src-minisql-admin-fullclient-ml-1207455468"></a>
### next

```ml
next
```

Points to the next node or void at the tail.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L147)

<a id="field-field-minisql-admin-fullclient-sqlsyntaxnode-span-span-src-minisql-admin-fullclient-ml-938750254"></a>
### span

```ml
span
```

Stores the syntax span owned by this node.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L145)
