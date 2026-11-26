# `src/minisql/executor/routine_state.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.executor.routine_state`](Package-minisql-executor-routine-state-1941593749.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `std/string.ml` as `string_api` → `../MiniLangCompilerML/std/string.ml` — external dependency

## Declarations

- [minisql.executor.routine_state.CachedDefinition](Type-minisql-executor-routine-state-cacheddefinition-1257185410.md) — struct
<a id="function-function-minisql-executor-routine-state-characteristic-function-characteristic-characteristics-key-fallback-src-minisql-executor-routine-state-ml-625308347"></a>
### characteristic

```ml
function characteristic(characteristics, key, fallback)
```

Returns a routine characteristic, applying the caller's explicit default.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `characteristics` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `fallback` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L346)

<a id="function-function-minisql-executor-routine-state-characterlength-function-characterlength-textvalue-src-minisql-executor-routine-state-ml-513731022"></a>
### characterLength

```ml
function characterLength(textValue)
```

Counts Unicode scalar encodings, not UTF-8 bytes, for SQL character limits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L282)

<a id="function-function-minisql-executor-routine-state-characterprefix-function-characterprefix-textvalue-count-src-minisql-executor-routine-state-ml-1838241357"></a>
### characterPrefix

```ml
function characterPrefix(textValue, count)
```

Takes a valid UTF-8 prefix without cutting through a multibyte character.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L291)

<a id="function-function-minisql-executor-routine-state-cleardiagnostic-function-cleardiagnostic-rowcount-src-minisql-executor-routine-state-ml-1270697639"></a>
### clearDiagnostic

```ml
function clearDiagnostic(rowCount)
```

Creates an empty diagnostics area after a successful statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L193)

<a id="function-function-minisql-executor-routine-state-componentname-function-componentname-src-minisql-executor-routine-state-ml-342823562"></a>
### componentName

```ml
function componentName()
```

Returns the stable identity used by the repository's module inventory.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L572)

<a id="function-function-minisql-executor-routine-state-create-function-create-src-minisql-executor-routine-state-ml-1983435270"></a>
### create

```ml
function create()
```

Allocates isolated state for one engine connection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L198)

<a id="function-function-minisql-executor-routine-state-currentframe-function-currentframe-session-src-minisql-executor-routine-state-ml-619394816"></a>
### currentFrame

```ml
function currentFrame(session)
```

Returns the currently executing procedure, or void outside a CALL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L203)

- [minisql.executor.routine_state.Cursor](Type-minisql-executor-routine-state-cursor-1556064043.md) — struct
- [minisql.executor.routine_state.Diagnostic](Type-minisql-executor-routine-state-diagnostic-972157970.md) — struct
<a id="function-function-minisql-executor-routine-state-diagnosticvalue-function-diagnosticvalue-diagnostic-name-src-minisql-executor-routine-state-ml-650594782"></a>
### diagnosticValue

```ml
function diagnosticValue(diagnostic, name)
```

Exposes standard condition information without returning MiniLang void as SQL NULL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `diagnostic` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L426)

<a id="function-function-minisql-executor-routine-state-findcondition-function-findcondition-frame-name-src-minisql-executor-routine-state-ml-853723942"></a>
### findCondition

```ml
function findCondition(frame, name)
```

Resolves a named condition without leaking caller scopes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L319)

<a id="function-function-minisql-executor-routine-state-findcursor-function-findcursor-frame-name-src-minisql-executor-routine-state-ml-727416986"></a>
### findCursor

```ml
function findCursor(frame, name)
```

Finds a cursor in its closest enclosing scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L306)

<a id="function-function-minisql-executor-routine-state-findlocal-function-findlocal-frame-name-qualifier-src-minisql-executor-routine-state-ml-1372983984"></a>
### findLocal

```ml
function findLocal(frame, name, qualifier)
```

Looks up a local variable using lexical shadowing and optional block qualification.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `qualifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L227)

<a id="function-function-minisql-executor-routine-state-findqualifiedlocal-function-findqualifiedlocal-frame-name-src-minisql-executor-routine-state-ml-1506106246"></a>
### findQualifiedLocal

```ml
function findQualifiedLocal(frame, name)
```

Resolves assignment targets with the same label qualification as expression references.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L565)

<a id="function-function-minisql-executor-routine-state-findsessionvariable-function-findsessionvariable-session-name-src-minisql-executor-routine-state-ml-1035011959"></a>
### findSessionVariable

```ml
function findSessionVariable(session, name)
```

Looks up a session variable without creating it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L243)

- [minisql.executor.routine_state.Flow](Type-minisql-executor-routine-state-flow-629731233.md) — struct
- [minisql.executor.routine_state.Frame](Type-minisql-executor-routine-state-frame-428241938.md) — struct
<a id="function-function-minisql-executor-routine-state-fromerror-function-fromerror-nativeerror-src-minisql-executor-routine-state-ml-1491445"></a>
### fromError

```ml
function fromError(nativeError)
```

Converts a native engine error to a routine condition without guessing success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nativeError` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L370)

