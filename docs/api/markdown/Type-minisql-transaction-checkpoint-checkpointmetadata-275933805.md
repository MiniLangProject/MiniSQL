# `minisql.transaction.checkpoint.CheckpointMetadata`

[Home](README.md) · [Source file](File-src-minisql-transaction-checkpoint-ml-1306482346.md)

<a id="struct-struct-minisql-transaction-checkpoint-checkpointmetadata-struct-checkpointmetadata-src-minisql-transaction-checkpoint-ml-1990312693"></a>
## CheckpointMetadata

```ml
struct CheckpointMetadata
```

Defines the checkpoint metadata record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L43)

## Members

<a id="field-field-minisql-transaction-checkpoint-checkpointmetadata-checkpointlsn-checkpointlsn-src-minisql-transaction-checkpoint-ml-1829465832"></a>
### checkpointLsn

```ml
checkpointLsn
```

Checkpoint lsn field of the checkpoint metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L47)

<a id="field-field-minisql-transaction-checkpoint-checkpointmetadata-databaseid-databaseid-src-minisql-transaction-checkpoint-ml-291788084"></a>
### databaseId

```ml
databaseId
```

Database id field of the checkpoint metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L53)

<a id="field-field-minisql-transaction-checkpoint-checkpointmetadata-generation-generation-src-minisql-transaction-checkpoint-ml-816175956"></a>
### generation

```ml
generation
```

Generation field of the checkpoint metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L45)

<a id="field-field-minisql-transaction-checkpoint-checkpointmetadata-recordcount-recordcount-src-minisql-transaction-checkpoint-ml-1485889264"></a>
### recordCount

```ml
recordCount
```

Record count field of the checkpoint metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L51)

<a id="field-field-minisql-transaction-checkpoint-checkpointmetadata-redostartlsn-redostartlsn-src-minisql-transaction-checkpoint-ml-1179408218"></a>
### redoStartLsn

```ml
redoStartLsn
```

Redo start lsn field of the checkpoint metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L49)
