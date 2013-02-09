include		windows.inc
include		kernel32.inc
include		user32.inc
include		Comctl32.inc
include		shell32.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	Comctl32.lib
includelib	shell32.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_MAIN		equ 101

MYSTRUCT struct
	aa		dd ?
	bb		dd ?
	rc		RECT <>
MYSTRUCT ends

;#########################################################################

.data?

hInstance		dd		?
x				dd		?
rect			RECT <>
ms				MYSTRUCT <>

;#########################################################################

