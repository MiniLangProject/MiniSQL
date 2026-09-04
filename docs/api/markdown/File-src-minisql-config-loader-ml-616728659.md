# `src/minisql/config/loader.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql config loader facilities for this project.

Package: [`minisql.config.loader`](Package-minisql-config-loader-1473622867.md)

Reachable from entry: **yes**

## Imports

- `minisql/config/model.ml` as `model` → [src/minisql/config/model.ml](File-src-minisql-config-model-ml-1120384851.md)
- `minisql/config/validation.ml` as `validation` → [src/minisql/config/validation.ml](File-src-minisql-config-validation-ml-366716535.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)

## Declarations

<a id="function-function-minisql-config-loader-boolmember-function-boolmember-object-key-src-minisql-config-loader-ml-398365118"></a>
### boolMember

```ml
function boolMember(object, key)
```

Implements bool member for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L344)

<a id="function-function-minisql-config-loader-componentname-function-componentname-src-minisql-config-loader-ml-712734766"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql config loader module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L493)

<a id="function-function-minisql-config-loader-ensureonlykeys-function-ensureonlykeys-object-allowedkeys-context-src-minisql-config-loader-ml-1275464266"></a>
### ensureOnlyKeys

```ml
function ensureOnlyKeys(object, allowedKeys, context)
```

Ensures only keys using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `allowedKeys` | `dynamic` | — | allowedKeys value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L369)

<a id="function-function-minisql-config-loader-expect-function-expect-parser-expected-operation-src-minisql-config-loader-ml-794451616"></a>
### expect

```ml
function expect(parser, expected, operation)
```

Implements expect for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L98)

<a id="function-function-minisql-config-loader-fail-function-fail-operation-message-src-minisql-config-loader-ml-712538310"></a>
### fail

```ml
function fail(operation, message)
```

Performs the fail operation for the minisql config loader module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L62)

<a id="function-function-minisql-config-loader-intmember-function-intmember-object-key-src-minisql-config-loader-ml-428072116"></a>
### intMember

```ml
function intMember(object, key)
```

Implements int member for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L333)

<a id="constant-constant-minisql-config-loader-invalid-configuration-const-invalid-configuration-9002-src-minisql-config-loader-ml-251303806"></a>
### INVALID_CONFIGURATION

```ml
const INVALID_CONFIGURATION = 9002
```

Defines the invalid configuration constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L14)

<a id="function-function-minisql-config-loader-isdigit-function-isdigit-value-src-minisql-config-loader-ml-2023040735"></a>
### isDigit

```ml
function isDigit(value)
```

Returns whether the supplied value satisfies the digit condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L149)

<a id="function-function-minisql-config-loader-isimplemented-function-isimplemented-src-minisql-config-loader-ml-127252518"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql config loader module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L507)

<a id="constant-constant-minisql-config-loader-json-array-const-json-array-5-src-minisql-config-loader-ml-1340486098"></a>
### JSON_ARRAY

```ml
const JSON_ARRAY = 5
```

Defines the json array constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L29)

<a id="constant-constant-minisql-config-loader-json-bool-const-json-bool-1-src-minisql-config-loader-ml-1105568016"></a>
### JSON_BOOL

```ml
const JSON_BOOL = 1
```

Defines the json bool constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L21)

<a id="constant-constant-minisql-config-loader-json-int-const-json-int-2-src-minisql-config-loader-ml-1782414173"></a>
### JSON_INT

```ml
const JSON_INT = 2
```

Defines the json int constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L23)

<a id="constant-constant-minisql-config-loader-json-null-const-json-null-0-src-minisql-config-loader-ml-1981711809"></a>
### JSON_NULL

```ml
const JSON_NULL = 0
```

Defines the json null constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L19)

<a id="constant-constant-minisql-config-loader-json-object-const-json-object-4-src-minisql-config-loader-ml-488124273"></a>
### JSON_OBJECT

```ml
const JSON_OBJECT = 4
```

Defines the json object constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L27)

<a id="constant-constant-minisql-config-loader-json-string-const-json-string-3-src-minisql-config-loader-ml-1920791998"></a>
### JSON_STRING

```ml
const JSON_STRING = 3
```

Defines the json string constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L25)

- [minisql.config.loader.JsonPair](Type-minisql-config-loader-jsonpair-455794721.md) — struct
- [minisql.config.loader.JsonValue](Type-minisql-config-loader-jsonvalue-1124844058.md) — struct
<a id="function-function-minisql-config-loader-load-function-load-path-src-minisql-config-loader-ml-1020072617"></a>
### load

