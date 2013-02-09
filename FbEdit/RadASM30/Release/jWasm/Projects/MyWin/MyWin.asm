.686
.XMM
.model flat,stdcall
option casemap:none
include windows.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

.data?
   hInstance HINSTANCE ?
   CommandLine LPSTR ?
   
.data
   ClassName	TCHAR "MainWinClass",0
   AppName		TCHAR "FirstWindow",0

.code

; ---------------------------------------------------------------------------

start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	
	invoke GetCommandLine
	mov    CommandLine,eax
	
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,0
	mov   wc.cbWndExtra,0
	push  hInstance
	pop   wc.hInstance
	invoke GetStockObject,WHITE_BRUSH
	mov   wc.hbrBackground,EAX
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName	
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	
	invoke RegisterClassEx, addr wc
	
	invoke CreateWindowEx,
		   NULL,
		   ADDR ClassName,
		   ADDR AppName,
           WS_OVERLAPPEDWINDOW,
           CW_USEDEFAULT,
           CW_USEDEFAULT,
           CW_USEDEFAULT,
           CW_USEDEFAULT,
           NULL,
           NULL,
           hInst,
           NULL
	
	mov   hwnd,eax
	
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	
	.while TRUE 
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

LOCAL hdc:HDC
LOCAL ps:PAINTSTRUCT

	.if uMsg==WM_DESTROY
		invoke PostQuitMessage,0
	
	.elseif uMsg==WM_CREATE

	.elseif uMsg == WM_PAINT
		invoke BeginPaint, [hWnd], addr ps
		mov  [hdc], EAX
		invoke EndPaint, [hWnd],addr ps	

	.elseif uMsg == WM_SIZE
		
	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam		
		ret
	.endif
	
	xor eax,eax
	ret
WndProc endp


end start
