IDD_DLGABOUT	equ 4900
IDC_EDTABOUT	equ 1001
IDC_URL1		equ 1002
IDC_URL2		equ 1003

.data?

OldUrlProc		dd ?
fMouseOver		dd ?
hUrlFont		dd ?
hUrlFontU		dd ?
hUrlBrush		dd ?

.code

UrlProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[128]:BYTE

	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE
		invoke LoadCursor,NULL,IDC_HAND
		invoke SetCursor,eax
		invoke GetClientRect,hWin,addr rect
		invoke GetCapture
		.if eax!=hWin
			mov		fMouseOver,TRUE
			invoke SetCapture,hWin
			invoke SendMessage,hWin,WM_SETFONT,hUrlFontU,TRUE
		.endif
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		.if eax>rect.right || edx>rect.bottom
			mov		fMouseOver,FALSE
			invoke ReleaseCapture
			invoke SendMessage,hWin,WM_SETFONT,hUrlFont,TRUE
		.endif
	.elseif eax==WM_LBUTTONUP
		mov		fMouseOver,FALSE
		invoke ReleaseCapture
		invoke SendMessage,hWin,WM_SETFONT,hUrlFont,TRUE
		invoke GetWindowText,hWin,addr buffer,sizeof buffer
		invoke ShellExecute,hWnd,addr szOpen,addr buffer,NULL,NULL,SW_SHOWNORMAL
	.endif
	invoke CallWindowProc,OldUrlProc,hWin,uMsg,wParam,lParam
	ret

UrlProc endp

AboutProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	lf:LOGFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetWindowText,hWin,addr szAppName
		invoke SendDlgItemMessage,hWin,IDC_EDTABOUT,WM_SETTEXT,0,addr szAboutMsg
		invoke SendDlgItemMessage,hWin,IDC_URL1,WM_SETTEXT,0,addr szAboutUrl1
		invoke SendDlgItemMessage,hWin,IDC_URL2,WM_SETTEXT,0,addr szAboutUrl2
		invoke GetDlgItem,hWin,IDC_URL1
		invoke SetWindowLong,eax,GWL_WNDPROC,addr UrlProc
		mov		OldUrlProc,eax
		invoke GetDlgItem,hWin,IDC_URL2
		invoke SetWindowLong,eax,GWL_WNDPROC,addr UrlProc
		invoke SendMessage,hWin,WM_GETFONT,0,0
		mov		hUrlFont,eax
		invoke GetObject,hUrlFont,sizeof LOGFONT,addr lf
		mov	lf.lfUnderline, TRUE
		invoke CreateFontIndirect,addr lf
		mov		hUrlFontU,eax
		invoke GetSysColor,COLOR_3DFACE
		invoke CreateSolidBrush,eax
		mov		hUrlBrush,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetDlgItem,hWin,IDC_URL1
		push	eax
		invoke GetDlgItem,hWin,IDC_URL2
		pop		edx
		mov		ecx,eax
		xor		eax,eax
		.if edx==lParam || ecx==lParam
			.if fMouseOver
				mov		eax,0FF0000h
			.endif
			invoke SetTextColor,wParam,eax
			invoke SetBkMode,wParam,TRANSPARENT
			mov		eax,hUrlBrush
		.endif
		ret
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hUrlFontU
		invoke DeleteObject,hUrlBrush
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

AboutProc endp
