# `src/minisql/admin/connection_profiles.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql admin connection profiles facilities for this project.

Package: [`minisql.admin.connection_profiles`](Package-minisql-admin-connection-profiles-896864838.md)

Reachable from entry: **no**

## Imports

- `minisql/admin/fullclient.ml` as `fullclient` → [src/minisql/admin/fullclient.ml](File-src-minisql-admin-fullclient-ml-1896932593.md)
- `minisql/config/loader.ml` as `json` → [src/minisql/config/loader.ml](File-src-minisql-config-loader-ml-616728659.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)

## Declarations

<a id="function-function-minisql-admin-connection-profiles-componentname-function-componentname-src-minisql-admin-connection-profiles-ml-1237966710"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L248)

<a id="constant-constant-minisql-admin-connection-profiles-cp-utf8-const-cp-utf8-65001-src-minisql-admin-connection-profiles-ml-1579490063"></a>
### CP_UTF8

```ml
const CP_UTF8 = 65001
```

Defines the cp utf8 constant used by the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L18)

<a id="function-function-minisql-admin-connection-profiles-defaultpath-function-defaultpath-src-minisql-admin-connection-profiles-ml-478093558"></a>
### defaultPath

```ml
function defaultPath()
```

Resolves the per-user connection-alias file and creates its parent directory.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L66)

<a id="function-function-minisql-admin-connection-profiles-defaultprofile-function-defaultprofile-src-minisql-admin-connection-profiles-ml-893744758"></a>
### defaultProfile

```ml
function defaultProfile()
```

Returns the first-run trusted-local alias used by the connection manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L78)

<a id="function-function-minisql-admin-connection-profiles-environment-function-environment-name-src-minisql-admin-connection-profiles-ml-952292723"></a>
### environment

```ml
function environment(name)
```

Returns one Unicode Windows environment variable as UTF-8 or an empty string when unavailable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L51)

<a id="function-function-minisql-admin-connection-profiles-escape-function-escape-value-src-minisql-admin-connection-profiles-ml-761035631"></a>
### escape

```ml
function escape(value)
```

Escapes a UTF-8 profile field while preserving every valid non-ASCII byte unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L91)

<a id="function-function-minisql-admin-connection-profiles-fail-function-fail-operation-message-src-minisql-admin-connection-profiles-ml-1235193630"></a>
### fail

```ml
function fail(operation, message)
```

Creates a namespaced profile-store error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L45)

<a id="extern_function-extern-function-minisql-admin-connection-profiles-getenvironmentvariablew-extern-function-getenvironmentvariablew-name-as-wstr-buffer-as-bytes-size-as-u32-from-kernel32-dll-symbol-getenvironmentvariablew-returns-u32-src-minisql-admin-connection-profiles-ml-1381608087"></a>
### GetEnvironmentVariableW

```ml
extern function GetEnvironmentVariableW(name as wstr, buffer as bytes, size as u32) from "kernel32.dll" symbol "GetEnvironmentVariableW" returns u32
```

Reads a Windows environment variable as UTF-16 so non-ASCII profile paths remain lossless.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `wstr` | — | Name of the affected item. |
| `buffer` | `bytes` | — | Buffer that receives or supplies the operation data. |
| `size` | `u32` | — | Size in the units required by the operation. |


**Returns:** Native u32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L29)

<a id="constant-constant-minisql-admin-connection-profiles-invalid-argument-const-invalid-argument-9001-src-minisql-admin-connection-profiles-ml-2004344089"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L14)

<a id="function-function-minisql-admin-connection-profiles-isimplemented-function-isimplemented-src-minisql-admin-connection-profiles-ml-1020041710"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that persistent aliases are implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L258)

<a id="function-function-minisql-admin-connection-profiles-load-function-load-path-src-minisql-admin-connection-profiles-ml-426072521"></a>
### load

```ml
function load(path)
```

Loads aliases or returns the first-run default when no file exists.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L201)

<a id="constant-constant-minisql-admin-connection-profiles-max-environment-utf16-units-const-max-environment-utf16-units-32768-src-minisql-admin-connection-profiles-ml-577557655"></a>
### MAX_ENVIRONMENT_UTF16_UNITS

