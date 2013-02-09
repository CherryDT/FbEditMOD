
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include Comctl32.inc
include comdlg32.inc
include ole32.inc
include oleaut32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib Comctl32.lib
includelib comdlg32.lib
includelib ole32.lib
includelib oleaut32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

includelib image.lib

BitmapFromFile      PROTO   pszFileName:DWORD
BitmapFromMemory    PROTO   pHeap:DWORD, dwSize:DWORD
BitmapFromResource  PROTO   hModule:DWORD, lpName:DWORD

DlgProc				PROTO	:HWND,:UINT,:WPARAM,:LPARAM

;Grid.dlg
IDD_DIALOG1			equ 101
IDC_BTNMOVEDOWN		equ 1001
IDC_BTNMOVEUP		equ 1002
IDC_BTNINSERT		equ 1003
IDC_BTNADD			equ 1004
IDC_BTNDEL			equ 1005
IDC_BTNTEST			equ 1006
IDC_GRD1			equ 1007

;Structure used to update rows
ROWDATA struct
	hbmp			dd ?			;bitmap handle
	lpszFileName	dd ?			;pointer to string
ROWDATA ends

.const

;Grid library
szRAGridDLL			db 'RAGrid.DLL',0

;Header text
szImage				db 'Image',0
szFileName			db 'Filename',0

szGridDemo6			db 'GridDemo6\Pictures\',0
szImages			db 'homer.jpg',0
					db 'hagar.jpg',0
					db 'cat.gif',0
					db 'shrek.gif',0
					db 'donkey.bmp',0
					db 'bitrake.bmp',0
					db 0

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid
szPath				db MAX_PATH dup(?)
rdta				ROWDATA <?>

;#########################################################################
