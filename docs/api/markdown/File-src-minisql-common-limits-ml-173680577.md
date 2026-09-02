# `src/minisql/common/limits.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.common.limits`](Package-minisql-common-limits-2094953501.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-limits-componentname-function-componentname-src-minisql-common-limits-ml-2138771630"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L26)

<a id="constant-constant-minisql-common-limits-default-page-size-const-default-page-size-4096-src-minisql-common-limits-ml-1174271558"></a>
### DEFAULT_PAGE_SIZE

```ml
const DEFAULT_PAGE_SIZE = 4096
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L10)

<a id="constant-constant-minisql-common-limits-default-port-const-default-port-7432-src-minisql-common-limits-ml-414369745"></a>
### DEFAULT_PORT

```ml
const DEFAULT_PORT = 7432
```

Shared format and protocol limits. Keeping these bounds in one module makes validation consistent between parsers, storage codecs, and network paths.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L9)

<a id="function-function-minisql-common-limits-isimplemented-function-isimplemented-src-minisql-common-limits-ml-140839550"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L38)

<a id="function-function-minisql-common-limits-issupportedpagesize-function-issupportedpagesize-pagesize-src-minisql-common-limits-ml-715466428"></a>
### isSupportedPageSize

```ml
function isSupportedPageSize(pageSize)
```

Evaluates whether the supplied input satisfies the supported page size predicate. Inputs: `pageSize`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L20)

<a id="constant-constant-minisql-common-limits-max-decimal-precision-const-max-decimal-precision-18-src-minisql-common-limits-ml-1448954828"></a>
### MAX_DECIMAL_PRECISION

```ml
const MAX_DECIMAL_PRECISION = 18
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L15)

<a id="constant-constant-minisql-common-limits-max-identifier-bytes-const-max-identifier-bytes-128-src-minisql-common-limits-ml-417635728"></a>
### MAX_IDENTIFIER_BYTES

```ml
const MAX_IDENTIFIER_BYTES = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L13)

<a id="constant-constant-minisql-common-limits-max-page-size-const-max-page-size-32768-src-minisql-common-limits-ml-2003500105"></a>
### MAX_PAGE_SIZE

```ml
const MAX_PAGE_SIZE = 32768
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L12)

<a id="constant-constant-minisql-common-limits-max-sql-nesting-const-max-sql-nesting-64-src-minisql-common-limits-ml-984650845"></a>
### MAX_SQL_NESTING

```ml
const MAX_SQL_NESTING = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L14)

<a id="constant-constant-minisql-common-limits-max-time-precision-const-max-time-precision-6-src-minisql-common-limits-ml-1735520235"></a>
### MAX_TIME_PRECISION

```ml
const MAX_TIME_PRECISION = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L16)

<a id="constant-constant-minisql-common-limits-min-page-size-const-min-page-size-4096-src-minisql-common-limits-ml-1179069074"></a>
### MIN_PAGE_SIZE

```ml
const MIN_PAGE_SIZE = 4096
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L11)

<a id="function-function-minisql-common-limits-targetmilestone-function-targetmilestone-src-minisql-common-limits-ml-279490992"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/limits.ml#L32)
