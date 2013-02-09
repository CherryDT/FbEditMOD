
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
	lpszName		dd ?			;Data for Name column. Pointer to string
	lpszGraph		dd ?			;Data for Graph column. Pointer to string
ROWDATA ends

.const

;Grid library
szRAGridDLL			db 'RAGrid.DLL',0
szEdit				db 'Edit',0

;Header text
szName				db 'Name',0
szGraph				db 'Graph',0

;Just some row data
szName1				db '#1',0
szName2				db '#2',0
szName3				db '#3',0
szName4				db '#4',0

rdta				ROWDATA <NULL,0201h>
					ROWDATA <NULL,0403h>
					ROWDATA <NULL,0605h>
					ROWDATA <NULL,0807h>

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid
ViewRoll			dd ?
fFlag				dd ?
OldEditProc			dd ?

;#########################################################################
