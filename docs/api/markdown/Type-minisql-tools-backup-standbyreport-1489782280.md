# `minisql.tools.backup.StandbyReport`

[Home](README.md) · [Source file](File-src-minisql-tools-backup-ml-1706031693.md)

<a id="struct-struct-minisql-tools-backup-standbyreport-struct-standbyreport-src-minisql-tools-backup-ml-1678136837"></a>
## StandbyReport

```ml
struct StandbyReport
```

Groups the standby report state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L747)

## Members

<a id="field-field-minisql-tools-backup-standbyreport-appliedlsn-appliedlsn-src-minisql-tools-backup-ml-2011887334"></a>
### appliedLsn

```ml
appliedLsn
```

Stores the applied LSN associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L753)

<a id="field-field-minisql-tools-backup-standbyreport-archivegeneration-archivegeneration-src-minisql-tools-backup-ml-1085464438"></a>
### archiveGeneration

```ml
archiveGeneration
```

Stores the archive generation associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L751)

<a id="field-field-minisql-tools-backup-standbyreport-databaseid-databaseid-src-minisql-tools-backup-ml-1768137298"></a>
### databaseId

```ml
databaseId
```

Identifies the database identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L749)

<a id="field-field-minisql-tools-backup-standbyreport-path-path-src-minisql-tools-backup-ml-433196900"></a>
### path

```ml
path
```

Stores the filesystem path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L755)
