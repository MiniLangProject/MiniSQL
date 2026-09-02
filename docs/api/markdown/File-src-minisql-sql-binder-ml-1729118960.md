# `src/minisql/sql/binder.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.sql.binder`](Package-minisql-sql-binder-1359417870.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)

## Declarations

<a id="function-function-minisql-sql-binder-appendinformationcolumn-function-appendinformationcolumn-columns-name-kind-nullable-src-minisql-sql-binder-ml-1429345233"></a>
### appendInformationColumn

```ml
function appendInformationColumn(columns, name, kind, nullable)
```

Appends one column definition to a virtual INFORMATION_SCHEMA table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columns` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `nullable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L560)

<a id="function-function-minisql-sql-binder-appendnamedsource-function-appendnamedsource-sources-named-alias-src-minisql-sql-binder-ml-1577303499"></a>
### appendNamedSource

```ml
function appendNamedSource(sources, named, alias)
```

Appends named source using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |
| `named` | `dynamic` | — |  |
| `alias` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L524)

<a id="function-function-minisql-sql-binder-appendresolvedsource-function-appendresolvedsource-sources-database-name-alias-availablequeries-viewstack-src-minisql-sql-binder-ml-1595355496"></a>
### appendResolvedSource

```ml
function appendResolvedSource(sources, database, name, alias, availableQueries, viewStack)
```

Appends resolved source using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `alias` | `dynamic` | — |  |
| `availableQueries` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L610)

<a id="function-function-minisql-sql-binder-appendsource-function-appendsource-sources-table-alias-src-minisql-sql-binder-ml-119937950"></a>
### appendSource

```ml
function appendSource(sources, table, alias)
```

Appends source using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `alias` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L463)

<a id="function-function-minisql-sql-binder-bindaggregate-function-bindaggregate-expression-sources-database-src-minisql-sql-binder-ml-441568511"></a>
### bindAggregate

```ml
function bindAggregate(expression, sources, database)
```

Binds aggregate using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L830)

<a id="function-function-minisql-sql-binder-bindaltertable-function-bindaltertable-statement-database-src-minisql-sql-binder-ml-407437228"></a>
### bindAlterTable

```ml
function bindAlterTable(statement, database)
```

Binds alter table using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2124)

<a id="function-function-minisql-sql-binder-bindbetweenexpression-function-bindbetweenexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-146631670"></a>
### bindBetweenExpression

```ml
function bindBetweenExpression(expression, sources, allowAggregates, database)
```

Binds one BETWEEN predicate and validates both boundary types.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | BETWEEN expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for the operand and boundaries. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1109)

<a id="function-function-minisql-sql-binder-bindbinaryexpression-function-bindbinaryexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-1747867668"></a>
### bindBinaryExpression

```ml
function bindBinaryExpression(expression, sources, allowAggregates, database)
```

Binds a binary operator and computes its SQL result type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | Binary expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for both operands. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1145)

<a id="function-function-minisql-sql-binder-bindcaseexpression-function-bindcaseexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-393381928"></a>
### bindCaseExpression

```ml
function bindCaseExpression(expression, sources, allowAggregates, database)
```

Binds all CASE branches while deriving their common nullable result type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | CASE expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for branch expressions. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1065)

<a id="function-function-minisql-sql-binder-bindcolumnsources-function-bindcolumnsources-expression-sources-src-minisql-sql-binder-ml-1731728374"></a>
### bindColumnSources

```ml
function bindColumnSources(expression, sources)
```

Binds column sources using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L659)

<a id="function-function-minisql-sql-binder-bindconflictassignments-function-bindconflictassignments-statement-table-sources-src-minisql-sql-binder-ml-1134364459"></a>
### bindConflictAssignments

```ml
function bindConflictAssignments(statement, table, sources)
```

Binds conflict assignments using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1687)

<a id="function-function-minisql-sql-binder-bindconflictexpression-function-bindconflictexpression-expression-table-sources-src-minisql-sql-binder-ml-400675656"></a>
### bindConflictExpression

```ml
function bindConflictExpression(expression, table, sources)
```

Binds conflict expression using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1680)

<a id="function-function-minisql-sql-binder-bindcreateindex-function-bindcreateindex-statement-database-src-minisql-sql-binder-ml-997421642"></a>
### bindCreateIndex

```ml
function bindCreateIndex(statement, database)
```

Binds index columns and validates an optional immutable row predicate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2011)

<a id="function-function-minisql-sql-binder-bindcreatetable-function-bindcreatetable-statement-database-src-minisql-sql-binder-ml-1804111214"></a>
### bindCreateTable

```ml
function bindCreateTable(statement, database)
```

Binds create table using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1870)

<a id="function-function-minisql-sql-binder-binddelete-function-binddelete-statement-database-src-minisql-sql-binder-ml-509950280"></a>
### bindDelete

