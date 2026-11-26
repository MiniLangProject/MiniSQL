# `minisql.executor.executor.CachedPlan`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-cachedplan-struct-cachedplan-src-minisql-executor-executor-ml-399741785"></a>
## CachedPlan

```ml
struct CachedPlan
```

Session-local reusable physical plan. Entries are generation-bound and the cache is invalidated atomically with local DDL or statistics maintenance.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L146)

## Members

<a id="field-field-minisql-executor-executor-cachedplan-hits-hits-src-minisql-executor-executor-ml-967551698"></a>
### hits

```ml
hits
```

Number of successful reuses since insertion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L156)

<a id="field-field-minisql-executor-executor-cachedplan-key-key-src-minisql-executor-executor-ml-472106278"></a>
### key

```ml
key
```

Canonical formatted SELECT text used for lookup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L148)

<a id="field-field-minisql-executor-executor-cachedplan-optimized-optimized-src-minisql-executor-executor-ml-1687486074"></a>
### optimized

```ml
optimized
```

Costed physical and executable plan.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L154)

<a id="field-field-minisql-executor-executor-cachedplan-schemageneration-schemageneration-src-minisql-executor-executor-ml-409237916"></a>
### schemaGeneration

```ml
schemaGeneration
```

Shared catalog/maintenance generation at planning time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L150)

<a id="field-field-minisql-executor-executor-cachedplan-statisticsgeneration-statisticsgeneration-src-minisql-executor-executor-ml-1931388848"></a>
### statisticsGeneration

```ml
statisticsGeneration
```

Persistent statistics generation at planning time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L152)
