# `src/minisql/storage/btree.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage btree facilities for this project.

Package: [`minisql.storage.btree`](Package-minisql-storage-btree-1716250021.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-storage-btree-allentries-function-allentries-tree-src-minisql-storage-btree-ml-304192544"></a>
### allEntries

```ml
function allEntries(tree)
```

Performs the all entries operation for this module. Inputs: `tree`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L807)

<a id="function-function-minisql-storage-btree-auditleafchain-function-auditleafchain-tree-src-minisql-storage-btree-ml-1222439520"></a>
### auditLeafChain

```ml
function auditLeafChain(tree)
```

Walks the active leaf generation one page at a time. Only the previous entry remains live between pages, so structural validation does not materialize the complete index. The page-count guard turns a corrupt forward-link cycle into a deterministic error without a second visited-page collection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L837)

<a id="function-function-minisql-storage-btree-auditnode-function-auditnode-tree-pagenumber-expectedlevel-state-src-minisql-storage-btree-ml-282196879"></a>
### auditNode

```ml
function auditNode(tree, pageNumber, expectedLevel, state)
```

Performs the audit node operation for this module. Inputs: `tree`, `pageNumber`, `expectedLevel`, `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `expectedLevel` | `dynamic` | — | expectedLevel value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1129)

- [minisql.storage.btree.BTree](Type-minisql-storage-btree-btree-129466497.md) — struct
- [minisql.storage.btree.BTreeAudit](Type-minisql-storage-btree-btreeaudit-1014624468.md) — struct
- [minisql.storage.btree.BTreeEntry](Type-minisql-storage-btree-btreeentry-1599338031.md) — struct
- [minisql.storage.btree.BTreeInternal](Type-minisql-storage-btree-btreeinternal-698637796.md) — struct
- [minisql.storage.btree.BTreeLeaf](Type-minisql-storage-btree-btreeleaf-1180898761.md) — struct
- [minisql.storage.btree.BTreeMeta](Type-minisql-storage-btree-btreemeta-1168535116.md) — struct
<a id="function-function-minisql-storage-btree-bulkload-function-bulkload-tree-values-src-minisql-storage-btree-ml-1643248522"></a>
### bulkLoad

```ml
function bulkLoad(tree, values)
```

Performs the bulk load operation for this module. Inputs: `tree`, `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L797)

<a id="function-function-minisql-storage-btree-bytesequal-function-bytesequal-left-right-src-minisql-storage-btree-ml-638325327"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql storage btree module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L176)

<a id="function-function-minisql-storage-btree-choosemeta-function-choosemeta-first-second-src-minisql-storage-btree-ml-1493140172"></a>
### chooseMeta

```ml
function chooseMeta(first, second)
```

Performs the choose meta operation for this module. Inputs: `first`, `second`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | first value consumed by this operation. |
| `second` | `dynamic` | — | second value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L392)

<a id="function-function-minisql-storage-btree-chunkentries-function-chunkentries-values-pagesize-src-minisql-storage-btree-ml-1560533940"></a>
### chunkEntries

```ml
function chunkEntries(values, pageSize)
```

