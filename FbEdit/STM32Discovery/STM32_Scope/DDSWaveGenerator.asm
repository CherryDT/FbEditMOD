
.code

;SineGenerator proc uses ebx esi edi,hWin:HWND
;	LOCAL	tmp:DWORD
;	LOCAL	buffer[256]:BYTE
;
;	xor		ebx,ebx
;	.while ebx<2048
;		mov		eax,ebx
;		and		eax,0Fh
;		.if !eax
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCRLF
;		.else
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCOMMA
;		.endif
;		fld		float2
;		fldpi
;		fmulp	st(1),st
;		mov		tmp,ebx
;		fild	tmp
;		fmulp	st(1),st
;		mov		tmp,2048
;		fild	tmp
;		fdivp	st(1),st
;		fsin
;		mov		tmp,2047
;		fild	tmp
;		fmulp	st(1),st
;		mov		tmp,2048
;		fild	tmp
;		faddp	st(1),st
;		fistp	tmp
;		invoke wsprintf,addr buffer,addr szFmtDec,tmp
;		invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr buffer
;		inc		ebx
;	.endw
;	ret
;
;SineGenerator endp
;
;TriangleGenerator proc uses ebx esi edi,hWin:HWND
;	LOCAL	buffer[256]:BYTE
;
;	xor		ebx,ebx
;	mov		esi,4
;	mov		edi,2048
;	.while ebx<2048
;		mov		eax,ebx
;		and		eax,0Fh
;		.if !eax
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCRLF
;		.else
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCOMMA
;		.endif
;		invoke wsprintf,addr buffer,addr szFmtDec,edi
;		invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr buffer
;		add		edi,esi
;		.if edi>4095
;			neg		esi
;			add		edi,esi
;		.endif
;		inc		ebx
;	.endw
;	ret
;
;TriangleGenerator endp
;
;SquuareGenerator proc uses ebx esi edi,hWin:HWND
;	LOCAL	buffer[256]:BYTE
;
;	xor		ebx,ebx
;	mov		edi,4095
;	.while ebx<2048
;		mov		eax,ebx
;		and		eax,0Fh
;		.if !eax
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCRLF
;		.else
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCOMMA
;		.endif
;		invoke wsprintf,addr buffer,addr szFmtDec,edi
;		invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr buffer
;		.if ebx==1023
;			xor		edi,edi
;		.endif
;		inc		ebx
;	.endw
;	ret
;
;SquuareGenerator endp
;
;SawtoothGenerator proc uses ebx esi edi,hWin:HWND
;	LOCAL	buffer[256]:BYTE
;
;	xor		ebx,ebx
;	mov		esi,2
;	mov		edi,2048
;	.while ebx<2048
;		mov		eax,ebx
;		and		eax,0Fh
;		.if !eax
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCRLF
;		.else
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCOMMA
;		.endif
;		invoke wsprintf,addr buffer,addr szFmtDec,edi
;		invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr buffer
;		add		edi,esi
;		.if edi>4095
;			xor		edi,edi
;		.endif
;		inc		ebx
;	.endw
;	ret
;
;SawtoothGenerator endp
;
;RevSawtoothGenerator proc uses ebx esi edi,hWin:HWND
;	LOCAL	buffer[256]:BYTE
;
;	xor		ebx,ebx
;	mov		esi,2
;	mov		edi,2048
;	.while ebx<2048
;		mov		eax,ebx
;		and		eax,0Fh
;		.if !eax
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCRLF
;		.else
;			invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr szCOMMA
;		.endif
;		invoke wsprintf,addr buffer,addr szFmtDec,edi
;		invoke SendDlgItemMessage,hWin,IDC_EDTDDSWAVEDATA,EM_REPLACESEL,FALSE,addr buffer
;		sub		edi,esi
;		.if CARRY?
;			mov		edi,4094
;		.endif
;		inc		ebx
;	.endw
;	ret
;
;RevSawtoothGenerator endp
;
;DDSWaveGenProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;
;	mov		eax,uMsg
;	.if eax==WM_INITDIALOG
;		;invoke SineGenerator,hWin
;		;invoke TriangleGenerator,hWin
;		;invoke SquuareGenerator,hWin
;		;invoke SawtoothGenerator,hWin
;		invoke RevSawtoothGenerator,hWin
;	.elseif eax==WM_CLOSE
;		invoke DestroyWindow,hWin
;		invoke SetFocus,hWnd
;	.else
;		mov		eax,FALSE
;		ret
;	.endif
;	mov		eax,TRUE
;	ret
;
;DDSWaveGenProc endp

