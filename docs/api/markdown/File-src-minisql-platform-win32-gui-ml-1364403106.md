# `src/minisql/platform/win32_gui.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.platform.win32_gui`](Package-minisql-platform-win32-gui-813301474.md)

Reachable from entry: **no**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)

## Declarations

- [minisql.platform.win32_gui.AcceleratorBinding](Type-minisql-platform-win32-gui-acceleratorbinding-1751381188.md) — struct
<a id="global-global-minisql-platform-win32-gui-acceleratorbindings-acceleratorbindings-src-minisql-platform-win32-gui-ml-1224401764"></a>
### acceleratorBindings

```ml
acceleratorBindings
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L258)

<a id="function-function-minisql-platform-win32-gui-acceleratorforwindow-function-acceleratorforwindow-hwnd-src-minisql-platform-win32-gui-ml-1947330723"></a>
### acceleratorForWindow

```ml
function acceleratorForWindow(hwnd)
```

Finds the keyboard accelerator table owned by an active top-level window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L764)

<a id="extern_function-extern-function-minisql-platform-win32-gui-adjustwindowrectexfordpi-extern-function-adjustwindowrectexfordpi-rectangle-as-bytes-style-as-u32-hasmenu-as-bool-exstyle-as-u32-dpivalue-as-u32-from-user32-dll-symbol-adjustwindowrectexfordpi-returns-bool-src-minisql-platform-win32-gui-ml-152993642"></a>
### AdjustWindowRectExForDpi

```ml
extern function AdjustWindowRectExForDpi(rectangle as bytes, style as u32, hasMenu as bool, exStyle as u32, dpiValue as u32) from "user32.dll" symbol "AdjustWindowRectExForDpi" returns bool
```

Binds the DPI-aware non-client size calculation used for exact client dimensions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rectangle` | `bytes` | — |  |
| `style` | `u32` | — |  |
| `hasMenu` | `bool` | — |  |
| `exStyle` | `u32` | — |  |
| `dpiValue` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L329)

<a id="extern_function-extern-function-minisql-platform-win32-gui-appendmenuwint-extern-function-appendmenuwint-menu-as-ptr-flags-as-u32-itemid-as-u32-text-as-wstr-from-user32-dll-symbol-appendmenuw-returns-bool-src-minisql-platform-win32-gui-ml-1312101501"></a>
### AppendMenuWInt

```ml
extern function AppendMenuWInt(menu as ptr, flags as u32, itemId as u32, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
```

Binds the native Windows AppendMenuWInt API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `menu` | `ptr` | — |  |
| `flags` | `u32` | — |  |
| `itemId` | `u32` | — |  |
| `text` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L291)

<a id="extern_function-extern-function-minisql-platform-win32-gui-appendmenuwptr-extern-function-appendmenuwptr-menu-as-ptr-flags-as-u32-item-as-ptr-text-as-wstr-from-user32-dll-symbol-appendmenuw-returns-bool-src-minisql-platform-win32-gui-ml-478739978"></a>
### AppendMenuWPtr

```ml
extern function AppendMenuWPtr(menu as ptr, flags as u32, item as ptr, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
```

Binds the native Windows AppendMenuWPtr API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `menu` | `ptr` | — |  |
| `flags` | `u32` | — |  |
| `item` | `ptr` | — |  |
| `text` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L293)

<a id="function-function-minisql-platform-win32-gui-applycontroltheme-function-applycontroltheme-hwnd-src-minisql-platform-win32-gui-ml-601205371"></a>
### applyControlTheme

```ml
function applyControlTheme(hwnd)
```

Applies modern Windows visual styles to a common control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L704)

<a id="function-function-minisql-platform-win32-gui-applydefaultfont-function-applydefaultfont-hwnd-src-minisql-platform-win32-gui-ml-16933039"></a>
### applyDefaultFont

```ml
function applyDefaultFont(hwnd)
```

Applies a cached per-DPI Segoe UI font, creating at most one GDI font per DPI.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L678)

<a id="function-function-minisql-platform-win32-gui-applynativecharacterstyle-function-applynativecharacterstyle-hwnd-startoffset-endoffset-color-bold-italic-src-minisql-platform-win32-gui-ml-1646147744"></a>
### applyNativeCharacterStyle

```ml
function applyNativeCharacterStyle(hwnd, startOffset, endOffset, color, bold, italic)
```

Applies one CHARFORMAT2 color/effect tuple to a RichEdit-native range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |
| `endOffset` | `dynamic` | — |  |
| `color` | `dynamic` | — |  |
| `bold` | `dynamic` | — |  |
| `italic` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1056)

<a id="function-function-minisql-platform-win32-gui-applysqlspanstyle-function-applysqlspanstyle-hwnd-range-src-minisql-platform-win32-gui-ml-971722192"></a>
### applySqlSpanStyle

```ml
function applySqlSpanStyle(hwnd, range)
```

Maps one translated token range to the stable light-theme SQL palette.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `range` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1071)

<a id="function-function-minisql-platform-win32-gui-applysqlsyntaxstyles-function-applysqlsyntaxstyles-hwnd-spans-src-minisql-platform-win32-gui-ml-1746945834"></a>
### applySqlSyntaxStyles

```ml
function applySqlSyntaxStyles(hwnd, spans)
```

Recolors a complete worksheet while preserving its caret/selection exactly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `spans` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1081)

<a id="function-function-minisql-platform-win32-gui-applywindowchrome-function-applywindowchrome-hwnd-src-minisql-platform-win32-gui-ml-2068874523"></a>
### applyWindowChrome

```ml
function applyWindowChrome(hwnd)
```

Requests rounded Windows 11 top-level window corners when supported.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L711)

<a id="function-function-minisql-platform-win32-gui-attachconnectionmenubar-function-attachconnectionmenubar-hwnd-src-minisql-platform-win32-gui-ml-1146645777"></a>
### attachConnectionMenuBar

```ml
function attachConnectionMenuBar(hwnd)
```

Attaches the smaller alias-management menu used before a session is open.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L794)

<a id="function-function-minisql-platform-win32-gui-attachworkbenchaccelerators-function-attachworkbenchaccelerators-hwnd-src-minisql-platform-win32-gui-ml-295313627"></a>
### attachWorkbenchAccelerators

```ml
function attachWorkbenchAccelerators(hwnd)
```

Registers the workbench keyboard contract for one top-level window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L744)

<a id="function-function-minisql-platform-win32-gui-attachworkbenchmenubar-function-attachworkbenchmenubar-hwnd-src-minisql-platform-win32-gui-ml-725378211"></a>
### attachWorkbenchMenuBar

```ml
function attachWorkbenchMenuBar(hwnd)
```

Attaches the complete MiniSQL workbench menu hierarchy to a top-level window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L773)

<a id="constant-constant-minisql-platform-win32-gui-bm-getcheck-const-bm-getcheck-240-src-minisql-platform-win32-gui-ml-1068695387"></a>
### BM_GETCHECK

```ml
const BM_GETCHECK = 240
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L77)

<a id="constant-constant-minisql-platform-win32-gui-bm-getstate-const-bm-getstate-242-src-minisql-platform-win32-gui-ml-1916760509"></a>
### BM_GETSTATE

```ml
const BM_GETSTATE = 242
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L76)

<a id="constant-constant-minisql-platform-win32-gui-bm-setcheck-const-bm-setcheck-241-src-minisql-platform-win32-gui-ml-1336847344"></a>
### BM_SETCHECK

```ml
const BM_SETCHECK = 241
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L78)

<a id="constant-constant-minisql-platform-win32-gui-bs-autocheckbox-const-bs-autocheckbox-3-src-minisql-platform-win32-gui-ml-1813876992"></a>
### BS_AUTOCHECKBOX

```ml
const BS_AUTOCHECKBOX = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L40)

<a id="constant-constant-minisql-platform-win32-gui-bs-defpushbutton-const-bs-defpushbutton-1-src-minisql-platform-win32-gui-ml-1931301266"></a>
### BS_DEFPUSHBUTTON

```ml
const BS_DEFPUSHBUTTON = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L39)

<a id="constant-constant-minisql-platform-win32-gui-bs-groupbox-const-bs-groupbox-7-src-minisql-platform-win32-gui-ml-1785107524"></a>
### BS_GROUPBOX

```ml
const BS_GROUPBOX = 7
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L38)

<a id="constant-constant-minisql-platform-win32-gui-bs-pushbutton-const-bs-pushbutton-0-src-minisql-platform-win32-gui-ml-1835561693"></a>
### BS_PUSHBUTTON

```ml
const BS_PUSHBUTTON = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L37)

<a id="constant-constant-minisql-platform-win32-gui-bst-checked-const-bst-checked-1-src-minisql-platform-win32-gui-ml-1388147494"></a>
### BST_CHECKED

```ml
const BST_CHECKED = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L79)

<a id="constant-constant-minisql-platform-win32-gui-bst-pushed-const-bst-pushed-4-src-minisql-platform-win32-gui-ml-522283745"></a>
### BST_PUSHED

```ml
const BST_PUSHED = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L80)

<a id="function-function-minisql-platform-win32-gui-buttondown-function-buttondown-hwnd-src-minisql-platform-win32-gui-ml-1675126375"></a>
### buttonDown

```ml
function buttonDown(hwnd)
```

Returns whether a push button currently reports its pressed state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1794)

<a id="constant-constant-minisql-platform-win32-gui-cf-unicodetext-const-cf-unicodetext-13-src-minisql-platform-win32-gui-ml-223216563"></a>
### CF_UNICODETEXT

```ml
const CF_UNICODETEXT = 13
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L159)

<a id="constant-constant-minisql-platform-win32-gui-cfe-bold-const-cfe-bold-1-src-minisql-platform-win32-gui-ml-563117400"></a>
### CFE_BOLD

```ml
const CFE_BOLD = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L72)

<a id="constant-constant-minisql-platform-win32-gui-cfe-italic-const-cfe-italic-2-src-minisql-platform-win32-gui-ml-2014302215"></a>
### CFE_ITALIC

```ml
const CFE_ITALIC = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L73)

<a id="constant-constant-minisql-platform-win32-gui-cfm-bold-const-cfm-bold-1-src-minisql-platform-win32-gui-ml-1312365384"></a>
### CFM_BOLD

```ml
const CFM_BOLD = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L69)

<a id="constant-constant-minisql-platform-win32-gui-cfm-color-const-cfm-color-1073741824-src-minisql-platform-win32-gui-ml-1809754314"></a>
### CFM_COLOR

```ml
const CFM_COLOR = 1073741824
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L71)

<a id="constant-constant-minisql-platform-win32-gui-cfm-italic-const-cfm-italic-2-src-minisql-platform-win32-gui-ml-1504576599"></a>
### CFM_ITALIC

```ml
const CFM_ITALIC = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L70)

<a id="constant-constant-minisql-platform-win32-gui-charformat2w-bytes-const-charformat2w-bytes-116-src-minisql-platform-win32-gui-ml-1303737487"></a>
### CHARFORMAT2W_BYTES

```ml
const CHARFORMAT2W_BYTES = 116
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L74)

<a id="function-function-minisql-platform-win32-gui-checkboxchecked-function-checkboxchecked-hwnd-src-minisql-platform-win32-gui-ml-506541051"></a>
### checkBoxChecked

```ml
function checkBoxChecked(hwnd)
```

Returns whether a checkbox currently holds the checked state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1308)

<a id="function-function-minisql-platform-win32-gui-checkboxset-function-checkboxset-hwnd-checked-src-minisql-platform-win32-gui-ml-806974520"></a>
### checkBoxSet

```ml
function checkBoxSet(hwnd, checked)
```

Sets the native checked state without generating a click notification.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `checked` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1300)

<a id="function-function-minisql-platform-win32-gui-choosecsvpath-function-choosecsvpath-owner-defaultname-src-minisql-platform-win32-gui-ml-197321903"></a>
### chooseCsvPath

```ml
function chooseCsvPath(owner, defaultName)
```

Opens a native Save As dialog and returns an absolute CSV path or an empty cancellation result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `defaultName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1244)

<a id="function-function-minisql-platform-win32-gui-clearevents-function-clearevents-src-minisql-platform-win32-gui-ml-1375732782"></a>
### clearEvents

```ml
function clearEvents()
```

Discards queued native events at a test or window-lifecycle boundary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L638)

<a id="function-function-minisql-platform-win32-gui-clicktabheaderfortest-function-clicktabheaderfortest-hwnd-x-y-src-minisql-platform-win32-gui-ml-405932704"></a>
### clickTabHeaderForTest

```ml
function clickTabHeaderForTest(hwnd, x, y)
```

Sends a native left-button click to a tab header so tests exercise WM_NOTIFY.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L650)

<a id="function-function-minisql-platform-win32-gui-clientsize-function-clientsize-hwnd-src-minisql-platform-win32-gui-ml-1429871147"></a>
### clientSize

```ml
function clientSize(hwnd)
```

Returns the physical-pixel dimensions of a window's client area.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1773)

<a id="function-function-minisql-platform-win32-gui-clientsizedip-function-clientsizedip-hwnd-src-minisql-platform-win32-gui-ml-381079813"></a>
### clientSizeDip

```ml
function clientSizeDip(hwnd)
```

Returns the client dimensions in DPI-independent pixels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1780)

<a id="constant-constant-minisql-platform-win32-gui-clipboard-open-attempts-const-clipboard-open-attempts-100-src-minisql-platform-win32-gui-ml-1610295730"></a>
### CLIPBOARD_OPEN_ATTEMPTS

```ml
const CLIPBOARD_OPEN_ATTEMPTS = 100
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L162)

<a id="constant-constant-minisql-platform-win32-gui-clipboard-retry-delay-ms-const-clipboard-retry-delay-ms-10-src-minisql-platform-win32-gui-ml-160701886"></a>
### CLIPBOARD_RETRY_DELAY_MS

```ml
const CLIPBOARD_RETRY_DELAY_MS = 10
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L163)

<a id="function-function-minisql-platform-win32-gui-clipboardsettext-function-clipboardsettext-owner-text-src-minisql-platform-win32-gui-ml-836026962"></a>
### clipboardSetText

```ml
function clipboardSetText(owner, text)
```

Replaces the Windows clipboard with one NUL-terminated Unicode string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1205)

<a id="function-function-minisql-platform-win32-gui-clipboardtext-function-clipboardtext-owner-src-minisql-platform-win32-gui-ml-1423465105"></a>
### clipboardText

```ml
function clipboardText(owner)
```

Reads Unicode clipboard text into a dynamically sized MiniLang string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1224)

<a id="extern_function-extern-function-minisql-platform-win32-gui-closeclipboard-extern-function-closeclipboard-from-user32-dll-symbol-closeclipboard-returns-bool-src-minisql-platform-win32-gui-ml-2074498672"></a>
### CloseClipboard

```ml
extern function CloseClipboard() from "user32.dll" symbol "CloseClipboard" returns bool
```

Closes the clipboard ownership scope.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L399)

<a id="global-global-minisql-platform-win32-gui-closeeventwindows-closeeventwindows-src-minisql-platform-win32-gui-ml-472510792"></a>
### closeEventWindows

```ml
closeEventWindows
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L259)

<a id="constant-constant-minisql-platform-win32-gui-color-window-const-color-window-5-src-minisql-platform-win32-gui-ml-300024276"></a>
### COLOR_WINDOW

```ml
const COLOR_WINDOW = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L94)

<a id="function-function-minisql-platform-win32-gui-componentname-function-componentname-src-minisql-platform-win32-gui-ml-1843408610"></a>
### componentName

```ml
function componentName()
```

Returns the stable module name used by smoke tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1857)

<a id="function-function-minisql-platform-win32-gui-confirmwarning-function-confirmwarning-owner-title-message-src-minisql-platform-win32-gui-ml-871328060"></a>
### confirmWarning

```ml
function confirmWarning(owner, title, message)
```

Shows an owned destructive-action warning and returns true only for an explicit Yes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `title` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1761)

<a id="function-function-minisql-platform-win32-gui-controlrectdip-function-controlrectdip-parent-child-src-minisql-platform-win32-gui-ml-226178964"></a>
### controlRectDip

```ml
function controlRectDip(parent, child)
```

Returns a child control rectangle in parent-relative DPI-independent pixels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `child` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1686)

<a id="constant-constant-minisql-platform-win32-gui-cp-utf8-const-cp-utf8-65001-src-minisql-platform-win32-gui-ml-214205997"></a>
### CP_UTF8

```ml
const CP_UTF8 = 65001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L88)

<a id="extern_function-extern-function-minisql-platform-win32-gui-createacceleratortablew-extern-function-createacceleratortablew-entries-as-bytes-count-as-i32-from-user32-dll-symbol-createacceleratortablew-returns-ptr-src-minisql-platform-win32-gui-ml-720369280"></a>
### CreateAcceleratorTableW

```ml
extern function CreateAcceleratorTableW(entries as bytes, count as i32) from "user32.dll" symbol "CreateAcceleratorTableW" returns ptr
```

Builds a native keyboard accelerator table from packed ACCEL records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `bytes` | — |  |
| `count` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L385)

<a id="function-function-minisql-platform-win32-gui-createbutton-function-createbutton-parent-text-x-y-width-height-src-minisql-platform-win32-gui-ml-1242349399"></a>
### createButton

```ml
function createButton(parent, text, x, y, width, height)
```

Creates an anonymous push button.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L869)

