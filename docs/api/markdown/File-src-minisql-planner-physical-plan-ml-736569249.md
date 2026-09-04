# `src/minisql/planner/physical_plan.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql planner physical plan facilities for this project.

Package: [`minisql.planner.physical_plan`](Package-minisql-planner-physical-plan-1950188103.md)

Reachable from entry: **yes**

## Imports

- `minisql/planner/logical_plan.ml` as `logical_plan` → [src/minisql/planner/logical_plan.ml](File-src-minisql-planner-logical-plan-ml-661531493.md)

## Declarations

<a id="function-function-minisql-planner-physical-plan-componentname-function-componentname-src-minisql-planner-physical-plan-ml-122324272"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql planner physical plan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L116)

<a id="function-function-minisql-planner-physical-plan-fail-function-fail-code-operation-message-src-minisql-planner-physical-plan-ml-1544624945"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql planner physical plan module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L35)

<a id="function-function-minisql-planner-physical-plan-fromlogical-function-fromlogical-plan-src-minisql-planner-physical-plan-ml-1521038681"></a>
### fromLogical

```ml
function fromLogical(plan)
```

Implements from logical for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — | plan value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L60)

<a id="function-function-minisql-planner-physical-plan-indent-function-indent-depth-src-minisql-planner-physical-plan-ml-813122451"></a>
### indent

```ml
function indent(depth)
```

Implements indent for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depth` | `dynamic` | — | depth value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L76)

<a id="constant-constant-minisql-planner-physical-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-physical-plan-ml-1506132383"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Concrete executable-plan description. M16 maps relational operators to safe


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L13)

<a id="function-function-minisql-planner-physical-plan-isimplemented-function-isimplemented-src-minisql-planner-physical-plan-ml-1387469912"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql planner physical plan module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L130)

<a id="function-function-minisql-planner-physical-plan-operatorfor-function-operatorfor-kind-src-minisql-planner-physical-plan-ml-1439792656"></a>
### operatorFor

```ml
function operatorFor(kind)
```

Implements operator for for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L43)

- [minisql.planner.physical_plan.PhysicalPlan](Type-minisql-planner-physical-plan-physicalplan-979510517.md) — struct
<a id="function-function-minisql-planner-physical-plan-render-function-render-plan-src-minisql-planner-physical-plan-ml-1635024843"></a>
### render

```ml
function render(plan)
```

Renders render using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — | plan value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L108)

<a id="function-function-minisql-planner-physical-plan-renderinto-function-renderinto-plan-depth-lines-src-minisql-planner-physical-plan-ml-1749439735"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L92)

<a id="function-function-minisql-planner-physical-plan-targetmilestone-function-targetmilestone-src-minisql-planner-physical-plan-ml-1119677282"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql planner physical plan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L123)
