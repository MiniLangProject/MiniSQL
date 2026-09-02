# `src/minisql/sql/parser.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.sql.parser`](Package-minisql-sql-parser-658583049.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/dialect.ml` as `dialect` → [src/minisql/sql/dialect.ml](File-src-minisql-sql-dialect-ml-1642253820.md)
- `minisql/sql/lexer.ml` as `lexer` → [src/minisql/sql/lexer.ml](File-src-minisql-sql-lexer-ml-462120544.md)
- `minisql/sql/token.ml` as `token` → [src/minisql/sql/token.ml](File-src-minisql-sql-token-ml-1018094825.md)

## Declarations

<a id="function-function-minisql-sql-parser-advance-function-advance-state-src-minisql-sql-parser-ml-1016213217"></a>
### advance

```ml
function advance(state)
```

Advances advance using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L61)

<a id="function-function-minisql-sql-parser-atend-function-atend-state-src-minisql-sql-parser-ml-1141605641"></a>
### atEnd

```ml
function atEnd(state)
```

Implements at end for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L54)

<a id="function-function-minisql-sql-parser-checkkeyword-function-checkkeyword-state-keyword-src-minisql-sql-parser-ml-1123058328"></a>
### checkKeyword

```ml
function checkKeyword(state, keyword)
```

Checks keyword using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `keyword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L77)

<a id="function-function-minisql-sql-parser-checkkind-function-checkkind-state-kind-src-minisql-sql-parser-ml-426117883"></a>
### checkKind

```ml
function checkKind(state, kind)
```

Checks kind using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L70)

<a id="function-function-minisql-sql-parser-componentname-function-componentname-src-minisql-sql-parser-ml-1016146040"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1667)

<a id="function-function-minisql-sql-parser-current-function-current-state-src-minisql-sql-parser-ml-1810443483"></a>
### current

```ml
function current(state)
```

Implements current for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L39)

<a id="function-function-minisql-sql-parser-expectkeyword-function-expectkeyword-state-keyword-src-minisql-sql-parser-ml-1169332012"></a>
### expectKeyword

```ml
function expectKeyword(state, keyword)
```

Implements expect keyword for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `keyword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L155)

<a id="function-function-minisql-sql-parser-expectkind-function-expectkind-state-kind-description-src-minisql-sql-parser-ml-798420505"></a>
### expectKind

```ml
function expectKind(state, kind, description)
```

Implements expect kind for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L147)

<a id="function-function-minisql-sql-parser-fail-function-fail-state-message-src-minisql-sql-parser-ml-510885780"></a>
### fail

```ml
function fail(state, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L31)

<a id="constant-constant-minisql-sql-parser-invalid-argument-const-invalid-argument-9001-src-minisql-sql-parser-ml-456493941"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L12)

<a id="function-function-minisql-sql-parser-isfunctionnametoken-function-isfunctionnametoken-value-src-minisql-sql-parser-ml-1403514569"></a>
### isFunctionNameToken

```ml
function isFunctionNameToken(value)
```

Returns whether the supplied value satisfies the function name token condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L111)

<a id="function-function-minisql-sql-parser-isidentifiertoken-function-isidentifiertoken-value-src-minisql-sql-parser-ml-784807657"></a>
### isIdentifierToken

```ml
function isIdentifierToken(value)
```

Returns whether the supplied value satisfies the identifier token condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L102)

<a id="function-function-minisql-sql-parser-isimplemented-function-isimplemented-src-minisql-sql-parser-ml-34734376"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1681)

<a id="function-function-minisql-sql-parser-istriggerrowqualifiertoken-function-istriggerrowqualifiertoken-value-src-minisql-sql-parser-ml-482427069"></a>
### isTriggerRowQualifierToken

```ml
function isTriggerRowQualifierToken(value)
```

OLD and NEW are reserved pseudo-row qualifiers, not general identifiers. The parser accepts them only in the qualified form OLD.column / NEW.column. Trigger execution replaces those qualified column expressions with typed row literals before the body is bound and executed. Returns whether the supplied value satisfies the trigger row qualifier token condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L122)

<a id="function-function-minisql-sql-parser-matchkeyword-function-matchkeyword-state-keyword-src-minisql-sql-parser-ml-170314060"></a>
### matchKeyword

```ml
function matchKeyword(state, keyword)
```

Implements match keyword for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `keyword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L138)

