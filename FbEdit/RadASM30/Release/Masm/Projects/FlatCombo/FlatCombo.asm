.386
.model flat,stdcall
option casemap:none

include FlatCombo.inc

.code

CboProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	ps:PAINTSTRUCT

	mov		eax,uMsg
	.if eax==WM_NCPAINT
		invoke BeginPaint,hWin,addr ps
		invoke GetClientRect,hWin,addr rect
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,ps.hdc,addr rect,eax
		inc		rect.left
		inc		rect.top
		dec		rect.right
		dec		rect.bottom
		invoke GetStockObject,WHITE_BRUSH
		invoke FrameRect,ps.hdc,addr rect,eax
		invoke EndPaint,hWin,addr ps
		inc		rect.left
		inc		rect.top
		dec		rect.right
		dec		rect.bottom
		invoke InvalidateRect,hWin,addr rect,FALSE
	.endif
	invoke CallWindowProc,lpOldCboProc,hWin,uMsg,wParam,lParam
	ret

CboProc endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke GetDlgItem,hWin,IDC_CBO2
		mov		hCbo,eax
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_ADDSTRING,0,addr szTest
		invoke SendMessage,hCbo,CB_SETCURSEL,0,0
		invoke SetWindowLong,hCbo,GWL_WNDPROC,offset CboProc
		mov		lpOldCboProc,eax
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
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset ClassName
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
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

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

end start