<a id="function-function-minisql-platform-win32-gui-createbuttonid-function-createbuttonid-parent-controlid-text-x-y-width-height-src-minisql-platform-win32-gui-ml-881553511"></a>
### createButtonId

```ml
function createButtonId(parent, controlId, text, x, y, width, height)
```

Creates a push button that reports its command identifier to the controller.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L874)

<a id="function-function-minisql-platform-win32-gui-createcheckboxid-function-createcheckboxid-parent-controlid-text-x-y-width-height-src-minisql-platform-win32-gui-ml-1610861395"></a>
### createCheckBoxId

```ml
function createCheckBoxId(parent, controlId, text, x, y, width, height)
```

Creates an automatically toggled checkbox with a controller command identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L884)

<a id="function-function-minisql-platform-win32-gui-createchild-function-createchild-parent-classname-text-x-y-width-height-style-exstyle-src-minisql-platform-win32-gui-ml-406113111"></a>
### createChild

```ml
function createChild(parent, className, text, x, y, width, height, style, exStyle)
```

Creates an anonymous child control used only for direct handle-based access.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `className` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `style` | `dynamic` | — |  |
| `exStyle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L854)

<a id="function-function-minisql-platform-win32-gui-createchildid-function-createchildid-parent-classname-text-x-y-width-height-style-exstyle-controlid-src-minisql-platform-win32-gui-ml-32945331"></a>
### createChildId

```ml
function createChildId(parent, className, text, x, y, width, height, style, exStyle, controlId)
```

Creates a child control with an explicit command identifier and shared visual policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `className` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `style` | `dynamic` | — |  |
| `exStyle` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L842)

<a id="function-function-minisql-platform-win32-gui-createdefaultbuttonid-function-createdefaultbuttonid-parent-controlid-text-x-y-width-height-src-minisql-platform-win32-gui-ml-916219323"></a>
### createDefaultButtonId

```ml
function createDefaultButtonId(parent, controlId, text, x, y, width, height)
```

Creates the dialog's default push button, activated by the Enter key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L879)

<a id="function-function-minisql-platform-win32-gui-createedit-function-createedit-parent-text-x-y-width-height-readonly-src-minisql-platform-win32-gui-ml-479264913"></a>
### createEdit

```ml
function createEdit(parent, text, x, y, width, height, readOnly)
```

Creates a multiline worksheet or read-only detail editor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `readOnly` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L911)

<a id="extern_function-extern-function-minisql-platform-win32-gui-createfontw-extern-function-createfontw-height-as-i32-width-as-i32-escapement-as-i32-orientation-as-i32-weight-as-i32-italic-as-u32-underline-as-u32-strikeout-as-u32-charset-as-u32-outputprecision-as-u32-clipprecision-as-u32-quality-as-u32-pitchandfamily-as-u32-facename-as-wstr-from-gdi32-dll-symbol-createfontw-returns-ptr-src-minisql-platform-win32-gui-ml-121101298"></a>
### CreateFontW

```ml
extern function CreateFontW(height as i32, width as i32, escapement as i32, orientation as i32, weight as i32, italic as u32, underline as u32, strikeOut as u32, charSet as u32, outputPrecision as u32, clipPrecision as u32, quality as u32, pitchAndFamily as u32, faceName as wstr) from "gdi32.dll" symbol "CreateFontW" returns ptr
```

Creates the shared Segoe UI font used by every workbench control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `height` | `i32` | — |  |
| `width` | `i32` | — |  |
| `escapement` | `i32` | — |  |
| `orientation` | `i32` | — |  |
| `weight` | `i32` | — |  |
| `italic` | `u32` | — |  |
| `underline` | `u32` | — |  |
| `strikeOut` | `u32` | — |  |
| `charSet` | `u32` | — |  |
| `outputPrecision` | `u32` | — |  |
| `clipPrecision` | `u32` | — |  |
| `quality` | `u32` | — |  |
| `pitchAndFamily` | `u32` | — |  |
| `faceName` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L359)

<a id="function-function-minisql-platform-win32-gui-creategroupbox-function-creategroupbox-parent-text-x-y-width-height-src-minisql-platform-win32-gui-ml-427663287"></a>
### createGroupBox

```ml
function createGroupBox(parent, text, x, y, width, height)
```

Creates a visual group box around related controls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L864)

<a id="function-function-minisql-platform-win32-gui-createlabel-function-createlabel-parent-text-x-y-width-height-src-minisql-platform-win32-gui-ml-1904706527"></a>
### createLabel

```ml
function createLabel(parent, text, x, y, width, height)
```

Creates a static text label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L859)

<a id="function-function-minisql-platform-win32-gui-createlistbox-function-createlistbox-parent-x-y-width-height-src-minisql-platform-win32-gui-ml-366847898"></a>
### createListBox

```ml
function createListBox(parent, x, y, width, height)
```

Creates an anonymous notifying list box.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1137)

<a id="function-function-minisql-platform-win32-gui-createlistboxid-function-createlistboxid-parent-controlid-x-y-width-height-src-minisql-platform-win32-gui-ml-1026231312"></a>
### createListBoxId

```ml
function createListBoxId(parent, controlId, x, y, width, height)
```

Creates a notifying list box with a stable controller identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1142)

<a id="function-function-minisql-platform-win32-gui-createlistview-function-createlistview-parent-controlid-x-y-width-height-src-minisql-platform-win32-gui-ml-1059047112"></a>
### createListView

```ml
function createListView(parent, controlId, x, y, width, height)
```

Creates a double-buffered report ListView for structured query results.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1157)

<a id="extern_function-extern-function-minisql-platform-win32-gui-createmenu-extern-function-createmenu-from-user32-dll-symbol-createmenu-returns-ptr-src-minisql-platform-win32-gui-ml-1392121889"></a>
### CreateMenu

```ml
extern function CreateMenu() from "user32.dll" symbol "CreateMenu" returns ptr
```

Binds the native Windows CreateMenu API used by the GUI abstraction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L287)

<a id="extern_function-extern-function-minisql-platform-win32-gui-createpopupmenu-extern-function-createpopupmenu-from-user32-dll-symbol-createpopupmenu-returns-ptr-src-minisql-platform-win32-gui-ml-2142579973"></a>
### CreatePopupMenu

```ml
extern function CreatePopupMenu() from "user32.dll" symbol "CreatePopupMenu" returns ptr
```

Binds the native Windows CreatePopupMenu API used by the GUI abstraction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L289)

<a id="function-function-minisql-platform-win32-gui-createsqleditor-function-createsqleditor-parent-controlid-text-x-y-width-height-src-minisql-platform-win32-gui-ml-444869445"></a>
### createSqlEditor

```ml
function createSqlEditor(parent, controlId, text, x, y, width, height)
```

Creates the notifying Unicode RichEdit worksheet used for SQL highlighting.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L898)

<a id="function-function-minisql-platform-win32-gui-createtabcontrol-function-createtabcontrol-parent-controlid-x-y-width-height-src-minisql-platform-win32-gui-ml-169076400"></a>
### createTabControl

```ml
function createTabControl(parent, controlId, x, y, width, height)
```

Creates an Explorer-themed notebook tab control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1152)

<a id="function-function-minisql-platform-win32-gui-createtextboxid-function-createtextboxid-parent-controlid-text-x-y-width-height-password-src-minisql-platform-win32-gui-ml-1314296566"></a>
### createTextBoxId

```ml
function createTextBoxId(parent, controlId, text, x, y, width, height, password)
```

Creates a single-line editor, optionally enabling native password masking.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1130)

<a id="function-function-minisql-platform-win32-gui-createtoplevel-function-createtoplevel-title-width-height-visible-src-minisql-platform-win32-gui-ml-791068565"></a>
### createTopLevel

```ml
function createTopLevel(title, width, height, visible)
```

Creates a per-monitor-DPI-aware top-level window with the requested logical client size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `visible` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L819)

<a id="function-function-minisql-platform-win32-gui-createtopmenu-function-createtopmenu-items-identifiers-src-minisql-platform-win32-gui-ml-1834024638"></a>
### createTopMenu

```ml
function createTopMenu(items, identifiers)
```

Builds one popup menu from positionally paired labels and command identifiers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `identifiers` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L720)

<a id="function-function-minisql-platform-win32-gui-createtreeview-function-createtreeview-parent-controlid-x-y-width-height-src-minisql-platform-win32-gui-ml-891277780"></a>
### createTreeView

```ml
function createTreeView(parent, controlId, x, y, width, height)
```

Creates the Explorer-themed MiniSQL object tree.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parent` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1147)

<a id="extern_function-extern-function-minisql-platform-win32-gui-createwindowexw-extern-function-createwindowexw-exstyle-as-u32-classname-as-wstr-windowname-as-wstr-style-as-u32-x-as-i32-y-as-i32-width-as-i32-height-as-i32-parent-as-ptr-menu-as-ptr-instance-as-ptr-param-as-ptr-from-user32-dll-symbol-createwindowexw-returns-ptr-src-minisql-platform-win32-gui-ml-835281808"></a>
### CreateWindowExW

```ml
extern function CreateWindowExW(exStyle as u32, className as wstr, windowName as wstr, style as u32, x as i32, y as i32, width as i32, height as i32, parent as ptr, menu as ptr, instance as ptr, param as ptr) from "user32.dll" symbol "CreateWindowExW" returns ptr
```

Binds the native Windows CreateWindowExW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `exStyle` | `u32` | — |  |
| `className` | `wstr` | — |  |
| `windowName` | `wstr` | — |  |
| `style` | `u32` | — |  |
| `x` | `i32` | — |  |
| `y` | `i32` | — |  |
| `width` | `i32` | — |  |
| `height` | `i32` | — |  |
| `parent` | `ptr` | — |  |
| `menu` | `ptr` | — |  |
| `instance` | `ptr` | — |  |
| `param` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L263)

<a id="constant-constant-minisql-platform-win32-gui-default-gui-font-const-default-gui-font-17-src-minisql-platform-win32-gui-ml-985443469"></a>
### DEFAULT_GUI_FONT

```ml
const DEFAULT_GUI_FONT = 17
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L91)

<a id="extern_function-extern-function-minisql-platform-win32-gui-defwindowprocw-extern-function-defwindowprocw-hwnd-as-ptr-message-as-u32-wparam-as-ptr-lparam-as-ptr-from-user32-dll-symbol-defwindowprocw-returns-ptr-src-minisql-platform-win32-gui-ml-1121079203"></a>
### DefWindowProcW

```ml
extern function DefWindowProcW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "DefWindowProcW" returns ptr
```

Binds the native Windows DefWindowProcW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `ptr` | — |  |
| `lParam` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L299)

<a id="function-function-minisql-platform-win32-gui-destroy-function-destroy-hwnd-src-minisql-platform-win32-gui-ml-813221771"></a>
### destroy

```ml
function destroy(hwnd)
```

Destroys a top-level window and releases its retained minimum-size policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1828)

<a id="extern_function-extern-function-minisql-platform-win32-gui-destroyacceleratortable-extern-function-destroyacceleratortable-table-as-ptr-from-user32-dll-symbol-destroyacceleratortable-returns-bool-src-minisql-platform-win32-gui-ml-864050563"></a>
### DestroyAcceleratorTable

```ml
extern function DestroyAcceleratorTable(table as ptr) from "user32.dll" symbol "DestroyAcceleratorTable" returns bool
```

Releases a native keyboard accelerator table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L389)

<a id="extern_function-extern-function-minisql-platform-win32-gui-destroymenu-extern-function-destroymenu-menu-as-ptr-from-user32-dll-symbol-destroymenu-returns-bool-src-minisql-platform-win32-gui-ml-112741372"></a>
### DestroyMenu

```ml
extern function DestroyMenu(menu as ptr) from "user32.dll" symbol "DestroyMenu" returns bool
```

Releases a temporary native menu after a context action was selected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `menu` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L383)

<a id="extern_function-extern-function-minisql-platform-win32-gui-destroywindow-extern-function-destroywindow-hwnd-as-ptr-from-user32-dll-symbol-destroywindow-returns-i32-src-minisql-platform-win32-gui-ml-2136478705"></a>
### DestroyWindow

```ml
extern function DestroyWindow(hwnd as ptr) from "user32.dll" symbol "DestroyWindow" returns i32
```

Binds the native Windows DestroyWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L265)

<a id="extern_function-extern-function-minisql-platform-win32-gui-dispatchmessagew-extern-function-dispatchmessagew-message-as-bytes-from-user32-dll-symbol-dispatchmessagew-returns-ptr-src-minisql-platform-win32-gui-ml-1771234678"></a>
### DispatchMessageW

```ml
extern function DispatchMessageW(message as bytes) from "user32.dll" symbol "DispatchMessageW" returns ptr
```

Binds the native Windows DispatchMessageW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L347)

<a id="function-function-minisql-platform-win32-gui-divideint-function-divideint-numerator-denominator-src-minisql-platform-win32-gui-ml-306754417"></a>
### divideInt

```ml
function divideInt(numerator, denominator)
```

Divides integers with truncation while preserving MiniLang's integer runtime type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — |  |
| `denominator` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L451)

<a id="function-function-minisql-platform-win32-gui-dpi-function-dpi-hwnd-src-minisql-platform-win32-gui-ml-1725552125"></a>
### dpi

```ml
function dpi(hwnd)
```

Returns a valid DPI for a window, falling back to the 96-DPI baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1787)

<a id="extern_function-extern-function-minisql-platform-win32-gui-drawmenubar-extern-function-drawmenubar-hwnd-as-ptr-from-user32-dll-symbol-drawmenubar-returns-bool-src-minisql-platform-win32-gui-ml-381794491"></a>
### DrawMenuBar

```ml
extern function DrawMenuBar(hwnd as ptr) from "user32.dll" symbol "DrawMenuBar" returns bool
```

Binds the native Windows DrawMenuBar API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L297)

<a id="extern_function-extern-function-minisql-platform-win32-gui-dwmsetwindowattribute-extern-function-dwmsetwindowattribute-hwnd-as-ptr-attribute-as-u32-value-as-bytes-size-as-u32-from-dwmapi-dll-symbol-dwmsetwindowattribute-returns-i32-src-minisql-platform-win32-gui-ml-427025494"></a>
### DwmSetWindowAttribute

```ml
extern function DwmSetWindowAttribute(hwnd as ptr, attribute as u32, value as bytes, size as u32) from "dwmapi.dll" symbol "DwmSetWindowAttribute" returns i32
```

Applies supported Windows 11 non-client chrome attributes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `attribute` | `u32` | — |  |
| `value` | `bytes` | — |  |
| `size` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L363)

<a id="constant-constant-minisql-platform-win32-gui-em-exgetsel-const-em-exgetsel-1076-src-minisql-platform-win32-gui-ml-894889569"></a>
### EM_EXGETSEL

```ml
const EM_EXGETSEL = 1076
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L58)

<a id="constant-constant-minisql-platform-win32-gui-em-exlimittext-const-em-exlimittext-1077-src-minisql-platform-win32-gui-ml-922229152"></a>
### EM_EXLIMITTEXT

```ml
const EM_EXLIMITTEXT = 1077
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L59)

<a id="constant-constant-minisql-platform-win32-gui-em-exsetsel-const-em-exsetsel-1079-src-minisql-platform-win32-gui-ml-1255868912"></a>
### EM_EXSETSEL

```ml
const EM_EXSETSEL = 1079
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L60)

<a id="constant-constant-minisql-platform-win32-gui-em-getcharformat-const-em-getcharformat-1082-src-minisql-platform-win32-gui-ml-527352112"></a>
### EM_GETCHARFORMAT

```ml
const EM_GETCHARFORMAT = 1082
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L61)

<a id="constant-constant-minisql-platform-win32-gui-em-getscrollpos-const-em-getscrollpos-1245-src-minisql-platform-win32-gui-ml-2140180905"></a>
### EM_GETSCROLLPOS

```ml
const EM_GETSCROLLPOS = 1245
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L64)

<a id="constant-constant-minisql-platform-win32-gui-em-setcharformat-const-em-setcharformat-1092-src-minisql-platform-win32-gui-ml-182101693"></a>
### EM_SETCHARFORMAT

```ml
const EM_SETCHARFORMAT = 1092
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L62)

<a id="constant-constant-minisql-platform-win32-gui-em-setcuebanner-const-em-setcuebanner-5377-src-minisql-platform-win32-gui-ml-621953327"></a>
### EM_SETCUEBANNER

```ml
const EM_SETCUEBANNER = 5377
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L66)

<a id="constant-constant-minisql-platform-win32-gui-em-seteventmask-const-em-seteventmask-1093-src-minisql-platform-win32-gui-ml-74963680"></a>
### EM_SETEVENTMASK

```ml
const EM_SETEVENTMASK = 1093
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L63)

<a id="constant-constant-minisql-platform-win32-gui-em-setlimittext-const-em-setlimittext-197-src-minisql-platform-win32-gui-ml-309244138"></a>
### EM_SETLIMITTEXT

```ml
const EM_SETLIMITTEXT = 197
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L57)

<a id="constant-constant-minisql-platform-win32-gui-em-setscrollpos-const-em-setscrollpos-1246-src-minisql-platform-win32-gui-ml-1534264684"></a>
### EM_SETSCROLLPOS

