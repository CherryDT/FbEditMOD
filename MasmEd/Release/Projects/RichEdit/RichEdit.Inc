
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib

IDR_ACCEL			equ 1

;Find.dlg
IDD_FINDDLG			equ 2000
IDC_FINDTEXT		equ 2001
IDC_BTN_REPLACE		equ 2007
IDC_REPLACETEXT		equ 2002
IDC_REPLACESTATIC	equ 2009
IDC_BTN_REPLACEALL	equ 2008
IDC_CHK_WHOLEWORD	equ 2004
IDC_CHK_MATCHCASE	equ 2003
IDC_RBN_DOWN		equ 2005
IDC_RBN_UP			equ 2006

;RichEditEditor.dlg
IDD_DLG				equ 1000
IDC_SBR				equ 1003
IDC_TBR				equ 1001
IDC_RED				equ 1002
IDB_TBRBMP			equ 1212
IDM_MENU			equ 10000

;RichEditEditor.mnu
IDM_FILE_NEW		equ 10001
IDM_FILE_OPEN		equ 10002
IDM_FILE_SAVE		equ 10003
IDM_FILE_SAVEAS		equ 10004
IDM_FILE_PRINT		equ 10005
IDM_FILE_EXIT		equ 10006
IDM_EDIT_UNDO		equ 10101
IDM_EDIT_REDO		equ 10102
IDM_EDIT_DELETE		equ 10103
IDM_EDIT_CUT		equ 10104
IDM_EDIT_COPY		equ 10105
IDM_EDIT_PASTE		equ 10106
IDM_EDIT_SELECTALL	equ 10107
IDM_EDIT_FIND		equ 10108
IDM_EDIT_FINDNEXT	equ 10110
IDM_EDIT_FINDPREV	equ 10111
IDM_EDIT_REPLACE	equ 10109
IDM_VIEW_TOOLBAR	equ 10008
IDM_VIEW_STATUSBAR	equ 10009
IDM_OPTION_FONT		equ 10007
IDM_HELP_ABOUT		equ 10201

.const

;structure for ToolBar buttons
tbrbtns				TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <6,IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <7,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <8,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <12,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <13,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <14,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
;;Number of buttons in tbbtns
ntbrbtns			equ 18

.data

RichEditDLL			db 'riched20.dll',0
ClassName			db 'DLGCLASS',0
AppName				db 'RichEdit editor',0
AboutMsg			db 'RadASM RichEdit editor',13,10,'KetilO (C) 2002',0
Replace				db 'Replace ..',0
OpenFileFail        db 'Cannot open the file',0
SaveFileFail		db 'Cannot save the file',0
WannaSave           db 'Want to save changes to',0Dh,0
NoMatches			db 'No matches found.',0
ReplaceAllRes		db '%d Replacements done.',0

NewFile             db '(Untitled)',0
szNULL				db 0
szFont				db 'Courier New',0

.data?

hRichEdDLL			dd ?
hInstance			dd ?
CommandLine			dd ?
hIcon				dd ?
hWnd				HWND ?
hAccel				dd ?
hREd				HWND ?
hFind				HWND ?
FileName			db MAX_PATH dup(?)
;structure for DateTimePicker
iccex				INITCOMMONCONTROLSEX <?>

fView				dd ?
TabSize				dd ?
lfnt				LOGFONT <?>
hFont				dd ?
rgb					dd ?
;Find
FindBuff			db MAX_PATH dup(?)
ReplaceBuff			db MAX_PATH dup(?)
FindInit			dd ?
fr					dd ?
fres				dd ?
ReplaceCount		dd ?
fw					FWORD ?
nn					dd ?