Performs the chunk entries operation for this module. Inputs: `values`, `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L686)

<a id="function-function-minisql-storage-btree-close-function-close-tree-src-minisql-storage-btree-ml-1598693584"></a>
### close

```ml
function close(tree)
```

Closes close owned by the minisql storage btree module. Inputs: `tree`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1201)

<a id="constant-constant-minisql-storage-btree-closed-handle-const-closed-handle-9008-src-minisql-storage-btree-ml-861742094"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L22)

<a id="function-function-minisql-storage-btree-commitsorted-function-commitsorted-tree-values-src-minisql-storage-btree-ml-1889270466"></a>
### commitSorted

```ml
function commitSorted(tree, values)
```

Commits the sorted. Inputs: `tree`, `values`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L742)

<a id="function-function-minisql-storage-btree-compareentries-function-compareentries-left-right-src-minisql-storage-btree-ml-813618475"></a>
### compareEntries

```ml
function compareEntries(left, right)
```

Compares the entries. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L208)

<a id="function-function-minisql-storage-btree-comparekeys-function-comparekeys-left-right-src-minisql-storage-btree-ml-1219268477"></a>
### compareKeys

```ml
function compareKeys(left, right)
```

Compares the keys. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L189)

<a id="function-function-minisql-storage-btree-componentname-function-componentname-src-minisql-storage-btree-ml-1535933160"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage btree module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1210)

<a id="function-function-minisql-storage-btree-containsentry-function-containsentry-tree-expected-src-minisql-storage-btree-ml-699816718"></a>
### containsEntry

```ml
function containsEntry(tree, expected)
```

Tests one complete key/value entry without building allEntries(). At most one leaf page and its small decoded entry array are retained at a time. Equal-key predecessor leaves are included so non-unique indexes remain exact even when a duplicate run crosses a leaf boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L905)

<a id="function-function-minisql-storage-btree-copyentry-function-copyentry-value-src-minisql-storage-btree-ml-962533537"></a>
### copyEntry

```ml
function copyEntry(value)
```

Copies the entry. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L228)

<a id="constant-constant-minisql-storage-btree-corrupt-data-const-corrupt-data-9004-src-minisql-storage-btree-ml-656652144"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L20)

<a id="function-function-minisql-storage-btree-count-function-count-tree-src-minisql-storage-btree-ml-1558978018"></a>
### count

```ml
function count(tree)
```

Counts the requested value. Inputs: `tree`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1177)

<a id="function-function-minisql-storage-btree-create-function-create-path-pagesize-fileid-databaseid-unique-src-minisql-storage-btree-ml-428455165"></a>
### create

```ml
function create(path, pageSize, fileId, databaseId, unique)
```

Creates create for the minisql storage btree module. Inputs: `path`, `pageSize`, `fileId`, `databaseId`, `unique`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `unique` | `dynamic` | — | unique value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L416)

<a id="function-function-minisql-storage-btree-decodeinternal-function-decodeinternal-tree-pagenumber-src-minisql-storage-btree-ml-1010670406"></a>
### decodeInternal

```ml
function decodeInternal(tree, pageNumber)
```

Decodes one internal node without retaining positioned-read setup.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L678)

<a id="function-function-minisql-storage-btree-decodeinternalwithcontext-function-decodeinternalwithcontext-tree-pagenumber-readcontext-src-minisql-storage-btree-ml-1660257631"></a>
### decodeInternalWithContext

```ml
function decodeInternalWithContext(tree, pageNumber, readContext)
```

Decodes the internal. Inputs: `tree`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L640)

<a id="function-function-minisql-storage-btree-decodeleaf-function-decodeleaf-tree-pagenumber-src-minisql-storage-btree-ml-1860519834"></a>
### decodeLeaf

```ml
function decodeLeaf(tree, pageNumber)
```

Decodes one leaf without retaining positioned-read setup across calls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L593)

<a id="function-function-minisql-storage-btree-decodeleafwithcontext-function-decodeleafwithcontext-tree-pagenumber-readcontext-src-minisql-storage-btree-ml-162776037"></a>
### decodeLeafWithContext

```ml
function decodeLeafWithContext(tree, pageNumber, readContext)
```

Decodes the leaf. Inputs: `tree`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L560)

<a id="function-function-minisql-storage-btree-decodemetapage-function-decodemetapage-treefile-pagenumber-src-minisql-storage-btree-ml-18858320"></a>
### decodeMetaPage

```ml
function decodeMetaPage(treeFile, pageNumber)
```

Decodes the meta page. Inputs: `treeFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `treeFile` | `dynamic` | — | treeFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L363)

<a id="function-function-minisql-storage-btree-decodenative-function-decodenative-words-operation-name-src-minisql-storage-btree-ml-1514441641"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes native for the minisql storage btree workflow. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | words value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L353)

<a id="function-function-minisql-storage-btree-encodeinternal-function-encodeinternal-tree-pagenumber-level-descriptors-src-minisql-storage-btree-ml-1408795798"></a>
### encodeInternal

```ml
function encodeInternal(tree, pageNumber, level, descriptors)
```

Encodes the internal. Inputs: `tree`, `pageNumber`, `level`, `descriptors`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `level` | `dynamic` | — | level value consumed by this operation. |
| `descriptors` | `dynamic` | — | descriptors value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L603)