DDSGenWave proc uses ebx esi edi

	mov		ddsdata.DDS_VMin,4095
	mov		ddsdata.DDS_VMax,0
	mov		eax,ddsdata.DDSWaveForm
	.if !eax
		mov		ddsdata.DDS_SampleSize,4097*WORD
		mov		esi,offset DDS_SineWave
		mov		edi,offset ddsdata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SineWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SineWave
		movsw
	.elseif eax==1
		mov		ddsdata.DDS_SampleSize,4097*WORD
		mov		esi,offset DDS_TriangleWave
		mov		edi,offset ddsdata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_TriangleWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_TriangleWave
		movsw
	.elseif eax==2
		mov		ddsdata.DDS_SampleSize,4097*WORD
		mov		esi,offset DDS_SquareWave
		mov		edi,offset ddsdata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SquareWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SquareWave
		movsw
	.elseif eax==3
		mov		ddsdata.DDS_SampleSize,4097*WORD
		mov		esi,offset DDS_SawToothWave
		mov		edi,offset ddsdata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SawToothWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_SawToothWave
		movsw
	.elseif eax==4
		mov		ddsdata.DDS_SampleSize,4097*WORD
		mov		esi,offset DDS_RevSawToothWave
		mov		edi,offset ddsdata.DDS_WaveData
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_RevSawToothWave
		mov		ecx,2048
		rep		movsw
		mov		esi,offset DDS_RevSawToothWave
		movsw
	.endif
	xor		ebx,ebx
	mov		edi,offset ddsdata.DDS_WaveData
	.while ebx<4098
		movzx	eax,word ptr [edi+ebx*WORD]
		mov		ecx,ddsdata.DDS_Amplitude
		mul		ecx
		mov		ecx,4096
		div		ecx
		mov		ecx,ddsdata.DDS_Amplitude
		shr		ecx,1
		sub		ax,cx
		add		ax,2048
		mov		ecx,ddsdata.DDS_DCOffset
		add		ax,cx
		sub		ax,4096
		.if CARRY?
			xor		ax,ax
		.elseif ax>4095
			mov		ax,4095
		.endif
		mov		[edi+ebx*WORD],ax
		movzx	eax,ax
		.if eax<ddsdata.DDS_VMin
			mov		ddsdata.DDS_VMin,eax
		.endif
		.if eax>ddsdata.DDS_VMax
			mov		ddsdata.DDS_VMax,eax
		.endif
		inc		ebx
	.endw
	invoke InvalidateRect,ddsdata.hWndDDS,NULL,TRUE
	invoke UpdateWindow,ddsdata.hWndDDS
	ret

DDSGenWave endp

DDSSetWave proc uses ebx esi edi

	mov		eax,ddsdata.SWEEP_StepSize
	mov		ecx,ddsdata.SWEEP_StepCount
	mul		ecx
	shr		eax,1
	mov		ebx,eax
	movzx	eax,ddsdata.DDS_CommandStruct.SWEEP_SubMode
	.if eax==SWEEP_SubModeUp
		mov		ddsdata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		sub		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Min,eax
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		add		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Max,eax
		mov		eax,ddsdata.SWEEP_StepSize
		mov		ddsdata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModeDown
		mov		ddsdata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		sub		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Max,eax
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		add		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Min,eax
		mov		eax,ddsdata.SWEEP_StepSize
		neg		eax
		mov		ddsdata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModeUpDown
		mov		ddsdata.DDS_Sweep.SWEEP_UpDovn,TRUE
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		sub		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Min,eax
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		add		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Max,eax
		mov		eax,ddsdata.SWEEP_StepSize
		mov		ddsdata.DDS_Sweep.SWEEP_Add,eax
	.elseif eax==SWEEP_SubModePeak
		mov		ddsdata.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		ddsdata.DDS_PeakData.DDS_Sweep.SWEEP_UpDovn,FALSE
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		sub		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Min,eax
		mov		ddsdata.DDS_PeakData.DDS_Sweep.SWEEP_Min,eax
		mov		eax,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		add		eax,ebx
		mov		ddsdata.DDS_Sweep.SWEEP_Max,eax
		mov		ddsdata.DDS_PeakData.DDS_Sweep.SWEEP_Max,eax
		mov		eax,ddsdata.SWEEP_StepSize
		mov		ddsdata.DDS_Sweep.SWEEP_Add,eax
		mov		ddsdata.DDS_PeakData.DDS_Sweep.SWEEP_Add,eax
	.endif
	.if ddsdata.DDS_Enable
		.if !fConnected
			;Connect to the STLink
			invoke STLinkConnect,hWnd
			mov		fConnected,eax
		.endif
		.if fConnected
			.if fConnected
				invoke STLinkReset,hWnd
				;Upload command
				mov		ddsdata.DDS_CommandStruct.STM32_Command,STM32_CommandWait
				invoke STLinkWrite,hWnd,STM32CommandStart,addr ddsdata.DDS_CommandStruct.STM32_Command,sizeof STM32_CommandStructDef
				;Upload waveform
				invoke STLinkWrite,hWnd,STM32DataStart,offset ddsdata.DDS_WaveData,4096
				;Upload sweep setup
				invoke STLinkWrite,hWnd,STM32DataStart+4096,offset ddsdata.DDS_Sweep,sizeof DDSSWEEP
				;Start wave generation
				mov		ddsdata.DDS_CommandStruct.STM32_Command,STM32_CommandInit
				invoke STLinkWrite,hWnd,STM32CommandStart,addr ddsdata.DDS_CommandStruct.STM32_Command,4
			.endif
		.endif
	.endif
	ret

