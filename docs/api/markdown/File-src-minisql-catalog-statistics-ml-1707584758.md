# `src/minisql/catalog/statistics.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql catalog statistics facilities for this project.

Package: [`minisql.catalog.statistics`](Package-minisql-catalog-statistics-1606211552.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)

## Declarations

<a id="function-function-minisql-catalog-statistics-analyzesample-function-analyzesample-table-populationrows-rows-pagecount-src-minisql-catalog-statistics-ml-1250963425"></a>
### analyzeSample

```ml
function analyzeSample(table, populationRows, rows, pageCount)
```

Retains the public single-column ANALYZE API used by older callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `pageCount` | `dynamic` | — | Number of page to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L718)

<a id="function-function-minisql-catalog-statistics-analyzesamplewithgroups-function-analyzesamplewithgroups-table-populationrows-rows-pagecount-columngroups-src-minisql-catalog-statistics-ml-2109569963"></a>
### analyzeSampleWithGroups

```ml
function analyzeSampleWithGroups(table, populationRows, rows, pageCount, columnGroups)
```

Builds bounded-memory statistics from a uniformly spaced sample. Small tables, whose sample contains every row, remain exact. Low-cardinality values seen repeatedly are treated as saturated; high-cardinality samples are scaled conservatively and capped by the estimated non-NULL population.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `pageCount` | `dynamic` | — | Number of page to process. |
| `columnGroups` | `dynamic` | — | columnGroups value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L661)

<a id="function-function-minisql-catalog-statistics-analyzetable-function-analyzetable-table-rows-pagecount-src-minisql-catalog-statistics-ml-23324639"></a>
### analyzeTable

```ml
function analyzeTable(table, rows, pageCount)
```

