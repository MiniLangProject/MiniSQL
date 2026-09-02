# `src/minisql/planner/optimizer.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.planner.optimizer`](Package-minisql-planner-optimizer-19815101.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/statistics.ml` as `statistics` → [src/minisql/catalog/statistics.ml](File-src-minisql-catalog-statistics-ml-1707584758.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/planner/cost.ml` as `cost` → [src/minisql/planner/cost.ml](File-src-minisql-planner-cost-ml-1593895935.md)
- `minisql/planner/execution_plan.ml` as `execution_plan` → [src/minisql/planner/execution_plan.ml](File-src-minisql-planner-execution-plan-ml-1727378828.md)
- `minisql/planner/physical_plan.ml` as `physical_plan` → [src/minisql/planner/physical_plan.ml](File-src-minisql-planner-physical-plan-ml-736569249.md)
- `minisql/planner/rewrites.ml` as `rewrites` → [src/minisql/planner/rewrites.ml](File-src-minisql-planner-rewrites-ml-771945595.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)

## Declarations

<a id="function-function-minisql-planner-optimizer-buildbase-function-buildbase-bound-state-sourcepredicates-src-minisql-planner-optimizer-ml-642130132"></a>
### buildBase

```ml
function buildBase(bound, state, sourcePredicates)
```

Builds the scan/join spine and its cumulative deterministic cost estimate. Equality INNER/LEFT joins compare hash and nested-loop costs; unsupported join shapes retain the semantic nested-loop fallback. Returns plan, cost, and stats-use flag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `sourcePredicates` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L853)

<a id="function-function-minisql-planner-optimizer-choosejoinsequence-function-choosejoinsequence-bound-sourcescans-state-src-minisql-planner-optimizer-ml-1303616112"></a>
### chooseJoinSequence

```ml
function chooseJoinSequence(bound, sourceScans, state)
```

Enumerates the cheapest connected left-deep order for up to eight sources. This is the classic Selinger subset dynamic program adapted to MiniSQL's executor contract, which attaches one source per JoinPlan. Unsupported or larger graphs retain the deterministic greedy implementation above.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `sourceScans` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L793)

<a id="function-function-minisql-planner-optimizer-choosejoinsequencegreedy-function-choosejoinsequencegreedy-bound-sourcescans-src-minisql-planner-optimizer-ml-1387968005"></a>
### chooseJoinSequenceGreedy

```ml
function chooseJoinSequenceGreedy(bound, sourceScans)
```

Reorders a pure INNER equijoin graph with a deterministic cost-guided greedy search. The smallest estimated source seeds the tree; each step attaches the smallest unjoined source connected by one eligible equality edge. Outer, cross, cyclic and non-binary predicates retain SQL order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `sourceScans` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L700)

<a id="function-function-minisql-planner-optimizer-columngroupstats-function-columngroupstats-found-columnindexes-src-minisql-planner-optimizer-ml-96333986"></a>
### columnGroupStats

```ml
function columnGroupStats(found, columnIndexes)
```

Finds exact ordered joint-column statistics, normally produced for a composite index key by ANALYZE.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `found` | `dynamic` | — |  |
| `columnIndexes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L133)

<a id="function-function-minisql-planner-optimizer-columnstats-function-columnstats-found-columnindex-src-minisql-planner-optimizer-ml-973773712"></a>
### columnStats

```ml
function columnStats(found, columnIndex)
```

Finds persisted column statistics by local table-column index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `found` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L123)

<a id="function-function-minisql-planner-optimizer-combinedindexcandidate-function-combinedindexcandidate-bound-source-predicate-state-found-rows-src-minisql-planner-optimizer-ml-1013611664"></a>
### combinedIndexCandidate

```ml
function combinedIndexCandidate(bound, source, predicate, state, found, rows)
```

Chooses a bounded multi-index path for a single base table. AND may use every independently indexable conjunct and intersect row identities; OR is eligible only when every disjunct has an index so no qualifying branch can be lost.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `found` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L464)

<a id="function-function-minisql-planner-optimizer-componentname-function-componentname-src-minisql-planner-optimizer-ml-838324764"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L1036)

<a id="function-function-minisql-planner-optimizer-connectingjoin-function-connectingjoin-bound-state-sourceindex-src-minisql-planner-optimizer-ml-1871492222"></a>
### connectingJoin

```ml
function connectingJoin(bound, state, sourceIndex)
```

Finds a join edge that connects one candidate source to the current subset. Pure tree-shaped INNER equijoin graphs have one such edge; when more than one exists the lowest estimated output cardinality wins deterministically.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L771)

<a id="function-function-minisql-planner-optimizer-countslotseligible-function-countslotseligible-bound-wherepredicate-src-minisql-planner-optimizer-ml-1085682114"></a>
### countSlotsEligible

```ml
function countSlotsEligible(bound, wherePredicate)
```

Recognizes the exact COUNT(*) form implemented by the checksum-verified heap slot counter. Keeping this choice in the optimizer makes EXPLAIN and normal execution agree about the fast path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `wherePredicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L607)

