
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include gdi32.inc
include ..\ragrid.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib gdi32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

;GridTest.dlg
IDD_DIALOG1			equ 101
IDC_GRD1			equ 1001
IDC_SBR1			equ 1002

ROWDATA struct
	lpszName		dd ?			;Data for Name column. Pointer to string
	nID				dd ?			;Data for ID column. Double word
	lpszBtnText		dd ?			;Data for button text column
ROWDATA ends

.const

szRAGridDLL			db 'RAGrid.DLL',0
szName				db 'Name',0
szID				db 'ID',0

szFmt				db 'X: %d, Y: %d',0
szDown				db 'WM_LBUTTONDOWN',0
szUp				db 'WM_LBUTTONUP',0

rdta				ROWDATA <offset szName,1,offset szName>
					ROWDATA <offset szID,2,offset szName>
					ROWDATA <offset szName,3,offset szName>
					ROWDATA <offset szID,4,offset szName>

;#########################################################################

.data

MS_Sans_Serif_14 LOGFONT <-19,0,0,0,400,0,0,0,0,1,2,1,34,"MS Sans Serif">

.data?

hInstance			dd ?
hRAGridDLL			dd ?
hGrd				dd ?
OldGrdProc			dd ?
hSbr				dd ?

;#########################################################################