Performs the analyze table operation for this module. Inputs: `table`, `rows`, `pageCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `pageCount` | `dynamic` | — | Number of page to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L727)

<a id="constant-constant-minisql-catalog-statistics-bounds-format-version-const-bounds-format-version-3-src-minisql-catalog-statistics-ml-167461614"></a>
### BOUNDS_FORMAT_VERSION

```ml
const BOUNDS_FORMAT_VERSION = 3
```

Defines the bounds format version constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L30)

<a id="function-function-minisql-catalog-statistics-bytesequal-function-bytesequal-left-right-src-minisql-catalog-statistics-ml-515183063"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql catalog statistics module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L203)

<a id="constant-constant-minisql-catalog-statistics-column-bytes-const-column-bytes-232-src-minisql-catalog-statistics-ml-1112926118"></a>
### COLUMN_BYTES

```ml
const COLUMN_BYTES = 232
```

Defines the column bytes constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L42)

<a id="constant-constant-minisql-catalog-statistics-column-flag-hashed-mcv-const-column-flag-hashed-mcv-2-src-minisql-catalog-statistics-ml-248219107"></a>
### COLUMN_FLAG_HASHED_MCV

```ml
const COLUMN_FLAG_HASHED_MCV = 2
```

Defines the column flag hashed mcv constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L54)

<a id="constant-constant-minisql-catalog-statistics-column-flag-integral-bounds-const-column-flag-integral-bounds-1-src-minisql-catalog-statistics-ml-388289452"></a>
### COLUMN_FLAG_INTEGRAL_BOUNDS

```ml
const COLUMN_FLAG_INTEGRAL_BOUNDS = 1
```

Defines the column flag integral bounds constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L52)

<a id="constant-constant-minisql-catalog-statistics-column-group-bytes-const-column-group-bytes-128-src-minisql-catalog-statistics-ml-4266284"></a>
### COLUMN_GROUP_BYTES

```ml
const COLUMN_GROUP_BYTES = 128
```

Defines the column group bytes constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L46)

- [minisql.catalog.statistics.ColumnGroupStatistics](Type-minisql-catalog-statistics-columngroupstatistics-647698160.md) — struct
- [minisql.catalog.statistics.ColumnStatistics](Type-minisql-catalog-statistics-columnstatistics-1679950787.md) — struct
<a id="function-function-minisql-catalog-statistics-compactstatisticscalar-function-compactstatisticscalar-candidate-src-minisql-catalog-statistics-ml-1029670255"></a>
### compactStatisticScalar

```ml
function compactStatisticScalar(candidate)
```

Converts one ordered SQL value to the compact histogram scalar when possible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `candidate` | `dynamic` | — | candidate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L361)

<a id="function-function-minisql-catalog-statistics-componentname-function-componentname-src-minisql-catalog-statistics-ml-1208793912"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql catalog statistics module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1160)

<a id="constant-constant-minisql-catalog-statistics-corrupt-data-const-corrupt-data-9004-src-minisql-catalog-statistics-ml-989850832"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L21)

<a id="function-function-minisql-catalog-statistics-create-function-create-databaseid-src-minisql-catalog-statistics-ml-253783548"></a>
### create

```ml
function create(databaseId)
```

Creates create for the minisql catalog statistics module. Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L215)

<a id="function-function-minisql-catalog-statistics-decode-function-decode-encoded-src-minisql-catalog-statistics-ml-2018924002"></a>
### decode

```ml
function decode(encoded)
```

Keep the qualified public API statistics.decode(...), while every internal call uses an unambiguous helper. MiniLang also exposes decode(bytes) as a builtin, so an unqualified internal decode(...) call may otherwise bind to UTF-8 decoding instead of the statistics catalog decoder. Decodes the requested value. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1095)

<a id="function-function-minisql-catalog-statistics-decodecatalog-function-decodecatalog-encoded-src-minisql-catalog-statistics-ml-1779189864"></a>
### decodeCatalog

```ml
function decodeCatalog(encoded)
```

Decodes the catalog. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1034)

<a id="function-function-minisql-catalog-statistics-decodecolumngrouprecord-function-decodecolumngrouprecord-payload-cursor-encodedversion-rowcount-destination-destinationindex-src-minisql-catalog-statistics-ml-1574939893"></a>
### decodeColumnGroupRecord

```ml
function decodeColumnGroupRecord(payload, cursor, encodedVersion, rowCount, destination, destinationIndex)
```

Decodes one column-group record directly into its preallocated destination.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | Validated statistics payload being decoded. |
| `cursor` | `dynamic` | — | Byte offset at which the group record begins. |
| `encodedVersion` | `dynamic` | — | On-disk statistics format version. |
| `rowCount` | `dynamic` | — | Owning table population used for validation. |
| `destination` | `dynamic` | — | Preallocated column-group statistics array. |
| `destinationIndex` | `dynamic` | — | Slot receiving the decoded record. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L998)

<a id="function-function-minisql-catalog-statistics-decodecolumnrecord-function-decodecolumnrecord-payload-cursor-encodedversion-rowcount-destination-destinationindex-src-minisql-catalog-statistics-ml-676435385"></a>
### decodeColumnRecord

```ml
function decodeColumnRecord(payload, cursor, encodedVersion, rowCount, destination, destinationIndex)
```

Decodes one column record directly into its preallocated destination slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | Validated statistics payload being decoded. |
| `cursor` | `dynamic` | — | Byte offset at which the column record begins. |
| `encodedVersion` | `dynamic` | — | On-disk statistics format version. |
| `rowCount` | `dynamic` | — | Owning table population used for validation. |
| `destination` | `dynamic` | — | Preallocated column-statistics array. |
| `destinationIndex` | `dynamic` | — | Slot receiving the decoded record. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L924)

<a id="function-function-minisql-catalog-statistics-decodenative-function-decodenative-words-operation-name-src-minisql-catalog-statistics-ml-5258399"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes native for the minisql catalog statistics workflow. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | words value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L912)

<a id="constant-constant-minisql-catalog-statistics-distinct-bucket-count-const-distinct-bucket-count-257-src-minisql-catalog-statistics-ml-1541929093"></a>
### DISTINCT_BUCKET_COUNT

```ml
const DISTINCT_BUCKET_COUNT = 257
```

Defines the distinct bucket count constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L48)

<a id="function-function-minisql-catalog-statistics-distinctcount-function-distinctcount-columnindex-rows-src-minisql-catalog-statistics-ml-1038299231"></a>
### distinctCount

```ml
function distinctCount(columnIndex, rows)
```

Performs the distinct count operation for this module. Inputs: `columnIndex`, `rows`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndex` | `dynamic` | — | Zero-based index of column. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L329)

<a id="constant-constant-minisql-catalog-statistics-distribution-format-version-const-distribution-format-version-4-src-minisql-catalog-statistics-ml-1619589675"></a>
### DISTRIBUTION_FORMAT_VERSION

