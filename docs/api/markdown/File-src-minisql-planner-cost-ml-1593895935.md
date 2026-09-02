# `src/minisql/planner/cost.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.planner.cost`](Package-minisql-planner-cost-781112943.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-planner-cost-aggregate-function-aggregate-input-grouprows-src-minisql-planner-cost-ml-2049241560"></a>
### aggregate

```ml
function aggregate(input, groupRows)
```

Implements aggregate for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |
| `groupRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L150)

<a id="function-function-minisql-planner-cost-componentname-function-componentname-src-minisql-planner-cost-ml-536142480"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L216)

- [minisql.planner.cost.CostEstimate](Type-minisql-planner-cost-costestimate-1352627348.md) — struct
<a id="function-function-minisql-planner-cost-estimate-function-estimate-startup-total-rows-algorithm-src-minisql-planner-cost-ml-770386993"></a>
### estimate

```ml
function estimate(startup, total, rows, algorithm)
```

Estimates estimate using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startup` | `dynamic` | — |  |
| `total` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |
| `algorithm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L51)

<a id="function-function-minisql-planner-cost-externalsort-function-externalsort-input-src-minisql-planner-cost-ml-71143082"></a>
### externalSort

```ml
function externalSort(input)
```

Implements external sort for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L175)

<a id="function-function-minisql-planner-cost-fail-function-fail-code-operation-message-src-minisql-planner-cost-ml-821851967"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L27)

<a id="function-function-minisql-planner-cost-filter-function-filter-input-outputrows-src-minisql-planner-cost-ml-1300402690"></a>
### filter

```ml
function filter(input, outputRows)
```

Implements filter for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L102)

<a id="function-function-minisql-planner-cost-hashjoin-function-hashjoin-left-right-outputrows-src-minisql-planner-cost-ml-372953793"></a>
### hashJoin

```ml
function hashJoin(left, right, outputRows)
```

Implements hash join for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L123)

<a id="function-function-minisql-planner-cost-indexnestedloop-function-indexnestedloop-left-indexheight-expectedmatchesperprobe-outputrows-src-minisql-planner-cost-ml-1725905444"></a>
### indexNestedLoop

```ml
function indexNestedLoop(left, indexHeight, expectedMatchesPerProbe, outputRows)
```

Estimates a parameterized nested loop whose inner side performs one B+-tree lookup per outer row. This is attractive for a small outer input but loses to a hash join once repeated random access dominates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `indexHeight` | `dynamic` | — |  |
| `expectedMatchesPerProbe` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L133)

<a id="function-function-minisql-planner-cost-indexonlyscan-function-indexonlyscan-height-indexrows-outputrows-uniquelookup-src-minisql-planner-cost-ml-1163232707"></a>
### indexOnlyScan

```ml
function indexOnlyScan(height, indexRows, outputRows, uniqueLookup)
```

Estimates an index-only scan whose key contains every column needed by the predicate and projection. No heap page or overflow value is fetched.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `height` | `dynamic` | — |  |
| `indexRows` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |
| `uniqueLookup` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L87)

<a id="function-function-minisql-planner-cost-indexscan-function-indexscan-height-heaprows-outputrows-uniquelookup-src-minisql-planner-cost-ml-2039395077"></a>
### indexScan

```ml
function indexScan(height, heapRows, outputRows, uniqueLookup)
```

Estimates a B+-tree lookup plus the heap fetches expected for qualifying rows. `height` models random index-page reads; `heapRows` distinguishes a covering/unique lookup from a broad range that would be cheaper to scan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `height` | `dynamic` | — |  |
| `heapRows` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |
| `uniqueLookup` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L71)

<a id="constant-constant-minisql-planner-cost-invalid-argument-const-invalid-argument-9001-src-minisql-planner-cost-ml-1569172149"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Integer cost model. Costs are abstract work units, deliberately deterministic so plans and acceptance tests do not depend on wall-clock timing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L10)

<a id="function-function-minisql-planner-cost-iscostestimate-function-iscostestimate-value-src-minisql-planner-cost-ml-327219777"></a>
### isCostEstimate

```ml
function isCostEstimate(value)
```

Returns whether the supplied value satisfies the cost estimate condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L34)

<a id="function-function-minisql-planner-cost-isimplemented-function-isimplemented-src-minisql-planner-cost-ml-329775880"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L230)

<a id="function-function-minisql-planner-cost-nestedloop-function-nestedloop-left-right-outputrows-src-minisql-planner-cost-ml-658383525"></a>
### nestedLoop

```ml
function nestedLoop(left, right, outputRows)
```

Implements nested loop for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L112)

<a id="function-function-minisql-planner-cost-project-function-project-input-outputrows-src-minisql-planner-cost-ml-1266302472"></a>
### project

```ml
function project(input, outputRows)
```

Implements project for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L207)

<a id="function-function-minisql-planner-cost-sequentialscan-function-sequentialscan-pagecount-rowcount-src-minisql-planner-cost-ml-55353789"></a>
### sequentialScan

```ml
function sequentialScan(pageCount, rowCount)
```

Implements sequential scan for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageCount` | `dynamic` | — |  |
| `rowCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L62)

<a id="function-function-minisql-planner-cost-sort-function-sort-input-src-minisql-planner-cost-ml-1367315482"></a>
### sort

```ml
function sort(input)
```

Sorts sort using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L160)

<a id="function-function-minisql-planner-cost-targetmilestone-function-targetmilestone-src-minisql-planner-cost-ml-1432677034"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L223)

<a id="function-function-minisql-planner-cost-topn-function-topn-input-windowrows-src-minisql-planner-cost-ml-80907153"></a>
### topN

```ml
function topN(input, windowRows)
```

Estimates a bounded top-N heap/insertion set. The executor uses this only for small LIMIT+OFFSET windows, so work depends on log(window) rather than log(input rows), and retained memory is bounded by the requested window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |
| `windowRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L191)

<a id="function-function-minisql-planner-cost-validaterows-function-validaterows-value-operation-name-src-minisql-planner-cost-ml-48230131"></a>
### validateRows

```ml
function validateRows(value, operation, name)
```

Validates rows using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/cost.ml#L42)
