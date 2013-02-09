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

include ..\RAResEd.inc
includelib ..\Lib\RAResEd.lib

include ..\RAResEd\RAGrid.Inc
include ..\RAResEd\RAEdit.Inc

;include masm32.inc
;include \RadASM\Masm\Inc\Debug.Inc
;includelib masm32.lib
;includelib \RadASM\Masm\Lib\Debug.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;WinMain						PROTO :DWORD,:DWORD,:DWORD,:DWORD
;WndProc						PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetToolMenu					PROTO
SetHelpMenu					PROTO

IDB_TOOLBAR					equ 100
IDB_ARROW					equ 32101
IDR_ACCEL					equ 105
IDI_ICON					equ 100

IDD_DIALOG					equ 3000
IDC_RESED					equ 1002
IDC_TBR1					equ 1004
IDC_SBR1					equ 1005
IDC_EDT1					equ 1007

IDR_MENU					equ 10000
IDM_FILE_NEW_PROJECT		equ 10029
IDM_FILE_OPEN_PROJECT		equ 10028
IDM_FILE_OPEN_TEXT			equ 10055
IDM_FILE_CLOSE_PROJECT		equ 10030
IDM_FILE_SAVE_PROJECT		equ 10031
IDM_FILE_SAVE_PROJECT_AS	equ 10032
IDM_FILE_EXIT				equ 10001
IDM_EDIT_UNDO				equ 10009
IDM_EDIT_REDO				equ 10051
IDM_EDIT_DELETE				equ 10010
IDM_EDIT_CUT				equ 10007
IDM_EDIT_COPY				equ 10006
IDM_EDIT_PASTE				equ 10008
IDM_EDIT_FIND				equ 10056
IDM_EDIT_REPLACE			equ 10057
IDM_VIEW_OUTPUT				equ 10039
IDM_VIEW_PREVIEW			equ 10042
IDM_VIEW_TEXTMODE			equ 10050
IDM_FORMAT_LOCK				equ 10011
IDM_FORMAT_BACK				equ 10012
IDM_FORMAT_FRONT			equ 10013
IDM_FORMAT_GRID				equ 10014
IDM_FORMAT_SNAP				equ 10015
IDM_FORMAT_ALIGN_LEFT		equ 10019
IDM_FORMAT_ALIGN_CENTER		equ 10020
IDM_FORMAT_ALIGN_RIGHT		equ 10021
IDM_FORMAT_ALIGN_TOP		equ 10022
IDM_FORMAT_ALIGN_MIDDLE		equ 10023
IDM_FORMAT_ALIGN_BOTTOM		equ 10024
IDM_FORMAT_SIZE_WIDTH		equ 10016
IDM_FORMAT_SIZE_HEIGHT		equ 10017
IDM_FORMAT_SIZE_BOTH		equ 10018
IDM_FORMAT_ALIGN_DLGHCENTER	equ 10043
IDM_FORMAT_ALIGN_DLGVCENTER	equ 10044
IDM_FORMAT_TABINDEX			equ 10045
IDM_FORMAT_AUTOID			equ 10047
IDM_PROJECT_ADD_DIALOG		equ 10002
IDM_PROJECT_ADD_MENU		equ 10003
IDM_PROJECT_LANGUAGE		equ 10041
IDM_PROJECT_ADD_ACCELERATOR	equ 10004
IDM_PROJECT_ADD_VERSIONINFO	equ 10026
IDM_PROJECT_ADD_STRINGTABLE	equ 10025
IDM_PROJECT_ADD_XPMANIFEST	equ 10048
IDM_PROJECT_ADD_RCDATA		equ 10049
IDM_PROJRCT_ADD_TOOLBAR		equ 10052
IDM_PROJECT_INCLUDE			equ 10034
IDM_PROJECT_RESOURCE		equ 10005
IDM_PROJECT_NAMES			equ 10035
IDM_PROJECT_REMOVE			equ 10027
IDM_PROJECT_EXPORT			equ 10040
IDM_PROJECT_UNDO			equ 10033
IDM_PROJECT_DLGSAVE			equ 10046
IDM_OPTION_TOOLS			equ 10036
IDM_OPTION_HELP				equ 10037
IDM_OPTION_OPTIONS			equ 10038
IDM_TOOLS_CLEAR				equ 10054
IDM_HELP_ABOUT				equ 10101

IDR_CONTEXT					equ 11000

WINPOS struct
	fMax		dd ?
	fView		dd ?
	x			dd ?
	y			dd ?
	wt			dd ?
	ht			dd ?
	htout		dd ?
	wtpro		dd ?
	htpro		dd ?
	left		dd ?
	top			dd ?
	wttbx		dd ?
	dummy		dd 3 dup(?)
WINPOS ends

NAMEEXPORT struct
	nType		dd ?
	szFileName	db MAX_PATH dup(?)
	nOutput		dd ?
	fAuto		dd ?
NAMEEXPORT ends

