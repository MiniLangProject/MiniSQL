# `minisql.platform.file_win32.PositionedReadContext`

[Home](README.md) · [Source file](File-src-minisql-platform-file-win32-ml-727822533.md)

<a id="struct-struct-minisql-platform-file-win32-positionedreadcontext-struct-positionedreadcontext-src-minisql-platform-file-win32-ml-2088501991"></a>
## PositionedReadContext

```ml
struct PositionedReadContext
```

One manual-reset completion event reused by a sequential query or cursor. ResetEvent is required before reuse because overlapped operations may finish synchronously without consuming the event through a wait.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L51)

## Members

<a id="field-field-minisql-platform-file-win32-positionedreadcontext-closed-closed-src-minisql-platform-file-win32-ml-1421685890"></a>
### closed

```ml
closed
```

Prevents an event handle from being reused after close.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L55)

<a id="field-field-minisql-platform-file-win32-positionedreadcontext-completion-completion-src-minisql-platform-file-win32-ml-1566031562"></a>
### completion

```ml
completion
```

Manual-reset event stored in each operation's OVERLAPPED record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_win32.ml#L53)
