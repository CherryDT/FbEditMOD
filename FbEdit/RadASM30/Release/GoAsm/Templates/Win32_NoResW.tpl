Window App, No resource, Unicode
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=goasm
Group=2,-1,0,1,UNICODE Win32 No Res,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].Asm
F2=-3,0,1,22,22,600,400,0,[*PROJECTNAME*].h
[Make]
Make=0
0=Win32 Unicode Release,'/r "$R"',"$R.res",'/c /x86 /d UNICODE "$C"',"$C.obj",'$C $M $R',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
;##################################################################
; [*PROJECTNAME*]
;##################################################################

STRINGS UNICODE

#include [*PROJECTNAME*].h

DATA SECTION
	ClassName			DUS "MainWinClass",0
	AppName				DUS "Main Window",0
	ALIGN 4
	hInstance			HANDLE ?
	CommandLine			HANDLE ?

CODE SECTION

START:

	invoke GetModuleHandle, NULL
	mov [hInstance],eax
	invoke GetCommandLine
	mov [CommandLine],eax
	invoke InitCommonControls
	invoke WinMain,[hInstance],NULL,[CommandLine],SW_SHOWNORMAL
	invoke ExitProcess,eax

WinMain FRAME hInst,hPrevInst,CmdLine,CmdShow
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:%HANDLE

	mov D[wc.cbSize],SIZEOF WNDCLASSEX
	mov D[wc.style], CS_HREDRAW + CS_VREDRAW
	mov [wc.lpfnWndProc], OFFSET WndProc
	mov D[wc.cbClsExtra],NULL
	mov D[wc.cbWndExtra],NULL
	push [hInstance]
	pop [wc.hInstance]
	mov D[wc.hbrBackground],COLOR_BTNFACE+1
	mov D[wc.lpszMenuName],NULL
	mov [wc.lpszClassName],OFFSET ClassName
	
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov [wc.hIcon],eax
	mov [wc.hIconSm],eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov [wc.hCursor],eax
	
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
			WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
			CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
			[hInst],NULL

	mov [hwnd],eax

	invoke ShowWindow, [hwnd],[CmdShow]
	invoke UpdateWindow, [hwnd]

	.messloop
		invoke GetMessage, ADDR msg,0,0,0
		or eax,eax
		JZ >.quit
			invoke TranslateMessage, ADDR msg
			invoke DispatchMessage, ADDR msg
	JMP .messloop
	.quit

	mov eax,[msg.wParam]
	ret
ENDF

WndProc FRAME hwnd, uMsg, wParam, lParam

	cmp D[uMsg],WM_CREATE
	jne >.WM_COMMAND
		jmp >>.EXIT

	.WM_COMMAND
	cmp D[uMsg],WM_COMMAND
	jne >.WM_CLOSE
		jmp >>.EXIT

	.WM_CLOSE
	cmp D[uMsg],WM_CLOSE
	jne >.WM_DESTROY
		invoke DestroyWindow,[hwnd]
		jmp >>.EXIT

	.WM_DESTROY
	cmp D[uMsg],WM_DESTROY
	jne >.DEFPROC
		invoke PostQuitMessage,NULL
		jmp >>.DEFPROC

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

#DEFINE WINVER NTDDI_WINXP
#DEFINE FILTERAPI

#DEFINE LINKFILES
#DEFINE LINKVCRT
#DEFINE CCUSEORDINALS

#include "WINDOWS.H"
#include "Commctrl.h"
[*ENDTXT*]
