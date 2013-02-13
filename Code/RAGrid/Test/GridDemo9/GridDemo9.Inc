include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc
include ..\RAGrid.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

IDD_DIALOG			equ 1000

IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10101

;Structure used to update rows
ROWDATA struct
	lpszName		dd ?			;Data for Name column. Pointer to string
	lpszAddress		dd ?			;Data for Address column. Pointer to string
	nPoints			dd ?			;Data for Points column. Double word value
	lpszButton1		dd ?
	lpszButton2		dd ?
ROWDATA ends

.const

szLib				db 'RAGrid.dll',0
ClassName			db 'MY_CLASS',0
GridClassName		db 'RAGrid',0
AppName				db 'Window',0

;Header text
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

rdta				ROWDATA <offset szName1,offset szAddress1,2000,offset szAddress1,offset szAddress1>
					ROWDATA <offset szName2,offset szAddress2,3500,offset szAddress1,offset szAddress1>
					ROWDATA <offset szName3,offset szAddress3,1900,offset szAddress1,offset szAddress1>
					ROWDATA <offset szName4,offset szAddress4,2300,offset szAddress1,offset szAddress1>

Tahoma_9 			LOGFONT <-12,0,0,0,400,0,0,0,0,3,2,1,34,"Tahoma">

.data?

hInstance			dd ?
CommandLine			dd ?
hLib				dd ?
hWnd				dd ?
hGrd				dd ?
hFont				dd ?

