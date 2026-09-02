# `src/minisql/planner/physical_plan.ml`

[Home](README.md) · [Files](Files.md)

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

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L105)

<a id="function-function-minisql-planner-physical-plan-fail-function-fail-code-operation-message-src-minisql-planner-physical-plan-ml-1544624945"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L31)

<a id="function-function-minisql-planner-physical-plan-fromlogical-function-fromlogical-plan-src-minisql-planner-physical-plan-ml-1521038681"></a>
### fromLogical

```ml
function fromLogical(plan)
```

Implements from logical for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L54)

<a id="function-function-minisql-planner-physical-plan-indent-function-indent-depth-src-minisql-planner-physical-plan-ml-813122451"></a>
### indent

```ml
function indent(depth)
```

Implements indent for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L69)

<a id="constant-constant-minisql-planner-physical-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-physical-plan-ml-1506132383"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Concrete executable-plan description. M16 maps relational operators to safe baseline algorithms; M17 may substitute cheaper access paths using statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L12)

<a id="function-function-minisql-planner-physical-plan-isimplemented-function-isimplemented-src-minisql-planner-physical-plan-ml-1387469912"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L119)

<a id="function-function-minisql-planner-physical-plan-operatorfor-function-operatorfor-kind-src-minisql-planner-physical-plan-ml-1439792656"></a>
### operatorFor

```ml
function operatorFor(kind)
```

Implements operator for for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L38)

- [minisql.planner.physical_plan.PhysicalPlan](Type-minisql-planner-physical-plan-physicalplan-979510517.md) — struct
<a id="function-function-minisql-planner-physical-plan-render-function-render-plan-src-minisql-planner-physical-plan-ml-1635024843"></a>
### render

```ml
function render(plan)
```

Renders render using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L97)

<a id="function-function-minisql-planner-physical-plan-renderinto-function-renderinto-plan-depth-lines-src-minisql-planner-physical-plan-ml-1749439735"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L82)

<a id="function-function-minisql-planner-physical-plan-targetmilestone-function-targetmilestone-src-minisql-planner-physical-plan-ml-1119677282"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/physical_plan.ml#L112)