```ml
const DISTRIBUTION_FORMAT_VERSION = 4
```

Defines the distribution format version constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L28)

<a id="function-function-minisql-catalog-statistics-encode-function-encode-state-src-minisql-catalog-statistics-ml-456684267"></a>
### encode

```ml
function encode(state)
```

Encodes encode for the minisql catalog statistics workflow. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L890)

<a id="function-function-minisql-catalog-statistics-encodecolumngrouprecord-function-encodecolumngrouprecord-payload-cursor-group-rowcount-src-minisql-catalog-statistics-ml-1984135064"></a>
### encodeColumnGroupRecord

```ml
function encodeColumnGroupRecord(payload, cursor, group, rowCount)
```

Validates and encodes one fixed-width multi-column statistics record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | Mutable catalog payload receiving the record. |
| `cursor` | `dynamic` | — | Byte offset at which the record begins. |
| `group` | `dynamic` | — | Multi-column statistics to validate and encode. |
| `rowCount` | `dynamic` | — | Owning table population used for range checks. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L826)

<a id="function-function-minisql-catalog-statistics-encodecolumnrecord-function-encodecolumnrecord-payload-cursor-column-rowcount-src-minisql-catalog-statistics-ml-1484728195"></a>
### encodeColumnRecord

```ml
function encodeColumnRecord(payload, cursor, column, rowCount)
```

Validates and encodes one fixed-width column-statistics record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | Mutable catalog payload receiving the record. |
| `cursor` | `dynamic` | — | Byte offset at which the record begins. |
| `column` | `dynamic` | — | Column statistics to validate and encode. |
| `rowCount` | `dynamic` | — | Owning table population used for range checks. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L757)

<a id="function-function-minisql-catalog-statistics-encodedsize-function-encodedsize-state-src-minisql-catalog-statistics-ml-530085929"></a>
### encodedSize

```ml
function encodedSize(state)
```

Encodes the d size. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L734)

<a id="function-function-minisql-catalog-statistics-encodetablerecord-function-encodetablerecord-payload-cursor-table-src-minisql-catalog-statistics-ml-1611084810"></a>
### encodeTableRecord

```ml
function encodeTableRecord(payload, cursor, table)
```

Encodes one table header followed by all of its column and group records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | Mutable catalog payload receiving the table record. |
| `cursor` | `dynamic` | — | Byte offset at which the table header begins. |
| `table` | `dynamic` | — | Table statistics and nested records to encode. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L861)

<a id="function-function-minisql-catalog-statistics-fail-function-fail-code-operation-message-src-minisql-catalog-statistics-ml-1919516987"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql catalog statistics module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L135)

<a id="function-function-minisql-catalog-statistics-findtable-function-findtable-state-tableid-src-minisql-catalog-statistics-ml-1133388196"></a>
### findTable

```ml
function findTable(state, tableId)
```

Finds the table. Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `tableId` | `dynamic` | — | Identifier of table. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L232)

<a id="constant-constant-minisql-catalog-statistics-format-version-const-format-version-5-src-minisql-catalog-statistics-ml-994207778"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 5
```

Defines the format version constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L26)

<a id="function-function-minisql-catalog-statistics-groupdistinctcount-function-groupdistinctcount-columnindexes-rows-src-minisql-catalog-statistics-ml-1624896485"></a>
### groupDistinctCount

```ml
function groupDistinctCount(columnIndexes, rows)
```

Counts distinct non-NULL tuples for one bounded-width column group. A hash bucket narrows comparisons, while complete SQL value comparison remains the authority and therefore makes collisions harmless.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndexes` | `dynamic` | — | columnIndexes value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L608)

<a id="function-function-minisql-catalog-statistics-groupdistribution-function-groupdistribution-columnindexes-rows-populationrows-src-minisql-catalog-statistics-ml-1286578933"></a>
### groupDistribution

```ml
function groupDistribution(columnIndexes, rows, populationRows)
```

