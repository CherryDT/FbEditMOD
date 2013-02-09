Custom control, ANSI
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=goasm
Group=2,-1,0,1,ANSI Custom control,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,0,1,22,22,600,400,0,[*PROJECTNAME*].Asm
F2=-3,0,1,22,22,600,400,0,[*PROJECTNAME*].h
F3=-5,2,4,22,22,600,400,0,[*PROJECTNAME*].Rc
[Make]
Make=0
0=Win32 ANSI Release,'/r "$R"',"$R.res",'/c /x86 "$C"',"$C.obj",'$C $M $R',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
;##################################################################
; [*PROJECTNAME*]
;##################################################################

#include [*PROJECTNAME*].h

IDD_DLG1	equ		1000

DATA SECTION
	hInstance	HANDLE 		?
	icc	 		DQ		3FFF00000008h
	UDC_Class	db		"UDC_ControlClass",0

CODE SECTION

START:
	invoke GetModuleHandle, 0
	mov [hInstance],eax
	invoke InitCommonControlsEx,OFFSET icc
	call InitClass
	invoke DialogBoxParam,[hInstance],IDD_DLG1,0,ADDR DlgProc,0
	invoke ExitProcess,0

DlgProc FRAME hwnd,uMsg,wParam,lParam

	cmp D[uMsg],WM_INITDIALOG
	jne >.WM_COMMAND

		jmp >.EXIT

	.WM_COMMAND
	cmp D[uMsg],WM_COMMAND
	jne >.WM_CLOSE
		jmp >.EXIT

	.WM_CLOSE
	cmp D[uMsg],WM_CLOSE
	jne >.DEFPROC
		INVOKE EndDialog,[hwnd],0

	.DEFPROC
		mov eax,FALSE
		ret

	.EXIT

	mov eax, TRUE
	ret
ENDF

InitClass FRAME
	LOCAL cc_wcx			:WNDCLASSEX

	mov D[cc_wcx.cbSize],SIZEOF WNDCLASSEX
	mov D[cc_wcx.style], CS_HREDRAW + CS_VREDRAW
	mov eax,[hInstance]
	mov D[cc_wcx.hInstance],eax
	mov D[cc_wcx.lpszClassName],OFFSET UDC_Class
	mov D[cc_wcx.cbClsExtra],0
	mov D[cc_wcx.cbWndExtra],32
	mov D[cc_wcx.lpfnWndProc],OFFSET _CCProc
	mov D[cc_wcx.hIcon],NULL
	mov D[cc_wcx.hIconSm],NULL
	mov D[cc_wcx.hbrBackground],COLOR_WINDOW+1
	mov D[cc_wcx.lpszMenuName],NULL

	invoke LoadCursor,NULL,IDC_ARROW
	mov [cc_wcx.hCursor],eax

	invoke RegisterClassEx,ADDR cc_wcx

	ret

ENDF

_CCProc FRAME hwnd,uMsg,wParam,lParam

	cmp D[uMsg],WM_CREATE
	jne >.WM_DESTROY
		
		jmp >.EXIT

	.WM_DESTROY
	cmp D[uMsg],WM_DESTROY
	jne >.DEFPROC
		
		jmp >.EXIT

	.DEFPROC
		invoke DefWindowProc,[hwnd],[uMsg],[wParam],[lParam]
		ret

	.EXIT
	xor eax,eax
	RET
ENDF
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].h
// Headers available at
// http://www.quickersoft.com/donkey/index.html

// NOTE: INCLUDE Environment variable must be set to headers path

#DEFINE WINVER NTDDI_WINXP
#DEFINE IUNKNOWN_DEFINED

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
CAPTION "IDD_DLG"
FONT 8,"MS Sans Serif",0,0
STYLE 0x10CF0000
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
