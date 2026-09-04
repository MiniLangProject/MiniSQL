# `minisql.sql.ast.MergeStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-mergestatement-struct-mergestatement-src-minisql-sql-ast-ml-726670523"></a>
## MergeStatement

```ml
struct MergeStatement
```

Represents a source-driven conditional INSERT/UPDATE/DELETE operation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L691)

## Members

<a id="field-field-minisql-sql-ast-mergestatement-condition-condition-src-minisql-sql-ast-ml-1858769316"></a>
### condition

```ml
condition
```

Stores the target/source match predicate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L701)

<a id="field-field-minisql-sql-ast-mergestatement-insertcolumns-insertcolumns-src-minisql-sql-ast-ml-1339718740"></a>
### insertColumns

```ml
insertColumns
```

Contains target columns for WHEN NOT MATCHED INSERT.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L707)

<a id="field-field-minisql-sql-ast-mergestatement-insertvalues-insertvalues-src-minisql-sql-ast-ml-272374358"></a>
### insertValues

```ml
insertValues
```

Contains source expressions for WHEN NOT MATCHED INSERT.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L709)

<a id="field-field-minisql-sql-ast-mergestatement-matchedassignments-matchedassignments-src-minisql-sql-ast-ml-1057172560"></a>
### matchedAssignments

```ml
matchedAssignments
```

Contains assignments for WHEN MATCHED UPDATE.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L703)

<a id="field-field-minisql-sql-ast-mergestatement-matcheddelete-matcheddelete-src-minisql-sql-ast-ml-2111009544"></a>
### matchedDelete

```ml
matchedDelete
```

Indicates WHEN MATCHED DELETE semantics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L705)

<a id="field-field-minisql-sql-ast-mergestatement-sourcealias-sourcealias-src-minisql-sql-ast-ml-746581204"></a>
### sourceAlias

```ml
sourceAlias
```

Stores the optional source alias.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L699)

<a id="field-field-minisql-sql-ast-mergestatement-sourcetable-sourcetable-src-minisql-sql-ast-ml-1145833332"></a>
### sourceTable

```ml
sourceTable
```

Stores the source table name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L697)

<a id="field-field-minisql-sql-ast-mergestatement-targetalias-targetalias-src-minisql-sql-ast-ml-1909575192"></a>
### targetAlias

```ml
targetAlias
```

Stores the optional target alias.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L695)

<a id="field-field-minisql-sql-ast-mergestatement-targettable-targettable-src-minisql-sql-ast-ml-1883750344"></a>
### targetTable

```ml
targetTable
```

Stores the target table name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L693)