Builds a bounded most-common tuple list for one analyzed column group.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndexes` | `dynamic` | — | columnIndexes value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L594)

<a id="constant-constant-minisql-catalog-statistics-hash-mask-const-hash-mask-2147483647-src-minisql-catalog-statistics-ml-1780823231"></a>
### HASH_MASK

```ml
const HASH_MASK = 2147483647
```

Defines the hash mask constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L50)

<a id="function-function-minisql-catalog-statistics-hashbytes-function-hashbytes-input-seed-src-minisql-catalog-statistics-ml-2135418485"></a>
### hashBytes

```ml
function hashBytes(input, seed)
```

Hashes SQL values into deterministic collision buckets. Full SQL comparison below remains authoritative, so hash collisions can only affect performance.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | input value consumed by this operation. |
| `seed` | `dynamic` | — | seed value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L284)

<a id="function-function-minisql-catalog-statistics-hasheddistribution-function-hasheddistribution-columnindex-rows-populationrows-src-minisql-catalog-statistics-ml-1329821327"></a>
### hashedDistribution

```ml
function hashedDistribution(columnIndex, rows, populationRows)
```

Builds hash-based equality MCVs for text, binary, and wide decimal values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndex` | `dynamic` | — | Zero-based index of column. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L568)

<a id="function-function-minisql-catalog-statistics-hashvalue-function-hashvalue-value-src-minisql-catalog-statistics-ml-1301438765"></a>
### hashValue

```ml
function hashValue(value)
```

Hashes one non-NULL SQL payload consistently with sameValue comparison.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L296)

<a id="constant-constant-minisql-catalog-statistics-histogram-bucket-count-const-histogram-bucket-count-8-src-minisql-catalog-statistics-ml-1381093835"></a>
### HISTOGRAM_BUCKET_COUNT

```ml
const HISTOGRAM_BUCKET_COUNT = 8
```

Defines the histogram bucket count constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L56)

<a id="function-function-minisql-catalog-statistics-integerdivide-function-integerdivide-numerator-denominator-src-minisql-catalog-statistics-ml-659929245"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Performs the integer divide operation for this module. Inputs: `numerator`, `denominator`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — | numerator value consumed by this operation. |
| `denominator` | `dynamic` | — | denominator value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L143)

<a id="function-function-minisql-catalog-statistics-integralbounds-function-integralbounds-columnindex-rows-src-minisql-catalog-statistics-ml-1037697349"></a>
### integralBounds

```ml
function integralBounds(columnIndex, rows)
```

Finds sampled minimum and maximum values for a compact integral column. The boolean prefix distinguishes an all-NULL sample from a legitimate [0, 0] domain and keeps older statistics versions unambiguous.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndex` | `dynamic` | — | Zero-based index of column. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L375)

<a id="function-function-minisql-catalog-statistics-integraldistribution-function-integraldistribution-columnindex-rows-populationrows-bounds-src-minisql-catalog-statistics-ml-1300685232"></a>
### integralDistribution

```ml
function integralDistribution(columnIndex, rows, populationRows, bounds)
```

Builds an equi-depth cumulative histogram and an exact top-frequency list from the bounded ANALYZE sample. Population frequencies are scaled once here, allowing the optimizer hot path to use only small fixed arrays.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndex` | `dynamic` | — | Zero-based index of column. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `bounds` | `dynamic` | — | bounds value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L428)

<a id="constant-constant-minisql-catalog-statistics-invalid-argument-const-invalid-argument-9001-src-minisql-catalog-statistics-ml-155436553"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Persistent table/column statistics used by the M17 cost model. Statistics are


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L17)

<a id="constant-constant-minisql-catalog-statistics-io-failure-const-io-failure-9005-src-minisql-catalog-statistics-ml-1597456377"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L23)

<a id="function-function-minisql-catalog-statistics-iscolumngroupstatistics-function-iscolumngroupstatistics-value-src-minisql-catalog-statistics-ml-45673359"></a>
### isColumnGroupStatistics

```ml
function isColumnGroupStatistics(value)
```

Reports whether a value is a persisted joint-column statistic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L181)

<a id="function-function-minisql-catalog-statistics-iscolumnstatistics-function-iscolumnstatistics-value-src-minisql-catalog-statistics-ml-154364607"></a>
### isColumnStatistics

```ml
function isColumnStatistics(value)
```

Evaluates whether the supplied input satisfies the column statistics predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L175)

<a id="function-function-minisql-catalog-statistics-isimplemented-function-isimplemented-src-minisql-catalog-statistics-ml-1678053104"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql catalog statistics module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1172)

<a id="function-function-minisql-catalog-statistics-isstatisticscatalog-function-isstatisticscatalog-value-src-minisql-catalog-statistics-ml-1364981647"></a>
### isStatisticsCatalog

