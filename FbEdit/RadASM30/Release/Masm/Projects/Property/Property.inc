include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib
includelib gdi32.lib

;#########################################################################
; VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

IDD_DIALOG              equ 1000
IDC_LST1                equ 1001
IDC_EDT1                equ 1002
IDC_BTN1                equ 1003
IDC_CBO1                equ 1004

nPropWt					equ 70

.const

ClassName				BYTE 'DLGCLASS',0
szListBox				BYTE 'ListBox',0

szPropItems				BYTE 1,'(ID)',VK_TAB,'1000',0
						BYTE 2,'(Name)',VK_TAB,'IDC_TEST',0
						BYTE 3,'Type3',VK_TAB,'VALUE3',0
						BYTE 4,'Type4',VK_TAB,'FALSE',0
						BYTE 5,'Type5',VK_TAB,'Type5.1',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 2,'Test',VK_TAB,'TEST',0
						BYTE 0

szPropValue4			BYTE 0,'FALSE',0
						BYTE 1,'TRUE',0
						BYTE 0,0

szPropValue5			BYTE 1,'Type5.1',0
						BYTE 2,'Type5.2',0
						BYTE 3,'Type5.3',0
						BYTE 4,'Type5.4',0
						BYTE 5,'Type5.5',0
						BYTE 6,'Type5.6',0
						BYTE 7,'Type5.7',0
						BYTE 8,'Type5.8',0
						BYTE 9,'Type5.9',0
						BYTE 10,'Type5.10',0
						BYTE 11,'Type5.11',0
						BYTE 12,'Type5.12',0
						BYTE 13,'Type5.13',0
						BYTE 14,'Type5.14',0
						BYTE 15,'Type5.15',0
						BYTE 0,0

szTest					BYTE 'Test',0

.data?

hInstance				HINSTANCE ?
CommandLine				DWORD ?
hWnd					HWND ?
hLstProp				HWND ?
lpOldPropListProc		DWORD ?
hCbo					HWND ?
lpOldChildComboProc		DWORD ?
hEdt					HWND ?
lpOldChildEditProc		DWORD ?
hBtn					HWND ?
tempbuff				BYTE 256 dup(?)
