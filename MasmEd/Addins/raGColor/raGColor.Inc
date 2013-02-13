
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include ComDlg32.inc
	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib ComDlg32.lib
	includelib Gdi32.lib

;#########################################################################
;		MasmEd Add In Include

	include ..\Addins.inc

;#########################################################################
;		VKim's Debug

;	include \RadASM\masm\inc\debug.inc
;	includelib \RadASM\masm\lib\debug.lib
;
;	DBGWIN_DEBUG_ON = 1		; include debug info into the program
;	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	
	COLOR_RED            	equ 706
	COLOR_GREEN          	equ 707
	COLOR_BLUE           	equ 708
	COLOR_ADD            	equ 712
	COLOR_MIX            	equ 719
	COLOR_BOX1				equ	720
.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	hOut				dd ?	;Handle of output window
	IDAddIn				dd ?	;Unique ID for this AddIn
	hook				HOOK <>

