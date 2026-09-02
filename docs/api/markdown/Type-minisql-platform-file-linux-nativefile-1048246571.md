# `minisql.platform.file_linux.NativeFile`

[Home](README.md) · [Source file](File-src-minisql-platform-file-linux-ml-802029674.md)

<a id="struct-struct-minisql-platform-file-linux-nativefile-struct-nativefile-src-minisql-platform-file-linux-ml-343578841"></a>
## NativeFile

```ml
struct NativeFile
```

Holds the portable file object and the compatibility cursor used by sequential calls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L29)

## Members

<a id="field-field-minisql-platform-file-linux-nativefile-cursor-cursor-src-minisql-platform-file-linux-ml-1052301238"></a>
### cursor

```ml
cursor
```

Logical offset used only by seek plus readCurrent/writeCurrent.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L33)

<a id="field-field-minisql-platform-file-linux-nativefile-file-file-src-minisql-platform-file-linux-ml-2100209502"></a>
### file

```ml
file
```

Open `std.io.file` object that owns the native descriptor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/file_linux.ml#L31)
