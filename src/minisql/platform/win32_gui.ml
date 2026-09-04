//! Provides minisql platform win32 gui facilities for this project.

package minisql.platform.win32_gui

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

/// Public geometry in this module is expressed in device-independent pixels.

const INVALID_ARGUMENT = 9001
/// Defines the gui error constant used by the minisql platform win32 gui module.
const GUI_ERROR = 9040
/// Defines the io failure constant used by the minisql platform win32 gui module.
const IO_FAILURE = 9005

/// Defines the ws overlappedwindow constant used by the minisql platform win32 gui module.
const WS_OVERLAPPEDWINDOW = 0x00CF0000
/// Defines the ws visible constant used by the minisql platform win32 gui module.
const WS_VISIBLE = 0x10000000
/// Defines the ws child constant used by the minisql platform win32 gui module.
const WS_CHILD = 0x40000000
/// Defines the ws border constant used by the minisql platform win32 gui module.
const WS_BORDER = 0x00800000
/// Defines the ws vscroll constant used by the minisql platform win32 gui module.
const WS_VSCROLL = 0x00200000
/// Defines the ws hscroll constant used by the minisql platform win32 gui module.
const WS_HSCROLL = 0x00100000
/// Defines the ws tabstop constant used by the minisql platform win32 gui module.
const WS_TABSTOP = 0x00010000
/// Defines the ws ex clientedge constant used by the minisql platform win32 gui module.
const WS_EX_CLIENTEDGE = 0x00000200
/// Defines the ws clipchildren constant used by the minisql platform win32 gui module.
const WS_CLIPCHILDREN = 0x02000000
/// Defines the ws clipsiblings constant used by the minisql platform win32 gui module.
const WS_CLIPSIBLINGS = 0x04000000
/// Defines the es multiline constant used by the minisql platform win32 gui module.
const ES_MULTILINE = 0x0004
/// Defines the es autovscroll constant used by the minisql platform win32 gui module.
const ES_AUTOVSCROLL = 0x0040
/// Defines the es autohscroll constant used by the minisql platform win32 gui module.
const ES_AUTOHSCROLL = 0x0080
/// Defines the es readonly constant used by the minisql platform win32 gui module.
const ES_READONLY = 0x0800
/// Defines the es wantreturn constant used by the minisql platform win32 gui module.
const ES_WANTRETURN = 0x1000
/// Defines the es password constant used by the minisql platform win32 gui module.
const ES_PASSWORD = 0x0020
/// Defines the es autohscroll single constant used by the minisql platform win32 gui module.
const ES_AUTOHSCROLL_SINGLE = 0x0080
/// Defines the lbs notify constant used by the minisql platform win32 gui module.
const LBS_NOTIFY = 0x0001
/// Defines the lbs nointegralheight constant used by the minisql platform win32 gui module.
const LBS_NOINTEGRALHEIGHT = 0x0100
/// Defines the bs pushbutton constant used by the minisql platform win32 gui module.
const BS_PUSHBUTTON = 0
/// Defines the bs groupbox constant used by the minisql platform win32 gui module.
const BS_GROUPBOX = 7
/// Defines the bs defpushbutton constant used by the minisql platform win32 gui module.
const BS_DEFPUSHBUTTON = 1
/// Defines the bs autocheckbox constant used by the minisql platform win32 gui module.
const BS_AUTOCHECKBOX = 3
/// Defines the sw show constant used by the minisql platform win32 gui module.
const SW_SHOW = 5
/// Defines the pm remove constant used by the minisql platform win32 gui module.
const PM_REMOVE = 1
/// Defines the wm settext constant used by the minisql platform win32 gui module.
const WM_SETTEXT = 0x000C
/// Defines the wm setredraw constant used by the minisql platform win32 gui module.
const WM_SETREDRAW = 0x000B
/// Defines the wm setfont constant used by the minisql platform win32 gui module.
const WM_SETFONT = 0x0030
/// Defines the wm close constant used by the minisql platform win32 gui module.
const WM_CLOSE = 0x0010
/// Defines the wm destroy constant used by the minisql platform win32 gui module.
const WM_DESTROY = 0x0002
/// Defines the wm move constant used by the minisql platform win32 gui module.
const WM_MOVE = 0x0003
/// Defines the wm size constant used by the minisql platform win32 gui module.
const WM_SIZE = 0x0005
/// Defines the wm getminmaxinfo constant used by the minisql platform win32 gui module.
const WM_GETMINMAXINFO = 0x0024
/// Defines the wm command constant used by the minisql platform win32 gui module.
const WM_COMMAND = 0x0111
/// Defines the wm notify constant used by the minisql platform win32 gui module.
const WM_NOTIFY = 0x004E
/// Defines the wm contextmenu constant used by the minisql platform win32 gui module.
const WM_CONTEXTMENU = 0x007B
/// Defines the wm lbuttondown constant used by the minisql platform win32 gui module.
const WM_LBUTTONDOWN = 0x0201
/// Defines the wm lbuttonup constant used by the minisql platform win32 gui module.
const WM_LBUTTONUP = 0x0202
/// Defines the wm dpichanged constant used by the minisql platform win32 gui module.
const WM_DPICHANGED = 0x02E0
/// Defines the em setlimittext constant used by the minisql platform win32 gui module.
const EM_SETLIMITTEXT = 0x00C5
/// Defines the em exgetsel constant used by the minisql platform win32 gui module.
const EM_EXGETSEL = 0x0434
/// Defines the em exlimittext constant used by the minisql platform win32 gui module.
const EM_EXLIMITTEXT = 0x0435
/// Defines the em exsetsel constant used by the minisql platform win32 gui module.
const EM_EXSETSEL = 0x0437
/// Defines the em getcharformat constant used by the minisql platform win32 gui module.
const EM_GETCHARFORMAT = 0x043A
/// Defines the em setcharformat constant used by the minisql platform win32 gui module.
const EM_SETCHARFORMAT = 0x0444
/// Defines the em seteventmask constant used by the minisql platform win32 gui module.
const EM_SETEVENTMASK = 0x0445
/// Defines the em getscrollpos constant used by the minisql platform win32 gui module.
const EM_GETSCROLLPOS = 0x04DD
/// Defines the em setscrollpos constant used by the minisql platform win32 gui module.
const EM_SETSCROLLPOS = 0x04DE
/// Defines the em setcuebanner constant used by the minisql platform win32 gui module.
const EM_SETCUEBANNER = 0x1501
/// Defines the enm change constant used by the minisql platform win32 gui module.
const ENM_CHANGE = 1
/// Defines the scf selection constant used by the minisql platform win32 gui module.
const SCF_SELECTION = 1
/// Defines the cfm bold constant used by the minisql platform win32 gui module.
const CFM_BOLD = 1
/// Defines the cfm italic constant used by the minisql platform win32 gui module.
const CFM_ITALIC = 2
/// Defines the cfm color constant used by the minisql platform win32 gui module.
const CFM_COLOR = 0x40000000
/// Defines the cfe bold constant used by the minisql platform win32 gui module.
const CFE_BOLD = 1
/// Defines the cfe italic constant used by the minisql platform win32 gui module.
const CFE_ITALIC = 2
/// Defines the charformat2 w bytes constant used by the minisql platform win32 gui module.
const CHARFORMAT2W_BYTES = 116
/// Defines the max edit text utf16 units constant used by the minisql platform win32 gui module.
const MAX_EDIT_TEXT_UTF16_UNITS = 2147483646
/// Defines the bm getstate constant used by the minisql platform win32 gui module.
const BM_GETSTATE = 0x00F2
/// Defines the bm getcheck constant used by the minisql platform win32 gui module.
const BM_GETCHECK = 0x00F0
/// Defines the bm setcheck constant used by the minisql platform win32 gui module.
const BM_SETCHECK = 0x00F1
/// Defines the bst checked constant used by the minisql platform win32 gui module.
const BST_CHECKED = 1
/// Defines the bst pushed constant used by the minisql platform win32 gui module.
const BST_PUSHED = 0x0004
/// Defines the lb addstring constant used by the minisql platform win32 gui module.
const LB_ADDSTRING = 0x0180
/// Defines the lb resetcontent constant used by the minisql platform win32 gui module.
const LB_RESETCONTENT = 0x0184
/// Defines the lb getcursel constant used by the minisql platform win32 gui module.
const LB_GETCURSEL = 0x0188
/// Defines the lb gettext constant used by the minisql platform win32 gui module.
const LB_GETTEXT = 0x0189
/// Defines the lb gettextlen constant used by the minisql platform win32 gui module.
const LB_GETTEXTLEN = 0x018A
/// Defines the lb setcursel constant used by the minisql platform win32 gui module.
const LB_SETCURSEL = 0x0186
/// Defines the lb err constant used by the minisql platform win32 gui module.
const LB_ERR = -1
/// Defines the cp utf8 constant used by the minisql platform win32 gui module.
const CP_UTF8 = 65001
/// Defines the wc err invalid chars constant used by the minisql platform win32 gui module.
const WC_ERR_INVALID_CHARS = 0x80
/// Defines the max control text utf16 units constant used by the minisql platform win32 gui module.
const MAX_CONTROL_TEXT_UTF16_UNITS = 32767
/// Defines the default gui font constant used by the minisql platform win32 gui module.
const DEFAULT_GUI_FONT = 17
/// Defines the mf string constant used by the minisql platform win32 gui module.
const MF_STRING = 0
/// Defines the mf popup constant used by the minisql platform win32 gui module.
const MF_POPUP = 16
/// Defines the color window constant used by the minisql platform win32 gui module.
const COLOR_WINDOW = 5
/// Defines the idc arrow constant used by the minisql platform win32 gui module.
const IDC_ARROW = 32512
/// Defines the error class already exists constant used by the minisql platform win32 gui module.
const ERROR_CLASS_ALREADY_EXISTS = 1410
/// Defines the icc listview classes constant used by the minisql platform win32 gui module.
const ICC_LISTVIEW_CLASSES = 1
/// Defines the icc treeview classes constant used by the minisql platform win32 gui module.
const ICC_TREEVIEW_CLASSES = 2
/// Defines the icc bar classes constant used by the minisql platform win32 gui module.
const ICC_BAR_CLASSES = 4
/// Defines the icc tab classes constant used by the minisql platform win32 gui module.
const ICC_TAB_CLASSES = 8
/// Defines the tvs hasbuttons constant used by the minisql platform win32 gui module.
const TVS_HASBUTTONS = 1
/// Defines the tvs haslines constant used by the minisql platform win32 gui module.
const TVS_HASLINES = 2
/// Defines the tvs linesatroot constant used by the minisql platform win32 gui module.
const TVS_LINESATROOT = 4
/// Defines the tvs showselalways constant used by the minisql platform win32 gui module.
const TVS_SHOWSELALWAYS = 32
/// Defines the tvif text constant used by the minisql platform win32 gui module.
const TVIF_TEXT = 1
/// Defines the tvif children constant used by the minisql platform win32 gui module.
const TVIF_CHILDREN = 64
/// Defines the tvm insertitemw constant used by the minisql platform win32 gui module.
const TVM_INSERTITEMW = 0x1132
/// Defines the tvm getnextitem constant used by the minisql platform win32 gui module.
const TVM_GETNEXTITEM = 0x110A
/// Defines the tvm getitemw constant used by the minisql platform win32 gui module.
const TVM_GETITEMW = 0x113E
/// Defines the tvm expand constant used by the minisql platform win32 gui module.
const TVM_EXPAND = 0x1102
/// Defines the tvm selectitem constant used by the minisql platform win32 gui module.
const TVM_SELECTITEM = 0x110B
/// Defines the tvgn caret constant used by the minisql platform win32 gui module.
const TVGN_CARET = 9
/// Defines the tve expand constant used by the minisql platform win32 gui module.
const TVE_EXPAND = 2
/// Defines the tcm insertitemw constant used by the minisql platform win32 gui module.
const TCM_INSERTITEMW = 0x133E
/// Defines the tcm getcursel constant used by the minisql platform win32 gui module.
const TCM_GETCURSEL = 0x130B
/// Defines the tcm getitemrect constant used by the minisql platform win32 gui module.
const TCM_GETITEMRECT = 0x130A
/// Defines the tcm hittest constant used by the minisql platform win32 gui module.
const TCM_HITTEST = 0x130D
/// Defines the tcif text constant used by the minisql platform win32 gui module.
const TCIF_TEXT = 1
/// Defines the lvs report constant used by the minisql platform win32 gui module.
const LVS_REPORT = 1
/// Defines the lvs showselalways constant used by the minisql platform win32 gui module.
const LVS_SHOWSELALWAYS = 8
/// Defines the lvs singlesel constant used by the minisql platform win32 gui module.
const LVS_SINGLESEL = 4
/// Defines the lvs ex gridlines constant used by the minisql platform win32 gui module.
const LVS_EX_GRIDLINES = 1
/// Defines the lvs ex fullrowselect constant used by the minisql platform win32 gui module.
const LVS_EX_FULLROWSELECT = 32
/// Defines the lvs ex doublebuffer constant used by the minisql platform win32 gui module.
const LVS_EX_DOUBLEBUFFER = 65536
/// Defines the lvm first constant used by the minisql platform win32 gui module.
const LVM_FIRST = 0x1000
/// Defines the lvm setextendedlistviewstyle constant used by the minisql platform win32 gui module.
const LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54
/// Defines the lvm deleteallitems constant used by the minisql platform win32 gui module.
const LVM_DELETEALLITEMS = LVM_FIRST + 9
/// Defines the lvm getitemcount constant used by the minisql platform win32 gui module.
const LVM_GETITEMCOUNT = LVM_FIRST + 4
/// Defines the lvm insertitemw constant used by the minisql platform win32 gui module.
const LVM_INSERTITEMW = LVM_FIRST + 77
/// Defines the lvm setitemtextw constant used by the minisql platform win32 gui module.
const LVM_SETITEMTEXTW = LVM_FIRST + 116
/// Defines the lvm insertcolumnw constant used by the minisql platform win32 gui module.
const LVM_INSERTCOLUMNW = LVM_FIRST + 97
/// Defines the lvm deletecolumn constant used by the minisql platform win32 gui module.
const LVM_DELETECOLUMN = LVM_FIRST + 28
/// Defines the lvm getnextitem constant used by the minisql platform win32 gui module.
const LVM_GETNEXTITEM = LVM_FIRST + 12
/// Defines the lvm setitemstate constant used by the minisql platform win32 gui module.
const LVM_SETITEMSTATE = LVM_FIRST + 43
/// Defines the lvm getitemtextw constant used by the minisql platform win32 gui module.
const LVM_GETITEMTEXTW = LVM_FIRST + 115
/// Defines the lvm subitemhittest constant used by the minisql platform win32 gui module.
const LVM_SUBITEMHITTEST = LVM_FIRST + 57
/// Defines the lvif text constant used by the minisql platform win32 gui module.
const LVIF_TEXT = 1
/// Defines the lvif state constant used by the minisql platform win32 gui module.
const LVIF_STATE = 8
/// Defines the lvis focused constant used by the minisql platform win32 gui module.
const LVIS_FOCUSED = 1
/// Defines the lvis selected constant used by the minisql platform win32 gui module.
const LVIS_SELECTED = 2
/// Defines the lvni selected constant used by the minisql platform win32 gui module.
const LVNI_SELECTED = 2
/// Defines the lvcf fmt constant used by the minisql platform win32 gui module.
const LVCF_FMT = 1
/// Defines the lvcf width constant used by the minisql platform win32 gui module.
const LVCF_WIDTH = 2
/// Defines the lvcf text constant used by the minisql platform win32 gui module.
const LVCF_TEXT = 4
/// Defines the lvcf subitem constant used by the minisql platform win32 gui module.
const LVCF_SUBITEM = 8
/// Defines the swp nozorder constant used by the minisql platform win32 gui module.
const SWP_NOZORDER = 4
/// Defines the swp nomove constant used by the minisql platform win32 gui module.
const SWP_NOMOVE = 2
/// Defines the swp noactivate constant used by the minisql platform win32 gui module.
const SWP_NOACTIVATE = 16
/// Defines the rdw invalidate constant used by the minisql platform win32 gui module.
const RDW_INVALIDATE = 1
/// Defines the rdw erase constant used by the minisql platform win32 gui module.
const RDW_ERASE = 4
/// Defines the rdw allchildren constant used by the minisql platform win32 gui module.
const RDW_ALLCHILDREN = 128
/// Defines the rdw updatenow constant used by the minisql platform win32 gui module.
const RDW_UPDATENOW = 256
/// Defines the mb ok constant used by the minisql platform win32 gui module.
const MB_OK = 0
/// Defines the mb iconinformation constant used by the minisql platform win32 gui module.
const MB_ICONINFORMATION = 64
/// Defines the mb iconerror constant used by the minisql platform win32 gui module.
const MB_ICONERROR = 16
/// Defines the mb yesno constant used by the minisql platform win32 gui module.
const MB_YESNO = 4
/// Defines the mb iconwarning constant used by the minisql platform win32 gui module.
const MB_ICONWARNING = 48
/// Defines the idyes constant used by the minisql platform win32 gui module.
const IDYES = 6
/// Defines the cf unicodetext constant used by the minisql platform win32 gui module.
const CF_UNICODETEXT = 13
/// Defines the gmem moveable constant used by the minisql platform win32 gui module.
const GMEM_MOVEABLE = 2
/// Defines the gmem zeroinit constant used by the minisql platform win32 gui module.
const GMEM_ZEROINIT = 64
/// Defines the clipboard open attempts constant used by the minisql platform win32 gui module.
const CLIPBOARD_OPEN_ATTEMPTS = 100
/// Defines the clipboard retry delay ms constant used by the minisql platform win32 gui module.
const CLIPBOARD_RETRY_DELAY_MS = 10
/// Defines the tpm rightbutton constant used by the minisql platform win32 gui module.
const TPM_RIGHTBUTTON = 2
/// Defines the tpm returncmd constant used by the minisql platform win32 gui module.
const TPM_RETURNCMD = 256
/// Defines the ofn overwriteprompt constant used by the minisql platform win32 gui module.
const OFN_OVERWRITEPROMPT = 2
/// Defines the ofn pathmustexist constant used by the minisql platform win32 gui module.
const OFN_PATHMUSTEXIST = 0x00000800
/// Defines the fvirtkey constant used by the minisql platform win32 gui module.
const FVIRTKEY = 1
/// Defines the fshift constant used by the minisql platform win32 gui module.
const FSHIFT = 4
/// Defines the fcontrol constant used by the minisql platform win32 gui module.
const FCONTROL = 8
/// Defines the vk f5 constant used by the minisql platform win32 gui module.
const VK_F5 = 0x74
/// Defines the vk return constant used by the minisql platform win32 gui module.
const VK_RETURN = 0x0D
/// Defines the vk n constant used by the minisql platform win32 gui module.
const VK_N = 0x4E
/// Defines the vk w constant used by the minisql platform win32 gui module.
const VK_W = 0x57
/// Defines the vk e constant used by the minisql platform win32 gui module.
const VK_E = 0x45

