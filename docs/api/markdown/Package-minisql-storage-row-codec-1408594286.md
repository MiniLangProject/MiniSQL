# Package `minisql.storage.row_codec`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)

## Symbols

- [`minisql.storage.row_codec.bytesEqual`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-bytesequal-function-bytesequal-left-right-src-minisql-storage-row-codec-ml-598731699) — function
- [`minisql.storage.row_codec.column`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-column-function-column-typecode-nullable-maxlength-precision-scale-src-minisql-storage-row-codec-ml-1524663962) — function
- [`minisql.storage.row_codec.ColumnSpec`](Type-minisql-storage-row-codec-columnspec-758963501.md) — struct
- [`minisql.storage.row_codec.componentName`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-componentname-function-componentname-src-minisql-storage-row-codec-ml-1469793138) — function
- [`minisql.storage.row_codec.CORRUPT_DATA`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-corrupt-data-const-corrupt-data-9004-src-minisql-storage-row-codec-ml-1601240734) — constant
- [`minisql.storage.row_codec.decodeBinary`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-decodebinary-function-decodebinary-spec-encoded-src-minisql-storage-row-codec-ml-975449589) — function
- [`minisql.storage.row_codec.decodeCompatible`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-decodecompatible-function-decodecompatible-rowschema-encoded-src-minisql-storage-row-codec-ml-369361365) — function
- [`minisql.storage.row_codec.decodeRow`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-decoderow-function-decoderow-rowschema-encoded-src-minisql-storage-row-codec-ml-1585141317) — function
- [`minisql.storage.row_codec.decodeScalar`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-decodescalar-function-decodescalar-spec-encoded-src-minisql-storage-row-codec-ml-670523345) — function
- [`minisql.storage.row_codec.decodeText`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-decodetext-function-decodetext-spec-encoded-src-minisql-storage-row-codec-ml-1197078753) — function
- [`minisql.storage.row_codec.DIRECTORY_ENTRY_SIZE`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-directory-entry-size-const-directory-entry-size-8-src-minisql-storage-row-codec-ml-1493453633) — constant
- [`minisql.storage.row_codec.encode`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-encode-function-encode-rowschema-values-src-minisql-storage-row-codec-ml-301403203) — function
- [`minisql.storage.row_codec.encodeBinary`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-encodebinary-function-encodebinary-spec-value-src-minisql-storage-row-codec-ml-572243650) — function
- [`minisql.storage.row_codec.encodeRow`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-encoderow-function-encoderow-rowschema-values-src-minisql-storage-row-codec-ml-1440850843) — function
- [`minisql.storage.row_codec.encodeScalar`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-encodescalar-function-encodescalar-spec-value-src-minisql-storage-row-codec-ml-1998781438) — function
- [`minisql.storage.row_codec.encodeText`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-encodetext-function-encodetext-spec-value-src-minisql-storage-row-codec-ml-1734285986) — function
- [`minisql.storage.row_codec.external`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-external-function-external-encodedpointer-src-minisql-storage-row-codec-ml-171784825) — function
- [`minisql.storage.row_codec.ExternalValue`](Type-minisql-storage-row-codec-externalvalue-1393329628.md) — struct
- [`minisql.storage.row_codec.fail`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-fail-function-fail-code-operation-message-src-minisql-storage-row-codec-ml-2022930651) — function
- [`minisql.storage.row_codec.FLAG_EXTERNAL`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-flag-external-const-flag-external-2-src-minisql-storage-row-codec-ml-1036953661) — constant
- [`minisql.storage.row_codec.FLAG_NULL`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-flag-null-const-flag-null-1-src-minisql-storage-row-codec-ml-1877188006) — constant
- [`minisql.storage.row_codec.FORMAT_VERSION`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-format-version-const-format-version-1-src-minisql-storage-row-codec-ml-1759885260) — constant
- [`minisql.storage.row_codec.HEADER_SIZE`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-header-size-const-header-size-16-src-minisql-storage-row-codec-ml-2060538730) — constant
- [`minisql.storage.row_codec.INVALID_ARGUMENT`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-invalid-argument-const-invalid-argument-9001-src-minisql-storage-row-codec-ml-1499762893) — constant
- [`minisql.storage.row_codec.isBinaryType`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-isbinarytype-function-isbinarytype-typecode-src-minisql-storage-row-codec-ml-1503835983) — function
- [`minisql.storage.row_codec.isExternalType`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-isexternaltype-function-isexternaltype-typecode-src-minisql-storage-row-codec-ml-1223654191) — function
- [`minisql.storage.row_codec.isExternalValue`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-isexternalvalue-function-isexternalvalue-value-src-minisql-storage-row-codec-ml-1217040491) — function
- [`minisql.storage.row_codec.isImplemented`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-isimplemented-function-isimplemented-src-minisql-storage-row-codec-ml-1675540762) — function
- [`minisql.storage.row_codec.isNull`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-isnull-function-isnull-value-src-minisql-storage-row-codec-ml-1364475411) — function
- [`minisql.storage.row_codec.isTextType`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-istexttype-function-istexttype-typecode-src-minisql-storage-row-codec-ml-1248090283) — function
- [`minisql.storage.row_codec.magicBytes`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-magicbytes-function-magicbytes-src-minisql-storage-row-codec-ml-2106157778) — function
- [`minisql.storage.row_codec.nullValue`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-nullvalue-function-nullvalue-src-minisql-storage-row-codec-ml-1709090746) — function
- [`minisql.storage.row_codec.RowData`](Type-minisql-storage-row-codec-rowdata-1101042380.md) — struct
- [`minisql.storage.row_codec.RowSchema`](Type-minisql-storage-row-codec-rowschema-2012310495.md) — struct
- [`minisql.storage.row_codec.schema`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-schema-function-schema-version-columns-src-minisql-storage-row-codec-ml-647148125) — function
- [`minisql.storage.row_codec.SqlNull`](Type-minisql-storage-row-codec-sqlnull-286022569.md) — struct
- [`minisql.storage.row_codec.targetMilestone`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-targetmilestone-function-targetmilestone-src-minisql-storage-row-codec-ml-1288005948) — function
- [`minisql.storage.row_codec.TYPE_BIGINT`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-bigint-const-type-bigint-4-src-minisql-storage-row-codec-ml-919592391) — constant
- [`minisql.storage.row_codec.TYPE_BINARY`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-binary-const-type-binary-11-src-minisql-storage-row-codec-ml-120856425) — constant
- [`minisql.storage.row_codec.TYPE_BLOB`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-blob-const-type-blob-13-src-minisql-storage-row-codec-ml-581405183) — constant
- [`minisql.storage.row_codec.TYPE_BOOLEAN`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-boolean-const-type-boolean-1-src-minisql-storage-row-codec-ml-1298432742) — constant
- [`minisql.storage.row_codec.TYPE_CHAR`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-char-const-type-char-8-src-minisql-storage-row-codec-ml-496746111) — constant
- [`minisql.storage.row_codec.TYPE_DATE`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-date-const-type-date-14-src-minisql-storage-row-codec-ml-2070001380) — constant
- [`minisql.storage.row_codec.TYPE_DECIMAL`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-decimal-const-type-decimal-7-src-minisql-storage-row-codec-ml-2126398578) — constant
- [`minisql.storage.row_codec.TYPE_DOUBLE`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-double-const-type-double-6-src-minisql-storage-row-codec-ml-1875877593) — constant
- [`minisql.storage.row_codec.TYPE_INTEGER`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-integer-const-type-integer-3-src-minisql-storage-row-codec-ml-1315628040) — constant
- [`minisql.storage.row_codec.TYPE_MISMATCH`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-mismatch-const-type-mismatch-9017-src-minisql-storage-row-codec-ml-1174863968) — constant
- [`minisql.storage.row_codec.TYPE_REAL`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-real-const-type-real-5-src-minisql-storage-row-codec-ml-238101938) — constant
- [`minisql.storage.row_codec.TYPE_SMALLINT`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-smallint-const-type-smallint-2-src-minisql-storage-row-codec-ml-1526105977) — constant
- [`minisql.storage.row_codec.TYPE_TEXT`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-text-const-type-text-10-src-minisql-storage-row-codec-ml-1635552812) — constant
- [`minisql.storage.row_codec.TYPE_TIME`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-time-const-type-time-15-src-minisql-storage-row-codec-ml-1208377217) — constant
- [`minisql.storage.row_codec.TYPE_TIMESTAMP`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-timestamp-const-type-timestamp-16-src-minisql-storage-row-codec-ml-1332625398) — constant
- [`minisql.storage.row_codec.TYPE_VARBINARY`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-varbinary-const-type-varbinary-12-src-minisql-storage-row-codec-ml-1237202394) — constant
- [`minisql.storage.row_codec.TYPE_VARCHAR`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-type-varchar-const-type-varchar-9-src-minisql-storage-row-codec-ml-972587244) — constant
- [`minisql.storage.row_codec.UNSUPPORTED_FORMAT`](File-src-minisql-storage-row-codec-ml-756043630.md#constant-constant-minisql-storage-row-codec-unsupported-format-const-unsupported-format-9003-src-minisql-storage-row-codec-ml-121070795) — constant
- [`minisql.storage.row_codec.validType`](File-src-minisql-storage-row-codec-ml-756043630.md#function-function-minisql-storage-row-codec-validtype-function-validtype-typecode-src-minisql-storage-row-codec-ml-2019194487) — function