```ml
const EM_SETSCROLLPOS = 1246
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L65)

<a id="extern_function-extern-function-minisql-platform-win32-gui-emptyclipboard-extern-function-emptyclipboard-from-user32-dll-symbol-emptyclipboard-returns-bool-src-minisql-platform-win32-gui-ml-809952857"></a>
### EmptyClipboard

```ml
extern function EmptyClipboard() from "user32.dll" symbol "EmptyClipboard" returns bool
```

Clears the clipboard after exclusive ownership was acquired.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L393)

<a id="extern_function-extern-function-minisql-platform-win32-gui-enablewindow-extern-function-enablewindow-hwnd-as-ptr-enabled-as-bool-from-user32-dll-symbol-enablewindow-returns-bool-src-minisql-platform-win32-gui-ml-1870518611"></a>
### EnableWindow

```ml
extern function EnableWindow(hwnd as ptr, enabled as bool) from "user32.dll" symbol "EnableWindow" returns bool
```

Enables or disables a native control while background work is active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `enabled` | `bool` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L365)

<a id="constant-constant-minisql-platform-win32-gui-enm-change-const-enm-change-1-src-minisql-platform-win32-gui-ml-2016851670"></a>
### ENM_CHANGE

```ml
const ENM_CHANGE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L67)

<a id="function-function-minisql-platform-win32-gui-ensurerichedit-function-ensurerichedit-src-minisql-platform-win32-gui-ml-1409646882"></a>
### ensureRichEdit

```ml
function ensureRichEdit()
```

Loads the system RichEdit 4.1 class once for the process-wide SQL worksheet.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L889)

<a id="function-function-minisql-platform-win32-gui-ensurewindowclass-function-ensurewindowclass-src-minisql-platform-win32-gui-ml-1601999050"></a>
### ensureWindowClass

```ml
function ensureWindowClass()
```

Registers the process-wide top-level window class exactly once.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L594)

<a id="constant-constant-minisql-platform-win32-gui-error-class-already-exists-const-error-class-already-exists-1410-src-minisql-platform-win32-gui-ml-1505081177"></a>
### ERROR_CLASS_ALREADY_EXISTS

```ml
const ERROR_CLASS_ALREADY_EXISTS = 1410
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L96)

<a id="constant-constant-minisql-platform-win32-gui-es-autohscroll-const-es-autohscroll-128-src-minisql-platform-win32-gui-ml-906169044"></a>
### ES_AUTOHSCROLL

```ml
const ES_AUTOHSCROLL = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L30)

<a id="constant-constant-minisql-platform-win32-gui-es-autohscroll-single-const-es-autohscroll-single-128-src-minisql-platform-win32-gui-ml-617023908"></a>
### ES_AUTOHSCROLL_SINGLE

```ml
const ES_AUTOHSCROLL_SINGLE = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L34)

<a id="constant-constant-minisql-platform-win32-gui-es-autovscroll-const-es-autovscroll-64-src-minisql-platform-win32-gui-ml-923434639"></a>
### ES_AUTOVSCROLL

```ml
const ES_AUTOVSCROLL = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L29)

<a id="constant-constant-minisql-platform-win32-gui-es-multiline-const-es-multiline-4-src-minisql-platform-win32-gui-ml-629240035"></a>
### ES_MULTILINE

```ml
const ES_MULTILINE = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L28)

<a id="constant-constant-minisql-platform-win32-gui-es-password-const-es-password-32-src-minisql-platform-win32-gui-ml-440089344"></a>
### ES_PASSWORD

```ml
const ES_PASSWORD = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L33)

<a id="constant-constant-minisql-platform-win32-gui-es-readonly-const-es-readonly-2048-src-minisql-platform-win32-gui-ml-988838455"></a>
### ES_READONLY

```ml
const ES_READONLY = 2048
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L31)

<a id="constant-constant-minisql-platform-win32-gui-es-wantreturn-const-es-wantreturn-4096-src-minisql-platform-win32-gui-ml-2032046342"></a>
### ES_WANTRETURN

```ml
const ES_WANTRETURN = 4096
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L32)

<a id="function-function-minisql-platform-win32-gui-fail-function-fail-operation-message-src-minisql-platform-win32-gui-ml-1512170874"></a>
### fail

```ml
function fail(operation, message)
```

Creates a namespaced structured error for a failed GUI operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L659)

<a id="constant-constant-minisql-platform-win32-gui-fcontrol-const-fcontrol-8-src-minisql-platform-win32-gui-ml-818865853"></a>
### FCONTROL

```ml
const FCONTROL = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L170)

<a id="function-function-minisql-platform-win32-gui-focus-function-focus-hwnd-src-minisql-platform-win32-gui-ml-1933063323"></a>
### focus

```ml
function focus(hwnd)
```

Gives keyboard focus to a workbench control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1740)

<a id="constant-constant-minisql-platform-win32-gui-fshift-const-fshift-4-src-minisql-platform-win32-gui-ml-777005207"></a>
### FSHIFT

```ml
const FSHIFT = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L169)

<a id="constant-constant-minisql-platform-win32-gui-fvirtkey-const-fvirtkey-1-src-minisql-platform-win32-gui-ml-1359524692"></a>
### FVIRTKEY

```ml
const FVIRTKEY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L168)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getactivewindow-extern-function-getactivewindow-from-user32-dll-symbol-getactivewindow-returns-ptr-src-minisql-platform-win32-gui-ml-361690332"></a>
### GetActiveWindow

```ml
extern function GetActiveWindow() from "user32.dll" symbol "GetActiveWindow" returns ptr
```

Returns the currently active top-level window for dialog-style keyboard routing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L371)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getclientrect-extern-function-getclientrect-hwnd-as-ptr-rectangle-as-bytes-from-user32-dll-symbol-getclientrect-returns-bool-src-minisql-platform-win32-gui-ml-192376664"></a>
### GetClientRect

```ml
extern function GetClientRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetClientRect" returns bool
```

Binds the native Windows GetClientRect API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `rectangle` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L317)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getclipboarddata-extern-function-getclipboarddata-format-as-u32-from-user32-dll-symbol-getclipboarddata-returns-ptr-src-minisql-platform-win32-gui-ml-668123543"></a>
### GetClipboardData

```ml
extern function GetClipboardData(format as u32) from "user32.dll" symbol "GetClipboardData" returns ptr
```

Retrieves one published clipboard memory block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `format` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L397)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getcursorpos-extern-function-getcursorpos-point-as-bytes-from-user32-dll-symbol-getcursorpos-returns-bool-src-minisql-platform-win32-gui-ml-1341159631"></a>
### GetCursorPos

```ml
extern function GetCursorPos(point as bytes) from "user32.dll" symbol "GetCursorPos" returns bool
```

Reads the current pointer position for ListView cell and context-menu hit testing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L377)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getdesktopwindow-extern-function-getdesktopwindow-from-user32-dll-symbol-getdesktopwindow-returns-ptr-src-minisql-platform-win32-gui-ml-1292731010"></a>
### GetDesktopWindow

```ml
extern function GetDesktopWindow() from "user32.dll" symbol "GetDesktopWindow" returns ptr
```

Binds the native Windows GetDesktopWindow API used by the GUI abstraction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L267)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getdlgctrlid-extern-function-getdlgctrlid-hwnd-as-ptr-from-user32-dll-symbol-getdlgctrlid-returns-i32-src-minisql-platform-win32-gui-ml-1359069940"></a>
### GetDlgCtrlID

```ml
extern function GetDlgCtrlID(hwnd as ptr) from "user32.dll" symbol "GetDlgCtrlID" returns i32
```

Returns a child control's numeric identifier for context-menu routing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L375)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getdpiforsystem-extern-function-getdpiforsystem-from-user32-dll-symbol-getdpiforsystem-returns-i32-src-minisql-platform-win32-gui-ml-1245781035"></a>
### GetDpiForSystem

```ml
extern function GetDpiForSystem() from "user32.dll" symbol "GetDpiForSystem" returns i32
```

Binds the native Windows GetDpiForSystem API used before a top-level handle exists.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L325)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getdpiforwindow-extern-function-getdpiforwindow-hwnd-as-ptr-from-user32-dll-symbol-getdpiforwindow-returns-i32-src-minisql-platform-win32-gui-ml-2121342785"></a>
### GetDpiForWindow

```ml
extern function GetDpiForWindow(hwnd as ptr) from "user32.dll" symbol "GetDpiForWindow" returns i32
```

Binds the native Windows GetDpiForWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L323)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getlasterror-extern-function-getlasterror-from-kernel32-dll-symbol-getlasterror-returns-u32-src-minisql-platform-win32-gui-ml-779378002"></a>
### GetLastError

```ml
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
```

Binds the native Windows GetLastError API used by the GUI abstraction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L307)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getmodulehandlew-extern-function-getmodulehandlew-modulename-as-ptr-from-kernel32-dll-symbol-getmodulehandlew-returns-ptr-src-minisql-platform-win32-gui-ml-1201220328"></a>
### GetModuleHandleW

```ml
extern function GetModuleHandleW(moduleName as ptr) from "kernel32.dll" symbol "GetModuleHandleW" returns ptr
```

Binds the native Windows GetModuleHandleW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `moduleName` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L303)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getsavefilenamew-extern-function-getsavefilenamew-configuration-as-bytes-from-comdlg32-dll-symbol-getsavefilenamew-returns-bool-src-minisql-platform-win32-gui-ml-1379805373"></a>
### GetSaveFileNameW

```ml
extern function GetSaveFileNameW(configuration as bytes) from "comdlg32.dll" symbol "GetSaveFileNameW" returns bool
```

Opens the native Save As dialog for CSV export.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `configuration` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L411)

<a id="function-function-minisql-platform-win32-gui-getsecretbytes-function-getsecretbytes-hwnd-src-minisql-platform-win32-gui-ml-481232903"></a>
### getSecretBytes

```ml
function getSecretBytes(hwnd)
```

Reads a password directly into bytes and clears both temporary UTF-16 storage and the editor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1282)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getstockobject-extern-function-getstockobject-kind-as-i32-from-gdi32-dll-symbol-getstockobject-returns-ptr-src-minisql-platform-win32-gui-ml-2120016914"></a>
### GetStockObject

```ml
extern function GetStockObject(kind as i32) from "gdi32.dll" symbol "GetStockObject" returns ptr
```

Binds the native Windows GetStockObject API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L357)

<a id="function-function-minisql-platform-win32-gui-gettext-function-gettext-hwnd-src-minisql-platform-win32-gui-ml-178979833"></a>
### getText

```ml
function getText(hwnd)
```

Reads complete Unicode control text into a validated MiniLang string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1183)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getwindowrect-extern-function-getwindowrect-hwnd-as-ptr-rectangle-as-bytes-from-user32-dll-symbol-getwindowrect-returns-bool-src-minisql-platform-win32-gui-ml-700566039"></a>
### GetWindowRect

```ml
extern function GetWindowRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetWindowRect" returns bool
```

Binds the native Windows GetWindowRect API used by geometry assertions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `rectangle` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L319)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getwindowtextlengthw-extern-function-getwindowtextlengthw-hwnd-as-ptr-from-user32-dll-symbol-getwindowtextlengthw-returns-i32-src-minisql-platform-win32-gui-ml-264800829"></a>
### GetWindowTextLengthW

```ml
extern function GetWindowTextLengthW(hwnd as ptr) from "user32.dll" symbol "GetWindowTextLengthW" returns i32
```

Binds the native Windows GetWindowTextLengthW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L275)

<a id="extern_function-extern-function-minisql-platform-win32-gui-getwindowtextw-extern-function-getwindowtextw-hwnd-as-ptr-buffer-as-bytes-maxcount-as-i32-from-user32-dll-symbol-getwindowtextw-returns-i32-src-minisql-platform-win32-gui-ml-743811971"></a>
### GetWindowTextW

```ml
extern function GetWindowTextW(hwnd as ptr, buffer as bytes, maxCount as i32) from "user32.dll" symbol "GetWindowTextW" returns i32
```

Binds the native Windows GetWindowTextW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `buffer` | `bytes` | — |  |
| `maxCount` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L277)

<a id="extern_function-extern-function-minisql-platform-win32-gui-globalalloc-extern-function-globalalloc-flags-as-u32-size-as-u64-from-kernel32-dll-symbol-globalalloc-returns-ptr-src-minisql-platform-win32-gui-ml-1871671889"></a>
### GlobalAlloc

```ml
extern function GlobalAlloc(flags as u32, size as u64) from "kernel32.dll" symbol "GlobalAlloc" returns ptr
```

Allocates a movable process heap block required by SetClipboardData.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `flags` | `u32` | — |  |
| `size` | `u64` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L401)

<a id="extern_function-extern-function-minisql-platform-win32-gui-globalfree-extern-function-globalfree-memory-as-ptr-from-kernel32-dll-symbol-globalfree-returns-ptr-src-minisql-platform-win32-gui-ml-1499424594"></a>
### GlobalFree

```ml
extern function GlobalFree(memory as ptr) from "kernel32.dll" symbol "GlobalFree" returns ptr
```

Releases a global memory block when clipboard publication fails.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memory` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L407)

<a id="extern_function-extern-function-minisql-platform-win32-gui-globallock-extern-function-globallock-memory-as-ptr-from-kernel32-dll-symbol-globallock-returns-ptr-src-minisql-platform-win32-gui-ml-1066379687"></a>
### GlobalLock

```ml
extern function GlobalLock(memory as ptr) from "kernel32.dll" symbol "GlobalLock" returns ptr
```

Locks a movable global memory block and returns its stable data pointer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memory` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L403)

<a id="extern_function-extern-function-minisql-platform-win32-gui-globalsize-extern-function-globalsize-memory-as-ptr-from-kernel32-dll-symbol-globalsize-returns-u64-src-minisql-platform-win32-gui-ml-1435790882"></a>
### GlobalSize

```ml
extern function GlobalSize(memory as ptr) from "kernel32.dll" symbol "GlobalSize" returns u64
```

Returns the byte size of a global memory block used by clipboard reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memory` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L409)

<a id="extern_function-extern-function-minisql-platform-win32-gui-globalunlock-extern-function-globalunlock-memory-as-ptr-from-kernel32-dll-symbol-globalunlock-returns-bool-src-minisql-platform-win32-gui-ml-95061192"></a>
### GlobalUnlock

```ml
extern function GlobalUnlock(memory as ptr) from "kernel32.dll" symbol "GlobalUnlock" returns bool
```

Unlocks a movable global memory block after copying data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memory` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L405)

<a id="constant-constant-minisql-platform-win32-gui-gmem-moveable-const-gmem-moveable-2-src-minisql-platform-win32-gui-ml-1134127231"></a>
### GMEM_MOVEABLE

```ml
const GMEM_MOVEABLE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L160)

<a id="constant-constant-minisql-platform-win32-gui-gmem-zeroinit-const-gmem-zeroinit-64-src-minisql-platform-win32-gui-ml-713306559"></a>
### GMEM_ZEROINIT

```ml
const GMEM_ZEROINIT = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L161)

<a id="constant-constant-minisql-platform-win32-gui-gui-error-const-gui-error-9040-src-minisql-platform-win32-gui-ml-2095931756"></a>
### GUI_ERROR

```ml
const GUI_ERROR = 9040
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L15)

<a id="global-global-minisql-platform-win32-gui-guiclassnamewide-guiclassnamewide-src-minisql-platform-win32-gui-ml-947133690"></a>
### guiClassNameWide

```ml
guiClassNameWide
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L254)

<a id="global-global-minisql-platform-win32-gui-guiclassregistered-guiclassregistered-src-minisql-platform-win32-gui-ml-1057400886"></a>
### guiClassRegistered

```ml
guiClassRegistered
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L253)

- [minisql.platform.win32_gui.GuiEvent](Type-minisql-platform-win32-gui-guievent-597858165.md) — struct
<a id="global-global-minisql-platform-win32-gui-guievents-guievents-src-minisql-platform-win32-gui-ml-667744512"></a>
### guiEvents

```ml
guiEvents
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L252)

<a id="function-function-minisql-platform-win32-gui-hiddenwindowsmoke-function-hiddenwindowsmoke-src-minisql-platform-win32-gui-ml-1274681812"></a>
### hiddenWindowSmoke

```ml
function hiddenWindowSmoke()
```

Creates and destroys a hidden top-level window to validate runtime Win32 integration.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L810)

<a id="constant-constant-minisql-platform-win32-gui-icc-bar-classes-const-icc-bar-classes-4-src-minisql-platform-win32-gui-ml-2003615873"></a>
### ICC_BAR_CLASSES

```ml
const ICC_BAR_CLASSES = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L99)

<a id="constant-constant-minisql-platform-win32-gui-icc-listview-classes-const-icc-listview-classes-1-src-minisql-platform-win32-gui-ml-914404104"></a>
### ICC_LISTVIEW_CLASSES

```ml
const ICC_LISTVIEW_CLASSES = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L97)

<a id="constant-constant-minisql-platform-win32-gui-icc-tab-classes-const-icc-tab-classes-8-src-minisql-platform-win32-gui-ml-1348859213"></a>
### ICC_TAB_CLASSES

```ml
const ICC_TAB_CLASSES = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L100)

<a id="constant-constant-minisql-platform-win32-gui-icc-treeview-classes-const-icc-treeview-classes-2-src-minisql-platform-win32-gui-ml-1898396873"></a>
### ICC_TREEVIEW_CLASSES

```ml
const ICC_TREEVIEW_CLASSES = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L98)

<a id="constant-constant-minisql-platform-win32-gui-idc-arrow-const-idc-arrow-32512-src-minisql-platform-win32-gui-ml-418675854"></a>
### IDC_ARROW

```ml
const IDC_ARROW = 32512
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L95)