DDSSetWave endp

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
		.if ddsdata.DDS_Enable
			mov		eax,BST_CHECKED
		.else
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKDDSENABLE,eax
		.if ddsdata.DDS_CommandStruct.DDSDacBuffer
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
		mov		eax,ddsdata.DDSWaveForm
		invoke SendDlgItemMessage,hWin,IDC_CBODDSWAVE,CB_SETCURSEL,eax,0
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_SETRANGE,FALSE,(DACMAX SHL 16)
		mov		eax,ddsdata.DDS_Amplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_SETRANGE,FALSE,(((DACMAX+1)*2-1) SHL 16)
		mov		eax,ddsdata.DDS_DCOffset
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETRANGE,FALSE,(DDSMAX SHL 16)
		mov		eax,ddsdata.DDS_Frequency
		shr		eax,15
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETRANGE,FALSE,(DDSMAX SHL 16)
		mov		eax,ddsdata.DDS_Frequency
		and		eax,DDSMAX
		invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETPOS,TRUE,eax
		invoke DDSPhaseFrqToHz,ddsdata.DDS_CommandStruct.DDSPhaseFrq
		invoke SetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTDDSFREQUENCY,EM_LIMITTEXT,7,0
		movzx	eax,ddsdata.DDS_CommandStruct.SWEEP_SubMode
		add		eax,IDC_RBNSWEEPOFF
		invoke CheckRadioButton,hWin,IDC_RBNSWEEPOFF,IDC_RBNSWEEPPEAK,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPSIZE,EM_LIMITTEXT,4,0
		invoke DDSPhaseFrqToHz,ddsdata.SWEEP_StepSize
		invoke SetDlgItemInt,hWin,IDC_EDTSWEEPSIZE,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPTIME,EM_LIMITTEXT,4,0
		movzx	eax,ddsdata.DDS_CommandStruct.SWEEP_StepTime
		inc		eax
		cdq
		mov		ecx,10
		div		ecx
		invoke SetDlgItemInt,hWin,IDC_EDTSWEEPTIME,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTSWEEPCOUNT,EM_LIMITTEXT,4,0
		mov		eax,ddsdata.SWEEP_StepCount
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
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,1
			.elseif eax==IDC_CHKDDSENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKDDSENABLE
				.if eax
					invoke DDSGenWave
					mov		ddsdata.DDS_Enable,1
					inc		fDDSWave
				.else
					.if fConnected
						invoke STLinkReset,hWnd
					.endif
					mov		ddsdata.DDS_Enable,0
				.endif
			.elseif eax==IDC_CHKDDSBUFFERED
				invoke IsDlgButtonChecked,hWin,IDC_CHKDDSBUFFERED
				mov		ddsdata.DDS_CommandStruct.DDSDacBuffer,al
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_BTNDDSSET
				invoke GetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,NULL,FALSE
				.if eax
					.if eax>1750000
						invoke SetDlgItemInt,hWin,IDC_EDTDDSFREQUENCY,1750000,FALSE
						mov		eax,1750000
					.endif
					invoke DDSHzToPhaseAdd,eax
					mov		ddsdata.DDS_CommandStruct.DDSPhaseFrq,eax
					dec		eax
					mov		ddsdata.DDS_Frequency,eax
					shr		eax,15
					invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_SETPOS,TRUE,eax
					mov		eax,ddsdata.DDS_Frequency
					and		eax,DDSMAX
					invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_SETPOS,TRUE,eax
					invoke DDSGenWave
					inc		fDDSWave
					invoke GetDlgItem,hWin,IDC_BTNDDSSET
					invoke EnableWindow,eax,FALSE
				.endif
			.elseif eax==IDC_RBNSWEEPOFF
				mov		ddsdata.DDS_CommandStruct.SWEEP_SubMode,SWEEP_SubModeOff
				invoke SendMessage,ddsdata.hWndDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_RBNSWEEPUP
				mov		ddsdata.DDS_CommandStruct.SWEEP_SubMode,SWEEP_SubModeUp
				invoke SendMessage,ddsdata.hWndDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_RBNSWEEPDOWN
				mov		ddsdata.DDS_CommandStruct.SWEEP_SubMode,SWEEP_SubModeDown
				invoke SendMessage,ddsdata.hWndDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_RBNSWEEPUPDOWN
				mov		ddsdata.DDS_CommandStruct.SWEEP_SubMode,SWEEP_SubModeUpDown
				invoke SendMessage,ddsdata.hWndDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_RBNSWEEPPEAK
				mov		ddsdata.DDS_CommandStruct.SWEEP_SubMode,SWEEP_SubModePeak
				invoke SendMessage,ddsdata.hWndDialog,WM_SIZE,0,0
				invoke DDSGenWave
				inc		fDDSWave
			.elseif eax==IDC_BTNSWEEPSET
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPSIZE,NULL,FALSE
				invoke DDSHzToPhaseAdd,eax
				mov		ddsdata.SWEEP_StepSize,eax
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPTIME,NULL,FALSE
				.if eax>6500
					invoke SetDlgItemInt,hWin,IDC_EDTSWEEPTIME,6500,FALSE
					mov		eax,6500
				.endif
				mov		ecx,10
				mul		ecx
				dec		eax
				mov		ddsdata.DDS_CommandStruct.SWEEP_StepTime,ax
				invoke GetDlgItemInt,hWin,IDC_EDTSWEEPCOUNT,NULL,FALSE
				.if eax>1500 && ddsdata.DDS_CommandStruct.SWEEP_SubMode==SWEEP_SubModePeak
					invoke SetDlgItemInt,hWin,IDC_EDTSWEEPCOUNT,1500,FALSE
					mov		eax,1500
				.endif
				mov		ddsdata.SWEEP_StepCount,eax
				invoke DDSGenWave
				inc		fDDSWave
				invoke GetDlgItem,hWin,IDC_BTNSWEEPSET
				invoke EnableWindow,eax,FALSE
				invoke InvalidateRect,ddsdata.hWndDDSPeak,NULL,TRUE
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
			mov		ddsdata.DDSWaveForm,eax
			invoke DDSGenWave
			inc		fDDSWave
		.endif
	.elseif eax==WM_HSCROLL
		invoke GetDlgCtrlID,lParam
		.if eax==IDC_TRBDDSAMP
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSAMP,TBM_GETPOS,0,0
			mov		ddsdata.DDS_Amplitude,eax
			invoke DDSGenWave
			inc		fDDSWave
		.elseif eax==IDC_TRBDDSDCOFS
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSDCOFS,TBM_GETPOS,0,0
			mov		ddsdata.DDS_DCOffset,eax
			invoke DDSGenWave
			inc		fDDSWave
		.elseif eax==IDC_TRBDDSFRQH || eax==IDC_TRBDDSFRQL
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQH,TBM_GETPOS,0,0
			mov		edx,ddsdata.DDS_Frequency
			and		edx,DDSMAX
			shl		eax,15
			or		eax,edx
			mov		ddsdata.DDS_Frequency,eax
			invoke SendDlgItemMessage,hWin,IDC_TRBDDSFRQL,TBM_GETPOS,0,0
			mov		edx,ddsdata.DDS_Frequency
			and		edx,0FFFF8000h
			or		eax,edx
			mov		ddsdata.DDS_Frequency,eax
			inc		eax
			mov		ddsdata.DDS_CommandStruct.DDSPhaseFrq,eax
			invoke DDSGenWave
			inc		fDDSWave
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		mov		childdialogs.hWndDDSSetup,0
		invoke SetFocus,hWnd
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
	LOCAL	xsinf:SCROLLINFO
	LOCAL	ysinf:SCROLLINFO
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	tmp:DWORD

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
		mov		ysinf.cbSize,sizeof SCROLLINFO
		mov		ysinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
		mov		eax,ysinf.nMax
		inc		eax
		mov		ysinf.nPage,eax
		invoke SetScrollInfo,hWin,SB_VERT,addr ysinf,TRUE
	.elseif eax==WM_PAINT
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
		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,TEXTHIGHT
		invoke SetTextColor,mDC,00FF00h
		invoke SetBkMode,mDC,TRANSPARENT

		fild	STM32Clock
		fild	dds64
		fdivp	st(1),st
		fild	ddscycles
		fdivp	st(1),st
		fild	ddsdata.DDS_CommandStruct.DDSPhaseFrq
		fmulp	st(1),st
		fild	dds1000
		fmulp	st(1),st
		fistp	tmp

		invoke FormatFrequencyX1000,addr buffer,addr szFmtFrq,tmp
		mov		eax,ddsdata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVmin,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddsdata.DDS_VMax
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVmax,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddsdata.DDS_VMax
		sub		eax,ddsdata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVpp,eax
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
		mov		esi,offset ddsdata.DDS_WaveData
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<ddsdata.DDS_SampleSize
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
;	.elseif eax==WM_SIZE
;		invoke GetParent,hWin
;		invoke GetWindowLong,eax,GWL_USERDATA
;		.if eax
;			mov		ebx,eax
;			movzx	eax,scopedata.ADC_CommandStructDone.STM32_DataBlocks
;			mov		ecx,STM32_BlockSize
;			mul		ecx
;			mov		samplesize,eax
;			call	SetScrooll
;		.endif
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
	.elseif eax==WM_VSCROLL
		mov		ysinf.cbSize,sizeof SCROLLINFO
		mov		ysinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBPOSITION
			mov		eax,ysinf.nTrackPos
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_THUMBTRACK
			mov		eax,ysinf.nTrackPos
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_LINELEFT
			mov		eax,ysinf.nPos
			sub		eax,10
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_LINERIGHT
			mov		eax,ysinf.nPos
			add		eax,10
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGELEFT
			mov		eax,ysinf.nPos
			sub		eax,ysinf.nPage
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGERIGHT
			mov		eax,ysinf.nPos
			add		eax,ysinf.nPage
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScrooll:
	invoke GetClientRect,hWin,addr rect
	sub		rect.bottom,TEXTHIGHT
	;Init horizontal scrollbar
	mov		xsinf.cbSize,sizeof SCROLLINFO
	mov		xsinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
	mov		xsinf.nMin,0
	mov		eax,256
	mov		ecx,ddsdata.xmag
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
	mov		ecx,256
	div		ecx
	mov		xsinf.nMax,eax
	mov		eax,rect.right
	inc		eax
	mov		xsinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
	;Init vertical scrollbar
	mov		ysinf.cbSize,sizeof SCROLLINFO
	mov		ysinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
	mov		ysinf.nMin,0
	mov		eax,DACMAX
	mov		ecx,ddsdata.ymag
	.if ecx>YMAGMAX/16
		sub		ecx,YMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<YMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,YMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.bottom
	mul		ecx
	mov		ecx,DACMAX
	div		ecx
	mov		ysinf.nMax,eax
	mov		eax,rect.bottom
	inc		eax
	mov		ysinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr ysinf,TRUE
	add		rect.bottom,TEXTHIGHT
	retn

