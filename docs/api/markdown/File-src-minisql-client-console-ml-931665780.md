# `src/minisql/client/console.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql client console facilities for this project.

Package: [`minisql.client.console`](Package-minisql-client-console-935104928.md)

Reachable from entry: **yes**

## Imports

- `minisql/client/client.ml` as `client` → [src/minisql/client/client.ml](File-src-minisql-client-client-ml-193935498.md)
- `minisql/client/formatter.ml` as `formatter` → [src/minisql/client/formatter.ml](File-src-minisql-client-formatter-ml-1949327393.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `std/console.ml` as `console_api` → `../MiniLangCompilerML/std/console.ml` — external dependency

## Declarations

<a id="function-function-minisql-client-console-appendsqlfragment-function-appendsqlfragment-statements-source-startoffset-endoffset-hastoken-src-minisql-client-console-ml-1010305493"></a>
### appendSqlFragment

```ml
function appendSqlFragment(statements, source, startOffset, endOffset, hasToken)
```

Appends SQL fragment using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statements` | `dynamic` | — | statements value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `startOffset` | `dynamic` | — | startOffset value consumed by this operation. |
| `endOffset` | `dynamic` | — | endOffset value consumed by this operation. |
| `hasToken` | `dynamic` | — | hasToken value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L433)

<a id="function-function-minisql-client-console-commandargument-function-commandargument-line-prefix-src-minisql-client-console-ml-1905937752"></a>
### commandArgument

```ml
function commandArgument(line, prefix)
```

Implements command argument for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — | line value consumed by this operation. |
| `prefix` | `dynamic` | — | prefix value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L596)

<a id="function-function-minisql-client-console-componentname-function-componentname-src-minisql-client-console-ml-2094586446"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql client console module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L750)

<a id="constant-constant-minisql-client-console-cp-utf8-const-cp-utf8-65001-src-minisql-client-console-ml-1512474041"></a>
### CP_UTF8

```ml
const CP_UTF8 = 65001
```

Defines the cp utf8 constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L32)

<a id="function-function-minisql-client-console-disablequickedit-function-disablequickedit-src-minisql-client-console-ml-1944763646"></a>
### disableQuickEdit

```ml
function disableQuickEdit()
```

Prevents accidental mouse selection from suspending a Windows console server. Redirected standard input and service processes have no console and are treated as already safe; a real console-mode update reports failures.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L103)

<a id="constant-constant-minisql-client-console-enable-echo-input-const-enable-echo-input-4-src-minisql-client-console-ml-1739088817"></a>
### ENABLE_ECHO_INPUT

```ml
const ENABLE_ECHO_INPUT = 4
```

Defines the enable echo input constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L26)

<a id="constant-constant-minisql-client-console-enable-extended-flags-const-enable-extended-flags-128-src-minisql-client-console-ml-174759396"></a>
### ENABLE_EXTENDED_FLAGS

```ml
const ENABLE_EXTENDED_FLAGS = 128
```

Defines the enable extended flags constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L30)

<a id="constant-constant-minisql-client-console-enable-quick-edit-mode-const-enable-quick-edit-mode-64-src-minisql-client-console-ml-248695477"></a>
### ENABLE_QUICK_EDIT_MODE

```ml
const ENABLE_QUICK_EDIT_MODE = 64
```

Defines the enable quick edit mode constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L28)

<a id="function-function-minisql-client-console-executemeta-function-executemeta-activeclient-line-src-minisql-client-console-ml-1983556331"></a>
### executeMeta

```ml
function executeMeta(activeClient, line)
```

Executes meta using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeClient` | `dynamic` | — | activeClient value consumed by this operation. |
| `line` | `dynamic` | — | line value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L657)

<a id="function-function-minisql-client-console-executeonce-function-executeonce-activeclient-sqltext-src-minisql-client-console-ml-337902070"></a>
### executeOnce

```ml
function executeOnce(activeClient, sqlText)
```

