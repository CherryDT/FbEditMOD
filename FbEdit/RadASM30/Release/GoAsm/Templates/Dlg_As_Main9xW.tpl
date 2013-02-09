Dialog as main, Win9x, Unicode, MSLU
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=goasm
Group=2,-1,0,1,UNICODE 9x Dialog As Main,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].Asm
F2=-3,0,1,22,22,600,400,0,[*PROJECTNAME*].h
F3=-5,2,4,22,22,600,400,0,[*PROJECTNAME*].Rc
[Make]
Make=0
0=Win32 MSLU Release,'/r "$R"',"$R.res",'/c /d UNICODE "$C"',"$C.obj",'$C $M $R /mslu',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
;##################################################################
; [*PROJECTNAME*]
;##################################################################

STRINGS UNICODE

#include [*PROJECTNAME*].h

IDD_DLG1			equ		1000

DATA SECTION
	hInstance			HANDLE 		?
	hDlg				HANDLE		?

	ClassName			DUS		"DialogClass",0

CODE SECTION

START:
	invoke GetModuleHandle, 0
	mov [hInstance],eax
	invoke InitCommonControls
	invoke WinMain,[hInstance],NULL,NULL,SW_SHOW
	invoke ExitProcess,0

WinMain FRAME hInst,hPrevInstance,lpCmdLine,nCmdShow
	LOCAL	wc				:WNDCLASSEX
	LOCAL	msg				:MSG
	LOCAL	hdc				:%HANDLE

	; Define our main window class and register it
	mov		D[wc.cbSize], SIZEOF WNDCLASSEX
	mov		D[wc.style], CS_HREDRAW + CS_VREDRAW
	mov		D[wc.lpfnWndProc], OFFSET DlgProc
	mov		D[wc.cbClsExtra], NULL
	mov		D[wc.cbWndExtra], DLGWINDOWEXTRA
	mov		eax, [hInstance]
	mov		D[wc.hInstance], eax
	mov		D[wc.hbrBackground], COLOR_BTNFACE + 1
	mov		D[wc.lpszMenuName], NULL
	mov		D[wc.lpszClassName], OFFSET ClassName
	invoke	LoadIcon, NULL, IDI_APPLICATION
	mov		D[wc.hIcon], eax
	mov		D[wc.hIconSm], eax
	invoke	LoadCursor,NULL,IDC_ARROW
	mov		D[wc.hCursor], eax

	invoke	RegisterClassEx, offset wc
	or eax,eax
	jnz >
		; If we were unable to register the class shut down
		invoke	ExitProcess, -1
	:

	invoke	CreateDialogParam, [hInstance],IDD_DLG1, NULL, NULL, NULL
	or eax,eax
	jnz >
		; If we were unable to create the dialog shut down
		invoke	ExitProcess, -1
	:
	mov [hDlg],eax

	invoke ShowWindow,[hDlg],[nCmdShow]

	:
		invoke GetMessage, offset msg,NULL,0,0
		or eax,eax
		jz >
			invoke IsDialogMessage, [hDlg], offset msg
			or eax,eax
			jnz <
				invoke TranslateMessage, offset msg
				invoke DispatchMessage, offset msg
				jmp <
	:

	mov eax,[msg.wParam]

	ret
ENDF

DlgProc FRAME hwnd,uMsg,wParam,lParam

	cmp D[uMsg],WM_CREATE
	jne >.WM_COMMAND
		jmp >.EXIT

	.WM_COMMAND
	cmp D[uMsg],WM_COMMAND
	jne >.WM_DESTROY
		jmp >.EXIT

	.WM_DESTROY
	cmp D[uMsg],WM_DESTROY
	jne >.DEFPROC
		invoke PostQuitMessage,0

	.DEFPROC
		invoke DefWindowProc,[hwnd],[uMsg],[wParam],[lParam]
		ret

	.EXIT

	xor eax,eax
	ret

ENDF
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].h
// Headers available at
// http://www.quickersoft.com/donkey/index.html

// NOTE: INCLUDE Environment variable must be set to headers path

#DEFINE WINVER NTDDI_WIN9XALL
#DEFINE FILTERAPI

#DEFINE LINKFILES
#DEFINE LINKVCRT

#DEFINE CCUSEORDINALS

#include "WINDOWS.H"
#include "Commctrl.h"
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Rc
#define IDD_DLG1 1000
IDD_DLG1 DIALOGEX 6,6,194,106
CAPTION "DIALOG AS MAIN"
FONT 8,"MS Sans Serif"
CLASS "DialogClass"
STYLE 0x10CF0000
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
