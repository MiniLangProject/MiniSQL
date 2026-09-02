# `minisql.sql.ast.RevokePrivilegeStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-revokeprivilegestatement-struct-revokeprivilegestatement-src-minisql-sql-ast-ml-959069331"></a>
## RevokePrivilegeStatement

```ml
struct RevokePrivilegeStatement
```

Groups the revoke privilege statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L810)

## Members

<a id="field-field-minisql-sql-ast-revokeprivilegestatement-cascade-cascade-src-minisql-sql-ast-ml-738057797"></a>
### cascade

```ml
cascade
```

Stores the cascade associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L820)

<a id="field-field-minisql-sql-ast-revokeprivilegestatement-granteename-granteename-src-minisql-sql-ast-ml-1894741981"></a>
### granteeName

```ml
granteeName
```

Stores the grantee name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L818)

<a id="field-field-minisql-sql-ast-revokeprivilegestatement-objectname-objectname-src-minisql-sql-ast-ml-1762416741"></a>
### objectName

```ml
objectName
```

Stores the object name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L816)

<a id="field-field-minisql-sql-ast-revokeprivilegestatement-objecttype-objecttype-src-minisql-sql-ast-ml-548653179"></a>
### objectType

```ml
objectType
```

Stores the object type associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L814)

<a id="field-field-minisql-sql-ast-revokeprivilegestatement-privileges-privileges-src-minisql-sql-ast-ml-1283017825"></a>
### privileges

```ml
privileges
```

Contains the ordered privileges collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L812)
