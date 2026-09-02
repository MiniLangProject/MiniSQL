# `minisql.executor.scan.TableRowCursor`

[Home](README.md) · [Source file](File-src-minisql-executor-scan-ml-657274302.md)

<a id="struct-struct-minisql-executor-scan-tablerowcursor-struct-tablerowcursor-src-minisql-executor-scan-ml-1868271005"></a>
## TableRowCursor

```ml
struct TableRowCursor
```

Holds a forward-only live-row scan. The cursor retains one heap page and one decoded row at a time; callers can therefore validate or consume tables whose total payload is much larger than the MiniLang heap.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L85)

## Members

<a id="field-field-minisql-executor-scan-tablerowcursor-endpageindex-endpageindex-src-minisql-executor-scan-ml-2032663143"></a>
### endPageIndex

```ml
endPageIndex
```

Exclusive heap-page index at which this cursor stops. Keeping the bound in the cursor lets independent read-only workers scan disjoint page ranges.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L96)

<a id="field-field-minisql-executor-scan-tablerowcursor-finished-finished-src-minisql-executor-scan-ml-492790583"></a>
### finished

```ml
finished
```

Indicates that every page and slot has been consumed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L102)

<a id="field-field-minisql-executor-scan-tablerowcursor-heappages-heappages-src-minisql-executor-scan-ml-828741607"></a>
### heapPages

```ml
heapPages
```

Persistent-directory result containing physical heap page numbers only.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L91)

<a id="field-field-minisql-executor-scan-tablerowcursor-pagebytes-pagebytes-src-minisql-executor-scan-ml-1626194367"></a>
### pageBytes

```ml
pageBytes
```

Checksummed bytes for the current heap page, or void between pages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L98)

<a id="field-field-minisql-executor-scan-tablerowcursor-pageindex-pageindex-src-minisql-executor-scan-ml-1601405411"></a>
### pageIndex

```ml
pageIndex
```

Index of the heap page currently being visited.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L93)

<a id="field-field-minisql-executor-scan-tablerowcursor-reader-reader-src-minisql-executor-scan-ml-385669045"></a>
### reader

```ml
reader
```

Reader that supplies transaction visibility, schema, and overflow access.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L87)

<a id="field-field-minisql-executor-scan-tablerowcursor-requiredcolumns-requiredcolumns-src-minisql-executor-scan-ml-772596447"></a>
### requiredColumns

```ml
requiredColumns
```

Optional column mask used to avoid unrelated overflow payload reads.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L89)

<a id="field-field-minisql-executor-scan-tablerowcursor-slotid-slotid-src-minisql-executor-scan-ml-2127051457"></a>
### slotId

```ml
slotId
```

Next slot to inspect within pageBytes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L100)
