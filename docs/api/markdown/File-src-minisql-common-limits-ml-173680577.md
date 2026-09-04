# `src/minisql/common/limits.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common limits facilities for this project.

Package: [`minisql.common.limits`](Package-minisql-common-limits-2094953501.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-limits-componentname-function-componentname-src-minisql-common-limits-ml-2138771630"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common limits module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L35)

<a id="constant-constant-minisql-common-limits-default-page-size-const-default-page-size-4096-src-minisql-common-limits-ml-1174271558"></a>
### DEFAULT_PAGE_SIZE

```ml
const DEFAULT_PAGE_SIZE = 4096
```

Defines the default page size constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L12)

<a id="constant-constant-minisql-common-limits-default-port-const-default-port-7432-src-minisql-common-limits-ml-414369745"></a>
### DEFAULT_PORT

```ml
const DEFAULT_PORT = 7432
```

Shared format and protocol limits. Keeping these bounds in one module makes


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L10)

<a id="function-function-minisql-common-limits-isimplemented-function-isimplemented-src-minisql-common-limits-ml-140839550"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common limits module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L47)

<a id="function-function-minisql-common-limits-issupportedpagesize-function-issupportedpagesize-pagesize-src-minisql-common-limits-ml-715466428"></a>
### isSupportedPageSize

```ml
function isSupportedPageSize(pageSize)
```

Evaluates whether the supplied input satisfies the supported page size predicate. Inputs: `pageSize`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L29)

<a id="constant-constant-minisql-common-limits-max-decimal-precision-const-max-decimal-precision-18-src-minisql-common-limits-ml-1448954828"></a>
### MAX_DECIMAL_PRECISION

```ml
const MAX_DECIMAL_PRECISION = 18
```

Defines the max decimal precision constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L22)

<a id="constant-constant-minisql-common-limits-max-identifier-bytes-const-max-identifier-bytes-128-src-minisql-common-limits-ml-417635728"></a>
### MAX_IDENTIFIER_BYTES

```ml
const MAX_IDENTIFIER_BYTES = 128
```

Defines the max identifier bytes constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L18)

<a id="constant-constant-minisql-common-limits-max-page-size-const-max-page-size-32768-src-minisql-common-limits-ml-2003500105"></a>
### MAX_PAGE_SIZE

```ml
const MAX_PAGE_SIZE = 32768
```

Defines the max page size constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L16)

<a id="constant-constant-minisql-common-limits-max-sql-nesting-const-max-sql-nesting-64-src-minisql-common-limits-ml-984650845"></a>
### MAX_SQL_NESTING

```ml
const MAX_SQL_NESTING = 64
```

Defines the max sql nesting constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L20)

<a id="constant-constant-minisql-common-limits-max-time-precision-const-max-time-precision-6-src-minisql-common-limits-ml-1735520235"></a>
### MAX_TIME_PRECISION

```ml
const MAX_TIME_PRECISION = 6
```

Defines the max time precision constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L24)

<a id="constant-constant-minisql-common-limits-min-page-size-const-min-page-size-4096-src-minisql-common-limits-ml-1179069074"></a>
### MIN_PAGE_SIZE

```ml
const MIN_PAGE_SIZE = 4096
```

Defines the min page size constant used by the minisql common limits module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L14)

<a id="function-function-minisql-common-limits-targetmilestone-function-targetmilestone-src-minisql-common-limits-ml-279490992"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql common limits module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L41)