/// Defines the menu file new constant used by the minisql platform win32 gui module.
const MENU_FILE_NEW = 1000
/// Defines the menu file close constant used by the minisql platform win32 gui module.
const MENU_FILE_CLOSE = 1001
/// Defines the menu file exit constant used by the minisql platform win32 gui module.
const MENU_FILE_EXIT = 1002
/// Defines the menu file close worksheet constant used by the minisql platform win32 gui module.
const MENU_FILE_CLOSE_WORKSHEET = 1003
/// Defines the menu file export constant used by the minisql platform win32 gui module.
const MENU_FILE_EXPORT = 1004
/// Defines the menu alias connect constant used by the minisql platform win32 gui module.
const MENU_ALIAS_CONNECT = 1100
/// Defines the menu alias new constant used by the minisql platform win32 gui module.
const MENU_ALIAS_NEW = 1101
/// Defines the menu alias edit constant used by the minisql platform win32 gui module.
const MENU_ALIAS_EDIT = 1102
/// Defines the menu alias delete constant used by the minisql platform win32 gui module.
const MENU_ALIAS_DELETE = 1103
/// Defines the menu alias save constant used by the minisql platform win32 gui module.
const MENU_ALIAS_SAVE = 1104
/// Defines the menu session refresh constant used by the minisql platform win32 gui module.
const MENU_SESSION_REFRESH = 1200
/// Defines the menu session commit constant used by the minisql platform win32 gui module.
const MENU_SESSION_COMMIT = 1201
/// Defines the menu session rollback constant used by the minisql platform win32 gui module.
const MENU_SESSION_ROLLBACK = 1202
/// Defines the menu sql execute constant used by the minisql platform win32 gui module.
const MENU_SQL_EXECUTE = 1300
/// Defines the menu sql explain constant used by the minisql platform win32 gui module.
const MENU_SQL_EXPLAIN = 1301
/// Defines the menu sql cancel constant used by the minisql platform win32 gui module.
const MENU_SQL_CANCEL = 1302
/// Defines the menu sql clear constant used by the minisql platform win32 gui module.
const MENU_SQL_CLEAR = 1303
/// Defines the menu sql execute script constant used by the minisql platform win32 gui module.
const MENU_SQL_EXECUTE_SCRIPT = 1304
/// Defines the menu admin database constant used by the minisql platform win32 gui module.
const MENU_ADMIN_DATABASE = 1400
/// Defines the menu admin security constant used by the minisql platform win32 gui module.
const MENU_ADMIN_SECURITY = 1401
/// Defines the menu help about constant used by the minisql platform win32 gui module.
const MENU_HELP_ABOUT = 1500
/// Defines the menu object use constant used by the minisql platform win32 gui module.
const MENU_OBJECT_USE = 1600
/// Defines the menu object describe constant used by the minisql platform win32 gui module.
const MENU_OBJECT_DESCRIBE = 1601
/// Defines the menu object query constant used by the minisql platform win32 gui module.
const MENU_OBJECT_QUERY = 1602
/// Defines the menu object schema constant used by the minisql platform win32 gui module.
const MENU_OBJECT_SCHEMA = 1603

/// Defines the menu data add constant used by the minisql platform win32 gui module.
const MENU_DATA_ADD = 1700
/// Defines the menu data copy constant used by the minisql platform win32 gui module.
const MENU_DATA_COPY = 1701
/// Defines the menu data paste constant used by the minisql platform win32 gui module.
const MENU_DATA_PASTE = 1702
/// Defines the menu data edit constant used by the minisql platform win32 gui module.
const MENU_DATA_EDIT = 1703
/// Defines the menu data delete constant used by the minisql platform win32 gui module.
const MENU_DATA_DELETE = 1704
/// Defines the menu data apply constant used by the minisql platform win32 gui module.
const MENU_DATA_APPLY = 1705
/// Defines the menu data revert constant used by the minisql platform win32 gui module.
const MENU_DATA_REVERT = 1706
/// Defines the menu data preview constant used by the minisql platform win32 gui module.
const MENU_DATA_PREVIEW = 1707

/// COLORREF palette shared by native SQL syntax rendering and its smoke tests.
const SQL_COLOR_DEFAULT = 0x002B2B2B
/// Defines the sql color keyword constant used by the minisql platform win32 gui module.
const SQL_COLOR_KEYWORD = 0x009E5A00
/// Defines the sql color string constant used by the minisql platform win32 gui module.
const SQL_COLOR_STRING = 0x001515A3
/// Defines the sql color number constant used by the minisql platform win32 gui module.
const SQL_COLOR_NUMBER = 0x00588609
/// Defines the sql color comment constant used by the minisql platform win32 gui module.
const SQL_COLOR_COMMENT = 0x005F7F3F
/// Defines the sql color quoted identifier constant used by the minisql platform win32 gui module.
const SQL_COLOR_QUOTED_IDENTIFIER = 0x009E4A79

/// Groups the native GuiEvent state used by the Windows workbench.
struct GuiEvent
  /// Stores the hwnd value supplied by the Win32 event or control.
  hwnd
  /// Stores the message value supplied by the Win32 event or control.
  message
  /// Stores the controlId value supplied by the Win32 event or control.
  controlId
  /// Stores the notification value supplied by the Win32 event or control.
  notification
  /// Stores the source value supplied by the Win32 event or control.
  source
end struct

/// Retains a top-level window's minimum client dimensions in DPI-independent pixels.
struct WindowMinimum
  /// Identifies the top-level window governed by this constraint.
  hwnd
  /// Stores the minimum usable client width in DIPs.
  width
  /// Stores the minimum usable client height in DIPs.
  height
end struct

/// Associates one top-level workbench window with its native shortcut table.
struct AcceleratorBinding
  /// Identifies the top-level window receiving translated WM_COMMAND messages.
  hwnd
  /// Owns the native HACCEL handle until the window is destroyed.
  table
end struct

/// Stores module-wide gui events state for the minisql platform win32 gui module.
guiEvents = []
/// Stores module-wide gui class registered state for the minisql platform win32 gui module.
guiClassRegistered = false
/// Stores module-wide gui class name wide state for the minisql platform win32 gui module.
guiClassNameWide = void
/// Stores module-wide modern gui font dpis state for the minisql platform win32 gui module.
modernGuiFontDpis = []
/// Stores module-wide modern gui fonts state for the minisql platform win32 gui module.
modernGuiFonts = []
/// Stores module-wide window minimums state for the minisql platform win32 gui module.
windowMinimums = []
/// Stores module-wide accelerator bindings state for the minisql platform win32 gui module.
acceleratorBindings = []
/// Stores module-wide close event windows state for the minisql platform win32 gui module.
closeEventWindows = []
/// Stores module-wide rich edit library state for the minisql platform win32 gui module.
richEditLibrary = 0

