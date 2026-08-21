package minisql.platform.win32_gui

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

// Public geometry in this module is expressed in device-independent pixels.
// Native structure buffers below deliberately use the Windows x64 layouts,
// while the window procedure copies only immutable event metadata into a FIFO;
// application controllers remain the sole owners of behavioral state.

const INVALID_ARGUMENT = 9001
const GUI_ERROR = 9040
const IO_FAILURE = 9005

const WS_OVERLAPPEDWINDOW = 0x00CF0000
const WS_VISIBLE = 0x10000000
const WS_CHILD = 0x40000000
const WS_BORDER = 0x00800000
const WS_VSCROLL = 0x00200000
const WS_HSCROLL = 0x00100000
const WS_TABSTOP = 0x00010000
const WS_EX_CLIENTEDGE = 0x00000200
const WS_CLIPCHILDREN = 0x02000000
const WS_CLIPSIBLINGS = 0x04000000
const ES_MULTILINE = 0x0004
const ES_AUTOVSCROLL = 0x0040
const ES_AUTOHSCROLL = 0x0080
const ES_READONLY = 0x0800
const ES_WANTRETURN = 0x1000
const ES_PASSWORD = 0x0020
const ES_AUTOHSCROLL_SINGLE = 0x0080
const LBS_NOTIFY = 0x0001
const LBS_NOINTEGRALHEIGHT = 0x0100
const BS_PUSHBUTTON = 0
const BS_GROUPBOX = 7
const BS_DEFPUSHBUTTON = 1
const BS_AUTOCHECKBOX = 3
const SW_SHOW = 5
const PM_REMOVE = 1
const WM_SETTEXT = 0x000C
const WM_SETFONT = 0x0030
const WM_CLOSE = 0x0010
const WM_DESTROY = 0x0002
const WM_SIZE = 0x0005
const WM_GETMINMAXINFO = 0x0024
const WM_COMMAND = 0x0111
const WM_NOTIFY = 0x004E
const WM_DPICHANGED = 0x02E0
const EM_SETLIMITTEXT = 0x00C5
const MAX_EDIT_TEXT_UTF16_UNITS = 2147483646
const BM_GETSTATE = 0x00F2
const BM_GETCHECK = 0x00F0
const BM_SETCHECK = 0x00F1
const BST_CHECKED = 1
const BST_PUSHED = 0x0004
const LB_ADDSTRING = 0x0180
const LB_RESETCONTENT = 0x0184
const LB_GETCURSEL = 0x0188
const LB_GETTEXT = 0x0189
const LB_GETTEXTLEN = 0x018A
const LB_SETCURSEL = 0x0186
const LB_ERR = -1
const CP_UTF8 = 65001
const WC_ERR_INVALID_CHARS = 0x80
const MAX_CONTROL_TEXT_UTF16_UNITS = 32767
const DEFAULT_GUI_FONT = 17
const MF_STRING = 0
const MF_POPUP = 16
const COLOR_WINDOW = 5
const IDC_ARROW = 32512
const ERROR_CLASS_ALREADY_EXISTS = 1410
const ICC_LISTVIEW_CLASSES = 1
const ICC_TREEVIEW_CLASSES = 2
const ICC_BAR_CLASSES = 4
const ICC_TAB_CLASSES = 8
const TVS_HASBUTTONS = 1
const TVS_HASLINES = 2
const TVS_LINESATROOT = 4
const TVS_SHOWSELALWAYS = 32
const TVIF_TEXT = 1
const TVIF_CHILDREN = 64
const TVM_INSERTITEMW = 0x1132
const TVM_GETNEXTITEM = 0x110A
const TVM_GETITEMW = 0x113E
const TVM_EXPAND = 0x1102
const TVM_SELECTITEM = 0x110B
const TVGN_CARET = 9
const TVE_EXPAND = 2
const TCM_INSERTITEMW = 0x133E
const TCM_GETCURSEL = 0x130B
const TCIF_TEXT = 1
const LVS_REPORT = 1
const LVS_SHOWSELALWAYS = 8
const LVS_SINGLESEL = 4
const LVS_EX_GRIDLINES = 1
const LVS_EX_FULLROWSELECT = 32
const LVS_EX_DOUBLEBUFFER = 65536
const LVM_FIRST = 0x1000
const LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54
const LVM_DELETEALLITEMS = LVM_FIRST + 9
const LVM_INSERTITEMW = LVM_FIRST + 77
const LVM_SETITEMTEXTW = LVM_FIRST + 116
const LVM_INSERTCOLUMNW = LVM_FIRST + 97
const LVM_DELETECOLUMN = LVM_FIRST + 28
const LVIF_TEXT = 1
const LVCF_FMT = 1
const LVCF_WIDTH = 2
const LVCF_TEXT = 4
const LVCF_SUBITEM = 8
const SWP_NOZORDER = 4
const SWP_NOMOVE = 2
const SWP_NOACTIVATE = 16
const RDW_INVALIDATE = 1
const RDW_ERASE = 4
const RDW_ALLCHILDREN = 128
const RDW_UPDATENOW = 256
const MB_OK = 0
const MB_ICONINFORMATION = 64

const MENU_FILE_NEW = 1000
const MENU_FILE_CLOSE = 1001
const MENU_FILE_EXIT = 1002
const MENU_ALIAS_CONNECT = 1100
const MENU_ALIAS_NEW = 1101
const MENU_ALIAS_EDIT = 1102
const MENU_ALIAS_DELETE = 1103
const MENU_ALIAS_SAVE = 1104
const MENU_SESSION_REFRESH = 1200
const MENU_SESSION_COMMIT = 1201
const MENU_SESSION_ROLLBACK = 1202
const MENU_SQL_EXECUTE = 1300
const MENU_SQL_EXPLAIN = 1301
const MENU_SQL_CANCEL = 1302
const MENU_SQL_CLEAR = 1303
const MENU_ADMIN_DATABASE = 1400
const MENU_ADMIN_SECURITY = 1401
const MENU_HELP_ABOUT = 1500
const MENU_OBJECT_USE = 1600
const MENU_OBJECT_DESCRIBE = 1601
const MENU_OBJECT_QUERY = 1602

// Groups the native GuiEvent state used by the Windows workbench.
struct GuiEvent
  // Stores the hwnd value supplied by the Win32 event or control.
  hwnd
  // Stores the message value supplied by the Win32 event or control.
  message
  // Stores the controlId value supplied by the Win32 event or control.
  controlId
  // Stores the notification value supplied by the Win32 event or control.
  notification
  // Stores the source value supplied by the Win32 event or control.
  source
end struct

// Retains a top-level window's minimum client dimensions in DPI-independent pixels.
struct WindowMinimum
  // Identifies the top-level window governed by this constraint.
  hwnd
  // Stores the minimum usable client width in DIPs.
  width
  // Stores the minimum usable client height in DIPs.
  height
end struct

guiEvents = []
guiClassRegistered = false
guiClassNameWide = void
modernGuiFontDpis = []
modernGuiFonts = []
windowMinimums = []