- [minisql.executor.routine_state.Handler](Type-minisql-executor-routine-state-handler-132936103.md) — struct
<a id="function-function-minisql-executor-routine-state-isimplemented-function-isimplemented-src-minisql-executor-routine-state-ml-2043570714"></a>
### isImplemented

```ml
function isImplemented()
```

Indicates that this module contains an implemented runtime contract.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L582)

<a id="function-function-minisql-executor-routine-state-isrecursionname-function-isrecursionname-name-src-minisql-executor-routine-state-ml-1504939677"></a>
### isRecursionName

```ml
function isRecursionName(name)
```

Resolves the supported system recursion setting in all accepted spellings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L256)

<a id="function-function-minisql-executor-routine-state-issessionname-function-issessionname-name-src-minisql-executor-routine-state-ml-890933125"></a>
### isSessionName

```ml
function isSessionName(name)
```

Identifies user and system variable spellings produced by the SQL lexer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L251)

<a id="function-function-minisql-executor-routine-state-matchpriority-function-matchpriority-condition-diagnostic-src-minisql-executor-routine-state-ml-41375516"></a>
### matchPriority

```ml
function matchPriority(condition, diagnostic)
```

Gives errno handlers priority over SQLSTATE and class within one scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — |  |
| `diagnostic` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L332)

<a id="function-function-minisql-executor-routine-state-mergediagnostics-function-mergediagnostics-original-current-src-minisql-executor-routine-state-ml-349987452"></a>
### mergeDiagnostics

```ml
function mergeDiagnostics(original, current)
```

Restores a stacked area and appends genuinely new handler conditions in ordinal order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `original` | `dynamic` | — |  |
| `current` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L587)

<a id="function-function-minisql-executor-routine-state-prefix-function-prefix-items-count-src-minisql-executor-routine-state-ml-1908962647"></a>
### prefix

```ml
function prefix(items, count)
```

Copies the first count array elements without sharing a mutable array container.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L216)

<a id="function-function-minisql-executor-routine-state-putcharacteristic-function-putcharacteristic-characteristics-key-value-src-minisql-executor-routine-state-ml-502520418"></a>
### putCharacteristic

```ml
function putCharacteristic(characteristics, key, value)
```

Replaces one characteristic while preserving the remaining declaration order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `characteristics` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L354)

<a id="function-function-minisql-executor-routine-state-raise-function-raise-session-sqlstate-errno-message-signaled-src-minisql-executor-routine-state-ml-342236801"></a>
### raise

```ml
function raise(session, sqlstate, errno, message, signaled)
```

Raises one explicit SQL condition; the interpreter consumes pending exactly once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — |  |
| `sqlstate` | `dynamic` | — |  |
| `errno` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |
| `signaled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L416)

<a id="function-function-minisql-executor-routine-state-remembercondition-function-remembercondition-session-diagnostic-src-minisql-executor-routine-state-ml-1391551493"></a>
### rememberCondition

```ml
function rememberCondition(session, diagnostic)
```

Retains conditions without allowing an unbounded warning-producing loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — |  |
| `diagnostic` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L273)

<a id="function-function-minisql-executor-routine-state-scope-function-scope-session-label-src-minisql-executor-routine-state-ml-1391595780"></a>
### scope

```ml
function scope(session, label)
```

Returns a fresh lexical scope with a stable EXIT destination.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L209)

- [minisql.executor.routine_state.Scope](Type-minisql-executor-routine-state-scope-1581782479.md) — struct
- [minisql.executor.routine_state.Session](Type-minisql-executor-routine-state-session-1458205123.md) — struct
<a id="function-function-minisql-executor-routine-state-systemname-function-systemname-name-src-minisql-executor-routine-state-ml-1398747991"></a>
### systemName

```ml
function systemName(name)
```

Normalizes supported unqualified and @@session/global system-variable names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L261)

<a id="function-function-minisql-executor-routine-state-targetmilestone-function-targetmilestone-src-minisql-executor-routine-state-ml-1726959036"></a>
### targetMilestone

```ml
function targetMilestone()
```

Associates procedure execution state with the stored-program milestone.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L577)

<a id="function-function-minisql-executor-routine-state-validatedefinition-function-validatedefinition-definition-src-minisql-executor-routine-state-ml-1544466257"></a>
### validateDefinition

```ml
function validateDefinition(definition)
```

Validates parameter types and the complete lexical structure without executing defaults or SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definition` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L551)

<a id="function-function-minisql-executor-routine-state-validatenode-function-validatenode-statement-frame-labels-src-minisql-executor-routine-state-ml-1544050705"></a>
### validateNode

```ml
function validateNode(statement, frame, labels)
```

Checks lexical declarations and jump destinations before any definition is persisted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L445)

- [minisql.executor.routine_state.Variable](Type-minisql-executor-routine-state-variable-170010473.md) — struct
