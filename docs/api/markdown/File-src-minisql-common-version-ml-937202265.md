# `src/minisql/common/version.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.common.version`](Package-minisql-common-version-1506281327.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-version-componentname-function-componentname-src-minisql-common-version-ml-2055549426"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L43)

<a id="constant-constant-minisql-common-version-database-format-version-const-database-format-version-1-src-minisql-common-version-ml-560453636"></a>
### DATABASE_FORMAT_VERSION

```ml
const DATABASE_FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L15)

<a id="function-function-minisql-common-version-isimplemented-function-isimplemented-src-minisql-common-version-ml-1254648010"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L55)

<a id="constant-constant-minisql-common-version-milestone-const-milestone-m50-src-minisql-common-version-ml-930485285"></a>
### MILESTONE

```ml
const MILESTONE = "M50"
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L12)

<a id="function-function-minisql-common-version-milestone-function-milestone-src-minisql-common-version-ml-1024844054"></a>
### milestone

```ml
function milestone()
```

Performs the milestone operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L31)

<a id="constant-constant-minisql-common-version-product-name-const-product-name-minisql-src-minisql-common-version-ml-1126804216"></a>
### PRODUCT_NAME

```ml
const PRODUCT_NAME = "MiniSQL"
```

Central product, wire-protocol, and database-format identity. Persisted and negotiated versions change independently of the human-readable product version so compatibility checks remain explicit.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L10)

<a id="constant-constant-minisql-common-version-product-version-const-product-version-1-1-0-src-minisql-common-version-ml-838981743"></a>
### PRODUCT_VERSION

```ml
const PRODUCT_VERSION = "1.1.0"
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L11)

<a id="function-function-minisql-common-version-productname-function-productname-src-minisql-common-version-ml-1991432874"></a>
### productName

```ml
function productName()
```

Performs the product name operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L19)

<a id="function-function-minisql-common-version-productversion-function-productversion-src-minisql-common-version-ml-294304962"></a>
### productVersion

```ml
function productVersion()
```

Performs the product version operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L25)

<a id="constant-constant-minisql-common-version-revision-const-revision-m48-m50r3-src-minisql-common-version-ml-398308410"></a>
### REVISION

```ml
const REVISION = "M48-M50R3"
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L13)

<a id="function-function-minisql-common-version-targetmilestone-function-targetmilestone-src-minisql-common-version-ml-414952808"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L49)

<a id="function-function-minisql-common-version-versionline-function-versionline-component-src-minisql-common-version-ml-881349033"></a>
### versionLine

```ml
function versionLine(component)
```

Performs the version line operation for this module. Inputs: `component`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `component` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L37)

<a id="constant-constant-minisql-common-version-wire-protocol-version-const-wire-protocol-version-1-src-minisql-common-version-ml-1744636000"></a>
### WIRE_PROTOCOL_VERSION

```ml
const WIRE_PROTOCOL_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/version.ml#L14)