```ml
function bindDelete(statement, database)
```

Binds delete using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1849)

<a id="function-function-minisql-sql-binder-binddropindex-function-binddropindex-statement-database-src-minisql-sql-binder-ml-1557931876"></a>
### bindDropIndex

```ml
function bindDropIndex(statement, database)
```

Binds DROP INDEX by resolving the database-wide index name to its owning table. Constraint-backed PRIMARY KEY and table-constraint UNIQUE indexes must be removed through ALTER TABLE DROP CONSTRAINT; explicitly created UNIQUE indexes remain DROP INDEX objects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2063)

<a id="function-function-minisql-sql-binder-binddroptable-function-binddroptable-statement-database-src-minisql-sql-binder-ml-2041613476"></a>
### bindDropTable

```ml
function bindDropTable(statement, database)
```

Binds drop table using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2045)

<a id="function-function-minisql-sql-binder-bindexpression-function-bindexpression-expression-table-alias-src-minisql-sql-binder-ml-1817696678"></a>
### bindExpression

```ml
function bindExpression(expression, table, alias)
```

Binds expression using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `alias` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1211)

<a id="function-function-minisql-sql-binder-bindexpressioninternal-function-bindexpressioninternal-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-817189148"></a>
### bindExpressionInternal

```ml
function bindExpressionInternal(expression, sources, allowAggregates, database)
```

Dispatches one AST expression to its node-specific binder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | AST expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for name resolution. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1181)

<a id="function-function-minisql-sql-binder-bindinexpression-function-bindinexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-1067051104"></a>
### bindInExpression

```ml
function bindInExpression(expression, sources, allowAggregates, database)
```

Binds one IN-list predicate and verifies every candidate type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | IN-list expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for operands and candidates. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1093)

<a id="constant-constant-minisql-sql-binder-binding-error-const-binding-error-9020-src-minisql-sql-binder-ml-223572636"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L20)

<a id="function-function-minisql-sql-binder-bindinsert-function-bindinsert-statement-database-src-minisql-sql-binder-ml-1258080740"></a>
### bindInsert

```ml
function bindInsert(statement, database)
```

Binds insert using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1773)

<a id="function-function-minisql-sql-binder-bindinsertvalue-function-bindinsertvalue-expression-targettype-src-minisql-sql-binder-ml-1269042503"></a>
### bindInsertValue

```ml
function bindInsertValue(expression, targetType)
```

