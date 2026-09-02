# `src/minisql/executor/filter.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.executor.filter`](Package-minisql-executor-filter-1376553475.md)

Reachable from entry: **yes**

## Imports

- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)

## Declarations

<a id="function-function-minisql-executor-filter-apply-function-apply-rows-predicate-src-minisql-executor-filter-ml-2126479770"></a>
### apply

```ml
function apply(rows, predicate)
```

Applies apply using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L23)

<a id="function-function-minisql-executor-filter-componentname-function-componentname-src-minisql-executor-filter-ml-524355326"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L37)

<a id="function-function-minisql-executor-filter-fail-function-fail-code-operation-message-src-minisql-executor-filter-ml-310989407"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L15)

<a id="constant-constant-minisql-executor-filter-invalid-argument-const-invalid-argument-9001-src-minisql-executor-filter-ml-1794472101"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L10)

<a id="function-function-minisql-executor-filter-isimplemented-function-isimplemented-src-minisql-executor-filter-ml-262149318"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L51)

<a id="function-function-minisql-executor-filter-targetmilestone-function-targetmilestone-src-minisql-executor-filter-ml-1266904520"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/filter.ml#L44)