/// Binds the native Windows CreateWindowExW API used by the GUI abstraction.
/// @param exStyle exStyle value consumed by this operation.
/// @param className className value consumed by this operation.
/// @param windowName windowName value consumed by this operation.
/// @param style style value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param parent parent value consumed by this operation.
/// @param menu menu value consumed by this operation.
/// @param instance instance value consumed by this operation.
/// @param param param value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function CreateWindowExW(exStyle as u32, className as wstr, windowName as wstr, style as u32, x as i32, y as i32, width as i32, height as i32, parent as ptr, menu as ptr, instance as ptr, param as ptr) from "user32.dll" symbol "CreateWindowExW" returns ptr
/// Binds the native Windows DestroyWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function DestroyWindow(hwnd as ptr) from "user32.dll" symbol "DestroyWindow" returns i32
/// Binds the native Windows GetDesktopWindow API used by the GUI abstraction.
/// @returns Native ptr result produced by the call.
extern function GetDesktopWindow() from "user32.dll" symbol "GetDesktopWindow" returns ptr
/// Binds the native Windows ShowWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param command command value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function ShowWindow(hwnd as ptr, command as i32) from "user32.dll" symbol "ShowWindow" returns bool
/// Binds the native Windows UpdateWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function UpdateWindow(hwnd as ptr) from "user32.dll" symbol "UpdateWindow" returns bool
/// Binds the native Windows SetWindowTextW API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
/// @returns Native bool result produced by the call.
extern function SetWindowTextW(hwnd as ptr, text as wstr) from "user32.dll" symbol "SetWindowTextW" returns bool
/// Binds the native Windows GetWindowTextLengthW API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function GetWindowTextLengthW(hwnd as ptr) from "user32.dll" symbol "GetWindowTextLengthW" returns i32
/// Binds the native Windows GetWindowTextW API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param maxCount Number of max to process.
/// @returns Native i32 result produced by the call.
extern function GetWindowTextW(hwnd as ptr, buffer as bytes, maxCount as i32) from "user32.dll" symbol "GetWindowTextW" returns i32
/// Binds the native Windows SendMessageWInt API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function SendMessageWInt(hwnd as ptr, message as u32, wParam as i32, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
/// Binds the native Windows SendMessageWPtrInt API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function SendMessageWPtrInt(hwnd as ptr, message as u32, wParam as ptr, lParam as i32) from "user32.dll" symbol "SendMessageW" returns i32
/// Binds the native Windows SendMessageWText API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function SendMessageWText(hwnd as ptr, message as u32, wParam as i32, lParam as wstr) from "user32.dll" symbol "SendMessageW" returns i32
/// Binds the native Windows SendMessageWIndexBuffer API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function SendMessageWIndexBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns i32
/// Binds the native Windows CreateMenu API used by the GUI abstraction.
/// @returns Native ptr result produced by the call.
extern function CreateMenu() from "user32.dll" symbol "CreateMenu" returns ptr
/// Binds the native Windows CreatePopupMenu API used by the GUI abstraction.
/// @returns Native ptr result produced by the call.
extern function CreatePopupMenu() from "user32.dll" symbol "CreatePopupMenu" returns ptr
/// Binds the native Windows AppendMenuWInt API used by the GUI abstraction.
/// @param menu menu value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param itemId Identifier of item.
/// @param text Text consumed by the operation.
/// @returns Native bool result produced by the call.
extern function AppendMenuWInt(menu as ptr, flags as u32, itemId as u32, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
/// Binds the native Windows AppendMenuWPtr API used by the GUI abstraction.
/// @param menu menu value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param item item value consumed by this operation.
/// @param text Text consumed by the operation.
/// @returns Native bool result produced by the call.
extern function AppendMenuWPtr(menu as ptr, flags as u32, item as ptr, text as wstr) from "user32.dll" symbol "AppendMenuW" returns bool
/// Binds the native Windows SetMenu API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param menu menu value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function SetMenu(hwnd as ptr, menu as ptr) from "user32.dll" symbol "SetMenu" returns bool
/// Binds the native Windows DrawMenuBar API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function DrawMenuBar(hwnd as ptr) from "user32.dll" symbol "DrawMenuBar" returns bool
/// Binds the native Windows DefWindowProcW API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function DefWindowProcW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "DefWindowProcW" returns ptr
/// Binds the native Windows RegisterClassExW API used by the GUI abstraction.
/// @param windowClass windowClass value consumed by this operation.
/// @returns Native u32 result produced by the call.
extern function RegisterClassExW(windowClass as bytes) from "user32.dll" symbol "RegisterClassExW" returns u32
/// Binds the native Windows GetModuleHandleW API used by the GUI abstraction.
/// @param moduleName moduleName value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function GetModuleHandleW(moduleName as ptr) from "kernel32.dll" symbol "GetModuleHandleW" returns ptr
/// Loads the system RichEdit implementation required by the colorized SQL editor.
/// @param moduleName moduleName value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function LoadLibraryW(moduleName as wstr) from "kernel32.dll" symbol "LoadLibraryW" returns ptr
/// Binds the native Windows GetLastError API used by the GUI abstraction.
/// @returns Native u32 result produced by the call.
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
/// Binds the native Windows LoadCursorW API used by the GUI abstraction.
/// @param instance instance value consumed by this operation.
/// @param cursorName cursorName value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function LoadCursorW(instance as ptr, cursorName as ptr) from "user32.dll" symbol "LoadCursorW" returns ptr
/// Binds the native Windows PostQuitMessage API used by the GUI abstraction.
/// @param exitCode exitCode value consumed by this operation.
extern function PostQuitMessage(exitCode as i32) from "user32.dll" symbol "PostQuitMessage" returns void
/// Binds the native Windows PostMessageW API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function PostMessageW(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "PostMessageW" returns bool
/// Binds the native Windows MoveWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param repaint repaint value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function MoveWindow(hwnd as ptr, x as i32, y as i32, width as i32, height as i32, repaint as bool) from "user32.dll" symbol "MoveWindow" returns bool
/// Binds the native Windows GetClientRect API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param rectangle rectangle value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetClientRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetClientRect" returns bool
/// Binds the native Windows GetWindowRect API used by geometry assertions.
/// @param hwnd hwnd value consumed by this operation.
/// @param rectangle rectangle value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetWindowRect(hwnd as ptr, rectangle as bytes) from "user32.dll" symbol "GetWindowRect" returns bool
/// Binds the native Windows MapWindowPoints API used to express child rectangles in parent coordinates.
/// @param fromWindow fromWindow value consumed by this operation.
/// @param toWindow toWindow value consumed by this operation.
/// @param points points value consumed by this operation.
/// @param pointCount Number of point to process.
/// @returns Native i32 result produced by the call.
extern function MapWindowPoints(fromWindow as ptr, toWindow as ptr, points as bytes, pointCount as u32) from "user32.dll" symbol "MapWindowPoints" returns i32
/// Binds the native Windows GetDpiForWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function GetDpiForWindow(hwnd as ptr) from "user32.dll" symbol "GetDpiForWindow" returns i32
/// Binds the native Windows GetDpiForSystem API used before a top-level handle exists.
/// @returns Native i32 result produced by the call.
extern function GetDpiForSystem() from "user32.dll" symbol "GetDpiForSystem" returns i32
/// Binds the native Windows SetProcessDpiAwarenessContext API used by the GUI abstraction.
/// @param context Context that carries state for the operation.
/// @returns Native bool result produced by the call.
extern function SetProcessDpiAwarenessContext(context as ptr) from "user32.dll" symbol "SetProcessDpiAwarenessContext" returns bool
/// Binds the DPI-aware non-client size calculation used for exact client dimensions.
/// @param rectangle rectangle value consumed by this operation.
/// @param style style value consumed by this operation.
/// @param hasMenu hasMenu value consumed by this operation.
/// @param exStyle exStyle value consumed by this operation.
/// @param dpiValue dpiValue value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function AdjustWindowRectExForDpi(rectangle as bytes, style as u32, hasMenu as bool, exStyle as u32, dpiValue as u32) from "user32.dll" symbol "AdjustWindowRectExForDpi" returns bool
/// Binds the native Windows SetWindowPos API used for DPI changes and deterministic test sizes.
/// @param hwnd hwnd value consumed by this operation.
/// @param insertAfter insertAfter value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param flags Bit flags controlling the operation.
/// @returns Native bool result produced by the call.
extern function SetWindowPos(hwnd as ptr, insertAfter as ptr, x as i32, y as i32, width as i32, height as i32, flags as u32) from "user32.dll" symbol "SetWindowPos" returns bool
/// Binds the native Windows RedrawWindow API used to erase stale resized child surfaces.
/// @param hwnd hwnd value consumed by this operation.
/// @param updateRectangle updateRectangle value consumed by this operation.
/// @param updateRegion updateRegion value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native bool result produced by the call.
extern function RedrawWindow(hwnd as ptr, updateRectangle as ptr, updateRegion as ptr, flags as u32) from "user32.dll" symbol "RedrawWindow" returns bool
/// Binds the native Windows MultiByteToWideChar API used by the GUI abstraction.
/// @param codePage codePage value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param source source value consumed by this operation.
/// @param sourceCount Number of source to process.
/// @param output Output collection or buffer populated by the operation.
/// @param outputCount Number of output to process.
/// @returns Native i32 result produced by the call.
extern function MultiByteToWideChar(codePage as u32, flags as u32, source as bytes, sourceCount as i32, output as bytes, outputCount as i32) from "kernel32.dll" symbol "MultiByteToWideChar" returns i32
/// Binds the native Windows RtlMoveMemory API used by the GUI abstraction.
/// @param destination destination value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param length length value consumed by this operation.
extern function RtlMoveMemory(destination as bytes, source as ptr, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
/// Copies a modified native structure back to a pointer owned by Windows.
/// @param destination destination value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param length length value consumed by this operation.
extern function RtlMoveMemoryToPtr(destination as ptr, source as bytes, length as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns void
/// Binds the native Windows InitCommonControlsEx API used by the GUI abstraction.
/// @param configuration configuration value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function InitCommonControlsEx(configuration as bytes) from "comctl32.dll" symbol "InitCommonControlsEx" returns bool
/// Binds the native Windows PeekMessageW API used by the GUI abstraction.
/// @param message Human-readable message associated with the operation.
/// @param hwnd hwnd value consumed by this operation.
/// @param filterMin filterMin value consumed by this operation.
/// @param filterMax filterMax value consumed by this operation.
/// @param removeMessage removeMessage value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function PeekMessageW(message as bytes, hwnd as ptr, filterMin as u32, filterMax as u32, removeMessage as u32) from "user32.dll" symbol "PeekMessageW" returns bool
/// Binds the native Windows TranslateMessage API used by the GUI abstraction.
/// @param message Human-readable message associated with the operation.
/// @returns Native bool result produced by the call.
extern function TranslateMessage(message as bytes) from "user32.dll" symbol "TranslateMessage" returns bool
/// Binds the native Windows DispatchMessageW API used by the GUI abstraction.
/// @param message Human-readable message associated with the operation.
/// @returns Native ptr result produced by the call.
extern function DispatchMessageW(message as bytes) from "user32.dll" symbol "DispatchMessageW" returns ptr
/// Binds the native Windows IsWindow API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function IsWindow(hwnd as ptr) from "user32.dll" symbol "IsWindow" returns bool
/// Binds the native Windows enabled-state query used by interaction smoke tests.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function IsWindowEnabled(hwnd as ptr) from "user32.dll" symbol "IsWindowEnabled" returns bool
/// Binds the native Windows Sleep API used by the GUI abstraction.
/// @param milliseconds milliseconds value consumed by this operation.
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void
/// Binds the native Windows WideCharToMultiByte API used by the GUI abstraction.
/// @param codePage codePage value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param wideText wideText value consumed by this operation.
/// @param wideCount Number of wide to process.
/// @param output Output collection or buffer populated by the operation.
/// @param outputCount Number of output to process.
/// @param defaultChar defaultChar value consumed by this operation.
/// @param usedDefault usedDefault value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32
/// Binds the native Windows GetStockObject API used by the GUI abstraction.
/// @param kind kind value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function GetStockObject(kind as i32) from "gdi32.dll" symbol "GetStockObject" returns ptr
/// Creates the shared Segoe UI font used by every workbench control.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param escapement escapement value consumed by this operation.
/// @param orientation orientation value consumed by this operation.
/// @param weight weight value consumed by this operation.
/// @param italic italic value consumed by this operation.
/// @param underline underline value consumed by this operation.
/// @param strikeOut strikeOut value consumed by this operation.
/// @param charSet charSet value consumed by this operation.
/// @param outputPrecision outputPrecision value consumed by this operation.
/// @param clipPrecision clipPrecision value consumed by this operation.
/// @param quality quality value consumed by this operation.
/// @param pitchAndFamily pitchAndFamily value consumed by this operation.
/// @param faceName faceName value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function CreateFontW(height as i32, width as i32, escapement as i32, orientation as i32, weight as i32, italic as u32, underline as u32, strikeOut as u32, charSet as u32, outputPrecision as u32, clipPrecision as u32, quality as u32, pitchAndFamily as u32, faceName as wstr) from "gdi32.dll" symbol "CreateFontW" returns ptr
/// Applies Explorer visual styles to common controls.
/// @param hwnd hwnd value consumed by this operation.
/// @param subAppName subAppName value consumed by this operation.
/// @param subIdList subIdList value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function SetWindowTheme(hwnd as ptr, subAppName as wstr, subIdList as ptr) from "uxtheme.dll" symbol "SetWindowTheme" returns i32
/// Applies supported Windows 11 non-client chrome attributes.
/// @param hwnd hwnd value consumed by this operation.
/// @param attribute attribute value consumed by this operation.
/// @param value Value consumed or transformed by the operation.
/// @param size Size in the units required by the operation.
/// @returns Native i32 result produced by the call.
extern function DwmSetWindowAttribute(hwnd as ptr, attribute as u32, value as bytes, size as u32) from "dwmapi.dll" symbol "DwmSetWindowAttribute" returns i32
/// Enables or disables a native control while background work is active.
/// @param hwnd hwnd value consumed by this operation.
/// @param enabled enabled value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function EnableWindow(hwnd as ptr, enabled as bool) from "user32.dll" symbol "EnableWindow" returns bool
/// Moves keyboard focus to a native editor or browser control.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function SetFocus(hwnd as ptr) from "user32.dll" symbol "SetFocus" returns ptr
/// Shows a native informational dialog owned by the workbench.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param caption caption value consumed by this operation.
/// @param kind kind value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function MessageBoxW(hwnd as ptr, text as wstr, caption as wstr, kind as u32) from "user32.dll" symbol "MessageBoxW" returns i32
/// Returns the currently active top-level window for dialog-style keyboard routing.
/// @returns Native ptr result produced by the call.
extern function GetActiveWindow() from "user32.dll" symbol "GetActiveWindow" returns ptr
/// Routes Tab, Shift+Tab, Enter, and mnemonic input among ordinary child controls.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @returns Native bool result produced by the call.
extern function IsDialogMessageW(hwnd as ptr, message as bytes) from "user32.dll" symbol "IsDialogMessageW" returns bool
/// Returns a child control's numeric identifier for context-menu routing.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function GetDlgCtrlID(hwnd as ptr) from "user32.dll" symbol "GetDlgCtrlID" returns i32
/// Reads the current pointer position for ListView cell and context-menu hit testing.
/// @param point point value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetCursorPos(point as bytes) from "user32.dll" symbol "GetCursorPos" returns bool
/// Converts a screen-space point to coordinates relative to one native control.
/// @param hwnd hwnd value consumed by this operation.
/// @param point point value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function ScreenToClient(hwnd as ptr, point as bytes) from "user32.dll" symbol "ScreenToClient" returns bool
/// Displays a popup menu and returns the selected command without blocking controller state.
/// @param menu menu value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param hwnd hwnd value consumed by this operation.
/// @param parameters parameters value consumed by this operation.
/// @returns Native u32 result produced by the call.
extern function TrackPopupMenuEx(menu as ptr, flags as u32, x as i32, y as i32, hwnd as ptr, parameters as ptr) from "user32.dll" symbol "TrackPopupMenuEx" returns u32
/// Releases a temporary native menu after a context action was selected.
/// @param menu menu value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function DestroyMenu(menu as ptr) from "user32.dll" symbol "DestroyMenu" returns bool
/// Builds a native keyboard accelerator table from packed ACCEL records.
/// @param entries entries value consumed by this operation.
/// @param count Number of items or units to process.
/// @returns Native ptr result produced by the call.
extern function CreateAcceleratorTableW(entries as bytes, count as i32) from "user32.dll" symbol "CreateAcceleratorTableW" returns ptr
/// Translates one queued key message into its registered workbench command.
/// @param hwnd hwnd value consumed by this operation.
/// @param table table value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @returns Native i32 result produced by the call.
extern function TranslateAcceleratorW(hwnd as ptr, table as ptr, message as bytes) from "user32.dll" symbol "TranslateAcceleratorW" returns i32
/// Releases a native keyboard accelerator table.
/// @param table table value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function DestroyAcceleratorTable(table as ptr) from "user32.dll" symbol "DestroyAcceleratorTable" returns bool
/// Opens the process clipboard for Unicode row copy and paste.
/// @param hwnd hwnd value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function OpenClipboard(hwnd as ptr) from "user32.dll" symbol "OpenClipboard" returns bool
/// Clears the clipboard after exclusive ownership was acquired.
/// @returns Native bool result produced by the call.
extern function EmptyClipboard() from "user32.dll" symbol "EmptyClipboard" returns bool
/// Publishes a movable Unicode memory block to the clipboard.
/// @param format format value consumed by this operation.
/// @param memory memory value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function SetClipboardData(format as u32, memory as ptr) from "user32.dll" symbol "SetClipboardData" returns ptr
/// Retrieves one published clipboard memory block.
/// @param format format value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function GetClipboardData(format as u32) from "user32.dll" symbol "GetClipboardData" returns ptr
/// Closes the clipboard ownership scope.
/// @returns Native bool result produced by the call.
extern function CloseClipboard() from "user32.dll" symbol "CloseClipboard" returns bool
/// Allocates a movable process heap block required by SetClipboardData.
/// @param flags Bit flags controlling the operation.
/// @param size Size in the units required by the operation.
/// @returns Native ptr result produced by the call.
extern function GlobalAlloc(flags as u32, size as u64) from "kernel32.dll" symbol "GlobalAlloc" returns ptr
/// Locks a movable global memory block and returns its stable data pointer.
/// @param memory memory value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function GlobalLock(memory as ptr) from "kernel32.dll" symbol "GlobalLock" returns ptr
/// Unlocks a movable global memory block after copying data.
/// @param memory memory value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GlobalUnlock(memory as ptr) from "kernel32.dll" symbol "GlobalUnlock" returns bool
/// Releases a global memory block when clipboard publication fails.
/// @param memory memory value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function GlobalFree(memory as ptr) from "kernel32.dll" symbol "GlobalFree" returns ptr
/// Returns the byte size of a global memory block used by clipboard reads.
/// @param memory memory value consumed by this operation.
/// @returns Native u64 result produced by the call.
extern function GlobalSize(memory as ptr) from "kernel32.dll" symbol "GlobalSize" returns u64
/// Opens the native Save As dialog for CSV export.
/// @param configuration configuration value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetSaveFileNameW(configuration as bytes) from "comdlg32.dll" symbol "GetSaveFileNameW" returns bool

/// Binds the native Windows SendMessageWPtrBuffer API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function SendMessageWPtrBuffer(hwnd as ptr, message as u32, wParam as ptr, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
/// Binds the native Windows SendMessageWIntBuffer API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function SendMessageWIntBuffer(hwnd as ptr, message as u32, wParam as i32, lParam as bytes) from "user32.dll" symbol "SendMessageW" returns ptr
/// Binds the native Windows SendMessageWPtr API used by the GUI abstraction.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function SendMessageWPtr(hwnd as ptr, message as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "SendMessageW" returns ptr

/// Encodes a MiniLang UTF-8 string as a NUL-terminated UTF-16LE Win32 buffer.
/// @param text Text consumed by the operation.
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

/// Writes one non-negative native pointer into an x64 ABI structure buffer.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param value Value consumed or transformed by the operation.
function writePointer(buffer, offset, value)
  endian.writeU64LE(buffer, offset, endian.uint64FromInt(value))
  return true
end function

/// Writes a sign-extended Win32 sentinel such as TVI_ROOT or TVI_LAST.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param low low value consumed by this operation.
function writeSpecialPointer(buffer, offset, low)
  endian.writeU64LE(buffer, offset, endian.makeUInt64(0xFFFFFFFF, low))
  return true
end function

/// Reads one pointer-sized field from an x64 ABI structure buffer.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
function readPointer(buffer, offset)
  return endian.uint64ToInt(endian.readU64LE(buffer, offset))
end function

/// Divides integers with truncation while preserving MiniLang's integer runtime type.
/// @param numerator numerator value consumed by this operation.
/// @param denominator denominator value consumed by this operation.
function divideInt(numerator, denominator)
  if typeof(numerator) != "int" or typeof(denominator) != "int" or denominator <= 0 then return 0 end if
  if numerator < 0 then return -divideInt(-numerator, denominator) end if
  return (numerator - (numerator % denominator)) / denominator
end function

/// Scales a DPI-independent pixel value for an explicit monitor DPI.
/// @param value Value consumed or transformed by the operation.
/// @param dpiValue dpiValue value consumed by this operation.
function scaleAtDpi(value, dpiValue)
  if typeof(value) != "int" or typeof(dpiValue) != "int" or dpiValue < 96 then return value end if
  if value < 0 then return -divideInt((-value) * dpiValue + 48, 96) end if
  return divideInt(value * dpiValue + 48, 96)
end function

/// Finds the minimum-client constraint registered for a top-level window.
/// @param hwnd hwnd value consumed by this operation.
function windowMinimum(hwnd)
  global windowMinimums
  for each minimum in windowMinimums
    if minimum.hwnd == hwnd then return minimum end if
  end for
  return void
end function

/// Reports whether the owning controller asked to validate a native close request.
/// @param hwnd hwnd value consumed by this operation.
function routesCloseEvent(hwnd)
  global closeEventWindows
  for each retainedHwnd in closeEventWindows
    if retainedHwnd == hwnd then return true end if
  end for
  return false
end function

/// Calculates a DPI-aware outer window size for the requested client area.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param dpiValue dpiValue value consumed by this operation.
/// @param hasMenu hasMenu value consumed by this operation.
function outerSizeForClient(width, height, dpiValue, hasMenu)
  rectangle = bytes(16, 0)
  endian.writeI32LE(rectangle, 8, scaleAtDpi(width, dpiValue))
  endian.writeI32LE(rectangle, 12, scaleAtDpi(height, dpiValue))
  if not AdjustWindowRectExForDpi(rectangle, WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN, hasMenu, 0, dpiValue) then return fail("outerSizeForClient", "AdjustWindowRectExForDpi failed") end if
  return [endian.readI32LE(rectangle, 8) - endian.readI32LE(rectangle, 0), endian.readI32LE(rectangle, 12) - endian.readI32LE(rectangle, 4)]
end function

/// Converts relevant Win32 callbacks into queued controller events and handles native sizing contracts.
/// @param hwnd hwnd value consumed by this operation.
/// @param message Human-readable message associated with the operation.
/// @param wParam wParam value consumed by this operation.
/// @param lParam lParam value consumed by this operation.
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
    notification = endian.readI32LE(header, 16)
    if notification == -108 then
      columnClick = bytes(32, 0)
      RtlMoveMemory(columnClick, lParam, 32)
      source = endian.readI32LE(columnClick, 28)
    else if notification == -2 then
      // NM_CLICK does not retain its pointer location. Capture it while the
      // notification is synchronous so delayed controller processing can
      // distinguish a tab body click from its trailing close glyph.
      point = bytes(8, 0)
      if source != 0 and GetCursorPos(point) and ScreenToClient(source, point) then
        pointX = endian.readI32LE(point, 0)
        pointY = endian.readI32LE(point, 4)
        if pointX >= 0 and pointX <= 65535 and pointY >= 0 and pointY <= 65535 then source = (pointY << 16) | (pointX & 65535) else source = -1 end if
      else
        source = -1
      end if
    end if
    guiEvents = guiEvents + [GuiEvent(hwnd, message, controlId, notification, source)]
    return 0
  end if
  if message == WM_CONTEXTMENU then
    controlId = 0
    if wParam != 0 then controlId = GetDlgCtrlID(wParam) end if
    guiEvents = guiEvents + [GuiEvent(hwnd, message, controlId, 0, wParam)]
    return 0
  end if
  if message == WM_SIZE then
    guiEvents = guiEvents + [GuiEvent(hwnd, message, lParam & 65535, (lParam >> 16) & 65535, 0)]
    return DefWindowProcW(hwnd, message, wParam, lParam)
  end if
  if message == WM_MOVE then
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
    // Long-lived controllers may need to confirm staged work before destruction;
    // modal helpers keep the conventional immediate-close behavior.
    if routesCloseEvent(hwnd) then
      guiEvents = guiEvents + [GuiEvent(hwnd, message, 0, 0, 0)]
      return 0
    end if
    ignored = destroy(hwnd)
    return 0
  end if
  if message == WM_DESTROY then
    return 0
  end if
  return DefWindowProcW(hwnd, message, wParam, lParam)
end function

/// Initializes the common-control classes required by trees, tabs, and ListViews.
function initializeCommonControls()
  configuration = bytes(8, 0)
  endian.writeU32LE(configuration, 0, 8)
  endian.writeU32LE(configuration, 4, ICC_LISTVIEW_CLASSES | ICC_TREEVIEW_CLASSES | ICC_BAR_CLASSES | ICC_TAB_CLASSES)
  if not InitCommonControlsEx(configuration) then return fail("initializeCommonControls", "InitCommonControlsEx failed") end if
  return true
end function

/// Registers the process-wide top-level window class exactly once.
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

/// Removes and returns the oldest controller event from the process-wide FIFO.
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

/// Discards queued native events at a test or window-lifecycle boundary.
function clearEvents()
  global guiEvents
  guiEvents = []
  return true
end function

/// Posts a real WM_COMMAND to exercise the same queue path as a user action.
/// @param hwnd hwnd value consumed by this operation.
/// @param controlId Identifier of control.
function postCommandForTest(hwnd, controlId)
  return PostMessageW(hwnd, WM_COMMAND, controlId, 0)
end function

/// Sends a native left-button click to a tab header so tests exercise WM_NOTIFY.
/// @param hwnd hwnd value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
function clickTabHeaderForTest(hwnd, x, y)
  if hwnd == 0 or typeof(x) != "int" or typeof(y) != "int" or x < 0 or y < 0 then return false end if
  packedPoint = (y << 16) | (x & 65535)
  ignoredDown = SendMessageWInt(hwnd, WM_LBUTTONDOWN, 1, packedPoint)
  ignoredUp = SendMessageWInt(hwnd, WM_LBUTTONUP, 0, packedPoint)
  return true
end function

/// Creates a namespaced structured error for a failed GUI operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(GUI_ERROR, "platform.win32_gui." + operation + ": " + message)
end function

/// Decodes a counted UTF-16LE buffer into MiniLang's validated UTF-8 string form.
/// @param wide wide value consumed by this operation.
/// @param units units value consumed by this operation.
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

/// Applies a cached per-DPI Segoe UI font, creating at most one GDI font per DPI.
/// @param hwnd hwnd value consumed by this operation.
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

/// Applies modern Windows visual styles to a common control.
/// @param hwnd hwnd value consumed by this operation.
function applyControlTheme(hwnd)
  if hwnd == 0 then return false end if
  ignored = SetWindowTheme(hwnd, "Explorer", void)
  return true
end function

/// Requests rounded Windows 11 top-level window corners when supported.
/// @param hwnd hwnd value consumed by this operation.
function applyWindowChrome(hwnd)
  if hwnd == 0 then return false end if
  preference = bytes(4, 0)
  endian.writeI32LE(preference, 0, 2)
  ignored = DwmSetWindowAttribute(hwnd, 33, preference, 4)
  return true
end function

/// Builds one popup menu from positionally paired labels and command identifiers.
/// @param items Items consumed or updated by the operation.
/// @param identifiers identifiers value consumed by this operation.
function createTopMenu(items, identifiers)
  if typeof(items) != "array" or typeof(identifiers) != "array" or len(items) == 0 or len(items) != len(identifiers) then return 0 end if
  menu = CreatePopupMenu()
  if menu == 0 then return menu end if
  for index = 0 to len(items) - 1
    ignored = AppendMenuWInt(menu, MF_STRING, identifiers[index], items[index])
  end for
  return menu
end function

/// Displays a command-returning context menu at the current pointer position.
/// @param owner owner value consumed by this operation.
/// @param items Items consumed or updated by the operation.
/// @param identifiers identifiers value consumed by this operation.
function showContextMenu(owner, items, identifiers)
  if owner == 0 or typeof(items) != "array" or typeof(identifiers) != "array" or len(items) == 0 or len(items) != len(identifiers) then return 0 end if
  menu = createTopMenu(items, identifiers)
  if menu == 0 then return 0 end if
  point = bytes(8, 0)
  if not GetCursorPos(point) then ignoredDestroy = DestroyMenu(menu); return 0 end if
  command = TrackPopupMenuEx(menu, TPM_RIGHTBUTTON | TPM_RETURNCMD, endian.readI32LE(point, 0), endian.readI32LE(point, 4), owner, void)
  ignoredDestroy = DestroyMenu(menu)
  if command != 0 then ignoredPost = PostMessageW(owner, WM_COMMAND, command, 0) end if
  return command
end function

/// Registers the workbench keyboard contract for one top-level window.
/// @param hwnd hwnd value consumed by this operation.
function attachWorkbenchAccelerators(hwnd)
  global acceleratorBindings
  if hwnd == 0 then return false end if
  commands = [MENU_SQL_EXECUTE, MENU_SQL_EXECUTE_SCRIPT, MENU_FILE_NEW, MENU_FILE_CLOSE_WORKSHEET, MENU_FILE_EXPORT]
  keys = [VK_F5, VK_RETURN, VK_N, VK_W, VK_E]
  modifiers = [FVIRTKEY, FVIRTKEY | FCONTROL | FSHIFT, FVIRTKEY | FCONTROL, FVIRTKEY | FCONTROL, FVIRTKEY | FCONTROL]
  entries = bytes(len(commands) * 6, 0)
  for index = 0 to len(commands) - 1
    offset = index * 6
    entries[offset] = modifiers[index]
    endian.writeU16LE(entries, offset + 2, keys[index])
    endian.writeU16LE(entries, offset + 4, commands[index])
  end for
  table = CreateAcceleratorTableW(entries, len(commands))
  if table == 0 then return false end if
  acceleratorBindings = acceleratorBindings + [AcceleratorBinding(hwnd, table)]
  return true
end function

/// Finds the keyboard accelerator table owned by an active top-level window.
/// @param hwnd hwnd value consumed by this operation.
function acceleratorForWindow(hwnd)
  global acceleratorBindings
  for each binding in acceleratorBindings
    if binding.hwnd == hwnd then return binding.table end if
  end for
  return 0
end function

/// Attaches the complete MiniSQL workbench menu hierarchy to a top-level window.
/// @param hwnd hwnd value consumed by this operation.
function attachWorkbenchMenuBar(hwnd)
  if hwnd == 0 then return false end if
  mainMenu = CreateMenu()
  if mainMenu == 0 then return false end if
  fileMenu = createTopMenu(["New SQL Worksheet\tCtrl+N", "Close SQL Worksheet\tCtrl+W", "Export Active Result as CSV\tCtrl+E", "Disconnect", "Exit"], [MENU_FILE_NEW, MENU_FILE_CLOSE_WORKSHEET, MENU_FILE_EXPORT, MENU_FILE_CLOSE, MENU_FILE_EXIT])
  sessionMenu = createTopMenu(["Refresh Object Tree", "Commit Transaction", "Rollback Transaction"], [MENU_SESSION_REFRESH, MENU_SESSION_COMMIT, MENU_SESSION_ROLLBACK])
  sqlMenu = createTopMenu(["Execute Current / Selection\tF5", "Execute Script\tCtrl+Shift+Enter", "Explain Current / Selection", "Stop Execution", "Clear Results"], [MENU_SQL_EXECUTE, MENU_SQL_EXECUTE_SCRIPT, MENU_SQL_EXPLAIN, MENU_SQL_CANCEL, MENU_SQL_CLEAR])
  objectMenu = createTopMenu(["Open Table Details", "Open Schema Designer", "Select First 100 Rows"], [MENU_OBJECT_DESCRIBE, MENU_OBJECT_SCHEMA, MENU_OBJECT_QUERY])
  helpMenu = createTopMenu(["About MiniSQL Workbench"], [MENU_HELP_ABOUT])
  if fileMenu != 0 then ignoredFile = AppendMenuWPtr(mainMenu, MF_POPUP, fileMenu, "File") end if
  if sessionMenu != 0 then ignoredSession = AppendMenuWPtr(mainMenu, MF_POPUP, sessionMenu, "Session") end if
  if sqlMenu != 0 then ignoredSql = AppendMenuWPtr(mainMenu, MF_POPUP, sqlMenu, "SQL") end if
  if objectMenu != 0 then ignoredObject = AppendMenuWPtr(mainMenu, MF_POPUP, objectMenu, "Objects") end if
  if helpMenu != 0 then ignoredHelp = AppendMenuWPtr(mainMenu, MF_POPUP, helpMenu, "Help") end if
  if not SetMenu(hwnd, mainMenu) then return false end if
  ignoredDraw = DrawMenuBar(hwnd)
  ignoredAccelerators = attachWorkbenchAccelerators(hwnd)
  return true
end function

/// Attaches the smaller alias-management menu used before a session is open.
/// @param hwnd hwnd value consumed by this operation.
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

/// Creates and destroys a hidden top-level window to validate runtime Win32 integration.
function hiddenWindowSmoke()
  hwnd = try(createTopLevel("MiniSQL Admin Smoke", 320, 240, false))
  if typeof(hwnd) == "error" then return hwnd end if
  destroyed = DestroyWindow(hwnd)
  if destroyed == 0 then return fail("hiddenWindowSmoke", "hidden window could not be destroyed") end if
  return true
end function

/// Creates a per-monitor-DPI-aware top-level window with the requested logical client size.
/// @param title Human-readable title presented to the user.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param visible visible value consumed by this operation.
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

/// Creates a child control with an explicit command identifier and shared visual policy.
/// @param parent parent value consumed by this operation.
/// @param className className value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param style style value consumed by this operation.
/// @param exStyle exStyle value consumed by this operation.
/// @param controlId Identifier of control.
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

/// Creates an anonymous child control used only for direct handle-based access.
/// @param parent parent value consumed by this operation.
/// @param className className value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param style style value consumed by this operation.
/// @param exStyle exStyle value consumed by this operation.
function createChild(parent, className, text, x, y, width, height, style, exStyle)
  return createChildId(parent, className, text, x, y, width, height, style, exStyle, 0)
end function

/// Creates a static text label.
/// @param parent parent value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createLabel(parent, text, x, y, width, height)
  return createChild(parent, "STATIC", text, x, y, width, height, 0, 0)
end function

/// Creates a visual group box around related controls.
/// @param parent parent value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createGroupBox(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_GROUPBOX, 0)
end function

/// Creates an anonymous push button.
/// @param parent parent value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createButton(parent, text, x, y, width, height)
  return createChild(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0)
end function

/// Creates a push button that reports its command identifier to the controller.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_PUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

/// Creates the dialog's default push button, activated by the Enter key.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createDefaultButtonId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_DEFPUSHBUTTON | WS_TABSTOP, 0, controlId)
end function

/// Creates an automatically toggled checkbox with a controller command identifier.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createCheckBoxId(parent, controlId, text, x, y, width, height)
  return createChildId(parent, "BUTTON", text, x, y, width, height, BS_AUTOCHECKBOX | WS_TABSTOP, 0, controlId)
end function

/// Loads the system RichEdit 4.1 class once for the process-wide SQL worksheet.
function ensureRichEdit()
  global richEditLibrary
  if richEditLibrary != 0 then return true end if
  richEditLibrary = LoadLibraryW("Msftedit.dll")
  if richEditLibrary == 0 then return fail("ensureRichEdit", "Msftedit.dll could not be loaded") end if
  return true
end function

/// Creates the notifying Unicode RichEdit worksheet used for SQL highlighting.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createSqlEditor(parent, controlId, text, x, y, width, height)
  loaded = try(ensureRichEdit())
  if typeof(loaded) == "error" then return loaded end if
  style = WS_BORDER | WS_TABSTOP | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_WANTRETURN | WS_VSCROLL | WS_HSCROLL
  hwnd = try(createChildId(parent, "RICHEDIT50W", text, x, y, width, height, style, WS_EX_CLIENTEDGE, controlId))
  if typeof(hwnd) == "error" then return hwnd end if
  // RichEdit's extended limit retains the prior unbounded worksheet contract.
  ignoredLimit = SendMessageWInt(hwnd, EM_EXLIMITTEXT, 0, MAX_EDIT_TEXT_UTF16_UNITS)
  ignoredEvents = SendMessageWInt(hwnd, EM_SETEVENTMASK, 0, ENM_CHANGE)
  return hwnd
end function

/// Creates a multiline worksheet or read-only detail editor.
/// @param parent parent value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param readOnly readOnly value consumed by this operation.
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

/// Counts UTF-16 code units in one NUL-terminated Win32 string buffer.
/// @param wide wide value consumed by this operation.
function utf16BufferUnits(wide)
  if typeof(wide) != "bytes" or len(wide) < 2 or (len(wide) % 2) != 0 then return fail("utf16BufferUnits", "invalid UTF-16 buffer") end if
  return divideInt(len(wide) - 2, 2)
end function

/// Maps a public CRLF-preserving text offset to RichEdit's CR-only coordinate space.
/// @param text Text consumed by the operation.
/// @param textOffset textOffset value consumed by this operation.
function richEditNativeOffset(text, textOffset)
  if typeof(text) != "string" or typeof(textOffset) != "int" or textOffset < 0 then return fail("richEditNativeOffset", "invalid text offset") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  documentUnits = try(utf16BufferUnits(wide))
  if typeof(documentUnits) == "error" then return documentUnits end if
  if textOffset > documentUnits then return fail("richEditNativeOffset", "text offset is outside the document") end if
  nativeOffset = 0
  previous = -1
  if textOffset > 0 then
    for index = 0 to textOffset - 1
      current = endian.readU16LE(wide, index * 2)
      if current != 10 or previous != 13 then nativeOffset = nativeOffset + 1 end if
      previous = current
    end for
  end if
  return nativeOffset
end function

/// Maps RichEdit's CR-only selection coordinate back to public CRLF text units.
/// @param text Text consumed by the operation.
/// @param nativeOffset nativeOffset value consumed by this operation.
function richEditDocumentOffset(text, nativeOffset)
  if typeof(text) != "string" or typeof(nativeOffset) != "int" or nativeOffset < 0 then return fail("richEditDocumentOffset", "invalid native offset") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  documentUnits = try(utf16BufferUnits(wide))
  if typeof(documentUnits) == "error" then return documentUnits end if
  documentOffset = 0
  currentNative = 0
  previous = -1
  while documentOffset < documentUnits and currentNative < nativeOffset
    current = endian.readU16LE(wide, documentOffset * 2)
    if current != 10 or previous != 13 then currentNative = currentNative + 1 end if
    previous = current
    documentOffset = documentOffset + 1
  end while
  if currentNative != nativeOffset then return fail("richEditDocumentOffset", "native offset is outside the document") end if
  // A caret after RichEdit's single paragraph mark corresponds to the public
  // position after both code units of the CRLF pair.
  while documentOffset < documentUnits
    current = endian.readU16LE(wide, documentOffset * 2)
    prior = -1
    if documentOffset > 0 then prior = endian.readU16LE(wide, (documentOffset - 1) * 2) end if
    if current == 10 and prior == 13 then documentOffset = documentOffset + 1 else break end if
  end while
  return documentOffset
end function

/// Converts ordered presentation spans to RichEdit-native offsets in one linear pass.
/// @param text Text consumed by the operation.
/// @param spans spans value consumed by this operation.
function richEditSyntaxRanges(text, spans)
  if typeof(text) != "string" or typeof(spans) != "array" then return fail("richEditSyntaxRanges", "invalid text or spans") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  documentUnits = try(utf16BufferUnits(wide))
  if typeof(documentUnits) == "error" then return documentUnits end if
  ranges = array(len(spans), void)
  documentOffset = 0
  nativeOffset = 0
  previous = -1
  if len(spans) > 0 then
    for spanIndex = 0 to len(spans) - 1
      span = spans[spanIndex]
      if span.startOffset < documentOffset or span.endOffset < span.startOffset or span.endOffset > documentUnits then return fail("richEditSyntaxRanges", "syntax spans must be ordered and inside the document") end if
      while documentOffset < span.startOffset
        current = endian.readU16LE(wide, documentOffset * 2)
        if current != 10 or previous != 13 then nativeOffset = nativeOffset + 1 end if
        previous = current
        documentOffset = documentOffset + 1
      end while
      nativeStart = nativeOffset
      while documentOffset < span.endOffset
        current = endian.readU16LE(wide, documentOffset * 2)
        if current != 10 or previous != 13 then nativeOffset = nativeOffset + 1 end if
        previous = current
        documentOffset = documentOffset + 1
      end while
      ranges[spanIndex] = [nativeStart, nativeOffset, span.kind]
    end for
  end if
  while documentOffset < documentUnits
    current = endian.readU16LE(wide, documentOffset * 2)
    if current != 10 or previous != 13 then nativeOffset = nativeOffset + 1 end if
    previous = current
    documentOffset = documentOffset + 1
  end while
  return [ranges, documentUnits, nativeOffset]
end function

/// Reads the RichEdit selection in the CRLF-preserving offsets used by MiniSQL text.
/// @param hwnd hwnd value consumed by this operation.
function textSelection(hwnd)
  if hwnd == 0 then return fail("textSelection", "hwnd is required") end if
  selection = bytes(8, 0)
  ignored = SendMessageWPtrBuffer(hwnd, EM_EXGETSEL, 0, selection)
  text = try(getText(hwnd))
  if typeof(text) == "error" then return text end if
  startOffset = try(richEditDocumentOffset(text, endian.readI32LE(selection, 0)))
  if typeof(startOffset) == "error" then return startOffset end if
  endOffset = try(richEditDocumentOffset(text, endian.readI32LE(selection, 4)))
  if typeof(endOffset) == "error" then return endOffset end if
  return [startOffset, endOffset]
end function

/// Selects one CRLF-preserving UTF-16 range without modifying editor contents.
/// @param hwnd hwnd value consumed by this operation.
/// @param startOffset startOffset value consumed by this operation.
/// @param endOffset endOffset value consumed by this operation.
function selectText(hwnd, startOffset, endOffset)
  if hwnd == 0 or typeof(startOffset) != "int" or typeof(endOffset) != "int" or startOffset < 0 or endOffset < startOffset then return fail("selectText", "invalid RichEdit range") end if
  text = try(getText(hwnd))
  if typeof(text) == "error" then return text end if
  nativeStart = try(richEditNativeOffset(text, startOffset))
  if typeof(nativeStart) == "error" then return nativeStart end if
  nativeEnd = try(richEditNativeOffset(text, endOffset))
  if typeof(nativeEnd) == "error" then return nativeEnd end if
  selection = bytes(8, 0)
  endian.writeI32LE(selection, 0, nativeStart)
  endian.writeI32LE(selection, 4, nativeEnd)
  ignored = SendMessageWIntBuffer(hwnd, EM_EXSETSEL, 0, selection)
  return true
end function

/// Selects one already translated RichEdit-native range.
/// @param hwnd hwnd value consumed by this operation.
/// @param startOffset startOffset value consumed by this operation.
/// @param endOffset endOffset value consumed by this operation.
function selectNativeText(hwnd, startOffset, endOffset)
  selection = bytes(8, 0)
  endian.writeI32LE(selection, 0, startOffset)
  endian.writeI32LE(selection, 4, endOffset)
  ignored = SendMessageWIntBuffer(hwnd, EM_EXSETSEL, 0, selection)
  return true
end function

/// Applies one CHARFORMAT2 color/effect tuple to a RichEdit-native range.
/// @param hwnd hwnd value consumed by this operation.
/// @param startOffset startOffset value consumed by this operation.
/// @param endOffset endOffset value consumed by this operation.
/// @param color color value consumed by this operation.
/// @param bold bold value consumed by this operation.
/// @param italic italic value consumed by this operation.
function applyNativeCharacterStyle(hwnd, startOffset, endOffset, color, bold, italic)
  selectNativeText(hwnd, startOffset, endOffset)
  format = bytes(CHARFORMAT2W_BYTES, 0)
  endian.writeU32LE(format, 0, CHARFORMAT2W_BYTES)
  endian.writeU32LE(format, 4, CFM_COLOR | CFM_BOLD | CFM_ITALIC)
  effects = 0
  if bold then effects = effects | CFE_BOLD end if
  if italic then effects = effects | CFE_ITALIC end if
  endian.writeU32LE(format, 8, effects)
  endian.writeU32LE(format, 20, color)
  ignored = SendMessageWIntBuffer(hwnd, EM_SETCHARFORMAT, SCF_SELECTION, format)
  return true
end function

/// Maps one translated token range to the stable light-theme SQL palette.
/// @param hwnd hwnd value consumed by this operation.
/// @param range range value consumed by this operation.
function applySqlSpanStyle(hwnd, range)
  if range[2] == 1 then return applyNativeCharacterStyle(hwnd, range[0], range[1], SQL_COLOR_KEYWORD, true, false) end if
  if range[2] == 2 then return applyNativeCharacterStyle(hwnd, range[0], range[1], SQL_COLOR_STRING, false, false) end if
  if range[2] == 3 then return applyNativeCharacterStyle(hwnd, range[0], range[1], SQL_COLOR_NUMBER, false, false) end if
  if range[2] == 4 then return applyNativeCharacterStyle(hwnd, range[0], range[1], SQL_COLOR_COMMENT, false, true) end if
  if range[2] == 5 then return applyNativeCharacterStyle(hwnd, range[0], range[1], SQL_COLOR_QUOTED_IDENTIFIER, false, false) end if
  return true
end function

/// Recolors a complete worksheet while preserving its caret/selection exactly.
/// @param hwnd hwnd value consumed by this operation.
/// @param spans spans value consumed by this operation.
function applySqlSyntaxStyles(hwnd, spans)
  if hwnd == 0 or typeof(spans) != "array" then return fail("applySqlSyntaxStyles", "invalid editor or spans") end if
  editorText = try(getText(hwnd))
  if typeof(editorText) == "error" then return editorText end if
  converted = try(richEditSyntaxRanges(editorText, spans))
  if typeof(converted) == "error" then return converted end if
  ranges = converted[0]
  nativeUnits = converted[2]
  original = try(textSelection(hwnd))
  if typeof(original) == "error" then return original end if
  scrollPosition = bytes(8, 0)
  ignoredScrollRead = SendMessageWPtrBuffer(hwnd, EM_GETSCROLLPOS, 0, scrollPosition)
  ignoredRedrawOff = SendMessageWInt(hwnd, WM_SETREDRAW, 0, 0)
  defaulted = try(applyNativeCharacterStyle(hwnd, 0, nativeUnits, SQL_COLOR_DEFAULT, false, false))
  if typeof(defaulted) == "error" then ignoredRestore = try(selectText(hwnd, original[0], original[1])); ignoredScrollRestore = SendMessageWIntBuffer(hwnd, EM_SETSCROLLPOS, 0, scrollPosition); ignoredRedrawOn = SendMessageWInt(hwnd, WM_SETREDRAW, 1, 0); return defaulted end if
  for each range in ranges
    styled = try(applySqlSpanStyle(hwnd, range))
    if typeof(styled) == "error" then ignoredRestore = try(selectText(hwnd, original[0], original[1])); ignoredScrollRestore = SendMessageWIntBuffer(hwnd, EM_SETSCROLLPOS, 0, scrollPosition); ignoredRedrawOn = SendMessageWInt(hwnd, WM_SETREDRAW, 1, 0); return styled end if
  end for
  restored = try(selectText(hwnd, original[0], original[1]))
  ignoredScrollRestore = SendMessageWIntBuffer(hwnd, EM_SETSCROLLPOS, 0, scrollPosition)
  ignoredRedrawOn = SendMessageWInt(hwnd, WM_SETREDRAW, 1, 0)
  ignoredRepaint = RedrawWindow(hwnd, void, void, RDW_INVALIDATE | RDW_ERASE | RDW_UPDATENOW)
  if typeof(restored) == "error" then return restored end if
  return true
end function

/// Reads the native color and effects of one character for deterministic tests.
/// @param hwnd hwnd value consumed by this operation.
/// @param offset Zero-based offset at which processing starts.
function sqlEditorStyleAt(hwnd, offset)
  if hwnd == 0 or typeof(offset) != "int" or offset < 0 then return fail("sqlEditorStyleAt", "offset is outside the editor") end if
  editorText = try(getText(hwnd))
  if typeof(editorText) == "error" then return editorText end if
  wide = try(utf16Bytes(editorText))
  if typeof(wide) == "error" then return wide end if
  documentUnits = try(utf16BufferUnits(wide))
  if typeof(documentUnits) == "error" or offset >= documentUnits then return fail("sqlEditorStyleAt", "offset is outside the editor") end if
  original = try(textSelection(hwnd))
  if typeof(original) == "error" then return original end if
  selected = try(selectText(hwnd, offset, offset + 1))
  if typeof(selected) == "error" then return selected end if
  format = bytes(CHARFORMAT2W_BYTES, 0)
  endian.writeU32LE(format, 0, CHARFORMAT2W_BYTES)
  ignored = SendMessageWIntBuffer(hwnd, EM_GETCHARFORMAT, SCF_SELECTION, format)
  restored = try(selectText(hwnd, original[0], original[1]))
  if typeof(restored) == "error" then return restored end if
  return [endian.readU32LE(format, 20), endian.readU32LE(format, 8)]
end function

/// Creates a single-line editor, optionally enabling native password masking.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param text Text consumed by the operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param password password value consumed by this operation.
function createTextBoxId(parent, controlId, text, x, y, width, height, password)
  style = WS_BORDER | WS_TABSTOP | ES_AUTOHSCROLL_SINGLE
  if password then style = style | ES_PASSWORD end if
  return createChildId(parent, "EDIT", text, x, y, width, height, style, WS_EX_CLIENTEDGE, controlId)
end function

/// Creates an anonymous notifying list box.
/// @param parent parent value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createListBox(parent, x, y, width, height)
  return createChild(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE)
end function

/// Creates a notifying list box with a stable controller identifier.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createListBoxId(parent, controlId, x, y, width, height)
  return createChildId(parent, "LISTBOX", "", x, y, width, height, WS_BORDER | WS_TABSTOP | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_HSCROLL, WS_EX_CLIENTEDGE, controlId)
end function

/// Creates the Explorer-themed MiniSQL object tree.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createTreeView(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTreeView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | TVS_HASBUTTONS | TVS_HASLINES | TVS_LINESATROOT | TVS_SHOWSELALWAYS, WS_EX_CLIENTEDGE, controlId)
end function

/// Creates an Explorer-themed notebook tab control.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createTabControl(parent, controlId, x, y, width, height)
  return createChildId(parent, "SysTabControl32", "", x, y, width, height, WS_TABSTOP, 0, controlId)
end function

/// Creates a double-buffered report ListView for structured query results.
/// @param parent parent value consumed by this operation.
/// @param controlId Identifier of control.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function createListView(parent, controlId, x, y, width, height)
  hwnd = try(createChildId(parent, "SysListView32", "", x, y, width, height, WS_BORDER | WS_TABSTOP | WS_VSCROLL | WS_HSCROLL | LVS_REPORT | LVS_SHOWSELALWAYS, WS_EX_CLIENTEDGE, controlId))
  if typeof(hwnd) == "error" then return hwnd end if
  ignored = SendMessageWInt(hwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT | LVS_EX_DOUBLEBUFFER)
  return hwnd
end function

/// Replaces control text through a dynamically sized UTF-16 buffer.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
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

/// Sets the native placeholder text shown by an empty single-line editor.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
function setCueBanner(hwnd, text)
  if hwnd == 0 or typeof(text) != "string" then return false end if
  return SendMessageWText(hwnd, EM_SETCUEBANNER, 1, text) != 0
end function

/// Reads complete Unicode control text into a validated MiniLang string.
/// @param hwnd hwnd value consumed by this operation.
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

/// Acquires the process-wide Windows clipboard with a bounded retry because
/// clipboard viewers and other desktop applications may own it momentarily.
/// @param owner owner value consumed by this operation.
function openClipboardWithRetry(owner)
  for attempt = 1 to CLIPBOARD_OPEN_ATTEMPTS
    if OpenClipboard(owner) then return true end if
    if attempt < CLIPBOARD_OPEN_ATTEMPTS then Sleep(CLIPBOARD_RETRY_DELAY_MS) end if
  end for
  return false
end function

/// Replaces the Windows clipboard with one NUL-terminated Unicode string.
/// @param owner owner value consumed by this operation.
/// @param text Text consumed by the operation.
function clipboardSetText(owner, text)
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.clipboardSetText: text must be a string") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  if not openClipboardWithRetry(owner) then return fail("clipboardSetText", "OpenClipboard remained busy after retrying; Win32 error " + GetLastError()) end if
  if not EmptyClipboard() then ignoredClose = CloseClipboard(); return fail("clipboardSetText", "EmptyClipboard failed") end if
  memory = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, len(wide))
  if memory == 0 then ignoredClose = CloseClipboard(); return fail("clipboardSetText", "GlobalAlloc failed") end if
  pointer = GlobalLock(memory)
  if pointer == 0 then ignoredFree = GlobalFree(memory); ignoredClose = CloseClipboard(); return fail("clipboardSetText", "GlobalLock failed") end if
  RtlMoveMemoryToPtr(pointer, wide, len(wide))
  ignoredUnlock = GlobalUnlock(memory)
  published = SetClipboardData(CF_UNICODETEXT, memory)
  ignoredClose = CloseClipboard()
  if published == 0 then ignoredFree = GlobalFree(memory); return fail("clipboardSetText", "SetClipboardData failed") end if
  return true
end function

/// Reads Unicode clipboard text into a dynamically sized MiniLang string.
/// @param owner owner value consumed by this operation.
function clipboardText(owner)
  if not openClipboardWithRetry(owner) then return fail("clipboardText", "OpenClipboard remained busy after retrying; Win32 error " + GetLastError()) end if
  memory = GetClipboardData(CF_UNICODETEXT)
  if memory == 0 then ignoredClose = CloseClipboard(); return fail("clipboardText", "clipboard does not contain Unicode text") end if
  pointer = GlobalLock(memory)
  if pointer == 0 then ignoredClose = CloseClipboard(); return fail("clipboardText", "GlobalLock failed") end if
  size = GlobalSize(memory)
  if size < 2 or size > 67108864 then ignoredUnlock = GlobalUnlock(memory); ignoredClose = CloseClipboard(); return fail("clipboardText", "clipboard text size is invalid") end if
  wide = bytes(size, 0)
  RtlMoveMemory(wide, pointer, size)
  ignoredUnlock = GlobalUnlock(memory)
  ignoredClose = CloseClipboard()
  units = 0
  while units * 2 + 1 < len(wide) and (wide[units * 2] != 0 or wide[units * 2 + 1] != 0)
    units = units + 1
  end while
  return wideBytesToText(wide, units)
end function

/// Opens a native Save As dialog and returns an absolute CSV path or an empty cancellation result.
/// @param owner owner value consumed by this operation.
/// @param defaultName defaultName value consumed by this operation.
function chooseCsvPath(owner, defaultName)
  if typeof(defaultName) != "string" or len(defaultName) == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.chooseCsvPath: default name is required") end if
  path = bytes(65536, 0)
  initial = try(utf16Bytes(defaultName))
  if typeof(initial) == "error" then return initial end if
  if len(initial) > len(path) then return fail("chooseCsvPath", "default file name is too long") end if
  for index = 0 to len(initial) - 1
    path[index] = initial[index]
  end for
  filter = bytes("CSV files (*.csv)") + bytes([0]) + bytes("*.csv") + bytes([0]) + bytes("All files (*.*)") + bytes([0]) + bytes("*.*") + bytes([0, 0])
  // Convert the ASCII filter explicitly to UTF-16 because embedded NULs are significant.
  wideFilter = bytes(len(filter) * 2, 0)
  for index = 0 to len(filter) - 1
    wideFilter[index * 2] = filter[index]
  end for
  title = try(utf16Bytes("Export MiniSQL result as CSV"))
  extension = try(utf16Bytes("csv"))
  if typeof(title) == "error" then return title end if
  if typeof(extension) == "error" then return extension end if
  configuration = bytes(152, 0)
  endian.writeU32LE(configuration, 0, 152)
  writePointer(configuration, 8, owner)
  writePointer(configuration, 24, nativeBytesPtr(wideFilter))
  endian.writeU32LE(configuration, 44, 1)
  writePointer(configuration, 48, nativeBytesPtr(path))
  endian.writeU32LE(configuration, 56, len(path) / 2)
  writePointer(configuration, 88, nativeBytesPtr(title))
  endian.writeU32LE(configuration, 96, OFN_OVERWRITEPROMPT | OFN_PATHMUSTEXIST)
  writePointer(configuration, 104, nativeBytesPtr(extension))
  if not GetSaveFileNameW(configuration) then return "" end if
  units = 0
  while units * 2 + 1 < len(path) and (path[units * 2] != 0 or path[units * 2 + 1] != 0)
    units = units + 1
  end while
  return wideBytesToText(path, units)
end function

/// Reads a password directly into bytes and clears both temporary UTF-16 storage and the editor.
/// @param hwnd hwnd value consumed by this operation.
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

/// Sets the native checked state without generating a click notification.
/// @param hwnd hwnd value consumed by this operation.
/// @param checked checked value consumed by this operation.
function checkBoxSet(hwnd, checked)
  value = 0
  if checked then value = BST_CHECKED end if
  ignored = SendMessageWInt(hwnd, BM_SETCHECK, value, 0)
  return true
end function

/// Returns whether a checkbox currently holds the checked state.
/// @param hwnd hwnd value consumed by this operation.
function checkBoxChecked(hwnd)
  return SendMessageWInt(hwnd, BM_GETCHECK, 0, 0) == BST_CHECKED
end function

/// Removes every item from a list box.
/// @param hwnd hwnd value consumed by this operation.
function listReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LB_RESETCONTENT, 0, 0)
  return true
end function

/// Appends one Unicode item to a list box and returns its index.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
function listAdd(hwnd, text)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: hwnd is required") end if
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.win32_gui.listAdd: text must be string") end if
  wide = try(utf16Bytes(text))
  if typeof(wide) == "error" then return wide end if
  index = SendMessageWPtr(hwnd, LB_ADDSTRING, 0, nativeBytesPtr(wide))
  if index == LB_ERR then return fail("listAdd", "LB_ADDSTRING failed") end if
  return index
end function

/// Reads the complete Unicode text of the currently selected list-box item.
/// @param hwnd hwnd value consumed by this operation.
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

/// Returns the selected list-box index or minus one when no row is selected.
/// @param hwnd hwnd value consumed by this operation.
function listSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, LB_GETCURSEL, 0, 0)
end function