GRIDSIZE struct
	x			dd ?
	y			dd ?
	show		dd ?
	snap		dd ?
	tips		dd ?
	color		dd ?
	line		dd ?
	stylehex	dd ?
	sizetofont	dd ?
	defines		dd ?
	simple		dd ?
	defstatic	dd ?
	standardmnu	dd ?
	borlandcomp	dd ?
GRIDSIZE ends

MENUINFO STRUCT
	cbSize			DWORD	?
	fmask			DWORD	?
	dwstyle			DWORD	?
	cyMax			DWORD	?
	hbrBack			DWORD	?
	dwContextHelpID	DWORD	?
	dwMenuData		DWORD	?
MENUINFO ends

MENUDATA struct
	img		dd ?
	tpe		dd ?
MENUDATA ends

TEXTFONT struct
	lfFaceName		db LF_FACESIZE dup(?)
	lfHeight		dd ?
	lfWeight		dd ?
	lfItalic		dd ?
	lfCharSet		dd ?
TEXTFONT ends

.const

szWannaSave			db 'Want to save changes to',0Dh,0
szOpenFileFail		db 'Cannot open the file',0Dh,0
szSaveFileFail		db 'Cannot save the file',0Dh,0
szMemFail			db 'Memory allocation failed!',0Dh,0
szProjectTitle		db 'Open project file',0
szProjectTextTitle	db 'Open project as text',0
szIncludeTitle		db 'Open defines file',0
szClearMRU			db 'Clear MRU projects list?',0

szNewFile			db '(Untitled).rc',0
szRCFilterString	db 'Resource (*.rc)',0,'*.rc',0,0
szDefRCExt			db 'rc',0
szHFilterString		db 'Include (*.h)',0,'*.h',0,0
szDefHExt			db 'h',0
szDLGFilterString	db 'RadASM dlg (*.dlg)',0,'*.dlg',0,0
szDefDLGExt			db 'dlg',0
szALLFilterString	db 'Resource (*.rc)',0,'*.rc',0,'All files (*.*)',0,'*.*',0,0

tbrbtns				TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <0,IDM_FILE_NEW_PROJECT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <1,IDM_FILE_OPEN_PROJECT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <2,IDM_FILE_SAVE_PROJECT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <3,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <4,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <5,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <6,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <7,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <8,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <12,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <13,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <9,IDM_VIEW_OUTPUT,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
					TBBUTTON <10,IDM_VIEW_PREVIEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
ntbrbtns			equ 19


szDlgClass			db 'DLGCLASS',0
szAppName			db 'Resource editor',0
szResEd				db 'Software\ResEd1000\',0
szAboutMsg			db 'Resource editor 2.1.0.3',13,10,'KetilO © 2008',13,10,13,10,'radasmide@hotmail.com',0
szAboutUrl			db 'http://www.radasm.com/resed/',0
szOpen				db 'Open',0
szRichEdit			db 'riched20.dll',0
szNULL				db 0
szTab				db VK_TAB,0
szComma				db ',',0
szBS				db '\',0

szREG_SZ			db 'REG_SZ',0
szWinPos			db 'WinPos',0
szMruProject		db 'MruProject#',0

.data

wpos				WINPOS <0,3,10,10,620,460,100,150,200,100,100,52>
nmeexp				NAMEEXPORT <0,'rsrc.inc'>
grdsize				GRIDSIZE <3,3,TRUE,TRUE,TRUE,0,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE>
col					COLOR <0FFFFFFh,0,804000h,0C00000h>
initid				INITID <<1000,100>,<10000,1000>,<1,1>,<1,1>,<1,1>,<1,1>,<1,1>,<100,1>>
textfont			TEXTFONT <'Courier New',-12,0,0,0>

.data?

hInstance			dd ?
hRichEd				dd ?
CommandLine			dd ?
hWnd				dd ?
hTbr				dd ?
hImlTbr				dd ?
hImlTbrGray			dd ?
hMnu				dd ?
hContextMenu		dd ?
hIcon				dd ?
hAccel				dd ?
hContextMenuPopup	dd ?
hIml				dd ?
hResEd				dd ?
hResEdSave			dd ?
ProjectFileName		db MAX_PATH dup(?)
IncludeFileName		db MAX_PATH dup(?)
ProjectPath			db MAX_PATH dup(?)
SystemPath			db MAX_PATH dup(?)
AppPath				db MAX_PATH dup(?)
icex				INITCOMMONCONTROLSEX <?>
hReg				dd ?
lpdwDisp			dd ?
lpType				dd ?
lpcbData			dd ?
hCustDll			dd 32 dup(?)
hPreview			dd ?
hDialog				dd ?
winsize				WINSIZE <?>
mnupos				dd ?
mnubuff				db 8192 dup(?)
hMenuBrushA			dd ?
hMenuBrushB			dd ?
hMnuFont			dd ?
mruproject			db MAX_PATH*2*11 dup(?)
tmpbuff				db 1024 dup(?)

