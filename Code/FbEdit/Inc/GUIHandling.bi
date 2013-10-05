

#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RAEdit.bi"


Enum OutputTextTemplate
    OTT_WINLASTERROR = 1
    OTT_HLINE
End Enum


Declare Sub BrowseForFolder (ByVal hWin As HWND,ByVal nID As Integer)
Declare Function BrowseForFolderCallBack (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal lParam As LPARAM,ByVal lpData As Integer) As Integer

Declare Function ImmediateProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Function OutputProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Function FileBrowserProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

Declare Sub ShowOutput (ByVal bShow As Boolean)
Declare Sub ShowImmediate (ByVal bShow As Boolean)

Declare Sub TextToOutput OverLoad (Byval pText As ZString Ptr)
Declare Sub TextToOutput OverLoad (Byval pText As ZString Ptr, ByVal SoundNo As UINT)
Declare Sub TextToOutput OverLoad (Byval pText As ZString Ptr, ByVal BookMarkType As BookMarkTypes, ByVal BookMarkID As Integer)
Declare Sub TextToOutput Overload (ByVal StdMsg As OutputTextTemplate)

Declare Sub ListAllBookmarks ()
Declare Sub SetFullScreen (ByVal hWin As HWND)
Declare Function ShowTooltip (ByVal hWin As HWND, ByVal lptt As TOOLTIP Ptr) As Integer
Declare Sub ShowProjectTab ()

Declare Sub SetWinCaption ()
Declare Sub CenterOwner (ByVal hWin As HWND)
Declare Function GetOwner () As HWND
Declare Sub DoEvents (ByVal hWin As HWND)         ' ;-)

Declare Sub AddMruProject ()
Declare Sub AddMruFile (Byref sFile As ZString)

Declare Sub MakeSubMenu (ByVal SubMenuID As UINT, ByVal FirstID As UINT, ByVal LastID As UINT, ByRef IniSection As ZString Ptr)
Declare Sub MakeMenuMruProjects ()
Declare Sub MakeMenuMruFiles ()		
Declare Sub MakeMenuCustomFilter ()


Extern lpOldOutputProc      As WNDPROC
Extern lpOldImmediateProc   As WNDPROC
Extern lpOldFileBrowserProc As WNDPROC  

Extern MruProject(3)        As ZString * 260
Extern MruFile(8)           As ZString * 260

Extern ttmsg                As MESSAGE                 ' Tooltip
Extern ttpos                As Integer
Extern novr                 As Integer
Extern nsel                 As Integer


#Macro IsDlgItemEnabled (hWin, DlgItem)
    IsWindowEnabled (GetDlgItem (hWin, DlgItem))
#EndMacro

#Macro EnableDlgItem (hWin, DlgItem, NewState)
    EnableWindow (GetDlgItem (hWin, DlgItem), NewState)
#EndMacro

#Macro ShowDlgItem (hWin, DlgItem, NewState)
    ShowWindow (GetDlgItem (hWin, DlgItem), NewState)
#EndMacro
