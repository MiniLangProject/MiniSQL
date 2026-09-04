# `src/minisql/common/logger.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common logger facilities for this project.

Package: [`minisql.common.logger`](Package-minisql-common-logger-425436237.md)

Reachable from entry: **yes**

## Imports

- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `std/string_builder.ml` as `string_builder` → `../MiniLangCompilerML/std/string_builder.ml` — external dependency
- `std/time.ml` as `time_api` → `../MiniLangCompilerML/std/time.ml` — external dependency

## Declarations

<a id="function-function-minisql-common-logger-appendline-function-appendline-handle-line-src-minisql-common-logger-ml-1796661674"></a>
### appendLine

```ml
function appendLine(handle, line)
```

Appends and flushes one line so a successful call makes the record durable. Inputs: `handle`, `line`. Returns true after the newline reaches the file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `line` | `dynamic` | — | line value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L255)

<a id="function-function-minisql-common-logger-binlog-synchronized-function-binlog-component-sqltext-src-minisql-common-logger-ml-934351314"></a>
### binlog

```ml
synchronized function binlog(component, sqlText)
```

Durably records one SQL command independently of the ordinary log threshold. Inputs: `component`, `sqlText`. Returns true when disabled or successfully appended.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L347)

<a id="function-function-minisql-common-logger-close-synchronized-function-close-src-minisql-common-logger-ml-1939248814"></a>
### close

```ml
synchronized function close()
```

Flushes, closes, and disables the singleton destinations. Takes no caller inputs. Returns true after logger shutdown.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L389)

<a id="function-function-minisql-common-logger-closehandle-function-closehandle-handle-src-minisql-common-logger-ml-380157248"></a>
### closeHandle

```ml
function closeHandle(handle)
```

Closes an optional file handle and preserves logger shutdown idempotence. Inputs: `handle`. Returns true when no open handle remains.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L144)

<a id="function-function-minisql-common-logger-componentname-function-componentname-src-minisql-common-logger-ml-18344354"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common logger module. Takes no caller inputs. Returns `common.logger`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L404)

<a id="function-function-minisql-common-logger-configure-synchronized-function-configure-level-directory-stdoutenabled-fileenabled-filename-rotationhours-binlogenabled-binlogfilename-src-minisql-common-logger-ml-1453672528"></a>
### configure

```ml
synchronized function configure(level, directory, stdoutEnabled, fileEnabled, fileName, rotationHours, binlogEnabled, binlogFileName)
```

Configures the singleton and opens enabled file destinations eagerly so a bad path fails server startup rather than silently losing later records. Inputs: level/destination/rotation/binlog settings. Returns true when ready.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `level` | `dynamic` | — | level value consumed by this operation. |
| `directory` | `dynamic` | — | directory value consumed by this operation. |
| `stdoutEnabled` | `dynamic` | — | stdoutEnabled value consumed by this operation. |
| `fileEnabled` | `dynamic` | — | fileEnabled value consumed by this operation. |
| `fileName` | `dynamic` | — | fileName value consumed by this operation. |
| `rotationHours` | `dynamic` | — | rotationHours value consumed by this operation. |
| `binlogEnabled` | `dynamic` | — | binlogEnabled value consumed by this operation. |
| `binlogFileName` | `dynamic` | — | binlogFileName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L169)

<a id="function-function-minisql-common-logger-debug-function-debug-component-message-src-minisql-common-logger-ml-1924939814"></a>
### debug

```ml
function debug(component, message)
```

Writes a DEBUG record. Inputs: `component`, `message`. Returns the singleton write status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L291)

<a id="function-function-minisql-common-logger-errorlog-function-errorlog-component-message-src-minisql-common-logger-ml-295714292"></a>
### errorLog

```ml
function errorLog(component, message)
```

Writes an ERROR record. Inputs: `component`, `message`. Returns the singleton write status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L315)

<a id="function-function-minisql-common-logger-escapesql-function-escapesql-sqltext-src-minisql-common-logger-ml-516734445"></a>
### escapeSql

```ml
function escapeSql(sqlText)
```

Escapes control characters so each SQL command occupies exactly one binlog record while retaining its complete text reversibly. Inputs: `sqlText`. Returns escaped SQL text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L323)

