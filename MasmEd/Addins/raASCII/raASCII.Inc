
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include Comctl32.inc
;	include shell32.inc
	include ComDlg32.inc
	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib Comctl32.lib
;	includelib shell32.lib
	includelib ComDlg32.lib
	includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

	include ..\Addins.inc

;#########################################################################
;		VKim's Debug

	include \RadASM\masm\inc\debug.inc
	includelib \RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

.data


.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	IDAddIn				dd ?	;Unique ID for this AddIn
	hook				HOOK <>

