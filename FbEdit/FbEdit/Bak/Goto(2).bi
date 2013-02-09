
#Include Once "windowsUR.bi"

Declare Function GotoDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Sub Elevator (ByVal hWin As HWND, ByVal Direction As BOOL)
Declare Sub GotoTextLine (ByVal hWin As HWND, ByVal LineNo As Long, ByVal VCenter As BOOLEAN)




