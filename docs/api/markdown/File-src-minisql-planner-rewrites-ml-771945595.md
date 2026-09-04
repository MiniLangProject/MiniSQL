# `src/minisql/planner/rewrites.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql planner rewrites facilities for this project.

Package: [`minisql.planner.rewrites`](Package-minisql-planner-rewrites-1685585919.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)

## Declarations

<a id="function-function-minisql-planner-rewrites-clamprows-function-clamprows-value-src-minisql-planner-rewrites-ml-1029653097"></a>
### clampRows

```ml
function clampRows(value)
```

Implements clamp rows for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L59)

<a id="function-function-minisql-planner-rewrites-collectcolumnindexes-function-collectcolumnindexes-expression-indexes-src-minisql-planner-rewrites-ml-121446924"></a>
### collectColumnIndexes

```ml
function collectColumnIndexes(expression, indexes)
```

Collects every bound column index referenced by an expression. Returning false for an unknown expression shape deliberately disables pushdown rather than risking a semantic change when the SQL surface grows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `indexes` | `dynamic` | — | indexes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L179)

<a id="function-function-minisql-planner-rewrites-collectequalitylinks-function-collectequalitylinks-expression-links-columntypes-src-minisql-planner-rewrites-ml-970187818"></a>
### collectEqualityLinks

```ml
function collectEqualityLinks(expression, links, columnTypes)
```

Adds undirected column-equality edges from top-level AND conjuncts. Bound column types are retained so propagated constants can construct typed source predicates without returning to parser or catalog representations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `links` | `dynamic` | — | links value consumed by this operation. |
| `columnTypes` | `dynamic` | — | columnTypes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L410)

<a id="function-function-minisql-planner-rewrites-combineconjuncts-function-combineconjuncts-items-src-minisql-planner-rewrites-ml-1736632870"></a>
### combineConjuncts

```ml
function combineConjuncts(items)
```

Reassembles predicates with SQL boolean semantics intact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L393)

<a id="function-function-minisql-planner-rewrites-comparisonconstraint-function-comparisonconstraint-expression-src-minisql-planner-rewrites-ml-540308798"></a>
### comparisonConstraint

```ml
function comparisonConstraint(expression)
```

Normalizes a column/literal comparison so the column is always on the left.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L312)

<a id="function-function-minisql-planner-rewrites-comparisonforcolumn-function-comparisonforcolumn-expression-columnindex-src-minisql-planner-rewrites-ml-395864058"></a>
### comparisonForColumn

```ml
function comparisonForColumn(expression, columnIndex)
```

Finds a column/literal comparison inside a conjunction. The returned tuple is [found, normalized operator, literal].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `columnIndex` | `dynamic` | — | Zero-based index of column. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L581)

<a id="function-function-minisql-planner-rewrites-comparisonforexpression-function-comparisonforexpression-expression-keyexpression-src-minisql-planner-rewrites-ml-2103306959"></a>
### comparisonForExpression

```ml
function comparisonForExpression(expression, keyExpression)
```

Finds a literal comparison whose other side matches one bound key expression.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `keyExpression` | `dynamic` | — | keyExpression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L601)

<a id="function-function-minisql-planner-rewrites-comparisonimplies-function-comparisonimplies-candidate-required-src-minisql-planner-rewrites-ml-1534288998"></a>
### comparisonImplies

```ml
function comparisonImplies(candidate, required)
```

Proves implication between two normalized single-column literal bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `candidate` | `dynamic` | — | candidate value consumed by this operation. |
| `required` | `dynamic` | — | required value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L330)

<a id="function-function-minisql-planner-rewrites-componentname-function-componentname-src-minisql-planner-rewrites-ml-2077108724"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql planner rewrites module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L621)

<a id="function-function-minisql-planner-rewrites-conjunctimplies-function-conjunctimplies-candidate-required-src-minisql-planner-rewrites-ml-1011735312"></a>
### conjunctImplies

```ml
function conjunctImplies(candidate, required)
```