Binds insert value using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `targetType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1752)

<a id="function-function-minisql-sql-binder-bindliteral-function-bindliteral-expression-src-minisql-sql-binder-ml-991973214"></a>
### bindLiteral

```ml
function bindLiteral(expression)
```

Binds literal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L396)

<a id="function-function-minisql-sql-binder-bindreturning-function-bindreturning-items-table-src-minisql-sql-binder-ml-1753836362"></a>
### bindReturning

```ml
function bindReturning(items, table)
```

Binds returning using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1555)

<a id="function-function-minisql-sql-binder-bindscalarfunction-function-bindscalarfunction-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-390962724"></a>
### bindScalarFunction

```ml
function bindScalarFunction(expression, sources, allowAggregates, database)
```

Binds scalar function using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `allowAggregates` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L744)

<a id="function-function-minisql-sql-binder-bindselect-function-bindselect-statement-database-src-minisql-sql-binder-ml-650448800"></a>
### bindSelect

```ml
function bindSelect(statement, database)
```

Binds select using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1547)

<a id="function-function-minisql-sql-binder-bindselectinternal-function-bindselectinternal-statement-database-inheritedqueries-viewstack-src-minisql-sql-binder-ml-2079062947"></a>
### bindSelectInternal

```ml
function bindSelectInternal(statement, database, inheritedQueries, viewStack)
```

Binds select internal using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `inheritedQueries` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1391)

<a id="function-function-minisql-sql-binder-bindstatement-function-bindstatement-statement-database-src-minisql-sql-binder-ml-1834647236"></a>
### bindStatement

```ml
function bindStatement(statement, database)
```

Binds statement using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2206)

<a id="function-function-minisql-sql-binder-bindsubqueryexpression-function-bindsubqueryexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-957967456"></a>
### bindSubqueryExpression

```ml
function bindSubqueryExpression(expression, sources, allowAggregates, database)
```

Binds a scalar, EXISTS, or IN subquery after masking correlated references.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | Subquery expression node to bind. |
| `sources` | `dynamic` | — | Visible outer sources that must not become correlations. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used to bind the nested SELECT. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L992)

<a id="function-function-minisql-sql-binder-bindtruncate-function-bindtruncate-statement-database-src-minisql-sql-binder-ml-1437790096"></a>
### bindTruncate

```ml
function bindTruncate(statement, database)
```

Binds truncate using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1859)

<a id="function-function-minisql-sql-binder-bindunaryexpression-function-bindunaryexpression-expression-sources-allowaggregates-database-src-minisql-sql-binder-ml-1635451516"></a>
### bindUnaryExpression

```ml
function bindUnaryExpression(expression, sources, allowAggregates, database)
```

Binds a unary operator, including the signed-literal minimum-value path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | Unary expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for the operand. |
| `allowAggregates` | `dynamic` | — | Whether this clause permits aggregate expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1123)

<a id="function-function-minisql-sql-binder-bindupdate-function-bindupdate-statement-database-src-minisql-sql-binder-ml-815972764"></a>
### bindUpdate

```ml
function bindUpdate(statement, database)
```

Binds update using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1826)

<a id="function-function-minisql-sql-binder-bindwhere-function-bindwhere-expression-table-alias-src-minisql-sql-binder-ml-1300413854"></a>
### bindWhere

```ml
function bindWhere(expression, table, alias)
```

Binds where using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `alias` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1274)

<a id="function-function-minisql-sql-binder-bindwheresources-function-bindwheresources-expression-sources-operation-database-src-minisql-sql-binder-ml-859913768"></a>
### bindWhereSources

```ml
function bindWhereSources(expression, sources, operation, database)
```

Binds where sources using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1282)

<a id="function-function-minisql-sql-binder-bindwindowexpression-function-bindwindowexpression-expression-sources-database-src-minisql-sql-binder-ml-2026047035"></a>
### bindWindowExpression

```ml
function bindWindowExpression(expression, sources, database)
```

Binds one window expression and preserves its ordering metadata arrays.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | Window expression node to bind. |
| `sources` | `dynamic` | — | Visible row sources for columns and scalar expressions. |
| `database` | `dynamic` | — | Catalog handle used by nested expression binding. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1025)

- [minisql.sql.binder.BoundAlterTable](Type-minisql-sql-binder-boundaltertable-2042442404.md) — struct
- [minisql.sql.binder.BoundAssignment](Type-minisql-sql-binder-boundassignment-1897273953.md) — struct
- [minisql.sql.binder.BoundCreateIndex](Type-minisql-sql-binder-boundcreateindex-1126752488.md) — struct
- [minisql.sql.binder.BoundCreateTable](Type-minisql-sql-binder-boundcreatetable-2104611360.md) — struct
- [minisql.sql.binder.BoundDelete](Type-minisql-sql-binder-bounddelete-347465107.md) — struct
- [minisql.sql.binder.BoundDropTable](Type-minisql-sql-binder-bounddroptable-172426911.md) — struct
- [minisql.sql.binder.BoundInformationSchemaSource](Type-minisql-sql-binder-boundinformationschemasource-1095618092.md) — struct
- [minisql.sql.binder.BoundInsert](Type-minisql-sql-binder-boundinsert-1011117101.md) — struct
<a id="function-function-minisql-sql-binder-bounditemindex-function-bounditemindex-items-expression-src-minisql-sql-binder-ml-2105275482"></a>
### boundItemIndex

```ml
function boundItemIndex(items, expression)
```

Implements bound item index for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1351)

- [minisql.sql.binder.BoundJoin](Type-minisql-sql-binder-boundjoin-1558173624.md) — struct
- [minisql.sql.binder.BoundNamedQuery](Type-minisql-sql-binder-boundnamedquery-1731520155.md) — struct
- [minisql.sql.binder.BoundRecursiveQuery](Type-minisql-sql-binder-boundrecursivequery-364757208.md) — struct
- [minisql.sql.binder.BoundRecursiveReference](Type-minisql-sql-binder-boundrecursivereference-742368849.md) — struct
- [minisql.sql.binder.BoundReturningItem](Type-minisql-sql-binder-boundreturningitem-1236008521.md) — struct
- [minisql.sql.binder.BoundSelect](Type-minisql-sql-binder-boundselect-1674445056.md) — struct
- [minisql.sql.binder.BoundSetOperation](Type-minisql-sql-binder-boundsetoperation-436847537.md) — struct
- [minisql.sql.binder.BoundSource](Type-minisql-sql-binder-boundsource-1961600029.md) — struct
- [minisql.sql.binder.BoundTruncate](Type-minisql-sql-binder-boundtruncate-815463778.md) — struct
- [minisql.sql.binder.BoundUpdate](Type-minisql-sql-binder-boundupdate-1984488393.md) — struct
<a id="function-function-minisql-sql-binder-componentname-function-componentname-src-minisql-sql-binder-ml-107332308"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2223)

<a id="function-function-minisql-sql-binder-conflictbindingsources-function-conflictbindingsources-table-src-minisql-sql-binder-ml-262429388"></a>
### conflictBindingSources

```ml
function conflictBindingSources(table)
```

Implements conflict binding sources for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1667)

<a id="function-function-minisql-sql-binder-conflictconstraint-function-conflictconstraint-database-table-target-src-minisql-sql-binder-ml-1602367482"></a>
### conflictConstraint

```ml
function conflictConstraint(database, table, target)
```

Implements conflict constraint for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1598)

<a id="function-function-minisql-sql-binder-constantschemaexpression-function-constantschemaexpression-expression-src-minisql-sql-binder-ml-1144196274"></a>
### constantSchemaExpression

```ml
function constantSchemaExpression(expression)
```

Implements constant schema expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2089)

<a id="constant-constant-minisql-sql-binder-constraint-violation-const-constraint-violation-9021-src-minisql-sql-binder-ml-1360484599"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L21)

<a id="function-function-minisql-sql-binder-containsaggregatelist-function-containsaggregatelist-items-src-minisql-sql-binder-ml-82998576"></a>
### containsAggregateList

```ml
function containsAggregateList(items)
```

Returns whether the supplied value satisfies the aggregate list condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1340)

<a id="function-function-minisql-sql-binder-crossjoinequalityforsource-function-crossjoinequalityforsource-expression-source-src-minisql-sql-binder-ml-2024335965"></a>
### crossJoinEqualityForSource

```ml
function crossJoinEqualityForSource(expression, source)
```

Finds one WHERE equality connecting a newly introduced CROSS/comma source to any source already present on its left. Only top-level AND conjuncts are eligible, so the equality may safely become the mandatory INNER-join edge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1220)

<a id="function-function-minisql-sql-binder-decimalliteraltext-function-decimalliteraltext-expression-src-minisql-sql-binder-ml-2069094174"></a>
### decimalLiteralText

```ml
function decimalLiteralText(expression)
```

Implements decimal literal text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1733)

<a id="function-function-minisql-sql-binder-ensureboolean-function-ensureboolean-expression-operation-src-minisql-sql-binder-ml-1404901977"></a>
### ensureBoolean

```ml
function ensureBoolean(expression, operation)
```

Ensures boolean using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L667)

<a id="function-function-minisql-sql-binder-fail-function-fail-code-operation-message-src-minisql-sql-binder-ml-955327995"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L240)

<a id="function-function-minisql-sql-binder-findboundcolumn-function-findboundcolumn-sources-expression-src-minisql-sql-binder-ml-1713627506"></a>
### findBoundColumn

```ml
function findBoundColumn(sources, expression)
```

Finds bound column using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L631)

<a id="function-function-minisql-sql-binder-findcolumn-function-findcolumn-table-name-src-minisql-sql-binder-ml-1963907833"></a>
### findColumn

```ml
function findColumn(table, name)
```

Finds column using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L376)

<a id="function-function-minisql-sql-binder-findcolumnindex-function-findcolumnindex-table-name-src-minisql-sql-binder-ml-1751556803"></a>
### findColumnIndex

```ml
function findColumnIndex(table, name)
```

Finds column index using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L361)

<a id="function-function-minisql-sql-binder-groupedexpressionsafe-function-groupedexpressionsafe-expression-groups-src-minisql-sql-binder-ml-123069204"></a>
### groupedExpressionSafe

```ml
function groupedExpressionSafe(expression, groups)
```

Implements grouped expression safe for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `groups` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1291)

<a id="function-function-minisql-sql-binder-indexkeyastdeterministic-function-indexkeyastdeterministic-expression-src-minisql-sql-binder-ml-1076658198"></a>
### indexKeyAstDeterministic

```ml
function indexKeyAstDeterministic(expression)
```

Accepts scalar AST shapes whose value is stable for a stored row. This check runs before binding because CURRENT_TIMESTAMP otherwise becomes an ordinary literal and loses the information needed to reject the volatile source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1936)

<a id="function-function-minisql-sql-binder-indexkeyexpressionreferencescolumn-function-indexkeyexpressionreferencescolumn-expression-src-minisql-sql-binder-ml-1311537574"></a>
### indexKeyExpressionReferencesColumn

```ml
function indexKeyExpressionReferencesColumn(expression)
```

Requires at least one table column so constant scalar expressions cannot create a redundant index whose single key changes between rebuilds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1975)

<a id="function-function-minisql-sql-binder-indexkeyexpressionroundtrips-function-indexkeyexpressionroundtrips-expression-boundexpression-table-src-minisql-sql-binder-ml-1991006508"></a>
### indexKeyExpressionRoundTrips

```ml
function indexKeyExpressionRoundTrips(expression, boundExpression, table)
```

Verifies that canonical catalog SQL reparses to the same typed expression. Column-expression AST nodes intentionally store canonical names rather than quoting state, so an identifier that still needs quotes must be rejected before it could make persisted index metadata ambiguous after a restart.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `boundExpression` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2001)

<a id="function-function-minisql-sql-binder-indexkeyexpressionsafe-function-indexkeyexpressionsafe-expression-src-minisql-sql-binder-ml-1521052446"></a>
### indexKeyExpressionSafe

```ml
function indexKeyExpressionSafe(expression)
```

Combines reproducible scalar-shape and row-dependency validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1993)

<a id="function-function-minisql-sql-binder-indexkeyexpressionshapesafe-function-indexkeyexpressionshapesafe-expression-src-minisql-sql-binder-ml-1128002492"></a>
### indexKeyExpressionShapeSafe

```ml
function indexKeyExpressionShapeSafe(expression)
```

Accepts the bound scalar shapes that the row evaluator can reproduce during inserts, updates, uniqueness checks, rebuilds, and index verification.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1955)

<a id="function-function-minisql-sql-binder-indexpredicatesafe-function-indexpredicatesafe-expression-src-minisql-sql-binder-ml-1720275398"></a>
### indexPredicateSafe

```ml
function indexPredicateSafe(expression)
```

Accepts only immutable row-local expression nodes for partial indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1925)

<a id="constant-constant-minisql-sql-binder-information-columns-const-information-columns-3-src-minisql-sql-binder-ml-844820326"></a>
### INFORMATION_COLUMNS

```ml
const INFORMATION_COLUMNS = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L72)

