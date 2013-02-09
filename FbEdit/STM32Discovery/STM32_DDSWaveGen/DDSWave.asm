
.code

DDSGenWave proc uses ebx esi edi

	mov		ddswavedata.DDS_VMin,4095
	mov		ddswavedata.DDS_VMax,0
	mov		eax,ddswavedata.DDS_WaveForm
	.if !eax
		mov		esi,offset DDS_SineWave
		mov		edi,offset ddswavedata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SineWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SineWave
		movsw
	.elseif eax==1
		mov		esi,offset DDS_TriangleWave
		mov		edi,offset ddswavedata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_TriangleWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_TriangleWave
		movsw
	.elseif eax==2
		mov		esi,offset DDS_SquareWave
		mov		edi,offset ddswavedata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SquareWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SquareWave
		movsw
	.elseif eax==3
		mov		esi,offset DDS_SawToothWave
		mov		edi,offset ddswavedata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SawToothWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SawToothWave
		movsw
	.elseif eax==4
		mov		esi,offset DDS_RevSawToothWave
		mov		edi,offset ddswavedata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_RevSawToothWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_RevSawToothWave
		movsw
	.endif
	xor		ebx,ebx
	mov		edi,offset ddswavedata.DDS_WaveData
	.while ebx<4098
		movzx	eax,word ptr [edi+ebx*WORD]
		mov		ecx,ddswavedata.DDS_Amplitude
		mul		ecx
		mov		ecx,4096
		div		ecx
		mov		ecx,ddswavedata.DDS_Amplitude
		shr		ecx,1
		sub		ax,cx
		add		ax,2048
		mov		ecx,ddswavedata.DDS_DCOffset
		add		ax,cx
		sub		ax,4096
		.if CARRY?
			xor		ax,ax
		.elseif ax>4095
			mov		ax,4095
		.endif
		mov		[edi+ebx*WORD],ax
		movzx	eax,ax
		.if eax<ddswavedata.DDS_VMin
			mov		ddswavedata.DDS_VMin,eax
		.endif
		.if eax>ddswavedata.DDS_VMax
			mov		ddswavedata.DDS_VMax,eax
		.endif
		inc		ebx
	.endw
	invoke InvalidateRect,childdialogs.hWndDDSWave,NULL,TRUE
	invoke UpdateWindow,childdialogs.hWndDDSWave
	mov		eax,ddswavedata.SWEEP_StepSize
	mov		ecx,ddswavedata.SWEEP_StepCount
	shr		ecx,1
	mul		ecx
	mov		ebx,ddswavedata.DDS_PhaseFrq
	sub		ebx,eax
	mov		eax,ddswavedata.SWEEP_StepSize
	mov		ecx,ddswavedata.SWEEP_StepCount
	mul		ecx
	mov		edx,ebx
	add		edx,eax
	mov		eax,ddswavedata.SWEEP_SubMode
	.if eax==SWEEP_SubModeUp
		mov		ddswavedata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		ddswavedata.DDS_Sweep.SWEEP_Min,ebx
		mov		ddswavedata.DDS_Sweep.SWEEP_Max,edx
		mov		eax,ddswavedata.SWEEP_StepSize
		mov		ddswavedata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModeDown
		mov		ddswavedata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		ddswavedata.DDS_Sweep.SWEEP_Max,ebx
		mov		ddswavedata.DDS_Sweep.SWEEP_Min,edx
		mov		eax,ddswavedata.SWEEP_StepSize
		neg		eax
		mov		ddswavedata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModeUpDown
		mov		ddswavedata.DDS_Sweep.SWEEP_UpDovn,TRUE
		mov		ddswavedata.DDS_Sweep.SWEEP_Min,ebx
		mov		ddswavedata.DDS_Sweep.SWEEP_Max,edx
		mov		eax,ddswavedata.SWEEP_StepSize
		mov		ddswavedata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModePeak
		mov		ddswavedata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		ddswavedata.DDS_Sweep.SWEEP_Min,ebx
		mov		ddswavedata.DDS_Sweep.SWEEP_Max,edx
		mov		eax,ddswavedata.SWEEP_StepSize
		mov		ddswavedata.DDS_Sweep.SWEEP_Add,eax
	.endif
	ret

DDSGenWave endp

DDSHzToPhaseAdd proc frq:DWORD

	fild	frq
	fild	dds64
	fmulp	st(1),st
	fild	ddscycles
	fmulp	st(1),st
	fild	STM32Clock
	fdivp	st(1),st
	fistp	frq
	mov		eax,frq
	ret

DDSHzToPhaseAdd endp

DDSPhaseFrqToHz proc PhaseAdd:DWORD
	
	fild	STM32Clock
	fild	dds64
	fdivp	st(1),st
	fild	ddscycles
	fdivp	st(1),st
	fild	PhaseAdd
	fmulp	st(1),st
	fistp	PhaseAdd
	mov		eax,PhaseAdd
	ret