/// Selects one list-box item by zero-based index.
/// @param hwnd hwnd value consumed by this operation.
/// @param index Zero-based index of the affected item.
function listSelect(hwnd, index)
  if hwnd == 0 or typeof(index) != "int" then return false end if
  return SendMessageWInt(hwnd, LB_SETCURSEL, index, 0) != LB_ERR
end function

/// Deletes all nodes and invalidates all prior native tree-item handles.
/// @param hwnd hwnd value consumed by this operation.
function treeReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.treeReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1101, 0, 0)
  return true
end function

/// Inserts one Unicode TreeView node using the Windows x64 TVINSERTSTRUCTW layout.
/// @param hwnd hwnd value consumed by this operation.
/// @param parentItem parentItem value consumed by this operation.
/// @param text Text consumed by the operation.
/// @param hasChildren hasChildren value consumed by this operation.
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

/// Expands one tree item so a freshly rebuilt object hierarchy is immediately useful.
/// @param hwnd hwnd value consumed by this operation.
/// @param item item value consumed by this operation.
function treeExpand(hwnd, item)
  if hwnd == 0 or typeof(item) != "int" or item == 0 then return false end if
  return SendMessageWPtr(hwnd, TVM_EXPAND, TVE_EXPAND, item) != 0
end function

