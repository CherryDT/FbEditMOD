include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include shlwapi.inc
include comctl32.inc
include comdlg32.inc
include advapi32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib shlwapi.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib advapi32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

include ..\RACad.inc

IDB_CADBOX						equ 100
IDR_ACCEL						equ 100

IDD_MAIN						equ 1000
IDC_CAD1						equ 1001
IDC_SBR1						equ 1002
IDC_TBR1						equ 1003
IDC_TBR2						equ 1004
IDC_SHP1						equ 1005
IDC_CBO1						equ 1006
IDC_EDT1						equ 1007
IDC_STC1						equ 1008

IDC_RBNSCHEMA					equ 1009
IDC_RBNCOMP						equ 1010
IDC_RBNPCBTOP					equ 1011
IDC_RBNPCBBOTTOM				equ 1012

IDD_DLGSYM						equ 2000
IDC_BTNNEXT						equ 1001
IDC_BTNPREV						equ 1002

;SimCad.mnu
IDM_MAIN						equ 10000
IDM_FILE_NEW					equ 10107
IDM_FILE_OPEN					equ 10002
IDM_FILE_SAVE					equ 10003
IDM_FILE_SAVE_AS				equ 10108
IDM_FILE_PAGESETUP				equ 10110
IDM_FILE_PRINT					equ 10004
IDM_FILE_EXIT					equ 10001
IDM_EDIT_UNDO					equ 10101
IDM_EDIT_REDO					equ 10102
IDM_EDIT_CUT					equ 10103
IDM_EDIT_COPY					equ 10104
IDM_EDIT_PASTE					equ 10105
IDM_EDIT_DELETE					equ 10106
IDM_EDIT_SELECTALL				equ 10109
IDM_EDIT_COLOR					equ 10120
IDM_EDIT_WIDTH					equ 10121
IDM_EDIT_SNAP					equ 10119
IDM_EDIT_ADDSYM					equ 10122
IDM_VIEW_GRID					equ 10111
IDM_VIEW_STATUSBAR				equ 10113
IDM_VIEW_ZOOM_IN				equ 10115
IDM_VIEW_ZOOM_OUT				equ 10116
IDM_VIEW_ZOOM_BEST_FIT			equ 10117
IDM_OPTION_SETUP				equ 10112
IDM_OPTION_TOOLS_MENU			equ 10114
IDM_OPTION_HELP_MENU			equ 10118
IDM_HELP_ABOUT					equ 10901

IDM_VIEW_HOME					equ 10200

IDC_MOVE						equ 20000
IDC_LINE						equ 20001
IDC_RECT						equ 20002
IDC_CIRCLE						equ 20003
IDC_POLYLINE					equ 20004
IDC_HTEXT						equ 20005
IDC_VTEXT						equ 20006
IDC_DIMENSION					equ 20007

IDC_FLIP						equ 20100
IDC_ROTATE						equ 20101

WINPOS struct
	fMax		dd ?
	fView		dd ?
	x			dd ?
	y			dd ?
	wt			dd ?
	ht			dd ?
	dummy		dd 4 dup(?)
WINPOS ends

SYMBOLS struct
	lpPath		dd ?
	lpFiles		dd ?
SYMBOLS ends

PRNPOS struct
	margins		RECT <?>
	pagesize	POINT <?>
PRNPOS ends

.const

RACad				db 'RACad.dll',0
DlgClass			db 'DLGCLASS',0
szALL				db '*.*',0
szCAD				db '.cad',0
szBackSlash			db '\',0
szSymbols			db '\Symbols',0

tbrbtns				TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <14,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <6,IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <7,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <8,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
ntbrbtns			equ 14

cadtbrbtns			TBBUTTON <0,IDC_MOVE,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <1,IDC_LINE,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <2,IDC_RECT,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <3,IDC_CIRCLE,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <4,IDC_POLYLINE,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <5,IDC_HTEXT,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <6,IDC_VTEXT,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <7,IDC_DIMENSION,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <8,IDC_FLIP,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <9,IDC_ROTATE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
cadntbrbtns			equ 11


AppName				db 'SimCad',0
AboutMsg			db 'SimCad',13,10,'KetilO (C) 2004',0

OpenFileFail        db 'Cannot open the file',0
SaveFileFail		db 'Cannot save the file',0
WannaSave           db 'Want to save changes to',0Dh,0
NewFile             db 'Untitled.cad',0

CADFilterString		db 'Cad Files (*.cad)',0,'*.cad',0
					db 'All Files (*.*)',0,'*.*',0,0
Cad					db 'Cad',0

sbp					dd 100,200,300,-1

.data

szREG_SZ			db 'REG_SZ',0
szSimCad			db 'Software\SimCad\',0
					db 64 dup(0)
szWinPos			db 'WinPos',0
wpos				WINPOS <0,7,10,10,620,460>
szPrnPos			db 'PrnPos',0
ppos				PRNPOS <<1000,1000,1000,1000>,<21000,29700>>

.data?

hInstance			dd ?
CommandLine			dd ?
hRACad				dd ?
hAccel				dd ?
hWnd				dd ?
hSymDlg				dd ?
hSym				dd 16 dup(?)
hCad				dd ?
hShp1				dd ?
hTbr1				dd ?
hTbr2				dd ?
hSbr				dd ?
hCbo				dd ?
hStc				dd ?
hEdt				dd ?
hBr					dd ?
nObj				dd ?
CustColors			dd 16 dup(?)
hReg				dd ?
lpdwDisp			dd ?
lpType				dd ?
lpcbData			dd ?
AppPath				db MAX_PATH dup(?)
FileName			db MAX_PATH dup(?)
psd					PAGESETUPDLG <?>
pd					PRINTDLG <?>
rpobj				dd ?
wfd					WIN32_FIND_DATA <?>
pthsym				db MAX_PATH*32 dup(?)
symfiles			db MAX_PATH*32*16 dup(?)
inxsym				dd ?
sym					SYMBOLS 32 dup(<>)
hSymSel				dd ?
curx				dd ?
cury				dd ?
layer				dd ?
