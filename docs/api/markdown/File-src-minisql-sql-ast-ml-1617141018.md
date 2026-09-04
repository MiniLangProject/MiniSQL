# `src/minisql/sql/ast.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql ast facilities for this project.

Package: [`minisql.sql.ast`](Package-minisql-sql-ast-313758762.md)

Reachable from entry: **yes**

## Declarations

<a id="constant-constant-minisql-sql-ast-alter-table-add-column-const-alter-table-add-column-1-src-minisql-sql-ast-ml-1778310820"></a>
### ALTER_TABLE_ADD_COLUMN

```ml
const ALTER_TABLE_ADD_COLUMN = 1
```

Defines the alter table add column constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L110)

<a id="constant-constant-minisql-sql-ast-alter-table-add-constraint-const-alter-table-add-constraint-4-src-minisql-sql-ast-ml-748055927"></a>
### ALTER_TABLE_ADD_CONSTRAINT

```ml
const ALTER_TABLE_ADD_CONSTRAINT = 4
```

Defines the alter table add constraint constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L116)

<a id="constant-constant-minisql-sql-ast-alter-table-drop-column-const-alter-table-drop-column-6-src-minisql-sql-ast-ml-2135584673"></a>
### ALTER_TABLE_DROP_COLUMN

```ml
const ALTER_TABLE_DROP_COLUMN = 6
```

Defines the alter table drop column constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L120)

<a id="constant-constant-minisql-sql-ast-alter-table-drop-constraint-const-alter-table-drop-constraint-5-src-minisql-sql-ast-ml-1699572130"></a>
### ALTER_TABLE_DROP_CONSTRAINT

```ml
const ALTER_TABLE_DROP_CONSTRAINT = 5
```

Defines the alter table drop constraint constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L118)

<a id="constant-constant-minisql-sql-ast-alter-table-drop-default-const-alter-table-drop-default-8-src-minisql-sql-ast-ml-1868763959"></a>
### ALTER_TABLE_DROP_DEFAULT

```ml
const ALTER_TABLE_DROP_DEFAULT = 8
```

Defines the alter table drop default constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L124)

<a id="constant-constant-minisql-sql-ast-alter-table-drop-not-null-const-alter-table-drop-not-null-10-src-minisql-sql-ast-ml-1302119716"></a>
### ALTER_TABLE_DROP_NOT_NULL

```ml
const ALTER_TABLE_DROP_NOT_NULL = 10
```

Defines the alter table drop not null constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L128)

<a id="constant-constant-minisql-sql-ast-alter-table-rename-column-const-alter-table-rename-column-2-src-minisql-sql-ast-ml-1545450233"></a>
### ALTER_TABLE_RENAME_COLUMN

```ml
const ALTER_TABLE_RENAME_COLUMN = 2
```

Defines the alter table rename column constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L112)

<a id="constant-constant-minisql-sql-ast-alter-table-rename-table-const-alter-table-rename-table-3-src-minisql-sql-ast-ml-1021059132"></a>
### ALTER_TABLE_RENAME_TABLE

```ml
const ALTER_TABLE_RENAME_TABLE = 3
```

Defines the alter table rename table constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L114)

<a id="constant-constant-minisql-sql-ast-alter-table-set-default-const-alter-table-set-default-7-src-minisql-sql-ast-ml-993683288"></a>
### ALTER_TABLE_SET_DEFAULT

```ml
const ALTER_TABLE_SET_DEFAULT = 7
```

Defines the alter table set default constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L122)

<a id="constant-constant-minisql-sql-ast-alter-table-set-not-null-const-alter-table-set-not-null-9-src-minisql-sql-ast-ml-471830140"></a>
### ALTER_TABLE_SET_NOT_NULL

```ml
const ALTER_TABLE_SET_NOT_NULL = 9
```

Defines the alter table set not null constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L126)

<a id="constant-constant-minisql-sql-ast-alter-user-disable-const-alter-user-disable-3-src-minisql-sql-ast-ml-309882380"></a>
### ALTER_USER_DISABLE

```ml
const ALTER_USER_DISABLE = 3
```

Defines the alter user disable constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L103)

<a id="constant-constant-minisql-sql-ast-alter-user-enable-const-alter-user-enable-2-src-minisql-sql-ast-ml-598432337"></a>
### ALTER_USER_ENABLE

```ml
const ALTER_USER_ENABLE = 2
```

Defines the alter user enable constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L101)

<a id="constant-constant-minisql-sql-ast-alter-user-password-const-alter-user-password-1-src-minisql-sql-ast-ml-425343302"></a>
### ALTER_USER_PASSWORD

```ml
const ALTER_USER_PASSWORD = 1
```

Defines the alter user password constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L99)

- [minisql.sql.ast.AlterTableStatement](Type-minisql-sql-ast-altertablestatement-1207466245.md) — struct
- [minisql.sql.ast.AlterTriggerStatement](Type-minisql-sql-ast-altertriggerstatement-43120821.md) — struct
- [minisql.sql.ast.AlterUserStatement](Type-minisql-sql-ast-alteruserstatement-1282601084.md) — struct
- [minisql.sql.ast.AnalyzeStatement](Type-minisql-sql-ast-analyzestatement-2053213101.md) — struct
- [minisql.sql.ast.Assignment](Type-minisql-sql-ast-assignment-231088629.md) — struct
- [minisql.sql.ast.BeginStatement](Type-minisql-sql-ast-beginstatement-191052114.md) — struct
<a id="function-function-minisql-sql-ast-betweenexpression-function-betweenexpression-operand-lower-upper-negated-src-minisql-sql-ast-ml-1793467478"></a>
### betweenExpression

```ml
function betweenExpression(operand, lower, upper, negated)
```

Implements between expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `lower` | `dynamic` | — | lower value consumed by this operation. |
| `upper` | `dynamic` | — | upper value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1158)

- [minisql.sql.ast.BetweenExpression](Type-minisql-sql-ast-betweenexpression-1728802310.md) — struct
<a id="function-function-minisql-sql-ast-binaryexpression-function-binaryexpression-operator-left-right-src-minisql-sql-ast-ml-375397191"></a>
### binaryExpression

```ml
function binaryExpression(operator, left, right)
```

Implements binary expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1064)

- [minisql.sql.ast.BinaryExpression](Type-minisql-sql-ast-binaryexpression-2105074591.md) — struct
<a id="function-function-minisql-sql-ast-booleanliteral-function-booleanliteral-value-src-minisql-sql-ast-ml-1072649271"></a>
### booleanLiteral

```ml
function booleanLiteral(value)
```

Implements boolean literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L997)

- [minisql.sql.ast.CallStatement](Type-minisql-sql-ast-callstatement-75468089.md) — struct
<a id="function-function-minisql-sql-ast-casebranch-function-casebranch-condition-result-src-minisql-sql-ast-ml-1393747230"></a>
### caseBranch

```ml
function caseBranch(condition, result)
```

Implements case branch for this module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — | condition value consumed by this operation. |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1104)

- [minisql.sql.ast.CaseBranch](Type-minisql-sql-ast-casebranch-776387952.md) — struct
<a id="function-function-minisql-sql-ast-caseexpression-function-caseexpression-branches-elseexpression-src-minisql-sql-ast-ml-1204552305"></a>
### caseExpression

```ml
function caseExpression(branches, elseExpression)
```

