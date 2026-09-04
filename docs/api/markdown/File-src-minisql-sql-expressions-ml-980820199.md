# `src/minisql/sql/expressions.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql expressions facilities for this project.

Package: [`minisql.sql.expressions`](Package-minisql-sql-expressions-81527389.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `std/bytes.ml` as `bytes_api` → `../MiniLangCompilerML/std/bytes.ml` — external dependency
- `std/math.ml` as `math` → `../MiniLangCompilerML/std/math.ml` — external dependency

## Declarations

<a id="function-function-minisql-sql-expressions-absolutevalue-function-absolutevalue-value-src-minisql-sql-expressions-ml-276633659"></a>
### absoluteValue

```ml
function absoluteValue(value)
```

Returns the absolute value while preserving full-width signed integer semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1092)

<a id="function-function-minisql-sql-expressions-aggregate-function-aggregate-name-argument-separator-distinct-typeinfo-countstar-src-minisql-sql-expressions-ml-600154012"></a>
### aggregate

```ml
function aggregate(name, argument, separator, distinct, typeInfo, countStar)
```

Implements aggregate for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `argument` | `dynamic` | — | argument value consumed by this operation. |
| `separator` | `dynamic` | — | separator value consumed by this operation. |
| `distinct` | `dynamic` | — | distinct value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |
| `countStar` | `dynamic` | — | countStar value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L400)

<a id="function-function-minisql-sql-expressions-asciicase-function-asciicase-value-upper-src-minisql-sql-expressions-ml-1924295497"></a>
### asciiCase

```ml
function asciiCase(value, upper)
```

Applies ASCII case conversion while preserving every non-ASCII UTF-8 byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `upper` | `dynamic` | — | upper value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L970)

<a id="function-function-minisql-sql-expressions-betweenpredicate-function-betweenpredicate-operand-lower-upper-negated-src-minisql-sql-expressions-ml-1156326868"></a>
### betweenPredicate

```ml
function betweenPredicate(operand, lower, upper, negated)
```

Implements between predicate for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `lower` | `dynamic` | — | lower value consumed by this operation. |
| `upper` | `dynamic` | — | upper value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L485)

<a id="function-function-minisql-sql-expressions-binary-function-binary-operator-left-right-typeinfo-src-minisql-sql-expressions-ml-2011680027"></a>
### binary

```ml
function binary(operator, left, right, typeInfo)
```

Implements binary for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L372)

