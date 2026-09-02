# `minisql.executor.sort.SpillRun`

[Home](README.md) · [Source file](File-src-minisql-executor-sort-ml-267147473.md)

<a id="struct-struct-minisql-executor-sort-spillrun-struct-spillrun-src-minisql-executor-sort-ml-498208919"></a>
## SpillRun

```ml
struct SpillRun
```

Groups the spill run state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L33)

## Members

<a id="field-field-minisql-executor-sort-spillrun-ordercount-ordercount-src-minisql-executor-sort-ml-325950584"></a>
### orderCount

```ml
orderCount
```

Tracks the order count numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L43)

<a id="field-field-minisql-executor-sort-spillrun-path-path-src-minisql-executor-sort-ml-1185878960"></a>
### path

```ml
path
```

Stores the filesystem path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L35)

<a id="field-field-minisql-executor-sort-spillrun-rowcount-rowcount-src-minisql-executor-sort-ml-497254288"></a>
### rowCount

```ml
rowCount
```

Tracks the row count numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L45)

<a id="field-field-minisql-executor-sort-spillrun-rowschema-rowschema-src-minisql-executor-sort-ml-1220776890"></a>
### rowSchema

```ml
rowSchema
```

Contains the ordered row schema collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L37)

<a id="field-field-minisql-executor-sort-spillrun-typekinds-typekinds-src-minisql-executor-sort-ml-2030878354"></a>
### typeKinds

```ml
typeKinds
```

Stores the type kinds associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L39)

<a id="field-field-minisql-executor-sort-spillrun-valuecount-valuecount-src-minisql-executor-sort-ml-1549647130"></a>
### valueCount

```ml
valueCount
```

Tracks the value count numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L41)