<a id="function-function-minisql-common-logger-fail-function-fail-code-operation-message-src-minisql-common-logger-ml-1070551327"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured logger error. Inputs: `code`, `operation`, `message`. Returns an error with stable component context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L66)

<a id="function-function-minisql-common-logger-info-function-info-component-message-src-minisql-common-logger-ml-1921379576"></a>
### info

```ml
function info(component, message)
```

Writes an INFO record. Inputs: `component`, `message`. Returns the singleton write status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L299)

<a id="constant-constant-minisql-common-logger-invalid-argument-const-invalid-argument-9001-src-minisql-common-logger-ml-1528606889"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Process-wide, thread-safe operational logger. Synchronized entry points form


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L15)

<a id="constant-constant-minisql-common-logger-io-failure-const-io-failure-9005-src-minisql-common-logger-ml-1123032497"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L17)

<a id="function-function-minisql-common-logger-isimplemented-function-isimplemented-src-minisql-common-logger-ml-248295954"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common logger module. Takes no caller inputs. Returns true.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L416)

<a id="function-function-minisql-common-logger-lastbinlogarchivepath-synchronized-function-lastbinlogarchivepath-src-minisql-common-logger-ml-1978897046"></a>
### lastBinlogArchivePath

```ml
synchronized function lastBinlogArchivePath()
```

Returns the most recently created binlog archive path, or an empty string before the first non-empty roll. Takes no caller inputs. Returns a stable snapshot under the singleton monitor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L382)

<a id="function-function-minisql-common-logger-lastlogarchivepath-synchronized-function-lastlogarchivepath-src-minisql-common-logger-ml-1630782548"></a>
### lastLogArchivePath

```ml
synchronized function lastLogArchivePath()
```

Returns the most recently created ordinary-log archive path, or an empty string before the first non-empty roll. Takes no caller inputs. Returns a stable snapshot under the singleton monitor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L375)

<a id="constant-constant-minisql-common-logger-level-debug-const-level-debug-10-src-minisql-common-logger-ml-1597187136"></a>
### LEVEL_DEBUG

```ml
const LEVEL_DEBUG = 10
```

Defines the level debug constant used by the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L20)

<a id="constant-constant-minisql-common-logger-level-error-const-level-error-40-src-minisql-common-logger-ml-1055801207"></a>
### LEVEL_ERROR

```ml
const LEVEL_ERROR = 40
```

Defines the level error constant used by the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L26)

<a id="constant-constant-minisql-common-logger-level-info-const-level-info-20-src-minisql-common-logger-ml-1618074053"></a>
### LEVEL_INFO

```ml
const LEVEL_INFO = 20
```

Defines the level info constant used by the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L22)

<a id="constant-constant-minisql-common-logger-level-warning-const-level-warning-30-src-minisql-common-logger-ml-62826430"></a>
### LEVEL_WARNING

```ml
const LEVEL_WARNING = 30
```

Defines the level warning constant used by the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L24)

<a id="function-function-minisql-common-logger-levelname-function-levelname-level-src-minisql-common-logger-ml-1434710328"></a>
### levelName

```ml
function levelName(level)
```

Returns the canonical uppercase label for a numeric severity. Inputs: `level`. Returns DEBUG, INFO, WARNING, or ERROR.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `level` | `dynamic` | — | level value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L84)

<a id="global-global-minisql-common-logger-loggerbinlogenabled-synchronized-loggerbinlogenabled-src-minisql-common-logger-ml-69545838"></a>
### loggerBinlogEnabled

```ml
synchronized loggerBinlogEnabled
```

Stores module-wide logger binlog enabled state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L37)

<a id="global-global-minisql-common-logger-loggerbinlogfile-synchronized-loggerbinlogfile-src-minisql-common-logger-ml-61066418"></a>
### loggerBinlogFile

```ml
synchronized loggerBinlogFile
```

Stores module-wide logger binlog file state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L49)

<a id="global-global-minisql-common-logger-loggerbinlogfilename-synchronized-loggerbinlogfilename-src-minisql-common-logger-ml-1446999582"></a>
### loggerBinlogFileName

```ml
synchronized loggerBinlogFileName
```

Stores module-wide logger binlog file name state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L43)