Implements case expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `branches` | `dynamic` | — | branches value consumed by this operation. |
| `elseExpression` | `dynamic` | — | elseExpression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1115)

- [minisql.sql.ast.CaseExpression](Type-minisql-sql-ast-caseexpression-1743911362.md) — struct
<a id="function-function-minisql-sql-ast-castexpression-function-castexpression-operand-targettype-src-minisql-sql-ast-ml-1440532198"></a>
### castExpression

```ml
function castExpression(operand, targetType)
```

Casts expression using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `targetType` | `dynamic` | — | targetType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1130)

- [minisql.sql.ast.CastExpression](Type-minisql-sql-ast-castexpression-2078216309.md) — struct
- [minisql.sql.ast.ColumnDefinition](Type-minisql-sql-ast-columndefinition-1472993879.md) — struct
<a id="function-function-minisql-sql-ast-columnexpression-function-columnexpression-qualifier-name-src-minisql-sql-ast-ml-1952237157"></a>
### columnExpression

```ml
function columnExpression(qualifier, name)
```

Implements column expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `qualifier` | `dynamic` | — | qualifier value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1037)

- [minisql.sql.ast.ColumnExpression](Type-minisql-sql-ast-columnexpression-575958076.md) — struct
- [minisql.sql.ast.CommitStatement](Type-minisql-sql-ast-commitstatement-21949002.md) — struct
- [minisql.sql.ast.CommonTableExpression](Type-minisql-sql-ast-commontableexpression-1198921545.md) — struct
<a id="function-function-minisql-sql-ast-componentname-function-componentname-src-minisql-sql-ast-ml-47902874"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql ast module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2184)

<a id="constant-constant-minisql-sql-ast-conflict-do-nothing-const-conflict-do-nothing-1-src-minisql-sql-ast-ml-1809960086"></a>
### CONFLICT_DO_NOTHING

```ml
const CONFLICT_DO_NOTHING = 1
```

Defines the conflict do nothing constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L90)

<a id="constant-constant-minisql-sql-ast-conflict-do-update-const-conflict-do-update-2-src-minisql-sql-ast-ml-637920611"></a>
### CONFLICT_DO_UPDATE

```ml
const CONFLICT_DO_UPDATE = 2
```

Defines the conflict do update constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L92)

<a id="constant-constant-minisql-sql-ast-conflict-none-const-conflict-none-0-src-minisql-sql-ast-ml-302954547"></a>
### CONFLICT_NONE

```ml
const CONFLICT_NONE = 0
```

Defines the conflict none constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L88)

<a id="constant-constant-minisql-sql-ast-constraint-check-const-constraint-check-3-src-minisql-sql-ast-ml-45991294"></a>
### CONSTRAINT_CHECK

```ml
const CONSTRAINT_CHECK = 3
```

Defines the constraint check constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L65)

<a id="constant-constant-minisql-sql-ast-constraint-foreign-key-const-constraint-foreign-key-4-src-minisql-sql-ast-ml-1279655877"></a>
### CONSTRAINT_FOREIGN_KEY

```ml
const CONSTRAINT_FOREIGN_KEY = 4
```

Defines the constraint foreign key constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L67)

<a id="constant-constant-minisql-sql-ast-constraint-primary-key-const-constraint-primary-key-1-src-minisql-sql-ast-ml-756796660"></a>
### CONSTRAINT_PRIMARY_KEY

```ml
const CONSTRAINT_PRIMARY_KEY = 1
```

Defines the constraint primary key constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L61)

<a id="constant-constant-minisql-sql-ast-constraint-unique-const-constraint-unique-2-src-minisql-sql-ast-ml-1283438001"></a>
### CONSTRAINT_UNIQUE

```ml
const CONSTRAINT_UNIQUE = 2
```

Defines the constraint unique constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L63)

<a id="function-function-minisql-sql-ast-containstypedliteral-function-containstypedliteral-expression-src-minisql-sql-ast-ml-130976936"></a>
### containsTypedLiteral

```ml
function containsTypedLiteral(expression)
```

Reports whether an expression tree embeds an executor-created typed literal. These values intentionally format opaquely and therefore cannot participate in a value-sensitive physical-plan cache key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1850)

- [minisql.sql.ast.CreateIndexStatement](Type-minisql-sql-ast-createindexstatement-753864273.md) — struct
- [minisql.sql.ast.CreatePrincipalStatement](Type-minisql-sql-ast-createprincipalstatement-1012906051.md) — struct
- [minisql.sql.ast.CreateProcedureStatement](Type-minisql-sql-ast-createprocedurestatement-40179358.md) — struct
- [minisql.sql.ast.CreateSchemaStatement](Type-minisql-sql-ast-createschemastatement-293237672.md) — struct
- [minisql.sql.ast.CreateSequenceStatement](Type-minisql-sql-ast-createsequencestatement-2074084630.md) — struct
- [minisql.sql.ast.CreateTableStatement](Type-minisql-sql-ast-createtablestatement-1018468393.md) — struct
- [minisql.sql.ast.CreateTriggerStatement](Type-minisql-sql-ast-createtriggerstatement-17656177.md) — struct
- [minisql.sql.ast.CreateViewStatement](Type-minisql-sql-ast-createviewstatement-1502012906.md) — struct
<a id="function-function-minisql-sql-ast-currenttimestampliteral-function-currenttimestampliteral-src-minisql-sql-ast-ml-1833146130"></a>
### currentTimestampLiteral

```ml
function currentTimestampLiteral()
```

Implements current timestamp literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1028)

<a id="constant-constant-minisql-sql-ast-dcl-object-database-const-dcl-object-database-1-src-minisql-sql-ast-ml-1001638022"></a>
### DCL_OBJECT_DATABASE

```ml
const DCL_OBJECT_DATABASE = 1
```

Defines the dcl object database constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L105)

<a id="constant-constant-minisql-sql-ast-dcl-object-table-const-dcl-object-table-2-src-minisql-sql-ast-ml-1324006183"></a>
### DCL_OBJECT_TABLE

```ml
const DCL_OBJECT_TABLE = 2
```

Defines the dcl object table constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L107)

- [minisql.sql.ast.DeallocateStatement](Type-minisql-sql-ast-deallocatestatement-405953281.md) — struct
- [minisql.sql.ast.DeleteStatement](Type-minisql-sql-ast-deletestatement-22603708.md) — struct
- [minisql.sql.ast.DescribeTableStatement](Type-minisql-sql-ast-describetablestatement-681171500.md) — struct
- [minisql.sql.ast.DropIndexStatement](Type-minisql-sql-ast-dropindexstatement-484240388.md) — struct
- [minisql.sql.ast.DropPrincipalStatement](Type-minisql-sql-ast-dropprincipalstatement-470879782.md) — struct
- [minisql.sql.ast.DropProcedureStatement](Type-minisql-sql-ast-dropprocedurestatement-1085483419.md) — struct
- [minisql.sql.ast.DropSchemaStatement](Type-minisql-sql-ast-dropschemastatement-1263888355.md) — struct
- [minisql.sql.ast.DropSequenceStatement](Type-minisql-sql-ast-dropsequencestatement-1673860961.md) — struct
- [minisql.sql.ast.DropTableStatement](Type-minisql-sql-ast-droptablestatement-1084036088.md) — struct
- [minisql.sql.ast.DropTriggerStatement](Type-minisql-sql-ast-droptriggerstatement-550842036.md) — struct
- [minisql.sql.ast.DropViewStatement](Type-minisql-sql-ast-dropviewstatement-870194193.md) — struct
- [minisql.sql.ast.ExecutePreparedStatement](Type-minisql-sql-ast-executepreparedstatement-166229847.md) — struct
<a id="function-function-minisql-sql-ast-existsexpression-function-existsexpression-query-src-minisql-sql-ast-ml-379925278"></a>
### existsExpression

