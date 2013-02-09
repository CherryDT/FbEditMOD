
.code

FormatFrequency proc uses edi,lpBuff:DWORD,lpszFrequency:DWORD,Frequency:DWORD

	mov		eax,Frequency
	mov		edi,lpBuff
	.if eax<1000
		;Hz
		invoke wsprintf,edi,addr szFmtFrqHz,lpszFrequency,eax
	.elseif eax<1000000
		;KHz
		invoke wsprintf,edi,addr szFmtFrqKHz,lpszFrequency,eax
		invoke lstrlen,edi
		mov		edx,[edi+eax-3]
		mov		[edi+eax-2],edx
		mov		edx,[edi+eax-7]
		mov		[edi+eax-6],edx
		mov		byte ptr [edi+eax-6],'.'
	.else
		;MHz
		invoke wsprintf,edi,addr szFmtFrqMHz,lpszFrequency,eax
		invoke lstrlen,edi
		mov		edx,[edi+eax-3]
		mov		[edi+eax-2],edx
		mov		edx,[edi+eax-7]
		mov		[edi+eax-6],edx
		mov		edx,[edi+eax-10]
		mov		[edi+eax-9],edx
		mov		byte ptr [edi+eax-9],'.'
	.endif
	ret

FormatFrequency endp

FormatFrequencyX1000 proc uses edi,lpBuff:DWORD,lpszFrequency:DWORD,Frequency:DWORD

	mov		eax,Frequency
	mov		edi,lpBuff
	.if eax<1000000
		;Hz
		invoke wsprintf,edi,addr szFmtFrqHzX1000,lpszFrequency,eax
		invoke lstrlen,edi
		mov		edx,[edi+eax-2]
		mov		[edi+eax-1],edx
		mov		edx,[edi+eax-6]
		mov		[edi+eax-5],edx
		mov		byte ptr [edi+eax-5],'.'
	.elseif eax<1000000000
		;KHz
		invoke wsprintf,edi,addr szFmtFrqKHz,lpszFrequency,eax
		invoke lstrlen,edi
		mov		edx,[edi+eax-3]
		mov		[edi+eax-2],edx
		mov		edx,[edi+eax-7]
		mov		[edi+eax-6],edx
		mov		edx,[edi+eax-10]
		mov		[edi+eax-9],edx
		mov		byte ptr [edi+eax-9],'.'
	.else
		;MHz
		invoke wsprintf,edi,addr szFmtFrqMHz,lpszFrequency,eax
		invoke lstrlen,edi
		mov		edx,[edi+eax-3]
		mov		[edi+eax-2],edx
		mov		edx,[edi+eax-7]
		mov		[edi+eax-6],edx
		mov		edx,[edi+eax-11]
		mov		[edi+eax-10],edx
		mov		edx,[edi+eax-13]
		mov		[edi+eax-12],edx
		mov		byte ptr [edi+eax-12],'.'
	.endif
	ret

FormatFrequencyX1000 endp

FormatVoltage proc uses edi,lpBuff:DWORD,lpFmt:DWORD,Volts:DWORD

	mov		edi,lpBuff
	invoke wsprintf,edi,lpFmt,Volts
	invoke lstrlen,edi
	mov		edx,[edi+eax-4]
	mov		[edi+eax-3],edx
	mov		byte ptr [edi+eax+1],0
	mov		byte ptr [edi+eax-4],'.'
	ret

FormatVoltage endp

TextProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[32]:BYTE
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke SendMessage,hWin,WM_GETTEXT,sizeof buffer,addr buffer		
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke CreateSolidBrush,0C0FFFFh
		push	eax
		invoke FillRect,mDC,addr rect,eax
		pop		eax
		invoke DeleteObject,eax
		invoke SetBkMode,mDC,TRANSPARENT
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==IDC_UDCFREQUENCY
			mov		ebx,offset szFrequency
		.elseif eax==IDC_UDCVOLTSDVM
			mov		ebx,offset szVoltsDVM
		.endif
		invoke lstrlen,ebx
		mov		edx,eax
		sub		rect.right,10
		invoke DrawText,mDC,ebx,edx,addr rect,DT_RIGHT or DT_TOP or DT_SINGLELINE
		invoke SelectObject,mDC,hFont
		push	eax
		add		rect.top,15
		invoke lstrlen,addr buffer
		mov		edx,eax
		invoke DrawText,mDC,addr buffer,edx,addr rect,DT_RIGHT or DT_VCENTER or DT_SINGLELINE
		add		rect.right,15
		pop		eax
		invoke SelectObject,mDC,eax
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_SETTEXT
		invoke InvalidateRect,hWin,NULL,TRUE
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

TextProc endp

FrequencyChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke CheckDlgButton,hWin,IDC_CHKFRQCOUNT,BST_CHECKED
		mov		ddswavedata.FRQ_Enable,TRUE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_CHKFRQCOUNT
				invoke IsDlgButtonChecked,hWin,IDC_CHKFRQCOUNT
				mov		ddswavedata.FRQ_Enable,eax
				inc		fCommand
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

FrequencyChildProc endp

