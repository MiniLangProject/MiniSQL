# `minisql.storage.heap_file.HeapPageDirectory`

[Home](README.md) · [Source file](File-src-minisql-storage-heap-file-ml-1771906446.md)

<a id="struct-struct-minisql-storage-heap-file-heappagedirectory-struct-heappagedirectory-src-minisql-storage-heap-file-ml-990262845"></a>
## HeapPageDirectory

```ml
struct HeapPageDirectory
```

Represents one validated snapshot of the heap pages in a table file. The generation belongs to the paged-file superblock at `indexedPageCount`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L83)

## Members

<a id="field-field-minisql-storage-heap-file-heappagedirectory-generation-generation-src-minisql-storage-heap-file-ml-1807569339"></a>
### generation

```ml
generation
```

Source superblock generation at publication time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L87)

<a id="field-field-minisql-storage-heap-file-heappagedirectory-indexedpagecount-indexedpagecount-src-minisql-storage-heap-file-ml-1659582461"></a>
### indexedPageCount

```ml
indexedPageCount
```

Number of source pages classified by this snapshot.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L85)

<a id="field-field-minisql-storage-heap-file-heappagedirectory-pagenumbers-pagenumbers-src-minisql-storage-heap-file-ml-1550008879"></a>
### pageNumbers

```ml
pageNumbers
```

Strictly increasing physical page numbers whose type is TYPE_HEAP.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L89)
