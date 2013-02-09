
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include Comctl32.inc
include comdlg32.inc
include odbc32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib Comctl32.lib
includelib comdlg32.lib
includelib odbc32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

DlgProc				PROTO	:HWND,:UINT,:WPARAM,:LPARAM

;Grid.dlg
IDD_DIALOG1			equ 101
IDC_BTNTEST			equ 1006
IDC_BTNMOVEDOWN		equ 1001
IDC_BTNMOVEUP		equ 1002
IDC_BTNINSERT		equ 1003
IDC_BTNADD			equ 1004
IDC_BTNDEL			equ 1005
IDC_GRD1			equ 1007
IDC_EDTDB			equ 1008
IDC_BTNDB			equ 1009
IDC_GRDTABLE		equ 1010
IDC_BTNOPEN			equ 1011

.const

;Grid library
szRAGridDLL			db 'RAGrid.dll',0
szFilterMdb     	db 'Database (*.mdb)',0,'*.mdb',0,0

;Header text
szHdrTable			db 'Table',0
szAutoInc			db '**',0		;Added to column header if AutoIncrement column

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of data grid
hGrdTable			dd ?			;Handle of table grid
szTable				db 256 dup(?)	;Table name
nRows				dd ?			;Number of rows
dbCols				db 32768 dup(?)	;Columns descriotors
fNoUpdate			dd ?			;Grid does not update DB

;#########################################################################