Executes once using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeClient` | `dynamic` | — | activeClient value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L133)

<a id="function-function-minisql-client-console-executestatements-function-executestatements-activeclient-statements-src-minisql-client-console-ml-1846893909"></a>
### executeStatements

```ml
function executeStatements(activeClient, statements)
```

Executes statements using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeClient` | `dynamic` | — | activeClient value consumed by this operation. |
| `statements` | `dynamic` | — | statements value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L554)

<a id="function-function-minisql-client-console-fail-function-fail-code-operation-message-src-minisql-client-console-ml-7739793"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql client console module. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L96)

<a id="extern_function-extern-function-minisql-client-console-getconsolemode-extern-function-getconsolemode-handle-as-ptr-mode-as-bytes-from-kernel32-dll-symbol-getconsolemode-returns-bool-src-minisql-client-console-ml-707164896"></a>
### GetConsoleMode

```ml
extern function GetConsoleMode(handle as ptr, mode as bytes) from "kernel32.dll" symbol "GetConsoleMode" returns bool
```

Reads console-mode flags into `mode` and returns false on a Win32 error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — | Native or runtime handle used by the operation. |
| `mode` | `bytes` | — | Mode selecting the requested behavior. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L55)

<a id="extern_function-extern-function-minisql-client-console-getstdhandle-extern-function-getstdhandle-kind-as-i32-from-kernel32-dll-symbol-getstdhandle-returns-ptr-src-minisql-client-console-ml-53103385"></a>
### GetStdHandle

```ml
extern function GetStdHandle(kind as i32) from "kernel32.dll" symbol "GetStdHandle" returns ptr
```

Returns the Windows standard-stream handle identified by `kind`; failure uses an invalid native handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `i32` | — | kind value consumed by this operation. |


**Returns:** Native ptr result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L50)

<a id="constant-constant-minisql-client-console-invalid-argument-const-invalid-argument-9001-src-minisql-client-console-ml-715297279"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L18)

<a id="constant-constant-minisql-client-console-io-failure-const-io-failure-9005-src-minisql-client-console-ml-1581845903"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L20)

<a id="function-function-minisql-client-console-isidentifierbyte-function-isidentifierbyte-value-first-src-minisql-client-console-ml-930599029"></a>
### isIdentifierByte

```ml
function isIdentifierByte(value, first)
```

Returns whether the supplied value satisfies the identifier byte condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `first` | `dynamic` | — | first value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L609)

<a id="function-function-minisql-client-console-isimplemented-function-isimplemented-src-minisql-client-console-ml-1986708534"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql client console module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L764)

<a id="function-function-minisql-client-console-ismetacommand-function-ismetacommand-text-src-minisql-client-console-ml-594018787"></a>
### isMetaCommand

```ml
function isMetaCommand(text)
```

Returns whether the supplied value satisfies the meta command condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L124)

<a id="function-function-minisql-client-console-issafemetaidentifier-function-issafemetaidentifier-value-src-minisql-client-console-ml-1475470437"></a>
### isSafeMetaIdentifier

```ml
function isSafeMetaIdentifier(value)
```

Returns whether the supplied value satisfies the safe meta identifier condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L621)

<a id="function-function-minisql-client-console-isscriptcomment-function-isscriptcomment-line-src-minisql-client-console-ml-983739572"></a>
### isScriptComment

```ml
function isScriptComment(line)
```

Returns whether the supplied value satisfies the script comment condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — | line value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L358)

<a id="function-function-minisql-client-console-issqlbatch-function-issqlbatch-value-src-minisql-client-console-ml-2056054537"></a>
### isSqlBatch

```ml
function isSqlBatch(value)
```

Returns whether the supplied value satisfies the SQL batch condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L399)

<a id="function-function-minisql-client-console-iswhitespacebyte-function-iswhitespacebyte-value-src-minisql-client-console-ml-1287863277"></a>
### isWhitespaceByte

