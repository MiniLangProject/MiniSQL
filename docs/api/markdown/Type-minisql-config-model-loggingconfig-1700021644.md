# `minisql.config.model.LoggingConfig`

[Home](README.md) · [Source file](File-src-minisql-config-model-ml-1120384851.md)

<a id="struct-struct-minisql-config-model-loggingconfig-struct-loggingconfig-src-minisql-config-model-ml-2073594131"></a>
## LoggingConfig

```ml
struct LoggingConfig
```

Defines ordinary server-log destinations and time-based file rotation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L60)

## Members

<a id="field-field-minisql-config-model-loggingconfig-fileenabled-fileenabled-src-minisql-config-model-ml-307262880"></a>
### fileEnabled

```ml
fileEnabled
```

Enables writing the same accepted record to the active log file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L64)

<a id="field-field-minisql-config-model-loggingconfig-filename-filename-src-minisql-config-model-ml-496862002"></a>
### fileName

```ml
fileName
```

Names the active log file inside `paths.logDirectory`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L66)

<a id="field-field-minisql-config-model-loggingconfig-rotationhours-rotationhours-src-minisql-config-model-ml-1492337048"></a>
### rotationHours

```ml
rotationHours
```

Selects the number of elapsed hours after which the active file is rolled.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L68)

<a id="field-field-minisql-config-model-loggingconfig-stdoutenabled-stdoutenabled-src-minisql-config-model-ml-585878044"></a>
### stdoutEnabled

```ml
stdoutEnabled
```

Enables writing each accepted log record to standard output.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L62)
