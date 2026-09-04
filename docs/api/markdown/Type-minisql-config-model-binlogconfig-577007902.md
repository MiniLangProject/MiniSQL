# `minisql.config.model.BinlogConfig`

[Home](README.md) · [Source file](File-src-minisql-config-model-ml-1120384851.md)

<a id="struct-struct-minisql-config-model-binlogconfig-struct-binlogconfig-src-minisql-config-model-ml-1797546811"></a>
## BinlogConfig

```ml
struct BinlogConfig
```

Defines the independent SQL statement log. Binlog records bypass the ordinary severity threshold so enabling it always captures every statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L73)

## Members

<a id="field-field-minisql-config-model-binlogconfig-enabled-enabled-src-minisql-config-model-ml-963086846"></a>
### enabled

```ml
enabled
```

Enables durable SQL statement recording.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L75)

<a id="field-field-minisql-config-model-binlogconfig-filename-filename-src-minisql-config-model-ml-928633828"></a>
### fileName

```ml
fileName
```

Names the active binlog file inside `paths.logDirectory`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L77)
