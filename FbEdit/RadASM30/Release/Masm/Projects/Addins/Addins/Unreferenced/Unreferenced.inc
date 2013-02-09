
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include ComDlg32.inc
include Gdi32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib ComDlg32.lib
includelib Gdi32.lib

;#########################################################################
;RadASM Add In Include

include ..\Addins.inc

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

FILES struct
	pid				DWORD ?
	lpFileName		DWORD ?
	hMem			HGLOBAL ?
FILES ends

.const

szMenuName			db 'Unreferenced Variables',0
szGlobal			db 'Found %d unreferenced global variable(s).',0
szLocal				db 'Found %d unreferenced local variable(s).',0
szCR				db 0Dh,0
szLoading			db 'Loading: ',0
szNULL				db 0
szCCs				db 's',0
szCCd				db 'd',0
szCCp				db 'p',0
szUnrefGlobal		db 'Unreferenced Global: ',0
szUnrefLocal		db 'Unreferenced Local: ',0
szLOCAL				db 'LOCAL',0

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
IDAddIn				dd ?	;Unique ID for this AddIn
hook				HOOK <>
nGlobal				dd ?
nLocal				dd ?
;nTest				dd ?
