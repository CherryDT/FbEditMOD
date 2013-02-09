
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

ByteToBin proc uses edi,lpBuff:DWORD,nByte:DWORD

	mov		edi,lpBuff
	mov		eax,nByte
	xor		ecx,ecx
	.while ecx<8
		shl		al,1
		.if CARRY?
			mov		ah,'1'
		.else
			mov		ah,'0'
		.endif
		mov		[edi+ecx],ah
		inc		ecx
	.endw
	mov		byte ptr [edi+ecx],0
	ret

ByteToBin endp

SetFrequencyAndDVM proc uses ebx
	LOCAL	buffer[32]:BYTE
	LOCAL	tmp:DWORD

	fld		scopedata.scopeCHAdata.frequency
	fistp	tmp
	invoke FormatFrequency,addr buffer,addr szNULL,tmp
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCFREQUENCYCHA,addr buffer
	fld		scopedata.scopeCHBdata.frequency
	fistp	tmp
	invoke FormatFrequency,addr buffer,addr szNULL,tmp
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCFREQUENCYCHB,addr buffer
	movzx	eax,scopedata.scopeCHAdata.frq_data.DVM
	mov		ecx,DVMAMUL
	mul		ecx
	mov		ecx,DVMMAX
	div		ecx
	invoke FormatVoltage,addr buffer,addr szFmtVolts,eax
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCVOLTSDVMA,addr buffer
	movzx	eax,scopedata.scopeCHBdata.frq_data.DVM
	mov		ecx,DVMBMUL
	mul		ecx
	mov		ecx,DVMMAX
	div		ecx
	invoke FormatVoltage,addr buffer,addr szFmtVolts,eax
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCVOLTSDVMB,addr buffer
	ret

SetFrequencyAndDVM endp

GetFrequency proc uses ebx esi edi,hWin:HWND
	LOCAL	ncount:DWORD
	LOCAL	samplesize:DWORD

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		ebx,eax
	movzx	eax,scopedata.ADC_CommandStruct.STM32_DataBlocks
	mov		ecx,STM32_BlockSize
	mul		ecx
	dec		eax
	mov		samplesize,eax
	movzx	edi,[ebx].SCOPECHDATA.ADC_TriggerValue
	lea		esi,[ebx].SCOPECHDATA.ADC_Data
	fldz
	fstp	[ebx].SCOPECHDATA.period
	xor		ecx,ecx
	mov		ncount,ecx
	mov		[ebx].SCOPECHDATA.nstart,ecx
	mov		[ebx].SCOPECHDATA.nend,ecx
	mov		[ebx].SCOPECHDATA.nperiods,ecx
	mov		[ebx].SCOPECHDATA.nsamples,ecx
	;Count number of rising edges
	.while ecx<samplesize
		movzx	eax,byte ptr [esi+ecx]
		movzx	edx,byte ptr [esi+ecx+BYTE]
		.if eax<=edi && edx>edi
			.if !ncount
				mov		[ebx].SCOPECHDATA.nstart,ecx
			.endif
			mov		[ebx].SCOPECHDATA.nend,ecx
			inc		ncount
			add		ecx,1
		.endif
		inc		ecx
	.endw
	mov		ecx,ncount
	.if ecx>1
		;Calculate period
		dec		ecx
		mov		[ebx].SCOPECHDATA.nperiods,ecx
		mov		eax,[ebx].SCOPECHDATA.nend
		sub		eax,[ebx].SCOPECHDATA.nstart
		mov		[ebx].SCOPECHDATA.nsamples,eax
		fld		nsinasec
		fld		[ebx].SCOPECHDATA.convperiod
		fild	[ebx].SCOPECHDATA.nsamples
		fmulp	st(1),st
		fild	[ebx].SCOPECHDATA.nperiods
		fdivp	st(1),st
		fst		[ebx].SCOPECHDATA.period
		fdivp	st(1),st
		fst		[ebx].SCOPECHDATA.frequency
		fistp	[ebx].SCOPECHDATA.frq_data.Frequency
	.endif
	ret

GetFrequency endp

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
		.if eax==IDC_UDCFREQUENCYCHA
			mov		ebx,offset szFrequencyCHA
		.elseif eax==IDC_UDCFREQUENCYCHB
			mov		ebx,offset szFrequencyCHB
		.elseif eax==IDC_UDCVOLTSDVMA
			mov		ebx,offset szVoltsDVMA
		.else
			mov		ebx,offset szVoltsDVMB
		.endif
		invoke lstrlen,ebx
		mov		edx,eax
		sub		rect.right,15
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
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

FrequencyChildProc endp