```ml
function existsExpression(query)
```

Implements exists expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `query` | `dynamic` | — | query value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1200)

- [minisql.sql.ast.ExistsExpression](Type-minisql-sql-ast-existsexpression-1619432718.md) — struct
- [minisql.sql.ast.ExplainStatement](Type-minisql-sql-ast-explainstatement-986742952.md) — struct
<a id="constant-constant-minisql-sql-ast-expr-between-const-expr-between-12-src-minisql-sql-ast-ml-1368477636"></a>
### EXPR_BETWEEN

```ml
const EXPR_BETWEEN = 12
```

Defines the expr between constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L33)

<a id="constant-constant-minisql-sql-ast-expr-binary-const-expr-binary-5-src-minisql-sql-ast-ml-1768543946"></a>
### EXPR_BINARY

```ml
const EXPR_BINARY = 5
```

Defines the expr binary constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L19)

<a id="constant-constant-minisql-sql-ast-expr-case-const-expr-case-9-src-minisql-sql-ast-ml-2138060814"></a>
### EXPR_CASE

```ml
const EXPR_CASE = 9
```

Defines the expr case constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L27)

<a id="constant-constant-minisql-sql-ast-expr-cast-const-expr-cast-10-src-minisql-sql-ast-ml-1185759452"></a>
### EXPR_CAST

```ml
const EXPR_CAST = 10
```

Defines the expr cast constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L29)

<a id="constant-constant-minisql-sql-ast-expr-column-const-expr-column-2-src-minisql-sql-ast-ml-431444901"></a>
### EXPR_COLUMN

```ml
const EXPR_COLUMN = 2
```

Defines the expr column constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L13)

<a id="constant-constant-minisql-sql-ast-expr-exists-const-expr-exists-16-src-minisql-sql-ast-ml-187168498"></a>
### EXPR_EXISTS

```ml
const EXPR_EXISTS = 16
```

Defines the expr exists constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L41)

<a id="constant-constant-minisql-sql-ast-expr-function-const-expr-function-7-src-minisql-sql-ast-ml-495752116"></a>
### EXPR_FUNCTION

```ml
const EXPR_FUNCTION = 7
```

Defines the expr function constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L23)

<a id="constant-constant-minisql-sql-ast-expr-in-const-expr-in-11-src-minisql-sql-ast-ml-550090581"></a>
### EXPR_IN

```ml
const EXPR_IN = 11
```

Defines the expr in constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L31)

<a id="constant-constant-minisql-sql-ast-expr-in-subquery-const-expr-in-subquery-17-src-minisql-sql-ast-ml-934093477"></a>
### EXPR_IN_SUBQUERY

```ml
const EXPR_IN_SUBQUERY = 17
```

Defines the expr in subquery constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L43)

<a id="constant-constant-minisql-sql-ast-expr-is-null-const-expr-is-null-6-src-minisql-sql-ast-ml-1206827371"></a>
### EXPR_IS_NULL

```ml
const EXPR_IS_NULL = 6
```

Defines the expr is null constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L21)

<a id="constant-constant-minisql-sql-ast-expr-literal-const-expr-literal-1-src-minisql-sql-ast-ml-1477254926"></a>
### EXPR_LITERAL

```ml
const EXPR_LITERAL = 1
```

Syntax tree for the MiniSQL SQL front end. The AST contains no catalog


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L11)

<a id="constant-constant-minisql-sql-ast-expr-parameter-const-expr-parameter-8-src-minisql-sql-ast-ml-2001258351"></a>
### EXPR_PARAMETER

```ml
const EXPR_PARAMETER = 8
```

Defines the expr parameter constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L25)

<a id="constant-constant-minisql-sql-ast-expr-star-const-expr-star-3-src-minisql-sql-ast-ml-1803018760"></a>
### EXPR_STAR

```ml
const EXPR_STAR = 3
```

Defines the expr star constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L15)

<a id="constant-constant-minisql-sql-ast-expr-subquery-const-expr-subquery-15-src-minisql-sql-ast-ml-2032410593"></a>
### EXPR_SUBQUERY

```ml
const EXPR_SUBQUERY = 15
```

Defines the expr subquery constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L39)

<a id="constant-constant-minisql-sql-ast-expr-truth-test-const-expr-truth-test-13-src-minisql-sql-ast-ml-1521756191"></a>
### EXPR_TRUTH_TEST

```ml
const EXPR_TRUTH_TEST = 13
```

Defines the expr truth test constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L35)

<a id="constant-constant-minisql-sql-ast-expr-typed-literal-const-expr-typed-literal-14-src-minisql-sql-ast-ml-1231478462"></a>
### EXPR_TYPED_LITERAL

```ml
const EXPR_TYPED_LITERAL = 14
```

Defines the expr typed literal constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L37)

<a id="constant-constant-minisql-sql-ast-expr-unary-const-expr-unary-4-src-minisql-sql-ast-ml-2036428755"></a>
### EXPR_UNARY

```ml
const EXPR_UNARY = 4
```

Defines the expr unary constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L17)

<a id="constant-constant-minisql-sql-ast-expr-window-const-expr-window-18-src-minisql-sql-ast-ml-1046385016"></a>
### EXPR_WINDOW

```ml
const EXPR_WINDOW = 18
```

Defines the expr window constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L45)

<a id="function-function-minisql-sql-ast-expressionkind-function-expressionkind-value-src-minisql-sql-ast-ml-1121485895"></a>
### expressionKind

```ml
function expressionKind(value)
```

Implements expression kind for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1788)

<a id="function-function-minisql-sql-ast-floatliteral-function-floatliteral-value-src-minisql-sql-ast-ml-1293074239"></a>
### floatLiteral

```ml
function floatLiteral(value)
```

Implements float literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1013)

<a id="function-function-minisql-sql-ast-formatexpression-function-formatexpression-expression-src-minisql-sql-ast-ml-1266422964"></a>
### formatExpression

```ml
function formatExpression(expression)
```

Formats expression using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1925)

<a id="function-function-minisql-sql-ast-formatfunction-function-formatfunction-expression-src-minisql-sql-ast-ml-1027802040"></a>
### formatFunction

```ml
function formatFunction(expression)
```

Formats function using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1834)

<a id="function-function-minisql-sql-ast-formatorderitem-function-formatorderitem-item-src-minisql-sql-ast-ml-411761525"></a>
### formatOrderItem

```ml
function formatOrderItem(item)
```

Formats order item using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | item value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2034)

<a id="function-function-minisql-sql-ast-formatselect-function-formatselect-statement-src-minisql-sql-ast-ml-6754827"></a>
### formatSelect

```ml
function formatSelect(statement)
```

Formats select using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2048)

<a id="function-function-minisql-sql-ast-formatselectitem-function-formatselectitem-item-src-minisql-sql-ast-ml-991865245"></a>
### formatSelectItem

```ml
function formatSelectItem(item)
```

Formats select item using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | item value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2024)

