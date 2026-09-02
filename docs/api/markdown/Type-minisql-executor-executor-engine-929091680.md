# `minisql.executor.executor.Engine`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-engine-struct-engine-src-minisql-executor-executor-ml-711180537"></a>
## Engine

```ml
struct Engine
```

Groups the engine state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L134)

## Members

<a id="field-field-minisql-executor-executor-engine-activeplankey-activeplankey-src-minisql-executor-executor-ml-1098933527"></a>
### activePlanKey

```ml
activePlanKey
```

Exact caller SQL consumed by the first/top-level physical-plan lookup. Nested SELECTs fall back to canonical AST keys after this value is cleared.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L171)

<a id="field-field-minisql-executor-executor-engine-closed-closed-src-minisql-executor-executor-ml-236730215"></a>
### closed

```ml
closed
```

Indicates whether the closed condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L150)

<a id="field-field-minisql-executor-executor-engine-database-database-src-minisql-executor-executor-ml-1703798385"></a>
### database

```ml
database
```

Stores the database associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L136)

<a id="field-field-minisql-executor-executor-engine-ddltransaction-ddltransaction-src-minisql-executor-executor-ml-561933819"></a>
### ddlTransaction

```ml
ddlTransaction
```

Stores the DDL transaction associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L146)

<a id="field-field-minisql-executor-executor-engine-explicittransaction-explicittransaction-src-minisql-executor-executor-ml-2028438947"></a>
### explicitTransaction

```ml
explicitTransaction
```

Stores the explicit transaction associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L140)

<a id="field-field-minisql-executor-executor-engine-failed-failed-src-minisql-executor-executor-ml-1689825413"></a>
### failed

```ml
failed
```

Stores the failed associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L148)

<a id="field-field-minisql-executor-executor-engine-ownsdatabase-ownsdatabase-src-minisql-executor-executor-ml-1838365587"></a>
### ownsDatabase

```ml
ownsDatabase
```

Stores the owns database associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L138)

<a id="field-field-minisql-executor-executor-engine-pagetransaction-pagetransaction-src-minisql-executor-executor-ml-1429869887"></a>
### pageTransaction

```ml
pageTransaction
```

Stores the page transaction associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L144)

<a id="field-field-minisql-executor-executor-engine-plancache-plancache-src-minisql-executor-executor-ml-1512273863"></a>
### planCache

```ml
planCache
```

Contains bounded reusable physical plans for normalized SELECT text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L168)

<a id="field-field-minisql-executor-executor-engine-planningcontext-planningcontext-src-minisql-executor-executor-ml-1781863915"></a>
### planningContext

```ml
planningContext
```

Caches advisory statistics and index metadata for physical planning.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L166)

<a id="field-field-minisql-executor-executor-engine-preparedstatements-preparedstatements-src-minisql-executor-executor-ml-2085321081"></a>
### preparedStatements

```ml
preparedStatements
```

Stores the prepared statements associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L156)

<a id="field-field-minisql-executor-executor-engine-principalid-principalid-src-minisql-executor-executor-ml-842499779"></a>
### principalId

```ml
principalId
```

Identifies the principal identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L154)

<a id="field-field-minisql-executor-executor-engine-querycontrol-querycontrol-src-minisql-executor-executor-ml-295591241"></a>
### queryControl

```ml
queryControl
```

Cooperative cancellation/deadline state for the active top-level statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L175)

<a id="field-field-minisql-executor-executor-engine-querymemory-querymemory-src-minisql-executor-executor-ml-1231164003"></a>
### queryMemory

```ml
queryMemory
```

Soft-limit policy and diagnostics for the current or most recent statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L173)

<a id="field-field-minisql-executor-executor-engine-recursivecteframes-recursivecteframes-src-minisql-executor-executor-ml-1705407119"></a>
### recursiveCteFrames

```ml
recursiveCteFrames
```

Contains nested recursive-CTE working tables for this isolated session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L164)

<a id="field-field-minisql-executor-executor-engine-sequencevalues-sequencevalues-src-minisql-executor-executor-ml-2079191929"></a>
### sequenceValues

```ml
sequenceValues
```

Stores the sequence values associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L160)

<a id="field-field-minisql-executor-executor-engine-sessionid-sessionid-src-minisql-executor-executor-ml-1681942923"></a>
### sessionId

```ml
sessionId
```

Identifies the session identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L158)

<a id="field-field-minisql-executor-executor-engine-transactionmode-transactionmode-src-minisql-executor-executor-ml-1870542671"></a>
### transactionMode

```ml
transactionMode
```

Stores the transaction mode associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L142)

<a id="field-field-minisql-executor-executor-engine-triggerdepth-triggerdepth-src-minisql-executor-executor-ml-751431753"></a>
### triggerDepth

```ml
triggerDepth
```

Tracks the trigger depth numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L162)

<a id="field-field-minisql-executor-executor-engine-trusted-trusted-src-minisql-executor-executor-ml-1803999907"></a>
### trusted

```ml
trusted
```

Stores the trusted associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L152)
