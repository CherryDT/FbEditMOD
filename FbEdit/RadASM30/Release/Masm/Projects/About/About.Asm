
.386
.model flat, stdcall  ;32 bit memory model eax
option casemap :none  ;case sensitive eax

include About.inc

.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	mys:MYSTRUCT

	mov		eax,uMsg
	.IF	eax==WM_INITDIALOG
		mov		eax,mys.rc.left
		mov		eax,ms.rc.right
		lea		eax,mys
		mov		eax,[eax].MYSTRUCT.rc.left
		lea		eax,mys
		mov		eax,(MYSTRUCT ptr [eax]).rc.top

		assume	edx:ptr MYSTRUCT
		lea		edx,mys
		mov		eax,[edx].rc.left
		assume	edx:nothing
		;initialization here
	.ELSEIF	eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.IF edx==BN_CLICKED
			.IF eax==IDOK

			.ELSEIF eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.ENDIF
		.ENDIF
	.ELSEIF	eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.ELSE
		mov		eax,FALSE
		ret
	.ENDIF
	mov		eax,TRUE
	ret

DlgProc endp

end start