Proves one required conjunct from one query conjunct without widening either.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `candidate` | `dynamic` | — | candidate value consumed by this operation. |
| `required` | `dynamic` | — | required value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L361)

<a id="function-function-minisql-planner-rewrites-conjuncts-function-conjuncts-expression-src-minisql-planner-rewrites-ml-351260916"></a>
### conjuncts

```ml
function conjuncts(expression)
```

Flattens an AND tree without changing the relative order of predicates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L296)

<a id="function-function-minisql-planner-rewrites-constantwhereempty-function-constantwhereempty-expression-src-minisql-planner-rewrites-ml-1192668918"></a>
### constantWhereEmpty

```ml
function constantWhereEmpty(expression)
```

Recognizes a literal WHERE that can never pass SQL's three-valued predicate test. It is safe to replace the source with an empty relation even for a global aggregate, whose aggregate operator will still emit its empty-group result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L572)

<a id="function-function-minisql-planner-rewrites-disjuncts-function-disjuncts-expression-src-minisql-planner-rewrites-ml-41439360"></a>
### disjuncts

```ml
function disjuncts(expression)
```

Flattens an OR tree without changing predicate order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L304)

<a id="function-function-minisql-planner-rewrites-estimatefilteredrows-function-estimatefilteredrows-inputrows-predicate-src-minisql-planner-rewrites-ml-738482154"></a>
### estimateFilteredRows

```ml
function estimateFilteredRows(inputRows, predicate)
```

Estimates filtered rows using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputRows` | `dynamic` | — | inputRows value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L120)

<a id="function-function-minisql-planner-rewrites-fail-function-fail-code-operation-message-src-minisql-planner-rewrites-ml-1069889835"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql planner rewrites module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L26)

<a id="function-function-minisql-planner-rewrites-intcontains-function-intcontains-items-value-src-minisql-planner-rewrites-ml-947223371"></a>
### intContains

```ml
function intContains(items, value)
```

Reports whether an integer array contains the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L265)

<a id="function-function-minisql-planner-rewrites-integerdivide-function-integerdivide-numerator-denominator-src-minisql-planner-rewrites-ml-117240041"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Implements integer divide for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — | numerator value consumed by this operation. |
| `denominator` | `dynamic` | — | denominator value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L36)

<a id="constant-constant-minisql-planner-rewrites-invalid-argument-const-invalid-argument-9001-src-minisql-planner-rewrites-ml-3106677"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Safe, semantics-preserving planner rewrites and selectivity helpers. Literal


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L18)

<a id="function-function-minisql-planner-rewrites-iscolumnequality-function-iscolumnequality-expression-src-minisql-planner-rewrites-ml-1175038654"></a>
### isColumnEquality

```ml
function isColumnEquality(expression)
```

Returns whether the supplied value satisfies the column equality condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L69)

<a id="function-function-minisql-planner-rewrites-isconstantboolean-function-isconstantboolean-expression-expected-src-minisql-planner-rewrites-ml-547535222"></a>
### isConstantBoolean

```ml
function isConstantBoolean(expression, expected)
```

Returns whether the supplied value satisfies the constant boolean condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L82)

<a id="function-function-minisql-planner-rewrites-isimplemented-function-isimplemented-src-minisql-planner-rewrites-ml-1736727980"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql planner rewrites module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L635)

<a id="function-function-minisql-planner-rewrites-predicatebucketcontains-function-predicatebucketcontains-bucket-predicate-src-minisql-planner-rewrites-ml-597515155"></a>
### predicateBucketContains

```ml
function predicateBucketContains(bucket, predicate)
```

Reports whether one predicate bucket already contains the same typed binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bucket` | `dynamic` | — | bucket value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L428)

<a id="function-function-minisql-planner-rewrites-predicateimplies-function-predicateimplies-querypredicate-requiredpredicate-src-minisql-planner-rewrites-ml-1041132329"></a>
### predicateImplies

```ml
function predicateImplies(queryPredicate, requiredPredicate)
```