<a id="function-function-minisql-storage-btree-encodeleaf-function-encodeleaf-tree-pagenumber-previouspage-nextpage-values-src-minisql-storage-btree-ml-1082243172"></a>
### encodeLeaf

```ml
function encodeLeaf(tree, pageNumber, previousPage, nextPage, values)
```

Encodes the leaf. Inputs: `tree`, `pageNumber`, `previousPage`, `nextPage`, `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `previousPage` | `dynamic` | — | previousPage value consumed by this operation. |
| `nextPage` | `dynamic` | — | nextPage value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L521)

<a id="function-function-minisql-storage-btree-encodemetapage-function-encodemetapage-treefile-pagenumber-generation-unique-rootpage-firstleaf-lastleaf-height-entrycount-src-minisql-storage-btree-ml-1472260786"></a>
### encodeMetaPage

```ml
function encodeMetaPage(treeFile, pageNumber, generation, unique, rootPage, firstLeaf, lastLeaf, height, entryCount)
```

Encodes the meta page. Inputs: `treeFile`, `pageNumber`, `generation`, `unique`, `rootPage`, `firstLeaf`, `lastLeaf`, `height`, `entryCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `treeFile` | `dynamic` | — | treeFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `generation` | `dynamic` | — | generation value consumed by this operation. |
| `unique` | `dynamic` | — | unique value consumed by this operation. |
| `rootPage` | `dynamic` | — | rootPage value consumed by this operation. |
| `firstLeaf` | `dynamic` | — | firstLeaf value consumed by this operation. |
| `lastLeaf` | `dynamic` | — | lastLeaf value consumed by this operation. |
| `height` | `dynamic` | — | Height in the coordinate or storage units used by the caller. |
| `entryCount` | `dynamic` | — | Number of entry to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L316)

<a id="function-function-minisql-storage-btree-entry-function-entry-key-value-src-minisql-storage-btree-ml-4224476"></a>
### entry

```ml
function entry(key, value)
```

Performs the entry operation for this module. Inputs: `key`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L219)

<a id="function-function-minisql-storage-btree-fail-function-fail-code-operation-message-src-minisql-storage-btree-ml-2143870441"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage btree module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L150)

<a id="function-function-minisql-storage-btree-find-function-find-tree-key-src-minisql-storage-btree-ml-1108622593"></a>
### find

```ml
function find(tree, key)
```

Finds values without retaining positioned-read setup across page reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1034)

<a id="function-function-minisql-storage-btree-findwithcontext-function-findwithcontext-tree-key-readcontext-src-minisql-storage-btree-ml-1627758102"></a>
### findWithContext

```ml
function findWithContext(tree, key, readContext)
```

Finds the requested value. Inputs: `tree`, `key`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L992)

<a id="constant-constant-minisql-storage-btree-flag-meta-const-flag-meta-32768-src-minisql-storage-btree-ml-409131251"></a>
### FLAG_META

```ml
const FLAG_META = 32768
```

Defines the flag meta constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L53)

<a id="constant-constant-minisql-storage-btree-flag-unique-const-flag-unique-1-src-minisql-storage-btree-ml-1767315518"></a>
### FLAG_UNIQUE

```ml
const FLAG_UNIQUE = 1
```

Defines the flag unique constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L51)

