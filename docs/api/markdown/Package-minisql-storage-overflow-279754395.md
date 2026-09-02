# Package `minisql.storage.overflow`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/storage/overflow.ml](File-src-minisql-storage-overflow-ml-2096314611.md)

## Symbols

- [`minisql.storage.overflow.abortReplace`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-abortreplace-function-abortreplace-pagedfile-replacement-src-minisql-storage-overflow-ml-1226285659) — function
- [`minisql.storage.overflow.allocatePageNumbers`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-allocatepagenumbers-function-allocatepagenumbers-pagedfile-count-src-minisql-storage-overflow-ml-1767540990) — function
- [`minisql.storage.overflow.bytesEqual`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-bytesequal-function-bytesequal-left-right-src-minisql-storage-overflow-ml-308644533) — function
- [`minisql.storage.overflow.CHAIN_HEADER_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-chain-header-offset-const-chain-header-offset-64-src-minisql-storage-overflow-ml-1644255521) — constant
- [`minisql.storage.overflow.CHAIN_HEADER_SIZE`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-chain-header-size-const-chain-header-size-40-src-minisql-storage-overflow-ml-1312042007) — constant
- [`minisql.storage.overflow.CHUNK_LENGTH_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-chunk-length-offset-const-chunk-length-offset-88-src-minisql-storage-overflow-ml-1930680579) — constant
- [`minisql.storage.overflow.chunkCapacity`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-chunkcapacity-function-chunkcapacity-pagedfile-src-minisql-storage-overflow-ml-138369749) — function
- [`minisql.storage.overflow.commitReplace`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-commitreplace-function-commitreplace-pagedfile-replacement-src-minisql-storage-overflow-ml-247521497) — function
- [`minisql.storage.overflow.componentName`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-componentname-function-componentname-src-minisql-storage-overflow-ml-493640988) — function
- [`minisql.storage.overflow.CORRUPT_DATA`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-corrupt-data-const-corrupt-data-9004-src-minisql-storage-overflow-ml-317644872) — constant
- [`minisql.storage.overflow.createPointer`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-createpointer-function-createpointer-fileid-firstpage-totallength-ownerid-valuechecksum-src-minisql-storage-overflow-ml-136600320) — function
- [`minisql.storage.overflow.DATA_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-data-offset-const-data-offset-104-src-minisql-storage-overflow-ml-1229116102) — constant
- [`minisql.storage.overflow.decodeNative`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-decodenative-function-decodenative-words-operation-name-src-minisql-storage-overflow-ml-1325354679) — function
- [`minisql.storage.overflow.decodeNext`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-decodenext-function-decodenext-pagebytes-src-minisql-storage-overflow-ml-748107312) — function
- [`minisql.storage.overflow.decodePointer`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-decodepointer-function-decodepointer-encoded-src-minisql-storage-overflow-ml-875987966) — function
- [`minisql.storage.overflow.encodePage`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-encodepage-function-encodepage-pagedfile-pagenumber-ownerid-nextpage-totallength-sequence-chunk-src-minisql-storage-overflow-ml-1327676373) — function
- [`minisql.storage.overflow.encodePointer`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-encodepointer-function-encodepointer-pointer-src-minisql-storage-overflow-ml-962920583) — function
- [`minisql.storage.overflow.fail`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-fail-function-fail-code-operation-message-src-minisql-storage-overflow-ml-1049687223) — function
- [`minisql.storage.overflow.FORMAT_VERSION`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-format-version-const-format-version-1-src-minisql-storage-overflow-ml-1749092064) — constant
- [`minisql.storage.overflow.free`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-free-function-free-pagedfile-pointer-src-minisql-storage-overflow-ml-1300206016) — function
- [`minisql.storage.overflow.fromExternal`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-fromexternal-function-fromexternal-value-src-minisql-storage-overflow-ml-1997172957) — function
- [`minisql.storage.overflow.INVALID_ARGUMENT`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-invalid-argument-const-invalid-argument-9001-src-minisql-storage-overflow-ml-667916541) — constant
- [`minisql.storage.overflow.isImplemented`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-isimplemented-function-isimplemented-src-minisql-storage-overflow-ml-779605716) — function
- [`minisql.storage.overflow.NEXT_PAGE_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-next-page-offset-const-next-page-offset-80-src-minisql-storage-overflow-ml-1610291567) — constant
- [`minisql.storage.overflow.OverflowPointer`](Type-minisql-storage-overflow-overflowpointer-507137354.md) — struct
- [`minisql.storage.overflow.OverflowReplacement`](Type-minisql-storage-overflow-overflowreplacement-1476181223.md) — struct
- [`minisql.storage.overflow.pageCountForLength`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-pagecountforlength-function-pagecountforlength-pagedfile-length-src-minisql-storage-overflow-ml-1521682731) — function
- [`minisql.storage.overflow.pageMagic`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-pagemagic-function-pagemagic-src-minisql-storage-overflow-ml-123890664) — function
- [`minisql.storage.overflow.POINTER_SIZE`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-pointer-size-const-pointer-size-48-src-minisql-storage-overflow-ml-1732029711) — constant
- [`minisql.storage.overflow.pointerMagic`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-pointermagic-function-pointermagic-src-minisql-storage-overflow-ml-331054636) — function
- [`minisql.storage.overflow.prepareReplace`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-preparereplace-function-preparereplace-pagedfile-oldpointer-ownerid-newvalue-src-minisql-storage-overflow-ml-825443226) — function
- [`minisql.storage.overflow.read`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-read-function-read-pagedfile-pointer-src-minisql-storage-overflow-ml-914711680) — function
- [`minisql.storage.overflow.readRange`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-readrange-function-readrange-pagedfile-pointer-requestedoffset-requestedlength-src-minisql-storage-overflow-ml-290782517) — function
- [`minisql.storage.overflow.readText`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-readtext-function-readtext-pagedfile-pointer-src-minisql-storage-overflow-ml-451057656) — function
- [`minisql.storage.overflow.replace`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-replace-function-replace-pagedfile-oldpointer-ownerid-newvalue-src-minisql-storage-overflow-ml-1714543266) — function
- [`minisql.storage.overflow.SEQUENCE_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-sequence-offset-const-sequence-offset-96-src-minisql-storage-overflow-ml-197451904) — constant
- [`minisql.storage.overflow.storeText`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-storetext-function-storetext-pagedfile-ownerid-text-src-minisql-storage-overflow-ml-221721332) — function
- [`minisql.storage.overflow.targetMilestone`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-targetmilestone-function-targetmilestone-src-minisql-storage-overflow-ml-1065735998) — function
- [`minisql.storage.overflow.toExternal`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-toexternal-function-toexternal-pointer-src-minisql-storage-overflow-ml-1073137437) — function
- [`minisql.storage.overflow.TOTAL_LENGTH_OFFSET`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-total-length-offset-const-total-length-offset-92-src-minisql-storage-overflow-ml-17356800) — constant
- [`minisql.storage.overflow.UNSUPPORTED_FORMAT`](File-src-minisql-storage-overflow-ml-2096314611.md#constant-constant-minisql-storage-overflow-unsupported-format-const-unsupported-format-9003-src-minisql-storage-overflow-ml-1365635915) — constant
- [`minisql.storage.overflow.validateChainPage`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-validatechainpage-function-validatechainpage-pagedfile-pagebytes-pointer-expectedpage-expectedsequence-src-minisql-storage-overflow-ml-1300362844) — function
- [`minisql.storage.overflow.validateNative`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-validatenative-function-validatenative-value-operation-name-allowminusone-src-minisql-storage-overflow-ml-305923936) — function
- [`minisql.storage.overflow.validatePointerForFile`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-validatepointerforfile-function-validatepointerforfile-pagedfile-pointer-operation-src-minisql-storage-overflow-ml-939664329) — function
- [`minisql.storage.overflow.write`](File-src-minisql-storage-overflow-ml-2096314611.md#function-function-minisql-storage-overflow-write-function-write-pagedfile-ownerid-value-src-minisql-storage-overflow-ml-960735172) — function
