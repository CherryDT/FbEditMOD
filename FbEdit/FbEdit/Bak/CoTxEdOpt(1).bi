

Declare Sub SetHiliteWords (ByVal hWin As HWND)
Declare Sub SetHiliteWordsFromApi (ByVal hWin As HWND)
Declare Sub AddApiFile (Byref sFile As zString, ByVal nType As Integer)
Declare Sub LoadApiFiles ()
Declare Sub SetToolsColors ()
Declare Sub PropertyHL (ByVal bUpdate As Integer)

Declare Function KeyWordsDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer


Type EDITOPTION
	tabsize			As Integer
	expand			As Integer
	hiliteline		As Integer
	autoindent		As Integer
	hilitecmnt		As Integer
	linenumbers		As Integer
	backup			As Integer
	bracematch		As Integer
	AutoBrace		As Integer
	autocase		As Integer
	autoblock		As Integer
	autoformat		As Integer
	codecomplete	As Integer
	autosave		As Integer
	autoload		As Integer
	autowidth		As Integer
	autoinclude		As Integer
	closeonlocks	As Integer
	tooltip			As Integer
	smartmath		As Integer
	ExtraLineSpace  As Integer                      '0.25 LF steps
End Type

Type EDITFONT
	size			As Integer
	charset			As Integer
	szFont			As ZString Ptr
	weight			As Integer
	italics			As Integer
End Type


Const szBracketMatch As String = "({[,)}],_"        ' Bracket matching


'KeyWords.dlg
#Define IDD_DLGKEYWORDS						4000
#Define IDC_BTNKWAPPLY						4002
#Define IDC_LSTKWCOLORS						4001
#Define IDC_CHKITALIC						4003
#Define IDC_CHKBOLD							4004
#Define IDC_BTNACTIVE						4008
#Define IDC_BTNHOLD							4009
#Define IDC_BTNDEL							4010
#Define IDC_BTNADD							4011
#Define IDC_EDTKW							4012
#Define IDC_LSTKWHOLD						4013
#Define IDC_LSTKWACTIVE						4014
#Define IDC_CHKRCFILE						4005
#Define IDC_CHKASM							4064
#Define IDC_LSTCOLORS						4015
#Define IDC_EDTCODEFILES					4030
#Define IDC_EDTTABSIZE						4018
#Define IDC_SPNTABSIZE						4017
#Define IDC_EDTEXTRALINESPACE               4067
#Define IDC_SPNEXTRALINESPACE               4069
#Define IDC_CHKEXPAND						4019
#Define IDC_CHKAUTOINDENT					4020
#Define IDC_CHKHILITELINE					4021
#Define IDC_STCCODEFONT						4022
#Define IDC_STCLNRFONT						4023
#Define IDC_STCTOOLSFONT					4065
#Define IDC_BTNCODEFONT						4024
#Define IDC_BTNLNRFONT						4025
#Define IDC_BTNTOOLSFONT					4066
#Define IDC_CHKHILITECMNT					4026
#Define IDC_CHKSINGLEINSTANCE				4031
#Define IDC_CBOTHEME						4007
#Define IDC_BTNSAVETHEME					4016
#Define IDC_EDTTHEME						4027
#Define IDC_CHKLINENUMBERS					4006
#Define IDC_EDTBACKUP						4029
#Define IDC_SPNBACKUP						4028
#Define IDC_CHKBRACEMATCH					4032
#Define IDC_CHKAUTOBRACE					4033
#Define IDC_CHKAUTOBLOCK					4035
#Define IDC_CHKAUTOFORMAT					4036
#Define IDC_CHKCOLORBOLD					4038
#Define IDC_CHKCOLORITALIC					4037
#Define IDC_CHKCODECOMPLETE				    4039
#Define IDC_CHKSAVE							4034
#Define IDC_CHKAUTOLOAD						4044
#Define IDC_CHKAUTOWIDTH					4045
#Define IDC_CHKAUTOINCLUDE					4046
#Define IDC_CHKTOOLTIP						4048
#define IDC_CHKCLOSEONLOCKS	     			4047
#Define IDC_CHKSMARTMATHS					4049
#Define IDC_RBNCASENONE						4040
#Define IDC_RBNCASEMIXED					4041
#Define IDC_RBNCASELOWER					4042
#Define IDC_RBNCASEUPPER					4043


Extern edtopt  As EDITOPTION
Extern fbcol   As FBCOLOR
Extern kwcol   As KWCOLOR

Extern edtfnt  As EDITFONT
Extern lnrfnt  As EDITFONT
Extern outpfnt As EDITFONT
Extern toolfnt As EDITFONT


Extern sCodeFiles    As ZString * 260          'sCodeFiles is LCASE p.def. - forced on every I/O
Extern custcol       As KWCOLOR

Extern thme(15)      As THEME
Extern szTheme(15)   As ZString * 32






