include windows.inc
include Comctl32.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib Comctl32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include ..\RAProperty.inc

;VKim Debug
include masm32.inc
include \Programme\RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \Programme\RadASM\masm\lib\debug.lib

RAPROPERTY struct
	hwnd			HWND ?
	hpar			HWND ?
	id				dd ?
	hfont			HFONT ?
	himl			dd ?
	htbr			HWND ?
	hcbo			HWND ?
	hlst			HWND ?
	hmem			dd ?
	cbsize			dd ?
	lpmem			dd ?
	rpfree			dd ?
	rpproject		dd ?
	lpchartab		dd ?
	defgen			DEFGEN <>
	lpignore		dd ?
	rpignorefree	dd ?
	lpisword		dd ?
	rpiswordfree	dd ?
	lpdeftype		dd ?
	rpfreedeftype	dd ?
	nOwner			dd ?
	nButton			dd ?
	szFindTypes		db 64 dup(?)
	szFindText		db 64 dup(?)
	rpFindPos		dd ?
	nfindtype		dd ?
	nfindowner		dd ?
	nfindline		dd ?
	nfindendline	dd ?
	backcolor		dd ?
	textcolor		dd ?
	oprcolor		dd ?
	hbrback			dd ?
	topindex		dd ?
	selindex		dd ?
	htooltip		dd ?
	nlanguage		dd ?
	hMemArray		dd ?
RAPROPERTY ends

IDB_TRV					equ 101

.const

szToolBar				db 'ToolbarWindow32',0
btnspro					TBBUTTON <0,1,TBSTATE_ENABLED or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <1,2,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <2,3,0,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <3,4,0,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <4,5,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
btnsnopro				TBBUTTON <0,1,TBSTATE_ENABLED or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <1,2,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <4,5,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
szComboBox				db 'ComboBox',0
szListBox				db 'ListBox',0
szToolTipClass			db 'tooltips_class32',0
szDot					db '.',0
szLpa					db '(',0
szRpa					db ')',0
szSpc					db ' ',0
szPtr					db ' Ptr',0
szMasmPtr				db 'PTR ',0
szInteger				db 'Integer',0
szDword					db ':DWORD',0
szColon					db ':',0
szSub					db 'SUB',0
szFunction				db 'FUNCTION',0
szAs					db ' As ',0
szCRLF					db 0Dh,0Ah,0
szMasmDataConv			db 'DB',0,'BYTE',0
						db 'DW',0,'WORD',0
						db 'DD',0,'DWORD',0
						db 'DQ',0,'QWORD',0
						db 'DT',0,'TBYTE',0
						db 'DF',0,'FWORD',0
						db 'DD',0,'REAL4',0
						db 'DQ',0,'REAL8',0
						db 'DT',0,'REAL10',0
						db 'DB',0,'SBYTE',0
						db 'DW',0,'SWORD',0
						db 'DD',0,'SDWORD',0
						db 0,0
szGoAsmDataConv			db 'DB',0,'DB',0
						db 'DW',0,'DW',0
						db 'DD',0,'DD',0
						db 'DQ',0,'DQ',0
						db 'DT',0,'DT',0
						db 'DO',0,'DO',0
						db 0,0
szFasmDataConv			db 'DB',0,'DB',0
						db 'DW',0,'DW',0
						db 'DD',0,'DD',0
						db 'DQ',0,'DQ',0
						db 'DT',0,'DT',0
						db 'DO',0,'DO',0
						db 0,0
szTasmDataConv			db 'DB',0,'BYTE',0
						db 'DW',0,'WORD',0
						db 'DD',0,'DWORD',0
						db 'DQ',0,'QWORD',0
						db 'DT',0,'TBYTE',0
						db 'DF',0,'FWORD',0
						db 'DD',0,'REAL4',0
						db 'DQ',0,'REAL8',0
						db 'DT',0,'REAL10',0
						db 'DB',0,'SBYTE',0
						db 'DW',0,'SWORD',0
						db 'DD',0,'SDWORD',0
						db 0,0
szSolDataConv			db	'DB',0,'BYTE',0
						db	'DW',0,'WORD',0
						db	'DD',0,'DWORD',0
						db	'DQ',0,'QWORD',0
						db	'DT',0,'TBYTE',0
						db	'DF',0,'FWORD',0
						db	'DD',0,'REAL4',0
						db	'DQ',0,'REAL8',0
						db	'DT',0,'REAL10',0
						db	'DB',0,'SBYTE',0
						db	'DW',0,'SWORD',0
						db	'DD',0,'SDWORD',0
						db	'RB',0,'BYTE',0
						db	'RW',0,'WORD',0
						db	'RD',0,'DWORD',0
						db	0,0

szAdd					db '+',0

.data?

hInstance				dd ?
OldListBoxProc			dd ?
OldItem					dd ?
szname					db 32768 dup(?)
buff1					db 16384 dup(?)
buff2					db 16384 dup(?)
szstructnest			db 1024 dup(?)
itemht					dd ?
;Tooltips
szCurrentFile			db 64 dup(?)
szOpenFiles				db 64 dup(?)
szSelectedProjectFile	db 64 dup(?)
szAllProjectFiles		db 64 dup(?)
szRefresh				db 64 dup(?)