<a id="function-function-minisql-sql-parser-matchkind-function-matchkind-state-kind-src-minisql-sql-parser-ml-1590339029"></a>
### matchKind

```ml
function matchKind(state, kind)
```

Implements match kind for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L129)

<a id="function-function-minisql-sql-parser-nextiskeyword-function-nextiskeyword-state-keyword-src-minisql-sql-parser-ml-871911436"></a>
### nextIsKeyword

```ml
function nextIsKeyword(state, keyword)
```

Implements next is keyword for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `keyword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L93)

<a id="function-function-minisql-sql-parser-nextiskind-function-nextiskind-state-kind-src-minisql-sql-parser-ml-638857839"></a>
### nextIsKind

```ml
function nextIsKind(state, kind)
```

Implements next is kind for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L84)

<a id="function-function-minisql-sql-parser-operatorprecedence-function-operatorprecedence-value-src-minisql-sql-parser-ml-1358644077"></a>
### operatorPrecedence

```ml
function operatorPrecedence(value)
```

Maps binary operators to increasing binding strength; zero means non-operator. The table makes OR weakest and multiplicative operators strongest.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1384)

<a id="function-function-minisql-sql-parser-operatortext-function-operatortext-value-src-minisql-sql-parser-ml-181559717"></a>
### operatorText

```ml
function operatorText(value)
```

Implements operator text for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1397)

<a id="function-function-minisql-sql-parser-parsealter-function-parsealter-state-src-minisql-sql-parser-ml-184766817"></a>
### parseAlter

```ml
function parseAlter(state)
```

Parses alter using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L467)

<a id="function-function-minisql-sql-parser-parsealtertable-function-parsealtertable-state-src-minisql-sql-parser-ml-2032474239"></a>
### parseAlterTable

```ml
function parseAlterTable(state)
```

Parses alter table using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L417)

<a id="function-function-minisql-sql-parser-parseassignments-function-parseassignments-state-src-minisql-sql-parser-ml-915825669"></a>
### parseAssignments

```ml
function parseAssignments(state)
```

Parses assignments using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L820)

<a id="function-function-minisql-sql-parser-parsebegin-function-parsebegin-state-src-minisql-sql-parser-ml-165773645"></a>
### parseBegin

```ml
function parseBegin(state)
```

Parses begin using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1186)

<a id="function-function-minisql-sql-parser-parsecall-function-parsecall-state-src-minisql-sql-parser-ml-308565695"></a>
### parseCall

```ml
function parseCall(state)
```

Parses CALL with positional constant argument expressions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1300)

<a id="function-function-minisql-sql-parser-parsecaseexpression-function-parsecaseexpression-state-src-minisql-sql-parser-ml-1164052659"></a>
### parseCaseExpression

```ml
function parseCaseExpression(state)
```

Parses case expression using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1406)

<a id="function-function-minisql-sql-parser-parsecastexpression-function-parsecastexpression-state-src-minisql-sql-parser-ml-798906017"></a>
### parseCastExpression

```ml
function parseCastExpression(state)
```

Parses cast expression using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1428)

<a id="function-function-minisql-sql-parser-parsecolumndefinition-function-parsecolumndefinition-state-src-minisql-sql-parser-ml-655854205"></a>
### parseColumnDefinition

```ml
function parseColumnDefinition(state)
```

Parses column definition using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L274)

<a id="function-function-minisql-sql-parser-parsecreate-function-parsecreate-state-src-minisql-sql-parser-ml-345218999"></a>
### parseCreate

```ml
function parseCreate(state)
```

Parses create using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L744)

<a id="function-function-minisql-sql-parser-parsecreateindex-function-parsecreateindex-state-unique-src-minisql-sql-parser-ml-1169847716"></a>
### parseCreateIndex

```ml
function parseCreateIndex(state, unique)
```

Parses create index using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `unique` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L627)

<a id="function-function-minisql-sql-parser-parsecreateprincipal-function-parsecreateprincipal-state-principalkind-src-minisql-sql-parser-ml-223417505"></a>
### parseCreatePrincipal

```ml
function parseCreatePrincipal(state, principalKind)
```

Parses create principal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `principalKind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L403)