<a id="function-function-minisql-sql-ast-formatstatement-function-formatstatement-statement-src-minisql-sql-ast-ml-80462947"></a>
### formatStatement

```ml
function formatStatement(statement)
```

Formats statement using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2121)

<a id="function-function-minisql-sql-ast-formattypename-function-formattypename-value-src-minisql-sql-ast-ml-373050403"></a>
### formatTypeName

```ml
function formatTypeName(value)
```

Formats type name using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1818)

<a id="function-function-minisql-sql-ast-functionexpression-function-functionexpression-name-arguments-distinct-src-minisql-sql-ast-ml-1847368411"></a>
### functionExpression

```ml
function functionExpression(name, arguments, distinct)
```

Implements function expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `arguments` | `dynamic` | — | arguments value consumed by this operation. |
| `distinct` | `dynamic` | — | distinct value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1084)

- [minisql.sql.ast.FunctionExpression](Type-minisql-sql-ast-functionexpression-265046054.md) — struct
- [minisql.sql.ast.GrantPrivilegeStatement](Type-minisql-sql-ast-grantprivilegestatement-1897004374.md) — struct
- [minisql.sql.ast.GrantRoleStatement](Type-minisql-sql-ast-grantrolestatement-327419515.md) — struct
<a id="function-function-minisql-sql-ast-identifier-function-identifier-name-quoted-src-minisql-sql-ast-ml-555338245"></a>
### identifier

```ml
function identifier(name, quoted)
```

Implements identifier for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `quoted` | `dynamic` | — | quoted value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L970)

- [minisql.sql.ast.Identifier](Type-minisql-sql-ast-identifier-1450494079.md) — struct
<a id="function-function-minisql-sql-ast-inexpression-function-inexpression-operand-candidates-negated-src-minisql-sql-ast-ml-726454145"></a>
### inExpression

```ml
function inExpression(operand, candidates, negated)
```

Implements in expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `candidates` | `dynamic` | — | candidates value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1142)

- [minisql.sql.ast.InExpression](Type-minisql-sql-ast-inexpression-61062901.md) — struct
- [minisql.sql.ast.InsertStatement](Type-minisql-sql-ast-insertstatement-82690842.md) — struct
<a id="function-function-minisql-sql-ast-insubqueryexpression-function-insubqueryexpression-operand-query-negated-src-minisql-sql-ast-ml-595674289"></a>
### inSubqueryExpression

```ml
function inSubqueryExpression(operand, query, negated)
```

Implements in subquery expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `query` | `dynamic` | — | query value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1212)

- [minisql.sql.ast.InSubqueryExpression](Type-minisql-sql-ast-insubqueryexpression-227257907.md) — struct
<a id="function-function-minisql-sql-ast-integerliteral-function-integerliteral-value-src-minisql-sql-ast-ml-1098082051"></a>
### integerLiteral

```ml
function integerLiteral(value)
```

Implements integer literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1005)

<a id="function-function-minisql-sql-ast-isaltertablestatement-function-isaltertablestatement-value-src-minisql-sql-ast-ml-40030561"></a>
### isAlterTableStatement

```ml
function isAlterTableStatement(value)
```

Returns whether the supplied value satisfies the alter table statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1508)

<a id="function-function-minisql-sql-ast-isaltertriggerstatement-function-isaltertriggerstatement-value-src-minisql-sql-ast-ml-1785774413"></a>
### isAlterTriggerStatement

```ml
function isAlterTriggerStatement(value)
```

Returns whether the supplied statement changes trigger activation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1482)

<a id="function-function-minisql-sql-ast-isalteruserstatement-function-isalteruserstatement-value-src-minisql-sql-ast-ml-1572440867"></a>
### isAlterUserStatement

```ml
function isAlterUserStatement(value)
```

Returns whether the supplied value satisfies the alter user statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1618)

<a id="function-function-minisql-sql-ast-isanalyzestatement-function-isanalyzestatement-value-src-minisql-sql-ast-ml-1349273419"></a>
### isAnalyzeStatement

```ml
function isAnalyzeStatement(value)
```

Returns whether the supplied value satisfies the analyze statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1674)

<a id="function-function-minisql-sql-ast-isbeginstatement-function-isbeginstatement-value-src-minisql-sql-ast-ml-1779121671"></a>
### isBeginStatement

```ml
function isBeginStatement(value)
```

Returns whether the supplied value satisfies the begin statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1562)

<a id="function-function-minisql-sql-ast-isbetweenexpression-function-isbetweenexpression-value-src-minisql-sql-ast-ml-971709295"></a>
### isBetweenExpression

```ml
function isBetweenExpression(value)
```

Returns whether the supplied value satisfies the between expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1314)

<a id="function-function-minisql-sql-ast-isbinaryexpression-function-isbinaryexpression-value-src-minisql-sql-ast-ml-658454799"></a>
### isBinaryExpression

```ml
function isBinaryExpression(value)
```

Returns whether the supplied value satisfies the binary expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1258)

<a id="function-function-minisql-sql-ast-iscallstatement-function-iscallstatement-value-src-minisql-sql-ast-ml-925352525"></a>
### isCallStatement

```ml
function isCallStatement(value)
```

Returns whether the supplied statement invokes a stored procedure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1500)

<a id="function-function-minisql-sql-ast-iscaseexpression-function-iscaseexpression-value-src-minisql-sql-ast-ml-452753343"></a>
### isCaseExpression

```ml
function isCaseExpression(value)
```

Returns whether the supplied value satisfies the case expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1290)

<a id="function-function-minisql-sql-ast-iscastexpression-function-iscastexpression-value-src-minisql-sql-ast-ml-2104106315"></a>
### isCastExpression

```ml
function isCastExpression(value)
```

Returns whether the supplied value satisfies the cast expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1298)

<a id="function-function-minisql-sql-ast-iscolumnexpression-function-iscolumnexpression-value-src-minisql-sql-ast-ml-725954983"></a>
### isColumnExpression

```ml
function isColumnExpression(value)
```

Returns whether the supplied value satisfies the column expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1234)

<a id="function-function-minisql-sql-ast-iscommitstatement-function-iscommitstatement-value-src-minisql-sql-ast-ml-1007195319"></a>
### isCommitStatement

```ml
function isCommitStatement(value)
```

Returns whether the supplied value satisfies the commit statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1570)

<a id="function-function-minisql-sql-ast-iscreateindexstatement-function-iscreateindexstatement-value-src-minisql-sql-ast-ml-855787659"></a>
### isCreateIndexStatement

```ml
function isCreateIndexStatement(value)
```

Returns whether the supplied value satisfies the create index statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1402)

<a id="function-function-minisql-sql-ast-iscreateprincipalstatement-function-iscreateprincipalstatement-value-src-minisql-sql-ast-ml-1766834055"></a>
### isCreatePrincipalStatement

```ml
function isCreatePrincipalStatement(value)
```

Returns whether the supplied value satisfies the create principal statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1610)

<a id="function-function-minisql-sql-ast-iscreateprocedurestatement-function-iscreateprocedurestatement-value-src-minisql-sql-ast-ml-1418620063"></a>
### isCreateProcedureStatement

```ml
function isCreateProcedureStatement(value)
```

Returns whether the supplied statement creates a stored procedure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1488)

<a id="function-function-minisql-sql-ast-iscreateschemastatement-function-iscreateschemastatement-value-src-minisql-sql-ast-ml-1191023427"></a>
### isCreateSchemaStatement

