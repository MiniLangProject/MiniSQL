# `minisql.tools.backup.PitrReport`

[Home](README.md) · [Source file](File-src-minisql-tools-backup-ml-1706031693.md)

<a id="struct-struct-minisql-tools-backup-pitrreport-struct-pitrreport-src-minisql-tools-backup-ml-1347941873"></a>
## PitrReport

```ml
struct PitrReport
```

Groups the point-in-time recovery report state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L727)

## Members

<a id="field-field-minisql-tools-backup-pitrreport-databaseid-databaseid-src-minisql-tools-backup-ml-1255274252"></a>
### databaseId

```ml
databaseId
```

Identifies the database identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L729)

<a id="field-field-minisql-tools-backup-pitrreport-path-path-src-minisql-tools-backup-ml-510848606"></a>
### path

```ml
path
```

Stores the filesystem path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L733)

<a id="field-field-minisql-tools-backup-pitrreport-targetlsn-targetlsn-src-minisql-tools-backup-ml-1104534376"></a>
### targetLsn

```ml
targetLsn
```

Stores the target LSN associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/backup.ml#L731)