DDSPhaseFrqToHz endp

DDSWaveSetupProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		childdialogs.hWndDDSWaveSetup,eax
		.if ddswavedata.DDS_Enable
			mov		eax,BST_CHECKED
		.else
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKDDSENABLE,eax
		.if ddswavedata.DDS_DacBuffer
			mov		eax,BST_CHECKED
		.else
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKDDSBUFFERED,eax
		mov		esi,offset szDDS_Waves
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBODDSWAVE,CB_ADDSTRING,0,esi
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		mov		eax,ddswavedata.DDS_WaveForm
		invoke SendDlgItemMessage,hWin,IDC_CBODDSWAVE,CB_SETCURSEL,eax,0
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_SETRANGE,FALSE,(DACMAX SHL 16)
		mov		eax,ddswavedata.DDS_Amplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_SETRANGE,FALSE,(((DACMAX+1)*2-1) SHL 16)
		mov		eax,ddswavedata.DDS_DCOffset
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETRANGE,FALSE,(DDSMAX SHL 16)
		mov		eax,ddswavedata.DDS_Frequency
		shr		eax,15
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETRANGE,FALSE,(DDSMAX SHL 16)
		mov		eax,ddswavedata.DDS_Frequency
		and		eax,DDSMAX
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETPOS,TRUE,eax
		invoke DDSPhaseFrqToHz,ddswavedata.DDS_PhaseFrq
		invoke SetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTDDSFREQUENCY,EM_LIMITTEXT,7,0
		mov		eax,ddswavedata.SWEEP_SubMode
		add		eax,IDC_RBNSWEEPOFF
		dec		eax
		invoke CheckRadioButton,hWin,IDC_RBNSWEEPOFF,IDC_RBNSWEEPPEAK,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPSIZE,EM_LIMITTEXT,4,0
		invoke DDSPhaseFrqToHz,ddswavedata.SWEEP_StepSize
		invoke SetDlgItemInt,hWin,IDC_EDTSWEEPSIZE,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPTIME,EM_LIMITTEXT,4,0
		mov		eax,ddswavedata.SWEEP_StepTime
		inc		eax
		cdq
		mov		ecx,10
		div		ecx
		invoke SetDlgItemInt,hWin,IDC_EDTSWEEPTIME,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPCOUNT,EM_LIMITTEXT,4,0
		mov		eax,ddswavedata.SWEEP_StepCount
		dec		eax
		invoke SetDlgItemInt,hWin,IDC_EDTSWEEPCOUNT,eax,FALSE
		invoke GetDlgItem,hWin,IDC_BTNDDSSET
		invoke EnableWindow,eax,FALSE
		invoke GetDlgItem,hWin,IDC_BTNSWEEPSET
		invoke EnableWindow,eax,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_CHKDDSENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKDDSENABLE
				mov		ddswavedata.DDS_Enable,eax
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_CHKDDSBUFFERED
				invoke IsDlgButtonChecked,hWin,IDC_CHKDDSBUFFERED
				mov		ddswavedata.DDS_DacBuffer,eax
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_BTNDDSSET
				invoke GetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,NULL,FALSE
				.if eax
					.if eax>1750000
						invoke SetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,1750000,FALSE
						mov		eax,1750000
					.endif
					invoke DDSHzToPhaseAdd,eax
					mov		ddswavedata.DDS_PhaseFrq,eax
					dec		eax
					mov		ddswavedata.DDS_Frequency,eax
					shr		eax,15
					invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETPOS,TRUE,eax
					mov		eax,ddswavedata.DDS_Frequency
					and		eax,DDSMAX
					invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETPOS,TRUE,eax
					invoke DDSGenWave
					inc		fCommand
					invoke GetDlgItem,hWin,IDC_BTNDDSSET
					invoke EnableWindow,eax,FALSE
				.endif
			.elseif eax==IDC_RBNSWEEPOFF
				mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModeOff
				invoke SendMessage,childdialogs.hWndDDSWaveDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_RBNSWEEPUP
				mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModeUp
				invoke SendMessage,childdialogs.hWndDDSWaveDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_RBNSWEEPDOWN
				mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModeDown
				invoke SendMessage,childdialogs.hWndDDSWaveDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_RBNSWEEPUPDOWN
				mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModeUpDown
				invoke SendMessage,childdialogs.hWndDDSWaveDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_RBNSWEEPPEAK
				mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModePeak
				invoke SendMessage,childdialogs.hWndDDSWaveDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fCommand
			.elseif eax==IDC_BTNSWEEPSET
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPSIZE,NULL,FALSE
				invoke DDSHzToPhaseAdd,eax
				mov		ddswavedata.SWEEP_StepSize,eax
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPTIME,NULL,FALSE
				.if eax>6500
					invoke SetDlgItemInt,hWin,IDC_EDTSWEEPTIME,6500,FALSE
					mov		eax,6500
				.endif
				mov		ecx,10
				mul		ecx
				dec		eax
				mov		ddswavedata.SWEEP_StepTime,eax
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPCOUNT,NULL,FALSE
				.if eax>1535
					invoke SetDlgItemInt,hWin,IDC_EDTSWEEPCOUNT,1536,FALSE
					mov		eax,1535
				.endif
				inc		eax
				mov		ddswavedata.SWEEP_StepCount,eax
				invoke DDSGenWave
				inc		fCommand
				invoke GetDlgItem,hWin,IDC_BTNSWEEPSET
				invoke EnableWindow,eax,FALSE
				invoke InvalidateRect,childdialogs.hWndDDSPeak,NULL,TRUE
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTDDSFREQUENCY
				invoke GetDlgItem,hWin,IDC_BTNDDSSET
				invoke EnableWindow,eax,TRUE
			.else
				invoke GetDlgItem,hWin,IDC_BTNSWEEPSET
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif edx==CBN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_CBODDSWAVE,CB_GETCURSEL,0,0
			mov		ddswavedata.DDS_WaveForm,eax
			invoke DDSGenWave
			inc		fCommand
		.endif
	.elseif eax==WM_HSCROLL
		invoke GetDlgCtrlID,lParam
		.if eax==IDC_TRBDDSAMP
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_GETPOS,0,0
			mov		ddswavedata.DDS_Amplitude,eax
			invoke DDSGenWave
			inc		fCommand
		.elseif eax==IDC_TRBDDSDCOFS
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_GETPOS,0,0
			mov		ddswavedata.DDS_DCOffset,eax
			invoke DDSGenWave
			inc		fCommand
		.elseif eax==IDC_TRBDDSFRQH || eax==IDC_TRBDDSFRQL
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_GETPOS,0,0
			mov		edx,ddswavedata.DDS_Frequency
			and		edx,DDSMAX
			shl		eax,15
			or		eax,edx
			mov		ddswavedata.DDS_Frequency,eax
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_GETPOS,0,0
			mov		edx,ddswavedata.DDS_Frequency
			and		edx,0FFFF8000h
			or		eax,edx
			mov		ddswavedata.DDS_Frequency,eax
			inc		eax
			mov		ddswavedata.DDS_PhaseFrq,eax
			invoke DDSGenWave
			inc		fCommand
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DDSWaveSetupProc endp

DDSWaveProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	tmp:DWORD

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		eax,hWin
		mov		childdialogs.hWndDDSWave,eax
		xor		eax,eax
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
		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,TEXTHIGHT
		invoke SetTextColor,mDC,00FF00h
		invoke SetBkMode,mDC,TRANSPARENT
		fild	STM32Clock
		fild	dds64
		fdivp	st(1),st
		fild	ddscycles
		fdivp	st(1),st
		fild	ddswavedata.DDS_PhaseFrq
		fmulp	st(1),st
		fild	dds1000
		fmulp	st(1),st
		fistp	tmp
		invoke FormatFrequencyX1000,addr buffer,addr szFmtFrq,tmp
		mov		eax,ddswavedata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtDDSVmin,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddswavedata.DDS_VMax
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtDDSVmax,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddswavedata.DDS_VMax
		sub		eax,ddswavedata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtDDSVpp,eax
		invoke lstrcat,addr buffer,addr buffer1
		invoke lstrlen,addr buffer
		mov		edx,rect.bottom
		add		edx,8
		invoke TextOut,mDC,0,edx,addr buffer,eax
		;Draw horizontal lines
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
		invoke CreateRectRgn,0,0,rect.right,rect.bottom
		push	eax
		invoke SelectClipRgn,mDC,eax
		pop		eax
		invoke DeleteObject,eax
		invoke CreatePen,PS_SOLID,2,008000h
		invoke SelectObject,mDC,eax
		push	eax
		mov		esi,offset ddswavedata.DDS_WaveData
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<4097*WORD
			call	GetPoint
			invoke LineTo,mDC,pt.x,pt.y
			inc		edi
			inc		edi
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		add		rect.bottom,TEXTHIGHT
		invoke SelectClipRgn,mDC,NULL
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
	mov		ecx,4097*2
	div		ecx
	mov		pt.x,eax
	;Get y position
	movzx	eax,word ptr [esi+edi]
	sub		eax,DACMAX
	neg		eax
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,DACMAX
	div		ecx
	add		eax,5
	mov		pt.y,eax
	retn

DDSWaveProc endp

DDSPeakProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	tmp:DWORD

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		eax,hWin
		mov		childdialogs.hWndDDSPeak,eax
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
		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,TEXTHIGHT
		invoke SetTextColor,mDC,00FF00h
		invoke SetBkMode,mDC,TRANSPARENT
		fild	STM32Clock
		fild	dds64
		fdivp	st(1),st
		fild	ddscycles
		fdivp	st(1),st
		fild	ddswavedata.DDS_Sweep.SWEEP_Min
		fmulp	st(1),st
		fistp	tmp
		invoke FormatFrequency,addr buffer,addr szFmtFrqMin,tmp
		fild	STM32Clock
		fild	dds64
		fdivp	st(1),st
		fild	ddscycles
		fdivp	st(1),st
		mov		eax,ddswavedata.DDS_Sweep.SWEEP_Max
		sub		eax,ddswavedata.DDS_Sweep.SWEEP_Add
		mov		tmp,eax
		fild	tmp
		fmulp	st(1),st
		fistp	tmp
		invoke FormatFrequency,addr buffer1,addr szFmtFrqMax,tmp
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddswavedata.DDS_PeakVMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtDDSVmin,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddswavedata.DDS_PeakVMax
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtDDSVmax,eax
		invoke lstrcat,addr buffer,addr buffer1
		invoke lstrlen,addr buffer
		mov		edx,rect.bottom
		add		edx,8
		invoke TextOut,mDC,0,edx,addr buffer,eax
		;Draw horizontal lines
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
		invoke CreateRectRgn,0,0,rect.right,rect.bottom
		push	eax
		invoke SelectClipRgn,mDC,eax
		pop		eax
		invoke DeleteObject,eax
		invoke CreatePen,PS_SOLID,2,008000h
		invoke SelectObject,mDC,eax
		push	eax
		mov		esi,offset ddswavedata.DDS_PeakData
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<ddswavedata.SWEEP_StepCount
			call	GetPoint
			invoke LineTo,mDC,pt.x,pt.y
			inc		edi
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		add		rect.bottom,TEXTHIGHT
		invoke SelectClipRgn,mDC,NULL
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
	mov		ecx,ddswavedata.SWEEP_StepCount
	dec		ecx
	div		ecx
	mov		pt.x,eax
	;Get y position
	movzx	eax,word ptr [esi+edi*WORD]
	sub		eax,DACMAX
	neg		eax
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,DACMAX
	div		ecx
	add		eax,5
	mov		pt.y,eax
	retn

DDSPeakProc endp

DDSWaveChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ddswavedata.SWEEP_SubMode,SWEEP_SubModeOff
		mov		ddswavedata.DDS_DacBuffer,TRUE
		invoke DDSHzToPhaseAdd,5000	;5KHz
		mov		ddswavedata.DDS_Frequency,eax
		inc		eax
		mov		ddswavedata.DDS_PhaseFrq,eax
		mov		ddswavedata.DDS_WaveForm,DDS_ModeSinWave
		mov		ddswavedata.DDS_Amplitude,DACMAX
		mov		ddswavedata.DDS_DCOffset,DACMAX
		invoke DDSHzToPhaseAdd,10	;10Hz
		mov		ddswavedata.SWEEP_StepSize,eax
		mov		ddswavedata.SWEEP_StepTime,999
		mov		ddswavedata.SWEEP_StepCount,101
		invoke DDSGenWave
		mov		esi,offset DDS_SineWave
		mov		edi,offset ddswavedata.DDS_PeakData
		xor		ebx,ebx
		.while ebx<1536
			mov		ax,[esi+ebx*WORD]
			mov		[edi+ebx*WORD],ax
			inc		ebx
		.endw
		invoke CreateDialogParam,hInstance,IDD_DDSWAVESETUP,hWin,addr DDSWaveSetupProc,0
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,312
		.if ddswavedata.SWEEP_SubMode==SWEEP_SubModePeak
			push	rect.bottom
			invoke ShowWindow,childdialogs.hWndDDSPeak,SW_SHOWNA
			mov		ebx,rect.bottom
			shr		ebx,1
			dec		ebx
			invoke MoveWindow,childdialogs.hWndDDSWave,0,0,rect.right,ebx,TRUE
			add		ebx,2
			add		rect.top,ebx
			sub		rect.bottom,ebx
			invoke MoveWindow,childdialogs.hWndDDSPeak,0,rect.top,rect.right,rect.bottom,TRUE
			pop		rect.bottom
		.else
			invoke MoveWindow,childdialogs.hWndDDSWave,0,0,rect.right,rect.bottom,TRUE
			invoke ShowWindow,childdialogs.hWndDDSPeak,SW_HIDE
		.endif
		sub		rect.bottom,70
		invoke MoveWindow,childdialogs.hWndDDSWaveSetup,rect.right,0,312,rect.bottom,TRUE
		invoke MoveWindow,childdialogs.hWndFrequency,rect.right,rect.bottom,310,75,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DDSWaveChildProc endp
