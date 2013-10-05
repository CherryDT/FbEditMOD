
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib

include ..\RAFile.Inc

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_DIALOG1			equ 101

;#########################################################################
.const

szDll				db 'RAFile.dll',0
Path				db 'C:\',0
Filter				db '.asm.inc.rc.txt.ini.exe.bat.',0

.data?

hInstance			dd ?
hDll				dd ?

;#########################################################################