GetPoint:
	;Get X position
	mov		eax,edi
	mov		ecx,ddsdata.xmag
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
	mov		ecx,ddsdata.DDS_SampleSize
	shr		ecx,1
	div		ecx
	sub		eax,xsinf.nPos
	mov		pt.x,eax
	;Get y position
	mov		edx,edi
	movzx	eax,word ptr [esi+edx]
	sub		eax,DACMAX
	neg		eax
	mov		ecx,ddsdata.ymag
	.if ecx>YMAGMAX/16
		sub		ecx,YMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<YMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,YMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,DACMAX
	div		ecx
	sub		eax,ysinf.nPos
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
	.if eax==WM_PAINT
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
		fild	ddsdata.DDS_CommandStruct.DDSPhaseFrq
		fmulp	st(1),st
		fild	dds1000
		fmulp	st(1),st
		fistp	tmp

		invoke FormatFrequencyX1000,addr buffer,addr szFmtFrq,tmp
		mov		eax,ddsdata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVmin,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddsdata.DDS_VMax
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVmax,eax
		invoke lstrcat,addr buffer,addr buffer1
		mov		eax,ddsdata.DDS_VMax
		sub		eax,ddsdata.DDS_VMin
		mov		ecx,3000
		mul		ecx
		mov		ecx,4095
		div		ecx
		invoke FormatVoltage,addr buffer1,addr szFmtScopeVpp,eax
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
		mov		esi,offset ddsdata.DDS_PeakData.DDS_PeakData
		xor		edi,edi
		.while edi<ddsdata.SWEEP_StepCount
			mov		edx,edi
			call	GetPoint
			.if sdword ptr pt.x>=0
				mov		eax,rect.bottom
				;sub		eax,10
				invoke MoveToEx,mDC,pt.x,eax,NULL
				invoke LineTo,mDC,pt.x,pt.y
				mov		eax,pt.x
				.break .if sdword ptr eax>rect.right
			.endif
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
	mov		ecx,ddsdata.SWEEP_StepCount
	div		ecx
	mov		pt.x,eax
	;Get y position
	mov		edx,edi
	movzx	eax,word ptr [esi+edx*WORD]
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

DDSWaveGeneratorToolChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DDSWaveGeneratorToolChildProc endp

DDSWaveGeneratorChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		ddsdata.hWndDialog,eax
		invoke GetDlgItem,hWin,IDC_UDCDDSWAVE
		mov		ddsdata.hWndDDS,eax
		invoke GetDlgItem,hWin,IDC_UDCDDSPEAK
		mov		ddsdata.hWndDDSPeak,eax
		invoke CreateDialogParam,hInstance,IDD_DLGDDSWAVETOOL,hWin,addr DDSWaveGeneratorToolChildProc,0
		mov		ddsdata.hWndDDSTool,eax
		mov		ddsdata.DDS_CommandStruct.STM32_Mode,STM32_ModeDDSWave
		mov		ddsdata.DDS_CommandStruct.DDSDacBuffer,TRUE
		invoke DDSHzToPhaseAdd,5000	;5KHz
		mov		ddsdata.DDS_Frequency,eax
		inc		eax
		mov		ddsdata.DDS_CommandStruct.DDSPhaseFrq,eax
		mov		ddsdata.DDSWaveForm,DDS_ModeSinWave
		mov		ddsdata.xmag,22
		mov		ddsdata.ymag,8
		mov		ddsdata.DDS_Amplitude,DACMAX
		mov		ddsdata.DDS_DCOffset,DACMAX
		invoke DDSHzToPhaseAdd,10	;10Hz
		mov		ddsdata.SWEEP_StepSize,eax
		mov		ddsdata.DDS_CommandStruct.SWEEP_StepTime,999
		mov		ddsdata.SWEEP_StepCount,100
		invoke DDSGenWave
		invoke DDSSetWave
		mov		esi,offset DDS_SineWave
		mov		edi,offset ddsdata.DDS_PeakData.DDS_PeakData
		xor		ebx,ebx
		.while ebx<2000
			mov		ax,[esi+ebx*WORD]
			mov		[edi+ebx*WORD],ax
			inc		ebx
		.endw
;		invoke CreateDialogParam,hInstance,IDD_DLGDDSWAVEGENERATOR,NULL,addr DDSWaveGenProc,0
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,135
		sub		rect.bottom,2
		.if ddsdata.DDS_CommandStruct.SWEEP_SubMode==SWEEP_SubModePeak
			invoke ShowWindow,ddsdata.hWndDDSPeak,SW_SHOWNA
			mov		ebx,rect.bottom
			shr		ebx,1
			invoke MoveWindow,ddsdata.hWndDDS,0,0,rect.right,ebx,TRUE
			add		ebx,2
			mov		eax,rect.bottom
			sub		eax,ebx
			invoke MoveWindow,ddsdata.hWndDDSPeak,0,ebx,rect.right,eax,TRUE
		.else
			invoke MoveWindow,ddsdata.hWndDDS,0,0,rect.right,rect.bottom,TRUE
			invoke ShowWindow,ddsdata.hWndDDSPeak,SW_HIDE
		.endif
		invoke MoveWindow,ddsdata.hWndDDSTool,rect.right,0,135,120,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DDSWaveGeneratorChildProc endp