```ml
function isCreateSchemaStatement(value)
```

Returns whether the supplied statement creates a schema namespace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1422)

<a id="function-function-minisql-sql-ast-iscreatesequencestatement-function-iscreatesequencestatement-value-src-minisql-sql-ast-ml-80805695"></a>
### isCreateSequenceStatement

```ml
function isCreateSequenceStatement(value)
```

Returns whether the supplied value satisfies the create sequence statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1452)

<a id="function-function-minisql-sql-ast-iscreatetablestatement-function-iscreatetablestatement-value-src-minisql-sql-ast-ml-136028519"></a>
### isCreateTableStatement

```ml
function isCreateTableStatement(value)
```

Returns whether the supplied value satisfies the create table statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1394)

<a id="function-function-minisql-sql-ast-iscreatetriggerstatement-function-iscreatetriggerstatement-value-src-minisql-sql-ast-ml-1541768999"></a>
### isCreateTriggerStatement

```ml
function isCreateTriggerStatement(value)
```

Returns whether the supplied value satisfies the create trigger statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1468)

<a id="function-function-minisql-sql-ast-iscreateviewstatement-function-iscreateviewstatement-value-src-minisql-sql-ast-ml-877572039"></a>
### isCreateViewStatement

```ml
function isCreateViewStatement(value)
```

Returns whether the supplied value satisfies the create view statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1436)

<a id="function-function-minisql-sql-ast-isdclstatement-function-isdclstatement-value-src-minisql-sql-ast-ml-1846374635"></a>
### isDclStatement

```ml
function isDclStatement(value)
```

Returns whether the supplied value satisfies the dcl statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1666)

<a id="function-function-minisql-sql-ast-isdeallocatestatement-function-isdeallocatestatement-value-src-minisql-sql-ast-ml-312609217"></a>
### isDeallocateStatement

```ml
function isDeallocateStatement(value)
```

Returns whether the supplied value satisfies the deallocate statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1706)

<a id="function-function-minisql-sql-ast-isdeletestatement-function-isdeletestatement-value-src-minisql-sql-ast-ml-1308345747"></a>
### isDeleteStatement

```ml
function isDeleteStatement(value)
```

Returns whether the supplied value satisfies the delete statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1532)

<a id="function-function-minisql-sql-ast-isdescribetablestatement-function-isdescribetablestatement-value-src-minisql-sql-ast-ml-461964515"></a>
### isDescribeTableStatement

```ml
function isDescribeTableStatement(value)
```

Returns whether the supplied value satisfies the describe table statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1756)

<a id="function-function-minisql-sql-ast-isdropindexstatement-function-isdropindexstatement-value-src-minisql-sql-ast-ml-1569565691"></a>
### isDropIndexStatement

```ml
function isDropIndexStatement(value)
```

Returns whether the supplied value is a DROP INDEX statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1408)

<a id="function-function-minisql-sql-ast-isdropprincipalstatement-function-isdropprincipalstatement-value-src-minisql-sql-ast-ml-1899354143"></a>
### isDropPrincipalStatement

```ml
function isDropPrincipalStatement(value)
```

Returns whether the supplied value satisfies the drop principal statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1626)

<a id="function-function-minisql-sql-ast-isdropprocedurestatement-function-isdropprocedurestatement-value-src-minisql-sql-ast-ml-629218479"></a>
### isDropProcedureStatement

```ml
function isDropProcedureStatement(value)
```

Returns whether the supplied statement drops a stored procedure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1494)

<a id="function-function-minisql-sql-ast-isdropschemastatement-function-isdropschemastatement-value-src-minisql-sql-ast-ml-543771925"></a>
### isDropSchemaStatement

```ml
function isDropSchemaStatement(value)
```

Returns whether the supplied statement drops a schema namespace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1428)

<a id="function-function-minisql-sql-ast-isdropsequencestatement-function-isdropsequencestatement-value-src-minisql-sql-ast-ml-1607171893"></a>
### isDropSequenceStatement

```ml
function isDropSequenceStatement(value)
```

Returns whether the supplied value satisfies the drop sequence statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1460)

<a id="function-function-minisql-sql-ast-isdroptablestatement-function-isdroptablestatement-value-src-minisql-sql-ast-ml-2016014587"></a>
### isDropTableStatement

```ml
function isDropTableStatement(value)
```

Returns whether the supplied value satisfies the drop table statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1416)

<a id="function-function-minisql-sql-ast-isdroptriggerstatement-function-isdroptriggerstatement-value-src-minisql-sql-ast-ml-1033522071"></a>
### isDropTriggerStatement

```ml
function isDropTriggerStatement(value)
```

Returns whether the supplied value satisfies the drop trigger statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1476)

<a id="function-function-minisql-sql-ast-isdropviewstatement-function-isdropviewstatement-value-src-minisql-sql-ast-ml-1623435317"></a>
### isDropViewStatement

```ml
function isDropViewStatement(value)
```

Returns whether the supplied value satisfies the drop view statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1444)

<a id="function-function-minisql-sql-ast-isexecutepreparedstatement-function-isexecutepreparedstatement-value-src-minisql-sql-ast-ml-84640663"></a>
### isExecutePreparedStatement

```ml
function isExecutePreparedStatement(value)
```

Returns whether the supplied value satisfies the execute prepared statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1698)

<a id="function-function-minisql-sql-ast-isexistsexpression-function-isexistsexpression-value-src-minisql-sql-ast-ml-1174377679"></a>
### isExistsExpression

```ml
function isExistsExpression(value)
```

Returns whether the supplied value satisfies the exists expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1346)

<a id="function-function-minisql-sql-ast-isexplainstatement-function-isexplainstatement-value-src-minisql-sql-ast-ml-62051"></a>
### isExplainStatement

```ml
function isExplainStatement(value)
```

Returns whether the supplied value satisfies the explain statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1682)

<a id="function-function-minisql-sql-ast-isexpression-function-isexpression-value-src-minisql-sql-ast-ml-1506136751"></a>
### isExpression

```ml
function isExpression(value)
```

Returns whether the supplied value satisfies the expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1386)

<a id="function-function-minisql-sql-ast-isfunctionexpression-function-isfunctionexpression-value-src-minisql-sql-ast-ml-2079687999"></a>
### isFunctionExpression

```ml
function isFunctionExpression(value)
```

Returns whether the supplied value satisfies the function expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1274)

<a id="function-function-minisql-sql-ast-isgrantprivilegestatement-function-isgrantprivilegestatement-value-src-minisql-sql-ast-ml-478556831"></a>
### isGrantPrivilegeStatement

```ml
function isGrantPrivilegeStatement(value)
```

Returns whether the supplied value satisfies the grant privilege statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1650)

<a id="function-function-minisql-sql-ast-isgrantrolestatement-function-isgrantrolestatement-value-src-minisql-sql-ast-ml-425039319"></a>
### isGrantRoleStatement

```ml
function isGrantRoleStatement(value)
```

Returns whether the supplied value satisfies the grant role statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1634)

<a id="function-function-minisql-sql-ast-isimplemented-function-isimplemented-src-minisql-sql-ast-ml-1131863410"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql ast module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2198)

<a id="function-function-minisql-sql-ast-isinexpression-function-isinexpression-value-src-minisql-sql-ast-ml-708072071"></a>
### isInExpression

