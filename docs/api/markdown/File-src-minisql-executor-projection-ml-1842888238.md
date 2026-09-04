# `src/minisql/executor/projection.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql executor projection facilities for this project.

Package: [`minisql.executor.projection`](Package-minisql-executor-projection-1281772020.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)

## Declarations

<a id="function-function-minisql-executor-projection-apply-function-apply-rows-selectexpressions-orderexpressions-src-minisql-executor-projection-ml-1878343791"></a>
### apply

```ml
function apply(rows, selectExpressions, orderExpressions)
```

Applies apply using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `orderExpressions` | `dynamic` | — | orderExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L79)

<a id="function-function-minisql-executor-projection-applywindows-function-applywindows-rows-selectexpressions-orderexpressions-src-minisql-executor-projection-ml-768487643"></a>
### applyWindows

```ml
function applyWindows(rows, selectExpressions, orderExpressions)
```

Applies windows using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `orderExpressions` | `dynamic` | — | orderExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L357)

<a id="function-function-minisql-executor-projection-comparenullable-function-comparenullable-left-right-descending-nullsfirst-nullsspecified-src-minisql-executor-projection-ml-236766771"></a>
### compareNullable

```ml
function compareNullable(left, right, descending, nullsFirst, nullsSpecified)
```

Compares nullable using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `descending` | `dynamic` | — | descending value consumed by this operation. |
| `nullsFirst` | `dynamic` | — | nullsFirst value consumed by this operation. |
| `nullsSpecified` | `dynamic` | — | nullsSpecified value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L420)

<a id="function-function-minisql-executor-projection-comparerows-function-comparerows-left-right-orderitems-src-minisql-executor-projection-ml-829552429"></a>
### compareRows

```ml
function compareRows(left, right, orderItems)
```

Compares rows using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L443)

<a id="function-function-minisql-executor-projection-comparewindowrows-function-comparewindowrows-left-right-expression-src-minisql-executor-projection-ml-967938227"></a>
### compareWindowRows

```ml
function compareWindowRows(left, right, expression)
```

Compares window rows using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L141)

<a id="function-function-minisql-executor-projection-componentname-function-componentname-src-minisql-executor-projection-ml-1073572968"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql executor projection module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L527)

<a id="function-function-minisql-executor-projection-distinct-function-distinct-rows-src-minisql-executor-projection-ml-2085779269"></a>
### distinct

```ml
function distinct(rows)
```

Implements distinct for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L398)

<a id="function-function-minisql-executor-projection-evaluatelist-function-evaluatelist-boundexpressions-context-operation-src-minisql-executor-projection-ml-397712523"></a>
### evaluateList

```ml
function evaluateList(boundExpressions, context, operation)
```

Evaluates list using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundExpressions` | `dynamic` | — | boundExpressions value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L61)

<a id="function-function-minisql-executor-projection-evaluatewindowargument-function-evaluatewindowargument-expression-argumentindex-row-src-minisql-executor-projection-ml-1614095541"></a>
### evaluateWindowArgument

```ml
function evaluateWindowArgument(expression, argumentIndex, row)
```

Evaluates a window argument in the context of one selected partition row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `argumentIndex` | `dynamic` | — | Zero-based index of argument. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L252)

<a id="function-function-minisql-executor-projection-evaluatewindowlist-function-evaluatewindowlist-boundexpressions-allrows-row-src-minisql-executor-projection-ml-2105108981"></a>
### evaluateWindowList

```ml
function evaluateWindowList(boundExpressions, allRows, row)
```

Evaluates window list using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundExpressions` | `dynamic` | — | boundExpressions value consumed by this operation. |
| `allRows` | `dynamic` | — | allRows value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L341)

<a id="function-function-minisql-executor-projection-fail-function-fail-code-operation-message-src-minisql-executor-projection-ml-1320360245"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql executor projection module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L42)

<a id="function-function-minisql-executor-projection-integerdivide-function-integerdivide-numerator-denominator-src-minisql-executor-projection-ml-1365264531"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Performs truncating integer division without converting window cardinalities to floats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — | numerator value consumed by this operation. |
| `denominator` | `dynamic` | — | denominator value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L21)

<a id="constant-constant-minisql-executor-projection-invalid-argument-const-invalid-argument-9001-src-minisql-executor-projection-ml-19400567"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql executor projection module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L16)

