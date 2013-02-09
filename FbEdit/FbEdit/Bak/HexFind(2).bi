

#include Once "windowsUR.bi"


#Define IDD_HEXFINDDLG          6300


Declare Function HexFindDlgProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer


Extern hexfindbuff As ZString * 260