```ml
function isInExpression(value)
```

Returns whether the supplied value satisfies the in expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1306)

<a id="function-function-minisql-sql-ast-isinsertstatement-function-isinsertstatement-value-src-minisql-sql-ast-ml-1488085327"></a>
### isInsertStatement

```ml
function isInsertStatement(value)
```

Returns whether the supplied value satisfies the insert statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1516)

<a id="function-function-minisql-sql-ast-isinsubqueryexpression-function-isinsubqueryexpression-value-src-minisql-sql-ast-ml-560259391"></a>
### isInSubqueryExpression

```ml
function isInSubqueryExpression(value)
```

Returns whether the supplied value satisfies the in subquery expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1354)

<a id="function-function-minisql-sql-ast-isisnullexpression-function-isisnullexpression-value-src-minisql-sql-ast-ml-330420399"></a>
### isIsNullExpression

```ml
function isIsNullExpression(value)
```

Returns whether the supplied value satisfies the is null expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1266)

<a id="function-function-minisql-sql-ast-isliteralexpression-function-isliteralexpression-value-src-minisql-sql-ast-ml-2077538641"></a>
### isLiteralExpression

```ml
function isLiteralExpression(value)
```

Returns whether the supplied value satisfies the literal expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1370)

<a id="function-function-minisql-sql-ast-ismergestatement-function-ismergestatement-value-src-minisql-sql-ast-ml-2075433311"></a>
### isMergeStatement

```ml
function isMergeStatement(value)
```

Returns whether the supplied statement is a MERGE operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1538)

<a id="function-function-minisql-sql-ast-ismetadatastatement-function-ismetadatastatement-value-src-minisql-sql-ast-ml-1591023695"></a>
### isMetadataStatement

```ml
function isMetadataStatement(value)
```

Returns whether the supplied value satisfies the metadata statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1772)

<a id="function-function-minisql-sql-ast-isnullexpression-function-isnullexpression-operand-negated-src-minisql-sql-ast-ml-684138563"></a>
### isNullExpression

```ml
function isNullExpression(operand, negated)
```

Returns whether the supplied value satisfies the null expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1073)

- [minisql.sql.ast.IsNullExpression](Type-minisql-sql-ast-isnullexpression-2095182023.md) — struct
<a id="function-function-minisql-sql-ast-isparameterexpression-function-isparameterexpression-value-src-minisql-sql-ast-ml-1004730265"></a>
### isParameterExpression

```ml
function isParameterExpression(value)
```

Returns whether the supplied value satisfies the parameter expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1282)

<a id="function-function-minisql-sql-ast-ispreparestatement-function-ispreparestatement-value-src-minisql-sql-ast-ml-1267735935"></a>
### isPrepareStatement

```ml
function isPrepareStatement(value)
```

Returns whether the supplied value satisfies the prepare statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1690)

<a id="function-function-minisql-sql-ast-isreindexstatement-function-isreindexstatement-value-src-minisql-sql-ast-ml-1222517071"></a>
### isReindexStatement

```ml
function isReindexStatement(value)
```

Returns whether the supplied value satisfies the reindex statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1722)

<a id="function-function-minisql-sql-ast-isreleasesavepointstatement-function-isreleasesavepointstatement-value-src-minisql-sql-ast-ml-1725768273"></a>
### isReleaseSavepointStatement

```ml
function isReleaseSavepointStatement(value)
```

Returns whether the supplied value satisfies the release savepoint statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1602)

<a id="function-function-minisql-sql-ast-isrevokeprivilegestatement-function-isrevokeprivilegestatement-value-src-minisql-sql-ast-ml-2142603711"></a>
### isRevokePrivilegeStatement

```ml
function isRevokePrivilegeStatement(value)
```

Returns whether the supplied value satisfies the revoke privilege statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1658)

<a id="function-function-minisql-sql-ast-isrevokerolestatement-function-isrevokerolestatement-value-src-minisql-sql-ast-ml-1322661157"></a>
### isRevokeRoleStatement

```ml
function isRevokeRoleStatement(value)
```

Returns whether the supplied value satisfies the revoke role statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1642)

<a id="function-function-minisql-sql-ast-isrollbackstatement-function-isrollbackstatement-value-src-minisql-sql-ast-ml-1624031173"></a>
### isRollbackStatement

```ml
function isRollbackStatement(value)
```

Returns whether the supplied value satisfies the rollback statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1578)

<a id="function-function-minisql-sql-ast-isrollbacktostatement-function-isrollbacktostatement-value-src-minisql-sql-ast-ml-570894687"></a>
### isRollbackToStatement

```ml
function isRollbackToStatement(value)
```

Returns whether the supplied value satisfies the rollback to statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1594)

<a id="function-function-minisql-sql-ast-issavepointstatement-function-issavepointstatement-value-src-minisql-sql-ast-ml-1804164543"></a>
### isSavepointStatement

```ml
function isSavepointStatement(value)
```

Returns whether the supplied value satisfies the savepoint statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1586)

<a id="function-function-minisql-sql-ast-isselectstatement-function-isselectstatement-value-src-minisql-sql-ast-ml-783638533"></a>
### isSelectStatement

```ml
function isSelectStatement(value)
```

Returns whether the supplied value satisfies the select statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1554)

<a id="function-function-minisql-sql-ast-isshowindexesstatement-function-isshowindexesstatement-value-src-minisql-sql-ast-ml-1977591419"></a>
### isShowIndexesStatement

```ml
function isShowIndexesStatement(value)
```

Returns whether the supplied value satisfies the show indexes statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1764)

<a id="function-function-minisql-sql-ast-isshowprocessliststatement-function-isshowprocessliststatement-value-src-minisql-sql-ast-ml-1400655311"></a>
### isShowProcesslistStatement

```ml
function isShowProcesslistStatement(value)
```

Returns whether the value is a SHOW PROCESSLIST statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1742)

<a id="function-function-minisql-sql-ast-isshowstatusstatement-function-isshowstatusstatement-value-src-minisql-sql-ast-ml-60956175"></a>
### isShowStatusStatement

```ml
function isShowStatusStatement(value)
```

Returns whether the value is a SHOW STATUS statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1736)

<a id="function-function-minisql-sql-ast-isshowtablesstatement-function-isshowtablesstatement-value-src-minisql-sql-ast-ml-252622253"></a>
### isShowTablesStatement

```ml
function isShowTablesStatement(value)
```

Returns whether the supplied value satisfies the show tables statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1730)

<a id="function-function-minisql-sql-ast-isshutdownstatement-function-isshutdownstatement-value-src-minisql-sql-ast-ml-1210487925"></a>
### isShutdownStatement

```ml
function isShutdownStatement(value)
```

Returns whether the value is a cooperative SHUTDOWN statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1748)

<a id="function-function-minisql-sql-ast-isstarexpression-function-isstarexpression-value-src-minisql-sql-ast-ml-789824527"></a>
### isStarExpression

```ml
function isStarExpression(value)
```

Returns whether the supplied value satisfies the star expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1242)

<a id="function-function-minisql-sql-ast-isstatement-function-isstatement-value-src-minisql-sql-ast-ml-1552680413"></a>
### isStatement

```ml
function isStatement(value)
```

Returns whether the supplied value satisfies the statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1780)

<a id="function-function-minisql-sql-ast-issubqueryexpression-function-issubqueryexpression-value-src-minisql-sql-ast-ml-1774571415"></a>
### isSubqueryExpression

