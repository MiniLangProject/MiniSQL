# `minisql.tools.backup.BackupManifest`

[Home](README.md) · [Source file](File-src-minisql-tools-backup-ml-1706031693.md)

<a id="struct-struct-minisql-tools-backup-backupmanifest-struct-backupmanifest-src-minisql-tools-backup-ml-640255177"></a>
## BackupManifest

```ml
struct BackupManifest
```

Groups the backup manifest state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L79)

## Members

<a id="field-field-minisql-tools-backup-backupmanifest-databaseid-databaseid-src-minisql-tools-backup-ml-380638804"></a>
### databaseId

```ml
databaseId
```

Identifies the database identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L81)

<a id="field-field-minisql-tools-backup-backupmanifest-entries-entries-src-minisql-tools-backup-ml-662165636"></a>
### entries

```ml
entries
```

Contains the ordered entries collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L85)

<a id="field-field-minisql-tools-backup-backupmanifest-pagesize-pagesize-src-minisql-tools-backup-ml-1546384008"></a>
### pageSize

```ml
pageSize
```

Tracks the page size numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L83)
