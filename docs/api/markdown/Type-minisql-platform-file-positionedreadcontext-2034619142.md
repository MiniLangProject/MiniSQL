# `minisql.platform.file.PositionedReadContext`

[Home](README.md) · [Source file](File-src-minisql-platform-file-ml-1202576533.md)

<a id="struct-struct-minisql-platform-file-positionedreadcontext-struct-positionedreadcontext-src-minisql-platform-file-ml-2055106927"></a>
## PositionedReadContext

```ml
struct PositionedReadContext
```

Cross-platform query-local state for amortizing positioned-read setup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L48)

## Members

<a id="field-field-minisql-platform-file-positionedreadcontext-closed-closed-src-minisql-platform-file-ml-1584979298"></a>
### closed

```ml
closed
```

Prevents reuse after the native resources have been released.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L54)

<a id="field-field-minisql-platform-file-positionedreadcontext-nativecontext-nativecontext-src-minisql-platform-file-ml-748981266"></a>
### nativeContext

```ml
nativeContext
```

Platform-owned state; a Win32 completion event and void on Linux.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L50)

<a id="field-field-minisql-platform-file-positionedreadcontext-operations-operations-src-minisql-platform-file-ml-2126930658"></a>
### operations

```ml
operations
```

Successful explicit-offset operations performed through this context.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L52)
