# `minisql.platform.win32_gui.AcceleratorBinding`

[Home](README.md) · [Source file](File-src-minisql-platform-win32-gui-ml-1364403106.md)

<a id="struct-struct-minisql-platform-win32-gui-acceleratorbinding-struct-acceleratorbinding-src-minisql-platform-win32-gui-ml-407407479"></a>
## AcceleratorBinding

```ml
struct AcceleratorBinding
```

Associates one top-level workbench window with its native shortcut table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L442)

## Members

<a id="field-field-minisql-platform-win32-gui-acceleratorbinding-hwnd-hwnd-src-minisql-platform-win32-gui-ml-686367811"></a>
### hwnd

```ml
hwnd
```

Identifies the top-level window receiving translated WM_COMMAND messages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L444)

<a id="field-field-minisql-platform-win32-gui-acceleratorbinding-table-table-src-minisql-platform-win32-gui-ml-902608929"></a>
### table

```ml
table
```

Owns the native HACCEL handle until the window is destroyed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L446)