<a id="constant-constant-minisql-sql-binder-information-routines-const-information-routines-6-src-minisql-sql-binder-ml-1270122887"></a>
### INFORMATION_ROUTINES

```ml
const INFORMATION_ROUTINES = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L75)

<a id="constant-constant-minisql-sql-binder-information-schemata-const-information-schemata-1-src-minisql-sql-binder-ml-1340427120"></a>
### INFORMATION_SCHEMATA

```ml
const INFORMATION_SCHEMATA = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L70)

<a id="constant-constant-minisql-sql-binder-information-table-constraints-const-information-table-constraints-4-src-minisql-sql-binder-ml-109033043"></a>
### INFORMATION_TABLE_CONSTRAINTS

```ml
const INFORMATION_TABLE_CONSTRAINTS = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L73)

<a id="constant-constant-minisql-sql-binder-information-tables-const-information-tables-2-src-minisql-sql-binder-ml-202796651"></a>
### INFORMATION_TABLES

```ml
const INFORMATION_TABLES = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L71)

<a id="constant-constant-minisql-sql-binder-information-views-const-information-views-5-src-minisql-sql-binder-ml-102551372"></a>
### INFORMATION_VIEWS

```ml
const INFORMATION_VIEWS = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L74)

<a id="function-function-minisql-sql-binder-informationschematable-function-informationschematable-name-src-minisql-sql-binder-ml-1979330633"></a>
### informationSchemaTable

```ml
function informationSchemaTable(name)
```

Builds the stable SQL-visible shape for a supported INFORMATION_SCHEMA relation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L565)

<a id="constant-constant-minisql-sql-binder-invalid-argument-const-invalid-argument-9001-src-minisql-sql-binder-ml-1288132997"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L17)

<a id="function-function-minisql-sql-binder-isaggregatename-function-isaggregatename-name-src-minisql-sql-binder-ml-933892693"></a>
### isAggregateName

```ml
function isAggregateName(name)
```

Returns whether the supplied value satisfies the aggregate name condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L684)

<a id="function-function-minisql-sql-binder-isboundaltertable-function-isboundaltertable-value-src-minisql-sql-binder-ml-2101810291"></a>
### isBoundAlterTable

```ml
function isBoundAlterTable(value)
```

Returns whether the supplied value satisfies the bound alter table condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L353)

<a id="function-function-minisql-sql-binder-isboundcreateindex-function-isboundcreateindex-value-src-minisql-sql-binder-ml-949542075"></a>
### isBoundCreateIndex

```ml
function isBoundCreateIndex(value)
```

Returns whether the supplied value satisfies the bound create index condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L339)

<a id="function-function-minisql-sql-binder-isboundcreatetable-function-isboundcreatetable-value-src-minisql-sql-binder-ml-1676883875"></a>
### isBoundCreateTable

```ml
function isBoundCreateTable(value)
```

Returns whether the supplied value satisfies the bound create table condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L332)

<a id="function-function-minisql-sql-binder-isbounddelete-function-isbounddelete-value-src-minisql-sql-binder-ml-1537092245"></a>
### isBoundDelete

```ml
function isBoundDelete(value)
```

Returns whether the supplied value satisfies the bound delete condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L318)

<a id="function-function-minisql-sql-binder-isbounddroptable-function-isbounddroptable-value-src-minisql-sql-binder-ml-1251230303"></a>
### isBoundDropTable

```ml
function isBoundDropTable(value)
```

Returns whether the supplied value satisfies the bound drop table condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L346)

<a id="function-function-minisql-sql-binder-isboundinformationschemasource-function-isboundinformationschemasource-value-src-minisql-sql-binder-ml-1987111215"></a>
### isBoundInformationSchemaSource

```ml
function isBoundInformationSchemaSource(value)
```

Returns whether a source is a virtual INFORMATION_SCHEMA metadata relation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L269)

<a id="function-function-minisql-sql-binder-isboundinsert-function-isboundinsert-value-src-minisql-sql-binder-ml-335298489"></a>
### isBoundInsert

```ml
function isBoundInsert(value)
```

Returns whether the supplied value satisfies the bound insert condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L304)

<a id="function-function-minisql-sql-binder-isboundjoin-function-isboundjoin-value-src-minisql-sql-binder-ml-125981327"></a>
### isBoundJoin

```ml
function isBoundJoin(value)
```

Returns whether the supplied value satisfies the bound join condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L276)

<a id="function-function-minisql-sql-binder-isboundnamedquery-function-isboundnamedquery-value-src-minisql-sql-binder-ml-1652693741"></a>
### isBoundNamedQuery

```ml
function isBoundNamedQuery(value)
```

Returns whether the supplied value satisfies the bound named query condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L254)

<a id="function-function-minisql-sql-binder-isboundrecursivequery-function-isboundrecursivequery-value-src-minisql-sql-binder-ml-1376699707"></a>
### isBoundRecursiveQuery

```ml
function isBoundRecursiveQuery(value)
```

Returns whether a named query is an executable recursive fixpoint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L259)

<a id="function-function-minisql-sql-binder-isboundrecursivereference-function-isboundrecursivereference-value-src-minisql-sql-binder-ml-356110369"></a>
### isBoundRecursiveReference

```ml
function isBoundRecursiveReference(value)
```

Returns whether a source reads the current recursive working-table delta.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L264)

<a id="function-function-minisql-sql-binder-isboundreturningitem-function-isboundreturningitem-value-src-minisql-sql-binder-ml-1701564431"></a>
### isBoundReturningItem

```ml
function isBoundReturningItem(value)
```

Returns whether the supplied value satisfies the bound returning item condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L297)

<a id="function-function-minisql-sql-binder-isboundselect-function-isboundselect-value-src-minisql-sql-binder-ml-1446717395"></a>
### isBoundSelect

```ml
function isBoundSelect(value)
```

Returns whether the supplied value satisfies the bound select condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L290)

<a id="function-function-minisql-sql-binder-isboundsetoperation-function-isboundsetoperation-value-src-minisql-sql-binder-ml-1197608773"></a>
### isBoundSetOperation

```ml
function isBoundSetOperation(value)
```

Returns whether the supplied value satisfies the bound set operation condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L283)

<a id="function-function-minisql-sql-binder-isboundsource-function-isboundsource-value-src-minisql-sql-binder-ml-503662793"></a>
### isBoundSource

```ml
function isBoundSource(value)
```

Returns whether the supplied value satisfies the bound source condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L247)

<a id="function-function-minisql-sql-binder-isboundtruncate-function-isboundtruncate-value-src-minisql-sql-binder-ml-983406651"></a>
### isBoundTruncate

```ml
function isBoundTruncate(value)
```

Returns whether the supplied value satisfies the bound truncate condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L325)

<a id="function-function-minisql-sql-binder-isboundupdate-function-isboundupdate-value-src-minisql-sql-binder-ml-179141801"></a>
### isBoundUpdate

```ml
function isBoundUpdate(value)
```

Returns whether the supplied value satisfies the bound update condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L311)

<a id="function-function-minisql-sql-binder-isimplemented-function-isimplemented-src-minisql-sql-binder-ml-2075088796"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2237)

<a id="function-function-minisql-sql-binder-isnullboundliteral-function-isnullboundliteral-expression-src-minisql-sql-binder-ml-2141812302"></a>
### isNullBoundLiteral

```ml
function isNullBoundLiteral(expression)
```

Returns whether the supplied value satisfies the null bound literal condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L677)

<a id="function-function-minisql-sql-binder-isscalarfunctionname-function-isscalarfunctionname-name-src-minisql-sql-binder-ml-1659469437"></a>
### isScalarFunctionName

```ml
function isScalarFunctionName(name)
```

Returns whether the name belongs to the built-in scalar function library.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L694)

<a id="function-function-minisql-sql-binder-iswindowaggregatename-function-iswindowaggregatename-name-src-minisql-sql-binder-ml-1786535925"></a>
### isWindowAggregateName

```ml
function isWindowAggregateName(name)
```

Returns whether the named aggregate is supported as a window aggregate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L689)

<a id="function-function-minisql-sql-binder-literaltype-function-literaltype-value-src-minisql-sql-binder-ml-576161245"></a>
### literalType

```ml
function literalType(value)
```

Implements literal type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L385)

<a id="function-function-minisql-sql-binder-maskoutercolumn-function-maskoutercolumn-expression-sources-statement-src-minisql-sql-binder-ml-938092317"></a>
### maskOuterColumn

```ml
function maskOuterColumn(expression, sources, statement)
```

Replaces an explicitly qualified outer-column reference with a typed NULL. The placeholder lets the ordinary nested-query binder infer and validate its output shape without depending on a concrete outer row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L885)

<a id="function-function-minisql-sql-binder-maskouterexpression-function-maskouterexpression-expression-sources-statement-src-minisql-sql-binder-ml-643904041"></a>
### maskOuterExpression

```ml
function maskOuterExpression(expression, sources, statement)
```

Recursively masks outer references throughout one nested expression tree.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L899)

<a id="function-function-minisql-sql-binder-maskouterselect-function-maskouterselect-statement-sources-src-minisql-sql-binder-ml-278497185"></a>
### maskOuterSelect

```ml
function maskOuterSelect(statement, sources)
```

Copies a nested SELECT while replacing only references resolved against outer sources.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L953)

<a id="function-function-minisql-sql-binder-mergeconcretetypes-function-mergeconcretetypes-left-right-src-minisql-sql-binder-ml-1653122587"></a>
### mergeConcreteTypes

```ml
function mergeConcreteTypes(left, right)
```

Implements merge concrete types for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L708)

<a id="function-function-minisql-sql-binder-mergeresulttype-function-mergeresulttype-currenttype-hasconcrete-nextexpression-src-minisql-sql-binder-ml-29465115"></a>
### mergeResultType

```ml
function mergeResultType(currentType, hasConcrete, nextExpression)
```

Implements merge result type for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentType` | `dynamic` | — |  |
| `hasConcrete` | `dynamic` | — |  |
| `nextExpression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L728)

<a id="function-function-minisql-sql-binder-namedqueryindex-function-namedqueryindex-availablequeries-name-src-minisql-sql-binder-ml-611887576"></a>
### namedQueryIndex

```ml
function namedQueryIndex(availableQueries, name)
```

Implements named query index for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `availableQueries` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L477)

<a id="function-function-minisql-sql-binder-namescontain-function-namescontain-names-value-src-minisql-sql-binder-ml-681028295"></a>
### namesContain

```ml
function namesContain(names, value)
```

Implements names contain for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L490)

<a id="constant-constant-minisql-sql-binder-object-not-found-const-object-not-found-9014-src-minisql-sql-binder-ml-1454386993"></a>
### OBJECT_NOT_FOUND

```ml
const OBJECT_NOT_FOUND = 9014
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L18)