```ml
function isSubqueryExpression(value)
```

Returns whether the supplied value satisfies the subquery expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1338)

<a id="function-function-minisql-sql-ast-istruncatestatement-function-istruncatestatement-value-src-minisql-sql-ast-ml-1091081009"></a>
### isTruncateStatement

```ml
function isTruncateStatement(value)
```

Returns whether the supplied value satisfies the truncate statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1546)

<a id="function-function-minisql-sql-ast-istruthtestexpression-function-istruthtestexpression-value-src-minisql-sql-ast-ml-688710733"></a>
### isTruthTestExpression

```ml
function isTruthTestExpression(value)
```

Returns whether the supplied value satisfies the truth test expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1322)

<a id="function-function-minisql-sql-ast-istypedliteralexpression-function-istypedliteralexpression-value-src-minisql-sql-ast-ml-298192903"></a>
### isTypedLiteralExpression

```ml
function isTypedLiteralExpression(value)
```

Returns whether the supplied value satisfies the typed literal expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1330)

<a id="function-function-minisql-sql-ast-istypename-function-istypename-value-src-minisql-sql-ast-ml-1342898399"></a>
### isTypeName

```ml
function isTypeName(value)
```

Returns whether the supplied value satisfies the type name condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1378)

<a id="function-function-minisql-sql-ast-isunaryexpression-function-isunaryexpression-value-src-minisql-sql-ast-ml-519270105"></a>
### isUnaryExpression

```ml
function isUnaryExpression(value)
```

Returns whether the supplied value satisfies the unary expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1250)

<a id="function-function-minisql-sql-ast-isupdatestatement-function-isupdatestatement-value-src-minisql-sql-ast-ml-639806879"></a>
### isUpdateStatement

```ml
function isUpdateStatement(value)
```

Returns whether the supplied value satisfies the update statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1524)

<a id="function-function-minisql-sql-ast-isvacuumstatement-function-isvacuumstatement-value-src-minisql-sql-ast-ml-339430435"></a>
### isVacuumStatement

```ml
function isVacuumStatement(value)
```

Returns whether the supplied value satisfies the vacuum statement condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1714)

<a id="function-function-minisql-sql-ast-iswindowexpression-function-iswindowexpression-value-src-minisql-sql-ast-ml-679986831"></a>
### isWindowExpression

```ml
function isWindowExpression(value)
```

Returns whether the supplied value satisfies the window expression condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1362)

<a id="constant-constant-minisql-sql-ast-join-cross-const-join-cross-3-src-minisql-sql-ast-ml-613966380"></a>
### JOIN_CROSS

```ml
const JOIN_CROSS = 3
```

Defines the join cross constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L74)

<a id="constant-constant-minisql-sql-ast-join-full-const-join-full-5-src-minisql-sql-ast-ml-848614714"></a>
### JOIN_FULL

```ml
const JOIN_FULL = 5
```

Defines the join full constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L78)

<a id="constant-constant-minisql-sql-ast-join-inner-const-join-inner-1-src-minisql-sql-ast-ml-2076055438"></a>
### JOIN_INNER

```ml
const JOIN_INNER = 1
```

Defines the join inner constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L70)

<a id="constant-constant-minisql-sql-ast-join-left-const-join-left-2-src-minisql-sql-ast-ml-2103469841"></a>
### JOIN_LEFT

```ml
const JOIN_LEFT = 2
```

Defines the join left constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L72)

<a id="constant-constant-minisql-sql-ast-join-right-const-join-right-4-src-minisql-sql-ast-ml-108989295"></a>
### JOIN_RIGHT

```ml
const JOIN_RIGHT = 4
```

Defines the join right constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L76)

- [minisql.sql.ast.JoinClause](Type-minisql-sql-ast-joinclause-1638359089.md) — struct
<a id="constant-constant-minisql-sql-ast-literal-boolean-const-literal-boolean-1-src-minisql-sql-ast-ml-1262259626"></a>
### LITERAL_BOOLEAN

```ml
const LITERAL_BOOLEAN = 1
```

Defines the literal boolean constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L50)

<a id="constant-constant-minisql-sql-ast-literal-current-timestamp-const-literal-current-timestamp-5-src-minisql-sql-ast-ml-97134642"></a>
### LITERAL_CURRENT_TIMESTAMP

```ml
const LITERAL_CURRENT_TIMESTAMP = 5
```

Defines the literal current timestamp constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L58)

<a id="constant-constant-minisql-sql-ast-literal-float-const-literal-float-3-src-minisql-sql-ast-ml-1768707520"></a>
### LITERAL_FLOAT

```ml
const LITERAL_FLOAT = 3
```

Defines the literal float constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L54)

<a id="constant-constant-minisql-sql-ast-literal-integer-const-literal-integer-2-src-minisql-sql-ast-ml-1423009949"></a>
### LITERAL_INTEGER

```ml
const LITERAL_INTEGER = 2
```

Defines the literal integer constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L52)

<a id="constant-constant-minisql-sql-ast-literal-null-const-literal-null-0-src-minisql-sql-ast-ml-759703635"></a>
### LITERAL_NULL

```ml
const LITERAL_NULL = 0
```

Defines the literal null constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L48)

<a id="constant-constant-minisql-sql-ast-literal-string-const-literal-string-4-src-minisql-sql-ast-ml-339188319"></a>
### LITERAL_STRING

```ml
const LITERAL_STRING = 4
```

Defines the literal string constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L56)

- [minisql.sql.ast.LiteralExpression](Type-minisql-sql-ast-literalexpression-448977349.md) — struct
- [minisql.sql.ast.MergeStatement](Type-minisql-sql-ast-mergestatement-1457176461.md) — struct
<a id="function-function-minisql-sql-ast-nullliteral-function-nullliteral-src-minisql-sql-ast-ml-231529170"></a>
### nullLiteral

```ml
function nullLiteral()
```

Implements null literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L989)

- [minisql.sql.ast.OrderItem](Type-minisql-sql-ast-orderitem-984479387.md) — struct
<a id="function-function-minisql-sql-ast-parameterexpression-function-parameterexpression-index-src-minisql-sql-ast-ml-5113052"></a>
### parameterExpression

```ml
function parameterExpression(index)
```

Implements parameter expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1094)

- [minisql.sql.ast.ParameterExpression](Type-minisql-sql-ast-parameterexpression-1507623205.md) — struct
- [minisql.sql.ast.PrepareStatement](Type-minisql-sql-ast-preparestatement-1778257532.md) — struct
<a id="constant-constant-minisql-sql-ast-principal-role-const-principal-role-2-src-minisql-sql-ast-ml-85340557"></a>
### PRINCIPAL_ROLE

```ml
const PRINCIPAL_ROLE = 2
```

Defines the principal role constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L97)

<a id="constant-constant-minisql-sql-ast-principal-user-const-principal-user-1-src-minisql-sql-ast-ml-1383993452"></a>
### PRINCIPAL_USER

```ml
const PRINCIPAL_USER = 1
```

Defines the principal user constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L95)

- [minisql.sql.ast.ProcedureParameter](Type-minisql-sql-ast-procedureparameter-789045828.md) — struct
<a id="function-function-minisql-sql-ast-quotestring-function-quotestring-value-src-minisql-sql-ast-ml-821514609"></a>
### quoteString