```ml
function isStatisticsCatalog(value)
```

Evaluates whether the supplied input satisfies the statistics catalog predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L195)

<a id="function-function-minisql-catalog-statistics-istablestatistics-function-istablestatistics-value-src-minisql-catalog-statistics-ml-1770237373"></a>
### isTableStatistics

```ml
function isTableStatistics(value)
```

Evaluates whether the supplied input satisfies the table statistics predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L188)

<a id="constant-constant-minisql-catalog-statistics-legacy-column-bytes-const-legacy-column-bytes-32-src-minisql-catalog-statistics-ml-1512100258"></a>
### LEGACY_COLUMN_BYTES

```ml
const LEGACY_COLUMN_BYTES = 32
```

Defines the legacy column bytes constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L40)

<a id="constant-constant-minisql-catalog-statistics-legacy-column-group-bytes-const-legacy-column-group-bytes-32-src-minisql-catalog-statistics-ml-971305506"></a>
### LEGACY_COLUMN_GROUP_BYTES

```ml
const LEGACY_COLUMN_GROUP_BYTES = 32
```

Defines the legacy column group bytes constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L44)

<a id="constant-constant-minisql-catalog-statistics-legacy-format-version-const-legacy-format-version-1-src-minisql-catalog-statistics-ml-1369650900"></a>
### LEGACY_FORMAT_VERSION

```ml
const LEGACY_FORMAT_VERSION = 1
```

Defines the legacy format version constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L34)

<a id="function-function-minisql-catalog-statistics-loadorcreate-function-loadorcreate-databasepath-databaseid-src-minisql-catalog-statistics-ml-2031492762"></a>
### loadOrCreate

```ml
function loadOrCreate(databasePath, databaseId)
```

Loads the or create. Inputs: `databasePath`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1149)

<a id="function-function-minisql-catalog-statistics-magic-function-magic-src-minisql-catalog-statistics-ml-1140359386"></a>
### magic

```ml
function magic()
```

Returns a fresh copy of the on-disk format magic bytes. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L168)

<a id="constant-constant-minisql-catalog-statistics-max-column-group-width-const-max-column-group-width-8-src-minisql-catalog-statistics-ml-893680397"></a>
### MAX_COLUMN_GROUP_WIDTH

```ml
const MAX_COLUMN_GROUP_WIDTH = 8
```

Defines the max column group width constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L60)

<a id="constant-constant-minisql-catalog-statistics-most-common-value-count-const-most-common-value-count-8-src-minisql-catalog-statistics-ml-121898199"></a>
### MOST_COMMON_VALUE_COUNT

```ml
const MOST_COMMON_VALUE_COUNT = 8
```

Defines the most common value count constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L58)

<a id="function-function-minisql-catalog-statistics-path-function-path-databasepath-src-minisql-catalog-statistics-ml-1117104922"></a>
### path

```ml
function path(databasePath)
```

Performs the path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L223)

<a id="function-function-minisql-catalog-statistics-readwhole-function-readwhole-filepath-src-minisql-catalog-statistics-ml-1245405581"></a>
### readWhole

```ml
function readWhole(filePath)
```

Reads whole for the minisql catalog statistics workflow. Inputs: `filePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filePath` | `dynamic` | — | Path associated with file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1102)

<a id="constant-constant-minisql-catalog-statistics-record-kind-const-record-kind-50-src-minisql-catalog-statistics-ml-535287378"></a>
### RECORD_KIND

```ml
const RECORD_KIND = 50
```

Defines the record kind constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L36)

<a id="function-function-minisql-catalog-statistics-replacetable-function-replacetable-state-value-src-minisql-catalog-statistics-ml-690541326"></a>
### replaceTable

```ml
function replaceTable(state, value)
```

Replaces the table. Inputs: `state`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L244)

<a id="function-function-minisql-catalog-statistics-samevalue-function-samevalue-left-right-src-minisql-catalog-statistics-ml-1885782181"></a>
### sameValue

```ml
function sameValue(left, right)
```

Compares the value. Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L275)

<a id="constant-constant-minisql-catalog-statistics-sampled-format-version-const-sampled-format-version-2-src-minisql-catalog-statistics-ml-272766541"></a>
### SAMPLED_FORMAT_VERSION

```ml
const SAMPLED_FORMAT_VERSION = 2
```

Defines the sampled format version constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L32)

