# Package `minisql.executor.sort`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/executor/sort.ml](File-src-minisql-executor-sort-ml-267147473.md)

## Symbols

- [`minisql.executor.sort.bytesEqual`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-bytesequal-function-bytesequal-left-right-src-minisql-executor-sort-ml-1570919653) — function
- [`minisql.executor.sort.cleanupRuns`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-cleanupruns-function-cleanupruns-runs-src-minisql-executor-sort-ml-1620652992) — function
- [`minisql.executor.sort.combinedValues`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-combinedvalues-function-combinedvalues-row-src-minisql-executor-sort-ml-1768930856) — function
- [`minisql.executor.sort.compareNullable`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-comparenullable-function-comparenullable-left-right-descending-nullsfirst-nullsspecified-src-minisql-executor-sort-ml-2086897419) — function
- [`minisql.executor.sort.compareRows`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-comparerows-function-comparerows-left-right-orderitems-src-minisql-executor-sort-ml-1321908421) — function
- [`minisql.executor.sort.componentName`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-componentname-function-componentname-src-minisql-executor-sort-ml-1485606542) — function
- [`minisql.executor.sort.CORRUPT_DATA`](File-src-minisql-executor-sort-ml-267147473.md#constant-constant-minisql-executor-sort-corrupt-data-const-corrupt-data-9004-src-minisql-executor-sort-ml-949147782) — constant
- [`minisql.executor.sort.decodeSqlValue`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-decodesqlvalue-function-decodesqlvalue-kind-raw-src-minisql-executor-sort-ml-660078412) — function
- [`minisql.executor.sort.encodeHeader`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-encodeheader-function-encodeheader-valuecount-ordercount-encrypted-src-minisql-executor-sort-ml-887163397) — function
- [`minisql.executor.sort.fail`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-fail-function-fail-code-operation-message-src-minisql-executor-sort-ml-952056199) — function
- [`minisql.executor.sort.INVALID_ARGUMENT`](File-src-minisql-executor-sort-ml-267147473.md#constant-constant-minisql-executor-sort-invalid-argument-const-invalid-argument-9001-src-minisql-executor-sort-ml-450573233) — constant
- [`minisql.executor.sort.isImplemented`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-isimplemented-function-isimplemented-src-minisql-executor-sort-ml-1237356158) — function
- [`minisql.executor.sort.MAX_SPILL_FILE_BYTES`](File-src-minisql-executor-sort-ml-267147473.md#constant-constant-minisql-executor-sort-max-spill-file-bytes-const-max-spill-file-bytes-268435456-src-minisql-executor-sort-ml-128573526) — constant
- [`minisql.executor.sort.merge`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-merge-function-merge-left-right-orderitems-src-minisql-executor-sort-ml-954716497) — function
- [`minisql.executor.sort.nextSpillToken`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-nextspilltoken-synchronized-function-nextspilltoken-src-minisql-executor-sort-ml-510667170) — function
- [`minisql.executor.sort.rawValues`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-rawvalues-function-rawvalues-input-src-minisql-executor-sort-ml-1645235892) — function
- [`minisql.executor.sort.readRun`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-readrun-function-readrun-run-src-minisql-executor-sort-ml-865847215) — function
- [`minisql.executor.sort.runPath`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-runpath-function-runpath-root-token-index-src-minisql-executor-sort-ml-1486832257) — function
- [`minisql.executor.sort.sortProjected`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-sortprojected-function-sortprojected-rows-orderitems-src-minisql-executor-sort-ml-1723376011) — function
- [`minisql.executor.sort.sortProjectedWithSpill`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-sortprojectedwithspill-function-sortprojectedwithspill-rows-orderitems-temporaryroot-threshold-src-minisql-executor-sort-ml-1872830833) — function
- [`minisql.executor.sort.SPILL_HEADER_SIZE`](File-src-minisql-executor-sort-ml-267147473.md#constant-constant-minisql-executor-sort-spill-header-size-const-spill-header-size-16-src-minisql-executor-sort-ml-117544562) — constant
- [`minisql.executor.sort.SPILL_VERSION`](File-src-minisql-executor-sort-ml-267147473.md#constant-constant-minisql-executor-sort-spill-version-const-spill-version-1-src-minisql-executor-sort-ml-1734409364) — constant
- [`minisql.executor.sort.spillAad`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-spillaad-function-spillaad-rowindex-src-minisql-executor-sort-ml-1708080306) — function
- [`minisql.executor.sort.spillMagic`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-spillmagic-function-spillmagic-src-minisql-executor-sort-ml-244061314) — function
- [`minisql.executor.sort.spillNonce`](File-src-minisql-executor-sort-ml-267147473.md#global-global-minisql-executor-sort-spillnonce-spillnonce-src-minisql-executor-sort-ml-2117164018) — global
- [`minisql.executor.sort.SpillRun`](Type-minisql-executor-sort-spillrun-632012310.md) — struct
- [`minisql.executor.sort.spillSchema`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-spillschema-function-spillschema-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1979130154) — function
- [`minisql.executor.sort.spillSpec`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-spillspec-function-spillspec-kind-src-minisql-executor-sort-ml-1981031390) — function
- [`minisql.executor.sort.spillType`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-spilltype-function-spilltype-kind-src-minisql-executor-sort-ml-20392400) — function
- [`minisql.executor.sort.targetMilestone`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-targetmilestone-function-targetmilestone-src-minisql-executor-sort-ml-206580668) — function
- [`minisql.executor.sort.topNProjected`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-topnprojected-function-topnprojected-rows-orderitems-count-src-minisql-executor-sort-ml-1665386162) — function
- [`minisql.executor.sort.writeRun`](File-src-minisql-executor-sort-ml-267147473.md#function-function-minisql-executor-sort-writerun-function-writerun-path-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1745860299) — function
