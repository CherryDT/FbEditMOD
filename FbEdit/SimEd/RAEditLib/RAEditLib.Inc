
include windows.inc
include kernel32.inc
include user32.inc
include comctl32.inc
include shell32.inc
include ole32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib ole32.lib

includelib ..\Lib\RaEdit.lib

DlgProc				PROTO	:HWND,:UINT,:WPARAM,:LPARAM
InstallRAEdit		PROTO	:DWORD,:DWORD
UnInstallRAEdit		PROTO

IDD_DIALOG1			equ 1000
IDC_RAEDIT			equ 1001

;#########################################################################

.data?

hInstance			dd ?

;#########################################################################