<a id="constant-constant-minisql-storage-btree-format-version-const-format-version-1-src-minisql-storage-btree-ml-140704084"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```

Defines the format version constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L29)

<a id="function-function-minisql-storage-btree-height-function-height-tree-src-minisql-storage-btree-ml-1211433548"></a>
### height

```ml
function height(tree)
```

Performs the height operation for this module. Inputs: `tree`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1185)

<a id="function-function-minisql-storage-btree-insert-function-insert-tree-key-value-src-minisql-storage-btree-ml-738273672"></a>
### insert

```ml
function insert(tree, key, value)
```

Performs the insert operation for the minisql storage btree module. Inputs: `tree`, `key`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L944)

<a id="constant-constant-minisql-storage-btree-internal-data-offset-const-internal-data-offset-88-src-minisql-storage-btree-ml-1408411819"></a>
### INTERNAL_DATA_OFFSET

```ml
const INTERNAL_DATA_OFFSET = 88
```

Defines the internal data offset constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L41)

<a id="function-function-minisql-storage-btree-internalmagic-function-internalmagic-src-minisql-storage-btree-ml-2134122928"></a>
### internalMagic

```ml
function internalMagic()
```

Performs the internal magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L168)

<a id="constant-constant-minisql-storage-btree-invalid-argument-const-invalid-argument-9001-src-minisql-storage-btree-ml-1551839931"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Persistent B+ tree v1.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L16)

<a id="function-function-minisql-storage-btree-isimplemented-function-isimplemented-src-minisql-storage-btree-ml-1883775896"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage btree module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1222)

<a id="function-function-minisql-storage-btree-isunique-function-isunique-tree-src-minisql-storage-btree-ml-721780756"></a>
### isUnique

```ml
function isUnique(tree)
```

Evaluates whether the supplied input satisfies the unique predicate. Inputs: `tree`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1193)

<a id="constant-constant-minisql-storage-btree-leaf-data-offset-const-leaf-data-offset-96-src-minisql-storage-btree-ml-446659412"></a>
### LEAF_DATA_OFFSET

```ml
const LEAF_DATA_OFFSET = 96
```

Defines the leaf data offset constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L39)

<a id="function-function-minisql-storage-btree-leafmagic-function-leafmagic-src-minisql-storage-btree-ml-1666210738"></a>
### leafMagic

```ml
function leafMagic()
```

Performs the leaf magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L162)

<a id="function-function-minisql-storage-btree-locateleaf-function-locateleaf-tree-key-src-minisql-storage-btree-ml-1847517933"></a>
### locateLeaf

```ml
function locateLeaf(tree, key)
```

Locates one leaf without a reusable positioned-read context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L895)

<a id="function-function-minisql-storage-btree-locateleafwithcontext-function-locateleafwithcontext-tree-key-readcontext-src-minisql-storage-btree-ml-2141609176"></a>
### locateLeafWithContext

```ml
function locateLeafWithContext(tree, key, readContext)
```

Descends through separator keys to the leaf that owns the rightmost range beginning at or before key. Non-unique indexes deliberately allow equal separators when a duplicate run spans leaves, so containsEntry subsequently walks backward over equal-key predecessors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L872)

<a id="constant-constant-minisql-storage-btree-max-internal-children-const-max-internal-children-12-src-minisql-storage-btree-ml-1653419868"></a>
### MAX_INTERNAL_CHILDREN

```ml
const MAX_INTERNAL_CHILDREN = 12
```

Defines the max internal children constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L49)

<a id="constant-constant-minisql-storage-btree-max-key-bytes-const-max-key-bytes-256-src-minisql-storage-btree-ml-1803503068"></a>
### MAX_KEY_BYTES

```ml
const MAX_KEY_BYTES = 256
```

Defines the max key bytes constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L43)

<a id="constant-constant-minisql-storage-btree-max-leaf-entries-const-max-leaf-entries-10-src-minisql-storage-btree-ml-412124260"></a>
### MAX_LEAF_ENTRIES

```ml
const MAX_LEAF_ENTRIES = 10
```

Defines the max leaf entries constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L47)

<a id="constant-constant-minisql-storage-btree-max-value-bytes-const-max-value-bytes-3584-src-minisql-storage-btree-ml-819686281"></a>
### MAX_VALUE_BYTES

```ml
const MAX_VALUE_BYTES = 3584
```

A leaf value may use the space remaining on the minimum supported 4 KiB


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L45)

<a id="function-function-minisql-storage-btree-mergesorted-function-mergesorted-left-right-src-minisql-storage-btree-ml-1557720837"></a>
### mergeSorted

```ml
function mergeSorted(left, right)
```

Merges the sorted. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L237)

<a id="constant-constant-minisql-storage-btree-meta-data-offset-const-meta-data-offset-64-src-minisql-storage-btree-ml-1032112221"></a>
### META_DATA_OFFSET

```ml
const META_DATA_OFFSET = 64
```

Defines the meta data offset constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L35)

<a id="constant-constant-minisql-storage-btree-meta-data-size-const-meta-data-size-64-src-minisql-storage-btree-ml-1910557789"></a>
### META_DATA_SIZE

```ml
const META_DATA_SIZE = 64
```

Defines the meta data size constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L37)

<a id="constant-constant-minisql-storage-btree-meta-page-a-const-meta-page-a-0-src-minisql-storage-btree-ml-2145884863"></a>
### META_PAGE_A

```ml
const META_PAGE_A = 0
```

Defines the meta page a constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L31)

<a id="constant-constant-minisql-storage-btree-meta-page-b-const-meta-page-b-1-src-minisql-storage-btree-ml-1502617810"></a>
### META_PAGE_B

```ml
const META_PAGE_B = 1
```

Defines the meta page b constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L33)

<a id="function-function-minisql-storage-btree-metamagic-function-metamagic-src-minisql-storage-btree-ml-1414963488"></a>
### metaMagic

```ml
function metaMagic()
```

Performs the meta magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L156)

- [minisql.storage.btree.NodeDescriptor](Type-minisql-storage-btree-nodedescriptor-1027824740.md) — struct
<a id="constant-constant-minisql-storage-btree-object-exists-const-object-exists-9013-src-minisql-storage-btree-ml-1911349022"></a>
### OBJECT_EXISTS

```ml
const OBJECT_EXISTS = 9013
```

Defines the object exists constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L24)

<a id="constant-constant-minisql-storage-btree-object-not-found-const-object-not-found-9014-src-minisql-storage-btree-ml-608342987"></a>
### OBJECT_NOT_FOUND

```ml
const OBJECT_NOT_FOUND = 9014
```

Defines the object not found constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L26)

<a id="function-function-minisql-storage-btree-open-function-open-path-src-minisql-storage-btree-ml-1067946583"></a>
### open

```ml
function open(path)
```

Opens open for the minisql storage btree module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L460)

<a id="function-function-minisql-storage-btree-openreadonly-function-openreadonly-path-src-minisql-storage-btree-ml-1734688875"></a>
### openReadOnly

```ml
function openReadOnly(path)
```

Opens the read only. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L467)

<a id="function-function-minisql-storage-btree-openreadonlyforlookup-function-openreadonlyforlookup-path-src-minisql-storage-btree-ml-655027473"></a>
### openReadOnlyForLookup

```ml
function openReadOnlyForLookup(path)
```

Opens a read-only tree for an ordinary lookup without auditing unrelated branches. The paged-file superblock and both redundant tree metadata pages are still decoded and checksum validated here; find/range subsequently verify every internal and leaf page they actually traverse. Full graph and leaf-chain audits remain available through openReadOnly plus verify and are used by explicit consistency checks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L478)

<a id="function-function-minisql-storage-btree-openreadonlyformanagedlookup-function-openreadonlyformanagedlookup-path-src-minisql-storage-btree-ml-1037068571"></a>
### openReadOnlyForManagedLookup

```ml
function openReadOnlyForManagedLookup(path)
```

ManagedDatabase cache variant of openReadOnlyForLookup. The owning database lock and execution gate replace a long-lived per-index byte-range lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L492)

<a id="function-function-minisql-storage-btree-opentreefile-function-opentreefile-treefile-src-minisql-storage-btree-ml-1086454918"></a>
### openTreeFile

```ml
function openTreeFile(treeFile)
```

Opens the tree file. Inputs: `treeFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `treeFile` | `dynamic` | — | treeFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L429)