<a id="constant-constant-minisql-platform-win32-gui-idyes-const-idyes-6-src-minisql-platform-win32-gui-ml-1344143511"></a>
### IDYES

```ml
const IDYES = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L158)

<a id="extern_function-extern-function-minisql-platform-win32-gui-initcommoncontrolsex-extern-function-initcommoncontrolsex-configuration-as-bytes-from-comctl32-dll-symbol-initcommoncontrolsex-returns-bool-src-minisql-platform-win32-gui-ml-1863544198"></a>
### InitCommonControlsEx

```ml
extern function InitCommonControlsEx(configuration as bytes) from "comctl32.dll" symbol "InitCommonControlsEx" returns bool
```

Binds the native Windows InitCommonControlsEx API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `configuration` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L341)

<a id="function-function-minisql-platform-win32-gui-initializecommoncontrols-function-initializecommoncontrols-src-minisql-platform-win32-gui-ml-261248526"></a>
### initializeCommonControls

```ml
function initializeCommonControls()
```

Initializes the common-control classes required by trees, tabs, and ListViews.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L585)

<a id="constant-constant-minisql-platform-win32-gui-invalid-argument-const-invalid-argument-9001-src-minisql-platform-win32-gui-ml-338177675"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Public geometry in this module is expressed in device-independent pixels. Native structure buffers below deliberately use the Windows x64 layouts, while the window procedure copies only immutable event metadata into a FIFO; application controllers remain the sole owners of behavioral state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L14)

<a id="constant-constant-minisql-platform-win32-gui-io-failure-const-io-failure-9005-src-minisql-platform-win32-gui-ml-688674891"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L16)

<a id="extern_function-extern-function-minisql-platform-win32-gui-isdialogmessagew-extern-function-isdialogmessagew-hwnd-as-ptr-message-as-bytes-from-user32-dll-symbol-isdialogmessagew-returns-bool-src-minisql-platform-win32-gui-ml-19621405"></a>
### IsDialogMessageW

```ml
extern function IsDialogMessageW(hwnd as ptr, message as bytes) from "user32.dll" symbol "IsDialogMessageW" returns bool
```

Routes Tab, Shift+Tab, Enter, and mnemonic input among ordinary child controls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L373)

<a id="function-function-minisql-platform-win32-gui-isenabled-function-isenabled-hwnd-src-minisql-platform-win32-gui-ml-2146954317"></a>
### isEnabled

```ml
function isEnabled(hwnd)
```

Returns the effective Win32 enabled state of one control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1734)

<a id="function-function-minisql-platform-win32-gui-isimplemented-function-isimplemented-src-minisql-platform-win32-gui-ml-151805354"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the native Win32 adapter is available in this build.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1867)

<a id="function-function-minisql-platform-win32-gui-isopen-function-isopen-hwnd-src-minisql-platform-win32-gui-ml-594062155"></a>
### isOpen

```ml
function isOpen(hwnd)
```

Returns whether a native handle still names a live window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1822)

<a id="extern_function-extern-function-minisql-platform-win32-gui-iswindow-extern-function-iswindow-hwnd-as-ptr-from-user32-dll-symbol-iswindow-returns-bool-src-minisql-platform-win32-gui-ml-69328351"></a>
### IsWindow

```ml
extern function IsWindow(hwnd as ptr) from "user32.dll" symbol "IsWindow" returns bool
```

Binds the native Windows IsWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L349)

<a id="extern_function-extern-function-minisql-platform-win32-gui-iswindowenabled-extern-function-iswindowenabled-hwnd-as-ptr-from-user32-dll-symbol-iswindowenabled-returns-bool-src-minisql-platform-win32-gui-ml-1685452124"></a>
### IsWindowEnabled

```ml
extern function IsWindowEnabled(hwnd as ptr) from "user32.dll" symbol "IsWindowEnabled" returns bool
```

Binds the native Windows enabled-state query used by interaction smoke tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L351)

<a id="constant-constant-minisql-platform-win32-gui-lb-addstring-const-lb-addstring-384-src-minisql-platform-win32-gui-ml-2086608500"></a>
### LB_ADDSTRING

```ml
const LB_ADDSTRING = 384
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L81)

<a id="constant-constant-minisql-platform-win32-gui-lb-err-const-lb-err-1-src-minisql-platform-win32-gui-ml-559244049"></a>
### LB_ERR

```ml
const LB_ERR = -1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L87)

<a id="constant-constant-minisql-platform-win32-gui-lb-getcursel-const-lb-getcursel-392-src-minisql-platform-win32-gui-ml-512157455"></a>
### LB_GETCURSEL

```ml
const LB_GETCURSEL = 392
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L83)

<a id="constant-constant-minisql-platform-win32-gui-lb-gettext-const-lb-gettext-393-src-minisql-platform-win32-gui-ml-1956959918"></a>
### LB_GETTEXT

```ml
const LB_GETTEXT = 393
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L84)

<a id="constant-constant-minisql-platform-win32-gui-lb-gettextlen-const-lb-gettextlen-394-src-minisql-platform-win32-gui-ml-638273881"></a>
### LB_GETTEXTLEN

```ml
const LB_GETTEXTLEN = 394
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L85)

<a id="constant-constant-minisql-platform-win32-gui-lb-resetcontent-const-lb-resetcontent-388-src-minisql-platform-win32-gui-ml-745953228"></a>
### LB_RESETCONTENT

```ml
const LB_RESETCONTENT = 388
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L82)

<a id="constant-constant-minisql-platform-win32-gui-lb-setcursel-const-lb-setcursel-390-src-minisql-platform-win32-gui-ml-351390897"></a>
### LB_SETCURSEL

```ml
const LB_SETCURSEL = 390
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L86)

<a id="constant-constant-minisql-platform-win32-gui-lbs-nointegralheight-const-lbs-nointegralheight-256-src-minisql-platform-win32-gui-ml-860853374"></a>
### LBS_NOINTEGRALHEIGHT

```ml
const LBS_NOINTEGRALHEIGHT = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L36)

<a id="constant-constant-minisql-platform-win32-gui-lbs-notify-const-lbs-notify-1-src-minisql-platform-win32-gui-ml-36000646"></a>
### LBS_NOTIFY

```ml
const LBS_NOTIFY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L35)

<a id="function-function-minisql-platform-win32-gui-listadd-function-listadd-hwnd-text-src-minisql-platform-win32-gui-ml-1735557164"></a>
### listAdd

```ml
function listAdd(hwnd, text)
```

Appends one Unicode item to a list box and returns its index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1320)

<a id="function-function-minisql-platform-win32-gui-listreset-function-listreset-hwnd-src-minisql-platform-win32-gui-ml-293305817"></a>
### listReset

```ml
function listReset(hwnd)
```

Removes every item from a list box.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1313)

<a id="function-function-minisql-platform-win32-gui-listselect-function-listselect-hwnd-index-src-minisql-platform-win32-gui-ml-1119567085"></a>
### listSelect

```ml
function listSelect(hwnd, index)
```

Selects one list-box item by zero-based index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1351)

<a id="function-function-minisql-platform-win32-gui-listselectedindex-function-listselectedindex-hwnd-src-minisql-platform-win32-gui-ml-610820889"></a>
### listSelectedIndex

```ml
function listSelectedIndex(hwnd)
```

Returns the selected list-box index or minus one when no row is selected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1345)

<a id="function-function-minisql-platform-win32-gui-listselectedtext-function-listselectedtext-hwnd-src-minisql-platform-win32-gui-ml-1587030843"></a>
### listSelectedText

```ml
function listSelectedText(hwnd)
```

Reads the complete Unicode text of the currently selected list-box item.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1331)

<a id="function-function-minisql-platform-win32-gui-listviewaddcolumn-function-listviewaddcolumn-hwnd-index-text-width-src-minisql-platform-win32-gui-ml-853655184"></a>
### listViewAddColumn

```ml
function listViewAddColumn(hwnd, index, text, width)
```

Inserts one report column using a pointer-safe x64 LVCOLUMNW buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1482)

<a id="function-function-minisql-platform-win32-gui-listviewaddrow-function-listviewaddrow-hwnd-rowindex-values-src-minisql-platform-win32-gui-ml-35957721"></a>
### listViewAddRow

```ml
function listViewAddRow(hwnd, rowIndex, values)
```

Inserts a result row and then fills its remaining subitems in column order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1498)

<a id="function-function-minisql-platform-win32-gui-listviewaddselection-function-listviewaddselection-hwnd-rowindex-src-minisql-platform-win32-gui-ml-99374059"></a>
### listViewAddSelection

```ml
function listViewAddSelection(hwnd, rowIndex)
```

Adds one row to the current report selection without clearing other rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1593)

<a id="function-function-minisql-platform-win32-gui-listviewcelltext-function-listviewcelltext-hwnd-rowindex-columnindex-src-minisql-platform-win32-gui-ml-1747693847"></a>
### listViewCellText

```ml
function listViewCellText(hwnd, rowIndex, columnIndex)
```

Reads one report cell through a dynamically sized LVITEMW text buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1542)

<a id="function-function-minisql-platform-win32-gui-listviewpointercell-function-listviewpointercell-hwnd-src-minisql-platform-win32-gui-ml-790306411"></a>
### listViewPointerCell

```ml
function listViewPointerCell(hwnd)
```

Returns the report row and subitem under the pointer, or [-1, -1].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1559)

<a id="function-function-minisql-platform-win32-gui-listviewreset-function-listviewreset-hwnd-src-minisql-platform-win32-gui-ml-932957311"></a>
### listViewReset

```ml
function listViewReset(hwnd)
```

Removes every result row while preserving the column schema.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1467)

<a id="function-function-minisql-platform-win32-gui-listviewresetcolumns-function-listviewresetcolumns-hwnd-src-minisql-platform-win32-gui-ml-1862495031"></a>
### listViewResetColumns

```ml
function listViewResetColumns(hwnd)
```

Deletes ListView columns from index zero until Windows reports none remain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1474)

<a id="function-function-minisql-platform-win32-gui-listviewrowcount-function-listviewrowcount-hwnd-src-minisql-platform-win32-gui-ml-474034459"></a>
### listViewRowCount

```ml
function listViewRowCount(hwnd)
```

Returns the number of report rows currently rendered in a native grid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1571)

<a id="function-function-minisql-platform-win32-gui-listviewselect-function-listviewselect-hwnd-rowindex-src-minisql-platform-win32-gui-ml-208815203"></a>
### listViewSelect

```ml
function listViewSelect(hwnd, rowIndex)
```

Selects and focuses one report row for deterministic keyboard and test workflows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `rowIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1577)

<a id="function-function-minisql-platform-win32-gui-listviewselectedindex-function-listviewselectedindex-hwnd-src-minisql-platform-win32-gui-ml-1383355475"></a>
### listViewSelectedIndex

```ml
function listViewSelectedIndex(hwnd)
```

Returns the selected report-row index, or -1 when the grid has no selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1524)

<a id="function-function-minisql-platform-win32-gui-listviewselectedindices-function-listviewselectedindices-hwnd-src-minisql-platform-win32-gui-ml-100142241"></a>
### listViewSelectedIndices

```ml
function listViewSelectedIndices(hwnd)
```

Returns every selected report-row index in ascending native order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1530)

<a id="extern_function-extern-function-minisql-platform-win32-gui-loadcursorw-extern-function-loadcursorw-instance-as-ptr-cursorname-as-ptr-from-user32-dll-symbol-loadcursorw-returns-ptr-src-minisql-platform-win32-gui-ml-1548540303"></a>
### LoadCursorW

```ml
extern function LoadCursorW(instance as ptr, cursorName as ptr) from "user32.dll" symbol "LoadCursorW" returns ptr
```

Binds the native Windows LoadCursorW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `instance` | `ptr` | — |  |
| `cursorName` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L309)

<a id="extern_function-extern-function-minisql-platform-win32-gui-loadlibraryw-extern-function-loadlibraryw-modulename-as-wstr-from-kernel32-dll-symbol-loadlibraryw-returns-ptr-src-minisql-platform-win32-gui-ml-1914680821"></a>
### LoadLibraryW

```ml
extern function LoadLibraryW(moduleName as wstr) from "kernel32.dll" symbol "LoadLibraryW" returns ptr
```

Loads the system RichEdit implementation required by the colorized SQL editor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `moduleName` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L305)

<a id="constant-constant-minisql-platform-win32-gui-lvcf-fmt-const-lvcf-fmt-1-src-minisql-platform-win32-gui-ml-801866686"></a>
### LVCF_FMT

```ml
const LVCF_FMT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L142)

<a id="constant-constant-minisql-platform-win32-gui-lvcf-subitem-const-lvcf-subitem-8-src-minisql-platform-win32-gui-ml-2055486033"></a>
### LVCF_SUBITEM

```ml
const LVCF_SUBITEM = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L145)

<a id="constant-constant-minisql-platform-win32-gui-lvcf-text-const-lvcf-text-4-src-minisql-platform-win32-gui-ml-2136301589"></a>
### LVCF_TEXT

```ml
const LVCF_TEXT = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L144)

<a id="constant-constant-minisql-platform-win32-gui-lvcf-width-const-lvcf-width-2-src-minisql-platform-win32-gui-ml-1537003657"></a>
### LVCF_WIDTH

```ml
const LVCF_WIDTH = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L143)

<a id="constant-constant-minisql-platform-win32-gui-lvif-state-const-lvif-state-8-src-minisql-platform-win32-gui-ml-1208965413"></a>
### LVIF_STATE

```ml
const LVIF_STATE = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L138)

<a id="constant-constant-minisql-platform-win32-gui-lvif-text-const-lvif-text-1-src-minisql-platform-win32-gui-ml-633701838"></a>
### LVIF_TEXT

```ml
const LVIF_TEXT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L137)

<a id="constant-constant-minisql-platform-win32-gui-lvis-focused-const-lvis-focused-1-src-minisql-platform-win32-gui-ml-1114200724"></a>
### LVIS_FOCUSED

```ml
const LVIS_FOCUSED = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L139)

<a id="constant-constant-minisql-platform-win32-gui-lvis-selected-const-lvis-selected-2-src-minisql-platform-win32-gui-ml-552060195"></a>
### LVIS_SELECTED

```ml
const LVIS_SELECTED = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L140)

<a id="constant-constant-minisql-platform-win32-gui-lvm-deleteallitems-const-lvm-deleteallitems-lvm-first-9-src-minisql-platform-win32-gui-ml-1443750969"></a>
### LVM_DELETEALLITEMS

```ml
const LVM_DELETEALLITEMS = LVM_FIRST + 9
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L127)

<a id="constant-constant-minisql-platform-win32-gui-lvm-deletecolumn-const-lvm-deletecolumn-lvm-first-28-src-minisql-platform-win32-gui-ml-1701729928"></a>
### LVM_DELETECOLUMN

```ml
const LVM_DELETECOLUMN = LVM_FIRST + 28
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L132)

<a id="constant-constant-minisql-platform-win32-gui-lvm-first-const-lvm-first-4096-src-minisql-platform-win32-gui-ml-1867548030"></a>
### LVM_FIRST

```ml
const LVM_FIRST = 4096
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L125)

<a id="constant-constant-minisql-platform-win32-gui-lvm-getitemcount-const-lvm-getitemcount-lvm-first-4-src-minisql-platform-win32-gui-ml-479733074"></a>
### LVM_GETITEMCOUNT

```ml
const LVM_GETITEMCOUNT = LVM_FIRST + 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L128)

<a id="constant-constant-minisql-platform-win32-gui-lvm-getitemtextw-const-lvm-getitemtextw-lvm-first-115-src-minisql-platform-win32-gui-ml-1592406517"></a>
### LVM_GETITEMTEXTW

```ml
const LVM_GETITEMTEXTW = LVM_FIRST + 115
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L135)

<a id="constant-constant-minisql-platform-win32-gui-lvm-getnextitem-const-lvm-getnextitem-lvm-first-12-src-minisql-platform-win32-gui-ml-833690981"></a>
### LVM_GETNEXTITEM

```ml
const LVM_GETNEXTITEM = LVM_FIRST + 12
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L133)

<a id="constant-constant-minisql-platform-win32-gui-lvm-insertcolumnw-const-lvm-insertcolumnw-lvm-first-97-src-minisql-platform-win32-gui-ml-882478038"></a>
### LVM_INSERTCOLUMNW

```ml
const LVM_INSERTCOLUMNW = LVM_FIRST + 97
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L131)

<a id="constant-constant-minisql-platform-win32-gui-lvm-insertitemw-const-lvm-insertitemw-lvm-first-77-src-minisql-platform-win32-gui-ml-1808003164"></a>
### LVM_INSERTITEMW

```ml
const LVM_INSERTITEMW = LVM_FIRST + 77
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L129)

<a id="constant-constant-minisql-platform-win32-gui-lvm-setextendedlistviewstyle-const-lvm-setextendedlistviewstyle-lvm-first-54-src-minisql-platform-win32-gui-ml-751387215"></a>
### LVM_SETEXTENDEDLISTVIEWSTYLE

```ml
const LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L126)

<a id="constant-constant-minisql-platform-win32-gui-lvm-setitemstate-const-lvm-setitemstate-lvm-first-43-src-minisql-platform-win32-gui-ml-1010061237"></a>
### LVM_SETITEMSTATE