<a id="function-function-minisql-sql-binder-objectlocalname-function-objectlocalname-name-src-minisql-sql-binder-ml-1852020831"></a>
### objectLocalName

```ml
function objectLocalName(name)
```

Returns the unqualified component of a canonical schema-qualified object name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L423)

<a id="function-function-minisql-sql-binder-parsesingleselect-function-parsesingleselect-sqltext-operation-src-minisql-sql-binder-ml-471399990"></a>
### parseSingleSelect

```ml
function parseSingleSelect(sqlText, operation)
```

Parses single select using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L537)

<a id="function-function-minisql-sql-binder-promotecrossjoinequalities-function-promotecrossjoinequalities-joins-whereexpression-src-minisql-sql-binder-ml-1965746434"></a>
### promoteCrossJoinEqualities

```ml
function promoteCrossJoinEqualities(joins, whereExpression)
```

Promotes a WHERE-restricted cartesian edge to an INNER equality edge so the existing hash/index join cost model avoids materializing the full product. The returned pair contains the promoted joins and the residual WHERE tree; consumed equalities are enforced by the join and must not be evaluated twice.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `joins` | `dynamic` | — |  |
| `whereExpression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1255)

<a id="function-function-minisql-sql-binder-removeboundconjunct-function-removeboundconjunct-expression-target-src-minisql-sql-binder-ml-1424838385"></a>
### removeBoundConjunct

```ml
function removeBoundConjunct(expression, target)
```

Removes every exact occurrence of one guaranteed conjunct from an AND tree. Rebuilding only affected branches preserves every unrelated predicate and its SQL three-valued evaluation semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1240)

<a id="function-function-minisql-sql-binder-resolveinsertcolumns-function-resolveinsertcolumns-statement-table-src-minisql-sql-binder-ml-2098304109"></a>
### resolveInsertColumns

```ml
function resolveInsertColumns(statement, table)
```

Implements resolve insert columns for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1708)

<a id="function-function-minisql-sql-binder-resolvenamedquery-function-resolvenamedquery-database-name-availablequeries-viewstack-src-minisql-sql-binder-ml-691584824"></a>
### resolveNamedQuery

```ml
function resolveNamedQuery(database, name, availableQueries, viewStack)
```

Implements resolve named query for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `availableQueries` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L546)

<a id="function-function-minisql-sql-binder-resulttypewithnullability-function-resulttypewithnullability-typeinfo-nullable-src-minisql-sql-binder-ml-1140656435"></a>
### resultTypeWithNullability

```ml
function resultTypeWithNullability(typeInfo, nullable)
```

Implements result type with nullability for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeInfo` | `dynamic` | — |  |
| `nullable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L701)

<a id="function-function-minisql-sql-binder-rewriteconflictexpression-function-rewriteconflictexpression-expression-targetname-src-minisql-sql-binder-ml-692511500"></a>
### rewriteConflictExpression

```ml
function rewriteConflictExpression(expression, targetName)
```

Rewrites conflict expression using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `targetName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1625)

