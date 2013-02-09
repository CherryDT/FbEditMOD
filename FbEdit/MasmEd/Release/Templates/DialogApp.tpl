Dialog Application
[*MAKE*]=0
[*BEGINTXT*]
[*PROJECTNAME*].Asm
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
[*PROJECTNAME*].Inc

include		windows.inc
include		kernel32.inc
include		user32.inc
include		Comctl32.inc
include		shell32.inc

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
[*PROJECTNAME*].Rc
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
