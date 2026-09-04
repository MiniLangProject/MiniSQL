# `minisql.sql.ast.GrantPrivilegeStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-grantprivilegestatement-struct-grantprivilegestatement-src-minisql-sql-ast-ml-1433309241"></a>
## GrantPrivilegeStatement

```ml
struct GrantPrivilegeStatement
```

Groups the grant privilege statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L851)

## Members

<a id="field-field-minisql-sql-ast-grantprivilegestatement-granteename-granteename-src-minisql-sql-ast-ml-1429229949"></a>
### granteeName

```ml
granteeName
```

Stores the grantee name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L859)

<a id="field-field-minisql-sql-ast-grantprivilegestatement-grantoption-grantoption-src-minisql-sql-ast-ml-1771978169"></a>
### grantOption

```ml
grantOption
```

Stores the grant option associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L861)

<a id="field-field-minisql-sql-ast-grantprivilegestatement-objectname-objectname-src-minisql-sql-ast-ml-1118005765"></a>
### objectName

```ml
objectName
```

Stores the object name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L857)

<a id="field-field-minisql-sql-ast-grantprivilegestatement-objecttype-objecttype-src-minisql-sql-ast-ml-1457671067"></a>
### objectType

```ml
objectType
```

Stores the object type associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L855)

<a id="field-field-minisql-sql-ast-grantprivilegestatement-privileges-privileges-src-minisql-sql-ast-ml-1021175681"></a>
### privileges

```ml
privileges
```

Contains the ordered privileges collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L853)
