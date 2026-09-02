# `minisql.storage.paged_file.PagedFile`

[Home](README.md) · [Source file](File-src-minisql-storage-paged-file-ml-1675839025.md)

<a id="struct-struct-minisql-storage-paged-file-pagedfile-struct-pagedfile-src-minisql-storage-paged-file-ml-1069835941"></a>
## PagedFile

```ml
struct PagedFile
```

Defines the paged file record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L34)

## Members

<a id="field-field-minisql-storage-paged-file-pagedfile-activeslot-activeslot-src-minisql-storage-paged-file-ml-178097674"></a>
### activeSlot

```ml
activeSlot
```

Active slot field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L52)

<a id="field-field-minisql-storage-paged-file-pagedfile-allocationhint-allocationhint-src-minisql-storage-paged-file-ml-509487524"></a>
### allocationHint

```ml
allocationHint
```

First page that may still contain reusable free storage for appenders.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L58)

<a id="field-field-minisql-storage-paged-file-pagedfile-closed-closed-src-minisql-storage-paged-file-ml-857546906"></a>
### closed

```ml
closed
```

Closed field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L60)

<a id="field-field-minisql-storage-paged-file-pagedfile-databaseid-databaseid-src-minisql-storage-paged-file-ml-1385689430"></a>
### databaseId

```ml
databaseId
```

Database id field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L46)

<a id="field-field-minisql-storage-paged-file-pagedfile-encryptionkey-encryptionkey-src-minisql-storage-paged-file-ml-1719193578"></a>
### encryptionKey

```ml
encryptionKey
```

Wipeable database encryption key, or void for a plaintext file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L56)

<a id="field-field-minisql-storage-paged-file-pagedfile-featureflags-featureflags-src-minisql-storage-paged-file-ml-106395284"></a>
### featureFlags

```ml
featureFlags
```

Feature flags field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L54)

<a id="field-field-minisql-storage-paged-file-pagedfile-file-file-src-minisql-storage-paged-file-ml-1802110642"></a>
### file

```ml
file
```

File field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L38)

<a id="field-field-minisql-storage-paged-file-pagedfile-fileid-fileid-src-minisql-storage-paged-file-ml-1068883668"></a>
### fileId

```ml
fileId
```

File id field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L44)

<a id="field-field-minisql-storage-paged-file-pagedfile-filetype-filetype-src-minisql-storage-paged-file-ml-323778482"></a>
### fileType

```ml
fileType
```

File type field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L42)

<a id="field-field-minisql-storage-paged-file-pagedfile-generation-generation-src-minisql-storage-paged-file-ml-200238130"></a>
### generation

```ml
generation
```

Generation field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L50)

<a id="field-field-minisql-storage-paged-file-pagedfile-pagecount-pagecount-src-minisql-storage-paged-file-ml-609278394"></a>
### pageCount

```ml
pageCount
```

Page count field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L48)

<a id="field-field-minisql-storage-paged-file-pagedfile-pagesize-pagesize-src-minisql-storage-paged-file-ml-1980513882"></a>
### pageSize

```ml
pageSize
```

Page size field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L40)

<a id="field-field-minisql-storage-paged-file-pagedfile-path-path-src-minisql-storage-paged-file-ml-1512633052"></a>
### path

```ml
path
```

Path field of the paged file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L36)
