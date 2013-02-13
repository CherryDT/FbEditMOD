

Declare Function CreateHexEd (Byref sFile As zString) As HWND
Declare Function HexEdProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

Declare Sub UpdateHexEdOptions (ByVal hEdt As HWND)