```ml
function isWhitespaceByte(value)
```

Returns whether the supplied value satisfies the whitespace byte condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L407)

<a id="constant-constant-minisql-client-console-max-password-utf16-units-const-max-password-utf16-units-1024-src-minisql-client-console-ml-1968761610"></a>
### MAX_PASSWORD_UTF16_UNITS

```ml
const MAX_PASSWORD_UTF16_UNITS = 1024
```

Defines the max password utf16 units constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L36)

<a id="function-function-minisql-client-console-openauthenticatedprompt-function-openauthenticatedprompt-address-port-username-src-minisql-client-console-ml-1386038845"></a>
### openAuthenticatedPrompt

```ml
function openAuthenticatedPrompt(address, port, username)
```

Opens authenticated prompt using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L263)

<a id="function-function-minisql-client-console-opentlsauthenticatedprompt-function-opentlsauthenticatedprompt-address-port-servername-username-src-minisql-client-console-ml-443851539"></a>
### openTlsAuthenticatedPrompt

```ml
function openTlsAuthenticatedPrompt(address, port, serverName, username)
```

Prompts for a password and opens native TLS using Windows certificate trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L277)

<a id="function-function-minisql-client-console-opentlspinnedauthenticatedprompt-function-opentlspinnedauthenticatedprompt-address-port-servername-pintext-username-src-minisql-client-console-ml-454610769"></a>
### openTlsPinnedAuthenticatedPrompt

```ml
function openTlsPinnedAuthenticatedPrompt(address, port, serverName, pinText, username)
```

Prompts for a password and opens native TLS using an exact leaf SHA-256 pin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | address value consumed by this operation. |
| `port` | `dynamic` | — | port value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L292)

<a id="function-function-minisql-client-console-printqueryresponse-function-printqueryresponse-response-src-minisql-client-console-ml-1181906627"></a>
### printQueryResponse

```ml
function printQueryResponse(response)
```

Prints query response using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — | response value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L541)

<a id="function-function-minisql-client-console-printshellhelp-function-printshellhelp-src-minisql-client-console-ml-1097463758"></a>
### printShellHelp

```ml
function printShellHelp()
```

Prints shell help using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L636)

<a id="function-function-minisql-client-console-rawtext-function-rawtext-source-offset-count-src-minisql-client-console-ml-1468995475"></a>
### rawText

```ml
function rawText(source, offset, count)
```

Implements raw text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L418)

<a id="extern_function-extern-function-minisql-client-console-readconsolew-extern-function-readconsolew-handle-as-ptr-buffer-as-bytes-count-as-u32-readout-as-bytes-control-as-ptr-from-kernel32-dll-symbol-readconsolew-returns-bool-src-minisql-client-console-ml-995591226"></a>
### ReadConsoleW

```ml
extern function ReadConsoleW(handle as ptr, buffer as bytes, count as u32, readOut as bytes, control as ptr) from "kernel32.dll" symbol "ReadConsoleW" returns bool
```

Reads UTF-16 console input into `buffer`, reporting the unit count through `readOut`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — | Native or runtime handle used by the operation. |
| `buffer` | `bytes` | — | Buffer that receives or supplies the operation data. |
| `count` | `u32` | — | Number of items or units to process. |
| `readOut` | `bytes` | — | readOut value consumed by this operation. |
| `control` | `ptr` | — | control value consumed by this operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L68)

<a id="function-function-minisql-client-console-readpassword-function-readpassword-prompt-src-minisql-client-console-ml-387799384"></a>
### readPassword

```ml
function readPassword(prompt)
```

Reads password using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prompt` | `dynamic` | — | prompt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L193)

<a id="function-function-minisql-client-console-readpasswordconfirmed-function-readpasswordconfirmed-prompt-confirmationprompt-src-minisql-client-console-ml-1456327181"></a>
### readPasswordConfirmed

```ml
function readPasswordConfirmed(prompt, confirmationPrompt)
```

Reads password confirmed using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prompt` | `dynamic` | — | prompt value consumed by this operation. |
| `confirmationPrompt` | `dynamic` | — | confirmationPrompt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L245)

