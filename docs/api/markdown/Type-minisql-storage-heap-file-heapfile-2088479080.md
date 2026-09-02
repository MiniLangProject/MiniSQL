# `minisql.storage.heap_file.HeapFile`

[Home](README.md) · [Source file](File-src-minisql-storage-heap-file-ml-1771906446.md)

<a id="struct-struct-minisql-storage-heap-file-heapfile-struct-heapfile-src-minisql-storage-heap-file-ml-338351099"></a>
## HeapFile

```ml
struct HeapFile
```

Defines the heap file record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L67)

## Members

<a id="field-field-minisql-storage-heap-file-heapfile-closed-closed-src-minisql-storage-heap-file-ml-1157758671"></a>
### closed

```ml
closed
```

Closed field of the heap file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L73)

<a id="field-field-minisql-storage-heap-file-heapfile-insertionpagehint-insertionpagehint-src-minisql-storage-heap-file-ml-1619094899"></a>
### insertionPageHint

```ml
insertionPageHint
```

Page most likely to accept the next row without a whole-file free-space scan.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L71)

<a id="field-field-minisql-storage-heap-file-heapfile-pagedfile-pagedfile-src-minisql-storage-heap-file-ml-1786440263"></a>
### pagedFile

```ml
pagedFile
```

Paged file field of the heap file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L69)
