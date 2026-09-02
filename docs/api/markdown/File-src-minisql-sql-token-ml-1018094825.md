# `src/minisql/sql/token.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.sql.token`](Package-minisql-sql-token-1282165675.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-sql-token-componentname-function-componentname-src-minisql-sql-token-ml-1887347984"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L133)

<a id="function-function-minisql-sql-token-create-function-create-kind-text-value-offset-line-column-quoted-src-minisql-sql-token-ml-1033617707"></a>
### create

```ml
function create(kind, text, value, offset, line, column, quoted)
```

Creates create using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `line` | `dynamic` | — |  |
| `column` | `dynamic` | — |  |
| `quoted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L86)

<a id="function-function-minisql-sql-token-describe-function-describe-value-src-minisql-sql-token-ml-1702861991"></a>
### describe

```ml
function describe(value)
```

Implements describe for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L119)

<a id="function-function-minisql-sql-token-eof-function-eof-offset-line-column-src-minisql-sql-token-ml-430385607"></a>
### eof

```ml
function eof(offset, line, column)
```

Implements eof for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offset` | `dynamic` | — |  |
| `line` | `dynamic` | — |  |
| `column` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L97)

<a id="function-function-minisql-sql-token-isimplemented-function-isimplemented-src-minisql-sql-token-ml-1204395352"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L147)

<a id="function-function-minisql-sql-token-iskeyword-function-iskeyword-value-keyword-src-minisql-sql-token-ml-1692711242"></a>
### isKeyword

```ml
function isKeyword(value, keyword)
```

Returns whether the supplied value satisfies the keyword condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `keyword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L111)

<a id="function-function-minisql-sql-token-iskind-function-iskind-value-kind-src-minisql-sql-token-ml-561094317"></a>
### isKind

```ml
function isKind(value, kind)
```

Returns whether the supplied value satisfies the kind condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L104)

<a id="function-function-minisql-sql-token-targetmilestone-function-targetmilestone-src-minisql-sql-token-ml-1626390678"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/token.ml#L140)

- [minisql.sql.token.Token](Type-minisql-sql-token-token-1789885460.md) — struct
- [minisql.sql.token.TokenKind](Type-minisql-sql-token-tokenkind-351735398.md) — enum
