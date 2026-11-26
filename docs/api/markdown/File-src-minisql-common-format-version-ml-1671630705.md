# `src/minisql/common/format_version.ml`

[Home](README.md) · [Files](Files.md)

Defines the incompatible storage generation independently of the wire protocol.

Package: [`minisql.common.format_version`](Package-minisql-common-format-version-2004555601.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-format-version-componentname-function-componentname-src-minisql-common-format-version-ml-1073231582"></a>
### componentName

```ml
function componentName()
```

Returns this module's stable component identity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L26)

<a id="constant-constant-minisql-common-format-version-database-const-database-2-src-minisql-common-format-version-ml-764786687"></a>
### DATABASE

```ml
const DATABASE = 2
```

Database generation requiring binary floats, aligned rows and table metadata pages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L9)

<a id="constant-constant-minisql-common-format-version-index-const-index-2-src-minisql-common-format-version-ml-1454053059"></a>
### INDEX

```ml
const INDEX = 2
```

Index format with typed, little-endian numeric keys and semantic comparison.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L13)

<a id="function-function-minisql-common-format-version-isimplemented-function-isimplemented-src-minisql-common-format-version-ml-658486638"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the version registry is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L36)

<a id="constant-constant-minisql-common-format-version-overflow-const-overflow-2-src-minisql-common-format-version-ml-729098809"></a>
### OVERFLOW

```ml
const OVERFLOW = 2
```

Overflow encoding with a U32 value length and an independent pointer checksum.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L17)

<a id="constant-constant-minisql-common-format-version-page-const-page-1-src-minisql-common-format-version-ml-413639752"></a>
### PAGE

```ml
const PAGE = 1
```

The common logical page header remains byte-compatible with its original layout.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L21)

<a id="constant-constant-minisql-common-format-version-row-const-row-2-src-minisql-common-format-version-ml-1183472955"></a>
### ROW

```ml
const ROW = 2
```

Row encoding with aligned values and little-endian IEEE-754 binary64 floats.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L15)

<a id="constant-constant-minisql-common-format-version-superblock-const-superblock-1-src-minisql-common-format-version-ml-2025666514"></a>
### SUPERBLOCK

```ml
const SUPERBLOCK = 1
```

The fixed redundant superblock layout remains unchanged.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L23)

<a id="constant-constant-minisql-common-format-version-table-const-table-2-src-minisql-common-format-version-ml-445597503"></a>
### TABLE

```ml
const TABLE = 2
```

User-table format with a mandatory identity page at logical page zero.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L11)

<a id="function-function-minisql-common-format-version-targetmilestone-function-targetmilestone-src-minisql-common-format-version-ml-682177592"></a>
### targetMilestone

```ml
function targetMilestone()
```

Identifies the storage-generation work that introduced this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L31)

<a id="constant-constant-minisql-common-format-version-wal-const-wal-1-src-minisql-common-format-version-ml-2113066804"></a>
### WAL

```ml
const WAL = 1
```

The existing WAL framing is unchanged; its page images carry storage generation two.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/format_version.ml#L19)