```ml
function quoteString(value)
```

Implements quote string for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1797)

- [minisql.sql.ast.ReindexStatement](Type-minisql-sql-ast-reindexstatement-511857896.md) — struct
- [minisql.sql.ast.ReleaseSavepointStatement](Type-minisql-sql-ast-releasesavepointstatement-2050402499.md) — struct
- [minisql.sql.ast.RevokePrivilegeStatement](Type-minisql-sql-ast-revokeprivilegestatement-927530854.md) — struct
- [minisql.sql.ast.RevokeRoleStatement](Type-minisql-sql-ast-revokerolestatement-1352488811.md) — struct
- [minisql.sql.ast.RollbackStatement](Type-minisql-sql-ast-rollbackstatement-2101230197.md) — struct
- [minisql.sql.ast.RollbackToStatement](Type-minisql-sql-ast-rollbacktostatement-1467636930.md) — struct
- [minisql.sql.ast.SavepointStatement](Type-minisql-sql-ast-savepointstatement-414718614.md) — struct
<a id="function-function-minisql-sql-ast-selectcontainstypedliteral-function-selectcontainstypedliteral-statement-src-minisql-sql-ast-ml-1099606839"></a>
### selectContainsTypedLiteral

```ml
function selectContainsTypedLiteral(statement)
```

Reports whether any clause of a SELECT embeds a typed literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1895)

- [minisql.sql.ast.SelectItem](Type-minisql-sql-ast-selectitem-408226539.md) — struct
- [minisql.sql.ast.SelectStatement](Type-minisql-sql-ast-selectstatement-1712428273.md) — struct
<a id="constant-constant-minisql-sql-ast-set-except-const-set-except-3-src-minisql-sql-ast-ml-1285872310"></a>
### SET_EXCEPT

```ml
const SET_EXCEPT = 3
```

Defines the set except constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L85)

<a id="constant-constant-minisql-sql-ast-set-intersect-const-set-intersect-2-src-minisql-sql-ast-ml-356781633"></a>
### SET_INTERSECT

```ml
const SET_INTERSECT = 2
```

Defines the set intersect constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L83)

<a id="constant-constant-minisql-sql-ast-set-union-const-set-union-1-src-minisql-sql-ast-ml-1306524342"></a>
### SET_UNION

```ml
const SET_UNION = 1
```

Defines the set union constant used by the minisql sql ast module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L81)

- [minisql.sql.ast.SetOperation](Type-minisql-sql-ast-setoperation-2110454621.md) — struct
- [minisql.sql.ast.ShowIndexesStatement](Type-minisql-sql-ast-showindexesstatement-1449874336.md) — struct
- [minisql.sql.ast.ShowProcesslistStatement](Type-minisql-sql-ast-showprocessliststatement-210832847.md) — struct
- [minisql.sql.ast.ShowStatusStatement](Type-minisql-sql-ast-showstatusstatement-1174000756.md) — struct
- [minisql.sql.ast.ShowTablesStatement](Type-minisql-sql-ast-showtablesstatement-1215995873.md) — struct
- [minisql.sql.ast.ShutdownStatement](Type-minisql-sql-ast-shutdownstatement-793258431.md) — struct
<a id="function-function-minisql-sql-ast-starexpression-function-starexpression-qualifier-src-minisql-sql-ast-ml-897648562"></a>
### starExpression

```ml
function starExpression(qualifier)
```

Implements star expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `qualifier` | `dynamic` | — | qualifier value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1045)

- [minisql.sql.ast.StarExpression](Type-minisql-sql-ast-starexpression-1721844166.md) — struct
<a id="function-function-minisql-sql-ast-stringliteral-function-stringliteral-value-src-minisql-sql-ast-ml-1314624707"></a>
### stringLiteral

```ml
function stringLiteral(value)
```

Implements string literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1021)

<a id="function-function-minisql-sql-ast-subqueryexpression-function-subqueryexpression-query-src-minisql-sql-ast-ml-855390986"></a>
### subqueryExpression

```ml
function subqueryExpression(query)
```

Implements subquery expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `query` | `dynamic` | — | query value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1190)

- [minisql.sql.ast.SubqueryExpression](Type-minisql-sql-ast-subqueryexpression-63020784.md) — struct
- [minisql.sql.ast.TableConstraint](Type-minisql-sql-ast-tableconstraint-447054775.md) — struct
<a id="function-function-minisql-sql-ast-targetmilestone-function-targetmilestone-src-minisql-sql-ast-ml-140603712"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql ast module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L2191)

- [minisql.sql.ast.TruncateStatement](Type-minisql-sql-ast-truncatestatement-1200600839.md) — struct
<a id="function-function-minisql-sql-ast-truthtestexpression-function-truthtestexpression-operand-expected-negated-src-minisql-sql-ast-ml-1025641925"></a>
### truthTestExpression

```ml
function truthTestExpression(operand, expected, negated)
```

Implements truth test expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operand` | `dynamic` | — | operand value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |
| `negated` | `dynamic` | — | negated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1170)

- [minisql.sql.ast.TruthTestExpression](Type-minisql-sql-ast-truthtestexpression-635200043.md) — struct
<a id="function-function-minisql-sql-ast-typedliteralexpression-function-typedliteralexpression-value-src-minisql-sql-ast-ml-1769096843"></a>
### typedLiteralExpression

```ml
function typedLiteralExpression(value)
```

Implements typed literal expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1180)

- [minisql.sql.ast.TypedLiteralExpression](Type-minisql-sql-ast-typedliteralexpression-180514753.md) — struct
<a id="function-function-minisql-sql-ast-typename-function-typename-name-length-precision-scale-src-minisql-sql-ast-ml-1310543883"></a>
### typeName

```ml
function typeName(name, length, precision, scale)
```

Implements type name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `length` | `dynamic` | — | length value consumed by this operation. |
| `precision` | `dynamic` | — | precision value consumed by this operation. |
| `scale` | `dynamic` | — | scale value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L982)

- [minisql.sql.ast.TypeName](Type-minisql-sql-ast-typename-1736152255.md) — struct
<a id="function-function-minisql-sql-ast-unaryexpression-function-unaryexpression-operator-operand-src-minisql-sql-ast-ml-1944287861"></a>
### unaryExpression

```ml
function unaryExpression(operator, operand)
```

Implements unary expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `operand` | `dynamic` | — | operand value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1054)

- [minisql.sql.ast.UnaryExpression](Type-minisql-sql-ast-unaryexpression-891119829.md) — struct
- [minisql.sql.ast.UpdateStatement](Type-minisql-sql-ast-updatestatement-1226840494.md) — struct
- [minisql.sql.ast.VacuumStatement](Type-minisql-sql-ast-vacuumstatement-1656039828.md) — struct
<a id="function-function-minisql-sql-ast-windowexpression-function-windowexpression-name-arguments-partitionby-orderby-src-minisql-sql-ast-ml-645495027"></a>
### windowExpression

```ml
function windowExpression(name, arguments, partitionBy, orderBy)
```

Implements window expression for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `arguments` | `dynamic` | — | arguments value consumed by this operation. |
| `partitionBy` | `dynamic` | — | partitionBy value consumed by this operation. |
| `orderBy` | `dynamic` | — | orderBy value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L1225)

- [minisql.sql.ast.WindowExpression](Type-minisql-sql-ast-windowexpression-949346098.md) — struct
