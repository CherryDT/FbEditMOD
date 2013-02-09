option casemap:none

WINVER equ 0500h
WIN32_LEAN_AND_MEAN equ 1

.nolist
.nocref

include WINDOWS.INC

includelib USER32.LIB
includelib KERNEL32.LIB
includelib GDI32.LIB


.data
align 01
szClass			db  'Win64class', 0
szAppName		db	'First Window', 0
szError			db  "Can't run in the windows version",0
szCaption		db	'Error', 0
szOkUntilNow	db	"Ok until now",0
szOk			db "Ok",0

.data?
align 08
hInstance	HINSTANCE ?
lpCmdLine	LPSTR ?

.code
start:
	
	sub rsp,16*4 + 8
	xor rcx, rcx
	call GetModuleHandle
	mov [hInstance], rax
	call GetCommandLine
	mov [lpCmdLine], rax
	mov r9, SW_SHOWDEFAULT
	mov r8, [lpCmdLine]
	mov rdx, NULL
	mov rcx, [hInstance]
	call WinMain
	add rsp, 16 * 4 + 8
	ret

	WinMain proc  hInst:HINSTANCE, hPrev:HINSTANCE, CmdLine:LPSTR, iShow:DWORD
	LOCAL msg:MSG
	LOCAL wcex:WNDCLASSEX
	LOCAL hWnd:HWND
	
	mov [wcex.cbSize], sizeof WNDCLASSEX
	mov [wcex.style], CS_HREDRAW or CS_VREDRAW
	lea rax, [WndProc]
	mov [wcex.lpfnWndProc], rax
	mov [wcex.cbClsExtra], 0
	mov [wcex.cbWndExtra], 0
	mov rax, [hInstance]
	mov [wcex.hInstance], rax
	mov [wcex.hbrBackground], COLOR_WINDOW + 1
	invoke LoadIcon, NULL, IDI_APPLICATION
	mov [wcex.hIcon], rax
	mov [wcex.hIconSm], rax
	invoke LoadCursor, NULL, IDC_ARROW
	mov [wcex.hCursor], rax
	mov [wcex.lpszMenuName], NULL
	lea rax, szClass
	mov [wcex.lpszClassName], rax
	
	invoke RegisterClassEx, addr wcex
	.if rax == 0
		invoke MessageBox, NULL, addr szError, addr szCaption, MB_OK
	.endif
	
	invoke CreateWindowEx, 0, addr szClass, addr szAppName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, [hInstance], NULL
	.if !rax
		invoke MessageBox, NULL, addr szOkUntilNow, addr szOk, MB_OK
	.endif
	mov [hWnd], rax
	
	invoke ShowWindow, [hWnd], SW_SHOWNORMAL
	invoke UpdateWindow, [hWnd]
	
	.while (TRUE)
		invoke GetMessage, addr msg, NULL, 0, 0
		.break .if (!rax)		
		
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
	.endw
	
	mov     rax, msg.wParam
	ret
	WinMain endp
	
	WndProc proc hWin:HWND, uMsg:QWORD, wParam:WPARAM, lParam:LPARAM
				
		mov [lParam], r9
		mov [wParam], r8 
		mov [uMsg], rdx
		mov [hWin], rcx
		
		.if rdx == WM_DESTROY
			invoke PostQuitMessage, NULL
			
		.elseif rdx == WM_CREATE

		.else
			invoke DefWindowProc, rcx, edx, r8, r9
			ret
		.endif
		
		xor rax, rax
		ret

	WndProc endp
end start