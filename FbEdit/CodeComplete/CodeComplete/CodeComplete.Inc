
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib

;VKim Debug
include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib


DlgProc				PROTO	:HWND,:UINT,:WPARAM,:LPARAM

IDD_DIALOG1			equ 101

.const

szDll				db 'RACodeComplete.dll',0
ApiFile				db 'Words.txt',0
szTestApi			db 'GdiComment',0
szTestParam			db 'hdc,cbSize,lpData',0
szTestRetType		db ':Dword',0
szTestDesc			db 'This is a test description',0

;#########################################################################

.data?

hInstance			dd ?
hDll				dd ?
FileData			db 32768 dup(?)

;#########################################################################
