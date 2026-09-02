# `src/minisql/planner/logical_plan.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.planner.logical_plan`](Package-minisql-planner-logical-plan-143884465.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)

## Declarations

<a id="function-function-minisql-planner-logical-plan-build-function-build-bound-src-minisql-planner-logical-plan-ml-35511694"></a>
### build

```ml
function build(bound)
```

Builds build using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L89)

<a id="function-function-minisql-planner-logical-plan-componentname-function-componentname-src-minisql-planner-logical-plan-ml-526401252"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L156)

<a id="function-function-minisql-planner-logical-plan-fail-function-fail-code-operation-message-src-minisql-planner-logical-plan-ml-1793763211"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L43)

<a id="function-function-minisql-planner-logical-plan-indent-function-indent-depth-src-minisql-planner-logical-plan-ml-1779106037"></a>
### indent

```ml
function indent(depth)
```

Implements indent for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L120)

<a id="constant-constant-minisql-planner-logical-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-logical-plan-ml-2084805321"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Relational-algebra tree. Logical nodes contain semantics only; access paths and concrete algorithms are chosen by physical_plan/optimizer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L13)

<a id="function-function-minisql-planner-logical-plan-isimplemented-function-isimplemented-src-minisql-planner-logical-plan-ml-1150103636"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L170)

<a id="function-function-minisql-planner-logical-plan-islogicalplan-function-islogicalplan-value-src-minisql-planner-logical-plan-ml-2093059229"></a>
### isLogicalPlan

```ml
function isLogicalPlan(value)
```

Returns whether the supplied value satisfies the logical plan condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L50)

<a id="function-function-minisql-planner-logical-plan-joinname-function-joinname-jointype-src-minisql-planner-logical-plan-ml-1814745364"></a>
### joinName

```ml
function joinName(joinType)
```

Implements join name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `joinType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L66)

- [minisql.planner.logical_plan.LogicalPlan](Type-minisql-planner-logical-plan-logicalplan-1962141215.md) — struct
<a id="function-function-minisql-planner-logical-plan-node-function-node-kind-name-details-estimatedrows-children-src-minisql-planner-logical-plan-ml-1264460925"></a>
### node

```ml
function node(kind, name, details, estimatedRows, children)
```

Implements node for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `details` | `dynamic` | — |  |
| `estimatedRows` | `dynamic` | — |  |
| `children` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L58)

<a id="constant-constant-minisql-planner-logical-plan-node-aggregate-const-node-aggregate-5-src-minisql-planner-logical-plan-ml-473091748"></a>
### NODE_AGGREGATE

```ml
const NODE_AGGREGATE = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L19)

<a id="constant-constant-minisql-planner-logical-plan-node-distinct-const-node-distinct-7-src-minisql-planner-logical-plan-ml-1100229268"></a>
### NODE_DISTINCT

```ml
const NODE_DISTINCT = 7
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L21)

<a id="constant-constant-minisql-planner-logical-plan-node-filter-const-node-filter-4-src-minisql-planner-logical-plan-ml-1712380653"></a>
### NODE_FILTER

```ml
const NODE_FILTER = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L18)

<a id="constant-constant-minisql-planner-logical-plan-node-join-const-node-join-3-src-minisql-planner-logical-plan-ml-859523072"></a>
### NODE_JOIN

```ml
const NODE_JOIN = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L17)

<a id="constant-constant-minisql-planner-logical-plan-node-limit-const-node-limit-10-src-minisql-planner-logical-plan-ml-953856188"></a>
### NODE_LIMIT

```ml
const NODE_LIMIT = 10
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L24)

<a id="constant-constant-minisql-planner-logical-plan-node-project-const-node-project-6-src-minisql-planner-logical-plan-ml-1618517013"></a>
### NODE_PROJECT

```ml
const NODE_PROJECT = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L20)

<a id="constant-constant-minisql-planner-logical-plan-node-scan-const-node-scan-2-src-minisql-planner-logical-plan-ml-722631155"></a>
### NODE_SCAN

```ml
const NODE_SCAN = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L16)

<a id="constant-constant-minisql-planner-logical-plan-node-set-const-node-set-8-src-minisql-planner-logical-plan-ml-1047055253"></a>
### NODE_SET

```ml
const NODE_SET = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L22)

<a id="constant-constant-minisql-planner-logical-plan-node-sort-const-node-sort-9-src-minisql-planner-logical-plan-ml-1761587918"></a>
### NODE_SORT

```ml
const NODE_SORT = 9
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L23)

<a id="constant-constant-minisql-planner-logical-plan-node-values-const-node-values-1-src-minisql-planner-logical-plan-ml-203625514"></a>
### NODE_VALUES

```ml
const NODE_VALUES = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L15)

<a id="function-function-minisql-planner-logical-plan-render-function-render-plan-src-minisql-planner-logical-plan-ml-372474821"></a>
### render

```ml
function render(plan)
```

Renders render using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L148)

<a id="function-function-minisql-planner-logical-plan-renderinto-function-renderinto-plan-depth-lines-src-minisql-planner-logical-plan-ml-209402609"></a>
### renderInto

```ml
function renderInto(plan, depth, lines)
```

Renders into using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — |  |
| `depth` | `dynamic` | — |  |
| `lines` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L133)

<a id="function-function-minisql-planner-logical-plan-setname-function-setname-operator-all-src-minisql-planner-logical-plan-ml-1205155633"></a>
### setName

```ml
function setName(operator, all)
```

Implements set name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — |  |
| `all` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L77)

<a id="function-function-minisql-planner-logical-plan-targetmilestone-function-targetmilestone-src-minisql-planner-logical-plan-ml-1997098278"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L163)
