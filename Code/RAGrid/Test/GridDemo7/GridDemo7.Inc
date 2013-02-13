
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
	lpszCheck		dd ?
	lpszName		dd ?			;Data for Name column. Pointer to string
	lpszAddress		dd ?			;Data for Address column. Pointer to string
	nPoints			dd ?			;Data for Points column. Double word value
	lpszButton1		dd ?
	lpszButton2		dd ?
ROWDATA ends

.const

;Grid library
szRAGridDLL			db 'RAGrid.DLL',0

;Header text
szCheck				db 'Check',0
szName				db 'Name',0
szAddress			db 'Address',0
szPoints			db 'Points',0
szButton			db 'Button',0

;Just some row data
szName1				db 'Name#1',0
szAddress1			db 'Address#1',0
szName2				db 'Name#2',0
szAddress2			db 'Address#2',0
szName3				db 'Name#3',0
szAddress3			db 'Address#3',0
szName4				db 'Name#4',0
szAddress4			db 'Address#4',0
szName5				db 'Name#5',0
szAddress5			db 'Address#5',0
szName6				db 'Name#6',0
szAddress6			db 'Address#6',0

rdta				ROWDATA <0,offset szName1,offset szAddress1,2000,offset szAddress1,offset szAddress1>
					ROWDATA <0,offset szName2,offset szAddress2,3500,offset szAddress1,offset szAddress1>
					ROWDATA <0,offset szName3,offset szAddress3,1900,offset szAddress1,offset szAddress1>
					ROWDATA <0,offset szName4,offset szAddress4,2300,offset szAddress1,offset szAddress1>
					ROWDATA <0,offset szName5,offset szAddress5,1800,offset szAddress1,offset szAddress1>
					ROWDATA <0,offset szName6,offset szAddress6,2700,offset szAddress1,offset szAddress1>

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid

;#########################################################################
