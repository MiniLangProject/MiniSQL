# `src/minisql/config/model.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql config model facilities for this project.

Package: [`minisql.config.model`](Package-minisql-config-model-2080962645.md)

Reachable from entry: **yes**

## Declarations

- [minisql.config.model.BinlogConfig](Type-minisql-config-model-binlogconfig-577007902.md) — struct
<a id="function-function-minisql-config-model-componentname-function-componentname-src-minisql-config-model-ml-1959695434"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql config model module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L223)

- [minisql.config.model.DatabaseDefaults](Type-minisql-config-model-databasedefaults-704930438.md) — struct
<a id="function-function-minisql-config-model-defaultconfig-function-defaultconfig-dataroot-src-minisql-config-model-ml-198024192"></a>
### defaultConfig

```ml
function defaultConfig(dataRoot)
```

Implements default config for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dataRoot` | `dynamic` | — | dataRoot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L253)

<a id="function-function-minisql-config-model-defaultdatabasesettings-function-defaultdatabasesettings-pagesize-src-minisql-config-model-ml-1333476822"></a>
### defaultDatabaseSettings

```ml
function defaultDatabaseSettings(pageSize)
```

Implements default database settings for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L245)

<a id="function-function-minisql-config-model-isbinlogconfig-function-isbinlogconfig-value-src-minisql-config-model-ml-1676898991"></a>
### isBinlogConfig

```ml
function isBinlogConfig(value)
```

Returns whether the supplied value is a binlog configuration. Inputs: `value`. Returns true only for `BinlogConfig` values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L186)

<a id="function-function-minisql-config-model-isdatabasedefaults-function-isdatabasedefaults-value-src-minisql-config-model-ml-731134279"></a>
### isDatabaseDefaults

```ml
function isDatabaseDefaults(value)
```

Returns whether the supplied value satisfies the database defaults condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L200)

<a id="function-function-minisql-config-model-isimplemented-function-isimplemented-src-minisql-config-model-ml-996830778"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql config model module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L237)

<a id="function-function-minisql-config-model-isloggingconfig-function-isloggingconfig-value-src-minisql-config-model-ml-2083258201"></a>
### isLoggingConfig

```ml
function isLoggingConfig(value)
```

Returns whether the supplied value is a logger configuration. Inputs: `value`. Returns true only for `LoggingConfig` values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L179)

<a id="function-function-minisql-config-model-isminisqlconfig-function-isminisqlconfig-value-src-minisql-config-model-ml-2114353501"></a>
### isMiniSqlConfig

```ml
function isMiniSqlConfig(value)
```

Returns whether the supplied value satisfies the mini SQL config condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L216)

<a id="function-function-minisql-config-model-ispathsconfig-function-ispathsconfig-value-src-minisql-config-model-ml-266010427"></a>
### isPathsConfig

```ml
function isPathsConfig(value)
```

Returns whether the supplied value satisfies the paths config condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L156)

<a id="function-function-minisql-config-model-isruntimeconfig-function-isruntimeconfig-value-src-minisql-config-model-ml-3333103"></a>
### isRuntimeConfig

```ml
function isRuntimeConfig(value)
```

Returns whether the supplied value satisfies the runtime config condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L172)

<a id="function-function-minisql-config-model-issafetyconfig-function-issafetyconfig-value-src-minisql-config-model-ml-1092988699"></a>
### isSafetyConfig

```ml
function isSafetyConfig(value)
```

Returns whether the supplied value satisfies the safety config condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L208)

<a id="function-function-minisql-config-model-isserverconfig-function-isserverconfig-value-src-minisql-config-model-ml-1219571259"></a>
### isServerConfig

```ml
function isServerConfig(value)
```

Returns whether the supplied value satisfies the server config condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L164)

<a id="function-function-minisql-config-model-istlsconfig-function-istlsconfig-value-src-minisql-config-model-ml-1134747821"></a>
### isTlsConfig

```ml
function isTlsConfig(value)
```

Returns whether the supplied value is a native TLS configuration.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L192)

- [minisql.config.model.LoggingConfig](Type-minisql-config-model-loggingconfig-1700021644.md) — struct
- [minisql.config.model.MiniSqlConfig](Type-minisql-config-model-minisqlconfig-1246526844.md) — struct
- [minisql.config.model.PathsConfig](Type-minisql-config-model-pathsconfig-332669465.md) — struct
- [minisql.config.model.RuntimeConfig](Type-minisql-config-model-runtimeconfig-1243455909.md) — struct
- [minisql.config.model.SafetyConfig](Type-minisql-config-model-safetyconfig-62505081.md) — struct
- [minisql.config.model.ServerConfig](Type-minisql-config-model-serverconfig-1598414400.md) — struct
<a id="function-function-minisql-config-model-targetmilestone-function-targetmilestone-src-minisql-config-model-ml-562188724"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql config model module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L230)

- [minisql.config.model.TlsConfig](Type-minisql-config-model-tlsconfig-1694670536.md) — struct
