# `src/minisql/planner/logical_plan.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql planner logical plan facilities for this project.

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
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L113)

<a id="function-function-minisql-planner-logical-plan-componentname-function-componentname-src-minisql-planner-logical-plan-ml-526401252"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql planner logical plan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L185)

<a id="function-function-minisql-planner-logical-plan-fail-function-fail-code-operation-message-src-minisql-planner-logical-plan-ml-1793763211"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql planner logical plan module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L57)

<a id="function-function-minisql-planner-logical-plan-indent-function-indent-depth-src-minisql-planner-logical-plan-ml-1779106037"></a>
### indent

```ml
function indent(depth)
```

Implements indent for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depth` | `dynamic` | — | depth value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L145)

<a id="constant-constant-minisql-planner-logical-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-logical-plan-ml-2084805321"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Relational-algebra tree. Logical nodes contain semantics only; access paths


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L14)

<a id="function-function-minisql-planner-logical-plan-isimplemented-function-isimplemented-src-minisql-planner-logical-plan-ml-1150103636"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql planner logical plan module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L199)

<a id="function-function-minisql-planner-logical-plan-islogicalplan-function-islogicalplan-value-src-minisql-planner-logical-plan-ml-2093059229"></a>
### isLogicalPlan

```ml
function isLogicalPlan(value)
```

Returns whether the supplied value satisfies the logical plan condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L65)

<a id="function-function-minisql-planner-logical-plan-joinname-function-joinname-jointype-src-minisql-planner-logical-plan-ml-1814745364"></a>
### joinName

```ml
function joinName(joinType)
```

Implements join name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `joinType` | `dynamic` | — | joinType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L87)

- [minisql.planner.logical_plan.LogicalPlan](Type-minisql-planner-logical-plan-logicalplan-1962141215.md) — struct
<a id="function-function-minisql-planner-logical-plan-node-function-node-kind-name-details-estimatedrows-children-src-minisql-planner-logical-plan-ml-1264460925"></a>
### node

```ml
function node(kind, name, details, estimatedRows, children)
```

Implements node for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |
| `details` | `dynamic` | — | details value consumed by this operation. |
| `estimatedRows` | `dynamic` | — | estimatedRows value consumed by this operation. |
| `children` | `dynamic` | — | children value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L78)

<a id="constant-constant-minisql-planner-logical-plan-node-aggregate-const-node-aggregate-5-src-minisql-planner-logical-plan-ml-473091748"></a>
### NODE_AGGREGATE

```ml
const NODE_AGGREGATE = 5
```

Defines the node aggregate constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L25)

<a id="constant-constant-minisql-planner-logical-plan-node-distinct-const-node-distinct-7-src-minisql-planner-logical-plan-ml-1100229268"></a>
### NODE_DISTINCT

```ml
const NODE_DISTINCT = 7
```

Defines the node distinct constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L29)

<a id="constant-constant-minisql-planner-logical-plan-node-filter-const-node-filter-4-src-minisql-planner-logical-plan-ml-1712380653"></a>
### NODE_FILTER

```ml
const NODE_FILTER = 4
```

Defines the node filter constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L23)

<a id="constant-constant-minisql-planner-logical-plan-node-join-const-node-join-3-src-minisql-planner-logical-plan-ml-859523072"></a>
### NODE_JOIN

```ml
const NODE_JOIN = 3
```

Defines the node join constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L21)

<a id="constant-constant-minisql-planner-logical-plan-node-limit-const-node-limit-10-src-minisql-planner-logical-plan-ml-953856188"></a>
### NODE_LIMIT

```ml
const NODE_LIMIT = 10
```

Defines the node limit constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L35)

<a id="constant-constant-minisql-planner-logical-plan-node-project-const-node-project-6-src-minisql-planner-logical-plan-ml-1618517013"></a>
### NODE_PROJECT

```ml
const NODE_PROJECT = 6
```

Defines the node project constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L27)

<a id="constant-constant-minisql-planner-logical-plan-node-scan-const-node-scan-2-src-minisql-planner-logical-plan-ml-722631155"></a>
### NODE_SCAN

```ml
const NODE_SCAN = 2
```

Defines the node scan constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L19)

<a id="constant-constant-minisql-planner-logical-plan-node-set-const-node-set-8-src-minisql-planner-logical-plan-ml-1047055253"></a>
### NODE_SET

```ml
const NODE_SET = 8
```

Defines the node set constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L31)

<a id="constant-constant-minisql-planner-logical-plan-node-sort-const-node-sort-9-src-minisql-planner-logical-plan-ml-1761587918"></a>
### NODE_SORT

```ml
const NODE_SORT = 9
```

Defines the node sort constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L33)

<a id="constant-constant-minisql-planner-logical-plan-node-values-const-node-values-1-src-minisql-planner-logical-plan-ml-203625514"></a>
### NODE_VALUES

```ml
const NODE_VALUES = 1
```

Defines the node values constant used by the minisql planner logical plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L17)

<a id="function-function-minisql-planner-logical-plan-render-function-render-plan-src-minisql-planner-logical-plan-ml-372474821"></a>
### render

```ml
function render(plan)
```

Renders render using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — | plan value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L177)

<a id="function-function-minisql-planner-logical-plan-renderinto-function-renderinto-plan-depth-lines-src-minisql-planner-logical-plan-ml-209402609"></a>
### renderInto

```ml
function renderInto(plan, depth, lines)
```

Renders into using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — | plan value consumed by this operation. |
| `depth` | `dynamic` | — | depth value consumed by this operation. |
| `lines` | `dynamic` | — | lines value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L161)

<a id="function-function-minisql-planner-logical-plan-setname-function-setname-operator-all-src-minisql-planner-logical-plan-ml-1205155633"></a>
### setName

```ml
function setName(operator, all)
```

Implements set name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `all` | `dynamic` | — | all value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L100)

<a id="function-function-minisql-planner-logical-plan-targetmilestone-function-targetmilestone-src-minisql-planner-logical-plan-ml-1997098278"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql planner logical plan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/logical_plan.ml#L192)
