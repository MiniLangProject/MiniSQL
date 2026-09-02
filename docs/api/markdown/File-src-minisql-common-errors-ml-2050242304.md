# `src/minisql/common/errors.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.common.errors`](Package-minisql-common-errors-294404942.md)

Reachable from entry: **no**

## Declarations

<a id="function-function-minisql-common-errors-componentname-function-componentname-src-minisql-common-errors-ml-692375092"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L99)

- [minisql.common.errors.ErrorCode](Type-minisql-common-errors-errorcode-924546683.md) — enum
<a id="function-function-minisql-common-errors-isimplemented-function-isimplemented-src-minisql-common-errors-ml-432368060"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L111)

<a id="function-function-minisql-common-errors-notimplemented-function-notimplemented-component-operation-src-minisql-common-errors-ml-2041041892"></a>
### notImplemented

```ml
function notImplemented(component, operation)
```

Performs the not implemented operation for this module. Inputs: `component`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L93)

<a id="function-function-minisql-common-errors-targetmilestone-function-targetmilestone-src-minisql-common-errors-ml-1337275382"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L105)
