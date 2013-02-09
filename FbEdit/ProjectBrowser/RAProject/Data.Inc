include windows.inc
include Comctl32.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib comctl32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

;VKim Debug
include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

IDB_TRV					equ 310
MAXITEMMEM				equ 1024*sizeof PBITEM
MAXFIEEXTMEM			equ 16*1024

PROJECTBROWSER struct
	hwnd			HWND ?
	htrv			HWND ?
	htbr			HWND ?
	himl			HIMAGELIST ?
	style			DWORD ?
	projectpath		db MAX_PATH dup(?)
	hmemfileext		HGLOBAL ?
	hmemitems		HGLOBAL ?
	ngrouping		dd ?
PROJECTBROWSER ends

SORT struct
	szname			db MAX_PATH dup(?)
	lpPBITEM		dd ?
SORT ends

.const

szTreeView				db 'SysTreeView32',0
szToolBar				db 'ToolbarWindow32',0

btns					TBBUTTON <0,1,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <1,2,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>

CombSort_Const			REAL4 1.3
szBS					db '\',0
szNewGroup				db 'New Group',0

.data

szGrouping				db 'Grouping',64 dup(0)
szExpand				db 'Expand / Collapse',64 dup(0)

.data?

hInstance				dd ?
lpOldGroupTrvEditProc	dd ?
IsDragging				dd ?
TVDragItem				dd ?
hDragIml				HIMAGELIST ?
szitemnew				db MAX_PATH dup(?)