<a id="function-function-minisql-storage-btree-publish-function-publish-tree-rootpage-firstleaf-lastleaf-height-entrycount-src-minisql-storage-btree-ml-1410154387"></a>
### publish

```ml
function publish(tree, rootPage, firstLeaf, lastLeaf, height, entryCount)
```

Performs the publish operation for this module. Inputs: `tree`, `rootPage`, `firstLeaf`, `lastLeaf`, `height`, `entryCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `rootPage` | `dynamic` | — | rootPage value consumed by this operation. |
| `firstLeaf` | `dynamic` | — | firstLeaf value consumed by this operation. |
| `lastLeaf` | `dynamic` | — | lastLeaf value consumed by this operation. |
| `height` | `dynamic` | — | Height in the coordinate or storage units used by the caller. |
| `entryCount` | `dynamic` | — | Number of entry to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L726)

<a id="function-function-minisql-storage-btree-range-function-range-tree-lower-lowerinclusive-upper-upperinclusive-maximum-src-minisql-storage-btree-ml-1143369316"></a>
### range

```ml
function range(tree, lower, lowerInclusive, upper, upperInclusive, maximum)
```

Scans a range without retaining positioned-read setup across page reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `lower` | `dynamic` | — | lower value consumed by this operation. |
| `lowerInclusive` | `dynamic` | — | lowerInclusive value consumed by this operation. |
| `upper` | `dynamic` | — | upper value consumed by this operation. |
| `upperInclusive` | `dynamic` | — | upperInclusive value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1111)

<a id="function-function-minisql-storage-btree-rangewithcontext-function-rangewithcontext-tree-lower-lowerinclusive-upper-upperinclusive-maximum-readcontext-src-minisql-storage-btree-ml-1940410515"></a>
### rangeWithContext

```ml
function rangeWithContext(tree, lower, lowerInclusive, upper, upperInclusive, maximum, readContext)
```

Performs the range operation for this module. Inputs: `tree`, `lower`, `lowerInclusive`, `upper`, `upperInclusive`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `lower` | `dynamic` | — | lower value consumed by this operation. |
| `lowerInclusive` | `dynamic` | — | lowerInclusive value consumed by this operation. |
| `upper` | `dynamic` | — | upper value consumed by this operation. |
| `upperInclusive` | `dynamic` | — | upperInclusive value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1047)

<a id="function-function-minisql-storage-btree-remove-function-remove-tree-key-value-src-minisql-storage-btree-ml-159743392"></a>
### remove

```ml
function remove(tree, key, value)
```

Removes remove from the state managed by the minisql storage btree module. Inputs: `tree`, `key`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L969)

<a id="function-function-minisql-storage-btree-slicearray-function-slicearray-values-offset-count-src-minisql-storage-btree-ml-1176188886"></a>
### sliceArray

```ml
function sliceArray(values, offset, count)
```

Performs the slice array operation for this module. Inputs: `values`, `offset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L709)

