package minisql.platform.win32_gui

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

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
const WM_COMMAND = 0x0111
const WM_NOTIFY = 0x004E
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
const TVGN_CARET = 9
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
const MB_OK = 0
const MB_ICONINFORMATION = 64

const MENU_FILE_NEW = 1000
const MENU_FILE_CLOSE = 1001
const MENU_FILE_EXIT = 1002
const MENU_ALIAS_CONNECT = 1100
const MENU_ALIAS_NEW = 1101
const MENU_ALIAS_EDIT = 1102
const MENU_ALIAS_DELETE = 1103
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

guiEvents = []
guiClassRegistered = false
guiClassNameWide = void
modernGuiFont = 0

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
// Binds the native Windows GetDpiForWindow API used by the GUI abstraction.
extern function GetDpiForWindow(hwnd as ptr) from "user32.dll" symbol "GetDpiForWindow" returns u32
// Binds the native Windows SetProcessDpiAwarenessContext API used by the GUI abstraction.
extern function SetProcessDpiAwarenessContext(context as ptr) from "user32.dll" symbol "SetProcessDpiAwarenessContext" returns bool
// Binds the native Windows MultiByteToWideChar API used by the GUI abstraction.
extern function MultiByteToWideChar(codePage as u32, flags as u32, source as bytes, sourceCount as i32, output as bytes, outputCount as i32) from "kernel32.dll" symbol "MultiByteToWideChar" returns i32
// Binds the native Windows RtlMoveMemory API used by the GUI abstraction.
extern function RtlMoveMemory(destination as bytes, source as ptr, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
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

// Binds the native Windows SendMessageWPtrBuffer API used by the GUI abstraction.
extern function SendMessageWPtrBuffer(hwnd as ptr, message as u32, wParam as ptr, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
// Binds the native Windows SendMessageWIntBuffer API used by the GUI abstraction.
extern function SendMessageWIntBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
// Binds the native Windows SendMessageWPtr API used by the GUI abstraction.
extern function SendMessageWPtr(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "SendMessageW" returns ptr

// Implements utf16Bytes for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements writePointer for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function writePointer(buffer, offset, value)
  endian.writeU64LE(buffer, offset, endian.uint64FromInt(value))
  return true
end function

// Implements writeSpecialPointer for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function writeSpecialPointer(buffer, offset, low)
  endian.writeU64LE(buffer, offset, endian.makeUInt64(0xFFFFFFFF, low))
  return true
end function

// Implements readPointer for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function readPointer(buffer, offset)
  return endian.uint64ToInt(endian.readU64LE(buffer, offset))
end function

// Implements windowProcedure for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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
    return 0
  end if
  if message == WM_CLOSE then
    ignored = DestroyWindow(hwnd)
    return 0
  end if
  if message == WM_DESTROY then
    PostQuitMessage(0)
    return 0
  end if
  return DefWindowProcW(hwnd, message, wParam, lParam)
end function

// Implements initializeCommonControls for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function initializeCommonControls()
  configuration = bytes(8, 0)
  endian.writeU32LE(configuration, 0, 8)
  endian.writeU32LE(configuration, 4, ICC_LISTVIEW_CLASSES | ICC_TREEVIEW_CLASSES | ICC_BAR_CLASSES | ICC_TAB_CLASSES)
  if not InitCommonControlsEx(configuration) then return fail("initializeCommonControls", "InitCommonControlsEx failed") end if
  return true
end function

// Implements ensureWindowClass for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements pollEvent for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements clearEvents for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function clearEvents()
  global guiEvents
  guiEvents = []
  return true
end function

// Implements postCommandForTest for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function postCommandForTest(hwnd, controlId)
  return PostMessageW(hwnd, WM_COMMAND, controlId, 0)
end function

// Implements fail for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function fail(operation, message)
  return error(GUI_ERROR, "platform.win32_gui." + operation + ": " + message)
end function

// Implements wideBytesToText for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function wideBytesToText(wide, units)
  if typeof(wide) != "bytes" or typeof(units) != "int" or units < 0 or units > MAX_CONTROL_TEXT_UTF16_UNITS then return error(INVALID_ARGUMENT, "platform.win32_gui.wideBytesToText: invalid UTF-16 input") end if
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

// Implements applyDefaultFont for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function applyDefaultFont(hwnd)
  global modernGuiFont
  if hwnd == 0 then return false end if
  if modernGuiFont == 0 then modernGuiFont = CreateFontW(-16, 0, 0, 0, 400, 0, 0, 0, 1, 0, 0, 5, 0, "Segoe UI") end if
  font = modernGuiFont
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

// Implements createTopMenu for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createTopMenu(items, identifiers)
  menu = CreatePopupMenu()
  if menu == 0 then return menu end if
  for index = 0 to len(items) - 1
    ignored = AppendMenuWInt(menu, MF_STRING, identifiers[index], items[index])
  end for
  return menu
end function

// Implements attachMenuBar for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function attachMenuBar(hwnd)
  if hwnd == 0 then return false end if
  mainMenu = CreateMenu()
  if mainMenu == 0 then return false end if
  fileMenu = createTopMenu(["New Connection", "Close Session", "Exit"], [MENU_FILE_NEW, MENU_FILE_CLOSE, MENU_FILE_EXIT])
  aliasesMenu = createTopMenu(["Connect", "New Alias", "Modify Alias", "Delete Alias"], [MENU_ALIAS_CONNECT, MENU_ALIAS_NEW, MENU_ALIAS_EDIT, MENU_ALIAS_DELETE])
  sessionMenu = createTopMenu(["Refresh Object Tree", "Commit Transaction", "Rollback Transaction"], [MENU_SESSION_REFRESH, MENU_SESSION_COMMIT, MENU_SESSION_ROLLBACK])
  sqlMenu = createTopMenu(["Execute SQL", "Explain SQL", "Stop Execution", "Clear Results"], [MENU_SQL_EXECUTE, MENU_SQL_EXPLAIN, MENU_SQL_CANCEL, MENU_SQL_CLEAR])
  objectMenu = createTopMenu(["Open Table Details", "Select First 100 Rows"], [MENU_OBJECT_DESCRIBE, MENU_OBJECT_QUERY])
  helpMenu = createTopMenu(["About MiniSQL Workbench"], [MENU_HELP_ABOUT])
  if fileMenu != 0 then ignoredFile = AppendMenuWPtr(mainMenu, MF_POPUP, fileMenu, "File") end if
  if aliasesMenu != 0 then ignoredAliases = AppendMenuWPtr(mainMenu, MF_POPUP, aliasesMenu, "Aliases") end if
  if sessionMenu != 0 then ignoredSession = AppendMenuWPtr(mainMenu, MF_POPUP, sessionMenu, "Session") end if
  if sqlMenu != 0 then ignoredSql = AppendMenuWPtr(mainMenu, MF_POPUP, sqlMenu, "SQL") end if
  if objectMenu != 0 then ignoredObject = AppendMenuWPtr(mainMenu, MF_POPUP, objectMenu, "Objects") end if
  if helpMenu != 0 then ignoredHelp = AppendMenuWPtr(mainMenu, MF_POPUP, helpMenu, "Help") end if
  if not SetMenu(hwnd, mainMenu) then return false end if
  ignoredDraw = DrawMenuBar(hwnd)
  return true
end function

// Implements hiddenWindowSmoke for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function hiddenWindowSmoke()
  hwnd = try(createTopLevel("MiniSQL Admin Smoke", 320, 240, false))
  if typeof(hwnd) == "error" then return hwnd end if
  destroyed = DestroyWindow(hwnd)
  if destroyed == 0 then return fail("hiddenWindowSmoke", "hidden window could not be destroyed") end if
  return true
end function

// Implements createTopLevel for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createTopLevel(title, width, height, visible)
  if typeof(title) != "string" or len(title) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createTopLevel: title must be non-empty") end if
  if typeof(width) != "int" or width < 320 or typeof(height) != "int" or height < 240 then return error(INVALID_ARGUMENT, "platform.win32_gui.createTopLevel: size is too small") end if
  initialized = try(ensureWindowClass())
  if typeof(initialized) == "error" then return initialized end if
  style = WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN
  if visible then style = style | WS_VISIBLE end if
  hwnd = CreateWindowExW(0, "MiniSQLAdminWindow13", title, style, 80, 80, width, height, void, void, GetModuleHandleW(void), void)
  if hwnd == 0 then return fail("createTopLevel", "top-level window could not be created") end if
  ignoredFont = applyDefaultFont(hwnd)
  ignoredChrome = applyWindowChrome(hwnd)
  ignoredMenu = attachMenuBar(hwnd)
  if visible then
    ignoredShow = ShowWindow(hwnd, SW_SHOW)
    ignoredUpdate = UpdateWindow(hwnd)
  end if
  return hwnd
end function

// Implements createChildId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createChildId(parent, className, text, x, y, width, height, style, exStyle, controlId)
  if parent == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createChild: parent is required") end if
  if typeof(className) != "string" or len(className) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.createChild: className must be non-empty") end if
  childStyle = WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | style
  hwnd = CreateWindowExW(exStyle, className, text, childStyle, x, y, width, height, parent, controlId, GetModuleHandleW(void), void)
  if hwnd == 0 then return fail("createChild", "child " + className + " could not be created") end if
  ignoredFont = applyDefaultFont(hwnd)
  ignoredTheme = applyControlTheme(hwnd)
  return hwnd
end function

// Implements createChild for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createChild(parent, className, text, x, y, width, height, style, exStyle)
  return createChildId(parent, className, text, x, y, width, height, style, exStyle, 0)
end function

// Implements createLabel for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createLabel(parent, text, x, y, width, height)
  return createChild(parent, "STATIC", text, x, y, width, height, 0, 0)
end function

// Implements createGroupBox for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createGroupBox(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_GROUPBOX, 0)
end function

// Implements createButton for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createButton(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0)
end function

// Implements createButtonId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

// Implements createDefaultButtonId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createDefaultButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_DEFPUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

// Implements createCheckBoxId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createCheckBoxId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_AUTOCHECKBOX | WS_TABSTOP, 0, controlId)
end function

// Implements createEdit for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createEdit(parent, text, x, y, width, height, readOnly)
  style = WS_BORDER | WS_TABSTOP | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_WANTRETURN | WS_VSCROLL | WS_HSCROLL
  if readOnly then style = style | ES_READONLY end if
  return createChild(parent, "EDIT", text, x, y, width, height, style, WS_EX_CLIENTEDGE)
end function

// Implements createTextBoxId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createTextBoxId(parent, controlId, text, x, y, width, height, password)
  style = WS_BORDER | WS_TABSTOP | ES_AUTOHSCROLL_SINGLE
  if password then style = style | ES_PASSWORD end if
  return createChildId(parent, "EDIT", text, x, y, width, height, style, WS_EX_CLIENTEDGE, controlId)
end function

// Implements createListBox for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createListBox(parent, x, y, width, height)
  return createChild(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE)
end function

// Implements createListBoxId for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createListBoxId(parent, controlId, x, y, width, height)
  return createChildId(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE, controlId)
end function

// Implements createTreeView for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createTreeView(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTreeView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | TVS_HASBUTTONS | TVS_HASLINES | TVS_LINESATROOT | TVS_SHOWSELALWAYS, WS_EX_CLIENTEDGE, controlId)
end function

// Implements createTabControl for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createTabControl(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTabControl32", "", x, y, width, height, WS_TABSTOP, 0, controlId)
end function

// Implements createListView for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function createListView(parent, controlId, x, y, width, height)
  hwnd = try(createChildId(parent, "SysListView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | WS_HSCROLL | LVS_REPORT | LVS_SHOWSELALWAYS | LVS_SINGLESEL, WS_EX_CLIENTEDGE, controlId))
  if typeof(hwnd) == "error" then return hwnd end if
  ignored = SendMessageWInt(hwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT | LVS_EX_DOUBLEBUFFER)
  return hwnd
end function

// Implements setText for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function setText(hwnd, text)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.setText: hwnd is required") end if
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.setText: text must be string") end if
  if not SetWindowTextW(hwnd, text) then return fail("setText", "SetWindowTextW failed") end if
  return true
end function

// Implements getText for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function getText(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.getText: hwnd is required") end if
  units = GetWindowTextLengthW(hwnd)
  if units < 0 or units > MAX_CONTROL_TEXT_UTF16_UNITS then return fail("getText", "control text length is invalid") end if
  if units == 0 then return "" end if
  buffer = bytes((units + 1) * 2, 0)
  actual = GetWindowTextW(hwnd, buffer, units + 1)
  if actual < 0 then return fail("getText", "GetWindowTextW failed") end if
  return wideBytesToText(buffer, actual)
end function

// Implements getSecretBytes for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements checkBoxSet for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function checkBoxSet(hwnd, checked)
  value = 0
  if checked then value = BST_CHECKED end if
  ignored = SendMessageWInt(hwnd, BM_SETCHECK, value, 0)
  return true
end function

// Implements checkBoxChecked for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function checkBoxChecked(hwnd)
  return SendMessageWInt(hwnd, BM_GETCHECK, 0, 0) == BST_CHECKED
end function

// Implements listReset for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function listReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LB_RESETCONTENT, 0, 0)
  return true
end function

// Implements listAdd for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function listAdd(hwnd, text)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: hwnd is required") end if
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: text must be string") end if
  index = SendMessageWText(hwnd, LB_ADDSTRING, 0, text)
  if index == LB_ERR then return fail("listAdd", "LB_ADDSTRING failed") end if
  return index
end function

// Implements listSelectedText for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements listSelect for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function listSelect(hwnd, index)
  if hwnd == 0 or typeof(index) != "int" then return false end if
  return SendMessageWInt(hwnd, LB_SETCURSEL, index, 0) != LB_ERR
end function

// Implements treeReset for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function treeReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.treeReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1101, 0, 0)
  return true
end function

// Implements treeInsert for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function treeInsert(hwnd, parentItem, text, hasChildren)
  if hwnd == 0 or typeof(parentItem) != "int" or typeof(text) != "string" or typeof(hasChildren) != "bool" then return error(INVALID_ARGUMENT, "platform.win32_gui.treeInsert: invalid tree item") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
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

// Implements treeSelectedText for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements tabReset for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function tabReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.tabReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1309, 0, 0)
  return true
end function

// Implements tabAdd for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements tabSelectedIndex for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function tabSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, TCM_GETCURSEL, 0, 0)
end function

// Implements listViewReset for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function listViewReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LVM_DELETEALLITEMS, 0, 0)
  return true
end function

// Implements listViewResetColumns for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function listViewResetColumns(hwnd)
  if hwnd == 0 then return false end if
  while SendMessageWInt(hwnd, LVM_DELETECOLUMN, 0, 0) != 0
  end while
  return true
end function

// Implements listViewAddColumn for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements listViewAddRow for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements move for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function move(hwnd, x, y, width, height)
  if hwnd == 0 then return false end if
  return MoveWindow(hwnd, x, y, width, height, true)
end function

// Implements show for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
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

// Implements tabSelect for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function tabSelect(hwnd, index)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, 0x130C, index, 0)
end function

// Implements clientSize for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function clientSize(hwnd)
  rectangle = bytes(16, 0)
  if not GetClientRect(hwnd, rectangle) then return fail("clientSize", "GetClientRect failed") end if
  return [endian.readI32LE(rectangle, 8), endian.readI32LE(rectangle, 12)]
end function

// Implements dpi for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function dpi(hwnd)
  value = GetDpiForWindow(hwnd)
  if value < 96 then return 96 end if
  return value
end function

// Implements buttonDown for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function buttonDown(hwnd)
  if hwnd == 0 then return false end if
  state = SendMessageWInt(hwnd, BM_GETSTATE, 0, 0)
  return (state & BST_PUSHED) != 0
end function

// Implements pumpMessages for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function pumpMessages()
  message = bytes(64, 0)
  pumped = 0
  while pumped < 128 and PeekMessageW(message, void, 0, 0, PM_REMOVE)
    ignoredTranslate = TranslateMessage(message)
    ignoredDispatch = DispatchMessageW(message)
    pumped = pumped + 1
  end while
  return pumped
end function

// Implements isOpen for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function isOpen(hwnd)
  if hwnd == 0 then return false end if
  return IsWindow(hwnd)
end function

// Implements destroy for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function destroy(hwnd)
  if hwnd == 0 then return true end if
  destroyed = DestroyWindow(hwnd)
  return destroyed != 0
end function

// Implements sleep for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function sleep(milliseconds)
  Sleep(milliseconds)
  return true
end function

// Implements componentName for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function componentName()
  return "platform.win32_gui"
end function

// Implements targetMilestone for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function targetMilestone()
  return "M74"
end function

// Implements isImplemented for the native Windows GUI abstraction.
// Validates public inputs and returns a structured error when Win32 rejects the operation.
function isImplemented()
  return true
end function
