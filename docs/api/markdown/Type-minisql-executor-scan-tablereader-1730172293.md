# `minisql.executor.scan.TableReader`

[Home](README.md) · [Source file](File-src-minisql-executor-scan-ml-657274302.md)

<a id="struct-struct-minisql-executor-scan-tablereader-struct-tablereader-src-minisql-executor-scan-ml-1607153209"></a>
## TableReader

```ml
struct TableReader
```

Groups the table reader state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L57)

## Members

<a id="field-field-minisql-executor-scan-tablereader-closed-closed-src-minisql-executor-scan-ml-2085864628"></a>
### closed

```ml
closed
```

Indicates whether the closed condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L81)

<a id="field-field-minisql-executor-scan-tablereader-controldatabase-controldatabase-src-minisql-executor-scan-ml-351171480"></a>
### controlDatabase

```ml
controlDatabase
```

Optional production-control registry polled at physical page boundaries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L77)

<a id="field-field-minisql-executor-scan-tablereader-controlsessionid-controlsessionid-src-minisql-executor-scan-ml-406172216"></a>
### controlSessionId

```ml
controlSessionId
```

Operational session whose token is attached to this reader.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L79)

<a id="field-field-minisql-executor-scan-tablereader-databasepath-databasepath-src-minisql-executor-scan-ml-1490654712"></a>
### databasePath

```ml
databasePath
```

Stores the filesystem database path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L59)

<a id="field-field-minisql-executor-scan-tablereader-file-file-src-minisql-executor-scan-ml-1585852572"></a>
### file

```ml
file
```

Stores the filesystem file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L67)

<a id="field-field-minisql-executor-scan-tablereader-generatedcolumns-generatedcolumns-src-minisql-executor-scan-ml-504482532"></a>
### generatedColumns

```ml
generatedColumns
```

Stores the generated columns associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L65)

<a id="field-field-minisql-executor-scan-tablereader-ownsfile-ownsfile-src-minisql-executor-scan-ml-750394938"></a>
### ownsFile

```ml
ownsFile
```

Stores the filesystem owns file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L73)

<a id="field-field-minisql-executor-scan-tablereader-pagetransaction-pagetransaction-src-minisql-executor-scan-ml-2098422716"></a>
### pageTransaction

```ml
pageTransaction
```

Stores the page transaction associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L71)

<a id="field-field-minisql-executor-scan-tablereader-readcache-readcache-src-minisql-executor-scan-ml-177781524"></a>
### readCache

```ml
readCache
```

Optional database-owned concurrent read cache.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L75)

<a id="field-field-minisql-executor-scan-tablereader-rowschema-rowschema-src-minisql-executor-scan-ml-683349944"></a>
### rowSchema

```ml
rowSchema
```

Contains the ordered row schema collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L69)

<a id="field-field-minisql-executor-scan-tablereader-table-table-src-minisql-executor-scan-ml-527985504"></a>
### table

```ml
table
```

Stores the table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L61)

<a id="field-field-minisql-executor-scan-tablereader-tableschema-tableschema-src-minisql-executor-scan-ml-1838548988"></a>
### tableSchema

```ml
tableSchema
```

Contains the ordered table schema collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L63)