```ml
function load(path)
```

Loads load using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L474)

<a id="function-function-minisql-config-loader-matchliteral-function-matchliteral-parser-text-src-minisql-config-loader-ml-1877433798"></a>
### matchLiteral

```ml
function matchLiteral(parser, text)
```

Implements match literal for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L185)

<a id="constant-constant-minisql-config-loader-max-config-bytes-const-max-config-bytes-1048576-src-minisql-config-loader-ml-881264294"></a>
### MAX_CONFIG_BYTES

```ml
const MAX_CONFIG_BYTES = 1048576
```

Defines the max config bytes constant used by the minisql config loader module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L16)

<a id="function-function-minisql-config-loader-member-function-member-object-key-src-minisql-config-loader-ml-2121791062"></a>
### member

```ml
function member(object, key)
```

Implements member for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L286)

<a id="function-function-minisql-config-loader-objectmember-function-objectmember-object-key-src-minisql-config-loader-ml-1193882294"></a>
### objectMember

```ml
function objectMember(object, key)
```

Implements object member for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L311)

<a id="function-function-minisql-config-loader-optionalintmember-function-optionalintmember-object-key-defaultvalue-src-minisql-config-loader-ml-1123232018"></a>
### optionalIntMember

```ml
function optionalIntMember(object, key, defaultValue)
```

Reads an optional integer while preserving backwards-compatible defaults.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |
| `defaultValue` | `dynamic` | — | defaultValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L354)

<a id="function-function-minisql-config-loader-optionalmember-function-optionalmember-object-key-src-minisql-config-loader-ml-158572846"></a>
### optionalMember

```ml
function optionalMember(object, key)
```

Looks up an optional object member without weakening strict unknown-key validation. Inputs: `object`, `key`. Returns the JSON value or void when the key is absent.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L298)

<a id="function-function-minisql-config-loader-parse-function-parse-text-src-minisql-config-loader-ml-426969023"></a>
### parse

```ml
function parse(text)
```

Parses parse using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L271)

<a id="function-function-minisql-config-loader-parsearray-function-parsearray-parser-src-minisql-config-loader-ml-624907013"></a>
### parseArray

```ml
function parseArray(parser)
```

Parses array using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L201)

<a id="function-function-minisql-config-loader-parseinteger-function-parseinteger-parser-src-minisql-config-loader-ml-1518684517"></a>
### parseInteger

```ml
function parseInteger(parser)
```

Parses integer using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L158)

<a id="function-function-minisql-config-loader-parseobject-function-parseobject-parser-src-minisql-config-loader-ml-2091080121"></a>
### parseObject

```ml
function parseObject(parser)
```

Parses object using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L224)

- [minisql.config.loader.Parser](Type-minisql-config-loader-parser-1540139416.md) — struct
<a id="function-function-minisql-config-loader-parsestring-function-parsestring-parser-src-minisql-config-loader-ml-516787009"></a>
### parseString

```ml
function parseString(parser)
```

Parses string using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L111)

<a id="function-function-minisql-config-loader-parsevalue-function-parsevalue-parser-src-minisql-config-loader-ml-1322716713"></a>
### parseValue

```ml
function parseValue(parser)
```

Parses value using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L254)

<a id="function-function-minisql-config-loader-peek-function-peek-parser-src-minisql-config-loader-ml-1072463429"></a>
### peek

```ml
function peek(parser)
```

Implements peek for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L86)

<a id="function-function-minisql-config-loader-skipwhitespace-function-skipwhitespace-parser-src-minisql-config-loader-ml-2124164697"></a>
### skipWhitespace

```ml
function skipWhitespace(parser)
```

Implements skip whitespace for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parser` | `dynamic` | — | parser value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L70)

<a id="function-function-minisql-config-loader-stringmember-function-stringmember-object-key-src-minisql-config-loader-ml-2062495582"></a>
### stringMember

```ml
function stringMember(object, key)
```

Implements string member for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `dynamic` | — | object value consumed by this operation. |
| `key` | `dynamic` | — | key value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L322)

<a id="function-function-minisql-config-loader-targetmilestone-function-targetmilestone-src-minisql-config-loader-ml-1492583176"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql config loader module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L500)

<a id="function-function-minisql-config-loader-toconfig-function-toconfig-root-src-minisql-config-loader-ml-887748334"></a>
### toConfig

```ml
function toConfig(root)
```

Implements to config for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — | root value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/loader.ml#L385)
