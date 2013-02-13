
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib

include RAFile.Inc
include RACodeComplete.inc
include RAGrid.inc
include RAHexEd.inc
include RAEdit.inc

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_DIALOG1			equ 101

;#########################################################################
.const

szDll				db 'FbEdit.dll',0
Path				db 'C:\',0
Filter				db '.asm.inc.rc.txt.ini.exe.bat.',0

szTestApi			db 'GdiComment',0
szTestParam			db 'hdc,cbSize,lpData',0
szTestRetType		db ':Dword',0
szTestDesc			db 'This is a test description',0
ApiFile				db 'Words.txt',0
szName				db 'Name',0

.data?

hInstance			dd ?
hDll				dd ?
FileData			db 32768 dup(?)

;#########################################################################