```ml
const LVM_SETITEMSTATE = LVM_FIRST + 43
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L134)

<a id="constant-constant-minisql-platform-win32-gui-lvm-setitemtextw-const-lvm-setitemtextw-lvm-first-116-src-minisql-platform-win32-gui-ml-875267192"></a>
### LVM_SETITEMTEXTW

```ml
const LVM_SETITEMTEXTW = LVM_FIRST + 116
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L130)

<a id="constant-constant-minisql-platform-win32-gui-lvm-subitemhittest-const-lvm-subitemhittest-lvm-first-57-src-minisql-platform-win32-gui-ml-887102564"></a>
### LVM_SUBITEMHITTEST

```ml
const LVM_SUBITEMHITTEST = LVM_FIRST + 57
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L136)

<a id="constant-constant-minisql-platform-win32-gui-lvni-selected-const-lvni-selected-2-src-minisql-platform-win32-gui-ml-900454119"></a>
### LVNI_SELECTED

```ml
const LVNI_SELECTED = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L141)

<a id="constant-constant-minisql-platform-win32-gui-lvs-ex-doublebuffer-const-lvs-ex-doublebuffer-65536-src-minisql-platform-win32-gui-ml-485376104"></a>
### LVS_EX_DOUBLEBUFFER

```ml
const LVS_EX_DOUBLEBUFFER = 65536
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L124)

<a id="constant-constant-minisql-platform-win32-gui-lvs-ex-fullrowselect-const-lvs-ex-fullrowselect-32-src-minisql-platform-win32-gui-ml-1320341900"></a>
### LVS_EX_FULLROWSELECT

```ml
const LVS_EX_FULLROWSELECT = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L123)

<a id="constant-constant-minisql-platform-win32-gui-lvs-ex-gridlines-const-lvs-ex-gridlines-1-src-minisql-platform-win32-gui-ml-549631942"></a>
### LVS_EX_GRIDLINES

```ml
const LVS_EX_GRIDLINES = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L122)

<a id="constant-constant-minisql-platform-win32-gui-lvs-report-const-lvs-report-1-src-minisql-platform-win32-gui-ml-971888268"></a>
### LVS_REPORT

```ml
const LVS_REPORT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L119)

<a id="constant-constant-minisql-platform-win32-gui-lvs-showselalways-const-lvs-showselalways-8-src-minisql-platform-win32-gui-ml-2034548941"></a>
### LVS_SHOWSELALWAYS

```ml
const LVS_SHOWSELALWAYS = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L120)

<a id="constant-constant-minisql-platform-win32-gui-lvs-singlesel-const-lvs-singlesel-4-src-minisql-platform-win32-gui-ml-186414037"></a>
### LVS_SINGLESEL

```ml
const LVS_SINGLESEL = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L121)

<a id="extern_function-extern-function-minisql-platform-win32-gui-mapwindowpoints-extern-function-mapwindowpoints-fromwindow-as-ptr-towindow-as-ptr-points-as-bytes-pointcount-as-u32-from-user32-dll-symbol-mapwindowpoints-returns-i32-src-minisql-platform-win32-gui-ml-1093013005"></a>
### MapWindowPoints

```ml
extern function MapWindowPoints(fromWindow as ptr, toWindow as ptr, points as bytes, pointCount as u32) from "user32.dll" symbol "MapWindowPoints" returns i32
```

Binds the native Windows MapWindowPoints API used to express child rectangles in parent coordinates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fromWindow` | `ptr` | — |  |
| `toWindow` | `ptr` | — |  |
| `points` | `bytes` | — |  |
| `pointCount` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L321)

<a id="constant-constant-minisql-platform-win32-gui-max-control-text-utf16-units-const-max-control-text-utf16-units-32767-src-minisql-platform-win32-gui-ml-2103997364"></a>
### MAX_CONTROL_TEXT_UTF16_UNITS

```ml
const MAX_CONTROL_TEXT_UTF16_UNITS = 32767
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L90)

<a id="constant-constant-minisql-platform-win32-gui-max-edit-text-utf16-units-const-max-edit-text-utf16-units-2147483646-src-minisql-platform-win32-gui-ml-1109239930"></a>
### MAX_EDIT_TEXT_UTF16_UNITS

```ml
const MAX_EDIT_TEXT_UTF16_UNITS = 2147483646
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L75)

<a id="constant-constant-minisql-platform-win32-gui-mb-iconerror-const-mb-iconerror-16-src-minisql-platform-win32-gui-ml-298470850"></a>
### MB_ICONERROR

```ml
const MB_ICONERROR = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L155)

<a id="constant-constant-minisql-platform-win32-gui-mb-iconinformation-const-mb-iconinformation-64-src-minisql-platform-win32-gui-ml-1305218239"></a>
### MB_ICONINFORMATION

```ml
const MB_ICONINFORMATION = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L154)

<a id="constant-constant-minisql-platform-win32-gui-mb-iconwarning-const-mb-iconwarning-48-src-minisql-platform-win32-gui-ml-694761069"></a>
### MB_ICONWARNING

```ml
const MB_ICONWARNING = 48
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L157)

<a id="constant-constant-minisql-platform-win32-gui-mb-ok-const-mb-ok-0-src-minisql-platform-win32-gui-ml-1781922473"></a>
### MB_OK

```ml
const MB_OK = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L153)

<a id="constant-constant-minisql-platform-win32-gui-mb-yesno-const-mb-yesno-4-src-minisql-platform-win32-gui-ml-678724915"></a>
### MB_YESNO

```ml
const MB_YESNO = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L156)

<a id="constant-constant-minisql-platform-win32-gui-menu-admin-database-const-menu-admin-database-1400-src-minisql-platform-win32-gui-ml-295439728"></a>
### MENU_ADMIN_DATABASE

```ml
const MENU_ADMIN_DATABASE = 1400
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L195)

<a id="constant-constant-minisql-platform-win32-gui-menu-admin-security-const-menu-admin-security-1401-src-minisql-platform-win32-gui-ml-908750719"></a>
### MENU_ADMIN_SECURITY

```ml
const MENU_ADMIN_SECURITY = 1401
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L196)

<a id="constant-constant-minisql-platform-win32-gui-menu-alias-connect-const-menu-alias-connect-1100-src-minisql-platform-win32-gui-ml-232006295"></a>
### MENU_ALIAS_CONNECT

```ml
const MENU_ALIAS_CONNECT = 1100
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L182)

<a id="constant-constant-minisql-platform-win32-gui-menu-alias-delete-const-menu-alias-delete-1103-src-minisql-platform-win32-gui-ml-357118874"></a>
### MENU_ALIAS_DELETE

```ml
const MENU_ALIAS_DELETE = 1103
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L185)

<a id="constant-constant-minisql-platform-win32-gui-menu-alias-edit-const-menu-alias-edit-1102-src-minisql-platform-win32-gui-ml-1910611321"></a>
### MENU_ALIAS_EDIT

```ml
const MENU_ALIAS_EDIT = 1102
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L184)

<a id="constant-constant-minisql-platform-win32-gui-menu-alias-new-const-menu-alias-new-1101-src-minisql-platform-win32-gui-ml-1162319452"></a>
### MENU_ALIAS_NEW

```ml
const MENU_ALIAS_NEW = 1101
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L183)

<a id="constant-constant-minisql-platform-win32-gui-menu-alias-save-const-menu-alias-save-1104-src-minisql-platform-win32-gui-ml-1403929555"></a>
### MENU_ALIAS_SAVE

```ml
const MENU_ALIAS_SAVE = 1104
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L186)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-add-const-menu-data-add-1700-src-minisql-platform-win32-gui-ml-678500005"></a>
### MENU_DATA_ADD

```ml
const MENU_DATA_ADD = 1700
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L203)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-apply-const-menu-data-apply-1705-src-minisql-platform-win32-gui-ml-2121430530"></a>
### MENU_DATA_APPLY

```ml
const MENU_DATA_APPLY = 1705
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L208)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-copy-const-menu-data-copy-1701-src-minisql-platform-win32-gui-ml-1668228868"></a>
### MENU_DATA_COPY

```ml
const MENU_DATA_COPY = 1701
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L204)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-delete-const-menu-data-delete-1704-src-minisql-platform-win32-gui-ml-1175437955"></a>
### MENU_DATA_DELETE

```ml
const MENU_DATA_DELETE = 1704
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L207)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-edit-const-menu-data-edit-1703-src-minisql-platform-win32-gui-ml-493478472"></a>
### MENU_DATA_EDIT

```ml
const MENU_DATA_EDIT = 1703
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L206)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-paste-const-menu-data-paste-1702-src-minisql-platform-win32-gui-ml-782681587"></a>
### MENU_DATA_PASTE

```ml
const MENU_DATA_PASTE = 1702
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L205)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-preview-const-menu-data-preview-1707-src-minisql-platform-win32-gui-ml-589733564"></a>
### MENU_DATA_PREVIEW

```ml
const MENU_DATA_PREVIEW = 1707
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L210)

<a id="constant-constant-minisql-platform-win32-gui-menu-data-revert-const-menu-data-revert-1706-src-minisql-platform-win32-gui-ml-553114763"></a>
### MENU_DATA_REVERT

```ml
const MENU_DATA_REVERT = 1706
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L209)

<a id="constant-constant-minisql-platform-win32-gui-menu-file-close-const-menu-file-close-1001-src-minisql-platform-win32-gui-ml-801383847"></a>
### MENU_FILE_CLOSE

```ml
const MENU_FILE_CLOSE = 1001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L178)

<a id="constant-constant-minisql-platform-win32-gui-menu-file-close-worksheet-const-menu-file-close-worksheet-1003-src-minisql-platform-win32-gui-ml-906941701"></a>
### MENU_FILE_CLOSE_WORKSHEET

```ml
const MENU_FILE_CLOSE_WORKSHEET = 1003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L180)

<a id="constant-constant-minisql-platform-win32-gui-menu-file-exit-const-menu-file-exit-1002-src-minisql-platform-win32-gui-ml-1300882474"></a>
### MENU_FILE_EXIT

```ml
const MENU_FILE_EXIT = 1002
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L179)

<a id="constant-constant-minisql-platform-win32-gui-menu-file-export-const-menu-file-export-1004-src-minisql-platform-win32-gui-ml-1153369072"></a>
### MENU_FILE_EXPORT

```ml
const MENU_FILE_EXPORT = 1004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L181)

<a id="constant-constant-minisql-platform-win32-gui-menu-file-new-const-menu-file-new-1000-src-minisql-platform-win32-gui-ml-498401612"></a>
### MENU_FILE_NEW

```ml
const MENU_FILE_NEW = 1000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L177)

<a id="constant-constant-minisql-platform-win32-gui-menu-help-about-const-menu-help-about-1500-src-minisql-platform-win32-gui-ml-1051755555"></a>
### MENU_HELP_ABOUT

```ml
const MENU_HELP_ABOUT = 1500
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L197)

<a id="constant-constant-minisql-platform-win32-gui-menu-object-describe-const-menu-object-describe-1601-src-minisql-platform-win32-gui-ml-1101004949"></a>
### MENU_OBJECT_DESCRIBE

```ml
const MENU_OBJECT_DESCRIBE = 1601
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L199)

<a id="constant-constant-minisql-platform-win32-gui-menu-object-query-const-menu-object-query-1602-src-minisql-platform-win32-gui-ml-925144656"></a>
### MENU_OBJECT_QUERY

```ml
const MENU_OBJECT_QUERY = 1602
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L200)

<a id="constant-constant-minisql-platform-win32-gui-menu-object-schema-const-menu-object-schema-1603-src-minisql-platform-win32-gui-ml-895137443"></a>
### MENU_OBJECT_SCHEMA

```ml
const MENU_OBJECT_SCHEMA = 1603
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L201)

<a id="constant-constant-minisql-platform-win32-gui-menu-object-use-const-menu-object-use-1600-src-minisql-platform-win32-gui-ml-1294818418"></a>
### MENU_OBJECT_USE

```ml
const MENU_OBJECT_USE = 1600
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L198)

<a id="constant-constant-minisql-platform-win32-gui-menu-session-commit-const-menu-session-commit-1201-src-minisql-platform-win32-gui-ml-494145597"></a>
### MENU_SESSION_COMMIT

```ml
const MENU_SESSION_COMMIT = 1201
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L188)

<a id="constant-constant-minisql-platform-win32-gui-menu-session-refresh-const-menu-session-refresh-1200-src-minisql-platform-win32-gui-ml-388813716"></a>
### MENU_SESSION_REFRESH

```ml
const MENU_SESSION_REFRESH = 1200
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L187)

<a id="constant-constant-minisql-platform-win32-gui-menu-session-rollback-const-menu-session-rollback-1202-src-minisql-platform-win32-gui-ml-1589777100"></a>
### MENU_SESSION_ROLLBACK

```ml
const MENU_SESSION_ROLLBACK = 1202
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L189)

<a id="constant-constant-minisql-platform-win32-gui-menu-sql-cancel-const-menu-sql-cancel-1302-src-minisql-platform-win32-gui-ml-501814979"></a>
### MENU_SQL_CANCEL

```ml
const MENU_SQL_CANCEL = 1302
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L192)

<a id="constant-constant-minisql-platform-win32-gui-menu-sql-clear-const-menu-sql-clear-1303-src-minisql-platform-win32-gui-ml-792654606"></a>
### MENU_SQL_CLEAR

```ml
const MENU_SQL_CLEAR = 1303
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L193)

<a id="constant-constant-minisql-platform-win32-gui-menu-sql-execute-const-menu-sql-execute-1300-src-minisql-platform-win32-gui-ml-1998116391"></a>
### MENU_SQL_EXECUTE

```ml
const MENU_SQL_EXECUTE = 1300
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L190)

<a id="constant-constant-minisql-platform-win32-gui-menu-sql-execute-script-const-menu-sql-execute-script-1304-src-minisql-platform-win32-gui-ml-1507059749"></a>
### MENU_SQL_EXECUTE_SCRIPT

```ml
const MENU_SQL_EXECUTE_SCRIPT = 1304
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L194)

<a id="constant-constant-minisql-platform-win32-gui-menu-sql-explain-const-menu-sql-explain-1301-src-minisql-platform-win32-gui-ml-2144590496"></a>
### MENU_SQL_EXPLAIN

```ml
const MENU_SQL_EXPLAIN = 1301
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L191)

<a id="extern_function-extern-function-minisql-platform-win32-gui-messageboxw-extern-function-messageboxw-hwnd-as-ptr-text-as-wstr-caption-as-wstr-kind-as-u32-from-user32-dll-symbol-messageboxw-returns-i32-src-minisql-platform-win32-gui-ml-2090453897"></a>
### MessageBoxW

```ml
extern function MessageBoxW(hwnd as ptr, text as wstr, caption as wstr, kind as u32) from "user32.dll" symbol "MessageBoxW" returns i32
```

Shows a native informational dialog owned by the workbench.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `text` | `wstr` | — |  |
| `caption` | `wstr` | — |  |
| `kind` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L369)

<a id="constant-constant-minisql-platform-win32-gui-mf-popup-const-mf-popup-16-src-minisql-platform-win32-gui-ml-96373116"></a>
### MF_POPUP

```ml
const MF_POPUP = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L93)

<a id="constant-constant-minisql-platform-win32-gui-mf-string-const-mf-string-0-src-minisql-platform-win32-gui-ml-752401169"></a>
### MF_STRING

```ml
const MF_STRING = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L92)

<a id="global-global-minisql-platform-win32-gui-modernguifontdpis-modernguifontdpis-src-minisql-platform-win32-gui-ml-1753694188"></a>
### modernGuiFontDpis

```ml
modernGuiFontDpis
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L255)

<a id="global-global-minisql-platform-win32-gui-modernguifonts-modernguifonts-src-minisql-platform-win32-gui-ml-980687416"></a>
### modernGuiFonts

```ml
modernGuiFonts
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L256)

<a id="function-function-minisql-platform-win32-gui-move-function-move-hwnd-x-y-width-height-src-minisql-platform-win32-gui-ml-655803571"></a>
### move

```ml
function move(hwnd, x, y, width, height)
```

Moves a control using physical Win32 coordinates and repaints immediately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1608)

<a id="function-function-minisql-platform-win32-gui-movedip-function-movedip-hwnd-x-y-width-height-src-minisql-platform-win32-gui-ml-1772941027"></a>
### moveDip

```ml
function moveDip(hwnd, x, y, width, height)
```

Moves a control using logical coordinates and defers repainting to the layout boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1630)

<a id="extern_function-extern-function-minisql-platform-win32-gui-movewindow-extern-function-movewindow-hwnd-as-ptr-x-as-i32-y-as-i32-width-as-i32-height-as-i32-repaint-as-bool-from-user32-dll-symbol-movewindow-returns-bool-src-minisql-platform-win32-gui-ml-1613539569"></a>
### MoveWindow

```ml
extern function MoveWindow(hwnd as ptr, x as i32, y as i32, width as i32, height as i32, repaint as bool) from "user32.dll" symbol "MoveWindow" returns bool
```

Binds the native Windows MoveWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `x` | `i32` | — |  |
| `y` | `i32` | — |  |
| `width` | `i32` | — |  |
| `height` | `i32` | — |  |
| `repaint` | `bool` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L315)

<a id="extern_function-extern-function-minisql-platform-win32-gui-multibytetowidechar-extern-function-multibytetowidechar-codepage-as-u32-flags-as-u32-source-as-bytes-sourcecount-as-i32-output-as-bytes-outputcount-as-i32-from-kernel32-dll-symbol-multibytetowidechar-returns-i32-src-minisql-platform-win32-gui-ml-1547507482"></a>
### MultiByteToWideChar

```ml
extern function MultiByteToWideChar(codePage as u32, flags as u32, source as bytes, sourceCount as i32, output as bytes, outputCount as i32) from "kernel32.dll" symbol "MultiByteToWideChar" returns i32
```

Binds the native Windows MultiByteToWideChar API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `codePage` | `u32` | — |  |
| `flags` | `u32` | — |  |
| `source` | `bytes` | — |  |
| `sourceCount` | `i32` | — |  |
| `output` | `bytes` | — |  |
| `outputCount` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L335)

<a id="constant-constant-minisql-platform-win32-gui-ofn-overwriteprompt-const-ofn-overwriteprompt-2-src-minisql-platform-win32-gui-ml-1292672503"></a>
### OFN_OVERWRITEPROMPT

```ml
const OFN_OVERWRITEPROMPT = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L166)

