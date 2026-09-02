# `minisql.platform.file.FileHandle`

[Home](README.md) · [Source file](File-src-minisql-platform-file-ml-1202576533.md)

<a id="struct-struct-minisql-platform-file-filehandle-struct-filehandle-src-minisql-platform-file-ml-1722995739"></a>
## FileHandle

```ml
struct FileHandle
```

Defines the file handle record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L28)

## Members

<a id="field-field-minisql-platform-file-filehandle-closed-closed-src-minisql-platform-file-ml-2101211155"></a>
### closed

```ml
closed
```

Closed field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L38)

<a id="field-field-minisql-platform-file-filehandle-lockheld-lockheld-src-minisql-platform-file-ml-934093379"></a>
### lockHeld

```ml
lockHeld
```

Lock held field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L40)

<a id="field-field-minisql-platform-file-filehandle-nativehandle-nativehandle-src-minisql-platform-file-ml-1623506765"></a>
### nativeHandle

```ml
nativeHandle
```

Native handle field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L32)

<a id="field-field-minisql-platform-file-filehandle-path-path-src-minisql-platform-file-ml-1742853973"></a>
### path

```ml
path
```

Path field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L30)

<a id="field-field-minisql-platform-file-filehandle-positionedread-positionedread-src-minisql-platform-file-ml-1392003683"></a>
### positionedRead

```ml
positionedRead
```

True when readAt uses a native explicit-offset operation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L44)

<a id="field-field-minisql-platform-file-filehandle-readable-readable-src-minisql-platform-file-ml-946727971"></a>
### readable

```ml
readable
```

Readable field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L34)

<a id="field-field-minisql-platform-file-filehandle-writable-writable-src-minisql-platform-file-ml-268841955"></a>
### writable

```ml
writable
```

Writable field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L36)

<a id="field-field-minisql-platform-file-filehandle-writethrough-writethrough-src-minisql-platform-file-ml-466593243"></a>
### writeThrough

```ml
writeThrough
```

Write through field of the file handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file.ml#L42)
