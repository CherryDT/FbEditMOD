Dialog As Main Window
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=jwasm
Group=2,-1,0,1,[*PROJECTNAME*],-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].asm
F2=-3,0,1,44,44,600,400,0,[*PROJECTNAME*].inc
F3=-5,2,4,66,66,600,400,0,[*PROJECTNAME*].rc
[Make]
Make=0
0=Window Release,'/v "$R"',"$R.res",'/c /coff /Cp "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
1=Window Debug,'/v "$R"',"$R.res",'/c /coff /Cp /Zi /Zd "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].asm
.386
.model flat,stdcall
option casemap:none

include [*PROJECTNAME*].inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.endif
;	.elseif eax==WM_SIZE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

end start
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].inc
include windows.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

IDD_DIALOG			equ 1000

IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10101

.const

ClassName			db 'DLGCLASS',0
AppName				db 'Dialog as main',0
AboutMsg			db 'jWasm RadASM Dialog as main',13,10,'Copyright © MASM32 2001',0

.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].rc
#define IDD_DIALOG 1000
#define IDM_MENU 10000
#define IDM_FILE_EXIT 10001
#define IDM_HELP_ABOUT 10101
IDD_DIALOG DIALOGEX 6,6,194,106
CAPTION "Dialog As Main"
FONT 8,"MS Sans Serif"
CLASS "DLGCLASS"
STYLE 0x10CF0800
EXSTYLE 0x00000000
BEGIN
END
IDM_MENU MENUEX
BEGIN
  POPUP "&File",,,
  BEGIN
    MENUITEM "E&xit",IDM_FILE_EXIT,,
  END
  POPUP "&Help",,,
  BEGIN
    MENUITEM "&About",IDM_HELP_ABOUT,,
  END
END
[*ENDTXT*]