<a id="constant-constant-minisql-sql-expressions-binding-error-const-binding-error-9020-src-minisql-sql-expressions-ml-1399282056"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```

Defines the binding error constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L20)

<a id="constant-constant-minisql-sql-expressions-bound-aggregate-const-bound-aggregate-6-src-minisql-sql-expressions-ml-816275085"></a>
### BOUND_AGGREGATE

```ml
const BOUND_AGGREGATE = 6
```

Defines the bound aggregate constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L33)

<a id="constant-constant-minisql-sql-expressions-bound-between-const-bound-between-11-src-minisql-sql-expressions-ml-741015819"></a>
### BOUND_BETWEEN

```ml
const BOUND_BETWEEN = 11
```

Defines the bound between constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L43)

<a id="constant-constant-minisql-sql-expressions-bound-binary-const-bound-binary-4-src-minisql-sql-expressions-ml-2048939277"></a>
### BOUND_BINARY

```ml
const BOUND_BINARY = 4
```

Defines the bound binary constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L29)

<a id="constant-constant-minisql-sql-expressions-bound-case-const-bound-case-7-src-minisql-sql-expressions-ml-747070612"></a>
### BOUND_CASE

```ml
const BOUND_CASE = 7
```

Defines the bound case constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L35)

<a id="constant-constant-minisql-sql-expressions-bound-cast-const-bound-cast-8-src-minisql-sql-expressions-ml-1628901069"></a>
### BOUND_CAST

```ml
const BOUND_CAST = 8
```

Defines the bound cast constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L37)

<a id="constant-constant-minisql-sql-expressions-bound-column-const-bound-column-2-src-minisql-sql-expressions-ml-1830967293"></a>
### BOUND_COLUMN

```ml
const BOUND_COLUMN = 2
```

Defines the bound column constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L25)

<a id="constant-constant-minisql-sql-expressions-bound-in-const-bound-in-10-src-minisql-sql-expressions-ml-655882104"></a>
### BOUND_IN

```ml
const BOUND_IN = 10
```

Defines the bound in constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L41)

<a id="constant-constant-minisql-sql-expressions-bound-is-null-const-bound-is-null-5-src-minisql-sql-expressions-ml-1029242754"></a>
### BOUND_IS_NULL

```ml
const BOUND_IS_NULL = 5
```

Defines the bound is null constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L31)

<a id="constant-constant-minisql-sql-expressions-bound-literal-const-bound-literal-1-src-minisql-sql-expressions-ml-2045380418"></a>
### BOUND_LITERAL

```ml
const BOUND_LITERAL = 1
```

Defines the bound literal constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L23)

<a id="constant-constant-minisql-sql-expressions-bound-scalar-const-bound-scalar-9-src-minisql-sql-expressions-ml-265121338"></a>
### BOUND_SCALAR

```ml
const BOUND_SCALAR = 9
```

Defines the bound scalar constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L39)

<a id="constant-constant-minisql-sql-expressions-bound-subquery-const-bound-subquery-14-src-minisql-sql-expressions-ml-783498354"></a>
### BOUND_SUBQUERY

```ml
const BOUND_SUBQUERY = 14
```

Defines the bound subquery constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L49)

<a id="constant-constant-minisql-sql-expressions-bound-truth-test-const-bound-truth-test-12-src-minisql-sql-expressions-ml-1529943224"></a>
### BOUND_TRUTH_TEST

```ml
const BOUND_TRUTH_TEST = 12
```

Defines the bound truth test constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L45)

<a id="constant-constant-minisql-sql-expressions-bound-unary-const-bound-unary-3-src-minisql-sql-expressions-ml-394298068"></a>
### BOUND_UNARY

```ml
const BOUND_UNARY = 3
```

Defines the bound unary constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L27)

<a id="constant-constant-minisql-sql-expressions-bound-window-const-bound-window-13-src-minisql-sql-expressions-ml-477633389"></a>
### BOUND_WINDOW

```ml
const BOUND_WINDOW = 13
```

Defines the bound window constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L47)

- [minisql.sql.expressions.BoundAggregate](Type-minisql-sql-expressions-boundaggregate-321703190.md) — struct
- [minisql.sql.expressions.BoundBetween](Type-minisql-sql-expressions-boundbetween-1479166313.md) — struct
- [minisql.sql.expressions.BoundCase](Type-minisql-sql-expressions-boundcase-1441287547.md) — struct
- [minisql.sql.expressions.BoundCaseBranch](Type-minisql-sql-expressions-boundcasebranch-588620307.md) — struct
- [minisql.sql.expressions.BoundCast](Type-minisql-sql-expressions-boundcast-1156068024.md) — struct
- [minisql.sql.expressions.BoundExpression](Type-minisql-sql-expressions-boundexpression-1415457849.md) — struct
- [minisql.sql.expressions.BoundIn](Type-minisql-sql-expressions-boundin-546586140.md) — struct
- [minisql.sql.expressions.BoundScalar](Type-minisql-sql-expressions-boundscalar-643609595.md) — struct
- [minisql.sql.expressions.BoundSubquery](Type-minisql-sql-expressions-boundsubquery-1803602985.md) — struct
- [minisql.sql.expressions.BoundTruthTest](Type-minisql-sql-expressions-boundtruthtest-546122980.md) — struct
- [minisql.sql.expressions.BoundWindow](Type-minisql-sql-expressions-boundwindow-118201735.md) — struct
<a id="function-function-minisql-sql-expressions-bytesmatchat-function-bytesmatchat-source-needle-offset-src-minisql-sql-expressions-ml-486032557"></a>
### bytesMatchAt

```ml
function bytesMatchAt(source, needle, offset)
```

Returns whether `needle` occurs in `source` at the supplied byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `needle` | `dynamic` | — | needle value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1013)

<a id="function-function-minisql-sql-expressions-casebranch-function-casebranch-condition-result-src-minisql-sql-expressions-ml-789695702"></a>
### caseBranch

```ml
function caseBranch(condition, result)
```

Implements case branch for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — | condition value consumed by this operation. |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L412)

<a id="function-function-minisql-sql-expressions-caseexpression-function-caseexpression-branches-elseexpression-typeinfo-src-minisql-sql-expressions-ml-854416207"></a>
### caseExpression

```ml
function caseExpression(branches, elseExpression, typeInfo)
```

Implements case expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `branches` | `dynamic` | — | branches value consumed by this operation. |
| `elseExpression` | `dynamic` | — | elseExpression value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L424)

<a id="function-function-minisql-sql-expressions-castexpression-function-castexpression-operand-targettype-src-minisql-sql-expressions-ml-152506130"></a>
### castExpression

```ml
function castExpression(operand, targetType)
```

Casts expression using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `targetType` | `dynamic` | — | targetType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L438)

<a id="function-function-minisql-sql-expressions-checkpasses-function-checkpasses-expression-context-src-minisql-sql-expressions-ml-1778957065"></a>
### checkPasses

```ml
function checkPasses(expression, context)
```

Checks passes using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1382)

<a id="function-function-minisql-sql-expressions-civildatefromepochdays-function-civildatefromepochdays-days-src-minisql-sql-expressions-ml-1188779335"></a>
### civilDateFromEpochDays

```ml
function civilDateFromEpochDays(days)
```

Converts days since 1970-01-01 to Gregorian year, month and day.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `days` | `dynamic` | — | days value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1073)

<a id="function-function-minisql-sql-expressions-column-function-column-index-typeinfo-src-minisql-sql-expressions-ml-1864292186"></a>
### column

```ml
function column(index, typeInfo)
```

Implements column for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the affected item. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L347)

<a id="function-function-minisql-sql-expressions-comparisonresult-function-comparisonresult-left-right-operator-src-minisql-sql-expressions-ml-1687809711"></a>
### comparisonResult

```ml
function comparisonResult(left, right, operator)
```

Implements comparison result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `operator` | `dynamic` | — | operator value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L884)

<a id="function-function-minisql-sql-expressions-componentname-function-componentname-src-minisql-sql-expressions-ml-1272046120"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql expressions module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1392)

<a id="function-function-minisql-sql-expressions-containsaggregate-function-containsaggregate-expression-src-minisql-sql-expressions-ml-2077814370"></a>
### containsAggregate

```ml
function containsAggregate(expression)
```

Returns whether the supplied value satisfies the aggregate condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L718)

<a id="function-function-minisql-sql-expressions-containssubquery-function-containssubquery-expression-src-minisql-sql-expressions-ml-1355758302"></a>
### containsSubquery

```ml
function containsSubquery(expression)
```

Returns true when an expression tree contains a row-dependent nested SELECT.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L519)

<a id="function-function-minisql-sql-expressions-containssubquerylist-function-containssubquerylist-items-src-minisql-sql-expressions-ml-602274278"></a>
### containsSubqueryList

```ml
function containsSubqueryList(items)
```

Returns true when at least one expression in a list contains a subquery.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L570)

<a id="function-function-minisql-sql-expressions-containswindow-function-containswindow-expression-src-minisql-sql-expressions-ml-1763696578"></a>
### containsWindow

```ml
function containsWindow(expression)
```

Returns whether the supplied value satisfies the window condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L609)

<a id="function-function-minisql-sql-expressions-containswindowlist-function-containswindowlist-items-src-minisql-sql-expressions-ml-1414774230"></a>
### containsWindowList

```ml
function containsWindowList(items)
```

Returns whether the supplied value satisfies the window list condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L648)

<a id="function-function-minisql-sql-expressions-evaluate-function-evaluate-expression-context-src-minisql-sql-expressions-ml-979657523"></a>
### evaluate

```ml
function evaluate(expression, context)
```

Evaluates evaluate using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1300)

<a id="function-function-minisql-sql-expressions-evaluatebetween-function-evaluatebetween-expression-context-src-minisql-sql-expressions-ml-1591508465"></a>
### evaluateBetween

```ml
function evaluateBetween(expression, context)
```

Evaluates between using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1270)

<a id="function-function-minisql-sql-expressions-evaluatecase-function-evaluatecase-expression-context-src-minisql-sql-expressions-ml-161039363"></a>
### evaluateCase

```ml
function evaluateCase(expression, context)
```

Evaluates case using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L958)

<a id="function-function-minisql-sql-expressions-evaluatein-function-evaluatein-expression-context-src-minisql-sql-expressions-ml-1120919715"></a>
### evaluateIn

```ml
function evaluateIn(expression, context)
```

Evaluates in using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1245)

<a id="function-function-minisql-sql-expressions-evaluatescalar-function-evaluatescalar-expression-context-src-minisql-sql-expressions-ml-259117407"></a>
### evaluateScalar

```ml
function evaluateScalar(expression, context)
```

Evaluates scalar using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1225)

<a id="function-function-minisql-sql-expressions-evaluatescalarvalues-function-evaluatescalarvalues-expression-arguments-src-minisql-sql-expressions-ml-1180906980"></a>
### evaluateScalarValues

```ml
function evaluateScalarValues(expression, arguments)
```

Evaluates a scalar after its arguments have already been evaluated. This entry point is also used by grouped expressions containing aggregates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `arguments` | `dynamic` | — | arguments value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1113)

<a id="function-function-minisql-sql-expressions-evaluatetruthtest-function-evaluatetruthtest-expression-context-src-minisql-sql-expressions-ml-509246463"></a>
### evaluateTruthTest

```ml
function evaluateTruthTest(expression, context)
```

Evaluates truth test using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1284)

<a id="function-function-minisql-sql-expressions-fail-function-fail-code-operation-message-src-minisql-sql-expressions-ml-1085390465"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql sql expressions module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L233)

<a id="function-function-minisql-sql-expressions-inpredicate-function-inpredicate-operand-candidates-negated-src-minisql-sql-expressions-ml-1643100991"></a>
### inPredicate

```ml
function inPredicate(operand, candidates, negated)
```

Implements in predicate for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `candidates` | `dynamic` | — | candidates value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L465)

<a id="function-function-minisql-sql-expressions-integerdivide-function-integerdivide-left-right-src-minisql-sql-expressions-ml-1001956497"></a>
### integerDivide

```ml
function integerDivide(left, right)
```

Computes exact floor division for native integers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1064)

<a id="constant-constant-minisql-sql-expressions-invalid-argument-const-invalid-argument-9001-src-minisql-sql-expressions-ml-719178215"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L16)

<a id="function-function-minisql-sql-expressions-isbaseboundexpression-function-isbaseboundexpression-value-src-minisql-sql-expressions-ml-1439032977"></a>
### isBaseBoundExpression

```ml
function isBaseBoundExpression(value)
```

Returns whether the supplied value satisfies the base bound expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L265)

<a id="function-function-minisql-sql-expressions-isboundaggregate-function-isboundaggregate-value-src-minisql-sql-expressions-ml-903333839"></a>
### isBoundAggregate

```ml
function isBoundAggregate(value)
```

Returns whether the supplied value satisfies the bound aggregate condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L249)

<a id="function-function-minisql-sql-expressions-isboundbetween-function-isboundbetween-value-src-minisql-sql-expressions-ml-1655655883"></a>
### isBoundBetween

```ml
function isBoundBetween(value)
```

Returns whether the supplied value satisfies the bound between condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L305)

<a id="function-function-minisql-sql-expressions-isboundcase-function-isboundcase-value-src-minisql-sql-expressions-ml-74747395"></a>
### isBoundCase

```ml
function isBoundCase(value)
```

Returns whether the supplied value satisfies the bound case condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L273)

<a id="function-function-minisql-sql-expressions-isboundcast-function-isboundcast-value-src-minisql-sql-expressions-ml-9631865"></a>
### isBoundCast

```ml
function isBoundCast(value)
```

Returns whether the supplied value satisfies the bound cast condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L281)

<a id="function-function-minisql-sql-expressions-isboundexpression-function-isboundexpression-value-src-minisql-sql-expressions-ml-1763501823"></a>
### isBoundExpression

```ml
function isBoundExpression(value)
```

Returns whether the supplied value satisfies the bound expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L241)

<a id="function-function-minisql-sql-expressions-isboundin-function-isboundin-value-src-minisql-sql-expressions-ml-1071518137"></a>
### isBoundIn

```ml
function isBoundIn(value)
```

Returns whether the supplied value satisfies the bound in condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L297)

<a id="function-function-minisql-sql-expressions-isboundliteral-function-isboundliteral-value-src-minisql-sql-expressions-ml-300714339"></a>
### isBoundLiteral

```ml
function isBoundLiteral(value)
```

Returns whether the supplied value satisfies the bound literal condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L257)

<a id="function-function-minisql-sql-expressions-isboundscalar-function-isboundscalar-value-src-minisql-sql-expressions-ml-1513274467"></a>
### isBoundScalar

```ml
function isBoundScalar(value)
```

Returns whether the supplied value satisfies the bound scalar condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L289)

<a id="function-function-minisql-sql-expressions-isboundsubquery-function-isboundsubquery-value-src-minisql-sql-expressions-ml-1508449695"></a>
### isBoundSubquery

```ml
function isBoundSubquery(value)
```

Returns whether a bound expression defers a nested SELECT to row evaluation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L327)

<a id="function-function-minisql-sql-expressions-isboundtruthtest-function-isboundtruthtest-value-src-minisql-sql-expressions-ml-463023955"></a>
### isBoundTruthTest

```ml
function isBoundTruthTest(value)
```

Returns whether the supplied value satisfies the bound truth test condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L313)

<a id="function-function-minisql-sql-expressions-isboundwindow-function-isboundwindow-value-src-minisql-sql-expressions-ml-2031183211"></a>
### isBoundWindow

```ml
function isBoundWindow(value)
```

Returns whether the supplied value satisfies the bound window condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L321)

<a id="function-function-minisql-sql-expressions-isimplemented-function-isimplemented-src-minisql-sql-expressions-ml-1402863288"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql expressions module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1406)

<a id="function-function-minisql-sql-expressions-isnull-function-isnull-operand-negated-src-minisql-sql-expressions-ml-1696555189"></a>
### isNull

```ml
function isNull(operand, negated)
```

Returns whether the supplied value satisfies the null condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L383)

<a id="function-function-minisql-sql-expressions-likeresult-function-likeresult-left-right-src-minisql-sql-expressions-ml-1774863519"></a>
### likeResult

```ml
function likeResult(left, right)
```

Implements like result for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L903)

<a id="function-function-minisql-sql-expressions-literal-function-literal-value-typeinfo-src-minisql-sql-expressions-ml-580674141"></a>
### literal

```ml
function literal(value, typeInfo)
```

Implements literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L336)

<a id="function-function-minisql-sql-expressions-numericresult-function-numericresult-left-right-operator-resulttype-src-minisql-sql-expressions-ml-684013274"></a>
### numericResult

```ml
function numericResult(left, right, operator, resultType)
```

Implements numeric result for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `resultType` | `dynamic` | — | resultType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L857)

<a id="function-function-minisql-sql-expressions-predicatepasses-function-predicatepasses-expression-context-src-minisql-sql-expressions-ml-909119135"></a>
### predicatePasses

```ml
function predicatePasses(expression, context)
```

Implements predicate passes for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1370)

<a id="function-function-minisql-sql-expressions-referencescolumnatorafter-function-referencescolumnatorafter-expression-minimumindex-src-minisql-sql-expressions-ml-1902384338"></a>
### referencesColumnAtOrAfter

```ml
function referencesColumnAtOrAfter(expression, minimumIndex)
```

Implements references column at or after for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `minimumIndex` | `dynamic` | — | Zero-based index of minimum. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L661)

<a id="function-function-minisql-sql-expressions-replacetext-function-replacetext-sourcetext-searchtext-replacementtext-src-minisql-sql-expressions-ml-726165740"></a>
### replaceText

```ml
function replaceText(sourceText, searchText, replacementText)
```

Replaces all non-overlapping UTF-8 byte sequences without changing unaffected bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sourceText` | `dynamic` | — | sourceText value consumed by this operation. |
| `searchText` | `dynamic` | — | searchText value consumed by this operation. |
| `replacementText` | `dynamic` | — | replacementText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1025)

