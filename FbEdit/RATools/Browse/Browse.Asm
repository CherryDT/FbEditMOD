.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Browse.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke LoadLibrary,addr szRATools
	mov		hLib,eax
    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke FreeLibrary,hLib
	invoke ExitProcess,0

;########################################################################

DlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	dck:DOCKING
	LOCAL	ps:PAINTSTRUCT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_CLIENT
		mov		hClient,eax
		invoke GetDlgItem,hWin,IDC_TOOL
		mov		hTool,eax
		invoke SendMessage,hTool,TLM_INIT,hClient,hWin
		mov		dck.ID,1
		mov		dck.Caption,offset szRATools
		mov		dck.Visible,TRUE
		mov		dck.Docked,TRUE
		mov		dck.Position,TL_RIGHT
		mov		dck.IsChild,FALSE
		mov		dck.dWidth,150
		mov		dck.dHeight,100
		mov		dck.fr.left,0
		mov		dck.fr.top,0
		mov		dck.fr.right,200
		mov		dck.fr.bottom,300
		invoke SendMessage,hTool,TLM_CREATE,0,addr dck
		mov		hTL1,eax
		mov		dck.ID,2
		mov		dck.Caption,offset szRATools
		mov		dck.Visible,TRUE
		mov		dck.Docked,TRUE
		mov		dck.Position,TL_BOTTOM
		mov		dck.IsChild,FALSE
		mov		dck.dWidth,150
		mov		dck.dHeight,100
		mov		dck.fr.left,0
		mov		dck.fr.top,0
		mov		dck.fr.right,200
		mov		dck.fr.bottom,300
		invoke SendMessage,hTool,TLM_CREATE,0,addr dck
		mov		hTL2,eax
		mov		dck.ID,3
		mov		dck.Caption,offset szRATools
		mov		dck.Visible,TRUE
		mov		dck.Docked,TRUE
		mov		dck.Position,TL_LEFT
		mov		dck.IsChild,FALSE
		mov		dck.dWidth,150
		mov		dck.dHeight,100
		mov		dck.fr.left,0
		mov		dck.fr.top,0
		mov		dck.fr.right,200
		mov		dck.fr.bottom,300
		invoke SendMessage,hTool,TLM_CREATE,0,addr dck
		mov		hTL3,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==1002
				invoke SendMessage,hTool,TLM_DOCKING,0,hTL1
			.endif
		.endif
	.elseif eax==WM_NOTIFY
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hTool,TLM_MOUSEMOVE,0,lParam
	.elseif eax==WM_LBUTTONDOWN
		invoke SendMessage,hTool,TLM_LBUTTONDOWN,0,lParam
	.elseif eax==WM_LBUTTONUP
		invoke SendMessage,hTool,TLM_LBUTTONUP,0,lParam
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke SendMessage,hTool,TLM_PAINT,0,0
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_SIZE
		invoke GetDlgItem,hWin,IDC_SBR1
		push	eax
		invoke MoveWindow,eax,0,0,0,0,FALSE
		pop		edx
		invoke GetClientRect,edx,addr rect
		push	rect.bottom
		invoke GetClientRect,hWin,addr rect
		pop		eax
		sub		rect.bottom,eax
		invoke SendMessage,hTool,TLM_SIZE,0,addr rect
	.elseif eax==WM_TOOLSIZE
PrintHex eax
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
