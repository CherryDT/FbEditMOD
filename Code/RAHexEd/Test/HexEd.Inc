
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
UpdateAll				PROTO :DWORD
CreateRAHexEd			PROTO
CreateNew				PROTO
TabToolAdd				PROTO :DWORD,:DWORD

IS_OPEN					equ -1
SAVE_ALL				equ -2

TABHT					equ 21

IDB_TBRBMP				equ 150
IDR_ACCEL				equ 200
IDB_MNUARROW			equ 200

;Find.dlg
IDD_FINDDLG				equ 2000
IDC_BTN_REPLACE			equ 2007
IDC_BTN_REPLACEALL		equ 2008
IDC_FINDTEXT			equ 2001
IDC_REPLACETEXT			equ 2002
IDC_REPLACESTATIC		equ 2009
IDC_RBN_ASCII			equ 2004
IDC_RBN_HEX				equ 2003
IDC_RBN_DOWN			equ 2005
IDC_RBN_UP				equ 2006

;HexEd.dlg
IDD_DLG					equ 1000
IDC_TBR					equ 1001
IDC_RAH					equ 1002
IDC_TAB					equ 1004
IDC_SBR					equ 1003
IDC_SHP					equ 1005
IDI_ICON				equ 100

IDM_HELPF1				equ 500
IDM_MENU				equ 10000

;HexEd.mnu
IDM_FILE_NEW			equ 10001
IDM_FILE_OPEN			equ 10002
IDM_FILE_SAVE			equ 10003
IDM_FILE_SAVEAS			equ 10004
IDM_FILE_SAVEALL		equ 10011
IDM_FILE_CLOSE			equ 10010
IDM_FILE_PRINT			equ 10005
IDM_FILE_EXIT			equ 10006
IDM_EDIT_UNDO			equ 10101
IDM_EDIT_REDO			equ 10102
IDM_EDIT_DELETE			equ 10103
IDM_EDIT_CUT			equ 10104
IDM_EDIT_COPY			equ 10105
IDM_EDIT_PASTE			equ 10106
IDM_EDIT_SELECTALL		equ 10107
IDM_EDIT_FIND			equ 10108
IDM_EDIT_FINDNEXT		equ 10110
IDM_EDIT_FINDPREV		equ 10111
IDM_EDIT_REPLACE		equ 10109
IDM_EDIT_TOGGLEBM		equ 10018
IDM_EDIT_NEXTBM			equ 10019
IDM_EDIT_PREVBM			equ 10020
IDM_EDIT_CLEARBM		equ 10021
IDM_VIEW_TOOLBAR		equ 10008
IDM_VIEW_STATUSBAR		equ 10009
IDM_VIEW_SELBAR			equ 10015
IDM_VIEW_ADDRESS		equ 10012
IDM_VIEW_ASCII			equ 10013
IDM_VIEW_UPPERCASE		equ 10014
IDM_OPTION_FONT			equ 10007
IDM_OPTION_LNFONT		equ 10022
IDM_OPTION_COLORS		equ 10023
IDM_OPTION_TOOLS		equ 10031
IDM_OPTION_HELP			equ 10032
IDM_HELP_ABOUT			equ 10201

TABMEM struct
	hwnd		dd ?
	filename	db MAX_PATH dup (?)
TABMEM ends

WINPOS struct
	fMax		dd ?
	fView		dd ?
	x			dd ?
	y			dd ?
	wt			dd ?
	ht			dd ?
	FindX		dd ?
	FindY		dd ?
WINPOS ends

.const

tbrbtns					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <16,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <6,IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <7,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <8,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <11,IDM_FILE_SAVEALL,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <9,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <10,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <12,IDM_EDIT_TOGGLEBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <13,IDM_EDIT_NEXTBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <14,IDM_EDIT_PREVBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <15,IDM_EDIT_CLEARBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
ntbrbtns				equ 24

ALLFilterString			db 'All Files (*.*)',0,'*.*',0,0

.data

RAHexEdDLL				db 'RAHexEd.dll',0
RAHexEdFail				db 'Could not find RAHexEd.dll',0
szRAHexEdClass			db 'RAHEXEDIT',0
ClassName				db 'DLGCLASS',0

szAppName				db 'Hex editor',0
szAboutMsg				db 'Hex editor 1.0.1.9',13,10,'KetilO © 2003-2008',13,10,13,10,'radasmide@hotmail.com',0
szAboutUrl				db 'http://www.radasm.com',0
szOpen					db 'Open',0

Replace					db 'Replace ..',0
OpenFileFail        	db 'Cannot open the file',0
SaveFileFail			db 'Cannot save the file',0
WannaSave           	db 'Want to save changes to',0Dh,0
NewFile             	db '(Untitled)',0
szNULL					db 0
szTab					db VK_TAB,0

szREG_SZ				db 'REG_SZ',0
szHexEd					db 'Software\HexEd1000\',0
						db 64 dup(0)
szWinPos				db 'WinPos',0
wpos					WINPOS <0,3,10,10,620,460,20,20>
szHexFont				db 'HexFont',0
lfnthex					LOGFONT <-12,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Courier New'>
szLnrFont				db 'LnrFont',0
lfntlnr					LOGFONT <-8,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Terminal'>
szColor					db 'Color',0
col						HECOLOR <DEFBCKCOLOR,DEFADRTXTCOLOR,DEFDTATXTCOLOR,DEFASCTXTCOLOR,DEFSELBCKCOLOR,DEFLFSELBCKCOLOR,DEFSELTXTCOLOR,DEFSELBARCOLOR,DEFSELBARPEN,DEFLNRCOLOR>
szCustColors			db 'CustColors',0

.data?

CustColors				dd 16 dup(?)
hRAHexEdDLL				dd ?
hInstance				dd ?
CommandLine				dd ?
hIcon					dd ?
hAccel					dd ?
hWnd					dd ?
hREd					dd ?
style					dd ?
hTab					dd ?
hFind					dd ?
hMnu					dd ?
hTbr					dd ?
hReg					dd ?
lpdwDisp				dd ?
lpType					dd ?
lpcbData				dd ?
FileName				db MAX_PATH dup(?)
hFont					dd ?
hLnrFont				dd ?
findbuff				db 256 dup(?)
replacebuff				db 256 dup(?)
ft						FINDTEXTEX <>
fr						dd ?
fres					dd ?
nLastLine				dd ?
fTimer					dd ?
hMnuIml					dd ?
LineTxt					db 16384 dup(?)