<a id="function-function-minisql-sql-expressions-rowcontext-function-rowcontext-rowvalues-src-minisql-sql-expressions-ml-1875813636"></a>
### rowContext

```ml
function rowContext(rowValues)
```

Implements row context for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowValues` | `dynamic` | — | rowValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L841)

- [minisql.sql.expressions.RowContext](Type-minisql-sql-expressions-rowcontext-652519886.md) — struct
<a id="function-function-minisql-sql-expressions-samebinding-function-samebinding-left-right-src-minisql-sql-expressions-ml-720867517"></a>
### sameBinding

```ml
function sameBinding(left, right)
```

Implements same binding for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L759)

<a id="function-function-minisql-sql-expressions-scalar-function-scalar-name-arguments-typeinfo-src-minisql-sql-expressions-ml-1239700967"></a>
### scalar

```ml
function scalar(name, arguments, typeInfo)
```

Implements scalar for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `arguments` | `dynamic` | — | arguments value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L450)

<a id="function-function-minisql-sql-expressions-subquery-function-subquery-subquerykind-query-operand-negated-typeinfo-src-minisql-sql-expressions-ml-792075027"></a>
### subquery

```ml
function subquery(subqueryKind, query, operand, negated, typeInfo)
```

Creates a deferred subquery binding after its shape and result type have been validated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `subqueryKind` | `dynamic` | — | subqueryKind value consumed by this operation. |
| `query` | `dynamic` | — | query value consumed by this operation. |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L509)

<a id="constant-constant-minisql-sql-expressions-subquery-exists-const-subquery-exists-2-src-minisql-sql-expressions-ml-238240837"></a>
### SUBQUERY_EXISTS

```ml
const SUBQUERY_EXISTS = 2
```

Defines the subquery exists constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L54)

<a id="constant-constant-minisql-sql-expressions-subquery-in-const-subquery-in-3-src-minisql-sql-expressions-ml-673033704"></a>
### SUBQUERY_IN

```ml
const SUBQUERY_IN = 3
```

Defines the subquery in constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L56)

<a id="constant-constant-minisql-sql-expressions-subquery-scalar-const-subquery-scalar-1-src-minisql-sql-expressions-ml-1379831510"></a>
### SUBQUERY_SCALAR

```ml
const SUBQUERY_SCALAR = 1
```

Defines the subquery scalar constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L52)

<a id="function-function-minisql-sql-expressions-targetmilestone-function-targetmilestone-src-minisql-sql-expressions-ml-1986052634"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql expressions module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L1399)

<a id="function-function-minisql-sql-expressions-truthtest-function-truthtest-operand-expected-negated-src-minisql-sql-expressions-ml-67539123"></a>
### truthTest

```ml
function truthTest(operand, expected, negated)
```

Implements truth test for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L498)

<a id="constant-constant-minisql-sql-expressions-type-mismatch-const-type-mismatch-9017-src-minisql-sql-expressions-ml-391730910"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```