/// Selects one tree item without synthesizing mouse input.
/// @param hwnd hwnd value consumed by this operation.
/// @param item item value consumed by this operation.
function treeSelect(hwnd, item)
  if hwnd == 0 or typeof(item) != "int" or item == 0 then return false end if
  return SendMessageWPtr(hwnd, TVM_SELECTITEM, TVGN_CARET, item) != 0
end function

/// Reads the selected TreeView item's text through a bounded TVITEMW buffer.
/// @param hwnd hwnd value consumed by this operation.
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

/// Removes every page label from a tab control.
/// @param hwnd hwnd value consumed by this operation.
function tabReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.tabReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, 0x1309, 0, 0)
  return true
end function

/// Appends one Unicode page label using the x64 TCITEMW layout.
/// @param hwnd hwnd value consumed by this operation.
/// @param text Text consumed by the operation.
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

/// Returns the currently selected zero-based tab index.
/// @param hwnd hwnd value consumed by this operation.
function tabSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, TCM_GETCURSEL, 0, 0)
end function

/// Returns one tab header rectangle in control-relative physical pixels.
/// @param hwnd hwnd value consumed by this operation.
/// @param index Zero-based index of the affected item.
function tabItemRectangle(hwnd, index)
  if hwnd == 0 or typeof(index) != "int" or index < 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.tabItemRectangle: invalid tab") end if
  rectangle = bytes(16, 0)
  found = SendMessageWIntBuffer(hwnd, TCM_GETITEMRECT, index, rectangle)
  if found == 0 then return fail("tabItemRectangle", "TCM_GETITEMRECT failed") end if
  return [endian.readI32LE(rectangle, 0), endian.readI32LE(rectangle, 4), endian.readI32LE(rectangle, 8), endian.readI32LE(rectangle, 12)]
