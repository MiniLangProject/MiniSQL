# `minisql.executor.executor.RecursiveCteFrame`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-recursivecteframe-struct-recursivecteframe-src-minisql-executor-executor-ml-534240537"></a>
## RecursiveCteFrame

```ml
struct RecursiveCteFrame
```

Stores one active recursive CTE working table on the session-local evaluation stack.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L130)

## Members

<a id="field-field-minisql-executor-executor-recursivecteframe-name-name-src-minisql-executor-executor-ml-2116878662"></a>
### name

```ml
name
```

Stores the CTE name used by bound self-reference sources.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L132)

<a id="field-field-minisql-executor-executor-recursivecteframe-rows-rows-src-minisql-executor-executor-ml-1649715106"></a>
### rows

```ml
rows
```

Contains the current iteration's delta rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L134)