<a id="function-function-minisql-executor-projection-isimplemented-function-isimplemented-src-minisql-executor-projection-ml-1722773056"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql executor projection module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L541)

<a id="function-function-minisql-executor-projection-isprojectedrow-function-isprojectedrow-value-src-minisql-executor-projection-ml-727211189"></a>
### isProjectedRow

```ml
function isProjectedRow(value)
```

Returns whether the supplied value satisfies the projected row condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L50)

<a id="function-function-minisql-executor-projection-merge-function-merge-left-right-orderitems-src-minisql-executor-projection-ml-1747901045"></a>
### merge

```ml
function merge(left, right, orderItems)
```

Implements merge for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L462)

<a id="function-function-minisql-executor-projection-mergewindow-function-mergewindow-left-right-expression-src-minisql-executor-projection-ml-312816011"></a>
### mergeWindow

```ml
function mergeWindow(left, right, expression)
```

Implements merge window for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L159)

- [minisql.executor.projection.ProjectedRow](Type-minisql-executor-projection-projectedrow-333893506.md) — struct
<a id="function-function-minisql-executor-projection-samerow-function-samerow-left-right-src-minisql-executor-projection-ml-1679890197"></a>
### sameRow

```ml
function sameRow(left, right)
```

Implements same row for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L384)

<a id="function-function-minisql-executor-projection-samevalue-function-samevalue-left-right-src-minisql-executor-projection-ml-1871791763"></a>
### sameValue

```ml
function sameValue(left, right)
```

Implements same value for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L372)

<a id="function-function-minisql-executor-projection-samevalues-function-samevalues-left-right-src-minisql-executor-projection-ml-187905965"></a>
### sameValues

```ml
function sameValues(left, right)
```

Implements same values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L98)

<a id="function-function-minisql-executor-projection-slicerows-function-slicerows-rows-offset-limit-src-minisql-executor-projection-ml-1123347503"></a>
### sliceRows

```ml
function sliceRows(rows, offset, limit)
```

Implements slice rows for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L511)

<a id="function-function-minisql-executor-projection-sort-function-sort-rows-orderitems-src-minisql-executor-projection-ml-230044301"></a>
### sort

```ml
function sort(rows, orderItems)
```

Sorts sort using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L492)

<a id="function-function-minisql-executor-projection-sortwindowrows-function-sortwindowrows-rows-expression-src-minisql-executor-projection-ml-27484951"></a>
### sortWindowRows

```ml
function sortWindowRows(rows, expression)
```

Sorts window rows using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L188)

<a id="function-function-minisql-executor-projection-targetmilestone-function-targetmilestone-src-minisql-executor-projection-ml-893382450"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql executor projection module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L534)

<a id="function-function-minisql-executor-projection-windowaggregate-function-windowaggregate-expression-partitionrows-src-minisql-executor-projection-ml-2036664787"></a>
### windowAggregate

```ml
function windowAggregate(expression, partitionRows)
```

Implements window aggregate for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `partitionRows` | `dynamic` | — | partitionRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L205)

<a id="function-function-minisql-executor-projection-windowinteger-function-windowinteger-value-operation-src-minisql-executor-projection-ml-1093985762"></a>
### windowInteger

```ml
function windowInteger(value, operation)
```

Decodes an integral SQL window argument and rejects NULL or non-integral values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L241)

<a id="function-function-minisql-executor-projection-windowordervalues-function-windowordervalues-expression-row-src-minisql-executor-projection-ml-1642483494"></a>
### windowOrderValues

```ml
function windowOrderValues(expression, row)
```

Implements window order values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L126)

<a id="function-function-minisql-executor-projection-windowpartitionkey-function-windowpartitionkey-expression-row-src-minisql-executor-projection-ml-2040949518"></a>
### windowPartitionKey

```ml
function windowPartitionKey(expression, row)
```

Implements window partition key for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L112)

<a id="function-function-minisql-executor-projection-windowvalue-function-windowvalue-expression-allrows-currentrow-src-minisql-executor-projection-ml-1459242917"></a>
### windowValue

```ml
function windowValue(expression, allRows, currentRow)
```

Implements window value for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `allRows` | `dynamic` | — | allRows value consumed by this operation. |
| `currentRow` | `dynamic` | — | currentRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/projection.ml#L262)
