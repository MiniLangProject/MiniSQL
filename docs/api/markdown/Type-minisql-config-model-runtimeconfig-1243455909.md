# `minisql.config.model.RuntimeConfig`

[Home](README.md) · [Source file](File-src-minisql-config-model-ml-1120384851.md)

<a id="struct-struct-minisql-config-model-runtimeconfig-struct-runtimeconfig-src-minisql-config-model-ml-783513909"></a>
## RuntimeConfig

```ml
struct RuntimeConfig
```

Groups the runtime config state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L40)

## Members

<a id="field-field-minisql-config-model-runtimeconfig-bufferpoolbytes-bufferpoolbytes-src-minisql-config-model-ml-180261489"></a>
### bufferPoolBytes

```ml
bufferPoolBytes
```

Tracks the buffer pool bytes numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L42)

<a id="field-field-minisql-config-model-runtimeconfig-checkpointwalbytes-checkpointwalbytes-src-minisql-config-model-ml-1768552747"></a>
### checkpointWalBytes

```ml
checkpointWalBytes
```

Tracks the checkpoint WAL bytes numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L46)

<a id="field-field-minisql-config-model-runtimeconfig-loglevel-loglevel-src-minisql-config-model-ml-485236233"></a>
### logLevel

```ml
logLevel
```

Stores the log level associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L56)

<a id="field-field-minisql-config-model-runtimeconfig-processmemorybytes-processmemorybytes-src-minisql-config-model-ml-1343396855"></a>
### processMemoryBytes

```ml
processMemoryBytes
```

Rejects or cooperatively aborts work when managed heap reaches this budget.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L50)

<a id="field-field-minisql-config-model-runtimeconfig-querytimeoutms-querytimeoutms-src-minisql-config-model-ml-1988675647"></a>
### queryTimeoutMs

```ml
queryTimeoutMs
```

Tracks the query timeout ms numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L44)

<a id="field-field-minisql-config-model-runtimeconfig-slowqueryms-slowqueryms-src-minisql-config-model-ml-1056249901"></a>
### slowQueryMs

```ml
slowQueryMs
```

Emits a warning for statements whose execution reaches this duration.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L54)

<a id="field-field-minisql-config-model-runtimeconfig-temporarymemorybytes-temporarymemorybytes-src-minisql-config-model-ml-796047351"></a>
### temporaryMemoryBytes

```ml
temporaryMemoryBytes
```

Indicates whether the temporary memory bytes condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L48)

<a id="field-field-minisql-config-model-runtimeconfig-temporarystoragebytes-temporarystoragebytes-src-minisql-config-model-ml-681419821"></a>
### temporaryStorageBytes

```ml
temporaryStorageBytes
```

Caps spill reservations shared by all concurrent queries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L52)
