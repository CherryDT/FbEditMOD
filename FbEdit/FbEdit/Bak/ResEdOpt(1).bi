

#Include Once "windowsUR.bi"


Declare Sub SetDialogOptions (ByVal hWin As HWND)
Declare Function TabOptionsProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer


Type NAMEEXPORT
	nType				As Integer
	nOutput	    		As Integer
	fAuto				As Integer
	szFileName	    	As ZString Ptr
End Type

Type GRIDSIZE
	x					As Integer
	y					As Integer
	show				As Integer
	snap				As Integer
	tips				As Integer
	Color				As Integer
	Line				As Integer
	stylehex			As Integer
	sizetofont		    As Integer
	nodefines   		As Integer
	simple		    	As Integer
	defstatic		    As Integer
End Type


'TabOptions.dlg
#Define IDD_TABOPTIONS						2000
#Define IDC_TABOPT							2001

'TabOpt1.dlg
#Define IDD_TABOPT1							2100
#Define IDC_RBNEXPOPT1						2101
#Define IDC_RBNEXPOPT2						2102
#Define IDC_EDTEXPOPT						2113
#Define IDC_RBNEXPOPT3						2103
#Define IDC_RBNEXPORTOUT					2112
#Define IDC_RBNEXPORTCLIP					2111
#Define IDC_RBNEXPORTFILE					2110
#Define IDC_CHKAUTOEXPORT					2114
#Define IDC_RBNEXPOPT4						2104

'TabOpt2.dlg
#Define IDD_TABOPT2							2200
#Define IDC_BTNCUSTDEL						2205
#Define IDC_BTNCUSTADD						2204
#Define IDC_GRDCUST							2201

'TabOpt3.dlg
#Define IDD_TABOPT3							2300
#Define IDC_EDTY							4005
#Define IDC_EDTX							4008
#Define IDC_CHKSNAPGRID						4002
#Define IDC_CHKSHOWGRID						4003
#Define IDC_UDNY							4004
#Define IDC_UDNX							4007
#Define IDC_CHKSHOWTIP						4001
#Define IDC_STCGRIDCOLOR					4006
#Define IDC_CHKGRIDLINE						4009
#Define IDC_CHKSTYLEHEX						4010
#Define IDC_CHKSIZETOFONT					4011
#Define IDC_CHKSIMPLEPROPERTY				4012
#Define IDC_CHKDEFSTATIC					4013

'TabOpt4.dlg
#Define IDD_TABOPT4							2400
#Define IDC_BTNSTYLEADD						2402
#Define IDC_BTNSTYLEDEL						2401
#Define IDC_GRDSTYLE						2403

'TabOpt5.dlg
#Define IDD_TABOPT5							2410
#Define IDC_BTNTYPEADD						2502
#Define IDC_BTNTYPEDEL						2501
#Define IDC_GRDTYPE							2503


Extern nmeexp  As NAMEEXPORT
Extern grdsize As GRIDSIZE