<a id="function-function-minisql-sql-parser-parsecreateprocedure-function-parsecreateprocedure-state-replace-src-minisql-sql-parser-ml-1644414057"></a>
### parseCreateProcedure

```ml
function parseCreateProcedure(state, replace)
```

Parses a stored procedure with typed positional inputs and one DML body statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `replace` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L658)

<a id="function-function-minisql-sql-parser-parsecreateschema-function-parsecreateschema-state-src-minisql-sql-parser-ml-1562481933"></a>
### parseCreateSchema

```ml
function parseCreateSchema(state)
```

Parses CREATE SCHEMA with optional idempotent creation semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L607)

<a id="function-function-minisql-sql-parser-parsecreatesequence-function-parsecreatesequence-state-src-minisql-sql-parser-ml-782151369"></a>
### parseCreateSequence

```ml
function parseCreateSequence(state)
```

Parses create sequence using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L680)

<a id="function-function-minisql-sql-parser-parsecreatetable-function-parsecreatetable-state-src-minisql-sql-parser-ml-767416413"></a>
### parseCreateTable

```ml
function parseCreateTable(state)
```

Parses create table using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L584)

<a id="function-function-minisql-sql-parser-parsecreatetrigger-function-parsecreatetrigger-state-src-minisql-sql-parser-ml-1250658305"></a>
### parseCreateTrigger

```ml
function parseCreateTrigger(state)
```

Parses create trigger using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L718)

<a id="function-function-minisql-sql-parser-parsecreateview-function-parsecreateview-state-replace-src-minisql-sql-parser-ml-1509415117"></a>
### parseCreateView

```ml
function parseCreateView(state, replace)
```

Parses create view using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `replace` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L644)

<a id="function-function-minisql-sql-parser-parsedeallocate-function-parsedeallocate-state-src-minisql-sql-parser-ml-1976083431"></a>
### parseDeallocate

```ml
function parseDeallocate(state)
```

Parses deallocate using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1317)

<a id="function-function-minisql-sql-parser-parsedelete-function-parsedelete-state-src-minisql-sql-parser-ml-1551249053"></a>
### parseDelete

```ml
function parseDelete(state)
```

Parses delete using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L895)

<a id="function-function-minisql-sql-parser-parsedescribe-function-parsedescribe-state-src-minisql-sql-parser-ml-1337118013"></a>
### parseDescribe

```ml
function parseDescribe(state)
```

Parses describe using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L937)

<a id="function-function-minisql-sql-parser-parsedrop-function-parsedrop-state-src-minisql-sql-parser-ml-900100933"></a>
### parseDrop

```ml
function parseDrop(state)
```

Parses drop using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L767)

<a id="function-function-minisql-sql-parser-parseexecuteprepared-function-parseexecuteprepared-state-src-minisql-sql-parser-ml-1014197913"></a>
### parseExecutePrepared

```ml
function parseExecutePrepared(state)
```

Parses execute prepared using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1287)

<a id="function-function-minisql-sql-parser-parseexpression-function-parseexpression-state-minimumprecedence-src-minisql-sql-parser-ml-1891708655"></a>
### parseExpression

