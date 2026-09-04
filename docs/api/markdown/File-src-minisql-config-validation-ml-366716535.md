# `src/minisql/config/validation.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql config validation facilities for this project.

Package: [`minisql.config.validation`](Package-minisql-config-validation-1886845739.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)
- `minisql/config/model.ml` as `model` → [src/minisql/config/model.ml](File-src-minisql-config-model-ml-1120384851.md)

## Declarations

<a id="function-function-minisql-config-validation-componentname-function-componentname-src-minisql-config-validation-ml-1592093102"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql config validation module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L113)

<a id="function-function-minisql-config-validation-fail-function-fail-message-src-minisql-config-validation-ml-1762653239"></a>
### fail

```ml
function fail(message)
```

Performs the fail operation for the minisql config validation module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L19)

<a id="constant-constant-minisql-config-validation-invalid-configuration-const-invalid-configuration-9002-src-minisql-config-validation-ml-75620910"></a>
### INVALID_CONFIGURATION

```ml
const INVALID_CONFIGURATION = 9002
```

Defines the invalid configuration constant used by the minisql config validation module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L13)

<a id="function-function-minisql-config-validation-isimplemented-function-isimplemented-src-minisql-config-validation-ml-1861970326"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql config validation module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L127)

<a id="function-function-minisql-config-validation-nonempty-function-nonempty-value-name-src-minisql-config-validation-ml-1246623130"></a>
### nonEmpty

```ml
function nonEmpty(value, name)
```

Implements non empty for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L40)

<a id="function-function-minisql-config-validation-positive-function-positive-value-name-src-minisql-config-validation-ml-468436278"></a>
### positive

```ml
function positive(value, name)
```

Implements positive for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L29)

<a id="function-function-minisql-config-validation-targetmilestone-function-targetmilestone-src-minisql-config-validation-ml-536604996"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql config validation module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L120)

<a id="function-function-minisql-config-validation-validate-function-validate-config-src-minisql-config-validation-ml-298327412"></a>
### validate

```ml
function validate(config)
```

Validates validate using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `config` | `dynamic` | — | Configuration used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/validation.ml#L50)
