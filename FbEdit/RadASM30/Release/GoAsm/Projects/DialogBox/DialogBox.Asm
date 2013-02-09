;##################################################################
; DIALOGAPP
;##################################################################

#include "DialogBox.Inc"

.DATA
	hInst				DD 	0
	mys					MYSTRUCT <>
	frect				RECT <>

;##################################################################

.CODE

Start:
	INVOKE GetModuleHandle, 0
	MOV [hInst],EAX
	INVOKE DialogBoxParam,[hInst],1000,0,ADDR DlgProc,0
	INVOKE ExitProcess,0

DlgProc FRAME hwnd,uMsg,wParam,lParam

	MOV EAX,[uMsg]
	.WMINITDIALOG
		CMP EAX,WM_INITDIALOG
		JNE >.WMCOMMAND
		JMP >.EXIT
	.WMCOMMAND
		CMP EAX,WM_COMMAND
		JNE >.WMCLOSE
		MOV EAX,[wParam]
		CMP EAX,1001
		JNE >.EXIT
		INVOKE ModuleProc,[hwnd]
		JMP >.EXIT

	.WMCLOSE
		CMP EAX,WM_CLOSE
		JNE >.DEFPROC
		INVOKE EndDialog,[hwnd],0

	.DEFPROC
		mov EAX,FALSE
		RET

	.EXIT

	MOV EAX, TRUE
	RET
DlgProc ENDF
