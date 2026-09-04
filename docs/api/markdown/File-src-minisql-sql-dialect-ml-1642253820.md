# `src/minisql/sql/dialect.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql dialect facilities for this project.

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
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L34)

<a id="function-function-minisql-sql-dialect-asciiupper-function-asciiupper-text-src-minisql-sql-dialect-ml-813625545"></a>
### asciiUpper

```ml
function asciiUpper(text)
```

Implements ascii upper for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L18)

<a id="function-function-minisql-sql-dialect-canonicalidentifier-function-canonicalidentifier-text-quoted-src-minisql-sql-dialect-ml-428411643"></a>
### canonicalIdentifier

```ml
function canonicalIdentifier(text, quoted)
```

Implements canonical identifier for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `quoted` | `dynamic` | — | quoted value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L114)

<a id="function-function-minisql-sql-dialect-componentname-function-componentname-src-minisql-sql-dialect-ml-1938107350"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql dialect module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L123)

<a id="function-function-minisql-sql-dialect-isimplemented-function-isimplemented-src-minisql-sql-dialect-ml-909798574"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql dialect module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L137)

<a id="function-function-minisql-sql-dialect-iskeyword-function-iskeyword-text-src-minisql-sql-dialect-ml-2008256239"></a>
### isKeyword

```ml
function isKeyword(text)
```

Returns whether the supplied value satisfies the keyword condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L69)

<a id="function-function-minisql-sql-dialect-isnonreservedidentifierkeyword-function-isnonreservedidentifierkeyword-text-src-minisql-sql-dialect-ml-567191917"></a>
### isNonReservedIdentifierKeyword

```ml
function isNonReservedIdentifierKeyword(text)
```

Returns whether the supplied value satisfies the non reserved identifier keyword condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L99)

<a id="function-function-minisql-sql-dialect-keywordlist-function-keywordlist-src-minisql-sql-dialect-ml-1573177160"></a>
### keywordList

```ml
function keywordList()
```

Implements keyword list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L48)

<a id="function-function-minisql-sql-dialect-nonreservedidentifierkeywordlist-function-nonreservedidentifierkeywordlist-src-minisql-sql-dialect-ml-1098673218"></a>
### nonReservedIdentifierKeywordList

```ml
function nonReservedIdentifierKeywordList()
```

MiniSQL distinguishes fully reserved grammar words from contextual words. SQL type names and aggregate function names are keywords while parsing their dedicated constructs, but remain legal unquoted identifiers where an object, column, alias, savepoint or principal name is expected. Implements non reserved identifier keyword list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L85)

<a id="function-function-minisql-sql-dialect-targetmilestone-function-targetmilestone-src-minisql-sql-dialect-ml-23612452"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql dialect module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/dialect.ml#L130)
