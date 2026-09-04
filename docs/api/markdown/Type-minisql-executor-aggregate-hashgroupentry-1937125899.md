# `minisql.executor.aggregate.HashGroupEntry`

[Home](README.md) · [Source file](File-src-minisql-executor-aggregate-ml-1058141144.md)

<a id="struct-struct-minisql-executor-aggregate-hashgroupentry-struct-hashgroupentry-src-minisql-executor-aggregate-ml-217053231"></a>
## HashGroupEntry

```ml
struct HashGroupEntry
```

Maps a collision-chain key to an index in the stable `groups` array.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L56)

## Members

<a id="field-field-minisql-executor-aggregate-hashgroupentry-groupindex-groupindex-src-minisql-executor-aggregate-ml-221894110"></a>
### groupIndex

```ml
groupIndex
```

Index of the corresponding AggregateGroup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L60)

<a id="field-field-minisql-executor-aggregate-hashgroupentry-keyvalues-keyvalues-src-minisql-executor-aggregate-ml-944320880"></a>
### keyValues

```ml
keyValues
```

Full key retained to resolve hash collisions using SQL grouping equality.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L58)