<a id="function-function-minisql-planner-optimizer-distinctforboundcolumn-function-distinctforboundcolumn-bound-state-columnindex-src-minisql-planner-optimizer-ml-91559879"></a>
### distinctForBoundColumn

```ml
function distinctForBoundColumn(bound, state, columnIndex)
```

Implements join rows for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L563)

<a id="function-function-minisql-planner-optimizer-equalitycolumngroup-function-equalitycolumngroup-source-found-predicate-src-minisql-planner-optimizer-ml-902858078"></a>
### equalityColumnGroup

```ml
function equalityColumnGroup(source, found, predicate)
```

Selects the widest complete equality group available for a predicate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `found` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L280)

<a id="function-function-minisql-planner-optimizer-equalityrows-function-equalityrows-inputrows-tablerows-current-literal-src-minisql-planner-optimizer-ml-300856598"></a>
### equalityRows

```ml
function equalityRows(inputRows, tableRows, current, literal)
```

Estimates equality from the MCV list and distributes the remaining population uniformly across non-MCV distinct values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputRows` | `dynamic` | — |  |
| `tableRows` | `dynamic` | — |  |
| `current` | `dynamic` | — |  |
| `literal` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L190)

<a id="function-function-minisql-planner-optimizer-explain-function-explain-bound-state-src-minisql-planner-optimizer-ml-1399099675"></a>
### explain

```ml
function explain(bound, state)
```

Implements explain for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L1025)

<a id="function-function-minisql-planner-optimizer-expressioncoveredbyindex-function-expressioncoveredbyindex-expression-source-index-src-minisql-planner-optimizer-ml-1671287147"></a>
### expressionCoveredByIndex

```ml
function expressionCoveredByIndex(expression, source, index)
```

Returns whether every column referenced by one expression belongs to an index key. Global bound indexes are translated into the source-local domain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L341)

<a id="function-function-minisql-planner-optimizer-fail-function-fail-code-operation-message-src-minisql-planner-optimizer-ml-483996185"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L71)

<a id="function-function-minisql-planner-optimizer-histogramlessorequal-function-histogramlessorequal-current-candidate-src-minisql-planner-optimizer-ml-2126737070"></a>
### histogramLessOrEqual

```ml
function histogramLessOrEqual(current, candidate)
```

Interpolates an inclusive integral boundary within the persisted cumulative histogram and returns a whole-table population estimate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `dynamic` | — |  |
| `candidate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L167)

<a id="function-function-minisql-planner-optimizer-indexcandidate-function-indexcandidate-bound-source-predicate-state-found-rows-outputrows-src-minisql-planner-optimizer-ml-696337736"></a>
### indexCandidate

```ml
function indexCandidate(bound, source, predicate, state, found, rows, outputRows)
```

