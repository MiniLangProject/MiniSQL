# Package `minisql.storage.superblock`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)

## Symbols

- [`minisql.storage.superblock.bytesEqual`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-bytesequal-function-bytesequal-left-right-src-minisql-storage-superblock-ml-143455021) — function
- [`minisql.storage.superblock.CHECKSUM_OFFSET`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-checksum-offset-const-checksum-offset-72-src-minisql-storage-superblock-ml-1098178802) — constant
- [`minisql.storage.superblock.compareGeneration`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-comparegeneration-function-comparegeneration-left-right-src-minisql-storage-superblock-ml-187893335) — function
- [`minisql.storage.superblock.componentName`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-componentname-function-componentname-src-minisql-storage-superblock-ml-1186223768) — function
- [`minisql.storage.superblock.copyExact`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-superblock-ml-2005440139) — function
- [`minisql.storage.superblock.CORRUPT_DATA`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-corrupt-data-const-corrupt-data-9004-src-minisql-storage-superblock-ml-866366320) — constant
- [`minisql.storage.superblock.create`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-create-function-create-formatversion-generation-pagesize-filetype-fileid-pagecount-databaseid-featureflags-src-minisql-storage-superblock-ml-857825497) — function
- [`minisql.storage.superblock.DATABASE_ID_SIZE`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-database-id-size-const-database-id-size-16-src-minisql-storage-superblock-ml-1965362984) — constant
- [`minisql.storage.superblock.decode`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-decode-function-decode-source-src-minisql-storage-superblock-ml-2131296055) — function
- [`minisql.storage.superblock.decodeNativeId`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-decodenativeid-function-decodenativeid-value-operation-name-src-minisql-storage-superblock-ml-1561575535) — function
- [`minisql.storage.superblock.encode`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-encode-function-encode-superblock-src-minisql-storage-superblock-ml-211795616) — function
- [`minisql.storage.superblock.fail`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-fail-function-fail-code-operation-message-src-minisql-storage-superblock-ml-918059683) — function
- [`minisql.storage.superblock.FILE_TYPE_DATABASE_META`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-file-type-database-meta-const-file-type-database-meta-4-src-minisql-storage-superblock-ml-1185852097) — constant
- [`minisql.storage.superblock.FILE_TYPE_GENERIC`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-file-type-generic-const-file-type-generic-255-src-minisql-storage-superblock-ml-266420945) — constant
- [`minisql.storage.superblock.FILE_TYPE_INDEX`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-file-type-index-const-file-type-index-2-src-minisql-storage-superblock-ml-206131539) — constant
- [`minisql.storage.superblock.FILE_TYPE_TABLE`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-file-type-table-const-file-type-table-1-src-minisql-storage-superblock-ml-262091530) — constant
- [`minisql.storage.superblock.FILE_TYPE_WAL`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-file-type-wal-const-file-type-wal-3-src-minisql-storage-superblock-ml-1150984676) — constant
- [`minisql.storage.superblock.FORMAT_VERSION`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-format-version-const-format-version-1-src-minisql-storage-superblock-ml-1405430500) — constant
- [`minisql.storage.superblock.HEADER_SIZE`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-header-size-const-header-size-128-src-minisql-storage-superblock-ml-1715962944) — constant
- [`minisql.storage.superblock.immutableIdentityMatches`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-immutableidentitymatches-function-immutableidentitymatches-left-right-src-minisql-storage-superblock-ml-651913081) — function
- [`minisql.storage.superblock.incrementGeneration`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-incrementgeneration-function-incrementgeneration-value-src-minisql-storage-superblock-ml-567024075) — function
- [`minisql.storage.superblock.INVALID_ARGUMENT`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-invalid-argument-const-invalid-argument-9001-src-minisql-storage-superblock-ml-1625683225) — constant
- [`minisql.storage.superblock.isImplemented`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-isimplemented-function-isimplemented-src-minisql-storage-superblock-ml-1639247848) — function
- [`minisql.storage.superblock.magicBytes`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-magicbytes-function-magicbytes-src-minisql-storage-superblock-ml-896338232) — function
- [`minisql.storage.superblock.sameDatabaseId`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-samedatabaseid-function-samedatabaseid-left-right-src-minisql-storage-superblock-ml-1253092185) — function
- [`minisql.storage.superblock.SLOT_SIZE`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-slot-size-const-slot-size-4096-src-minisql-storage-superblock-ml-1237792916) — constant
- [`minisql.storage.superblock.Superblock`](Type-minisql-storage-superblock-superblock-1928044593.md) — struct
- [`minisql.storage.superblock.targetMilestone`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-targetmilestone-function-targetmilestone-src-minisql-storage-superblock-ml-577867690) — function
- [`minisql.storage.superblock.UNSUPPORTED_FORMAT`](File-src-minisql-storage-superblock-ml-1268029913.md#constant-constant-minisql-storage-superblock-unsupported-format-const-unsupported-format-9003-src-minisql-storage-superblock-ml-426358211) — constant
- [`minisql.storage.superblock.validateDatabaseId`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-validatedatabaseid-function-validatedatabaseid-databaseid-operation-src-minisql-storage-superblock-ml-250969645) — function
- [`minisql.storage.superblock.validateFileType`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-validatefiletype-function-validatefiletype-filetype-operation-src-minisql-storage-superblock-ml-553372391) — function
- [`minisql.storage.superblock.validateNativeId`](File-src-minisql-storage-superblock-ml-1268029913.md#function-function-minisql-storage-superblock-validatenativeid-function-validatenativeid-value-operation-name-src-minisql-storage-superblock-ml-86386115) — function