```ml
function parseExpression(state, minimumPrecedence)
```

Parses a binary expression with precedence climbing and left associativity. Unary/predicate parsing supplies the left operand; recursive calls consume only operators stronger than `minimumPrecedence`. Advances `state` or returns syntax errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `minimumPrecedence` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1612)

<a id="function-function-minisql-sql-parser-parseexpressiontext-function-parseexpressiontext-source-src-minisql-sql-parser-ml-1621736567"></a>
### parseExpressionText

```ml
function parseExpressionText(source)
```

Parses expression text using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1654)

<a id="function-function-minisql-sql-parser-parsegrant-function-parsegrant-state-src-minisql-sql-parser-ml-869061341"></a>
### parseGrant

```ml
function parseGrant(state)
```

Parses grant using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L516)

<a id="function-function-minisql-sql-parser-parseidentifier-function-parseidentifier-state-description-src-minisql-sql-parser-ml-1519662343"></a>
### parseIdentifier

```ml
function parseIdentifier(state, description)
```

Parses identifier using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L163)

<a id="function-function-minisql-sql-parser-parseidentifierlist-function-parseidentifierlist-state-src-minisql-sql-parser-ml-14518141"></a>
### parseIdentifierList

```ml
function parseIdentifierList(state)
```

Parses identifier list using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L210)

<a id="function-function-minisql-sql-parser-parseidentifiername-function-parseidentifiername-state-description-src-minisql-sql-parser-ml-838817309"></a>
### parseIdentifierName

```ml
function parseIdentifierName(state, description)
```

Parses identifier name using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L177)

<a id="function-function-minisql-sql-parser-parseindexkeylist-function-parseindexkeylist-state-src-minisql-sql-parser-ml-10134397"></a>
### parseIndexKeyList

```ml
function parseIndexKeyList(state)
```

Parses the parenthesized expression list used by CREATE INDEX keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L614)

<a id="function-function-minisql-sql-parser-parseinsert-function-parseinsert-state-src-minisql-sql-parser-ml-1062368913"></a>
### parseInsert

```ml
function parseInsert(state)
```

Parses insert using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L835)

<a id="function-function-minisql-sql-parser-parseintegervalue-function-parseintegervalue-state-description-src-minisql-sql-parser-ml-1304910103"></a>
### parseIntegerValue

```ml
function parseIntegerValue(state, description)
```

Parses integer value using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L224)

<a id="function-function-minisql-sql-parser-parsejoinclause-function-parsejoinclause-state-src-minisql-sql-parser-ml-2003264545"></a>
### parseJoinClause

```ml
function parseJoinClause(state)
```

Parses join clause using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1014)

<a id="function-function-minisql-sql-parser-parsemerge-function-parsemerge-state-src-minisql-sql-parser-ml-460496321"></a>
### parseMerge

```ml
function parseMerge(state)
```

Parses the core SQL MERGE form with table source, matched update/delete, and insert.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1212)

<a id="function-function-minisql-sql-parser-parseobjectname-function-parseobjectname-state-description-src-minisql-sql-parser-ml-1805546373"></a>
### parseObjectName

```ml
function parseObjectName(state, description)
```

Parses an optionally schema-qualified SQL object name into its canonical dotted form.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L182)

<a id="function-function-minisql-sql-parser-parseorderitem-function-parseorderitem-state-src-minisql-sql-parser-ml-1292881405"></a>
### parseOrderItem

```ml
function parseOrderItem(state)
```

Parses order item using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L958)

<a id="function-function-minisql-sql-parser-parsepasswordliteral-function-parsepasswordliteral-state-src-minisql-sql-parser-ml-459925117"></a>
### parsePasswordLiteral

```ml
function parsePasswordLiteral(state)
```

Parses password literal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L202)

<a id="function-function-minisql-sql-parser-parsepredicatetail-function-parsepredicatetail-state-expression-src-minisql-sql-parser-ml-678144915"></a>
### parsePredicateTail