<a id="constant-constant-minisql-platform-win32-gui-ofn-pathmustexist-const-ofn-pathmustexist-2048-src-minisql-platform-win32-gui-ml-735090795"></a>
### OFN_PATHMUSTEXIST

```ml
const OFN_PATHMUSTEXIST = 2048
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L167)

<a id="extern_function-extern-function-minisql-platform-win32-gui-openclipboard-extern-function-openclipboard-hwnd-as-ptr-from-user32-dll-symbol-openclipboard-returns-bool-src-minisql-platform-win32-gui-ml-1359093207"></a>
### OpenClipboard

```ml
extern function OpenClipboard(hwnd as ptr) from "user32.dll" symbol "OpenClipboard" returns bool
```

Opens the process clipboard for Unicode row copy and paste.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L391)

<a id="function-function-minisql-platform-win32-gui-openclipboardwithretry-function-openclipboardwithretry-owner-src-minisql-platform-win32-gui-ml-74691727"></a>
### openClipboardWithRetry

```ml
function openClipboardWithRetry(owner)
```

Acquires the process-wide Windows clipboard with a bounded retry because clipboard viewers and other desktop applications may own it momentarily.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1196)

<a id="function-function-minisql-platform-win32-gui-outersizeforclient-function-outersizeforclient-width-height-dpivalue-hasmenu-src-minisql-platform-win32-gui-ml-9020732"></a>
### outerSizeForClient

```ml
function outerSizeForClient(width, height, dpiValue, hasMenu)
```

Calculates a DPI-aware outer window size for the requested client area.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `dpiValue` | `dynamic` | — |  |
| `hasMenu` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L483)

<a id="extern_function-extern-function-minisql-platform-win32-gui-peekmessagew-extern-function-peekmessagew-message-as-bytes-hwnd-as-ptr-filtermin-as-u32-filtermax-as-u32-removemessage-as-u32-from-user32-dll-symbol-peekmessagew-returns-bool-src-minisql-platform-win32-gui-ml-964751165"></a>
### PeekMessageW

```ml
extern function PeekMessageW(message as bytes, hwnd as ptr, filterMin as u32, filterMax as u32, removeMessage as u32) from "user32.dll" symbol "PeekMessageW" returns bool
```

Binds the native Windows PeekMessageW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `bytes` | — |  |
| `hwnd` | `ptr` | — |  |
| `filterMin` | `u32` | — |  |
| `filterMax` | `u32` | — |  |
| `removeMessage` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L343)

<a id="constant-constant-minisql-platform-win32-gui-pm-remove-const-pm-remove-1-src-minisql-platform-win32-gui-ml-320942978"></a>
### PM_REMOVE

```ml
const PM_REMOVE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L42)

<a id="function-function-minisql-platform-win32-gui-pollevent-function-pollevent-src-minisql-platform-win32-gui-ml-617929572"></a>
### pollEvent

```ml
function pollEvent()
```

Removes and returns the oldest controller event from the process-wide FIFO.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L623)

<a id="function-function-minisql-platform-win32-gui-postcommandfortest-function-postcommandfortest-hwnd-controlid-src-minisql-platform-win32-gui-ml-1870300781"></a>
### postCommandForTest

```ml
function postCommandForTest(hwnd, controlId)
```

Posts a real WM_COMMAND to exercise the same queue path as a user action.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `controlId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L645)

<a id="extern_function-extern-function-minisql-platform-win32-gui-postmessagew-extern-function-postmessagew-hwnd-as-ptr-message-as-u32-wparam-as-ptr-lparam-as-ptr-from-user32-dll-symbol-postmessagew-returns-bool-src-minisql-platform-win32-gui-ml-998985271"></a>
### PostMessageW

```ml
extern function PostMessageW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "PostMessageW" returns bool
```

Binds the native Windows PostMessageW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `ptr` | — |  |
| `lParam` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L313)

<a id="extern_function-extern-function-minisql-platform-win32-gui-postquitmessage-extern-function-postquitmessage-exitcode-as-i32-from-user32-dll-symbol-postquitmessage-returns-void-src-minisql-platform-win32-gui-ml-1483309737"></a>
### PostQuitMessage

```ml
extern function PostQuitMessage(exitCode as i32) from "user32.dll" symbol "PostQuitMessage" returns void
```

Binds the native Windows PostQuitMessage API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `exitCode` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L311)

<a id="function-function-minisql-platform-win32-gui-pumpmessages-function-pumpmessages-src-minisql-platform-win32-gui-ml-898321282"></a>
### pumpMessages

```ml
function pumpMessages()
```

Dispatches a bounded batch of messages and applies dialog-style keyboard navigation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1801)

<a id="constant-constant-minisql-platform-win32-gui-rdw-allchildren-const-rdw-allchildren-128-src-minisql-platform-win32-gui-ml-1086852928"></a>
### RDW_ALLCHILDREN

```ml
const RDW_ALLCHILDREN = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L151)

<a id="constant-constant-minisql-platform-win32-gui-rdw-erase-const-rdw-erase-4-src-minisql-platform-win32-gui-ml-1420479213"></a>
### RDW_ERASE

```ml
const RDW_ERASE = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L150)

<a id="constant-constant-minisql-platform-win32-gui-rdw-invalidate-const-rdw-invalidate-1-src-minisql-platform-win32-gui-ml-1630264430"></a>
### RDW_INVALIDATE

```ml
const RDW_INVALIDATE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L149)

<a id="constant-constant-minisql-platform-win32-gui-rdw-updatenow-const-rdw-updatenow-256-src-minisql-platform-win32-gui-ml-1767633148"></a>
### RDW_UPDATENOW

```ml
const RDW_UPDATENOW = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L152)

<a id="function-function-minisql-platform-win32-gui-readpointer-function-readpointer-buffer-offset-src-minisql-platform-win32-gui-ml-1414361267"></a>
### readPointer

```ml
function readPointer(buffer, offset)
```

Reads one pointer-sized field from an x64 ABI structure buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L446)

<a id="function-function-minisql-platform-win32-gui-redraw-function-redraw-hwnd-src-minisql-platform-win32-gui-ml-1659648043"></a>
### redraw

```ml
function redraw(hwnd)
```

Invalidates a complete top-level window and all descendants after a layout transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1637)

<a id="extern_function-extern-function-minisql-platform-win32-gui-redrawwindow-extern-function-redrawwindow-hwnd-as-ptr-updaterectangle-as-ptr-updateregion-as-ptr-flags-as-u32-from-user32-dll-symbol-redrawwindow-returns-bool-src-minisql-platform-win32-gui-ml-559625224"></a>
### RedrawWindow

```ml
extern function RedrawWindow(hwnd as ptr, updateRectangle as ptr, updateRegion as ptr, flags as u32) from "user32.dll" symbol "RedrawWindow" returns bool
```

Binds the native Windows RedrawWindow API used to erase stale resized child surfaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `updateRectangle` | `ptr` | — |  |
| `updateRegion` | `ptr` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L333)

<a id="extern_function-extern-function-minisql-platform-win32-gui-registerclassexw-extern-function-registerclassexw-windowclass-as-bytes-from-user32-dll-symbol-registerclassexw-returns-u32-src-minisql-platform-win32-gui-ml-121015988"></a>
### RegisterClassExW

```ml
extern function RegisterClassExW(windowClass as bytes) from "user32.dll" symbol "RegisterClassExW" returns u32
```

Binds the native Windows RegisterClassExW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `windowClass` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L301)

<a id="function-function-minisql-platform-win32-gui-richeditdocumentoffset-function-richeditdocumentoffset-text-nativeoffset-src-minisql-platform-win32-gui-ml-1376752071"></a>
### richEditDocumentOffset

```ml
function richEditDocumentOffset(text, nativeOffset)
```

Maps RichEdit's CR-only selection coordinate back to public CRLF text units.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `nativeOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L949)

<a id="global-global-minisql-platform-win32-gui-richeditlibrary-richeditlibrary-src-minisql-platform-win32-gui-ml-411581412"></a>
### richEditLibrary

```ml
richEditLibrary
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L260)

<a id="function-function-minisql-platform-win32-gui-richeditnativeoffset-function-richeditnativeoffset-text-textoffset-src-minisql-platform-win32-gui-ml-430934467"></a>
### richEditNativeOffset

```ml
function richEditNativeOffset(text, textOffset)
```

Maps a public CRLF-preserving text offset to RichEdit's CR-only coordinate space.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `textOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L929)

<a id="function-function-minisql-platform-win32-gui-richeditsyntaxranges-function-richeditsyntaxranges-text-spans-src-minisql-platform-win32-gui-ml-53576058"></a>
### richEditSyntaxRanges

```ml
function richEditSyntaxRanges(text, spans)
```

Converts ordered presentation spans to RichEdit-native offsets in one linear pass.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `spans` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L977)

<a id="function-function-minisql-platform-win32-gui-routescloseevent-function-routescloseevent-hwnd-src-minisql-platform-win32-gui-ml-1985807803"></a>
### routesCloseEvent

```ml
function routesCloseEvent(hwnd)
```

Reports whether the owning controller asked to validate a native close request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L474)

<a id="extern_function-extern-function-minisql-platform-win32-gui-rtlmovememory-extern-function-rtlmovememory-destination-as-bytes-source-as-ptr-length-as-u64-from-kernel32-dll-symbol-rtlmovememory-returns-void-src-minisql-platform-win32-gui-ml-1940481577"></a>
### RtlMoveMemory

```ml
extern function RtlMoveMemory(destination as bytes, source as ptr, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
```

Binds the native Windows RtlMoveMemory API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `bytes` | — |  |
| `source` | `ptr` | — |  |
| `length` | `u64` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L337)

<a id="extern_function-extern-function-minisql-platform-win32-gui-rtlmovememorytoptr-extern-function-rtlmovememorytoptr-destination-as-ptr-source-as-bytes-length-as-u64-from-kernel32-dll-symbol-rtlmovememory-returns-void-src-minisql-platform-win32-gui-ml-1494990125"></a>
### RtlMoveMemoryToPtr

```ml
extern function RtlMoveMemoryToPtr(destination as ptr, source as bytes, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
```

Copies a modified native structure back to a pointer owned by Windows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `ptr` | — |  |
| `source` | `bytes` | — |  |
| `length` | `u64` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L339)

<a id="function-function-minisql-platform-win32-gui-scaleatdpi-function-scaleatdpi-value-dpivalue-src-minisql-platform-win32-gui-ml-1328273993"></a>
### scaleAtDpi

```ml
function scaleAtDpi(value, dpiValue)
```

Scales a DPI-independent pixel value for an explicit monitor DPI.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `dpiValue` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L458)

<a id="function-function-minisql-platform-win32-gui-scaledip-function-scaledip-hwnd-value-src-minisql-platform-win32-gui-ml-109513106"></a>
### scaleDip

```ml
function scaleDip(hwnd, value)
```

Scales one logical coordinate for the monitor currently hosting a window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1614)

<a id="constant-constant-minisql-platform-win32-gui-scf-selection-const-scf-selection-1-src-minisql-platform-win32-gui-ml-323842446"></a>
### SCF_SELECTION

```ml
const SCF_SELECTION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L68)

<a id="extern_function-extern-function-minisql-platform-win32-gui-screentoclient-extern-function-screentoclient-hwnd-as-ptr-point-as-bytes-from-user32-dll-symbol-screentoclient-returns-bool-src-minisql-platform-win32-gui-ml-412344708"></a>
### ScreenToClient

```ml
extern function ScreenToClient(hwnd as ptr, point as bytes) from "user32.dll" symbol "ScreenToClient" returns bool
```

Converts a screen-space point to coordinates relative to one native control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `point` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L379)

<a id="function-function-minisql-platform-win32-gui-selectnativetext-function-selectnativetext-hwnd-startoffset-endoffset-src-minisql-platform-win32-gui-ml-493526870"></a>
### selectNativeText

```ml
function selectNativeText(hwnd, startOffset, endOffset)
```

Selects one already translated RichEdit-native range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |
| `endOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1047)

<a id="function-function-minisql-platform-win32-gui-selecttext-function-selecttext-hwnd-startoffset-endoffset-src-minisql-platform-win32-gui-ml-929969310"></a>
### selectText

```ml
function selectText(hwnd, startOffset, endOffset)
```

