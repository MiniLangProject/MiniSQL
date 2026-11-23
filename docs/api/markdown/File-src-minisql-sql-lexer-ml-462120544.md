# `src/minisql/sql/lexer.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql lexer facilities for this project.

Package: [`minisql.sql.lexer`](Package-minisql-sql-lexer-27747776.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/dialect.ml` as `dialect` → [src/minisql/sql/dialect.ml](File-src-minisql-sql-dialect-ml-1642253820.md)
- `minisql/sql/token.ml` as `token` → [src/minisql/sql/token.ml](File-src-minisql-sql-token-ml-1018094825.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-sql-lexer-advance-function-advance-state-src-minisql-sql-lexer-ml-1156309179"></a>
### advance

```ml
function advance(state)
```

Advances advance using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L99)

<a id="function-function-minisql-sql-lexer-appendtoken-function-appendtoken-state-kind-text-value-offset-line-column-quoted-src-minisql-sql-lexer-ml-268081274"></a>
### appendToken

```ml
function appendToken(state, kind, text, value, offset, line, column, quoted)
```

Appends token using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `kind` | `dynamic` | — | kind value consumed by this operation. |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `line` | `dynamic` | — | line value consumed by this operation. |
| `column` | `dynamic` | — | column value consumed by this operation. |
| `quoted` | `dynamic` | — | quoted value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L133)

<a id="function-function-minisql-sql-lexer-componentname-function-componentname-src-minisql-sql-lexer-ml-188876834"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql lexer module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L377)

<a id="function-function-minisql-sql-lexer-current-function-current-state-src-minisql-sql-lexer-ml-1392062601"></a>
### current

```ml
function current(state)
```

Implements current for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L79)

<a id="function-function-minisql-sql-lexer-fail-function-fail-state-message-src-minisql-sql-lexer-ml-237243994"></a>
### fail

```ml
function fail(state, message)
```

Performs the fail operation for the minisql sql lexer module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L39)

<a id="constant-constant-minisql-sql-lexer-invalid-argument-const-invalid-argument-9001-src-minisql-sql-lexer-ml-1395162233"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql sql lexer module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L14)

<a id="function-function-minisql-sql-lexer-isdigit-function-isdigit-value-src-minisql-sql-lexer-ml-427885961"></a>
### isDigit

```ml
function isDigit(value)
```

Returns whether the supplied value satisfies the digit condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L55)

<a id="function-function-minisql-sql-lexer-isidentifierpart-function-isidentifierpart-value-src-minisql-sql-lexer-ml-1582357871"></a>
### isIdentifierPart

```ml
function isIdentifierPart(value)
```

Returns whether the supplied value satisfies the identifier part condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L71)

<a id="function-function-minisql-sql-lexer-isidentifierstart-function-isidentifierstart-value-src-minisql-sql-lexer-ml-1596903397"></a>
### isIdentifierStart

```ml
function isIdentifierStart(value)
```

Returns whether the supplied value satisfies the identifier start condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L63)

<a id="function-function-minisql-sql-lexer-isimplemented-function-isimplemented-src-minisql-sql-lexer-ml-1122888698"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql lexer module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L391)

<a id="function-function-minisql-sql-lexer-iswhitespace-function-iswhitespace-value-src-minisql-sql-lexer-ml-545372067"></a>
### isWhitespace

```ml
function isWhitespace(value)
```

Returns whether the supplied value satisfies the whitespace condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L47)

- [minisql.sql.lexer.LexerState](Type-minisql-sql-lexer-lexerstate-700274641.md) — struct
<a id="function-function-minisql-sql-lexer-peek-function-peek-state-distance-src-minisql-sql-lexer-ml-1761817316"></a>
### peek

```ml
function peek(state, distance)
```

Implements peek for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `distance` | `dynamic` | — | distance value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L89)

<a id="function-function-minisql-sql-lexer-rawtext-function-rawtext-state-startoffset-endoffset-src-minisql-sql-lexer-ml-219029626"></a>
### rawText

```ml
function rawText(state, startOffset, endOffset)
```

Implements raw text for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `startOffset` | `dynamic` | — | startOffset value consumed by this operation. |
| `endOffset` | `dynamic` | — | endOffset value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L118)

<a id="function-function-minisql-sql-lexer-readidentifier-function-readidentifier-state-src-minisql-sql-lexer-ml-66473823"></a>
### readIdentifier

```ml
function readIdentifier(state)
```

Reads identifier using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L181)

<a id="function-function-minisql-sql-lexer-readnumber-function-readnumber-state-src-minisql-sql-lexer-ml-838656239"></a>
### readNumber

```ml
function readNumber(state)
```

Reads number using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L280)

<a id="function-function-minisql-sql-lexer-readquotedidentifier-function-readquotedidentifier-state-src-minisql-sql-lexer-ml-1335996291"></a>
### readQuotedIdentifier

```ml
function readQuotedIdentifier(state)
```

Reads quoted identifier using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L203)

<a id="function-function-minisql-sql-lexer-readstring-function-readstring-state-src-minisql-sql-lexer-ml-1223701547"></a>
### readString

```ml
function readString(state)
```

Reads string using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L241)

<a id="function-function-minisql-sql-lexer-skipignored-function-skipignored-state-src-minisql-sql-lexer-ml-1910730313"></a>
### skipIgnored

```ml
function skipIgnored(state)
```

Implements skip ignored for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L142)

<a id="constant-constant-minisql-sql-lexer-sql-syntax-const-sql-syntax-9019-src-minisql-sql-lexer-ml-84339536"></a>
### SQL_SYNTAX

```ml
const SQL_SYNTAX = 9019
```

Defines the sql syntax constant used by the minisql sql lexer module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L16)

<a id="function-function-minisql-sql-lexer-symboltoken-function-symboltoken-state-src-minisql-sql-lexer-ml-1120007953"></a>
### symbolToken

```ml
function symbolToken(state)
```

Implements symbol token for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L315)

<a id="function-function-minisql-sql-lexer-targetmilestone-function-targetmilestone-src-minisql-sql-lexer-ml-1713377632"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql lexer module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L384)

<a id="function-function-minisql-sql-lexer-tokenizesql-function-tokenizesql-source-src-minisql-sql-lexer-ml-2095317789"></a>
### tokenizeSql

```ml
function tokenizeSql(source)
```

Tokenizes SQL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/lexer.ml#L349)