Chooses the longest usable B+-tree prefix for a source predicate. Equality may consume every index column; a range may consume only the leading column because the current storage integration does not yet expose prefix ranges.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `found` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |
| `outputRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L382)

<a id="function-function-minisql-planner-optimizer-indexcoversbound-function-indexcoversbound-bound-source-index-predicate-src-minisql-planner-optimizer-ml-654161322"></a>
### indexCoversBound

```ml
function indexCoversBound(bound, source, index, predicate)
```

Recognizes a query fully answerable from B+-tree key and INCLUDE payloads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L358)

<a id="function-function-minisql-planner-optimizer-indexnamecontains-function-indexnamecontains-items-name-src-minisql-planner-optimizer-ml-945262785"></a>
### indexNameContains

```ml
function indexNameContains(items, name)
```

Reports whether a stable index-name list contains one name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L26)

<a id="function-function-minisql-planner-optimizer-indexnamelisttext-function-indexnamelisttext-items-src-minisql-planner-optimizer-ml-1078447614"></a>
### indexNameListText

```ml
function indexNameListText(items)
```

Renders a deterministic comma-separated index-name list for EXPLAIN.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L34)

<a id="function-function-minisql-planner-optimizer-integerdivide-function-integerdivide-numerator-denominator-src-minisql-planner-optimizer-ml-355225887"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Implements integer divide for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — |  |
| `denominator` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L79)

<a id="function-function-minisql-planner-optimizer-integralrangerows-function-integralrangerows-inputrows-tablerows-current-operator-literal-src-minisql-planner-optimizer-ml-2069824678"></a>
### integralRangeRows

```ml
function integralRangeRows(inputRows, tableRows, current, operator, literal)
```

Estimates an integral inequality from a cumulative histogram, with a uniform interpolation inside each bucket and a bounds-only fallback for v1-v3 data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputRows` | `dynamic` | — |  |
| `tableRows` | `dynamic` | — |  |
| `current` | `dynamic` | — |  |
| `operator` | `dynamic` | — |  |
| `literal` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L231)

<a id="constant-constant-minisql-planner-optimizer-invalid-argument-const-invalid-argument-9001-src-minisql-planner-optimizer-ml-161393955"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Costed physical-plan builder. It produces both the stable descriptive EXPLAIN tree and a typed execution contract consumed by the executor, so access paths and operator algorithms cannot silently diverge at runtime.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L23)

<a id="function-function-minisql-planner-optimizer-isimplemented-function-isimplemented-src-minisql-planner-optimizer-ml-1145481580"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L1050)

<a id="function-function-minisql-planner-optimizer-isoptimizedplan-function-isoptimizedplan-value-src-minisql-planner-optimizer-ml-1744473327"></a>
### isOptimizedPlan

```ml
function isOptimizedPlan(value)
```

Returns whether the supplied value satisfies the optimized plan condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L100)

<a id="function-function-minisql-planner-optimizer-joinindexcandidate-function-joinindexcandidate-joined-state-src-minisql-planner-optimizer-ml-897481648"></a>
### joinIndexCandidate

```ml
function joinIndexCandidate(joined, state)
```

Finds the single-column right-side index usable by a parameterized equality join. Composite join probes are deferred until the executor accepts multiple lookup keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `joined` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L651)

<a id="function-function-minisql-planner-optimizer-joinoperator-function-joinoperator-jointype-src-minisql-planner-optimizer-ml-249465496"></a>
### joinOperator

```ml
function joinOperator(joinType)
```

Implements join operator for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `joinType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L596)

- [minisql.planner.optimizer.JoinOrderState](Type-minisql-planner-optimizer-joinorderstate-1862784944.md) — struct
<a id="function-function-minisql-planner-optimizer-joinrows-function-joinrows-bound-state-leftrows-rightrows-jointype-condition-src-minisql-planner-optimizer-ml-1552550485"></a>
### joinRows

```ml
function joinRows(bound, state, leftRows, rightRows, joinType, condition)
```

Estimates output cardinality for one join using NDV statistics when the predicate is a supported equality.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `joinType` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L577)

<a id="function-function-minisql-planner-optimizer-optimize-function-optimize-bound-state-src-minisql-planner-optimizer-ml-644607809"></a>
### optimize

```ml
function optimize(bound, state)
```

Lowers a bound SELECT into a costed physical operator tree. Operators are added in relational order; analyzed statistics replace defaults, large sorts select external merge sort, and set-operation branches recurse. Returns OptimizedPlan or a structured validation/dependency error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L936)

- [minisql.planner.optimizer.OptimizedPlan](Type-minisql-planner-optimizer-optimizedplan-1915252585.md) — struct
<a id="function-function-minisql-planner-optimizer-originaljoinsequence-function-originaljoinsequence-bound-src-minisql-planner-optimizer-ml-704726834"></a>
### originalJoinSequence

```ml
function originalJoinSequence(bound)
```

Returns join indexes in their bound SQL order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L664)

<a id="function-function-minisql-planner-optimizer-originaljoinsources-function-originaljoinsources-bound-src-minisql-planner-optimizer-ml-681575948"></a>
### originalJoinSources

```ml
function originalJoinSources(bound)
```

Returns the syntactic source introduced by each original join.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L675)

<a id="function-function-minisql-planner-optimizer-predicaterows-function-predicaterows-source-found-predicate-fallbackrows-src-minisql-planner-optimizer-ml-2046176487"></a>
### predicateRows

```ml
function predicateRows(source, found, predicate, fallbackRows)
```

Estimates a pushed predicate with available NDV statistics, retaining the conservative M17 heuristic for unsupported expression shapes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `found` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |
| `fallbackRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L296)