// Binds the native Windows CreateWindowExW API used by the GUI abstraction.
extern function CreateWindowExW(exStyle as u32, className as wstr, windowName as wstr, style as u32, x as i32, y as i32, width as i32, height as i32, parent as ptr, menu as ptr, instance as ptr, param as ptr) from "user32.dll" symbol "CreateWindowExW" returns ptr
// Binds the native Windows DestroyWindow API used by the GUI abstraction.
extern function DestroyWindow(hwnd as ptr) from "user32.dll" symbol "DestroyWindow" returns i32
// Binds the native Windows GetDesktopWindow API used by the GUI abstraction.
extern function GetDesktopWindow() from "user32.dll" symbol "GetDesktopWindow" returns ptr
// Binds the native Windows ShowWindow API used by the GUI abstraction.
extern function ShowWindow(hwnd as ptr, command as i32) from "user32.dll" symbol "ShowWindow" returns bool
// Binds the native Windows UpdateWindow API used by the GUI abstraction.
extern function UpdateWindow(hwnd as ptr) from "user32.dll" symbol "UpdateWindow" returns bool
// Binds the native Windows SetWindowTextW API used by the GUI abstraction.
extern function SetWindowTextW(hwnd as ptr, text as wstr) from "user32.dll" symbol "SetWindowTextW" returns bool
// Binds the native Windows GetWindowTextLengthW API used by the GUI abstraction.
extern function GetWindowTextLengthW(hwnd as ptr) from "user32.dll" symbol "GetWindowTextLengthW" returns i32
// Binds the native Windows GetWindowTextW API used by the GUI abstraction.
extern function GetWindowTextW(hwnd as ptr, buffer as bytes, maxCount as i32) from "user32.dll" symbol "GetWindowTextW" returns i32
// Binds the native Windows SendMessageWInt API used by the GUI abstraction.
extern function SendMessageWInt(hwnd as ptr, message as u32, wParam as i32, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
// Binds the native Windows SendMessageWPtrInt API used by the GUI abstraction.
extern function SendMessageWPtrInt(hwnd as ptr, message as u32, wParam as ptr, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
// Binds the native Windows SendMessageWText API used by the GUI abstraction.
extern function SendMessageWText(hwnd as ptr, message as u32, wParam as i32, lParam as wstr) from "user32.dll" symbol "SendMessageW" returns i32
// Binds the native Windows SendMessageWIndexBuffer API used by the GUI abstraction.
extern function SendMessageWIndexBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns i32
// Binds the native Windows CreateMenu API used by the GUI abstraction.
extern function CreateMenu() from "user32.dll" symbol "CreateMenu" returns ptr
// Binds the native Windows CreatePopupMenu API used by the GUI abstraction.
extern function CreatePopupMenu() from "user32.dll" symbol "CreatePopupMenu" returns ptr
// Binds the native Windows AppendMenuWInt API used by the GUI abstraction.
extern function AppendMenuWInt(menu as ptr, flags as u32, itemId as u32, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
// Binds the native Windows AppendMenuWPtr API used by the GUI abstraction.
extern function AppendMenuWPtr(menu as ptr, flags as u32, item as ptr, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
// Binds the native Windows SetMenu API used by the GUI abstraction.
extern function SetMenu(hwnd as ptr, menu as ptr) from "user32.dll" symbol "SetMenu" returns bool
// Binds the native Windows DrawMenuBar API used by the GUI abstraction.
extern function DrawMenuBar(hwnd as ptr) from "user32.dll" symbol "DrawMenuBar" returns bool
// Binds the native Windows DefWindowProcW API used by the GUI abstraction.
extern function DefWindowProcW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "DefWindowProcW" returns ptr
// Binds the native Windows RegisterClassExW API used by the GUI abstraction.
extern function RegisterClassExW(windowClass as bytes) from "user32.dll" symbol "RegisterClassExW" returns u32
// Binds the native Windows GetModuleHandleW API used by the GUI abstraction.
extern function GetModuleHandleW(moduleName as ptr) from "kernel32.dll" symbol "GetModuleHandleW" returns ptr
// Binds the native Windows GetLastError API used by the GUI abstraction.
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
// Binds the native Windows LoadCursorW API used by the GUI abstraction.
extern function LoadCursorW(instance as ptr, cursorName as ptr) from "user32.dll" symbol "LoadCursorW" returns ptr
// Binds the native Windows PostQuitMessage API used by the GUI abstraction.
extern function PostQuitMessage(exitCode as i32) from "user32.dll" symbol "PostQuitMessage" returns void
// Binds the native Windows PostMessageW API used by the GUI abstraction.
extern function PostMessageW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "PostMessageW" returns bool
// Binds the native Windows MoveWindow API used by the GUI abstraction.
extern function MoveWindow(hwnd as ptr, x as i32, y as i32, width as i32, height as i32, repaint as bool) from "user32.dll" symbol "MoveWindow" returns bool
// Binds the native Windows GetClientRect API used by the GUI abstraction.
extern function GetClientRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetClientRect" returns bool
// Binds the native Windows GetWindowRect API used by geometry assertions.
extern function GetWindowRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetWindowRect" returns bool
// Binds the native Windows MapWindowPoints API used to express child rectangles in parent coordinates.
extern function MapWindowPoints(fromWindow as ptr, toWindow as ptr, points as bytes, pointCount as u32) from "user32.dll" symbol "MapWindowPoints" returns i32
// Binds the native Windows GetDpiForWindow API used by the GUI abstraction.
extern function GetDpiForWindow(hwnd as ptr) from "user32.dll" symbol "GetDpiForWindow" returns i32
// Binds the native Windows GetDpiForSystem API used before a top-level handle exists.
extern function GetDpiForSystem() from "user32.dll" symbol "GetDpiForSystem" returns i32
// Binds the native Windows SetProcessDpiAwarenessContext API used by the GUI abstraction.
extern function SetProcessDpiAwarenessContext(context as ptr) from "user32.dll" symbol "SetProcessDpiAwarenessContext" returns bool
// Binds the DPI-aware non-client size calculation used for exact client dimensions.
extern function AdjustWindowRectExForDpi(rectangle as bytes, style as u32, hasMenu as bool, exStyle as u32, dpiValue as u32) from "user32.dll" symbol "AdjustWindowRectExForDpi" returns bool
// Binds the native Windows SetWindowPos API used for DPI changes and deterministic test sizes.
extern function SetWindowPos(hwnd as ptr, insertAfter as ptr, x as i32, y as i32, width as i32, height as i32, flags as u32) from "user32.dll" symbol "SetWindowPos" returns bool
// Binds the native Windows RedrawWindow API used to erase stale resized child surfaces.
extern function RedrawWindow(hwnd as ptr, updateRectangle as ptr, updateRegion as ptr, flags as u32) from "user32.dll" symbol "RedrawWindow" returns bool
// Binds the native Windows MultiByteToWideChar API used by the GUI abstraction.
extern function MultiByteToWideChar(codePage as u32, flags as u32, source as bytes, sourceCount as i32, output as bytes, outputCount as i32) from "kernel32.dll" symbol "MultiByteToWideChar" returns i32
// Binds the native Windows RtlMoveMemory API used by the GUI abstraction.
extern function RtlMoveMemory(destination as bytes, source as ptr, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
// Copies a modified native structure back to a pointer owned by Windows.
extern function RtlMoveMemoryToPtr(destination as ptr, source as bytes, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
// Binds the native Windows InitCommonControlsEx API used by the GUI abstraction.
extern function InitCommonControlsEx(configuration as bytes) from "comctl32.dll" symbol "InitCommonControlsEx" returns bool
// Binds the native Windows PeekMessageW API used by the GUI abstraction.
extern function PeekMessageW(message as bytes, hwnd as ptr, filterMin as u32, filterMax as u32, removeMessage as u32) from "user32.dll" symbol "PeekMessageW" returns bool
// Binds the native Windows TranslateMessage API used by the GUI abstraction.
extern function TranslateMessage(message as bytes) from "user32.dll" symbol "TranslateMessage" returns bool
// Binds the native Windows DispatchMessageW API used by the GUI abstraction.
extern function DispatchMessageW(message as bytes) from "user32.dll" symbol "DispatchMessageW" returns ptr
// Binds the native Windows IsWindow API used by the GUI abstraction.
extern function IsWindow(hwnd as ptr) from "user32.dll" symbol "IsWindow" returns bool
// Binds the native Windows enabled-state query used by interaction smoke tests.
extern function IsWindowEnabled(hwnd as ptr) from "user32.dll" symbol "IsWindowEnabled" returns bool
// Binds the native Windows Sleep API used by the GUI abstraction.
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void
// Binds the native Windows WideCharToMultiByte API used by the GUI abstraction.
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32
// Binds the native Windows GetStockObject API used by the GUI abstraction.
extern function GetStockObject(kind as i32) from "gdi32.dll" symbol "GetStockObject" returns ptr
// Creates the shared Segoe UI font used by every workbench control.
extern function CreateFontW(height as i32, width as i32, escapement as i32, orientation as i32, weight as i32, italic as u32, underline as u32, strikeOut as u32, charSet as u32, outputPrecision as u32, clipPrecision as u32, quality as u32, pitchAndFamily as u32, faceName as wstr) from "gdi32.dll" symbol "CreateFontW" returns ptr
// Applies Explorer visual styles to common controls.
extern function SetWindowTheme(hwnd as ptr, subAppName as wstr, subIdList as ptr) from "uxtheme.dll" symbol "SetWindowTheme" returns i32
// Applies supported Windows 11 non-client chrome attributes.
extern function DwmSetWindowAttribute(hwnd as ptr, attribute as u32, value as bytes, size as u32) from "dwmapi.dll" symbol "DwmSetWindowAttribute" returns i32
// Enables or disables a native control while background work is active.
extern function EnableWindow(hwnd as ptr, enabled as bool) from "user32.dll" symbol "EnableWindow" returns bool
// Moves keyboard focus to a native editor or browser control.
extern function SetFocus(hwnd as ptr) from "user32.dll" symbol "SetFocus" returns ptr
// Shows a native informational dialog owned by the workbench.
extern function MessageBoxW(hwnd as ptr, text as wstr, caption as wstr, kind as u32) from "user32.dll" symbol "MessageBoxW" returns i32
// Returns the currently active top-level window for dialog-style keyboard routing.
extern function GetActiveWindow() from "user32.dll" symbol "GetActiveWindow" returns ptr
// Routes Tab, Shift+Tab, Enter, and mnemonic input among ordinary child controls.
extern function IsDialogMessageW(hwnd as ptr, message as bytes) from "user32.dll" symbol "IsDialogMessageW" returns bool

// Binds the native Windows SendMessageWPtrBuffer API used by the GUI abstraction.
extern function SendMessageWPtrBuffer(hwnd as ptr, message as u32, wParam as ptr, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
// Binds the native Windows SendMessageWIntBuffer API used by the GUI abstraction.
extern function SendMessageWIntBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
// Binds the native Windows SendMessageWPtr API used by the GUI abstraction.
extern function SendMessageWPtr(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "SendMessageW" returns ptr

// Encodes a MiniLang UTF-8 string as a NUL-terminated UTF-16LE Win32 buffer.
function utf16Bytes(text)
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.utf16Bytes: text must be string") end if
  source = bytes(text)
  if len(source) == 0 then return bytes(2, 0) end if
  units = MultiByteToWideChar(CP_UTF8, 8, source, len(source), void, 0)
  if units <= 0 then return fail("utf16Bytes", "UTF-8 to UTF-16 size query failed") end if
  output = bytes((units + 1) * 2, 0)
  actual = MultiByteToWideChar(CP_UTF8, 8, source, len(source), output, units)
  if actual != units then return fail("utf16Bytes", "UTF-8 to UTF-16 conversion failed") end if
  return output
end function

// Writes one non-negative native pointer into an x64 ABI structure buffer.
function writePointer(buffer, offset, value)
  endian.writeU64LE(buffer, offset, endian.uint64FromInt(value))
  return true
end function

// Writes a sign-extended Win32 sentinel such as TVI_ROOT or TVI_LAST.
function writeSpecialPointer(buffer, offset, low)
  endian.writeU64LE(buffer, offset, endian.makeUInt64(0xFFFFFFFF, low))
  return true
end function

// Reads one pointer-sized field from an x64 ABI structure buffer.
function readPointer(buffer, offset)
  return endian.uint64ToInt(endian.readU64LE(buffer, offset))
end function

// Divides integers with truncation while preserving MiniLang's integer runtime type.
function divideInt(numerator, denominator)
  if typeof(numerator) != "int" or typeof(denominator) != "int" or denominator <= 0 then return 0 end if
  if numerator < 0 then return -divideInt(-numerator, denominator) end if
  return (numerator - (numerator % denominator)) / denominator
end function

// Scales a DPI-independent pixel value for an explicit monitor DPI.
function scaleAtDpi(value, dpiValue)
  if typeof(value) != "int" or typeof(dpiValue) != "int" or dpiValue < 96 then return value end if
  if value < 0 then return -divideInt((-value) * dpiValue + 48, 96) end if
  return divideInt(value * dpiValue + 48, 96)
end function

// Finds the minimum-client constraint registered for a top-level window.
function windowMinimum(hwnd)
  global windowMinimums
  for each minimum in windowMinimums
    if minimum.hwnd == hwnd then return minimum end if
  end for
  return void
end function

// Calculates a DPI-aware outer window size for the requested client area.
function outerSizeForClient(width, height, dpiValue, hasMenu)
  rectangle = bytes(16, 0)
  endian.writeI32LE(rectangle, 8, scaleAtDpi(width, dpiValue))
  endian.writeI32LE(rectangle, 12, scaleAtDpi(height, dpiValue))
  if not AdjustWindowRectExForDpi(rectangle, WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN, hasMenu, 0, dpiValue) then return fail("outerSizeForClient", "AdjustWindowRectExForDpi failed") end if
  return [endian.readI32LE(rectangle, 8) - endian.readI32LE(rectangle, 0), endian.readI32LE(rectangle, 12) - endian.readI32LE(rectangle, 4)]
end function

// Converts relevant Win32 callbacks into queued controller events and handles native sizing contracts.
function windowProcedure(hwnd, message, wParam, lParam)
  global guiEvents
  if message == WM_COMMAND then
    guiEvents = guiEvents + [GuiEvent(hwnd, message, wParam & 65535, (wParam >> 16) & 65535, lParam)]
    return 0
  end if
  if message == WM_NOTIFY then
    header = bytes(24, 0)
    RtlMoveMemory(header, lParam, 24)
    source = try(readPointer(header, 0))
    if typeof(source) == "error" then source = 0 end if
    controlId = try(readPointer(header, 8))
    if typeof(controlId) == "error" then controlId = 0 end if
    guiEvents = guiEvents + [GuiEvent(hwnd, message, controlId, endian.readI32LE(header, 16), source)]
    return 0
  end if
  if message == WM_SIZE then
    guiEvents = guiEvents + [GuiEvent(hwnd, message, lParam & 65535, (lParam >> 16) & 65535, 0)]
    return DefWindowProcW(hwnd, message, wParam, lParam)
  end if
  if message == WM_DPICHANGED then
    suggested = bytes(16, 0)
    RtlMoveMemory(suggested, lParam, 16)
    left = endian.readI32LE(suggested, 0)
    top = endian.readI32LE(suggested, 4)
    right = endian.readI32LE(suggested, 8)
    bottom = endian.readI32LE(suggested, 12)
    ignoredMove = SetWindowPos(hwnd, 0, left, top, right - left, bottom - top, SWP_NOZORDER | SWP_NOACTIVATE)
    guiEvents = guiEvents + [GuiEvent(hwnd, message, wParam & 65535, (wParam >> 16) & 65535, 0)]
    return 0
  end if
  if message == WM_GETMINMAXINFO then
    minimum = windowMinimum(hwnd)
    if minimum is not void then
      dpiValue = GetDpiForWindow(hwnd)
      if dpiValue < 96 then dpiValue = GetDpiForSystem() end if
      if dpiValue < 96 then dpiValue = 96 end if
      outer = try(outerSizeForClient(minimum.width, minimum.height, dpiValue, true))
      if typeof(outer) != "error" then
        info = bytes(40, 0)
        RtlMoveMemory(info, lParam, 40)
        endian.writeI32LE(info, 24, outer[0])
        endian.writeI32LE(info, 28, outer[1])
        RtlMoveMemoryToPtr(lParam, info, 40)
        return 0
      end if
    end if
  end if
  if message == WM_CLOSE then
    // Route native close-button destruction through the same lifecycle helper
    // as controller-driven closes so per-window retained state is released.
    ignored = destroy(hwnd)
    return 0
  end if
  if message == WM_DESTROY then
    return 0
  end if
  return DefWindowProcW(hwnd, message, wParam, lParam)
end function

// Initializes the common-control classes required by trees, tabs, and ListViews.
function initializeCommonControls()
  configuration = bytes(8, 0)
  endian.writeU32LE(configuration, 0, 8)
  endian.writeU32LE(configuration, 4, ICC_LISTVIEW_CLASSES | ICC_TREEVIEW_CLASSES | ICC_BAR_CLASSES | ICC_TAB_CLASSES)
  if not InitCommonControlsEx(configuration) then return fail("initializeCommonControls", "InitCommonControlsEx failed") end if
  return true
end function

// Registers the process-wide top-level window class exactly once.
function ensureWindowClass()
  global guiClassRegistered, guiClassNameWide
  if guiClassRegistered then return true end if
  ignoredDpi = SetProcessDpiAwarenessContext(-4)
  initialized = try(initializeCommonControls())
  if typeof(initialized) == "error" then return initialized end if
  className = try(utf16Bytes("MiniSQLAdminWindow13"))
  if typeof(className) == "error" then return className end if
  instance = GetModuleHandleW(void)
  if instance == 0 then return fail("ensureWindowClass", "module handle is unavailable") end if
  callback = nativeCallback(windowProcedure, "wndproc")
  if callback == 0 then return fail("ensureWindowClass", "window callback could not be created") end if
  windowClass = bytes(80, 0)
  endian.writeU32LE(windowClass, 0, 80)
  endian.writeU32LE(windowClass, 4, 3)
  writePointer(windowClass, 8, callback)
  writePointer(windowClass, 24, instance)
  cursor = LoadCursorW(void, IDC_ARROW)
  if cursor != 0 then writePointer(windowClass, 40, cursor) end if
  writePointer(windowClass, 48, COLOR_WINDOW + 1)
  writePointer(windowClass, 64, nativeBytesPtr(className))
  atom = RegisterClassExW(windowClass)
  if atom == 0 and GetLastError() != ERROR_CLASS_ALREADY_EXISTS then return fail("ensureWindowClass", "RegisterClassExW failed") end if
  guiClassNameWide = className
  guiClassRegistered = true
  return true
end function

// Removes and returns the oldest controller event from the process-wide FIFO.
function pollEvent()
  global guiEvents
  if len(guiEvents) == 0 then return void end if
  first = guiEvents[0]
  remaining = []
  if len(guiEvents) > 1 then
    for index = 1 to len(guiEvents) - 1
      remaining = remaining + [guiEvents[index]]
    end for
  end if
  guiEvents = remaining
  return first
end function

// Discards queued native events at a test or window-lifecycle boundary.
function clearEvents()
  global guiEvents
  guiEvents = []
  return true
end function

// Posts a real WM_COMMAND to exercise the same queue path as a user action.
function postCommandForTest(hwnd, controlId)
  return PostMessageW(hwnd, WM_COMMAND, controlId, 0)
end function

// Creates a namespaced structured error for a failed GUI operation.
function fail(operation, message)
  return error(GUI_ERROR, "platform.win32_gui." + operation + ": " + message)
end function

// Decodes a counted UTF-16LE buffer into MiniLang's validated UTF-8 string form.
function wideBytesToText(wide, units)
  if typeof(wide) != "bytes" or typeof(units) != "int" or units < 0 or units * 2 > len(wide) then return error(INVALID_ARGUMENT, "platform.win32_gui.wideBytesToText: invalid UTF-16 input") end if
  if units == 0 then return "" end if
  required = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, void, 0, void, void)
  if required <= 0 then return fail("wideBytesToText", "UTF-16 to UTF-8 size query failed") end if
  output = bytes(required, 0)
  actual = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, output, required, void, void)
  if actual != required then return fail("wideBytesToText", "UTF-16 to UTF-8 conversion failed") end if
  decoded = decode(output)
  if typeof(decoded) != "string" then return fail("wideBytesToText", "UTF-8 decode failed") end if
  return decoded
end function

// Applies a cached per-DPI Segoe UI font, creating at most one GDI font per DPI.
function applyDefaultFont(hwnd)
  global modernGuiFontDpis, modernGuiFonts
  if hwnd == 0 then return false end if
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = GetDpiForSystem() end if
  if dpiValue < 96 then dpiValue = 96 end if
  font = 0
  if len(modernGuiFontDpis) > 0 then
    for index = 0 to len(modernGuiFontDpis) - 1
      if modernGuiFontDpis[index] == dpiValue then font = modernGuiFonts[index] end if
    end for
  end if
  if font == 0 then
    font = CreateFontW(-scaleAtDpi(16, dpiValue), 0, 0, 0, 400, 0, 0, 0, 1, 0, 0, 5, 0, "Segoe UI")
    if font != 0 then
      modernGuiFontDpis = modernGuiFontDpis + [dpiValue]
      modernGuiFonts = modernGuiFonts + [font]
    end if
  end if
  if font == 0 then font = GetStockObject(DEFAULT_GUI_FONT) end if
  if font == 0 then return false end if
  ignored = SendMessageWPtrInt(hwnd, WM_SETFONT, font, 1)
  return true
end function

// Applies modern Windows visual styles to a common control.
function applyControlTheme(hwnd)
  if hwnd == 0 then return false end if
  ignored = SetWindowTheme(hwnd, "Explorer", void)
  return true
end function

// Requests rounded Windows 11 top-level window corners when supported.
function applyWindowChrome(hwnd)
  if hwnd == 0 then return false end if
  preference = bytes(4, 0)
  endian.writeI32LE(preference, 0, 2)
  ignored = DwmSetWindowAttribute(hwnd, 33, preference, 4)
  return true
end function

// Builds one popup menu from positionally paired labels and command identifiers.
function createTopMenu(items, identifiers)
  if typeof(items) != "array" or typeof(identifiers) != "array" or len(items) == 0 or len(items) != len(identifiers) then return 0 end if
  menu = CreatePopupMenu()
  if menu == 0 then return menu end if
  for index = 0 to len(items) - 1
    ignored = AppendMenuWInt(menu, MF_STRING, identifiers[index], items[index])
  end for
  return menu
end function

// Attaches the complete MiniSQL workbench menu hierarchy to a top-level window.
function attachWorkbenchMenuBar(hwnd)
  if hwnd == 0 then return false end if
  mainMenu = CreateMenu()
  if mainMenu == 0 then return false end if
  fileMenu = createTopMenu(["New SQL Worksheet", "Disconnect", "Exit"], [MENU_FILE_NEW, MENU_FILE_CLOSE, MENU_FILE_EXIT])
  sessionMenu = createTopMenu(["Refresh Object Tree", "Commit Transaction", "Rollback Transaction"], [MENU_SESSION_REFRESH, MENU_SESSION_COMMIT, MENU_SESSION_ROLLBACK])
  sqlMenu = createTopMenu(["Execute SQL", "Explain SQL", "Stop Execution", "Clear Results"], [MENU_SQL_EXECUTE, MENU_SQL_EXPLAIN, MENU_SQL_CANCEL, MENU_SQL_CLEAR])
  objectMenu = createTopMenu(["Open Table Details", "Select First 100 Rows"], [MENU_OBJECT_DESCRIBE, MENU_OBJECT_QUERY])
  helpMenu = createTopMenu(["About MiniSQL Workbench"], [MENU_HELP_ABOUT])
  if fileMenu != 0 then ignoredFile = AppendMenuWPtr(mainMenu, MF_POPUP, fileMenu, "File") end if
  if sessionMenu != 0 then ignoredSession = AppendMenuWPtr(mainMenu, MF_POPUP, sessionMenu, "Session") end if
  if sqlMenu != 0 then ignoredSql = AppendMenuWPtr(mainMenu, MF_POPUP, sqlMenu, "SQL") end if
  if objectMenu != 0 then ignoredObject = AppendMenuWPtr(mainMenu, MF_POPUP, objectMenu, "Objects") end if
  if helpMenu != 0 then ignoredHelp = AppendMenuWPtr(mainMenu, MF_POPUP, helpMenu, "Help") end if
  if not SetMenu(hwnd, mainMenu) then return false end if
  ignoredDraw = DrawMenuBar(hwnd)
  return true
end function

// Attaches the smaller alias-management menu used before a session is open.
function attachConnectionMenuBar(hwnd)
  if hwnd == 0 then return false end if
  mainMenu = CreateMenu()
  if mainMenu == 0 then return false end if
  fileMenu = createTopMenu(["New Alias", "Exit"], [MENU_ALIAS_NEW, MENU_FILE_EXIT])
  aliasesMenu = createTopMenu(["Connect", "New Alias", "Edit Alias", "Save Alias", "Delete Alias"], [MENU_ALIAS_CONNECT, MENU_ALIAS_NEW, MENU_ALIAS_EDIT, MENU_ALIAS_SAVE, MENU_ALIAS_DELETE])
  helpMenu = createTopMenu(["About MiniSQL Workbench"], [MENU_HELP_ABOUT])
  if fileMenu != 0 then ignoredFile = AppendMenuWPtr(mainMenu, MF_POPUP, fileMenu, "File") end if
  if aliasesMenu != 0 then ignoredAliases = AppendMenuWPtr(mainMenu, MF_POPUP, aliasesMenu, "Aliases") end if
  if helpMenu != 0 then ignoredHelp = AppendMenuWPtr(mainMenu, MF_POPUP, helpMenu, "Help") end if
  if not SetMenu(hwnd, mainMenu) then return false end if
  ignoredDraw = DrawMenuBar(hwnd)
  return true
end function

// Creates and destroys a hidden top-level window to validate runtime Win32 integration.
function hiddenWindowSmoke()
  hwnd = try(createTopLevel("MiniSQL Admin Smoke", 320, 240, false))
  if typeof(hwnd) == "error" then return hwnd end if
  destroyed = DestroyWindow(hwnd)
  if destroyed == 0 then return fail("hiddenWindowSmoke", "hidden window could not be destroyed") end if
  return true
end function

// Creates a per-monitor-DPI-aware top-level window with the requested logical client size.
function createTopLevel(title, width, height, visible)
  if typeof(title) != "string" or len(title) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createTopLevel: title must be non-empty") end if
  if typeof(width) != "int" or width < 320 or typeof(height) != "int" or height < 240 then return error(INVALID_ARGUMENT, "platform.win32_gui.createTopLevel: size is too small") end if
  initialized = try(ensureWindowClass())
  if typeof(initialized) == "error" then return initialized end if
  dpiValue = GetDpiForSystem()
  if dpiValue < 96 then dpiValue = 96 end if
  outer = try(outerSizeForClient(width, height, dpiValue, false))
  if typeof(outer) == "error" then return outer end if
  style = WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN
  if visible then style = style | WS_VISIBLE end if
  hwnd = CreateWindowExW(0, "MiniSQLAdminWindow13", title, style, scaleAtDpi(80, dpiValue), scaleAtDpi(80, dpiValue), outer[0], outer[1], void, void, GetModuleHandleW(void), void)
  if hwnd == 0 then return fail("createTopLevel", "top-level window could not be created") end if
  ignoredFont = applyDefaultFont(hwnd)
  ignoredChrome = applyWindowChrome(hwnd)
  if visible then
    ignoredShow = ShowWindow(hwnd, SW_SHOW)
    ignoredUpdate = UpdateWindow(hwnd)
  end if
  return hwnd
end function

// Creates a child control with an explicit command identifier and shared visual policy.
function createChildId(parent, className, text, x, y, width, height, style, exStyle, controlId)
  if parent == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createChild: parent is required") end if
  if typeof(className) != "string" or len(className) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createChild: className must be non-empty") end if
  childStyle = WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | style
  hwnd = CreateWindowExW(exStyle, className, text, childStyle, x, y, width, height, parent, controlId, GetModuleHandleW(void), void)
  if hwnd == 0 then return fail("createChild", "child " + className + " could not be created") end if
  ignoredFont = applyDefaultFont(hwnd)
  if className == "BUTTON" or className == "SysTreeView32" or className == "SysTabControl32" or className == "SysListView32" then ignoredTheme = applyControlTheme(hwnd) end if
  return hwnd
end function

// Creates an anonymous child control used only for direct handle-based access.
function createChild(parent, className, text, x, y, width, height, style, exStyle)
  return createChildId(parent, className, text, x, y, width, height, style, exStyle, 0)
end function

// Creates a static text label.
function createLabel(parent, text, x, y, width, height)
  return createChild(parent, "STATIC", text, x, y, width, height, 0, 0)
end function

// Creates a visual group box around related controls.
function createGroupBox(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_GROUPBOX, 0)
end function

// Creates an anonymous push button.
function createButton(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0)
end function

// Creates a push button that reports its command identifier to the controller.
function createButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

// Creates the dialog's default push button, activated by the Enter key.
function createDefaultButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_DEFPUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

// Creates an automatically toggled checkbox with a controller command identifier.
function createCheckBoxId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_AUTOCHECKBOX | WS_TABSTOP, 0, controlId)
end function

// Creates a multiline worksheet or read-only detail editor.
function createEdit(parent, text, x, y, width, height, readOnly)
  style = WS_BORDER | WS_TABSTOP | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_WANTRETURN | WS_VSCROLL | WS_HSCROLL
  if readOnly then style = style | ES_READONLY end if
  hwnd = try(createChild(parent, "EDIT", text, x, y, width, height, style, WS_EX_CLIENTEDGE))
  if typeof(hwnd) == "error" then return hwnd end if
  // The classic EDIT default is too small for real migration scripts. Raising
  // it to the Win32 signed-count ceiling leaves capacity governed by memory.
  ignoredLimit = SendMessageWInt(hwnd, EM_SETLIMITTEXT, MAX_EDIT_TEXT_UTF16_UNITS, 0)
  return hwnd
end function

// Creates a single-line editor, optionally enabling native password masking.
function createTextBoxId(parent, controlId, text, x, y, width, height, password)
  style = WS_BORDER | WS_TABSTOP | ES_AUTOHSCROLL_SINGLE
  if password then style = style | ES_PASSWORD end if
  return createChildId(parent, "EDIT", text, x, y, width, height, style, WS_EX_CLIENTEDGE, controlId)
end function

// Creates an anonymous notifying list box.
function createListBox(parent, x, y, width, height)
  return createChild(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE)
end function

// Creates a notifying list box with a stable controller identifier.
function createListBoxId(parent, controlId, x, y, width, height)
  return createChildId(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE, controlId)
end function

// Creates the Explorer-themed MiniSQL object tree.
function createTreeView(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTreeView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | TVS_HASBUTTONS | TVS_HASLINES | TVS_LINESATROOT | TVS_SHOWSELALWAYS, WS_EX_CLIENTEDGE, controlId)
end function

// Creates an Explorer-themed notebook tab control.
function createTabControl(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTabControl32", "", x, y, width, height, WS_TABSTOP, 0, controlId)
end function

// Creates a double-buffered report ListView for structured query results.
function createListView(parent, controlId, x, y, width, height)
  hwnd = try(createChildId(parent, "SysListView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | WS_HSCROLL | LVS_REPORT | LVS_SHOWSELALWAYS | LVS_SINGLESEL, WS_EX_CLIENTEDGE, controlId))
  if typeof(hwnd) == "error" then return hwnd end if
  ignored = SendMessageWInt(hwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT | LVS_EX_DOUBLEBUFFER)
  return hwnd
end function

// Replaces control text through a dynamically sized UTF-16 buffer.
function setText(hwnd, text)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.setText: hwnd is required") end if
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.setText: text must be string") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  // The compiler's direct `wstr` FFI path uses a small shared scratch buffer;
  // WM_SETTEXT with caller-owned bytes preserves arbitrarily large SQL text.
  if SendMessageWPtr(hwnd, WM_SETTEXT, 0, nativeBytesPtr(wide)) == 0 then return fail("setText", "WM_SETTEXT failed") end if
  return true
end function

// Reads complete Unicode control text into a validated MiniLang string.
function getText(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.getText: hwnd is required") end if
  units = GetWindowTextLengthW(hwnd)
  if units < 0 then return fail("getText", "control text length is invalid") end if
  if units == 0 then return "" end if
  buffer = bytes((units + 1) * 2, 0)
  actual = GetWindowTextW(hwnd, buffer, units + 1)
  if actual < 0 then return fail("getText", "GetWindowTextW failed") end if
  return wideBytesToText(buffer, actual)
end function

// Reads a password directly into bytes and clears both temporary UTF-16 storage and the editor.
function getSecretBytes(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.getSecretBytes: hwnd is required") end if
  units = GetWindowTextLengthW(hwnd)
  if units <= 0 or units > MAX_CONTROL_TEXT_UTF16_UNITS then return error(INVALID_ARGUMENT, "platform.win32_gui.getSecretBytes: password is empty or too large") end if
  wide = bytes((units + 1) * 2, 0)
  actual = GetWindowTextW(hwnd, wide, units + 1)
  if actual != units then fillBytes(wide, 0, len(wide), 0); return fail("getSecretBytes", "GetWindowTextW failed") end if
  required = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, void, 0, void, void)
  if required <= 0 then fillBytes(wide, 0, len(wide), 0); return fail("getSecretBytes", "password is not valid UTF-16") end if
  output = bytes(required, 0)
  converted = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, output, required, void, void)
  fillBytes(wide, 0, len(wide), 0)
  ignoredClear = SetWindowTextW(hwnd, "")
  if converted != required then fillBytes(output, 0, len(output), 0); return fail("getSecretBytes", "password conversion failed") end if
  return output
end function

// Sets the native checked state without generating a click notification.
function checkBoxSet(hwnd, checked)
  value = 0
  if checked then value = BST_CHECKED end if
  ignored = SendMessageWInt(hwnd, BM_SETCHECK, value, 0)
  return true
end function

// Returns whether a checkbox currently holds the checked state.
function checkBoxChecked(hwnd)
  return SendMessageWInt(hwnd, BM_GETCHECK, 0, 0) == BST_CHECKED
end function

// Removes every item from a list box.
function listReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LB_RESETCONTENT, 0, 0)
  return true
end function

// Appends one Unicode item to a list box and returns its index.
function listAdd(hwnd, text)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: hwnd is required") end if
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: text must be string") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  index = SendMessageWPtr(hwnd, LB_ADDSTRING, 0, nativeBytesPtr(wide))
  if index == LB_ERR then return fail("listAdd", "LB_ADDSTRING failed") end if
  return index
end function

// Reads the complete Unicode text of the currently selected list-box item.
function listSelectedText(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listSelectedText: hwnd is required") end if
  selected = SendMessageWInt(hwnd, LB_GETCURSEL, 0, 0)
  if selected == LB_ERR then return "" end if
  units = SendMessageWInt(hwnd, LB_GETTEXTLEN, selected, 0)
  if units == LB_ERR or units <= 0 then return "" end if
  if units > MAX_CONTROL_TEXT_UTF16_UNITS then return fail("listSelectedText", "selected text is too large") end if
  buffer = bytes((units + 1) * 2, 0)
  actual = SendMessageWIndexBuffer(hwnd, LB_GETTEXT, selected, buffer)
  if actual == LB_ERR then return fail("listSelectedText", "LB_GETTEXT failed") end if
  return wideBytesToText(buffer, actual)
end function

// Returns the selected list-box index or minus one when no row is selected.
function listSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, LB_GETCURSEL, 0, 0)
end function

// Selects one list-box item by zero-based index.
function listSelect(hwnd, index)
  if hwnd == 0 or typeof(index) != "int" then return false end if
  return SendMessageWInt(hwnd, LB_SETCURSEL, index, 0) != LB_ERR
end function

// Deletes all nodes and invalidates all prior native tree-item handles.
function treeReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.treeReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1101, 0, 0)
  return true
end function

// Inserts one Unicode TreeView node using the Windows x64 TVINSERTSTRUCTW layout.
function treeInsert(hwnd, parentItem, text, hasChildren)
  if hwnd == 0 or typeof(parentItem) != "int" or typeof(text) != "string" or typeof(hasChildren) != "bool" then return error(INVALID_ARGUMENT, "platform.win32_gui.treeInsert: invalid tree item") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  // TVINSERTSTRUCTW embeds a pointer-sized parent and insertion position,
  // followed by the x64 TVITEMW payload beginning at byte offset 16.
  insertion = bytes(80, 0)
  if parentItem == 0 then writeSpecialPointer(insertion, 0, 0xFFFF0000) else writePointer(insertion, 0, parentItem) end if
  writeSpecialPointer(insertion, 8, 0xFFFF0002)
  mask = TVIF_TEXT
  if hasChildren then mask = mask | TVIF_CHILDREN end if
  endian.writeU32LE(insertion, 16, mask)
  writePointer(insertion, 40, nativeBytesPtr(wide))
  endian.writeU32LE(insertion, 48, len(wide) / 2)
  if hasChildren then endian.writeI32LE(insertion, 60, 1) end if
  item = SendMessageWPtrBuffer(hwnd, TVM_INSERTITEMW, 0, insertion)
  if item == 0 then return fail("treeInsert", "TVM_INSERTITEMW failed") end if
  return item
end function

// Expands one tree item so a freshly rebuilt object hierarchy is immediately useful.
function treeExpand(hwnd, item)
  if hwnd == 0 or typeof(item) != "int" or item == 0 then return false end if
  return SendMessageWPtr(hwnd, TVM_EXPAND, TVE_EXPAND, item) != 0
end function

// Selects one tree item without synthesizing mouse input.
function treeSelect(hwnd, item)
  if hwnd == 0 or typeof(item) != "int" or item == 0 then return false end if
  return SendMessageWPtr(hwnd, TVM_SELECTITEM, TVGN_CARET, item) != 0
end function

// Reads the selected TreeView item's text through a bounded TVITEMW buffer.
function treeSelectedText(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.treeSelectedText: hwnd is required") end if
  item = SendMessageWPtr(hwnd, TVM_GETNEXTITEM, TVGN_CARET, 0)
  if item == 0 then return "" end if
  wide = bytes((MAX_CONTROL_TEXT_UTF16_UNITS + 1) * 2, 0)
  descriptor = bytes(80, 0)
  endian.writeU32LE(descriptor, 0, TVIF_TEXT)
  writePointer(descriptor, 8, item)
  writePointer(descriptor, 24, nativeBytesPtr(wide))
  endian.writeI32LE(descriptor, 32, MAX_CONTROL_TEXT_UTF16_UNITS)
  ok = SendMessageWPtrBuffer(hwnd, TVM_GETITEMW, 0, descriptor)
  if ok == 0 then return fail("treeSelectedText", "TVM_GETITEMW failed") end if
  units = 0
  while units < MAX_CONTROL_TEXT_UTF16_UNITS and (wide[units * 2] != 0 or wide[units * 2 + 1] != 0)
    units = units + 1
  end while
  return wideBytesToText(wide, units)
end function

// Removes every page label from a tab control.
function tabReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.tabReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1309, 0, 0)
  return true
end function

// Appends one Unicode page label using the x64 TCITEMW layout.
function tabAdd(hwnd, text)
  if hwnd == 0 or typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.tabAdd: invalid tab") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  item = bytes(40, 0)
  endian.writeU32LE(item, 0, TCIF_TEXT)
  writePointer(item, 16, nativeBytesPtr(wide))
  index = SendMessageWIntBuffer(hwnd, TCM_INSERTITEMW, 2147483647, item)
  if index < 0 then return fail("tabAdd", "TCM_INSERTITEMW failed") end if
  return index
end function

// Returns the currently selected zero-based tab index.
function tabSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, TCM_GETCURSEL, 0, 0)
end function

// Removes every result row while preserving the column schema.
function listViewReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LVM_DELETEALLITEMS, 0, 0)
  return true
end function

// Deletes ListView columns from index zero until Windows reports none remain.
function listViewResetColumns(hwnd)
  if hwnd == 0 then return false end if
  while SendMessageWInt(hwnd, LVM_DELETECOLUMN, 0, 0) != 0
  end while
  return true
end function

// Inserts one report column using a pointer-safe x64 LVCOLUMNW buffer.
function listViewAddColumn(hwnd, index, text, width)
  if hwnd == 0 or typeof(index) != "int" or typeof(text) != "string" or typeof(width) != "int" then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewAddColumn: invalid column") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  column = bytes(56, 0)
  endian.writeU32LE(column, 0, LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM)
  endian.writeI32LE(column, 8, width)
  writePointer(column, 16, nativeBytesPtr(wide))
  endian.writeI32LE(column, 24, len(wide) / 2)
  endian.writeI32LE(column, 28, index)
  result = SendMessageWIntBuffer(hwnd, LVM_INSERTCOLUMNW, index, column)
  if result < 0 then return fail("listViewAddColumn", "LVM_INSERTCOLUMNW failed") end if
  return result
end function

// Inserts a result row and then fills its remaining subitems in column order.
function listViewAddRow(hwnd, rowIndex, values)
  if hwnd == 0 or typeof(rowIndex) != "int" or typeof(values) != "array" or len(values) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewAddRow: invalid row") end if
  firstWide = try(utf16Bytes(values[0]))
  if typeof(firstWide) == "error" then return firstWide end if
  item = bytes(88, 0)
  endian.writeU32LE(item, 0, LVIF_TEXT)
  endian.writeI32LE(item, 4, rowIndex)
  writePointer(item, 24, nativeBytesPtr(firstWide))
  endian.writeI32LE(item, 32, len(firstWide) / 2)
  inserted = SendMessageWIntBuffer(hwnd, LVM_INSERTITEMW, 0, item)
  if inserted < 0 then return fail("listViewAddRow", "LVM_INSERTITEMW failed") end if
  if len(values) > 1 then
    for index = 1 to len(values) - 1
      wide = try(utf16Bytes(values[index]))
      if typeof(wide) == "error" then return wide end if
      subitem = bytes(88, 0)
      endian.writeI32LE(subitem, 8, index)
      writePointer(subitem, 24, nativeBytesPtr(wide))
      endian.writeI32LE(subitem, 32, len(wide) / 2)
      ignored = SendMessageWIntBuffer(hwnd, LVM_SETITEMTEXTW, inserted, subitem)
    end for
  end if
  return inserted
end function

// Moves a control using physical Win32 coordinates and repaints immediately.
function move(hwnd, x, y, width, height)
  if hwnd == 0 then return false end if
  return MoveWindow(hwnd, x, y, width, height, true)
end function

// Scales one logical coordinate for the monitor currently hosting a window.
function scaleDip(hwnd, value)
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = 96 end if
  return scaleAtDpi(value, dpiValue)
end function

// Converts a physical coordinate into a logical DPI-independent value.
function unscaleDip(hwnd, value)
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = 96 end if
  halfDpi = dpiValue >> 1
  if value < 0 then return -divideInt((-value) * 96 + halfDpi, dpiValue) end if
  return divideInt(value * 96 + halfDpi, dpiValue)
end function

// Moves a control using logical coordinates and defers repainting to the layout boundary.
function moveDip(hwnd, x, y, width, height)
  if hwnd == 0 then return false end if
  ignoredFont = applyDefaultFont(hwnd)
  return MoveWindow(hwnd, scaleDip(hwnd, x), scaleDip(hwnd, y), scaleDip(hwnd, width), scaleDip(hwnd, height), false)
end function

// Invalidates a complete top-level window and all descendants after a layout transaction.
function redraw(hwnd)
  if hwnd == 0 then return false end if
  return RedrawWindow(hwnd, void, void, RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW)
end function

// Shows a fully constructed top-level window without exposing its placeholder layout.
function showTopLevel(hwnd)
  if hwnd == 0 then return false end if
  ignoredShow = ShowWindow(hwnd, SW_SHOW)
  ignoredRedraw = redraw(hwnd)
  return UpdateWindow(hwnd)
end function

// Registers a DPI-aware minimum client size consumed by WM_GETMINMAXINFO.
function setMinimumClientSizeDip(hwnd, width, height)
  global windowMinimums
  if hwnd == 0 or typeof(width) != "int" or typeof(height) != "int" or width < 320 or height < 240 then return false end if
  retained = []
  for each minimum in windowMinimums
    if minimum.hwnd != hwnd then retained = retained + [minimum] end if
  end for
  windowMinimums = retained + [WindowMinimum(hwnd, width, height)]
  return true
end function

// Resizes a top-level window so its client area matches logical dimensions exactly.
function setClientSizeDip(hwnd, width, height, hasMenu)
  if hwnd == 0 or typeof(width) != "int" or typeof(height) != "int" then return false end if
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = GetDpiForSystem() end if
  if dpiValue < 96 then dpiValue = 96 end if
  outer = try(outerSizeForClient(width, height, dpiValue, hasMenu))
  if typeof(outer) == "error" then return outer end if
  return SetWindowPos(hwnd, 0, 0, 0, outer[0], outer[1], SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE)
end function

// Returns a child control rectangle in parent-relative DPI-independent pixels.
function controlRectDip(parent, child)
  if parent == 0 or child == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.controlRectDip: parent and child are required") end if
  rectangle = bytes(16, 0)
  if not GetWindowRect(child, rectangle) then return fail("controlRectDip", "GetWindowRect failed") end if
  ignoredMap = MapWindowPoints(0, parent, rectangle, 2)
  left = unscaleDip(parent, endian.readI32LE(rectangle, 0))
  top = unscaleDip(parent, endian.readI32LE(rectangle, 4))
  right = unscaleDip(parent, endian.readI32LE(rectangle, 8))
  bottom = unscaleDip(parent, endian.readI32LE(rectangle, 12))
  return [left, top, right - left, bottom - top]
end function

// Shows or hides one control without changing its layout rectangle.
function show(hwnd, visible)
  if hwnd == 0 then return false end if
  command = 0
  if visible then command = SW_SHOW end if
  return ShowWindow(hwnd, command)
end function

// Enables or disables one workbench control.
function setEnabled(hwnd, enabled)
  if hwnd == 0 then return false end if
  return EnableWindow(hwnd, enabled)
end function

// Returns the effective Win32 enabled state of one control.
function isEnabled(hwnd)
  if hwnd == 0 then return false end if
  return IsWindowEnabled(hwnd)
end function

// Gives keyboard focus to a workbench control.
function focus(hwnd)
  if hwnd == 0 then return false end if
  ignored = SetFocus(hwnd)
  return true
end function

// Displays a native informational message box.
function showInfo(owner, title, message)
  if owner == 0 or typeof(title) != "string" or typeof(message) != "string" then return false end if
  ignored = MessageBoxW(owner, message, title, MB_OK | MB_ICONINFORMATION)
  return true
end function

// Selects a tab page by zero-based index.
function tabSelect(hwnd, index)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, 0x130C, index, 0)
end function

// Returns the physical-pixel dimensions of a window's client area.
function clientSize(hwnd)
  rectangle = bytes(16, 0)
  if not GetClientRect(hwnd, rectangle) then return fail("clientSize", "GetClientRect failed") end if
  return [endian.readI32LE(rectangle, 8), endian.readI32LE(rectangle, 12)]
end function

// Returns the client dimensions in DPI-independent pixels.
function clientSizeDip(hwnd)
  size = try(clientSize(hwnd))
  if typeof(size) == "error" then return size end if
  return [unscaleDip(hwnd, size[0]), unscaleDip(hwnd, size[1])]
end function

// Returns a valid DPI for a window, falling back to the 96-DPI baseline.
function dpi(hwnd)
  value = GetDpiForWindow(hwnd)
  if value < 96 then return 96 end if
  return value
end function

// Returns whether a push button currently reports its pressed state.
function buttonDown(hwnd)
  if hwnd == 0 then return false end if
  state = SendMessageWInt(hwnd, BM_GETSTATE, 0, 0)
  return (state & BST_PUSHED) != 0
end function

// Dispatches a bounded batch of messages and applies dialog-style keyboard navigation.
function pumpMessages()
  message = bytes(64, 0)
  pumped = 0
  while pumped < 128 and PeekMessageW(message, void, 0, 0, PM_REMOVE)
    active = GetActiveWindow()
    handled = false
    if active != 0 then handled = IsDialogMessageW(active, message) end if
    if not handled then
      ignoredTranslate = TranslateMessage(message)
      ignoredDispatch = DispatchMessageW(message)
    end if
    pumped = pumped + 1
  end while
  return pumped
end function

// Returns whether a native handle still names a live window.
function isOpen(hwnd)
  if hwnd == 0 then return false end if
  return IsWindow(hwnd)
end function

// Destroys a top-level window and releases its retained minimum-size policy.
function destroy(hwnd)
  global windowMinimums
  if hwnd == 0 then return true end if
  retained = []
  for each minimum in windowMinimums
    if minimum.hwnd != hwnd then retained = retained + [minimum] end if
  end for
  windowMinimums = retained
  destroyed = DestroyWindow(hwnd)
  return destroyed != 0
end function

// Yields the current native thread for the requested polling interval.
function sleep(milliseconds)
  Sleep(milliseconds)
  return true
end function

// Returns the stable module name used by smoke tests.
function componentName()
  return "platform.win32_gui"
end function

// Identifies the workbench milestone that introduced this Win32 adapter.
function targetMilestone()
  return "M74"
end function

// Reports that the native Win32 adapter is available in this build.
function isImplemented()
  return true
end function