Defines the type mismatch constant used by the minisql sql expressions module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L18)

<a id="function-function-minisql-sql-expressions-unary-function-unary-operator-operand-typeinfo-src-minisql-sql-expressions-ml-510660709"></a>
### unary

```ml
function unary(operator, operand, typeInfo)
```

Implements unary for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L359)

<a id="function-function-minisql-sql-expressions-utf8byteoffset-function-utf8byteoffset-raw-characterindex-src-minisql-sql-expressions-ml-1813106529"></a>
### utf8ByteOffset

```ml
function utf8ByteOffset(raw, characterIndex)
```

Maps a zero-based Unicode character index to a UTF-8 byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — | raw value consumed by this operation. |
| `characterIndex` | `dynamic` | — | Zero-based index of character. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L997)

<a id="function-function-minisql-sql-expressions-utf8charactercount-function-utf8charactercount-raw-src-minisql-sql-expressions-ml-1224644980"></a>
### utf8CharacterCount

```ml
function utf8CharacterCount(raw)
```

Counts Unicode scalar starts in validated UTF-8 text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — | raw value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L986)

<a id="function-function-minisql-sql-expressions-window-function-window-name-arguments-partitionby-orderby-descending-nullsfirst-nullsspecified-typeinfo-src-minisql-sql-expressions-ml-730976289"></a>
### window

```ml
function window(name, arguments, partitionBy, orderBy, descending, nullsFirst, nullsSpecified, typeInfo)
```

Implements window for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `arguments` | `dynamic` | — | arguments value consumed by this operation. |
| `partitionBy` | `dynamic` | — | partitionBy value consumed by this operation. |
| `orderBy` | `dynamic` | — | orderBy value consumed by this operation. |
| `descending` | `dynamic` | — | descending value consumed by this operation. |
| `nullsFirst` | `dynamic` | — | nullsFirst value consumed by this operation. |
| `nullsSpecified` | `dynamic` | — | nullsSpecified value consumed by this operation. |
| `typeInfo` | `dynamic` | — | typeInfo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L589)