Selects one CRLF-preserving UTF-16 range without modifying editor contents.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |
| `endOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1031)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewindexbuffer-extern-function-sendmessagewindexbuffer-hwnd-as-ptr-message-as-u32-wparam-as-i32-lparam-as-bytes-from-user32-dll-symbol-sendmessagew-returns-i32-src-minisql-platform-win32-gui-ml-1032055606"></a>
### SendMessageWIndexBuffer

```ml
extern function SendMessageWIndexBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns i32
```

Binds the native Windows SendMessageWIndexBuffer API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `i32` | — |  |
| `lParam` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L285)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewint-extern-function-sendmessagewint-hwnd-as-ptr-message-as-u32-wparam-as-i32-lparam-as-i32-from-user32-dll-symbol-sendmessagew-returns-i32-src-minisql-platform-win32-gui-ml-595284793"></a>
### SendMessageWInt

```ml
extern function SendMessageWInt(hwnd as ptr, message as u32, wParam as i32, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
```

Binds the native Windows SendMessageWInt API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `i32` | — |  |
| `lParam` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L279)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewintbuffer-extern-function-sendmessagewintbuffer-hwnd-as-ptr-message-as-u32-wparam-as-i32-lparam-as-bytes-from-user32-dll-symbol-sendmessagew-returns-ptr-src-minisql-platform-win32-gui-ml-1699800694"></a>
### SendMessageWIntBuffer

```ml
extern function SendMessageWIntBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
```

Binds the native Windows SendMessageWIntBuffer API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `i32` | — |  |
| `lParam` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L416)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewptr-extern-function-sendmessagewptr-hwnd-as-ptr-message-as-u32-wparam-as-ptr-lparam-as-ptr-from-user32-dll-symbol-sendmessagew-returns-ptr-src-minisql-platform-win32-gui-ml-294974773"></a>
### SendMessageWPtr

```ml
extern function SendMessageWPtr(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "SendMessageW" returns ptr
```

Binds the native Windows SendMessageWPtr API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `ptr` | — |  |
| `lParam` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L418)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewptrbuffer-extern-function-sendmessagewptrbuffer-hwnd-as-ptr-message-as-u32-wparam-as-ptr-lparam-as-bytes-from-user32-dll-symbol-sendmessagew-returns-ptr-src-minisql-platform-win32-gui-ml-201952918"></a>
### SendMessageWPtrBuffer

```ml
extern function SendMessageWPtrBuffer(hwnd as ptr, message as u32, wParam as ptr, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
```

Binds the native Windows SendMessageWPtrBuffer API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `ptr` | — |  |
| `lParam` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L414)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewptrint-extern-function-sendmessagewptrint-hwnd-as-ptr-message-as-u32-wparam-as-ptr-lparam-as-i32-from-user32-dll-symbol-sendmessagew-returns-i32-src-minisql-platform-win32-gui-ml-312611295"></a>
### SendMessageWPtrInt

```ml
extern function SendMessageWPtrInt(hwnd as ptr, message as u32, wParam as ptr, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
```

Binds the native Windows SendMessageWPtrInt API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `ptr` | — |  |
| `lParam` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L281)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sendmessagewtext-extern-function-sendmessagewtext-hwnd-as-ptr-message-as-u32-wparam-as-i32-lparam-as-wstr-from-user32-dll-symbol-sendmessagew-returns-i32-src-minisql-platform-win32-gui-ml-2136637941"></a>
### SendMessageWText

```ml
extern function SendMessageWText(hwnd as ptr, message as u32, wParam as i32, lParam as wstr) from "user32.dll" symbol "SendMessageW" returns i32
```

Binds the native Windows SendMessageWText API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `message` | `u32` | — |  |
| `wParam` | `i32` | — |  |
| `lParam` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L283)

<a id="function-function-minisql-platform-win32-gui-setclientsizedip-function-setclientsizedip-hwnd-width-height-hasmenu-src-minisql-platform-win32-gui-ml-237430337"></a>
### setClientSizeDip

```ml
function setClientSizeDip(hwnd, width, height, hasMenu)
```

Resizes a top-level window so its client area matches logical dimensions exactly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |
| `hasMenu` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1675)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setclipboarddata-extern-function-setclipboarddata-format-as-u32-memory-as-ptr-from-user32-dll-symbol-setclipboarddata-returns-ptr-src-minisql-platform-win32-gui-ml-866107570"></a>
### SetClipboardData

```ml
extern function SetClipboardData(format as u32, memory as ptr) from "user32.dll" symbol "SetClipboardData" returns ptr
```

Publishes a movable Unicode memory block to the clipboard.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `format` | `u32` | — |  |
| `memory` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L395)

<a id="function-function-minisql-platform-win32-gui-setcloseeventrouting-function-setcloseeventrouting-hwnd-enabled-src-minisql-platform-win32-gui-ml-837877830"></a>
### setCloseEventRouting

```ml
function setCloseEventRouting(hwnd, enabled)
```

Selects whether WM_CLOSE is queued for controller validation or destroys immediately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1663)

<a id="function-function-minisql-platform-win32-gui-setcuebanner-function-setcuebanner-hwnd-text-src-minisql-platform-win32-gui-ml-135148006"></a>
### setCueBanner

```ml
function setCueBanner(hwnd, text)
```

Sets the native placeholder text shown by an empty single-line editor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1177)

<a id="function-function-minisql-platform-win32-gui-setenabled-function-setenabled-hwnd-enabled-src-minisql-platform-win32-gui-ml-1487658042"></a>
### setEnabled

```ml
function setEnabled(hwnd, enabled)
```

Enables or disables one workbench control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1728)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setfocus-extern-function-setfocus-hwnd-as-ptr-from-user32-dll-symbol-setfocus-returns-ptr-src-minisql-platform-win32-gui-ml-1396189405"></a>
### SetFocus

```ml
extern function SetFocus(hwnd as ptr) from "user32.dll" symbol "SetFocus" returns ptr
```

Moves keyboard focus to a native editor or browser control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L367)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setmenu-extern-function-setmenu-hwnd-as-ptr-menu-as-ptr-from-user32-dll-symbol-setmenu-returns-bool-src-minisql-platform-win32-gui-ml-1499870699"></a>
### SetMenu

```ml
extern function SetMenu(hwnd as ptr, menu as ptr) from "user32.dll" symbol "SetMenu" returns bool
```

Binds the native Windows SetMenu API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `menu` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L295)

<a id="function-function-minisql-platform-win32-gui-setminimumclientsizedip-function-setminimumclientsizedip-hwnd-width-height-src-minisql-platform-win32-gui-ml-496306702"></a>
### setMinimumClientSizeDip

```ml
function setMinimumClientSizeDip(hwnd, width, height)
```

Registers a DPI-aware minimum client size consumed by WM_GETMINMAXINFO.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `width` | `dynamic` | — |  |
| `height` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1651)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setprocessdpiawarenesscontext-extern-function-setprocessdpiawarenesscontext-context-as-ptr-from-user32-dll-symbol-setprocessdpiawarenesscontext-returns-bool-src-minisql-platform-win32-gui-ml-1147011803"></a>
### SetProcessDpiAwarenessContext

```ml
extern function SetProcessDpiAwarenessContext(context as ptr) from "user32.dll" symbol "SetProcessDpiAwarenessContext" returns bool
```

Binds the native Windows SetProcessDpiAwarenessContext API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L327)

<a id="function-function-minisql-platform-win32-gui-settext-function-settext-hwnd-text-src-minisql-platform-win32-gui-ml-1797658124"></a>
### setText

```ml
function setText(hwnd, text)
```

Replaces control text through a dynamically sized UTF-16 buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1165)

<a id="function-function-minisql-platform-win32-gui-settoplevelrect-function-settoplevelrect-hwnd-rectangle-src-minisql-platform-win32-gui-ml-451269016"></a>
### setTopLevelRect

```ml
function setTopLevelRect(hwnd, rectangle)
```

Restores a validated top-level physical desktop rectangle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `rectangle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1711)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setwindowpos-extern-function-setwindowpos-hwnd-as-ptr-insertafter-as-ptr-x-as-i32-y-as-i32-width-as-i32-height-as-i32-flags-as-u32-from-user32-dll-symbol-setwindowpos-returns-bool-src-minisql-platform-win32-gui-ml-713263907"></a>
### SetWindowPos

```ml
extern function SetWindowPos(hwnd as ptr, insertAfter as ptr, x as i32, y as i32, width as i32, height as i32, flags as u32) from "user32.dll" symbol "SetWindowPos" returns bool
```

Binds the native Windows SetWindowPos API used for DPI changes and deterministic test sizes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `insertAfter` | `ptr` | — |  |
| `x` | `i32` | — |  |
| `y` | `i32` | — |  |
| `width` | `i32` | — |  |
| `height` | `i32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L331)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setwindowtextw-extern-function-setwindowtextw-hwnd-as-ptr-text-as-wstr-from-user32-dll-symbol-setwindowtextw-returns-bool-src-minisql-platform-win32-gui-ml-1818337356"></a>
### SetWindowTextW

```ml
extern function SetWindowTextW(hwnd as ptr, text as wstr) from "user32.dll" symbol "SetWindowTextW" returns bool
```

Binds the native Windows SetWindowTextW API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `text` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L273)

<a id="extern_function-extern-function-minisql-platform-win32-gui-setwindowtheme-extern-function-setwindowtheme-hwnd-as-ptr-subappname-as-wstr-subidlist-as-ptr-from-uxtheme-dll-symbol-setwindowtheme-returns-i32-src-minisql-platform-win32-gui-ml-13152811"></a>
### SetWindowTheme

```ml
extern function SetWindowTheme(hwnd as ptr, subAppName as wstr, subIdList as ptr) from "uxtheme.dll" symbol "SetWindowTheme" returns i32
```

Applies Explorer visual styles to common controls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `subAppName` | `wstr` | — |  |
| `subIdList` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L361)

<a id="function-function-minisql-platform-win32-gui-show-function-show-hwnd-visible-src-minisql-platform-win32-gui-ml-1008199915"></a>
### show

```ml
function show(hwnd, visible)
```

Shows or hides one control without changing its layout rectangle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `visible` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1720)

<a id="function-function-minisql-platform-win32-gui-showcontextmenu-function-showcontextmenu-owner-items-identifiers-src-minisql-platform-win32-gui-ml-895701585"></a>
### showContextMenu

```ml
function showContextMenu(owner, items, identifiers)
```

Displays a command-returning context menu at the current pointer position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `items` | `dynamic` | — |  |
| `identifiers` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L731)

<a id="function-function-minisql-platform-win32-gui-showerror-function-showerror-owner-title-message-src-minisql-platform-win32-gui-ml-1539960354"></a>
### showError

```ml
function showError(owner, title, message)
```

Displays a native error dialog; a zero owner supports pre-window startup failures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `title` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1754)

<a id="function-function-minisql-platform-win32-gui-showinfo-function-showinfo-owner-title-message-src-minisql-platform-win32-gui-ml-33800016"></a>
### showInfo

```ml
function showInfo(owner, title, message)
```

Displays a native informational message box.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `owner` | `dynamic` | — |  |
| `title` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1747)

<a id="function-function-minisql-platform-win32-gui-showtoplevel-function-showtoplevel-hwnd-src-minisql-platform-win32-gui-ml-2006180891"></a>
### showTopLevel

```ml
function showTopLevel(hwnd)
```

Shows a fully constructed top-level window without exposing its placeholder layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1643)

<a id="extern_function-extern-function-minisql-platform-win32-gui-showwindow-extern-function-showwindow-hwnd-as-ptr-command-as-i32-from-user32-dll-symbol-showwindow-returns-bool-src-minisql-platform-win32-gui-ml-1042697993"></a>
### ShowWindow

```ml
extern function ShowWindow(hwnd as ptr, command as i32) from "user32.dll" symbol "ShowWindow" returns bool
```

Binds the native Windows ShowWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `command` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L269)

<a id="extern_function-extern-function-minisql-platform-win32-gui-sleep-extern-function-sleep-milliseconds-as-u32-from-kernel32-dll-symbol-sleep-returns-void-src-minisql-platform-win32-gui-ml-850375443"></a>
### Sleep

```ml
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void
```

Binds the native Windows Sleep API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L353)

<a id="function-function-minisql-platform-win32-gui-sleep-function-sleep-milliseconds-src-minisql-platform-win32-gui-ml-1823262414"></a>
### sleep

```ml
function sleep(milliseconds)
```

Yields the current native thread for the requested polling interval.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1851)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-comment-const-sql-color-comment-6258495-src-minisql-platform-win32-gui-ml-1935697216"></a>
### SQL_COLOR_COMMENT

```ml
const SQL_COLOR_COMMENT = 6258495
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L217)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-default-const-sql-color-default-2829099-src-minisql-platform-win32-gui-ml-1050784070"></a>
### SQL_COLOR_DEFAULT

```ml
const SQL_COLOR_DEFAULT = 2829099
```

COLORREF palette shared by native SQL syntax rendering and its smoke tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L213)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-keyword-const-sql-color-keyword-10377728-src-minisql-platform-win32-gui-ml-1640783146"></a>
### SQL_COLOR_KEYWORD

```ml
const SQL_COLOR_KEYWORD = 10377728
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L214)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-number-const-sql-color-number-5801481-src-minisql-platform-win32-gui-ml-1724443286"></a>
### SQL_COLOR_NUMBER

```ml
const SQL_COLOR_NUMBER = 5801481
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L216)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-quoted-identifier-const-sql-color-quoted-identifier-10373753-src-minisql-platform-win32-gui-ml-733580352"></a>
### SQL_COLOR_QUOTED_IDENTIFIER

```ml
const SQL_COLOR_QUOTED_IDENTIFIER = 10373753
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L218)

<a id="constant-constant-minisql-platform-win32-gui-sql-color-string-const-sql-color-string-1381795-src-minisql-platform-win32-gui-ml-3367137"></a>
### SQL_COLOR_STRING

```ml
const SQL_COLOR_STRING = 1381795
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L215)

<a id="function-function-minisql-platform-win32-gui-sqleditorstyleat-function-sqleditorstyleat-hwnd-offset-src-minisql-platform-win32-gui-ml-1690023422"></a>
### sqlEditorStyleAt

```ml
function sqlEditorStyleAt(hwnd, offset)
```

Reads the native color and effects of one character for deterministic tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1109)

<a id="constant-constant-minisql-platform-win32-gui-sw-show-const-sw-show-5-src-minisql-platform-win32-gui-ml-2139277574"></a>
### SW_SHOW

```ml
const SW_SHOW = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L41)

<a id="constant-constant-minisql-platform-win32-gui-swp-noactivate-const-swp-noactivate-16-src-minisql-platform-win32-gui-ml-1813137002"></a>
### SWP_NOACTIVATE

```ml
const SWP_NOACTIVATE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L148)

<a id="constant-constant-minisql-platform-win32-gui-swp-nomove-const-swp-nomove-2-src-minisql-platform-win32-gui-ml-121248415"></a>
### SWP_NOMOVE

```ml
const SWP_NOMOVE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L147)

<a id="constant-constant-minisql-platform-win32-gui-swp-nozorder-const-swp-nozorder-4-src-minisql-platform-win32-gui-ml-1697263263"></a>
### SWP_NOZORDER

```ml
const SWP_NOZORDER = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L146)

<a id="function-function-minisql-platform-win32-gui-tabadd-function-tabadd-hwnd-text-src-minisql-platform-win32-gui-ml-1412728286"></a>
### tabAdd

```ml
function tabAdd(hwnd, text)
```

Appends one Unicode page label using the x64 TCITEMW layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1424)

<a id="function-function-minisql-platform-win32-gui-tabclosehitindexat-function-tabclosehitindexat-hwnd-x-y-src-minisql-platform-win32-gui-ml-957339638"></a>
### tabCloseHitIndexAt

```ml
function tabCloseHitIndexAt(hwnd, x, y)
```

Hit-tests a captured pointer against the trailing close-glyph region of a tab.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `y` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1452)

<a id="function-function-minisql-platform-win32-gui-tabitemrectangle-function-tabitemrectangle-hwnd-index-src-minisql-platform-win32-gui-ml-639598413"></a>
### tabItemRectangle

```ml
function tabItemRectangle(hwnd, index)
```

Returns one tab header rectangle in control-relative physical pixels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1443)

<a id="function-function-minisql-platform-win32-gui-tabreset-function-tabreset-hwnd-src-minisql-platform-win32-gui-ml-665707731"></a>
### tabReset

```ml
function tabReset(hwnd)
```

Removes every page label from a tab control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1417)

<a id="function-function-minisql-platform-win32-gui-tabselect-function-tabselect-hwnd-index-src-minisql-platform-win32-gui-ml-2051260971"></a>
### tabSelect

```ml
function tabSelect(hwnd, index)
```

Selects a tab page by zero-based index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1767)

<a id="function-function-minisql-platform-win32-gui-tabselectedindex-function-tabselectedindex-hwnd-src-minisql-platform-win32-gui-ml-404467707"></a>
### tabSelectedIndex

```ml
function tabSelectedIndex(hwnd)
```

Returns the currently selected zero-based tab index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1437)

<a id="function-function-minisql-platform-win32-gui-targetmilestone-function-targetmilestone-src-minisql-platform-win32-gui-ml-461939552"></a>
### targetMilestone

```ml
function targetMilestone()
```

Identifies the workbench milestone that introduced this Win32 adapter.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1862)

<a id="constant-constant-minisql-platform-win32-gui-tcif-text-const-tcif-text-1-src-minisql-platform-win32-gui-ml-689022714"></a>
### TCIF_TEXT

```ml
const TCIF_TEXT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L118)

<a id="constant-constant-minisql-platform-win32-gui-tcm-getcursel-const-tcm-getcursel-4875-src-minisql-platform-win32-gui-ml-853416685"></a>
### TCM_GETCURSEL

```ml
const TCM_GETCURSEL = 4875
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L115)

<a id="constant-constant-minisql-platform-win32-gui-tcm-getitemrect-const-tcm-getitemrect-4874-src-minisql-platform-win32-gui-ml-1975304038"></a>
### TCM_GETITEMRECT

```ml
const TCM_GETITEMRECT = 4874
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L116)

<a id="constant-constant-minisql-platform-win32-gui-tcm-hittest-const-tcm-hittest-4877-src-minisql-platform-win32-gui-ml-982859883"></a>
### TCM_HITTEST

```ml
const TCM_HITTEST = 4877
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L117)

<a id="constant-constant-minisql-platform-win32-gui-tcm-insertitemw-const-tcm-insertitemw-4926-src-minisql-platform-win32-gui-ml-271278346"></a>
### TCM_INSERTITEMW

```ml
const TCM_INSERTITEMW = 4926
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L114)

<a id="function-function-minisql-platform-win32-gui-textselection-function-textselection-hwnd-src-minisql-platform-win32-gui-ml-1669553601"></a>
### textSelection

```ml
function textSelection(hwnd)
```

Reads the RichEdit selection in the CRLF-preserving offsets used by MiniSQL text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1017)

<a id="function-function-minisql-platform-win32-gui-toplevelrect-function-toplevelrect-hwnd-src-minisql-platform-win32-gui-ml-1791653719"></a>
### topLevelRect

```ml
function topLevelRect(hwnd)
```

Returns one top-level window rectangle in physical desktop pixels for persistence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1699)

<a id="constant-constant-minisql-platform-win32-gui-tpm-returncmd-const-tpm-returncmd-256-src-minisql-platform-win32-gui-ml-1392506128"></a>
### TPM_RETURNCMD

```ml
const TPM_RETURNCMD = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L165)

<a id="constant-constant-minisql-platform-win32-gui-tpm-rightbutton-const-tpm-rightbutton-2-src-minisql-platform-win32-gui-ml-1556256315"></a>
### TPM_RIGHTBUTTON

