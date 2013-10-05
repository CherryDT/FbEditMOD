
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

IDB_BITMAP			equ 100

;Structure used to update rows
ROWDATA struct
	nImage			dd ?			;Data for Image column. Image index
	lpszName		dd ?			;Data for Name column. Pointer to string
	nID				dd ?			;Data for ID column. Double word
	nAccel			dd ?			;Data for Accelerator column. Double word
	nCheck			dd ?			;Data for Check column. Double word TRUE or FALSE
	nCombo			dd ?			;Data for Combo column. Double word item data
	lpszButton		dd ?			;Data for Button column. Pointer to string
	nDate			dd ?			;Data for Date column. Double word
	nTime			dd ?			;Data for Time column. Double word
	nIP				dd ?			;Data for IPAddress (TYPE_USER)
	lpszEditButton	dd ?			;Data for EditButton column. Pointer to string
	empty0			dd ?
	empty1			dd ?
	empty2			dd ?
	empty3			dd ?
	empty4			dd ?
	empty5			dd ?
	empty6			dd ?
	empty7			dd ?
	empty8			dd ?
	empty9			dd ?
ROWDATA ends

.const

szIPAddressClass	db 'SysIPAddress32',0

;ComboBox text
szComboBoxText		db 'Button',0
					db 'ComboBox',0
					db 'Edit',0
					db 'HotKey',0
					db 'ListBox',0
					db 'ScrollBar',0
					db 'Static',0
					db 'TabControl',0
					db 0

;Header text
szName				db 'Name',0
szID				db 'ID',0
szAccel				db 'Accelerator',0
szCheck				db 'Check',0
szImageCombo		db 'ImageCombo',0
szButton			db 'Button',0
szDate				db 'Date',0
szTime				db 'Time',0
szIPAddress			db 'IPAddress',0
szEditButton		db 'EditButton',0

szRAGridDLL			db 'RAGrid.DLL',0

;Format string
;szFormat			db '#´###´###´###',0
szFormat			db '# ### ### ###',0
szDateFormat		db "yyyy'-'MM'-'dd' '",0
szTimeFormat		db "hh':'mm",0

.data

;Just some row data
szText1				db 'IDM_FILE_NEW',0
szButton1			db 'C:\RadASM\RadASM.ini',0
szText2				db 'IDM_FILE_OPEN',0
szButton2			db 'C:\RadASM\masm.ini',0
szText3				db 'IDM_FILE_SAVE',0
szButton3			db 'C:\RadASM\GoAsm.ini',0
szText4				db 'IDM_FILE_EXIT',0
szButton4			db 'C:\RadASM\tasm.ini',0

szTextNew			db 'IDM_NEW_ITEM',0
szButtonNew			db 'C:\RadASM\hla.ini',0

rdta				ROWDATA <0,offset szText1,1001,(HOTKEYF_CONTROL shl 8) or VK_A,0,0,offset szButton1,147090,3600,01020341h,offset szButton1>
					ROWDATA <1,offset szText2,1002,(HOTKEYF_CONTROL shl 8) or VK_B,1,1,offset szButton2,147091,3601,01020342h,offset szButton2>
					ROWDATA <2,offset szText3,1003,(HOTKEYF_CONTROL shl 8) or VK_C,0,2,offset szButton3,147092,3602,01020304h,offset szButton3>
					ROWDATA <3,offset szText4,1004,(HOTKEYF_CONTROL shl 8) or VK_D,1,3,offset szButton4,147093,3603,01020304h,offset szButton4>
					ROWDATA <4,offset szText1,1005,(HOTKEYF_CONTROL shl 8) or VK_E,0,4,offset szButton1,147094,3604,01020304h,offset szButton1>
					ROWDATA <5,offset szText2,1006,(HOTKEYF_CONTROL shl 8) or VK_F,1,5,offset szButton2,147095,3605,01020304h,offset szButton2>
					ROWDATA <6,offset szText3,1007,(HOTKEYF_CONTROL shl 8) or VK_G,0,6,offset szButton3,147096,3606,01020304h,offset szButton3>
					ROWDATA <7,offset szText4,1008,(HOTKEYF_CONTROL shl 8) or VK_H,1,7,offset szButton4,147097,3607,01020304h,offset szButton4>
					ROWDATA <0,offset szText1,1009,(HOTKEYF_CONTROL shl 8) or VK_I,0,0,offset szButton1,147098,3608,01020304h,offset szButton1>
					ROWDATA <1,offset szText2,1010,(HOTKEYF_CONTROL shl 8) or VK_J,1,1,offset szButton2,147099,3609,01020304h,offset szButton2>
					ROWDATA <2,offset szText3,1011,(HOTKEYF_CONTROL shl 8) or VK_K,0,2,offset szButton3,147100,3610,01020304h,offset szButton3>
					ROWDATA <3,offset szText4,1012,(HOTKEYF_CONTROL shl 8) or VK_L,1,3,offset szButton4,147101,3611,01020304h,offset szButton4>
					ROWDATA <4,offset szText1,1013,(HOTKEYF_CONTROL shl 8) or VK_M,0,4,offset szButton1,147102,3612,01020304h,offset szButton1>
					ROWDATA <5,offset szText2,1014,(HOTKEYF_CONTROL shl 8) or VK_N,1,5,offset szButton2,147103,3613,01020304h,offset szButton2>
					ROWDATA <6,offset szText3,1015,(HOTKEYF_CONTROL shl 8) or VK_O,0,6,offset szButton3,147104,3614,01020304h,offset szButton3>
					ROWDATA <7,offset szText4,1016,(HOTKEYF_CONTROL shl 8) or VK_P,1,7,offset szButton4,147105,3615,01020304h,offset szButton4>

rdtanew				ROWDATA <0,offset szTextNew,1020,0,0,0,offset szButtonNew,147105,3615,01020304h,offset szButtonNew>

;#########################################################################

.data?

hInstance			dd ?			;Instance
hRAGridDLL			dd ?
hWnd				dd ?			;Handle of dialog
hGrd				dd ?			;Handle of grid
hIml				dd ?			;Handle of imagelist
OldIPAddressProc	dd ?
fFlag				dd ?

;#########################################################################
