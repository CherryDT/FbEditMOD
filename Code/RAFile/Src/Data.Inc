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
;include masm32.inc
;include \RadASM\masm\inc\debug.inc
;includelib masm32.lib
;includelib \RadASM\masm\lib\debug.lib

m2m macro M1, M2
    push M2
    pop  M1
endm

FileDir					PROTO :DWORD,:DWORD,:DWORD

IDB_TRV					equ 300

FILEBROWSER struct
	htrv		dd ?
	htbr		dd ?
	himl		dd ?
	hthread		dd ?
	hchange		dd ?
	ntimer		dd ?
	ffilter		dd ?
	filter		db MAX_PATH dup(?)
	filepath	db MAX_PATH dup(?)
	fdrives		dd ?
FILEBROWSER ends

.const

szTreeView				db 'SysTreeView32',0
szToolBar				db 'ToolbarWindow32',0
szListBox				db 'ListBox',0
szBackSlash				db '\',0
szAPA					db '*.*',0

btns					TBBUTTON <8,1,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <9,2,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>

.data?

hInstance				dd ?
wfd						WIN32_FIND_DATA <?>
szUpOneLevel			db 64 dup(?)
szFileFilter			db 64 dup(?)
