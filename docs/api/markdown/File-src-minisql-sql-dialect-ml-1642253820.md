# `src/minisql/sql/dialect.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.sql.dialect`](Package-minisql-sql-dialect-1677227552.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-sql-dialect-asciilower-function-asciilower-text-src-minisql-sql-dialect-ml-183930125"></a>
### asciiLower

```ml
function asciiLower(text)
```

Implements ascii lower for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L30)

<a id="function-function-minisql-sql-dialect-asciiupper-function-asciiupper-text-src-minisql-sql-dialect-ml-813625545"></a>
### asciiUpper

```ml
function asciiUpper(text)
```

Implements ascii upper for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L15)

<a id="function-function-minisql-sql-dialect-canonicalidentifier-function-canonicalidentifier-text-quoted-src-minisql-sql-dialect-ml-428411643"></a>
### canonicalIdentifier

```ml
function canonicalIdentifier(text, quoted)
```

Implements canonical identifier for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `quoted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L106)

<a id="function-function-minisql-sql-dialect-componentname-function-componentname-src-minisql-sql-dialect-ml-1938107350"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L115)

<a id="function-function-minisql-sql-dialect-isimplemented-function-isimplemented-src-minisql-sql-dialect-ml-909798574"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L129)

<a id="function-function-minisql-sql-dialect-iskeyword-function-iskeyword-text-src-minisql-sql-dialect-ml-2008256239"></a>
### isKeyword

```ml
function isKeyword(text)
```

Returns whether the supplied value satisfies the keyword condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L64)

<a id="function-function-minisql-sql-dialect-isnonreservedidentifierkeyword-function-isnonreservedidentifierkeyword-text-src-minisql-sql-dialect-ml-567191917"></a>
### isNonReservedIdentifierKeyword

```ml
function isNonReservedIdentifierKeyword(text)
```

Returns whether the supplied value satisfies the non reserved identifier keyword condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L93)

<a id="function-function-minisql-sql-dialect-keywordlist-function-keywordlist-src-minisql-sql-dialect-ml-1573177160"></a>
### keywordList

```ml
function keywordList()
```

Implements keyword list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L44)

<a id="function-function-minisql-sql-dialect-nonreservedidentifierkeywordlist-function-nonreservedidentifierkeywordlist-src-minisql-sql-dialect-ml-1098673218"></a>
### nonReservedIdentifierKeywordList

```ml
function nonReservedIdentifierKeywordList()
```

MiniSQL distinguishes fully reserved grammar words from contextual words. SQL type names and aggregate function names are keywords while parsing their dedicated constructs, but remain legal unquoted identifiers where an object, column, alias, savepoint or principal name is expected. Implements non reserved identifier keyword list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L80)

<a id="function-function-minisql-sql-dialect-targetmilestone-function-targetmilestone-src-minisql-sql-dialect-ml-23612452"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L122)