<a id="function-function-minisql-sql-binder-samenamearray-function-samenamearray-left-right-src-minisql-sql-binder-ml-1290020455"></a>
### sameNameArray

```ml
function sameNameArray(left, right)
```

Implements same name array for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1585)

<a id="function-function-minisql-sql-binder-schemapreservingrename-function-schemapreservingrename-currentname-newlocalname-src-minisql-sql-binder-ml-602413340"></a>
### schemaPreservingRename

```ml
function schemaPreservingRename(currentName, newLocalName)
```

Keeps an unqualified ALTER TABLE rename inside the table's current schema.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentName` | `dynamic` | — |  |
| `newLocalName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L436)

<a id="function-function-minisql-sql-binder-selectdeclaresqualifier-function-selectdeclaresqualifier-statement-qualifier-src-minisql-sql-binder-ml-282681999"></a>
### selectDeclaresQualifier

```ml
function selectDeclaresQualifier(statement, qualifier)
```

Returns true when a qualifier belongs to a source declared by this nested SELECT. Such names shadow outer aliases and must remain ordinary inner-column references.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `qualifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L869)

<a id="function-function-minisql-sql-binder-selectreferencessource-function-selectreferencessource-statement-name-src-minisql-sql-binder-ml-1463936734"></a>
### selectReferencesSource

