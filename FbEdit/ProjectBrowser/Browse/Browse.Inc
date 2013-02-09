
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib

include ..\RAProject.inc

;VKim Debug
include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

IDD_DIALOG1						equ 101
IDC_RAP							equ 1001

IDR_MENU						equ 10000
IDM_PROJECT						equ 10001
IDM_PROJECT_ADDGROUP			equ 10002
IDM_PROJECT_DELGROUP			equ 10003
IDM_PROJECT_EDITGROUP			equ 10004

.const

szRAProject			db 'RAProject.dll',0

;#########################################################################

pbfileext			PBFILEEXT 3 dup(<1,'.asm.'>,<2,'.inc.'>,<0>)
pbitems				PBITEM <-1,0,'MyProject',1>
					PBITEM <-2,-1,'Assembly',1>
					PBITEM <-3,-2,'Asm',0>
					PBITEM <-4,-2,'Inc',0>
					PBITEM <-5,-1,'Resource',1>
					PBITEM <-6,-5,'Dialog',1>
					PBITEM <-7,-5,'Menu',1>
					PBITEM <1,-3,'C:\Assembly\Project\MyProject\Mod\MyAsm2.asm'>
					PBITEM <2,-3,'C:\Assembly\Project\MyProject\MyAsm1.asm'>
					PBITEM <3,-4,'C:\Assembly\Project\MyProject\MyInc.inc'>
					PBITEM <4,-6,'C:\Assembly\Project\MyProject\MyDialog.dlg'>
					PBITEM <5,-7,'C:\Assembly\Project\MyProject\MyMenu.mnu'>
					PBITEM <0,0,,0>
pbpath				db 'C:\Assembly\Project\MyProject',0

.data?

hInstance			HINSTANCE ?
hLib				HMODULE ?
hPbr				HWND ?
hMnu				HMENU ?

;#########################################################################
