include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib gdi32.lib

;#########################################################################
; VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

IDD_DIALOG			equ 1000
IDC_CBO1			equ 1001
IDC_CBO2			equ 1002

.const

ClassName			db 'DLGCLASS',0
szTest				db 'Test',0

.data?

hInstance			HINSTANCE ?
CommandLine			DWORD ?
hWnd				HWND ?
hCbo				HWND ?
lpOldCboProc		DWORD ?
