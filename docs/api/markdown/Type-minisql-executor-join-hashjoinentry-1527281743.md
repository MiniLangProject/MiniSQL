# `minisql.executor.join.HashJoinEntry`

[Home](README.md) · [Source file](File-src-minisql-executor-join-ml-2069389245.md)

<a id="struct-struct-minisql-executor-join-hashjoinentry-struct-hashjoinentry-src-minisql-executor-join-ml-2045540041"></a>
## HashJoinEntry

```ml
struct HashJoinEntry
```

Stores one build-side row in a hash-bucket collision chain.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L29)

## Members

<a id="field-field-minisql-executor-join-hashjoinentry-key-key-src-minisql-executor-join-ml-1669950801"></a>
### key

```ml
key
```

Non-NULL equality key retained for collision verification.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L31)

<a id="field-field-minisql-executor-join-hashjoinentry-row-row-src-minisql-executor-join-ml-1293308001"></a>
### row

```ml
row
```

Right/build-side row associated with the key.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L33)