```ml
function selectReferencesSource(statement, name)
```

Returns true when a SELECT tree names a candidate recursive working table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1373)

<a id="function-function-minisql-sql-binder-sourcetypes-function-sourcetypes-sources-src-minisql-sql-binder-ml-72856834"></a>
### sourceTypes

```ml
function sourceTypes(sources)
```

Implements source types for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1362)

<a id="function-function-minisql-sql-binder-sourcevisiblename-function-sourcevisiblename-source-src-minisql-sql-binder-ml-1357318831"></a>
### sourceVisibleName

```ml
function sourceVisibleName(source)
```

Implements source visible name for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L409)

<a id="function-function-minisql-sql-binder-sourcewidth-function-sourcewidth-sources-src-minisql-sql-binder-ml-912426732"></a>
### sourceWidth

```ml
function sourceWidth(sources)
```

Implements source width for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L451)

<a id="function-function-minisql-sql-binder-stringarraycontains-function-stringarraycontains-values-name-src-minisql-sql-binder-ml-93810217"></a>
### stringArrayContains

```ml
function stringArrayContains(values, name)
```

Returns whether a string array contains the requested column name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2052)

<a id="function-function-minisql-sql-binder-tableforquery-function-tableforquery-name-bound-explicitnames-src-minisql-sql-binder-ml-677146883"></a>
### tableForQuery

