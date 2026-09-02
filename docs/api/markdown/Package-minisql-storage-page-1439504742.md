# Package `minisql.storage.page`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)

## Symbols

- [`minisql.storage.page.bytesEqual`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-bytesequal-function-bytesequal-left-right-src-minisql-storage-page-ml-546423855) — function
- [`minisql.storage.page.compareLsn`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-comparelsn-function-comparelsn-left-right-src-minisql-storage-page-ml-1404447731) — function
- [`minisql.storage.page.componentName`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-componentname-function-componentname-src-minisql-storage-page-ml-1611715800) — function
- [`minisql.storage.page.copyExact`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-page-ml-1146974041) — function
- [`minisql.storage.page.CORRUPT_DATA`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-corrupt-data-const-corrupt-data-9004-src-minisql-storage-page-ml-1880155572) — constant
- [`minisql.storage.page.create`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-create-function-create-pagesize-pagetype-fileid-pagenumber-src-minisql-storage-page-ml-172780160) — function
- [`minisql.storage.page.createPageId`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-createpageid-function-createpageid-fileid-pagenumber-src-minisql-storage-page-ml-829668231) — function
- [`minisql.storage.page.decodeNativeId`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-decodenativeid-function-decodenativeid-value-operation-name-src-minisql-storage-page-ml-944603091) — function
- [`minisql.storage.page.decodePageHeader`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-decodepageheader-function-decodepageheader-source-src-minisql-storage-page-ml-1523355231) — function
- [`minisql.storage.page.encodePageHeader`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-encodepageheader-function-encodepageheader-header-destination-src-minisql-storage-page-ml-1620133033) — function
- [`minisql.storage.page.fail`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-fail-function-fail-code-operation-message-src-minisql-storage-page-ml-145257751) — function
- [`minisql.storage.page.FORMAT_VERSION`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-format-version-const-format-version-1-src-minisql-storage-page-ml-1382878926) — constant
- [`minisql.storage.page.HEADER_CHECKSUM_OFFSET`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-header-checksum-offset-const-header-checksum-offset-60-src-minisql-storage-page-ml-1071638965) — constant
- [`minisql.storage.page.HEADER_SIZE`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-header-size-const-header-size-64-src-minisql-storage-page-ml-165044873) — constant
- [`minisql.storage.page.INVALID_ARGUMENT`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-invalid-argument-const-invalid-argument-9001-src-minisql-storage-page-ml-247732101) — constant
- [`minisql.storage.page.isImplemented`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-isimplemented-function-isimplemented-src-minisql-storage-page-ml-1236222240) — function
- [`minisql.storage.page.MAGIC_SIZE`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-magic-size-const-magic-size-4-src-minisql-storage-page-ml-757155631) — constant
- [`minisql.storage.page.magicBytes`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-magicbytes-function-magicbytes-src-minisql-storage-page-ml-346578040) — function
- [`minisql.storage.page.newHeader`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-newheader-function-newheader-pagetype-pageid-pagesize-src-minisql-storage-page-ml-1402566195) — function
- [`minisql.storage.page.PageHeader`](Type-minisql-storage-page-pageheader-38785874.md) — struct
- [`minisql.storage.page.PageId`](Type-minisql-storage-page-pageid-1131505422.md) — struct
- [`minisql.storage.page.PAYLOAD_CHECKSUM_OFFSET`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-payload-checksum-offset-const-payload-checksum-offset-56-src-minisql-storage-page-ml-1375952372) — constant
- [`minisql.storage.page.reseal`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-reseal-function-reseal-pagebytes-src-minisql-storage-page-ml-1377155554) — function
- [`minisql.storage.page.seal`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-seal-function-seal-pagebytes-header-src-minisql-storage-page-ml-137564969) — function
- [`minisql.storage.page.setLsn`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-setlsn-function-setlsn-pagebytes-lsn-src-minisql-storage-page-ml-1593770705) — function
- [`minisql.storage.page.targetMilestone`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-targetmilestone-function-targetmilestone-src-minisql-storage-page-ml-1525109030) — function
- [`minisql.storage.page.TYPE_BTREE_INTERNAL`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-btree-internal-const-type-btree-internal-3-src-minisql-storage-page-ml-1816321862) — constant
- [`minisql.storage.page.TYPE_BTREE_LEAF`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-btree-leaf-const-type-btree-leaf-4-src-minisql-storage-page-ml-1149099115) — constant
- [`minisql.storage.page.TYPE_CATALOG`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-catalog-const-type-catalog-5-src-minisql-storage-page-ml-1749695602) — constant
- [`minisql.storage.page.TYPE_FREE`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-free-const-type-free-0-src-minisql-storage-page-ml-164652775) — constant
- [`minisql.storage.page.TYPE_GENERIC`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-generic-const-type-generic-255-src-minisql-storage-page-ml-2000011725) — constant
- [`minisql.storage.page.TYPE_HEAP`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-heap-const-type-heap-1-src-minisql-storage-page-ml-1734479264) — constant
- [`minisql.storage.page.TYPE_OVERFLOW`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-type-overflow-const-type-overflow-2-src-minisql-storage-page-ml-1788757645) — constant
- [`minisql.storage.page.UNSUPPORTED_FORMAT`](File-src-minisql-storage-page-ml-792931788.md#constant-constant-minisql-storage-page-unsupported-format-const-unsupported-format-9003-src-minisql-storage-page-ml-1070137087) — constant
- [`minisql.storage.page.validateHeader`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-validateheader-function-validateheader-header-pagesize-operation-src-minisql-storage-page-ml-1805710224) — function
- [`minisql.storage.page.validateNativeId`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-validatenativeid-function-validatenativeid-value-operation-name-src-minisql-storage-page-ml-1435170287) — function
- [`minisql.storage.page.validatePageBuffer`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-validatepagebuffer-function-validatepagebuffer-pagebytes-operation-src-minisql-storage-page-ml-625609429) — function
- [`minisql.storage.page.validatePageSize`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-validatepagesize-function-validatepagesize-pagesize-operation-src-minisql-storage-page-ml-956255381) — function
- [`minisql.storage.page.validatePageType`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-validatepagetype-function-validatepagetype-value-operation-src-minisql-storage-page-ml-676555070) — function
- [`minisql.storage.page.verify`](File-src-minisql-storage-page-ml-792931788.md#function-function-minisql-storage-page-verify-function-verify-pagebytes-src-minisql-storage-page-ml-652437490) — function