<a id="function-function-minisql-storage-btree-sortentries-function-sortentries-values-src-minisql-storage-btree-ml-446483214"></a>
### sortEntries

```ml
function sortEntries(values)
```

Orders the entries. Inputs: `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L268)

<a id="function-function-minisql-storage-btree-targetmilestone-function-targetmilestone-src-minisql-storage-btree-ml-1921177446"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage btree module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1216)

<a id="constant-constant-minisql-storage-btree-unsupported-format-const-unsupported-format-9003-src-minisql-storage-btree-ml-1338510201"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql storage btree module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L18)

<a id="function-function-minisql-storage-btree-validateopen-function-validateopen-tree-operation-src-minisql-storage-btree-ml-2077186735"></a>
### validateOpen

```ml
function validateOpen(tree, operation)
```

Validates open for the minisql storage btree workflow. Inputs: `tree`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L507)

<a id="function-function-minisql-storage-btree-validatesorted-function-validatesorted-values-unique-operation-src-minisql-storage-btree-ml-1382432732"></a>
### validateSorted

```ml
function validateSorted(values, unique, operation)
```

Validates the sorted. Inputs: `values`, `unique`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |
| `unique` | `dynamic` | — | unique value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L289)

<a id="function-function-minisql-storage-btree-verify-function-verify-tree-src-minisql-storage-btree-ml-1625814372"></a>
### verify

```ml
function verify(tree)
```

Performs the verify operation for the minisql storage btree module. Inputs: `tree`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tree` | `dynamic` | — | tree value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1162)

<a id="function-function-minisql-storage-btree-visitcontains-function-visitcontains-state-pagenumber-src-minisql-storage-btree-ml-2078111669"></a>
### visitContains

```ml
function visitContains(state, pageNumber)
```

Performs the visit contains operation for this module. Inputs: `state`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/btree.ml#L1119)

- [minisql.storage.btree.VisitState](Type-minisql-storage-btree-visitstate-1033435189.md) — struct
