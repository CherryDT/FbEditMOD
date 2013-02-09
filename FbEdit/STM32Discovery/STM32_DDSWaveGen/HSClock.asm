
.code

MakeHSCWave proc  uses ebx esi edi, lpWave:DWORD,Duty:DWORD

	mov		edi,lpWave
	.if !Duty
		mov		byte ptr [edi],0
	.elseif Duty==100
		mov		byte ptr [edi],WAVEMAX
	.else
		mov		byte ptr [edi],WAVEMAX/2
	.endif
	inc		edi
	xor		ebx,ebx
	.while ebx<2
		xor		ecx,ecx
		mov		edx,WAVEMAX
		.while ecx<HSCMAX/2-1
			.if ecx==Duty
				xor		edx,edx
			.endif
			mov		[edi+ecx],dl
			inc		ecx
		.endw
		lea		edi,[edi+ecx]
		inc		ebx
	.endw
	.if !Duty
		mov		byte ptr [edi],0
	.elseif Duty==100
		mov		byte ptr [edi],WAVEMAX
	.else
		mov		byte ptr [edi],WAVEMAX/2
	.endif
	ret

MakeHSCWave endp

HSClockSetupProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	tmp:DWORD
	LOCAL	ftmp:QWORD
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		childdialogs.hWndHSClockSetup,eax
		mov		eax,BST_UNCHECKED
		.if hsclockdata.hsclockenable
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKHSCLOCKENABLE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDIV,TBM_SETRANGE,FALSE,(9 SHL 16)+0
		mov		eax,hsclockdata.hsclockdivisor
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDIV,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKH,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hsclockfrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKH,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKL,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hsclockfrequency
		and		eax,255
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKL,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDUTY,TBM_SETRANGE,FALSE,(100 SHL 16)+0
		mov		eax,hsclockdata.hsclockdutycycle
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDUTY,TBM_SETPOS,TRUE,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_CHKHSCLOCKENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKHSCLOCKENABLE
				mov		hsclockdata.hsclockenable,eax
				inc		fCommand
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		mov		fChanged,0
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDIV,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hsclockdivisor
			mov		hsclockdata.hsclockdivisor,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKL,TBM_GETPOS,0,0
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKH,TBM_GETPOS,0,0
		shl		eax,8
		pop		edx
		or		eax,edx
		.if eax!=hsclockdata.hsclockfrequency
			mov		hsclockdata.hsclockfrequency,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKDUTY,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hsclockdutycycle
			mov		hsclockdata.hsclockdutycycle,eax
			mov		fChanged,TRUE
		.endif
		mov		eax,65537
		sub		eax,hsclockdata.hsclockfrequency
		.if eax<100
;			mov		tmp,eax
;			fld		float100
;			fild	tmp
;			fdivp	st(1),st
;			fistp	tmp
;			fild	hsclockdata.hsclockdutycycle
;			fild	tmp
;			fdivp	st(1),st
;			fistp	hsclockdata.hsclockccr
;			fild	hsclockdata.hsclockccr
;			mov		eax,65537
;			sub		eax,hsclockdata.hsclockfrequency
;			mov		tmp,eax
;			fld		float100
;			fild	tmp
;			fdivp	st(1),st
;			fmulp	st(1),st
;			fistp	tmp
;			mov		eax,tmp

			inc		eax
			mov		tmp,eax
			mov		ecx,eax
			mov		eax,100
			xor		edx,edx
			div		ecx
			mov		ecx,eax
			mov		eax,hsclockdata.hsclockdutycycle
			xor		edx,edx
			div		ecx
			.if eax>=tmp
				mov		eax,tmp
				dec		eax
			.endif
			mov		hsclockdata.hsclockccr,eax
			fild	hsclockdata.hsclockccr
			mov		eax,65537
			sub		eax,hsclockdata.hsclockfrequency
			mov		tmp,eax
			fld		float100
			fild	tmp
			fdivp	st(1),st
			fmulp	st(1),st
			fistp	tmp
			mov		eax,tmp
		.else
			mov		ecx,hsclockdata.hsclockdutycycle
			mul		ecx
			mov		ecx,100
			div		ecx
			mov		hsclockdata.hsclockccr,eax
			mov		eax,hsclockdata.hsclockdutycycle
		.endif
		.if fChanged
			invoke MakeHSCWave,addr hsclockdata.HSC_Data,eax
			invoke InvalidateRect,childdialogs.hWndHSClock,NULL,TRUE
			inc		fCommand
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HSClockSetupProc endp

HSClockProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE

	mov		eax,uMsg
	.if	eax==WM_CREATE
		mov		eax,hWin
		mov		childdialogs.hWndHSClock,eax
	.elseif eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke GetStockObject,BLACK_BRUSH
		invoke FillRect,mDC,addr rect,eax
		;Draw horizontal lines
		sub		rect.bottom,TEXTHIGHT
		invoke CreatePen,PS_SOLID,1,0303030h
		invoke SelectObject,mDC,eax
		push	eax
		mov		eax,rect.bottom
		mov		ecx,6
		xor		edx,edx
		div		ecx
		mov		edx,eax
		mov		edi,eax
		xor		ecx,ecx
		.while ecx<5
			push	ecx
			push	edx
			invoke MoveToEx,mDC,0,edi,NULL
			invoke LineTo,mDC,rect.right,edi
			pop		edx
			add		edi,edx
			pop		ecx
			inc		ecx
		.endw
		invoke MoveToEx,mDC,0,rect.bottom,NULL
		invoke LineTo,mDC,rect.right,rect.bottom
		;Draw vertical lines
		mov		eax,rect.right
		mov		ecx,10
		xor		edx,edx
		div		ecx
		mov		edx,eax
		mov		edi,eax
		xor		ecx,ecx
		.while ecx<9
			push	ecx
			push	edx
			invoke MoveToEx,mDC,edi,0,NULL
			invoke LineTo,mDC,edi,rect.bottom
			pop		edx
			add		edi,edx
			pop		ecx
			inc		ecx
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		;Draw curve
		invoke SetTextColor,mDC,00FF00h
		mov		eax,008000h
		invoke CreatePen,PS_SOLID,2,eax
		invoke SelectObject,mDC,eax
		push	eax
		invoke SetBkMode,mDC,TRANSPARENT
		
		mov		esi,offset hsclockdata.HSC_Data
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<HSCMAX
			call	GetPoint
			.if sdword ptr pt.x>=0
				invoke LineTo,mDC,pt.x,pt.y
				mov		eax,pt.x
				.break .if sdword ptr eax>rect.right
			.else
				invoke MoveToEx,mDC,pt.x,pt.y,NULL
			.endif
			inc		edi
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		mov		eax,hsclockdata.hsclockdivisor
		.if !eax
			;Div1
			mov		ecx,1
		.elseif eax==1
			;Div5
			mov		ecx,5
		.elseif eax==2
			;Div10
			mov		ecx,10
		.elseif eax==3
			;Div50
			mov		ecx,50
		.elseif eax==4
			;Div100
			mov		ecx,100
		.elseif eax==5
			;Div500
			mov		ecx,500
		.elseif eax==6
			;Div1000
			mov		ecx,1000
		.elseif eax==7
			;Div5000
			mov		ecx,5000
		.elseif eax==8
			;Div10000
			mov		ecx,10000
		.elseif eax==9
			;Div50000
			mov		ecx,50000
		.endif
		mov		eax,STM32Clock
		cdq
		div		ecx
		cdq
		mov		ecx,65537
		sub		ecx,hsclockdata.hsclockfrequency
		.if ecx==65537
			xor		eax,eax
		.else
			div		ecx
		.endif
		push	eax
		.if eax
			mov		ecx,65537
			sub		ecx,hsclockdata.hsclockfrequency
			mov		eax,ecx
			sub		eax,hsclockdata.hsclockccr
			sub		eax,ecx
			neg		eax
			mov		edx,100
			mul		edx
			div		ecx
		.else
			xor		eax,eax
		.endif
		pop		edx
		push	eax
		invoke FormatFrequency,addr buffer,addr szFmtFrq,edx
		pop		eax
		invoke wsprintf,addr buffer1,addr szFmtDuty,eax
		invoke lstrcat,addr buffer,addr buffer1
		invoke lstrlen,addr buffer
		mov		edx,rect.bottom
		add		edx,8
		invoke TextOut,mDC,0,edx,addr buffer,eax
		add		rect.bottom,TEXTHIGHT
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

GetPoint:
	;Get X position
	mov		eax,edi
	mov		ecx,rect.right
	mul		ecx
	mov		ecx,HSCMAX
	div		ecx
	mov		pt.x,eax
	;Get y position
	movzx	eax,byte ptr [esi+edi]
	sub		eax,WAVEMAX
	neg		eax
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,WAVEMAX
	div		ecx
	add		eax,5
	mov		pt.y,eax
	retn

HSClockProc endp

HSClockChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		hsclockdata.hsclockfrequency,65535-54
		mov		hsclockdata.hsclockdutycycle,50
		mov		hsclockdata.hsclockccr,28
		invoke MakeHSCWave,addr hsclockdata.HSC_Data,hsclockdata.hsclockdutycycle
		invoke CreateDialogParam,hInstance,IDD_HSCLOCKSETUP,hWin,addr HSClockSetupProc,0
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,312
		invoke MoveWindow,childdialogs.hWndHSClock,0,0,rect.right,rect.bottom,TRUE
		sub		rect.bottom,60
		invoke MoveWindow,childdialogs.hWndHSClockSetup,rect.right,0,312,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HSClockChildProc endp

