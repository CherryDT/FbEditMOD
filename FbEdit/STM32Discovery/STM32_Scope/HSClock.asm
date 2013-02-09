
.code

MakeHSCWave proc  uses ebx esi edi, lpWave:DWORD,Duty:DWORD

	mov		edi,lpWave
	.if !Duty
		mov		byte ptr [edi],0
	.elseif Duty==100
		mov		byte ptr [edi],ADCMAX
	.else
		mov		byte ptr [edi],ADCMAX/2
	.endif
	inc		edi
	xor		ebx,ebx
	.while ebx<2
		xor		ecx,ecx
		mov		edx,ADCMAX
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
		mov		byte ptr [edi],ADCMAX
	.else
		mov		byte ptr [edi],ADCMAX/2
	.endif
	ret

MakeHSCWave endp

SetTIM16 proc uses ebx esi edi,fenable:DWORD,clockdiv:DWORD,frequency:DWORD,Duty:DWORD
	;TIM16 Base 	0x40014400
	;TIM16_CR1		0x40014400			Bit 0 CEN: Counter enable
	;TIM16_CR2		0x40014404
	;TIM16_DIER		0x4001440C
	;TIM16_SR		0x40014410
	;TIM16_EGR		0x40014414
	;TIM16_CCMR1	0x40014418			Bits 6:4 OC1M: 110: PWM mode 1 - In upcounting, channel 1 is active as long as TIMx_CNT<TIMx_CCR1 else inactive. In downcounting, channel 1 is inactive (OC1REF=‘0’) as long as TIMx_CNT>TIMx_CCR1 else active (OC1REF=’1’).
	;									Bits 1:0 CC1S: 00: CC1 channel is configured as output. Capture/Compare 1 selection. This bit-field defines the direction of the channel (input/output) as well as the used input.
	;TIM16_CCER		0x40014420
	;TIM16_CNT		0x40014424
	;TIM16_PSC		0x40014428
	;TIM16_ARR		0x4001442C
	;TIM16_RCR		0x40014430
	;TIM16_CCR1		0x40014434
	;TIM16_BDTR		0x40014444
	;TIM16_DCR		0x40014448
	;TIM16_DMAR		0x4001444C

	.if hsclockdata.hscCHAData.hsclockenable
		mov		edi,offset rwdata.RW_CommandStruct
		;TIM16_CR1
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014400h
		mov		eax,fenable
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM16_PSC
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014428h
		mov		eax,clockdiv
		.if eax==1
			;Div5
			mov		eax,4
		.elseif eax==2
			;Div10
			mov		eax,9
		.elseif eax==3
			;Div50
			mov		eax,49
		.elseif eax==4
			;Div100
			mov		eax,99
		.elseif eax==5
			;Div500
			mov		eax,499
		.elseif eax==6
			;Div1000
			mov		eax,999
		.elseif eax==7
			;Div5000
			mov		eax,4999
		.elseif eax==8
			;Div10000
			mov		eax,9999
		.elseif eax==9
			;Div50000
			mov		eax,49999
		.endif
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM16_ARR
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,4001442Ch
		mov		eax,65536
		sub		eax,frequency
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM16_CCR1
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014434h
		mov		eax,65536
		sub		eax,frequency
		inc		eax
		shr		eax,1
		mov		eax,Duty
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;Set end of sequence
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeNone
		mov		fWave,TRUE
	.endif
	ret

SetTIM16 endp