```ml
function tableForQuery(name, bound, explicitNames)
```

Implements table for query for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `explicitNames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L501)

<a id="function-function-minisql-sql-binder-targetmilestone-function-targetmilestone-src-minisql-sql-binder-ml-75170918"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L2230)

<a id="constant-constant-minisql-sql-binder-type-mismatch-const-type-mismatch-9017-src-minisql-sql-binder-ml-1772443626"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L19)

<a id="constant-constant-minisql-sql-binder-unsupported-sql-const-unsupported-sql-9025-src-minisql-sql-binder-ml-2083885539"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L22)

<a id="function-function-minisql-sql-binder-validatewindowarguments-function-validatewindowarguments-name-ranking-countstar-arguments-src-minisql-sql-binder-ml-180528314"></a>
### validateWindowArguments

```ml
function validateWindowArguments(name, ranking, countStar, arguments)
```

Validates the arity and types required by one supported window function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Normalized window-function name. |
| `ranking` | `dynamic` | — | Whether the function belongs to the ranking family. |
| `countStar` | `dynamic` | — | Whether the function represents COUNT(*). |
| `arguments` | `dynamic` | — | Bound window-function arguments. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1009)

<a id="function-function-minisql-sql-binder-windowtoplevelsafe-function-windowtoplevelsafe-expression-src-minisql-sql-binder-ml-219770398"></a>
### windowTopLevelSafe

```ml
function windowTopLevelSafe(expression)
```

Implements window top level safe for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L1332)
