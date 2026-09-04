# `minisql.executor.dml.InsertCursor`

[Home](README.md) · [Source file](File-src-minisql-executor-dml-ml-1278137778.md)

<a id="struct-struct-minisql-executor-dml-insertcursor-struct-insertcursor-src-minisql-executor-dml-ml-139197787"></a>
## InsertCursor

```ml
struct InsertCursor
```

Tracks the last heap page considered by a statement-local bulk insert.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L85)

## Members

<a id="field-field-minisql-executor-dml-insertcursor-allocationbatch-allocationbatch-src-minisql-executor-dml-ml-1679639670"></a>
### allocationBatch

```ml
allocationBatch
```

Maximum number of empty heap pages reserved by one durability barrier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L89)

<a id="field-field-minisql-executor-dml-insertcursor-pagenumber-pagenumber-src-minisql-executor-dml-ml-1700220258"></a>
### pageNumber

```ml
pageNumber
```

First page that can still have capacity during the current insert batch.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L87)

<a id="field-field-minisql-executor-dml-insertcursor-remainingrows-remainingrows-src-minisql-executor-dml-ml-1952287014"></a>
### remainingRows

```ml
remainingRows
```

Rows not yet staged, used to avoid reserving unused tail pages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L91)
