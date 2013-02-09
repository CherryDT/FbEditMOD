

#Define IDD_HEXFINDDLG          6300
#Define IDC_HEXFINDTEXT         1002
#define IDC_HEXREPLACESTATIC    1003
#define IDC_HEXREPLACETEXT      1004
#define IDC_HEXRBN_HEX          1006
#define IDC_HEXRBN_ASCII        1007
#define IDC_HEXRBN_DOWN         1009
#define IDC_HEXRBN_UP           1010
#define IDC_HEXBTN_REPLACE      1011
#define IDC_HEXBTN_REPLACEALL   1012


Declare Function HexFindDlgProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer


Extern hexfindbuff As ZString * 260