<a id="global-global-minisql-common-logger-loggerbinlogopenedat-synchronized-loggerbinlogopenedat-src-minisql-common-logger-ml-1591277830"></a>
### loggerBinlogOpenedAt

```ml
synchronized loggerBinlogOpenedAt
```

Stores module-wide logger binlog opened at state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L53)

<a id="global-global-minisql-common-logger-loggerconfigured-synchronized-loggerconfigured-src-minisql-common-logger-ml-320401254"></a>
### loggerConfigured

```ml
synchronized loggerConfigured
```

Stores module-wide logger configured state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L29)

<a id="global-global-minisql-common-logger-loggerdirectory-synchronized-loggerdirectory-src-minisql-common-logger-ml-1344809908"></a>
### loggerDirectory

```ml
synchronized loggerDirectory
```

Stores module-wide logger directory state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L39)

<a id="global-global-minisql-common-logger-loggerfile-synchronized-loggerfile-src-minisql-common-logger-ml-1441917958"></a>
### loggerFile

```ml
synchronized loggerFile
```

Stores module-wide logger file state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L47)

<a id="global-global-minisql-common-logger-loggerfileenabled-synchronized-loggerfileenabled-src-minisql-common-logger-ml-236450312"></a>
### loggerFileEnabled

```ml
synchronized loggerFileEnabled
```

Stores module-wide logger file enabled state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L35)

<a id="global-global-minisql-common-logger-loggerfilename-synchronized-loggerfilename-src-minisql-common-logger-ml-1244148742"></a>
### loggerFileName

```ml
synchronized loggerFileName
```

Stores module-wide logger file name state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L41)

<a id="global-global-minisql-common-logger-loggerlastbinlogarchive-synchronized-loggerlastbinlogarchive-src-minisql-common-logger-ml-297059984"></a>
### loggerLastBinlogArchive

```ml
synchronized loggerLastBinlogArchive
```

Stores module-wide logger last binlog archive state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L59)

<a id="global-global-minisql-common-logger-loggerlastlogarchive-synchronized-loggerlastlogarchive-src-minisql-common-logger-ml-752737846"></a>
### loggerLastLogArchive

```ml
synchronized loggerLastLogArchive
```

Stores module-wide logger last log archive state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L57)

<a id="global-global-minisql-common-logger-loggerminimumlevel-synchronized-loggerminimumlevel-src-minisql-common-logger-ml-128161938"></a>
### loggerMinimumLevel

```ml
synchronized loggerMinimumLevel
```

Stores module-wide logger minimum level state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L31)

<a id="global-global-minisql-common-logger-loggeropenedat-synchronized-loggeropenedat-src-minisql-common-logger-ml-1483825398"></a>
### loggerOpenedAt

```ml
synchronized loggerOpenedAt
```

Stores module-wide logger opened at state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L51)

<a id="global-global-minisql-common-logger-loggerrotationmilliseconds-synchronized-loggerrotationmilliseconds-src-minisql-common-logger-ml-675798014"></a>
### loggerRotationMilliseconds

```ml
synchronized loggerRotationMilliseconds
```

Stores module-wide logger rotation milliseconds state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L45)

<a id="global-global-minisql-common-logger-loggerrotationsequence-synchronized-loggerrotationsequence-src-minisql-common-logger-ml-217156842"></a>
### loggerRotationSequence

```ml
synchronized loggerRotationSequence
```

Stores module-wide logger rotation sequence state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L55)

<a id="global-global-minisql-common-logger-loggerstdoutenabled-synchronized-loggerstdoutenabled-src-minisql-common-logger-ml-2049452550"></a>
### loggerStdoutEnabled

```ml
synchronized loggerStdoutEnabled
```

Stores module-wide logger stdout enabled state for the minisql common logger module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L33)

<a id="function-function-minisql-common-logger-nextarchivepath-function-nextarchivepath-activename-timestamp-src-minisql-common-logger-ml-1461353035"></a>
### nextArchivePath

```ml
function nextArchivePath(activeName, timestamp)
```

