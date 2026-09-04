# `src/minisql/sql/types.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql types facilities for this project.

Package: [`minisql.sql.types`](Package-minisql-sql-types-1525453495.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)

## Declarations

<a id="constant-constant-minisql-sql-types-binding-error-const-binding-error-9020-src-minisql-sql-types-ml-166499176"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```

Defines the binding error constant used by the minisql sql types module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L16)

<a id="function-function-minisql-sql-types-canassign-function-canassign-source-target-src-minisql-sql-types-ml-1828095526"></a>
### canAssign

```ml
function canAssign(source, target)
```

Returns whether the supplied value satisfies the assign condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `target` | `dynamic` | — | target value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L304)

<a id="function-function-minisql-sql-types-commonnumeric-function-commonnumeric-left-right-src-minisql-sql-types-ml-829139855"></a>
### commonNumeric

```ml
function commonNumeric(left, right)
```

Implements common numeric for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L281)

<a id="function-function-minisql-sql-types-comparable-function-comparable-left-right-src-minisql-sql-types-ml-386719523"></a>
### comparable

```ml
function comparable(left, right)
```

Implements comparable for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L326)

<a id="function-function-minisql-sql-types-componentname-function-componentname-src-minisql-sql-types-ml-338189600"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql types module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L338)

<a id="function-function-minisql-sql-types-create-function-create-kind-length-precision-scale-nullable-src-minisql-sql-types-ml-715572705"></a>
### create

```ml
function create(kind, length, precision, scale, nullable)
```

Creates create for the minisql sql types module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |
| `length` | `dynamic` | — | length value consumed by this operation. |
| `precision` | `dynamic` | — | precision value consumed by this operation. |
| `scale` | `dynamic` | — | scale value consumed by this operation. |
| `nullable` | `dynamic` | — | nullable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L108)

<a id="function-function-minisql-sql-types-fail-function-fail-code-operation-message-src-minisql-sql-types-ml-159536105"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql sql types module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L78)

<a id="function-function-minisql-sql-types-fromcolumn-function-fromcolumn-column-src-minisql-sql-types-ml-1350218350"></a>
### fromColumn

```ml
function fromColumn(column)
```

Implements from column for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `column` | `dynamic` | — | column value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L204)

<a id="function-function-minisql-sql-types-fromtypename-function-fromtypename-typename-nullable-src-minisql-sql-types-ml-842400726"></a>
### fromTypeName

```ml
function fromTypeName(typeName, nullable)
```

Implements from type name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeName` | `dynamic` | — | typeName value consumed by this operation. |
| `nullable` | `dynamic` | — | nullable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L163)

<a id="constant-constant-minisql-sql-types-invalid-argument-const-invalid-argument-9001-src-minisql-sql-types-ml-1119706683"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql sql types module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L12)

<a id="function-function-minisql-sql-types-isbinarykind-function-isbinarykind-kind-src-minisql-sql-types-ml-169006622"></a>
### isBinaryKind

```ml
function isBinaryKind(kind)
```

Returns whether the supplied value satisfies the binary kind condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L246)

<a id="function-function-minisql-sql-types-isimplemented-function-isimplemented-src-minisql-sql-types-ml-1804958216"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql types module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L352)

<a id="function-function-minisql-sql-types-isintegralkind-function-isintegralkind-kind-src-minisql-sql-types-ml-1163157310"></a>
### isIntegralKind

```ml
function isIntegralKind(kind)
```

Returns whether the supplied value satisfies the integral kind condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L230)

<a id="function-function-minisql-sql-types-isnumeric-function-isnumeric-value-src-minisql-sql-types-ml-1826020421"></a>
### isNumeric

```ml
function isNumeric(value)
```

Returns whether the supplied value satisfies the numeric condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L213)

<a id="function-function-minisql-sql-types-isnumerickind-function-isnumerickind-kind-src-minisql-sql-types-ml-2017142596"></a>
### isNumericKind

```ml
function isNumericKind(kind)
```

Returns whether the supplied value satisfies the numeric kind condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L222)

<a id="function-function-minisql-sql-types-issqltype-function-issqltype-value-src-minisql-sql-types-ml-1425719963"></a>
### isSqlType

```ml
function isSqlType(value)
```

Returns whether the supplied value satisfies the SQL type condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L86)

<a id="function-function-minisql-sql-types-istextkind-function-istextkind-kind-src-minisql-sql-types-ml-1055756910"></a>
### isTextKind

```ml
function isTextKind(kind)
```

Returns whether the supplied value satisfies the text kind condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L238)

<a id="function-function-minisql-sql-types-kindname-function-kindname-kind-src-minisql-sql-types-ml-117751850"></a>
### kindName

```ml
function kindName(kind)
```

Implements kind name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L138)

<a id="function-function-minisql-sql-types-numericrank-function-numericrank-kind-src-minisql-sql-types-ml-555960800"></a>
### numericRank

```ml
function numericRank(kind)
```

Implements numeric rank for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L265)

<a id="function-function-minisql-sql-types-samebase-function-samebase-left-right-src-minisql-sql-types-ml-2034679663"></a>
### sameBase

```ml
function sameBase(left, right)
```

Implements same base for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L256)

- [minisql.sql.types.SqlType](Type-minisql-sql-types-sqltype-334036941.md) — struct
- [minisql.sql.types.SqlTypeKind](Type-minisql-sql-types-sqltypekind-84723867.md) — enum
<a id="function-function-minisql-sql-types-targetmilestone-function-targetmilestone-src-minisql-sql-types-ml-1883073302"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql types module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L345)

<a id="constant-constant-minisql-sql-types-type-mismatch-const-type-mismatch-9017-src-minisql-sql-types-ml-1291332290"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```

Defines the type mismatch constant used by the minisql sql types module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L14)

<a id="function-function-minisql-sql-types-validkind-function-validkind-kind-src-minisql-sql-types-ml-639223374"></a>
### validKind

```ml
function validKind(kind)
```

Implements valid kind for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L95)

<a id="function-function-minisql-sql-types-withnullable-function-withnullable-value-nullable-src-minisql-sql-types-ml-1301055790"></a>
### withNullable

```ml
function withNullable(value, nullable)
```

Implements with nullable for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `nullable` | `dynamic` | — | nullable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L129)