```ml
const MAX_ENVIRONMENT_UTF16_UNITS = 32768
```

Defines the max environment utf16 units constant used by the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L22)

<a id="constant-constant-minisql-admin-connection-profiles-max-profile-document-bytes-const-max-profile-document-bytes-16777216-src-minisql-admin-connection-profiles-ml-121485172"></a>
### MAX_PROFILE_DOCUMENT_BYTES

```ml
const MAX_PROFILE_DOCUMENT_BYTES = 16777216
```

Defines the max profile document bytes constant used by the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L16)

<a id="function-function-minisql-admin-connection-profiles-profilefromjson-function-profilefromjson-value-src-minisql-admin-connection-profiles-ml-2108427221"></a>
### profileFromJson

```ml
function profileFromJson(value)
```

Decodes one schema-version-two profile object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L177)

<a id="function-function-minisql-admin-connection-profiles-profilejson-function-profilejson-profile-src-minisql-admin-connection-profiles-ml-1073360725"></a>
### profileJson

```ml
function profileJson(profile)
```

Serializes one validated alias without a password or other secret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L117)

<a id="function-function-minisql-admin-connection-profiles-remove-function-remove-profiles-name-src-minisql-admin-connection-profiles-ml-1549359319"></a>
### remove

```ml
function remove(profiles, name)
```

Removes the alias with the supplied exact name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L239)

<a id="function-function-minisql-admin-connection-profiles-replace-function-replace-profiles-profile-src-minisql-admin-connection-profiles-ml-723006357"></a>
### replace

```ml
function replace(profiles, profile)
```

Replaces an alias by name or appends it when it is new.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L224)

<a id="function-function-minisql-admin-connection-profiles-save-function-save-path-profiles-src-minisql-admin-connection-profiles-ml-1255652535"></a>
### save

```ml
function save(path, profiles)
```

Persists aliases atomically and never serializes the connection password.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L168)

<a id="function-function-minisql-admin-connection-profiles-serialize-function-serialize-profiles-src-minisql-admin-connection-profiles-ml-606203636"></a>
### serialize

```ml
function serialize(profiles)
```

Serializes all aliases using a versioned JSON envelope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profiles` | `dynamic` | — | profiles value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L129)

<a id="function-function-minisql-admin-connection-profiles-targetmilestone-function-targetmilestone-src-minisql-admin-connection-profiles-ml-1385711664"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L253)

<a id="function-function-minisql-admin-connection-profiles-validate-function-validate-profile-src-minisql-admin-connection-profiles-ml-1139155027"></a>
### validate

```ml
function validate(profile)
```

Revalidates a profile through the canonical model constructor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — | profile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L84)

<a id="constant-constant-minisql-admin-connection-profiles-wc-err-invalid-chars-const-wc-err-invalid-chars-128-src-minisql-admin-connection-profiles-ml-462265418"></a>
### WC_ERR_INVALID_CHARS

```ml
const WC_ERR_INVALID_CHARS = 128
```

Defines the wc err invalid chars constant used by the minisql admin connection profiles module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L20)

<a id="extern_function-extern-function-minisql-admin-connection-profiles-widechartomultibyte-extern-function-widechartomultibyte-codepage-as-u32-flags-as-u32-widetext-as-bytes-widecount-as-i32-output-as-bytes-outputcount-as-i32-defaultchar-as-ptr-useddefault-as-ptr-from-kernel32-dll-symbol-widechartomultibyte-returns-i32-src-minisql-admin-connection-profiles-ml-1785642218"></a>
### WideCharToMultiByte

```ml
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32
```

Converts a UTF-16 environment value into the UTF-8 representation used by MiniLang strings.

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

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L40)

<a id="function-function-minisql-admin-connection-profiles-write-function-write-path-text-src-minisql-admin-connection-profiles-ml-268521028"></a>
### write

```ml
function write(path, text)
```

Durably replaces the alias file through a flushed temporary sibling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/connection_profiles.ml#L146)