end function

/// Hit-tests a captured pointer against the trailing close-glyph region of a tab.
/// @param hwnd hwnd value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
function tabCloseHitIndexAt(hwnd, x, y)
  if hwnd == 0 or typeof(x) != "int" or typeof(y) != "int" or x < 0 or y < 0 then return -1 end if
  hit = bytes(12, 0)
  endian.writeI32LE(hit, 0, x)
  endian.writeI32LE(hit, 4, y)
  index = SendMessageWIntBuffer(hwnd, TCM_HITTEST, 0, hit)
  if index < 0 then return -1 end if
  rectangle = try(tabItemRectangle(hwnd, index))
  if typeof(rectangle) == "error" then return -1 end if
  closeWidth = scaleDip(hwnd, 24)
  if x >= rectangle[2] - closeWidth and x < rectangle[2] and y >= rectangle[1] and y < rectangle[3] then return index end if
  return -1
end function

/// Removes every result row while preserving the column schema.
/// @param hwnd hwnd value consumed by this operation.
function listViewReset(hwnd)
  if hwnd == 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewReset: hwnd is required") end if
  ignored = SendMessageWInt(hwnd, LVM_DELETEALLITEMS, 0, 0)
  return true
end function

/// Deletes ListView columns from index zero until Windows reports none remain.
/// @param hwnd hwnd value consumed by this operation.
function listViewResetColumns(hwnd)
  if hwnd == 0 then return false end if
  while SendMessageWInt(hwnd, LVM_DELETECOLUMN, 0, 0) != 0
  end while
  return true