Proves the deliberately bounded partial-index implication contract. Every required index conjunct must occur identically or follow from a stronger typed single-column literal bound in the query predicate. This recognizes additional/reordered conjuncts without general Boolean theorem proving.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `queryPredicate` | `dynamic` | — | queryPredicate value consumed by this operation. |
| `requiredPredicate` | `dynamic` | — | requiredPredicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L377)

<a id="function-function-minisql-planner-rewrites-propagatejoinconstants-function-propagatejoinconstants-whereexpression-sources-joins-buckets-src-minisql-planner-rewrites-ml-1172367303"></a>
### propagateJoinConstants

```ml
function propagateJoinConstants(whereExpression, sources, joins, buckets)
```

Propagates non-NULL equality constants through INNER/CROSS join equality classes. The inferred expressions are execution hints only: the original WHERE remains the final semantic guard and outer joins are never rewritten.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `whereExpression` | `dynamic` | — | whereExpression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `joins` | `dynamic` | — | joins value consumed by this operation. |
| `buckets` | `dynamic` | — | buckets value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L443)

<a id="function-function-minisql-planner-rewrites-pushdownsafe-function-pushdownsafe-expression-src-minisql-planner-rewrites-ml-1057999826"></a>
### pushdownSafe

```ml
function pushdownSafe(expression)
```

Predicate pushdown must not duplicate observable evaluation of volatile nested query expressions. Deterministic scalar and cast trees are safe when each argument is itself source-local, which also enables functional indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L502)

<a id="function-function-minisql-planner-rewrites-referencedsources-function-referencedsources-expression-sources-src-minisql-planner-rewrites-ml-2074529508"></a>
### referencedSources

```ml
function referencedSources(expression, sources)
```

Returns the unique source indexes referenced by an expression, or void when a newly introduced expression shape cannot be analyzed conservatively.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L276)

<a id="function-function-minisql-planner-rewrites-residualpredicate-function-residualpredicate-whereexpression-sources-joins-src-minisql-planner-rewrites-ml-434186448"></a>
### residualPredicate

```ml
function residualPredicate(whereExpression, sources, joins)
```

Returns the WHERE conjuncts that could not be assigned to a safe source pushdown. The executor still evaluates the complete simplified WHERE as a correctness guard; this residual is used for cardinality and cost only.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `whereExpression` | `dynamic` | — | whereExpression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `joins` | `dynamic` | — | joins value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L556)

<a id="function-function-minisql-planner-rewrites-selectivitypermille-function-selectivitypermille-expression-src-minisql-planner-rewrites-ml-1293299572"></a>
### selectivityPermille

```ml
function selectivityPermille(expression)
```

Implements selectivity permille for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L92)

<a id="function-function-minisql-planner-rewrites-simplify-function-simplify-expression-src-minisql-planner-rewrites-ml-588072394"></a>
### simplify

```ml
function simplify(expression)
```

Folds deterministic literal-only base expressions and left-hand boolean identities. Restricting identities to the evaluator's short-circuit side preserves the observable behavior of volatile scalar functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L132)

<a id="function-function-minisql-planner-rewrites-singlesource-function-singlesource-expression-sources-src-minisql-planner-rewrites-ml-1592355262"></a>
### singleSource

```ml
function singleSource(expression, sources)
```

Maps an expression to its sole source, -1 for a constant, or -2 when the expression spans sources or cannot be analyzed safely.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L243)

<a id="function-function-minisql-planner-rewrites-sourcepredicates-function-sourcepredicates-whereexpression-sources-joins-src-minisql-planner-rewrites-ml-1176130900"></a>
### sourcePredicates

```ml
function sourcePredicates(whereExpression, sources, joins)
```

Returns one safe per-source predicate. Pushdown is initially limited to inner/cross join trees; outer-join NULL extension requires a dedicated null-rejection proof and therefore keeps the original WHERE placement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `whereExpression` | `dynamic` | — | whereExpression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `joins` | `dynamic` | — | joins value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L526)

<a id="function-function-minisql-planner-rewrites-targetmilestone-function-targetmilestone-src-minisql-planner-rewrites-ml-1260548874"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql planner rewrites module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/rewrites.ml#L628)