```ml
const TPM_RIGHTBUTTON = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L164)

<a id="extern_function-extern-function-minisql-platform-win32-gui-trackpopupmenuex-extern-function-trackpopupmenuex-menu-as-ptr-flags-as-u32-x-as-i32-y-as-i32-hwnd-as-ptr-parameters-as-ptr-from-user32-dll-symbol-trackpopupmenuex-returns-u32-src-minisql-platform-win32-gui-ml-2048446467"></a>
### TrackPopupMenuEx

```ml
extern function TrackPopupMenuEx(menu as ptr, flags as u32, x as i32, y as i32, hwnd as ptr, parameters as ptr) from "user32.dll" symbol "TrackPopupMenuEx" returns u32
```

Displays a popup menu and returns the selected command without blocking controller state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `menu` | `ptr` | — |  |
| `flags` | `u32` | — |  |
| `x` | `i32` | — |  |
| `y` | `i32` | — |  |
| `hwnd` | `ptr` | — |  |
| `parameters` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L381)

<a id="extern_function-extern-function-minisql-platform-win32-gui-translateacceleratorw-extern-function-translateacceleratorw-hwnd-as-ptr-table-as-ptr-message-as-bytes-from-user32-dll-symbol-translateacceleratorw-returns-i32-src-minisql-platform-win32-gui-ml-995199893"></a>
### TranslateAcceleratorW

```ml
extern function TranslateAcceleratorW(hwnd as ptr, table as ptr, message as bytes) from "user32.dll" symbol "TranslateAcceleratorW" returns i32
```

Translates one queued key message into its registered workbench command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |
| `table` | `ptr` | — |  |
| `message` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L387)

<a id="extern_function-extern-function-minisql-platform-win32-gui-translatemessage-extern-function-translatemessage-message-as-bytes-from-user32-dll-symbol-translatemessage-returns-bool-src-minisql-platform-win32-gui-ml-1656411731"></a>
### TranslateMessage

```ml
extern function TranslateMessage(message as bytes) from "user32.dll" symbol "TranslateMessage" returns bool
```

Binds the native Windows TranslateMessage API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L345)

<a id="function-function-minisql-platform-win32-gui-treeexpand-function-treeexpand-hwnd-item-src-minisql-platform-win32-gui-ml-108263106"></a>
### treeExpand

```ml
function treeExpand(hwnd, item)
```

Expands one tree item so a freshly rebuilt object hierarchy is immediately useful.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `item` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1385)

<a id="function-function-minisql-platform-win32-gui-treeinsert-function-treeinsert-hwnd-parentitem-text-haschildren-src-minisql-platform-win32-gui-ml-380032704"></a>
### treeInsert

```ml
function treeInsert(hwnd, parentItem, text, hasChildren)
```

Inserts one Unicode TreeView node using the Windows x64 TVINSERTSTRUCTW layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `parentItem` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |
| `hasChildren` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1364)

<a id="function-function-minisql-platform-win32-gui-treereset-function-treereset-hwnd-src-minisql-platform-win32-gui-ml-154855181"></a>
### treeReset

```ml
function treeReset(hwnd)
```

Deletes all nodes and invalidates all prior native tree-item handles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1357)

<a id="function-function-minisql-platform-win32-gui-treeselect-function-treeselect-hwnd-item-src-minisql-platform-win32-gui-ml-1189616342"></a>
### treeSelect

```ml
function treeSelect(hwnd, item)
```

Selects one tree item without synthesizing mouse input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `item` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1391)

<a id="function-function-minisql-platform-win32-gui-treeselectedtext-function-treeselectedtext-hwnd-src-minisql-platform-win32-gui-ml-1627375611"></a>
### treeSelectedText

```ml
function treeSelectedText(hwnd)
```

Reads the selected TreeView item's text through a bounded TVITEMW buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1397)

<a id="constant-constant-minisql-platform-win32-gui-tve-expand-const-tve-expand-2-src-minisql-platform-win32-gui-ml-727886633"></a>
### TVE_EXPAND

```ml
const TVE_EXPAND = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L113)

<a id="constant-constant-minisql-platform-win32-gui-tvgn-caret-const-tvgn-caret-9-src-minisql-platform-win32-gui-ml-1283838802"></a>
### TVGN_CARET

```ml
const TVGN_CARET = 9
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L112)

<a id="constant-constant-minisql-platform-win32-gui-tvif-children-const-tvif-children-64-src-minisql-platform-win32-gui-ml-1021316271"></a>
### TVIF_CHILDREN

```ml
const TVIF_CHILDREN = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L106)

<a id="constant-constant-minisql-platform-win32-gui-tvif-text-const-tvif-text-1-src-minisql-platform-win32-gui-ml-433971326"></a>
### TVIF_TEXT

```ml
const TVIF_TEXT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L105)

<a id="constant-constant-minisql-platform-win32-gui-tvm-expand-const-tvm-expand-4354-src-minisql-platform-win32-gui-ml-1749230571"></a>
### TVM_EXPAND

```ml
const TVM_EXPAND = 4354
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L110)

<a id="constant-constant-minisql-platform-win32-gui-tvm-getitemw-const-tvm-getitemw-4414-src-minisql-platform-win32-gui-ml-190304266"></a>
### TVM_GETITEMW

```ml
const TVM_GETITEMW = 4414
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L109)

<a id="constant-constant-minisql-platform-win32-gui-tvm-getnextitem-const-tvm-getnextitem-4362-src-minisql-platform-win32-gui-ml-1799511056"></a>
### TVM_GETNEXTITEM

```ml
const TVM_GETNEXTITEM = 4362
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L108)

<a id="constant-constant-minisql-platform-win32-gui-tvm-insertitemw-const-tvm-insertitemw-4402-src-minisql-platform-win32-gui-ml-1447536459"></a>
### TVM_INSERTITEMW

```ml
const TVM_INSERTITEMW = 4402
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L107)

<a id="constant-constant-minisql-platform-win32-gui-tvm-selectitem-const-tvm-selectitem-4363-src-minisql-platform-win32-gui-ml-843153827"></a>
### TVM_SELECTITEM

```ml
const TVM_SELECTITEM = 4363
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L111)

<a id="constant-constant-minisql-platform-win32-gui-tvs-hasbuttons-const-tvs-hasbuttons-1-src-minisql-platform-win32-gui-ml-651746806"></a>
### TVS_HASBUTTONS

```ml
const TVS_HASBUTTONS = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L101)

<a id="constant-constant-minisql-platform-win32-gui-tvs-haslines-const-tvs-haslines-2-src-minisql-platform-win32-gui-ml-629231387"></a>
### TVS_HASLINES

```ml
const TVS_HASLINES = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L102)

<a id="constant-constant-minisql-platform-win32-gui-tvs-linesatroot-const-tvs-linesatroot-4-src-minisql-platform-win32-gui-ml-1970709269"></a>
### TVS_LINESATROOT

```ml
const TVS_LINESATROOT = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L103)

<a id="constant-constant-minisql-platform-win32-gui-tvs-showselalways-const-tvs-showselalways-32-src-minisql-platform-win32-gui-ml-1708646488"></a>
### TVS_SHOWSELALWAYS

```ml
const TVS_SHOWSELALWAYS = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L104)

<a id="function-function-minisql-platform-win32-gui-unscaledip-function-unscaledip-hwnd-value-src-minisql-platform-win32-gui-ml-1857266954"></a>
### unscaleDip

```ml
function unscaleDip(hwnd, value)
```

Converts a physical coordinate into a logical DPI-independent value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L1621)

<a id="extern_function-extern-function-minisql-platform-win32-gui-updatewindow-extern-function-updatewindow-hwnd-as-ptr-from-user32-dll-symbol-updatewindow-returns-bool-src-minisql-platform-win32-gui-ml-537150968"></a>
### UpdateWindow

```ml
extern function UpdateWindow(hwnd as ptr) from "user32.dll" symbol "UpdateWindow" returns bool
```

Binds the native Windows UpdateWindow API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L271)

<a id="function-function-minisql-platform-win32-gui-utf16bufferunits-function-utf16bufferunits-wide-src-minisql-platform-win32-gui-ml-1757590951"></a>
### utf16BufferUnits

```ml
function utf16BufferUnits(wide)
```

Counts UTF-16 code units in one NUL-terminated Win32 string buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wide` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L923)

<a id="function-function-minisql-platform-win32-gui-utf16bytes-function-utf16bytes-text-src-minisql-platform-win32-gui-ml-1838727015"></a>
### utf16Bytes

```ml
function utf16Bytes(text)
```

Encodes a MiniLang UTF-8 string as a NUL-terminated UTF-16LE Win32 buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L421)

<a id="constant-constant-minisql-platform-win32-gui-vk-e-const-vk-e-69-src-minisql-platform-win32-gui-ml-81377048"></a>
### VK_E

```ml
const VK_E = 69
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L175)

<a id="constant-constant-minisql-platform-win32-gui-vk-f5-const-vk-f5-116-src-minisql-platform-win32-gui-ml-409097069"></a>
### VK_F5

```ml
const VK_F5 = 116
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L171)

<a id="constant-constant-minisql-platform-win32-gui-vk-n-const-vk-n-78-src-minisql-platform-win32-gui-ml-330102524"></a>
### VK_N

```ml
const VK_N = 78
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L173)

<a id="constant-constant-minisql-platform-win32-gui-vk-return-const-vk-return-13-src-minisql-platform-win32-gui-ml-759394525"></a>
### VK_RETURN

```ml
const VK_RETURN = 13
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L172)

<a id="constant-constant-minisql-platform-win32-gui-vk-w-const-vk-w-87-src-minisql-platform-win32-gui-ml-860293828"></a>
### VK_W

```ml
const VK_W = 87
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L174)

<a id="constant-constant-minisql-platform-win32-gui-wc-err-invalid-chars-const-wc-err-invalid-chars-128-src-minisql-platform-win32-gui-ml-65912238"></a>
### WC_ERR_INVALID_CHARS

```ml
const WC_ERR_INVALID_CHARS = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L89)

<a id="function-function-minisql-platform-win32-gui-widebytestotext-function-widebytestotext-wide-units-src-minisql-platform-win32-gui-ml-1172002856"></a>
### wideBytesToText

```ml
function wideBytesToText(wide, units)
```

Decodes a counted UTF-16LE buffer into MiniLang's validated UTF-8 string form.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wide` | `dynamic` | — |  |
| `units` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L664)

<a id="extern_function-extern-function-minisql-platform-win32-gui-widechartomultibyte-extern-function-widechartomultibyte-codepage-as-u32-flags-as-u32-widetext-as-bytes-widecount-as-i32-output-as-bytes-outputcount-as-i32-defaultchar-as-ptr-useddefault-as-ptr-from-kernel32-dll-symbol-widechartomultibyte-returns-i32-src-minisql-platform-win32-gui-ml-1970395956"></a>
### WideCharToMultiByte

```ml
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32
```

Binds the native Windows WideCharToMultiByte API used by the GUI abstraction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `codePage` | `u32` | — |  |
| `flags` | `u32` | — |  |
| `wideText` | `bytes` | — |  |
| `wideCount` | `i32` | — |  |
| `output` | `bytes` | — |  |
| `outputCount` | `i32` | — |  |
| `defaultChar` | `ptr` | — |  |
| `usedDefault` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L355)

<a id="function-function-minisql-platform-win32-gui-windowminimum-function-windowminimum-hwnd-src-minisql-platform-win32-gui-ml-807449519"></a>
### windowMinimum

```ml
function windowMinimum(hwnd)
```

Finds the minimum-client constraint registered for a top-level window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L465)

- [minisql.platform.win32_gui.WindowMinimum](Type-minisql-platform-win32-gui-windowminimum-41689620.md) — struct
<a id="global-global-minisql-platform-win32-gui-windowminimums-windowminimums-src-minisql-platform-win32-gui-ml-648829698"></a>
### windowMinimums

```ml
windowMinimums
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L257)

<a id="function-function-minisql-platform-win32-gui-windowprocedure-function-windowprocedure-hwnd-message-wparam-lparam-src-minisql-platform-win32-gui-ml-1424683571"></a>
### windowProcedure

```ml
function windowProcedure(hwnd, message, wParam, lParam)
```

Converts relevant Win32 callbacks into queued controller events and handles native sizing contracts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hwnd` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |
| `wParam` | `dynamic` | — |  |
| `lParam` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L492)

<a id="constant-constant-minisql-platform-win32-gui-wm-close-const-wm-close-16-src-minisql-platform-win32-gui-ml-1244483386"></a>
### WM_CLOSE

```ml
const WM_CLOSE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L46)

<a id="constant-constant-minisql-platform-win32-gui-wm-command-const-wm-command-273-src-minisql-platform-win32-gui-ml-1295529451"></a>
### WM_COMMAND

```ml
const WM_COMMAND = 273
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L51)

<a id="constant-constant-minisql-platform-win32-gui-wm-contextmenu-const-wm-contextmenu-123-src-minisql-platform-win32-gui-ml-1366070133"></a>
### WM_CONTEXTMENU

```ml
const WM_CONTEXTMENU = 123
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L53)

<a id="constant-constant-minisql-platform-win32-gui-wm-destroy-const-wm-destroy-2-src-minisql-platform-win32-gui-ml-698946919"></a>
### WM_DESTROY

```ml
const WM_DESTROY = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L47)

<a id="constant-constant-minisql-platform-win32-gui-wm-dpichanged-const-wm-dpichanged-736-src-minisql-platform-win32-gui-ml-1470860705"></a>
### WM_DPICHANGED

```ml
const WM_DPICHANGED = 736
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L56)

<a id="constant-constant-minisql-platform-win32-gui-wm-getminmaxinfo-const-wm-getminmaxinfo-36-src-minisql-platform-win32-gui-ml-1767654152"></a>
### WM_GETMINMAXINFO

```ml
const WM_GETMINMAXINFO = 36
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L50)

<a id="constant-constant-minisql-platform-win32-gui-wm-lbuttondown-const-wm-lbuttondown-513-src-minisql-platform-win32-gui-ml-954200726"></a>
### WM_LBUTTONDOWN

```ml
const WM_LBUTTONDOWN = 513
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L54)

<a id="constant-constant-minisql-platform-win32-gui-wm-lbuttonup-const-wm-lbuttonup-514-src-minisql-platform-win32-gui-ml-1924540281"></a>
### WM_LBUTTONUP

```ml
const WM_LBUTTONUP = 514
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L55)

<a id="constant-constant-minisql-platform-win32-gui-wm-move-const-wm-move-3-src-minisql-platform-win32-gui-ml-874259420"></a>
### WM_MOVE

```ml
const WM_MOVE = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L48)

<a id="constant-constant-minisql-platform-win32-gui-wm-notify-const-wm-notify-78-src-minisql-platform-win32-gui-ml-328730822"></a>
### WM_NOTIFY

```ml
const WM_NOTIFY = 78
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L52)

<a id="constant-constant-minisql-platform-win32-gui-wm-setfont-const-wm-setfont-48-src-minisql-platform-win32-gui-ml-1809371767"></a>
### WM_SETFONT

```ml
const WM_SETFONT = 48
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L45)

<a id="constant-constant-minisql-platform-win32-gui-wm-setredraw-const-wm-setredraw-11-src-minisql-platform-win32-gui-ml-452401993"></a>
### WM_SETREDRAW

```ml
const WM_SETREDRAW = 11
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L44)

<a id="constant-constant-minisql-platform-win32-gui-wm-settext-const-wm-settext-12-src-minisql-platform-win32-gui-ml-609827148"></a>
### WM_SETTEXT

```ml
const WM_SETTEXT = 12
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L43)

<a id="constant-constant-minisql-platform-win32-gui-wm-size-const-wm-size-5-src-minisql-platform-win32-gui-ml-1752609982"></a>
### WM_SIZE

```ml
const WM_SIZE = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L49)

<a id="function-function-minisql-platform-win32-gui-writepointer-function-writepointer-buffer-offset-value-src-minisql-platform-win32-gui-ml-1778604020"></a>
### writePointer

```ml
function writePointer(buffer, offset, value)
```

Writes one non-negative native pointer into an x64 ABI structure buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L434)

<a id="function-function-minisql-platform-win32-gui-writespecialpointer-function-writespecialpointer-buffer-offset-low-src-minisql-platform-win32-gui-ml-1825765787"></a>
### writeSpecialPointer

```ml
function writeSpecialPointer(buffer, offset, low)
```

Writes a sign-extended Win32 sentinel such as TVI_ROOT or TVI_LAST.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `low` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L440)

<a id="constant-constant-minisql-platform-win32-gui-ws-border-const-ws-border-8388608-src-minisql-platform-win32-gui-ml-799746756"></a>
### WS_BORDER

```ml
const WS_BORDER = 8388608
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L21)

<a id="constant-constant-minisql-platform-win32-gui-ws-child-const-ws-child-1073741824-src-minisql-platform-win32-gui-ml-467848530"></a>
### WS_CHILD

```ml
const WS_CHILD = 1073741824
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L20)

<a id="constant-constant-minisql-platform-win32-gui-ws-clipchildren-const-ws-clipchildren-33554432-src-minisql-platform-win32-gui-ml-934517960"></a>
### WS_CLIPCHILDREN

```ml
const WS_CLIPCHILDREN = 33554432
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L26)

<a id="constant-constant-minisql-platform-win32-gui-ws-clipsiblings-const-ws-clipsiblings-67108864-src-minisql-platform-win32-gui-ml-1694235373"></a>
### WS_CLIPSIBLINGS

```ml
const WS_CLIPSIBLINGS = 67108864
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L27)

<a id="constant-constant-minisql-platform-win32-gui-ws-ex-clientedge-const-ws-ex-clientedge-512-src-minisql-platform-win32-gui-ml-446434453"></a>
### WS_EX_CLIENTEDGE

```ml
const WS_EX_CLIENTEDGE = 512
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L25)

<a id="constant-constant-minisql-platform-win32-gui-ws-hscroll-const-ws-hscroll-1048576-src-minisql-platform-win32-gui-ml-331327054"></a>
### WS_HSCROLL

```ml
const WS_HSCROLL = 1048576
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L23)

<a id="constant-constant-minisql-platform-win32-gui-ws-overlappedwindow-const-ws-overlappedwindow-13565952-src-minisql-platform-win32-gui-ml-602085663"></a>
### WS_OVERLAPPEDWINDOW

```ml
const WS_OVERLAPPEDWINDOW = 13565952
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L18)

<a id="constant-constant-minisql-platform-win32-gui-ws-tabstop-const-ws-tabstop-65536-src-minisql-platform-win32-gui-ml-2046053094"></a>
### WS_TABSTOP

```ml
const WS_TABSTOP = 65536
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L24)

<a id="constant-constant-minisql-platform-win32-gui-ws-visible-const-ws-visible-268435456-src-minisql-platform-win32-gui-ml-1481468334"></a>
### WS_VISIBLE

```ml
const WS_VISIBLE = 268435456
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L19)

<a id="constant-constant-minisql-platform-win32-gui-ws-vscroll-const-ws-vscroll-2097152-src-minisql-platform-win32-gui-ml-2001935689"></a>
### WS_VSCROLL

```ml
const WS_VSCROLL = 2097152
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/win32_gui.ml#L22)