end function

/// Inserts one report column using a pointer-safe x64 LVCOLUMNW buffer.
/// @param hwnd hwnd value consumed by this operation.
/// @param index Zero-based index of the affected item.
/// @param text Text consumed by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
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

/// Inserts a result row and then fills its remaining subitems in column order.
/// @param hwnd hwnd value consumed by this operation.
/// @param rowIndex Zero-based index of row.
/// @param values values value consumed by this operation.
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

/// Returns the selected report-row index, or -1 when the grid has no selection.
/// @param hwnd hwnd value consumed by this operation.
function listViewSelectedIndex(hwnd)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, LVM_GETNEXTITEM, -1, LVNI_SELECTED)
end function

/// Returns every selected report-row index in ascending native order.
/// @param hwnd hwnd value consumed by this operation.
function listViewSelectedIndices(hwnd)
  if hwnd == 0 then return [] end if
  selected = []
  current = SendMessageWInt(hwnd, LVM_GETNEXTITEM, -1, LVNI_SELECTED)
  while current >= 0
    selected = selected + [current]
    current = SendMessageWInt(hwnd, LVM_GETNEXTITEM, current, LVNI_SELECTED)
  end while
  return selected
end function

/// Reads one report cell through a dynamically sized LVITEMW text buffer.
/// @param hwnd hwnd value consumed by this operation.
/// @param rowIndex Zero-based index of row.
/// @param columnIndex Zero-based index of column.
function listViewCellText(hwnd, rowIndex, columnIndex)
  if hwnd == 0 or typeof(rowIndex) != "int" or typeof(columnIndex) != "int" or rowIndex < 0 or columnIndex < 0 then return error(INVALID_ARGUMENT, "platform.win32_gui.listViewCellText: invalid cell") end if
  wide = bytes(65536, 0)
  item = bytes(88, 0)
  endian.writeI32LE(item, 4, rowIndex)
  endian.writeI32LE(item, 8, columnIndex)
  writePointer(item, 24, nativeBytesPtr(wide))
  endian.writeI32LE(item, 32, len(wide) / 2)
  ignored = SendMessageWIntBuffer(hwnd, LVM_GETITEMTEXTW, rowIndex, item)
  units = 0
  while units * 2 + 1 < len(wide) and (wide[units * 2] != 0 or wide[units * 2 + 1] != 0)
    units = units + 1
  end while
  return wideBytesToText(wide, units)
end function

/// Returns the report row and subitem under the pointer, or [-1, -1].
/// @param hwnd hwnd value consumed by this operation.
function listViewPointerCell(hwnd)
  if hwnd == 0 then return [-1, -1] end if
  point = bytes(8, 0)
  if not GetCursorPos(point) or not ScreenToClient(hwnd, point) then return [-1, -1] end if
  hit = bytes(40, 0)
  endian.writeI32LE(hit, 0, endian.readI32LE(point, 0))
  endian.writeI32LE(hit, 4, endian.readI32LE(point, 4))
  ignored = SendMessageWIntBuffer(hwnd, LVM_SUBITEMHITTEST, -1, hit)
  return [endian.readI32LE(hit, 12), endian.readI32LE(hit, 16)]
end function

/// Returns the number of report rows currently rendered in a native grid.
/// @param hwnd hwnd value consumed by this operation.
function listViewRowCount(hwnd)
  if hwnd == 0 then return 0 end if
  return SendMessageWInt(hwnd, LVM_GETITEMCOUNT, 0, 0)
end function

