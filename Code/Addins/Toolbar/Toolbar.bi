
type TBMEM
	szTbrFile	As zstring*260
	hIml		As HIMAGELIST
	fChanged	As bool
end type

type TBR
	szTbrName	as zstring*32
	nTbrID		as integer
	szBmpFile	as zstring*260
	szBmpName	as zstring*32
	nBmp		As integer
	nStyle		as integer
	nBtnSize	As integer
	nBtn		As integer
end type

type TBRBTN
	szBtnName	as zstring*32
	nBtnID		as integer
	nBmp		As integer
	nStyle		as integer
end type

dim SHARED hInstance   As HINSTANCE
dim SHARED hooks       As ADDINHOOKS
dim SHARED lpHandles   As ADDINHANDLES ptr
dim SHARED lpFunctions As ADDINFUNCTIONS ptr
dim SHARED lpData      As ADDINDATA ptr
dim SHARED winsize     As RECT = (10,10,800,600)
dim SHARED hWnd        As HWND

#define IDD_DLGTOOLBAR           1000
#define IDC_EDTTBRNAME           1001
#define IDC_EDTTBRID             1002
#define IDC_EDTBTNNAME           1005
#define IDC_EDTBTNID             1003
#define IDC_LSTBTN               1004
#define IDC_BTNUP                1006
#define IDC_BTNADDBTN            1008
#define IDC_BTNINSBTN            1009
#define IDC_BTNADDSEP            1011
#define IDC_BTNINSSEP            1010
#define IDC_BTNDEL               1012
#define IDC_BTNDN                1007
#define IDC_EDTBMPFILE           1013
#define IDC_BTNBMP               1017
#define IDC_EDTBMPNAME           1015
#define IDC_EDTBMPNBR            1014
#define IDC_STCBTN               1016
#define IDC_BTNEXPORT            1019
#define IDC_CHKTBRFLAT           1018
#define IDC_CHKTBRWRAP           1020
#define IDC_CHKTBRDIVIDER        1021
#define IDC_CHKTBRTIP            1023
#define IDC_CHKTBRLIST           1022
#define IDC_CHKBTNCHECK          1025
#define IDC_CHKBTNGROUP          1024
#define IDC_EDTSIZE              1026
#define IDC_UDNSIZE              1027
#define IDC_TBR1                 1028
#define IDC_TBR2                 1029

#define IDB_ARROW		         100

Const szNULL=!"\0"
Const BMPFilterString="Bitmap (*.bmp)" & szNULL & "*.bmp" & szNULL & szNULL
Const szSTD="IDB_STD_SMALL_COLOR"
Const CRLF = !"\13\10"
