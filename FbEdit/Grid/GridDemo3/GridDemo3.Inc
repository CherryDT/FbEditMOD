
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include Comctl32.inc
include comdlg32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib Comctl32.lib
includelib comdlg32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

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
	inx				dd ?
	lpszName		dd ?			;Data for Name column. Pointer to string
	lpszAddress		dd ?			;Data for Address column. Pointer to string
	nPoints			dd ?			;Data for Points column. Double word value
	nUser			dw ?			;Data for user column. Word value
ROWDATA ends

.const

;Grid library
szRAGridDLL			db 'RAGrid.DLL',0

;Header text
szIndex				db 'Index',0
szName				db 'Name',0
szAddress			db 'Address',0
szPoints			db 'Points',0
szUser				db 'User',0

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid

;#########################################################################
