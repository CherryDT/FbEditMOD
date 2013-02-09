Dialog Application
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
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include [*PROJECTNAME*].inc

.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov	eax,uMsg
	.if	eax==WM_INITDIALOG
		;initialization here
	.elseif	eax==WM_COMMAND
		mov edx,wParam
		movzx eax,dx
		shr edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK

			.elseif eax==IDCANCEL
				invoke	SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWin,0
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
DlgProc endp

end start
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].inc

include		windows.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	Comctl32.lib
includelib	shell32.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_MAIN		equ 101

;#########################################################################

.data?

hInstance		dd		?

;#########################################################################
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].rc
#define IDD_MAIN 101
IDD_MAIN DIALOGEX 6,6,194,106
CAPTION "DialogApp"
FONT 8,"Tahoma",0,0
STYLE 0x10CF0800
EXSTYLE 0x00000000
BEGIN
  CONTROL "OK",1,"Button",0x50010000,144,90,48,13,0x00000000
  CONTROL "Cancel",2,"Button",0x50010000,92,90,48,13,0x00000000
END
[*ENDTXT*]