Produces a unique archive path for one active file. Inputs: `activeName`, `timestamp`. Returns a path inside the log directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeName` | `dynamic` | — | activeName value consumed by this operation. |
| `timestamp` | `dynamic` | — | timestamp value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L208)

<a id="function-function-minisql-common-logger-openlogfile-function-openlogfile-name-src-minisql-common-logger-ml-303644945"></a>
### openLogFile

```ml
function openLogFile(name)
```

Opens an append-capable log file inside the configured directory. Inputs: `name`. Returns an open writable handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L153)

<a id="function-function-minisql-common-logger-pad2-function-pad2-value-src-minisql-common-logger-ml-1405537813"></a>
### pad2

```ml
function pad2(value)
```

Formats an integer with at least two decimal digits. Inputs: `value`. Returns a zero-padded string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L95)

<a id="function-function-minisql-common-logger-pad4-function-pad4-value-src-minisql-common-logger-ml-597415025"></a>
### pad4

```ml
function pad4(value)
```

Formats a year with at least four decimal digits. Inputs: `value`. Returns a zero-padded string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L103)

<a id="function-function-minisql-common-logger-parselevel-function-parselevel-value-src-minisql-common-logger-ml-685227325"></a>
### parseLevel

```ml
function parseLevel(value)
```

Converts a configured textual level to its ordered numeric severity. Inputs: `value`. Returns a level constant or an invalid-argument error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L73)

<a id="function-function-minisql-common-logger-rollhandle-function-rollhandle-handle-activename-timestamp-src-minisql-common-logger-ml-871024017"></a>
### rollHandle

```ml
function rollHandle(handle, activeName, timestamp)
```

Rolls one destination by closing, renaming a non-empty active file, and opening a fresh active name. The caller holds the singleton monitor. Inputs: `handle`, `activeName`, `timestamp`. Returns the new handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | Native or runtime handle used by the operation. |
| `activeName` | `dynamic` | — | activeName value consumed by this operation. |
| `timestamp` | `dynamic` | — | timestamp value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L220)

<a id="function-function-minisql-common-logger-rotateifdue-function-rotateifdue-now-timestamp-src-minisql-common-logger-ml-1528285762"></a>
### rotateIfDue

```ml
function rotateIfDue(now, timestamp)
```

Rolls elapsed file destinations before the next record is appended. Inputs: `now`, `timestamp`. Returns true after both destinations are current.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `now` | `dynamic` | — | now value consumed by this operation. |
| `timestamp` | `dynamic` | — | timestamp value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L238)

<a id="function-function-minisql-common-logger-rotatenow-synchronized-function-rotatenow-src-minisql-common-logger-ml-1126751350"></a>
### rotateNow

```ml
synchronized function rotateNow()
```

Forces both enabled destinations to roll immediately. This is useful for administrative rotation and deterministic tests without waiting for hours. Takes no caller inputs. Returns true after fresh active files are open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L363)

<a id="function-function-minisql-common-logger-targetmilestone-function-targetmilestone-src-minisql-common-logger-ml-1818843280"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone introducing the singleton operational logger. Takes no caller inputs. Returns `M51`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L410)

<a id="function-function-minisql-common-logger-timestampparts-function-timestampparts-src-minisql-common-logger-ml-1444688594"></a>
### timestampParts

```ml
function timestampParts()
```

Captures local wall-clock text for record display and collision-resistant rolled-file suffixes from the same SYSTEMTIME snapshot. Takes no caller inputs. Returns `[displayTimestamp, fileTimestamp]`.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L113)

<a id="function-function-minisql-common-logger-validatefilename-function-validatefilename-value-name-src-minisql-common-logger-ml-864939386"></a>
### validateFileName

```ml
function validateFileName(value, name)
```

Rejects path separators so configured file names cannot escape the selected log directory. Inputs: `value`, `name`. Returns true or an invalid-argument error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L132)

<a id="function-function-minisql-common-logger-warning-function-warning-component-message-src-minisql-common-logger-ml-143545320"></a>
### warning

```ml
function warning(component, message)
```

Writes a WARNING record. Inputs: `component`, `message`. Returns the singleton write status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L307)

<a id="function-function-minisql-common-logger-write-synchronized-function-write-level-component-message-src-minisql-common-logger-ml-760412368"></a>
### write

```ml
synchronized function write(level, component, message)
```

Writes one severity-filtered operational record to every enabled destination. Inputs: `level`, `component`, `message`. Returns false only if a destination fails.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `level` | `dynamic` | — | level value consumed by this operation. |
| `component` | `dynamic` | — | component value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/logger.ml#L267)