<a id="function-function-minisql-catalog-statistics-save-function-save-databasepath-state-src-minisql-catalog-statistics-ml-1453989001"></a>
### save

```ml
function save(databasePath, state)
```

Persists the requested value. Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1134)

<a id="function-function-minisql-catalog-statistics-scalesamplecount-function-scalesamplecount-samplevalue-populationrows-samplerows-src-minisql-catalog-statistics-ml-64739958"></a>
### scaleSampleCount

```ml
function scaleSampleCount(sampleValue, populationRows, sampleRows)
```

Scales a sample count without overflowing MiniLang's native integer range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sampleValue` | `dynamic` | — | sampleValue value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `sampleRows` | `dynamic` | — | sampleRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L645)

<a id="function-function-minisql-catalog-statistics-sortstatisticscalars-function-sortstatisticscalars-items-left-right-src-minisql-catalog-statistics-ml-1338897343"></a>
### sortStatisticScalars

```ml
function sortStatisticScalars(items, left, right)
```

In-place quicksort for the bounded ANALYZE scalar sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L396)

- [minisql.catalog.statistics.StatisticsCatalog](Type-minisql-catalog-statistics-statisticscatalog-932870512.md) — struct
<a id="function-function-minisql-catalog-statistics-supportsintegralbounds-function-supportsintegralbounds-column-src-minisql-catalog-statistics-ml-1888245874"></a>
### supportsIntegralBounds

```ml
function supportsIntegralBounds(column)
```

Reports whether a catalog column has an ordered numeric representation that can use compact signed-32-bit quantile bounds when its sampled values fit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `column` | `dynamic` | — | column value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L355)

<a id="constant-constant-minisql-catalog-statistics-table-header-bytes-const-table-header-bytes-32-src-minisql-catalog-statistics-ml-1483600988"></a>
### TABLE_HEADER_BYTES

```ml
const TABLE_HEADER_BYTES = 32
```

Defines the table header bytes constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L38)

- [minisql.catalog.statistics.TableStatistics](Type-minisql-catalog-statistics-tablestatistics-790274793.md) — struct
<a id="function-function-minisql-catalog-statistics-targetmilestone-function-targetmilestone-src-minisql-catalog-statistics-ml-417217334"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql catalog statistics module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1166)

<a id="function-function-minisql-catalog-statistics-tophashfrequencies-function-tophashfrequencies-hashes-populationrows-samplerows-src-minisql-catalog-statistics-ml-917157235"></a>
### topHashFrequencies

```ml
function topHashFrequencies(hashes, populationRows, sampleRows)
```

Selects the eight most frequent stable hashes from a bounded sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hashes` | `dynamic` | — | hashes value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `sampleRows` | `dynamic` | — | sampleRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L518)

<a id="function-function-minisql-catalog-statistics-tuplehash-function-tuplehash-columnindexes-sqlvalues-src-minisql-catalog-statistics-ml-1370251396"></a>
### tupleHash

```ml
function tupleHash(columnIndexes, sqlValues)
```

Computes the stable hash shared by group ANALYZE and optimizer probes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnIndexes` | `dynamic` | — | columnIndexes value consumed by this operation. |
| `sqlValues` | `dynamic` | — | sqlValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L580)

<a id="constant-constant-minisql-catalog-statistics-unsupported-format-const-unsupported-format-9003-src-minisql-catalog-statistics-ml-1307091991"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql catalog statistics module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L19)

<a id="function-function-minisql-catalog-statistics-validatenative-function-validatenative-value-operation-name-src-minisql-catalog-statistics-ml-252233627"></a>
### validateNative

```ml
function validateNative(value, operation, name)
```

Validates native for the minisql catalog statistics workflow. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L747)

<a id="function-function-minisql-catalog-statistics-valuewidth-function-valuewidth-value-src-minisql-catalog-statistics-ml-1311092519"></a>
### valueWidth

```ml
function valueWidth(value)
```

Performs the value width operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L264)

<a id="function-function-minisql-catalog-statistics-writeatomic-function-writeatomic-filepath-encoded-src-minisql-catalog-statistics-ml-1472445963"></a>
### writeAtomic

```ml
function writeAtomic(filePath, encoded)
```

Writes the atomic. Inputs: `filePath`, `encoded`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filePath` | `dynamic` | — | Path associated with file. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L1115)
