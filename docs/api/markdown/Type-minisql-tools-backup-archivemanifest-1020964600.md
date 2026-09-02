# `minisql.tools.backup.ArchiveManifest`

[Home](README.md) · [Source file](File-src-minisql-tools-backup-ml-1706031693.md)

<a id="struct-struct-minisql-tools-backup-archivemanifest-struct-archivemanifest-src-minisql-tools-backup-ml-950645221"></a>
## ArchiveManifest

```ml
struct ArchiveManifest
```

Groups the archive manifest state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L693)

## Members

<a id="field-field-minisql-tools-backup-archivemanifest-baseendlsn-baseendlsn-src-minisql-tools-backup-ml-1429712844"></a>
### baseEndLsn

```ml
baseEndLsn
```

Stores the base end LSN associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L701)

<a id="field-field-minisql-tools-backup-archivemanifest-databaseid-databaseid-src-minisql-tools-backup-ml-877620162"></a>
### databaseId

```ml
databaseId
```

Identifies the database identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L695)

<a id="field-field-minisql-tools-backup-archivemanifest-generation-generation-src-minisql-tools-backup-ml-1625358174"></a>
### generation

```ml
generation
```

Stores the generation associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L699)

<a id="field-field-minisql-tools-backup-archivemanifest-latestendlsn-latestendlsn-src-minisql-tools-backup-ml-964081468"></a>
### latestEndLsn

```ml
latestEndLsn
```

Stores the latest end LSN associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L703)

<a id="field-field-minisql-tools-backup-archivemanifest-pagesize-pagesize-src-minisql-tools-backup-ml-1920297222"></a>
### pageSize

```ml
pageSize
```

Tracks the page size numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L697)

<a id="field-field-minisql-tools-backup-archivemanifest-walchecksum-walchecksum-src-minisql-tools-backup-ml-20335946"></a>
### walChecksum

```ml
walChecksum
```

Stores the WAL checksum associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L709)

<a id="field-field-minisql-tools-backup-archivemanifest-walfilename-walfilename-src-minisql-tools-backup-ml-625476506"></a>
### walFileName

```ml
walFileName
```

Stores the WAL file name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L705)

<a id="field-field-minisql-tools-backup-archivemanifest-wallength-wallength-src-minisql-tools-backup-ml-660791746"></a>
### walLength

```ml
walLength
```

Tracks the WAL length numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L707)