SetTIM17 proc uses ebx esi edi,fenable:DWORD,clockdiv:DWORD,frequency:DWORD,Duty:DWORD
	;TIM17 Base 	0x40014800
	;TIM17_CR1		0x40014800			Bit 0 CEN: Counter enable
	;TIM17_CR2		0x40014804
	;TIM17_DIER		0x4001480C
	;TIM17_SR		0x40014810
	;TIM17_EGR		0x40014814
	;TIM17_CCMR1	0x40014818			Bits 6:4 OC1M: 110: PWM mode 1 - In upcounting, channel 1 is active as long as TIMx_CNT<TIMx_CCR1 else inactive. In downcounting, channel 1 is inactive (OC1REF=‘0’) as long as TIMx_CNT>TIMx_CCR1 else active (OC1REF=’1’).
	;									Bits 1:0 CC1S: 00: CC1 channel is configured as output. Capture/Compare 1 selection. This bit-field defines the direction of the channel (input/output) as well as the used input.
	;TIM17_CCER		0x40014820
	;TIM17_CNT		0x40014824
	;TIM17_PSC		0x40014828
	;TIM17_ARR		0x4001482C
	;TIM17_RCR		0x40014830
	;TIM17_CCR1		0x40014834
	;TIM17_BDTR		0x40014844
	;TIM17_DCR		0x40014848
	;TIM17_DMAR		0x4001484C
	
	.if hsclockdata.hscCHBData.hsclockenable
		mov		edi,offset rwdata.RW_CommandStruct
		;TIM17_CR1
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014800h
		mov		eax,fenable
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM17_PSC
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014828h
		mov		eax,clockdiv
		.if eax==1
			;Div5
			mov		eax,4
		.elseif eax==2
			;Div10
			mov		eax,9
		.elseif eax==3
			;Div50
			mov		eax,49
		.elseif eax==4
			;Div100
			mov		eax,99
		.elseif eax==5
			;Div500
			mov		eax,499
		.elseif eax==6
			;Div1000
			mov		eax,999
		.elseif eax==7
			;Div5000
			mov		eax,4999
		.elseif eax==8
			;Div10000
			mov		eax,9999
		.elseif eax==9
			;Div50000
			mov		eax,49999
		.endif
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM17_ARR
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,4001482Ch
		mov		eax,65536
		sub		eax,frequency
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;TIM17_CCR1
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
		mov		[edi].RWDATA.RW_CommandStruct.Address,40014834h
		mov		eax,65536
		sub		eax,frequency
		inc		eax
		shr		eax,1
		mov		eax,Duty
		mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
		lea		edi,[edi+sizeof STM32_CommandStructDef]
		;Set end of sequence
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeNone
		mov		fWave,TRUE
	.endif
	ret

SetTIM17 endp

HSClockSetupProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	tmp:DWORD
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Channel A
		mov		eax,BST_UNCHECKED
		.if hsclockdata.hscCHAData.hsclockenable
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKHSCLOCKAENABLE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADIV,TBM_SETRANGE,FALSE,(9 SHL 16)+0
		mov		eax,hsclockdata.hscCHAData.hsclockdivisor
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADIV,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAH,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hscCHAData.hsclockfrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAH,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAL,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hscCHAData.hsclockfrequency
		and		eax,255
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAL,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADUTY,TBM_SETRANGE,FALSE,(100 SHL 16)+0
		mov		eax,hsclockdata.hscCHAData.hsclockdutycycle
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADUTY,TBM_SETPOS,TRUE,eax
		;Channel B
		mov		eax,BST_UNCHECKED
		.if hsclockdata.hscCHBData.hsclockenable
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKHSCLOCKBENABLE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDIV,TBM_SETRANGE,FALSE,(9 SHL 16)+0
		mov		eax,hsclockdata.hscCHBData.hsclockdivisor
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDIV,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBH,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hscCHBData.hsclockfrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBH,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBL,TBM_SETRANGE,FALSE,(255 SHL 16)+0
		mov		eax,hsclockdata.hscCHBData.hsclockfrequency
		and		eax,255
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBL,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDUTY,TBM_SETRANGE,FALSE,(100 SHL 16)+0
		mov		eax,hsclockdata.hscCHBData.hsclockdutycycle
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDUTY,TBM_SETPOS,TRUE,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,1
			.elseif eax==IDC_CHKHSCLOCKAENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKHSCLOCKAENABLE
				mov		hsclockdata.hscCHAData.hsclockenable,eax
				invoke SetTIM16,eax,hsclockdata.hscCHAData.hsclockdivisor,hsclockdata.hscCHAData.hsclockfrequency,hsclockdata.hscCHAData.hsclockccr
			.elseif eax==IDC_CHKHSCLOCKBENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKHSCLOCKBENABLE
				mov		hsclockdata.hscCHBData.hsclockenable,eax
				invoke SetTIM17,eax,hsclockdata.hscCHBData.hsclockdivisor,hsclockdata.hscCHBData.hsclockfrequency,hsclockdata.hscCHBData.hsclockccr
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		mov		fChanged,0
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADIV,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hscCHAData.hsclockdivisor
			mov		hsclockdata.hscCHAData.hsclockdivisor,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAL,TBM_GETPOS,0,0
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKAH,TBM_GETPOS,0,0
		shl		eax,8
		pop		edx
		or		eax,edx
		.if eax!=hsclockdata.hscCHAData.hsclockfrequency
			mov		hsclockdata.hscCHAData.hsclockfrequency,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKADUTY,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hscCHAData.hsclockdutycycle
			mov		hsclockdata.hscCHAData.hsclockdutycycle,eax
			mov		fChanged,TRUE
		.endif
		mov		eax,65537
		sub		eax,hsclockdata.hscCHAData.hsclockfrequency
		.if eax<100
			mov		tmp,eax
			fld		float100
			fild	tmp
			fdivp	st(1),st
			fistp	tmp
			fild	hsclockdata.hscCHAData.hsclockdutycycle
			fild	tmp
			fdivp	st(1),st
			fistp	hsclockdata.hscCHAData.hsclockccr
			fild	hsclockdata.hscCHAData.hsclockccr
			mov		eax,65537
			sub		eax,hsclockdata.hscCHAData.hsclockfrequency
			mov		tmp,eax
			fld		float100
			fild	tmp
			fdivp	st(1),st
			fmulp	st(1),st
			fistp	tmp
			mov		eax,tmp
		.else
			mov		eax,65537
			sub		eax,hsclockdata.hscCHAData.hsclockfrequency
			mov		ecx,hsclockdata.hscCHAData.hsclockdutycycle
			mul		ecx
			mov		ecx,100
			div		ecx
			mov		hsclockdata.hscCHAData.hsclockccr,eax
			mov		eax,hsclockdata.hscCHAData.hsclockdutycycle
		.endif
		.if fChanged
			invoke MakeHSCWave,addr hsclockdata.hscCHAData.HSC_Data,eax
			invoke InvalidateRect,hsclockdata.hscCHAData.hWndHSClock,NULL,TRUE
			invoke SetTIM16,hsclockdata.hscCHAData.hsclockenable,hsclockdata.hscCHAData.hsclockdivisor,hsclockdata.hscCHAData.hsclockfrequency,hsclockdata.hscCHAData.hsclockccr
		.endif

		mov		fChanged,0
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDIV,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hscCHBData.hsclockdivisor
			mov		hsclockdata.hscCHBData.hsclockdivisor,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBL,TBM_GETPOS,0,0
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBH,TBM_GETPOS,0,0
		shl		eax,8
		pop		edx
		or		eax,edx
		.if eax!=hsclockdata.hscCHBData.hsclockfrequency
			mov		hsclockdata.hscCHBData.hsclockfrequency,eax
			mov		fChanged,TRUE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKBDUTY,TBM_GETPOS,0,0
		.if eax!=hsclockdata.hscCHBData.hsclockdutycycle
			mov		hsclockdata.hscCHBData.hsclockdutycycle,eax
			mov		fChanged,TRUE
		.endif
		mov		eax,65537
		sub		eax,hsclockdata.hscCHBData.hsclockfrequency
		.if eax<100
			mov		tmp,eax
			fld		float100
			fild	tmp
			fdivp	st(1),st
			fistp	tmp
			fild	hsclockdata.hscCHBData.hsclockdutycycle
			fild	tmp
			fdivp	st(1),st
			fistp	hsclockdata.hscCHBData.hsclockccr
			fild	hsclockdata.hscCHBData.hsclockccr
			mov		eax,65537
			sub		eax,hsclockdata.hscCHBData.hsclockfrequency
			mov		tmp,eax
			fld		float100
			fild	tmp
			fdivp	st(1),st
			fmulp	st(1),st
			fistp	tmp
			mov		eax,tmp
		.else
			mov		eax,65537
			sub		eax,hsclockdata.hscCHBData.hsclockfrequency
			mov		ecx,hsclockdata.hscCHBData.hsclockdutycycle
			mul		ecx
			mov		ecx,100
			div		ecx
			mov		hsclockdata.hscCHBData.hsclockccr,eax
			mov		eax,hsclockdata.hscCHBData.hsclockdutycycle
		.endif
		.if fChanged
			invoke MakeHSCWave,addr hsclockdata.hscCHBData.HSC_Data,eax
			invoke InvalidateRect,hsclockdata.hscCHBData.hWndHSClock,NULL,TRUE
			invoke SetTIM17,hsclockdata.hscCHBData.hsclockenable,hsclockdata.hscCHBData.hsclockdivisor,hsclockdata.hscCHBData.hsclockfrequency,hsclockdata.hscCHBData.hsclockccr
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		mov		childdialogs.hWndHSClockSetup,0
		invoke SetFocus,hWnd
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HSClockSetupProc endp

HSClockToolChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKXMAG,TBM_SETRANGE,FALSE,(XMAGMAX SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKXMAG,TBM_SETPOS,TRUE,XMAGMAX/16
	.elseif eax==WM_HSCROLL
		;X-Magnification
		invoke GetParent,hWin
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBHSCLOCKXMAG,TBM_GETPOS,0,0
		mov		[ebx].HSCLOCKCHDATA.xmag,eax
		invoke InvalidateRect,[ebx].HSCLOCKCHDATA.hWndHSClock,NULL,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HSClockToolChildProc endp

HSClockProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	xsinf:SCROLLINFO
	LOCAL	samplesize:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE

	mov		eax,uMsg
	.if eax==WM_CREATE
		xor		eax,eax
		mov		xsinf.cbSize,sizeof SCROLLINFO
		mov		xsinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
		mov		eax,xsinf.nMax
		inc		eax
		mov		xsinf.nPage,eax
		invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
	.elseif eax==WM_PAINT
		invoke GetParent,hWin
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		call	SetScrooll
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
		mov		eax,hWin
		.if eax==hsclockdata.hscCHAData.hWndHSClock
			;Channel A
			invoke SetTextColor,mDC,00FF00h
			mov		eax,008000h
		.else
			;Channel B
			invoke SetTextColor,mDC,0FFFF00h
			mov		eax,0808000h
		.endif
		invoke CreatePen,PS_SOLID,2,eax
		invoke SelectObject,mDC,eax
		push	eax
		invoke SetBkMode,mDC,TRANSPARENT
		lea		esi,[ebx].HSCLOCKCHDATA.HSC_Data
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<samplesize
			mov		edx,edi
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
		mov		eax,[ebx].HSCLOCKCHDATA.hsclockdivisor
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
		sub		ecx,[ebx].HSCLOCKCHDATA.hsclockfrequency
		.if ecx==65537
			xor		eax,eax
		.else
			div		ecx
		.endif
		push	eax
		.if eax
			mov		ecx,65537
			sub		ecx,[ebx].HSCLOCKCHDATA.hsclockfrequency
			mov		eax,ecx
			sub		eax,[ebx].HSCLOCKCHDATA.hsclockccr
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
	.elseif eax==WM_HSCROLL
		mov		xsinf.cbSize,sizeof SCROLLINFO
		mov		xsinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBPOSITION
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_THUMBTRACK
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_LINELEFT
			mov		eax,xsinf.nPos
			sub		eax,10
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_LINERIGHT
			mov		eax,xsinf.nPos
			add		eax,10
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGELEFT
			mov		eax,xsinf.nPos
			sub		eax,xsinf.nPage
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGERIGHT
			mov		eax,xsinf.nPos
			add		eax,xsinf.nPage
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScrooll:
	invoke GetParent,hWin
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	mov		samplesize,HSCMAX
	invoke GetClientRect,hWin,addr rect
	;Init horizontal scrollbar
	mov		xsinf.cbSize,sizeof SCROLLINFO
	mov		xsinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
	mov		xsinf.nMin,0
	mov		eax,samplesize
	mov		ecx,[ebx].HSCLOCKCHDATA.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	mov		xsinf.nMax,eax
	mov		eax,rect.right
	inc		eax
	mov		xsinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
	retn

GetPoint:
	;Get X position
	mov		eax,edi
	mov		ecx,[ebx].HSCLOCKCHDATA.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	sub		eax,xsinf.nPos
	mov		pt.x,eax
	;Get y position
	mov		edx,edi
	movzx	eax,byte ptr [esi+edx]
	sub		eax,ADCMAX
	neg		eax
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,ADCMAX
	div		ecx
	add		eax,5
	mov		pt.y,eax
	retn

HSClockProc endp

HSClockChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,ebx
		mov		eax,hWin
		mov		[ebx].HSCLOCKCHDATA.hWndDialog,eax
		invoke GetDlgItem,hWin,IDC_UDCHSCLOCK
		mov		[ebx].HSCLOCKCHDATA.hWndHSClock,eax
		invoke CreateDialogParam,hInstance,IDD_DLGHSCLOCKTOOL,hWin,addr HSClockToolChildProc,0
		mov		[ebx].HSCLOCKCHDATA.hWndHSClockTool,eax
		mov		[ebx].HSCLOCKCHDATA.hsclockfrequency,65535
		mov		[ebx].HSCLOCKCHDATA.hsclockdutycycle,50
		mov		[ebx].HSCLOCKCHDATA.hsclockccr,1
		mov		[ebx].HSCLOCKCHDATA.xmag,XMAGMAX/16
		invoke MakeHSCWave,addr [ebx].HSCLOCKCHDATA.HSC_Data,[ebx].HSCLOCKCHDATA.hsclockdutycycle
	.elseif	eax==WM_SIZE
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,135
		sub		rect.bottom,2
		invoke MoveWindow,[ebx].HSCLOCKCHDATA.hWndHSClock,0,0,rect.right,rect.bottom,TRUE
		invoke MoveWindow,[ebx].HSCLOCKCHDATA.hWndHSClockTool,rect.right,0,135,60,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HSClockChildProc endp

