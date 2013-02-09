.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Module.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==1001
				invoke Module1,hWin
			.elseif eax==1002
				invoke Module2,hWin
			.elseif eax==1003
				invoke Module3,hWin
			.elseif eax==1004
				invoke Module4,hWin
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
		mov		eax,rect.left
		lea		eax,rect
		mov		[eax].RECT.left,1
		mov		eax,[eax].RECT.left
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