```ml
function parsePredicateTail(state, expression)
```

Parses predicate tail using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1541)

<a id="function-function-minisql-sql-parser-parseprepare-function-parseprepare-state-src-minisql-sql-parser-ml-799376733"></a>
### parsePrepare

```ml
function parsePrepare(state)
```

Parses prepare using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1270)

<a id="function-function-minisql-sql-parser-parseprimary-function-parseprimary-state-src-minisql-sql-parser-ml-1720555453"></a>
### parsePrimary

```ml
function parsePrimary(state)
```

Parses primary using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1441)

<a id="function-function-minisql-sql-parser-parseprincipalname-function-parseprincipalname-state-description-src-minisql-sql-parser-ml-1131152435"></a>
### parsePrincipalName

```ml
function parsePrincipalName(state, description)
```

Parses principal name using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L194)

<a id="function-function-minisql-sql-parser-parseprivilegelist-function-parseprivilegelist-state-src-minisql-sql-parser-ml-185389693"></a>
### parsePrivilegeList

```ml
function parsePrivilegeList(state)
```

Parses privilege list using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L501)

<a id="function-function-minisql-sql-parser-parsereferentialaction-function-parsereferentialaction-state-src-minisql-sql-parser-ml-1519990733"></a>
### parseReferentialAction

```ml
function parseReferentialAction(state)
```

Parses referential action using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L263)

<a id="function-function-minisql-sql-parser-parsereturning-function-parsereturning-state-src-minisql-sql-parser-ml-1749622157"></a>
### parseReturning

```ml
function parseReturning(state)
```

Parses returning using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L807)

<a id="function-function-minisql-sql-parser-parserevoke-function-parserevoke-state-src-minisql-sql-parser-ml-1933001427"></a>
### parseRevoke

```ml
function parseRevoke(state)
```

Parses revoke using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L557)

<a id="function-function-minisql-sql-parser-parserevokebehavior-function-parserevokebehavior-state-src-minisql-sql-parser-ml-15461451"></a>
### parseRevokeBehavior

```ml
function parseRevokeBehavior(state)
```

Parses revoke behavior using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L547)

- [minisql.sql.parser.ParserState](Type-minisql-sql-parser-parserstate-824999695.md) — struct
<a id="function-function-minisql-sql-parser-parseselect-function-parseselect-state-src-minisql-sql-parser-ml-131685571"></a>
### parseSelect

```ml
function parseSelect(state)
```

Parses select using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1108)

<a id="function-function-minisql-sql-parser-parseselectcore-function-parseselectcore-state-src-minisql-sql-parser-ml-1726657285"></a>
### parseSelectCore

```ml
function parseSelectCore(state)
```

Parses select core using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1058)

<a id="function-function-minisql-sql-parser-parseselectitem-function-parseselectitem-state-src-minisql-sql-parser-ml-1233371773"></a>
### parseSelectItem

```ml
function parseSelectItem(state)
```

Parses select item using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L944)

<a id="function-function-minisql-sql-parser-parseshow-function-parseshow-state-src-minisql-sql-parser-ml-2141513113"></a>
### parseShow

```ml
function parseShow(state)
```

Parses show using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L923)

<a id="function-function-minisql-sql-parser-parsesql-function-parsesql-source-src-minisql-sql-parser-ml-1887707447"></a>
### parseSql

```ml
function parseSql(source)
```

Parses SQL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1647)

<a id="function-function-minisql-sql-parser-parsestatement-function-parsestatement-state-src-minisql-sql-parser-ml-697443873"></a>
### parseStatement

```ml
function parseStatement(state)
```

Parses statement using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1325)

<a id="function-function-minisql-sql-parser-parsetablealias-function-parsetablealias-state-src-minisql-sql-parser-ml-1426797263"></a>
### parseTableAlias

```ml
function parseTableAlias(state)
```

