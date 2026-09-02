# `minisql.storage.btree.VisitState`

[Home](README.md) · [Source file](File-src-minisql-storage-btree-ml-1474397187.md)

<a id="struct-struct-minisql-storage-btree-visitstate-struct-visitstate-src-minisql-storage-btree-ml-207956409"></a>
## VisitState

```ml
struct VisitState
```

Defines the visit state record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L117)

## Members

<a id="field-field-minisql-storage-btree-visitstate-pages-pages-src-minisql-storage-btree-ml-1915476117"></a>
### pages

```ml
pages
```

One byte per physical page marks nodes already reached from the root. The bitmap is bounded by index-file size and never retains index entries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L120)
