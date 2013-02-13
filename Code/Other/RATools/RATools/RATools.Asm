.386
.model flat,stdcall
option casemap:none

include windows.inc
include ..\RATools.inc
include Data.inc
include Tools.asm

.code

InstallRATools proc public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	invoke RtlZeroMemory,addr wc,sizeof WNDCLASSEX
	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS or CS_DBLCLKS
	.endif
	mov		wc.lpfnWndProc,offset ToolsControlProc
	mov		eax,hInst
	mov		hInstance,eax
	mov		wc.hInstance,eax
	mov		eax,NULL
	mov		wc.cbClsExtra,eax
	mov		wc.cbWndExtra,4
	mov		wc.hbrBackground,COLOR_BTNFACE+1;eax
	mov		wc.lpszMenuName,eax
	mov		wc.lpszClassName,offset szToolClassName
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	;Tool floating windows
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset ToolWndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	mov		eax,hInst
	mov		wc.hInstance,eax
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szToolClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	;Tool child windows
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset ToolCldProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	mov		eax,hInst
	mov		wc.hInstance,eax
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szToolCldClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke LoadCursor,hInst,IDC_SPLICURV
	mov		hSplitCurV,eax
	invoke LoadCursor,hInst,IDC_SPLICURH
	mov		hSplitCurH,eax
	mov		fRightCaption,TRUE
	ret

InstallRATools endp

UnInstallRATools proc public

	ret

UnInstallRATools endp

;--------------------------------------------------------------------------------

ToolsControlProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hTL:HWND

	mov		eax,uMsg
	.if eax==WM_CREATE
		jmp		ExDef
	.elseif eax==WM_DESTROY
		invoke DestroyWindow,hSize
		jmp		ExDef
	.elseif eax==TLM_INIT
		mov		eax,wParam
		mov		hClient,eax
		mov		eax,lParam
		mov		hWnd,eax
		invoke ToolMessage,0,TLM_INIT,0
		invoke CreateWindowEx,WS_EX_TOPMOST,addr szStatic,0,WS_POPUP or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,hWnd,0,hInstance,0
		mov		hSize,eax
		xor		eax,eax
	.elseif eax==TLM_CREATE
		invoke CreateWindowEx,0,addr szToolCldClass,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,hWnd,0,hInstance,0
		mov		hTL,eax
	    invoke ToolMessage,hTL,TLM_CREATE,lParam
    	mov     eax,hTL
	.elseif eax==TLM_DOCKING
	    invoke ToolMessage,lParam,TLM_DOCKING,0
		xor		eax,eax
	.elseif eax==TLM_HIDE
	    invoke ToolMessage,lParam,TLM_HIDE,0
		xor		eax,eax
	.elseif eax==TLM_MOUSEMOVE
	    invoke ToolMessage,0,TLM_MOUSEMOVE,lParam
		xor		eax,eax
	.elseif eax==TLM_LBUTTONDOWN
	    invoke ToolMessage,0,TLM_LBUTTONDOWN,lParam
		xor		eax,eax
	.elseif eax==TLM_LBUTTONUP
	    invoke ToolMessage,0,TLM_LBUTTONUP,lParam
		xor		eax,eax
	.elseif eax==TLM_PAINT
		invoke ToolMessage,0,TLM_PAINT,0
		xor		eax,eax
	.elseif eax==TLM_SIZE
		invoke CopyRect,offset mdirect,lParam
		invoke ToolMessage,0,TLM_SIZE,lParam
		xor		eax,eax
	.elseif eax==TLM_CAPTION
		invoke ToolMsgAll,TLM_CAPTION,0,0
		xor		eax,eax
	.elseif eax==TLM_GETVISIBLE
		invoke ToolMsg,lParam,TLM_GETVISIBLE,0
	.elseif eax==TLM_GETSTRUCT
		invoke ToolMsg,lParam,TLM_GETSTRUCT,0
	.elseif eax==TLM_GETDOCKED
		invoke ToolMsg,lParam,TLM_GETDOCKED,0
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
  Ex:
	ret

ToolsControlProc endp


IFDEF DLL
	include RAToolsDll.asm
ENDIF

end