Parses table alias using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L978)

<a id="function-function-minisql-sql-parser-parsetableconstraint-function-parsetableconstraint-state-src-minisql-sql-parser-ml-1048842061"></a>
### parseTableConstraint

```ml
function parseTableConstraint(state)
```

Parses table constraint using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L355)

<a id="function-function-minisql-sql-parser-parsetablesource-function-parsetablesource-state-description-src-minisql-sql-parser-ml-1900678295"></a>
### parseTableSource

```ml
function parseTableSource(state, description)
```

Parses either a catalog/CTE name or a parenthesized SELECT source. Derived tables are represented as private CTEs so the existing named-query binder and executor retain one source abstraction; only the user alias is visible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `description` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L991)

<a id="function-function-minisql-sql-parser-parsetokens-function-parsetokens-tokens-src-minisql-sql-parser-ml-1550899676"></a>
### parseTokens

```ml
function parseTokens(tokens)
```

Parses a complete token stream into ordered statement AST nodes. Empty statements between semicolons are ignored; any other trailing token is a syntax error. The input must be a non-empty array ending in EndOfInput.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tokens` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1627)

<a id="function-function-minisql-sql-parser-parsetruncate-function-parsetruncate-state-src-minisql-sql-parser-ml-1311540655"></a>
### parseTruncate

```ml
function parseTruncate(state)
```

Parses truncate using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L906)

<a id="function-function-minisql-sql-parser-parsetypename-function-parsetypename-state-src-minisql-sql-parser-ml-752638909"></a>
### parseTypeName

```ml
function parseTypeName(state)
```

Parses type name using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L236)

<a id="function-function-minisql-sql-parser-parseunary-function-parseunary-state-src-minisql-sql-parser-ml-1255049437"></a>
### parseUnary

```ml
function parseUnary(state)
```

Parses unary using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1602)

<a id="function-function-minisql-sql-parser-parseupdate-function-parseupdate-state-src-minisql-sql-parser-ml-1003819037"></a>
### parseUpdate

```ml
function parseUpdate(state)
```

Parses update using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L883)

<a id="function-function-minisql-sql-parser-parsewithselect-function-parsewithselect-state-src-minisql-sql-parser-ml-1831116375"></a>
### parseWithSelect

```ml
function parseWithSelect(state)
```

Parses with select using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1156)

<a id="function-function-minisql-sql-parser-preparablestatement-function-preparablestatement-statement-src-minisql-sql-parser-ml-1538119331"></a>
### preparableStatement

```ml
function preparableStatement(statement)
```

Implements preparable statement for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1263)

<a id="function-function-minisql-sql-parser-previous-function-previous-state-src-minisql-sql-parser-ml-552479361"></a>
### previous

```ml
function previous(state)
```

Implements previous for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L46)

<a id="function-function-minisql-sql-parser-privilegename-function-privilegename-state-src-minisql-sql-parser-ml-1909899965"></a>
### privilegeName

```ml
function privilegeName(state)
```

Implements privilege name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L489)

<a id="constant-constant-minisql-sql-parser-sql-syntax-const-sql-syntax-9019-src-minisql-sql-parser-ml-1533729826"></a>
### SQL_SYNTAX

```ml
const SQL_SYNTAX = 9019
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L13)

<a id="function-function-minisql-sql-parser-startsjoin-function-startsjoin-state-src-minisql-sql-parser-ml-721577185"></a>
### startsJoin

```ml
function startsJoin(state)
```

Implements starts join for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1051)

<a id="function-function-minisql-sql-parser-startstableconstraint-function-startstableconstraint-state-src-minisql-sql-parser-ml-370278397"></a>
### startsTableConstraint

```ml
function startsTableConstraint(state)
```

Implements starts table constraint for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L396)

<a id="function-function-minisql-sql-parser-targetmilestone-function-targetmilestone-src-minisql-sql-parser-ml-790413730"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L1674)
