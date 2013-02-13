
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
	lpszAddress		dd ?			;Data for Address column. Pointer to string
	nPoints			dd ?			;Data for Points column. Double word value
	lpszGraph		dd ?			;Data for Graph column. Pointer to string
ROWDATA ends

.const

;Grid library
szRAGridDLL			db 'RAGrid.DLL',0

;Header text
szName				db 'Name',0
szAddress			db 'Address',0
szPoints			db 'Points',0
szGraph				db 'Graph',0

;Just some row data
szName1				db 'Name#1',0
szAddress1			db 'Address#1',0
szName2				db 'Name#2',0
szAddress2			db 'Address#2',0
szName3				db 'Name#3',0
szAddress3			db 'Address#3',0
szName4				db 'Name#4',0
szAddress4			db 'Address#4',0

rdta				ROWDATA <offset szName1,offset szAddress1,2100,NULL>
					ROWDATA <offset szName2,offset szAddress2,3500,NULL>
					ROWDATA <offset szName3,offset szAddress3,8900,NULL>
					ROWDATA <offset szName4,offset szAddress4,4300,NULL>

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid

;#########################################################################