<a id="function-function-minisql-planner-optimizer-removeintegerat-function-removeintegerat-items-removedindex-src-minisql-planner-optimizer-ml-1998590852"></a>
### removeIntegerAt

```ml
function removeIntegerAt(items, removedIndex)
```

Copies an integer array while omitting one position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `removedIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L686)

<a id="function-function-minisql-planner-optimizer-scalefraction-function-scalefraction-value-numerator-denominator-src-minisql-planner-optimizer-ml-1937239010"></a>
### scaleFraction

```ml
function scaleFraction(value, numerator, denominator)
```

Multiplies a cardinality by a bounded fraction without overflowing the native integer. Dividing the remainder and denominator together only occurs in the exceptional near-limit case and preserves a close conservative ratio.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `numerator` | `dynamic` | — |  |
| `denominator` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L150)

<a id="function-function-minisql-planner-optimizer-scanplan-function-scanplan-bound-source-state-predicate-sourceindex-src-minisql-planner-optimizer-ml-1794583322"></a>
### scanPlan

```ml
function scanPlan(bound, source, state, predicate, sourceIndex)
```

Scans plan using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L510)

<a id="function-function-minisql-planner-optimizer-sourcemaskcount-function-sourcemaskcount-mask-src-minisql-planner-optimizer-ml-1982441320"></a>
### sourceMaskCount

```ml
function sourceMaskCount(mask)
```

Counts set source bits in a small join-enumeration mask.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mask` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L758)

<a id="function-function-minisql-planner-optimizer-streamaggregateeligible-function-streamaggregateeligible-bound-wherepredicate-src-minisql-planner-optimizer-ml-759054978"></a>
### streamAggregateEligible

```ml
function streamAggregateEligible(bound, wherePredicate)
```

Recognizes direct, non-DISTINCT scalar aggregates that can update fixed-size accumulators while scanning instead of retaining every input row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `wherePredicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L620)

<a id="function-function-minisql-planner-optimizer-streamingjoincounteligible-function-streamingjoincounteligible-bound-wherepredicate-reordered-src-minisql-planner-optimizer-ml-1081424670"></a>
### streamingJoinCountEligible

```ml
function streamingJoinCountEligible(bound, wherePredicate, reordered)
```

Recognizes a reordered INNER-equijoin COUNT(*) whose final join can count matches instead of materializing the potentially much larger joined rowset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `wherePredicate` | `dynamic` | — |  |
| `reordered` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L634)

<a id="function-function-minisql-planner-optimizer-tableindexes-function-tableindexes-state-tableid-src-minisql-planner-optimizer-ml-716805978"></a>
### tableIndexes

```ml
function tableIndexes(state, tableId)
```

Returns index metadata from a rich planning context. Legacy callers that pass only StatisticsCatalog retain sequential scans and remain source-compatible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L117)

<a id="function-function-minisql-planner-optimizer-tablestats-function-tablestats-state-tableid-src-minisql-planner-optimizer-ml-1794827490"></a>
### tableStats

```ml
function tableStats(state, tableId)
```

Implements table stats for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L107)

<a id="function-function-minisql-planner-optimizer-targetmilestone-function-targetmilestone-src-minisql-planner-optimizer-ml-1078047754"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L1043)

<a id="function-function-minisql-planner-optimizer-tuplehashforliterals-function-tuplehashforliterals-literals-src-minisql-planner-optimizer-ml-893299664"></a>
### tupleHashForLiterals

```ml
function tupleHashForLiterals(literals)
```

Computes the persisted tuple hash used by multi-column MCV statistics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `literals` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L220)
