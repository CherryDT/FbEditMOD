.386
.model flat,stdcall
option casemap:none

include GridDemoLib1.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
    invoke GridInstall,hInstance
	invoke InitCommonControls
	invoke GetCommandLine
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
	mov		wc.cbWndExtra,NULL
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset ClassName,offset AppName,WS_SIZEBOX or WS_CAPTION or WS_SYSMENU or WS_VISIBLE or WS_CLIPCHILDREN,0,0,500,400,NULL,NULL,hInstance,0
	mov		hWnd,eax
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
	LOCAL	col:COLUMN
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	hWin
		pop		hWnd
		invoke CreateWindowEx,NULL,offset GridClassName,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_HGRIDLINES or STYLE_VGRIDLINES or STYLE_GRIDFRAME,0,0,0,0,hWin,NULL,hInstance,0
		mov		hGrd,eax
		invoke CreateFontIndirect,offset Tahoma_9
		mov		hFont,eax
		invoke SendMessage,hGrd,WM_SETFONT,hFont,FALSE
		call	Setup
		call	AddData
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hGrd,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		invoke DeleteObject,hFont
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

Setup:
	;Add Name column
	mov		col.colwt,150
	mov		col.lpszhdrtext,offset szName
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_LEFT
	mov		col.ctype,TYPE_EDITTEXT
	mov		col.ctextmax,31
	mov		col.lpszformat,0
	mov		col.himl,0
	mov		col.hdrflag,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Add Address column
	mov		col.colwt,150
	mov		col.lpszhdrtext,offset szAddress
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_LEFT
	mov		col.ctype,TYPE_EDITTEXT
	mov		col.ctextmax,31
	mov		col.lpszformat,0
	mov		col.himl,0
	mov		col.hdrflag,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Add Points column
	mov		col.colwt,50
	mov		col.lpszhdrtext,offset szPoints
	mov		col.halign,GA_ALIGN_RIGHT
	mov		col.calign,GA_ALIGN_RIGHT
	mov		col.ctype,TYPE_EDITLONG
	mov		col.ctextmax,4
	mov		col.lpszformat,0
	mov		col.himl,0
	mov		col.hdrflag,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Button column
	mov		col.colwt,60
	mov		col.lpszhdrtext,offset szButton
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_LEFT
	mov		col.ctype,TYPE_BUTTON
	mov		col.ctextmax,MAX_PATH
	mov		col.lpszformat,0
	mov		col.himl,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Button column
	mov		col.colwt,60
	mov		col.lpszhdrtext,offset szButton
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_LEFT
	mov		col.ctype,TYPE_BUTTON
	mov		col.ctextmax,MAX_PATH
	mov		col.lpszformat,0
	mov		col.himl,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
	retn

AddData:
	;Add some rows
	push	esi
	mov		esi,offset rdta
	mov		ecx,4
	.while ecx
		push	ecx
		invoke SendMessage,hGrd,GM_ADDROW,0,esi
		pop		ecx
		add		esi,sizeof rdta
		dec		ecx
	.endw
	pop		esi
	invoke SendMessage,hGrd,GM_SETCURSEL,0,0
	invoke SetFocus,hGrd
	retn

WndProc endp

end start