/// Selects and focuses one report row for deterministic keyboard and test workflows.
/// @param hwnd hwnd value consumed by this operation.
/// @param rowIndex Zero-based index of row.
function listViewSelect(hwnd, rowIndex)
  if hwnd == 0 or typeof(rowIndex) != "int" or rowIndex < 0 then return false end if
  cleared = bytes(88, 0)
  endian.writeU32LE(cleared, 0, LVIF_STATE)
  endian.writeU32LE(cleared, 12, 0)
  endian.writeU32LE(cleared, 16, LVIS_SELECTED | LVIS_FOCUSED)
  ignoredClear = SendMessageWIntBuffer(hwnd, LVM_SETITEMSTATE, -1, cleared)
  item = bytes(88, 0)
  endian.writeU32LE(item, 0, LVIF_STATE)
  endian.writeU32LE(item, 12, LVIS_SELECTED | LVIS_FOCUSED)
  endian.writeU32LE(item, 16, LVIS_SELECTED | LVIS_FOCUSED)
  ignored = SendMessageWIntBuffer(hwnd, LVM_SETITEMSTATE, rowIndex, item)
  return listViewSelectedIndex(hwnd) == rowIndex
end function

/// Adds one row to the current report selection without clearing other rows.
/// @param hwnd hwnd value consumed by this operation.
/// @param rowIndex Zero-based index of row.
function listViewAddSelection(hwnd, rowIndex)
  if hwnd == 0 or typeof(rowIndex) != "int" or rowIndex < 0 then return false end if
  item = bytes(88, 0)
  endian.writeU32LE(item, 0, LVIF_STATE)
  endian.writeU32LE(item, 12, LVIS_SELECTED)
  endian.writeU32LE(item, 16, LVIS_SELECTED)
  ignored = SendMessageWIntBuffer(hwnd, LVM_SETITEMSTATE, rowIndex, item)
  selected = listViewSelectedIndices(hwnd)
  for each value in selected
    if value == rowIndex then return true end if
  end for
  return false
end function

/// Moves a control using physical Win32 coordinates and repaints immediately.
/// @param hwnd hwnd value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function move(hwnd, x, y, width, height)
  if hwnd == 0 then return false end if
  return MoveWindow(hwnd, x, y, width, height, true)
end function

/// Scales one logical coordinate for the monitor currently hosting a window.
/// @param hwnd hwnd value consumed by this operation.
/// @param value Value consumed or transformed by the operation.
function scaleDip(hwnd, value)
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = 96 end if
  return scaleAtDpi(value, dpiValue)
end function

/// Converts a physical coordinate into a logical DPI-independent value.
/// @param hwnd hwnd value consumed by this operation.
/// @param value Value consumed or transformed by the operation.
function unscaleDip(hwnd, value)
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = 96 end if
  halfDpi = dpiValue >> 1
  if value < 0 then return -divideInt((-value) * 96 + halfDpi, dpiValue) end if
  return divideInt(value * 96 + halfDpi, dpiValue)
end function

/// Moves a control using logical coordinates and defers repainting to the layout boundary.
/// @param hwnd hwnd value consumed by this operation.
/// @param x Horizontal coordinate used by the operation.
/// @param y Vertical coordinate used by the operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function moveDip(hwnd, x, y, width, height)
  if hwnd == 0 then return false end if
  ignoredFont = applyDefaultFont(hwnd)
  return MoveWindow(hwnd, scaleDip(hwnd, x), scaleDip(hwnd, y), scaleDip(hwnd, width), scaleDip(hwnd, height), false)
end function

/// Invalidates a complete top-level window and all descendants after a layout transaction.
/// @param hwnd hwnd value consumed by this operation.
function redraw(hwnd)
  if hwnd == 0 then return false end if
  return RedrawWindow(hwnd, void, void, RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW)
end function

/// Shows a fully constructed top-level window without exposing its placeholder layout.
/// @param hwnd hwnd value consumed by this operation.
function showTopLevel(hwnd)
  if hwnd == 0 then return false end if
  ignoredShow = ShowWindow(hwnd, SW_SHOW)
  ignoredRedraw = redraw(hwnd)
  return UpdateWindow(hwnd)
end function

/// Registers a DPI-aware minimum client size consumed by WM_GETMINMAXINFO.
/// @param hwnd hwnd value consumed by this operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
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

/// Selects whether WM_CLOSE is queued for controller validation or destroys immediately.
/// @param hwnd hwnd value consumed by this operation.
/// @param enabled enabled value consumed by this operation.
function setCloseEventRouting(hwnd, enabled)
  global closeEventWindows
  retained = []
  for each retainedHwnd in closeEventWindows
    if retainedHwnd != hwnd then retained = retained + [retainedHwnd] end if
  end for
  closeEventWindows = retained
  if enabled then closeEventWindows = closeEventWindows + [hwnd] end if
  return true
end function

/// Resizes a top-level window so its client area matches logical dimensions exactly.
/// @param hwnd hwnd value consumed by this operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param hasMenu hasMenu value consumed by this operation.
function setClientSizeDip(hwnd, width, height, hasMenu)
  if hwnd == 0 or typeof(width) != "int" or typeof(height) != "int" then return false end if
  dpiValue = GetDpiForWindow(hwnd)
  if dpiValue < 96 then dpiValue = GetDpiForSystem() end if
  if dpiValue < 96 then dpiValue = 96 end if
  outer = try(outerSizeForClient(width, height, dpiValue, hasMenu))
  if typeof(outer) == "error" then return outer end if
  return SetWindowPos(hwnd, 0, 0, 0, outer[0], outer[1], SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE)
end function

/// Returns a child control rectangle in parent-relative DPI-independent pixels.
/// @param parent parent value consumed by this operation.
/// @param child child value consumed by this operation.
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

/// Returns one top-level window rectangle in physical desktop pixels for persistence.
/// @param hwnd hwnd value consumed by this operation.
function topLevelRect(hwnd)
  if hwnd == 0 then return fail("topLevelRect", "hwnd is required") end if
  rectangle = bytes(16, 0)
  if not GetWindowRect(hwnd, rectangle) then return fail("topLevelRect", "GetWindowRect failed") end if
  left = endian.readI32LE(rectangle, 0)
  top = endian.readI32LE(rectangle, 4)
  right = endian.readI32LE(rectangle, 8)
  bottom = endian.readI32LE(rectangle, 12)
  return [left, top, right - left, bottom - top]
end function

/// Restores a validated top-level physical desktop rectangle.
/// @param hwnd hwnd value consumed by this operation.
/// @param rectangle rectangle value consumed by this operation.
function setTopLevelRect(hwnd, rectangle)
  if hwnd == 0 or typeof(rectangle) != "array" or len(rectangle) != 4 then return false end if
  if typeof(rectangle[0]) != "int" or typeof(rectangle[1]) != "int" or typeof(rectangle[2]) != "int" or typeof(rectangle[3]) != "int" then return false end if
  if rectangle[0] < -32768 or rectangle[0] > 32768 or rectangle[1] < -32768 or rectangle[1] > 32768 then return false end if
  if rectangle[2] < 640 or rectangle[3] < 480 or rectangle[2] > 16384 or rectangle[3] > 16384 then return false end if
  return SetWindowPos(hwnd, 0, rectangle[0], rectangle[1], rectangle[2], rectangle[3], SWP_NOZORDER | SWP_NOACTIVATE)
end function

/// Shows or hides one control without changing its layout rectangle.
/// @param hwnd hwnd value consumed by this operation.
/// @param visible visible value consumed by this operation.
function show(hwnd, visible)
  if hwnd == 0 then return false end if
  command = 0
  if visible then command = SW_SHOW end if
  return ShowWindow(hwnd, command)
end function

/// Enables or disables one workbench control.
/// @param hwnd hwnd value consumed by this operation.
/// @param enabled enabled value consumed by this operation.
function setEnabled(hwnd, enabled)
  if hwnd == 0 then return false end if
  return EnableWindow(hwnd, enabled)
end function

/// Returns the effective Win32 enabled state of one control.
/// @param hwnd hwnd value consumed by this operation.
function isEnabled(hwnd)
  if hwnd == 0 then return false end if
  return IsWindowEnabled(hwnd)
end function

/// Gives keyboard focus to a workbench control.
/// @param hwnd hwnd value consumed by this operation.
function focus(hwnd)
  if hwnd == 0 then return false end if
  ignored = SetFocus(hwnd)
  return true
end function

/// Displays a native informational message box.
/// @param owner owner value consumed by this operation.
/// @param title Human-readable title presented to the user.
/// @param message Human-readable message associated with the operation.
function showInfo(owner, title, message)
  if owner == 0 or typeof(title) != "string" or typeof(message) != "string" then return false end if
  ignored = MessageBoxW(owner, message, title, MB_OK | MB_ICONINFORMATION)
  return true
end function

/// Displays a native error dialog; a zero owner supports pre-window startup failures.
/// @param owner owner value consumed by this operation.
/// @param title Human-readable title presented to the user.
/// @param message Human-readable message associated with the operation.
function showError(owner, title, message)
  if typeof(owner) != "int" or typeof(title) != "string" or typeof(message) != "string" then return false end if
  ignored = MessageBoxW(owner, message, title, MB_OK | MB_ICONERROR)
  return true
end function

/// Shows an owned destructive-action warning and returns true only for an explicit Yes.
/// @param owner owner value consumed by this operation.
/// @param title Human-readable title presented to the user.
/// @param message Human-readable message associated with the operation.
function confirmWarning(owner, title, message)
  if owner == 0 or typeof(title) != "string" or typeof(message) != "string" then return false end if
  return MessageBoxW(owner, message, title, MB_YESNO | MB_ICONWARNING) == IDYES
end function

/// Selects a tab page by zero-based index.
/// @param hwnd hwnd value consumed by this operation.
/// @param index Zero-based index of the affected item.
function tabSelect(hwnd, index)
  if hwnd == 0 then return -1 end if
  return SendMessageWInt(hwnd, 0x130C, index, 0)
end function

/// Returns the physical-pixel dimensions of a window's client area.
/// @param hwnd hwnd value consumed by this operation.
function clientSize(hwnd)
  rectangle = bytes(16, 0)
  if not GetClientRect(hwnd, rectangle) then return fail("clientSize", "GetClientRect failed") end if
  return [endian.readI32LE(rectangle, 8), endian.readI32LE(rectangle, 12)]
end function

/// Returns the client dimensions in DPI-independent pixels.
/// @param hwnd hwnd value consumed by this operation.
function clientSizeDip(hwnd)
  size = try(clientSize(hwnd))
  if typeof(size) == "error" then return size end if
  return [unscaleDip(hwnd, size[0]), unscaleDip(hwnd, size[1])]
end function

/// Returns a valid DPI for a window, falling back to the 96-DPI baseline.
/// @param hwnd hwnd value consumed by this operation.
function dpi(hwnd)
  value = GetDpiForWindow(hwnd)
  if value < 96 then return 96 end if
  return value
end function

/// Returns whether a push button currently reports its pressed state.
/// @param hwnd hwnd value consumed by this operation.
function buttonDown(hwnd)
  if hwnd == 0 then return false end if
  state = SendMessageWInt(hwnd, BM_GETSTATE, 0, 0)
  return (state & BST_PUSHED) != 0
end function

/// Dispatches a bounded batch of messages and applies dialog-style keyboard navigation.
function pumpMessages()
  message = bytes(64, 0)
  pumped = 0
  while pumped < 128 and PeekMessageW(message, void, 0, 0, PM_REMOVE)
    active = GetActiveWindow()
    handled = false
    if active != 0 then
      accelerator = acceleratorForWindow(active)
      if accelerator != 0 then handled = TranslateAcceleratorW(active, accelerator, message) != 0 end if
      if not handled then handled = IsDialogMessageW(active, message) end if
    end if
    if not handled then
      ignoredTranslate = TranslateMessage(message)
      ignoredDispatch = DispatchMessageW(message)
    end if
    pumped = pumped + 1
  end while
  return pumped
end function

/// Returns whether a native handle still names a live window.
/// @param hwnd hwnd value consumed by this operation.
function isOpen(hwnd)
  if hwnd == 0 then return false end if
  return IsWindow(hwnd)
end function

/// Destroys a top-level window and releases its retained minimum-size policy.
/// @param hwnd hwnd value consumed by this operation.
function destroy(hwnd)
  global windowMinimums, acceleratorBindings, closeEventWindows
  if hwnd == 0 then return true end if
  retained = []
  for each minimum in windowMinimums
    if minimum.hwnd != hwnd then retained = retained + [minimum] end if
  end for
  windowMinimums = retained
  retainedAccelerators = []
  for each binding in acceleratorBindings
    if binding.hwnd == hwnd then ignoredAccelerator = DestroyAcceleratorTable(binding.table) else retainedAccelerators = retainedAccelerators + [binding] end if
  end for
  acceleratorBindings = retainedAccelerators
  retainedCloseEvents = []
  for each retainedHwnd in closeEventWindows
    if retainedHwnd != hwnd then retainedCloseEvents = retainedCloseEvents + [retainedHwnd] end if
  end for
  closeEventWindows = retainedCloseEvents
  destroyed = DestroyWindow(hwnd)
  return destroyed != 0
end function

/// Yields the current native thread for the requested polling interval.
/// @param milliseconds milliseconds value consumed by this operation.
function sleep(milliseconds)
  Sleep(milliseconds)
  return true
end function

/// Performs the componentName operation for the minisql platform win32 gui module.
function componentName()
  return "platform.win32_gui"
end function

/// Identifies the workbench milestone that introduced this Win32 adapter.
function targetMilestone()
  return "M74"
end function

/// Reports that the native Win32 adapter is available in this build.
function isImplemented()
  return true
end function