<a id="function-function-minisql-client-console-runscript-function-runscript-activeclient-path-src-minisql-client-console-ml-1344560780"></a>
### runScript

```ml
function runScript(activeClient, path)
```

Runs script using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeClient` | `dynamic` | — | activeClient value consumed by this operation. |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L581)

<a id="function-function-minisql-client-console-runshell-function-runshell-activeclient-prompt-src-minisql-client-console-ml-1448604231"></a>
### runShell

```ml
function runShell(activeClient, prompt)
```

Runs shell using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `activeClient` | `dynamic` | — | activeClient value consumed by this operation. |
| `prompt` | `dynamic` | — | prompt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L693)

<a id="function-function-minisql-client-console-scansqlbatch-function-scansqlbatch-text-finalinput-src-minisql-client-console-ml-1580539323"></a>
### scanSqlBatch

```ml
function scanSqlBatch(text, finalInput)
```

Split complete SQL statements without treating semicolons inside quoted strings, quoted identifiers or comments as terminators. When finalInput is false, an incomplete suffix is returned for the interactive continuation prompt. When finalInput is true, a final statement may omit its semicolon. Scans SQL batch using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `finalInput` | `dynamic` | — | finalInput value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L450)

<a id="extern_function-extern-function-minisql-client-console-setconsolemode-extern-function-setconsolemode-handle-as-ptr-mode-as-u32-from-kernel32-dll-symbol-setconsolemode-returns-bool-src-minisql-client-console-ml-1497610401"></a>
### SetConsoleMode

```ml
extern function SetConsoleMode(handle as ptr, mode as u32) from "kernel32.dll" symbol "SetConsoleMode" returns bool
```

Replaces console-mode flags and returns false on a Win32 error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — | Native or runtime handle used by the operation. |
| `mode` | `u32` | — | Mode selecting the requested behavior. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L60)

<a id="function-function-minisql-client-console-splitlines-function-splitlines-text-src-minisql-client-console-ml-76886627"></a>
### splitLines

```ml
function splitLines(text)
```

Implements split lines for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L370)

<a id="function-function-minisql-client-console-splitsqlstatements-function-splitsqlstatements-text-src-minisql-client-console-ml-463089859"></a>
### splitSqlStatements

```ml
function splitSqlStatements(text)
```

Implements split SQL statements for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L532)

- [minisql.client.console.SqlBatch](Type-minisql-client-console-sqlbatch-2091586626.md) — struct
<a id="function-function-minisql-client-console-startswithbytes-function-startswithbytes-text-first-second-src-minisql-client-console-ml-1583632311"></a>
### startsWithBytes

```ml
function startsWithBytes(text, first, second)
```

Implements starts with bytes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `first` | `dynamic` | — | first value consumed by this operation. |
| `second` | `dynamic` | — | second value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L328)

<a id="function-function-minisql-client-console-startswithtext-function-startswithtext-text-prefix-src-minisql-client-console-ml-112134931"></a>
### startsWithText

```ml
function startsWithText(text, prefix)
```

Implements starts with text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `prefix` | `dynamic` | — | prefix value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L340)

<a id="constant-constant-minisql-client-console-std-input-handle-const-std-input-handle-10-src-minisql-client-console-ml-1587103395"></a>
### STD_INPUT_HANDLE

```ml
const STD_INPUT_HANDLE = -10
```

Defines the std input handle constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L22)

<a id="constant-constant-minisql-client-console-std-output-handle-const-std-output-handle-11-src-minisql-client-console-ml-1849187272"></a>
### STD_OUTPUT_HANDLE

```ml
const STD_OUTPUT_HANDLE = -11
```

Defines the std output handle constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L24)

<a id="function-function-minisql-client-console-targetmilestone-function-targetmilestone-src-minisql-client-console-ml-1073307508"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql client console module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L757)

<a id="function-function-minisql-client-console-trimascii-function-trimascii-text-src-minisql-client-console-ml-1840217793"></a>
### trimAscii

```ml
function trimAscii(text)
```

Implements trim ascii for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L306)

<a id="function-function-minisql-client-console-utf16passwordtoutf8-function-utf16passwordtoutf8-wide-units-src-minisql-client-console-ml-1891019474"></a>
### utf16PasswordToUtf8

```ml
function utf16PasswordToUtf8(wide, units)
```

Implements utf16 password to UTF-8 for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wide` | `dynamic` | — | wide value consumed by this operation. |
| `units` | `dynamic` | — | units value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L173)

<a id="constant-constant-minisql-client-console-wc-err-invalid-chars-const-wc-err-invalid-chars-128-src-minisql-client-console-ml-1798620070"></a>
### WC_ERR_INVALID_CHARS

```ml
const WC_ERR_INVALID_CHARS = 128
```

Defines the wc err invalid chars constant used by the minisql client console module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L34)

<a id="extern_function-extern-function-minisql-client-console-widechartomultibyte-extern-function-widechartomultibyte-codepage-as-u32-flags-as-u32-widetext-as-bytes-widecount-as-i32-output-as-bytes-outputcount-as-i32-defaultchar-as-ptr-useddefault-as-ptr-from-kernel32-dll-symbol-widechartomultibyte-returns-i32-src-minisql-client-console-ml-1045535032"></a>
### WideCharToMultiByte

```ml
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32
```

Converts UTF-16 units to the requested code page; returns bytes written or zero on failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `codePage` | `u32` | — | codePage value consumed by this operation. |
| `flags` | `u32` | — | Bit flags controlling the operation. |
| `wideText` | `bytes` | — | wideText value consumed by this operation. |
| `wideCount` | `i32` | — | Number of wide to process. |
| `output` | `bytes` | — | Output collection or buffer populated by the operation. |
| `outputCount` | `i32` | — | Number of output to process. |
| `defaultChar` | `ptr` | — | defaultChar value consumed by this operation. |
| `usedDefault` | `ptr` | — | usedDefault value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L87)

<a id="function-function-minisql-client-console-wipepassword-function-wipepassword-passwordbytes-src-minisql-client-console-ml-723476118"></a>
### wipePassword

```ml
function wipePassword(passwordBytes)
```

Implements wipe password for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L141)

<a id="extern_function-extern-function-minisql-client-console-writeconsolew-extern-function-writeconsolew-handle-as-ptr-text-as-wstr-count-as-u32-writtenout-as-bytes-reserved-as-ptr-from-kernel32-dll-symbol-writeconsolew-returns-bool-src-minisql-client-console-ml-10162773"></a>
### WriteConsoleW

```ml
extern function WriteConsoleW(handle as ptr, text as wstr, count as u32, writtenOut as bytes, reserved as ptr) from "kernel32.dll" symbol "WriteConsoleW" returns bool
```

Writes UTF-16 console text and reports the unit count through `writtenOut`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — | Native or runtime handle used by the operation. |
| `text` | `wstr` | — | Text consumed by the operation. |
| `count` | `u32` | — | Number of items or units to process. |
| `writtenOut` | `bytes` | — | writtenOut value consumed by this operation. |
| `reserved` | `ptr` | — | reserved value consumed by this operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L76)

<a id="function-function-minisql-client-console-writeprompt-function-writeprompt-outputhandle-prompt-src-minisql-client-console-ml-24564463"></a>
### writePrompt

```ml
function writePrompt(outputHandle, prompt)
```

Writes prompt using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `outputHandle` | `dynamic` | — | outputHandle value consumed by this operation. |
| `prompt` | `dynamic` | — | prompt value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L151)
