
IDD_DLGSONAR            equ 1500
IDC_TRBSONARGAIN        equ 1504
IDC_CHKSONARGAIN        equ 1503
IDC_TRBSONARPING        equ 1510
IDC_CHKSONARPING        equ 1509
IDC_TRBSONARRANGE       equ 1507
IDC_CHKSONARRANGE       equ 1506
IDC_TRBSONARNOISE       equ 1501
IDC_TRBSONARREJECT		equ 1534
IDC_TRBSONARFISH        equ 1530
IDC_CHKSONARALARM       equ 1514
IDC_TRBSONARCHART       equ 1512
IDC_CHKCHARTPAUSE       equ 1532
IDC_TRBPINGTIMER        equ 1526
IDC_TRBSOUNDSPEED       equ 1528
IDC_BTNGD               equ 1502
IDC_BTNGU               equ 1505
IDC_BTNPU               equ 1508
IDC_BTNPD               equ 1511
IDC_BTNRU               equ 1513
IDC_BTNRD               equ 1516
IDC_BTNCU               equ 1517
IDC_BTNCD               equ 1518
IDC_BTNNU               equ 1519
IDC_BTNND               equ 1520
IDC_BTNNRD				equ 1535
IDC_BTNNRU				equ 1533
IDC_BTNPTU              equ 1525
IDC_BTNPTD              equ 1527
IDC_BTNSSU              equ 1523
IDC_BTNSSD              equ 1529
IDC_BTNFU               equ 1515
IDC_BTNFD               equ 1531
IDC_STCGAIN				equ 1521
IDC_STCPING				equ 1536

IDD_DLGSONARGAIN		equ 1600
IDC_BTNXD				equ 1604
IDC_BTNXU				equ 1601
IDC_BTNYD				equ 1602
IDC_BTNYU				equ 1605
IDC_CBORANGE			equ 1603
IDC_STCX				equ 1606
IDC_STCY				equ 1607
IDC_EDTGAINOFS			equ 1608
IDC_EDTGAINMAX			equ 1609
IDC_BTNCALCULATE		equ 1610

GAINXOFS				equ 60
GAINYOFS				equ 117

.code

GetRangePtr proc uses edx,RangeInx:DWORD

	mov		eax,RangeInx
	mov		edx,sizeof RANGE
	mul		edx
	ret

GetRangePtr endp

SetRange proc uses ebx,RangeInx:DWORD

	mov		eax,RangeInx
	mov		sonardata.RangeInx,al
	invoke GetRangePtr,eax
	mov		ebx,eax
	mov		eax,sonardata.sonarrange.pixeltimer[ebx]
	mov		sonardata.PixelTimer,ax
	mov		eax,sonardata.sonarrange.range[ebx]
	mov		sonardata.RangeVal,eax
	invoke wsprintf,addr sonardata.options.text,addr szFmtDec,eax
	ret

SetRange endp

ButtonProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	.data?
		nCount		DWORD ?
	.code
	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN || eax==WM_LBUTTONDBLCLK
		mov		nCount,16
		invoke SetTimer,hWin,1000,500,NULL
	.elseif eax==WM_LBUTTONUP
		mov		nCount,16
		invoke KillTimer,hWin,1000
	.elseif eax==WM_TIMER
		invoke GetWindowLong,hWin,GWL_ID
		mov		ebx,eax
		invoke GetParent,hWin
		mov		esi,eax
		invoke SendMessage,esi,WM_COMMAND,ebx,hWin
		mov		edi,nCount
		shr		edi,4
		.if edi>40
			mov		edi,40
		.endif
		.while edi
			invoke SendMessage,esi,WM_COMMAND,ebx,hWin
			dec		edi
		.endw
		invoke KillTimer,hWin,1000
		invoke SetTimer,hWin,1000,50,NULL
		inc		nCount
		xor		eax,eax
		ret
	.endif
	invoke CallWindowProc,lpOldButtonProc,hWin,uMsg,wParam,lParam
	ret

ButtonProc endp

;Description
;===========
;A short ping at 200KHz is transmitted at intervalls depending on range.
;From the time it takes for the echo to return we can calculate the depth.
;The ADC measures the strenght of the echo at intervalls depending on range
;and stores it in a 512 byte array.
;
;Speed of sound in water
;=======================
;Temp (C)    Speed (m/s)
;  0             1403
;  5             1427
; 10             1447
; 20             1481
; 30             1507
; 40             1526
;
;1450m/s is probably a good estimate.
;
;The timer is clocked at 56 MHz so it increments every 0,0178571 us.
;For each tick the sound travels 1450 * 0,0178571 = 25,8929 um or 25,8929e-6 meters.

;Timer value calculation
;=======================
;Example 2m range and 56 MHz clock
;Timer period Tp=1/56MHz
;Each pixel is Px=2m/512.
;Time for each pixel is t=Px/1450/2
;Timer ticks Tt=t/Tp

;Formula T=((Range/512)/(1450/2))56000000

RangeToTimer proc RangeInx:DWORD
	LOCAL	tmp:DWORD

	invoke GetRangePtr,RangeInx
	mov		eax,sonardata.sonarrange.range[eax]
	mov		tmp,eax
	fild	tmp
	mov		tmp,MAXYECHO
	fild	tmp
	fdivp	st(1),st
	mov		eax,sonardata.SoundSpeed
	shr		eax,1			;Divide by 2 since it is the echo
	mov		tmp,eax
	fild	tmp
	fdivp	st(1),st
	mov		tmp,STM32_Clock
	fild	tmp
	fmulp	st(1),st
	fistp	tmp
	mov		eax,tmp
	dec		eax
	ret

RangeToTimer endp

SetupPixelTimer proc uses ebx edi
	
	xor		ebx,ebx
	mov		edi,offset sonardata.sonarrange
	.while ebx<sonardata.MaxRange
		invoke RangeToTimer,ebx
		mov		[edi].RANGE.pixeltimer,eax
		inc		ebx
		lea		edi,[edi+sizeof RANGE]
	.endw
	movzx	eax,sonardata.RangeInx
	invoke SetRange,eax
	ret

SetupPixelTimer endp

SetupGainArray proc uses ebx esi edi
	LOCAL	tmp:DWORD
	LOCAL	ftmp1:REAL8
	LOCAL	ftmp2:REAL8

	;Calculate the missing gain levels
	xor		ebx,ebx
	xor		edi,edi
	.while ebx<sonardata.MaxRange
		xor		esi,esi
		mov		ecx,sonardata.sonarrange.gain[edi+esi*DWORD]
		.while esi<MAXYECHO
			mov		eax,sonardata.sonarrange.gain[edi+esi*DWORD+32*DWORD]
			push	eax
			sub		eax,ecx
			mov		tmp,eax
			fild	tmp
			mov		tmp,32
			fild	tmp
			fdivp	st(1),st
			fstp	ftmp1
			mov		tmp,ecx
			fild	tmp
			fstp	ftmp2
			push	ebx
			mov		ebx,1
			.while ebx<32
				fld		ftmp1
				fld		ftmp2
				faddp	st(1),st
				fst		ftmp2
				fistp	tmp
				mov		eax,tmp
				lea		edx,[esi+ebx]
				mov		sonardata.sonarrange.gain[edi+edx*DWORD],eax
				inc		ebx
			.endw
			pop		ebx
			pop		ecx
			lea		esi,[esi+32]
		.endw
		lea		edi,[edi+sizeof RANGE]
		inc		ebx
	.endw
	ret

SetupGainArray endp

SonarOptionProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		.if sonardata.AutoRange
			invoke CheckDlgButton,hWin,IDC_CHKSONARRANGE,BST_CHECKED
		.endif
		mov		eax,sonardata.MaxRange
		dec		eax
		shl		eax,16
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARRANGE,TBM_SETRANGE,FALSE,eax
		movzx	eax,sonardata.RangeInx
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARRANGE,TBM_SETPOS,TRUE,eax
		.if sonardata.AutoGain
			invoke CheckDlgButton,hWin,IDC_CHKSONARGAIN,BST_CHECKED
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARGAIN,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARGAIN,TBM_SETPOS,TRUE,sonardata.GainSet
		.if sonardata.AutoPing
			invoke CheckDlgButton,hWin,IDC_CHKSONARPING,BST_CHECKED
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARPING,TBM_SETRANGE,FALSE,(MAXPING SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARPING,TBM_SETPOS,TRUE,sonardata.PingInit
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARNOISE,TBM_SETRANGE,FALSE,(255 SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARNOISE,TBM_SETPOS,TRUE,sonardata.NoiseLevel
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARREJECT,TBM_SETRANGE,FALSE,(3 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARREJECT,TBM_SETPOS,TRUE,sonardata.NoiseReject
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARFISH,TBM_SETRANGE,FALSE,(3 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARFISH,TBM_SETPOS,TRUE,sonardata.FishDetect
		.if sonardata.FishAlarm
			invoke CheckDlgButton,hWin,IDC_CHKSONARALARM,BST_CHECKED
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARCHART,TBM_SETRANGE,FALSE,(4 SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBSONARCHART,TBM_SETPOS,TRUE,sonardata.ChartSpeed
		invoke IsDlgButtonChecked,hWnd,IDC_CHKCHART
		.if eax
			invoke CheckDlgButton,hWin,IDC_CHKCHARTPAUSE,BST_CHECKED
		.endif
		invoke SendDlgItemMessage,hWin,IDC_TRBPINGTIMER,TBM_SETRANGE,FALSE,((STM32_PingTimer+1) SHL 16)+STM32_PingTimer-1
		movzx	eax,sonardata.PingTimer
		invoke SendDlgItemMessage,hWin,IDC_TRBPINGTIMER,TBM_SETPOS,TRUE,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBSOUNDSPEED,TBM_SETRANGE,FALSE,((SOUNDSPEEDMAX) SHL 16)+SOUNDSPEEDMIN
		invoke SendDlgItemMessage,hWin,IDC_TRBSOUNDSPEED,TBM_SETPOS,TRUE,sonardata.SoundSpeed
		invoke ImageList_GetIcon,hIml,6,ILD_NORMAL
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_BTNNRD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNGD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNPD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNRD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNCD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNND,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNSSD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNPTD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNFD,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke ImageList_GetIcon,hIml,2,ILD_NORMAL
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_BTNNRU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNGU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNPU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNRU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNCU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNNU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNSSU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNPTU,BM_SETIMAGE,IMAGE_ICON,ebx
		invoke SendDlgItemMessage,hWin,IDC_BTNFU,BM_SETIMAGE,IMAGE_ICON,ebx
		;Subclass buttons to get autorepeat
		push	0
		push	IDC_BTNNRD
		push	IDC_BTNNRU
		push	IDC_BTNGD
		push	IDC_BTNGU
		push	IDC_BTNPD
		push	IDC_BTNPU
		push	IDC_BTNRD
		push	IDC_BTNRU
		push	IDC_BTNCD
		push	IDC_BTNCU
		push	IDC_BTNND
		push	IDC_BTNNU
		push	IDC_BTNSSD
		push	IDC_BTNSSU
		push	IDC_BTNPTD
		push	IDC_BTNPTU
		push	IDC_BTNFD
		mov		eax,IDC_BTNFU
		.while eax
			invoke GetDlgItem,hWin,eax
			invoke SetWindowLong,eax,GWL_WNDPROC,offset ButtonProc
			mov		lpOldButtonProc,eax
			pop		eax
		.endw
		call	SetGain
		call	SetPing
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,NULL,FALSE
			.elseif eax==IDC_CHKSONARGAIN
				xor		sonardata.AutoGain,1
			.elseif eax==IDC_CHKSONARPING
				xor		sonardata.AutoPing,1
			.elseif eax==IDC_CHKSONARRANGE
				xor		sonardata.AutoRange,1
			.elseif eax==IDC_CHKCHARTPAUSE
				invoke IsDlgButtonChecked,hWin,IDC_CHKCHARTPAUSE
				.if eax
					mov		eax,BST_CHECKED
				.endif
				invoke CheckDlgButton,hWnd,IDC_CHKCHART,eax
			.elseif eax==IDC_CHKSONARALARM
				xor		sonardata.FishAlarm,1
			.elseif eax==IDC_BTNGD
				.if sonardata.GainSet
					dec		sonardata.GainSet
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARGAIN,TBM_SETPOS,TRUE,sonardata.GainSet
					mov		sonardata.fGainUpload,TRUE
					call	SetGain
				.endif
			.elseif eax==IDC_BTNGU
				.if sonardata.GainSet<4095
					inc		sonardata.GainSet
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARGAIN,TBM_SETPOS,TRUE,sonardata.GainSet
					mov		sonardata.fGainUpload,TRUE
					call	SetGain
				.endif
			.elseif eax==IDC_BTNPD
				.if sonardata.PingInit>1
					dec		sonardata.PingInit
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARPING,TBM_SETPOS,TRUE,sonardata.PingInit
					call	SetPing
				.endif
			.elseif eax==IDC_BTNPU
				.if sonardata.PingInit<MAXPING
					inc		sonardata.PingInit
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARPING,TBM_SETPOS,TRUE,sonardata.PingInit
					call	SetPing
				.endif
			.elseif eax==IDC_BTNRD
				.if sonardata.RangeInx
					dec		sonardata.RangeInx
					movzx	eax,sonardata.RangeInx
					invoke SetRange,eax
					movzx	eax,sonardata.RangeInx
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARRANGE,TBM_SETPOS,TRUE,eax
					mov		sonardata.fGainUpload,TRUE
				.endif
			.elseif eax==IDC_BTNRU
				mov		eax,sonardata.MaxRange
				dec		eax
				.if al>sonardata.RangeInx
					inc		sonardata.RangeInx
					movzx	eax,sonardata.RangeInx
					invoke SetRange,eax
					movzx	eax,sonardata.RangeInx
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARRANGE,TBM_SETPOS,TRUE,eax
					mov		sonardata.fGainUpload,TRUE
				.endif
			.elseif eax==IDC_BTNND
				.if sonardata.NoiseLevel>1
					dec		sonardata.NoiseLevel
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARNOISE,TBM_SETPOS,TRUE,sonardata.NoiseLevel
				.endif
			.elseif eax==IDC_BTNNU
				.if sonardata.NoiseLevel<255
					inc		sonardata.NoiseLevel
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARNOISE,TBM_SETPOS,TRUE,sonardata.NoiseLevel
				.endif
			.elseif eax==IDC_BTNNRD
				.if sonardata.NoiseReject
					dec		sonardata.NoiseReject
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARREJECT,TBM_SETPOS,TRUE,sonardata.NoiseReject
				.endif
			.elseif eax==IDC_BTNNRU
				.if sonardata.NoiseReject<3
					inc		sonardata.NoiseReject
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARREJECT,TBM_SETPOS,TRUE,sonardata.NoiseReject
				.endif
			.elseif eax==IDC_BTNFD
				.if sonardata.FishDetect
					dec		sonardata.FishDetect
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARFISH,TBM_SETPOS,TRUE,sonardata.FishDetect
				.endif
			.elseif eax==IDC_BTNFU
				.if sonardata.FishDetect<3
					inc		sonardata.FishDetect
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARFISH,TBM_SETPOS,TRUE,sonardata.FishDetect
				.endif
			.elseif eax==IDC_BTNCD
				.if sonardata.ChartSpeed>1
					dec		sonardata.ChartSpeed
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARCHART,TBM_SETPOS,TRUE,sonardata.ChartSpeed
				.endif
			.elseif eax==IDC_BTNCU
				.if sonardata.ChartSpeed<4
					inc		sonardata.ChartSpeed
					invoke SendDlgItemMessage,hWin,IDC_TRBSONARCHART,TBM_SETPOS,TRUE,sonardata.ChartSpeed
				.endif
			.elseif eax==IDC_BTNPTD
				.if sonardata.PingTimer>STM32_PingTimer-2
					dec		sonardata.PingTimer
					movzx	eax,sonardata.PingTimer
					invoke SendDlgItemMessage,hWin,IDC_TRBPINGTIMER,TBM_SETPOS,TRUE,eax
				.endif
			.elseif eax==IDC_BTNPTU
				.if sonardata.PingTimer<STM32_PingTimer+2
					inc		sonardata.PingTimer
					movzx	eax,sonardata.PingTimer
					invoke SendDlgItemMessage,hWin,IDC_TRBPINGTIMER,TBM_SETPOS,TRUE,eax
				.endif
			.elseif eax==IDC_BTNSSU
				.if sonardata.SoundSpeed<SOUNDSPEEDMAX
					inc		sonardata.SoundSpeed
					invoke SendDlgItemMessage,hWin,IDC_TRBSOUNDSPEED,TBM_SETPOS,TRUE,sonardata.SoundSpeed
					invoke SetupPixelTimer
				.endif
			.elseif eax==IDC_BTNSSD
				.if sonardata.SoundSpeed>SOUNDSPEEDMIN
					dec		sonardata.SoundSpeed
					invoke SendDlgItemMessage,hWin,IDC_TRBSOUNDSPEED,TBM_SETPOS,TRUE,sonardata.SoundSpeed
					invoke SetupPixelTimer
				.endif
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		invoke SendMessage,lParam,TBM_GETPOS,0,0
		mov		ebx,eax
		invoke GetDlgCtrlID,lParam
		.if eax==IDC_TRBSONARGAIN
			mov		sonardata.GainSet,ebx
			mov		sonardata.fGainUpload,TRUE
			call	SetGain
		.elseif eax==IDC_TRBSONARRANGE
			mov		sonardata.RangeInx,bl
			invoke SetRange,ebx
			mov		sonardata.fGainUpload,TRUE
		.elseif eax==IDC_TRBSONARNOISE
			mov		sonardata.NoiseLevel,ebx
		.elseif eax==IDC_TRBSONARREJECT
			mov		sonardata.NoiseReject,ebx
		.elseif eax==IDC_TRBSONARPING
			mov		sonardata.PingInit,ebx
			call	SetPing
		.elseif eax==IDC_TRBSONARFISH
			mov		sonardata.FishDetect,ebx
		.elseif eax==IDC_TRBSONARCHART
			mov		sonardata.ChartSpeed,ebx
		.elseif eax==IDC_TRBPINGTIMER
			mov		sonardata.PingTimer,bl
		.elseif eax==IDC_TRBSOUNDSPEED
			mov		sonardata.SoundSpeed,ebx
			invoke SetupPixelTimer
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SetGain:
	invoke SetDlgItemInt,hWin,IDC_STCGAIN,sonardata.GainSet,FALSE
	retn

SetPing:
	invoke SetDlgItemInt,hWin,IDC_STCPING,sonardata.PingInit,FALSE
	retn

SonarOptionProc endp

SonarGainOptionProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	ps:PAINTSTRUCT
	LOCAL	buffer[256]:BYTE
	LOCAL	tmp:DWORD
	LOCAL	ftmp:REAL8
	LOCAL	frng:REAL8

	.data?
		xrange	DWORD ?
		xp		DWORD ?
		yp		DWORD ?
		pgain	DWORD ?
	.code

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		esi,offset sonardata.sonarrange
		xor		ebx,ebx
		.while ebx<sonardata.MaxRange
			mov		eax,[esi].RANGE.range
			invoke wsprintf,addr buffer,addr szFmtDec,eax
			invoke SendDlgItemMessage,hWin,IDC_CBORANGE,CB_ADDSTRING,0,addr buffer
			lea		esi,[esi+sizeof RANGE]
			inc		ebx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBORANGE,CB_SETCURSEL,0,0
		mov		xp,0
		mov		yp,0
		invoke ImageList_GetIcon,hIml,0,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNYU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,4,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNYD,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,6,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNXD,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNXU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke SetDlgItemInt,hWin,IDC_EDTGAINOFS,sonardata.gainofs,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTGAINOFS,EM_LIMITTEXT,3,0
		invoke SetDlgItemInt,hWin,IDC_EDTGAINMAX,sonardata.gainmax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTGAINMAX,EM_LIMITTEXT,3,0
		;Subclass buttons to get autorepeat
		push	0
		push	IDC_BTNXD
		push	IDC_BTNXU
		push	IDC_BTNYD
		mov		eax,IDC_BTNYU
		.while eax
			invoke GetDlgItem,hWin,eax
			invoke SetWindowLong,eax,GWL_WNDPROC,offset ButtonProc
			mov		lpOldButtonProc,eax
			pop		eax
		.endw
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				xor		ebx,ebx
				mov		esi,offset sonardata.sonarrange
				.while ebx<sonardata.MaxRange
					push	ebx
					push	esi
					mov		szbuff,0
					invoke PutItemInt,addr szbuff,[esi].RANGE.range
					invoke PutItemInt,addr szbuff,[esi].RANGE.interval
					invoke PutItemInt,addr szbuff,[esi].RANGE.pingadd
					xor		ebx,ebx
					.while ebx<=MAXYECHO
						invoke PutItemInt,addr szbuff,[esi].RANGE.gain[ebx*DWORD]
						lea		ebx,[ebx+32]
					.endw
					mov		ebx,[esi].RANGE.nticks
					lea		esi,[esi].RANGE.scale
					.while sdword ptr ebx>=0
						invoke PutItemStr,addr szbuff,esi
						invoke strlen,esi
						lea		esi,[esi+eax+1]
						dec		ebx
					.endw
					pop		esi
					pop		ebx
					invoke wsprintf,addr buffer,addr szFmtDec,ebx
					invoke WritePrivateProfileString,addr szIniSonarRange,addr buffer,addr szbuff+1,addr szIniFileName
					lea		esi,[esi+sizeof RANGE]
					inc		ebx
				.endw
				invoke EndDialog,hWin,NULL
			.elseif eax==IDC_BTNCALCULATE
				invoke GetDlgItemInt,hWin,IDC_EDTGAINOFS,NULL,FALSE
				mov		sonardata.gainofs,eax
				invoke GetDlgItemInt,hWin,IDC_EDTGAINMAX,NULL,FALSE
				mov		sonardata.gainmax,eax
				mov		eax,4095
				sub		eax,sonardata.gainofs
				mov		tmp,eax
				fild	tmp
				mov		eax,sonardata.gainmax
				mov		tmp,eax
				fidiv	tmp
				fstp	ftmp
				mov		esi,offset sonardata.sonarrange
				xor		ebx,ebx
				.while ebx<sonardata.MaxRange
					fld		ftmp
					mov		eax,[esi].RANGE.range
					mov		tmp,eax
					fimul	tmp
					fidiv	dd512
					fstp	frng
					fldz
					xor		edi,edi
					.while edi<MAXYECHO
						fist	tmp
						mov		eax,tmp
						mov		[esi].RANGE.gain[edi*DWORD],eax
						fadd	frng
						inc		edi
					.endw
					fistp	tmp
					mov		eax,tmp
					mov		[esi].RANGE.gain[edi*DWORD],eax
					lea		esi,[esi+sizeof RANGE]
					inc		ebx
				.endw
				call	Invalidate
			.elseif eax==IDCANCEL
				invoke EndDialog,hWin,NULL
			.elseif eax==IDC_BTNXD
				.if xp>1
					sub		xp,32
					call	Invalidate
				.endif
			.elseif eax==IDC_BTNXU
				.if xp<512
					add		xp,32
					call	Invalidate
				.endif
			.elseif eax==IDC_BTNYD
				mov		eax,pgain
				.if dword ptr [eax]
					dec		dword ptr [eax]
					invoke SetupGainArray
					call	Invalidate
					mov		sonardata.fGainUpload,TRUE
				.endif
			.elseif eax==IDC_BTNYU
				mov		eax,pgain
				.if dword ptr [eax]<10000
					inc		dword ptr [eax]
					invoke SetupGainArray
					call	Invalidate
					mov		sonardata.fGainUpload,TRUE
				.endif
			.endif
		.elseif edx==CBN_SELCHANGE
			.if eax==IDC_CBORANGE
				call	Invalidate
			.endif
		.endif
	.elseif eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke BeginPaint,hWin,addr ps
		call	DrawGain
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Invalidate:
	invoke GetClientRect,hWin,addr rect
	mov		rect.left,GAINXOFS
	mov		eax,rect.left
	add		eax,260
	mov		rect.right,eax
	mov		rect.top,GAINYOFS-1
	mov		eax,rect.top
	add		eax,261
	mov		rect.bottom,eax
	invoke InvalidateRect,hWin,addr rect,TRUE
	retn

DrawGain:
	invoke CreatePen,PS_SOLID,1,0FFh
	invoke SelectObject,ps.hdc,eax
	push	eax
	mov		ebx,xp
	shr		ebx,1
	add		ebx,GAINXOFS+1
	invoke MoveToEx,ps.hdc,ebx,GAINYOFS,NULL
	invoke LineTo,ps.hdc,ebx,GAINYOFS+260
	invoke SendDlgItemMessage,hWin,IDC_CBORANGE,CB_GETCURSEL,0,0
	mov		ecx,sizeof RANGE
	mul		ecx
	lea		esi,[eax+offset sonardata.sonarrange.gain]
	lea		eax,[eax+offset sonardata.sonarrange]
	mov		eax,[eax].RANGE.range
	mov		xrange,eax
	mov		eax,xp
	lea		esi,[esi+eax*DWORD]
	mov		pgain,esi
	mov		eax,[esi]
	add		eax,sonardata.gainofs
	.if eax>4095
		mov		eax,4095
	.endif
	mov		yp,eax
	mov		ebx,yp
	shr		ebx,4
	sub		ebx,256
	neg		ebx
	add		ebx,GAINYOFS
	invoke MoveToEx,ps.hdc,GAINXOFS,ebx,NULL
	invoke LineTo,ps.hdc,GAINXOFS+260,ebx
	mov		eax,xrange
	mov		ecx,100
	imul	ecx
	mov		ecx,xp
	imul	ecx
	shr		eax,9
	invoke wsprintf,addr szbuff,addr szFmtDec3,eax
	invoke strlen,addr szbuff
	mov		ecx,dword ptr szbuff[eax-2]
	mov		szbuff[eax-2],'.'
	mov		dword ptr szbuff[eax-1],ecx
	invoke SetDlgItemText,hWin,IDC_STCX,addr szbuff
	invoke SetDlgItemInt,hWin,IDC_STCY,yp,FALSE
	pop		eax
	invoke SelectObject,ps.hdc,eax
	invoke DeleteObject,eax
	invoke CreatePen,PS_SOLID,2,0
	invoke SelectObject,ps.hdc,eax
	push		eax
	;Y-axis
	invoke MoveToEx,ps.hdc,GAINXOFS,GAINYOFS,NULL
	invoke LineTo,ps.hdc,GAINXOFS,GAINYOFS+260
	;X-axis
	invoke MoveToEx,ps.hdc,GAINXOFS,GAINYOFS+260,NULL
	invoke LineTo,ps.hdc,260+GAINXOFS,GAINYOFS+260
	pop		eax
	invoke SelectObject,ps.hdc,eax
	invoke DeleteObject,eax
	invoke CreatePen,PS_SOLID,2,0FF0000h
	invoke SelectObject,ps.hdc,eax
	push		eax
	invoke SendDlgItemMessage,hWin,IDC_CBORANGE,CB_GETCURSEL,0,0
	mov		ecx,sizeof RANGE
	mul		ecx
	lea		esi,[eax+offset sonardata.sonarrange.gain]
	xor		ebx,ebx
	.while ebx<512
		mov		eax,[esi]
		add		eax,sonardata.gainofs
		.if eax>4095
			mov		eax,4095
		.endif
		sub		eax,4095
		neg		eax
		shr		eax,4
		add		eax,GAINYOFS
		mov		edx,ebx
		shr		edx,1
		add		edx,GAINXOFS+1
		.if !ebx
			push	eax
			push	edx
			invoke MoveToEx,ps.hdc,edx,eax,NULL
			pop		edx
			pop		eax
		.endif
		invoke LineTo,ps.hdc,edx,eax
		lea		esi,[esi+DWORD]
		inc		ebx
	.endw
	pop		eax
	invoke SelectObject,ps.hdc,eax
	invoke DeleteObject,eax
	retn

SonarGainOptionProc endp

Random proc uses ecx edx,range:DWORD

	mov		eax,rseed
	mov		ecx,23
	mul		ecx
	add		eax,7
	and		eax,0FFFFFFFFh
	ror		eax,1
	xor		eax,rseed
	mov		rseed,eax
	mov		ecx,range
	xor		edx,edx
	div		ecx
	mov		eax,edx
	ret

Random endp

Resize_Image proc uses ebx esi edi,hBmp:HBITMAP,wt:DWORD,ht:DWORD
	LOCAL	iwt:DWORD
	LOCAL	iht:DWORD
	LOCAL	image1:DWORD
	LOCAL	image2:DWORD
	LOCAL	gfx:DWORD
	LOCAL	lFormat:DWORD
	LOCAL	hBmpRet:HBITMAP

	invoke GdipCreateBitmapFromHBITMAP,hBmp,0,addr image1
	invoke GdipGetImageWidth,image1,addr iwt
	invoke GdipGetImageHeight,image1,addr iht
	invoke GdipGetImagePixelFormat,image1,addr lFormat
	invoke GdipCreateBitmapFromScan0,wt,ht,0,lFormat,0,addr image2
	invoke GdipGetImageGraphicsContext,image2,addr gfx
	invoke GdipSetInterpolationMode,gfx,InterpolationModeNearestNeighbor
	invoke GdipDrawImageRectI,gfx,image1,0,0,wt,ht
	invoke GdipDisposeImage,image1
	invoke GdipCreateHBITMAPFromBitmap,image2,addr hBmpRet,0
	invoke GdipDisposeImage,image2
	invoke GdipDeleteGraphics,gfx
	mov		eax,hBmpRet
	ret

Resize_Image endp

UpdateBitmap proc uses ebx esi edi,NewRange:DWORD
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	wt:DWORD

	invoke GetDC,hSonar
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke ReleaseDC,hSonar,hDC
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,MAXXECHO
	mov		rect.bottom,MAXYECHO
	invoke FillRect,sonardata.mDC,addr rect,sonardata.hBrBack
	mov		esi,offset sonardata.sonarbmp
	xor		ebx,ebx
	.while ebx<MAXSONARBMP
		.if [esi].SONARBMP.hBmp
			mov		eax,[esi].SONARBMP.xpos
			add		eax,[esi].SONARBMP.wt
			.if sdword ptr eax>0 && [esi].SONARBMP.wt
				invoke GetRangePtr,[esi].SONARBMP.RangeInx
				mov		ecx,sonardata.sonarrange.range[eax]
				mov		eax,MAXYECHO
				mul		ecx
				mov		ecx,NewRange
				div		ecx
				mov		edx,[esi].SONARBMP.wt
				invoke Resize_Image,[esi].SONARBMP.hBmp,edx,eax
				invoke SelectObject,mDC,eax
				push	eax
				invoke GetRangePtr,[esi].SONARBMP.RangeInx
				mov		ecx,sonardata.sonarrange.range[eax]
				mov		eax,MAXYECHO
				mul		ecx
				mov		ecx,NewRange
				div		ecx
				mov		edx,[esi].SONARBMP.wt
				mov		ecx,[esi].SONARBMP.xpos
				xor		edi,edi
				.if sdword ptr ecx<0
					neg		ecx
					mov		edi,ecx
					sub		edx,ecx
					xor		ecx,ecx
				.endif
				invoke BitBlt,sonardata.mDC,ecx,0,edx,eax,mDC,edi,0,SRCCOPY
				pop		eax
				invoke SelectObject,mDC,eax
				invoke DeleteObject,eax
			.else
				invoke DeleteObject,[esi].SONARBMP.hBmp
				mov		[esi].SONARBMP.hBmp,0
			.endif
		.endif
		lea		esi,[esi+sizeof SONARBMP]
		inc		ebx
	.endw
	invoke DeleteDC,mDC
	ret

UpdateBitmap endp

SonarUpdateProc proc uses ebx esi edi
	LOCAL	rect:RECT
	LOCAL	buffer[256]:BYTE
	LOCAL	tmp:DWORD
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC

	.if sonardata.hReply
		call	Update
		;Update range
		movzx	eax,sonardata.EchoArray
		mov		sonardata.RangeInx,al
	.elseif sonardata.fSTLink
		call	Update
	.endif
	ret

SetBattery:
	.if eax!=sonardata.Battery
		mov		sonardata.Battery,eax
		mov		ecx,100
		mul		ecx
		mov		ecx,1792
		div		ecx
		invoke wsprintf,addr buffer,addr szFmtVolts,eax
		invoke strlen,addr buffer
		movzx	ecx,word ptr buffer[eax-1]
		shl		ecx,8
		mov		cl,'.'
		mov		dword ptr buffer[eax-1],ecx
		invoke strcat,addr buffer,addr szVolts
		invoke strcpy,addr map.options.text[sizeof OPTIONS],addr buffer
		invoke InvalidateRect,hMap,NULL,TRUE
	.endif
	retn

SetWTemp:
	.if eax!=sonardata.WTemp
		mov		sonardata.WTemp,eax
		sub		eax,0BC8h
		neg		eax
		mov		tmp,eax
		fild	tmp
		fld		watertempconv
		fdivp	st(1),st
		fistp	tmp
		sub		tmp,164
		invoke wsprintf,addr buffer,addr szFmtDec,tmp
		invoke strlen,addr buffer
		movzx	ecx,word ptr buffer[eax-1]
		shl		ecx,8
		mov		cl,'.'
		mov		dword ptr buffer[eax-1],ecx
		invoke strcat,addr buffer,addr szCelcius
		invoke strcpy,addr sonardata.options.text[sizeof OPTIONS*2],addr buffer
	.endif
	retn

SetATemp:
	.if eax!=sonardata.ATemp
		xor		ebx,ebx
		mov		esi,offset atemp
		.while ebx<NATEMP
			.if eax<[esi+ebx*sizeof TEMP].TEMP.adcvalue && eax>=[esi+ebx*sizeof TEMP+sizeof TEMP].TEMP.adcvalue
				.break
			.endif
			inc		ebx
		.endw
		.if ebx<NATEMP
			mov		sonardata.ATemp,eax
			;Tx=(T1-T2)/(V1-V2)*(V1-Vx)+T1
			mov		eax,[esi+ebx*sizeof TEMP].TEMP.temp
			sub		eax,[esi+ebx*sizeof TEMP+sizeof TEMP].TEMP.temp
			mov		tmp,eax
			fild	tmp
			mov		eax,[esi+ebx*sizeof TEMP].TEMP.adcvalue
			sub		eax,[esi+ebx*sizeof TEMP+sizeof TEMP].TEMP.adcvalue
			mov		tmp,eax
			fild	tmp
			fdivp	st(1),st
			mov		eax,[esi+ebx*sizeof TEMP].TEMP.adcvalue
			sub		eax,sonardata.ATemp
			mov		tmp,eax
			fild	tmp
			fmulp	st(1),st
			fistp	tmp
			mov		eax,[esi+ebx*sizeof TEMP].TEMP.temp
			sub		eax,tmp
			sub		eax,20
			mov		tmp,eax
			invoke wsprintf,addr buffer,addr szFmtDec,tmp
			invoke strlen,addr buffer
			movzx	ecx,word ptr buffer[eax-1]
			shl		ecx,8
			mov		cl,'.'
			mov		dword ptr buffer[eax-1],ecx
			invoke strcat,addr buffer,addr szCelcius
			invoke strcpy,addr map.options.text[sizeof OPTIONS*2],addr buffer
		.endif
	.endif
	retn

GetBitmap:
	invoke GetDC,hSonar
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,sonardata.sonarbmp.wt,MAXYECHO
	invoke SelectObject,mDC,eax
	push	eax
	invoke ReleaseDC,hSonar,hDC
	mov		eax,MAXXECHO
	sub		eax,sonardata.sonarbmp.wt
	invoke BitBlt,mDC,0,0,sonardata.sonarbmp.wt,MAXYECHO,sonardata.mDC,eax,0,SRCCOPY
	pop		eax
	invoke SelectObject,mDC,eax
	mov		sonardata.sonarbmp.hBmp,eax
	invoke DeleteDC,mDC
	retn

ScrollBitmapArray:
	lea		edi,sonardata.sonarbmp[sizeof SONARBMP*(MAXSONARBMP-1)]
	.if [edi].SONARBMP.hBmp
		invoke DeleteObject,[edi].SONARBMP.hBmp
	.endif
	mov		ebx,MAXSONARBMP-1
	.while ebx
		lea		esi,[edi-sizeof SONARBMP]
		invoke RtlMoveMemory,edi,esi,sizeof SONARBMP
		lea		edi,[edi-sizeof SONARBMP]
		dec		ebx
	.endw
	movzx	eax,sonardata.EchoArray
	mov		sonardata.sonarbmp.RangeInx,eax
	mov		sonardata.sonarbmp.xpos,MAXXECHO
	mov		sonardata.sonarbmp.wt,0
	mov		sonardata.sonarbmp.hBmp,0
	retn

UpdateBitmapArray:
	lea		edi,sonardata.sonarbmp[sizeof SONARBMP*(MAXSONARBMP-1)]
	mov		edx,MAXSONARBMP-1
	.while edx
		.if [edi].SONARBMP.hBmp
			dec		[edi].SONARBMP.xpos
			mov		eax,[edi].SONARBMP.xpos
			add		eax,[edi].SONARBMP.wt
			.if sdword ptr eax<=0
				;Delete the bitmap, it is no longer needed
				push	edx
				invoke DeleteObject,[edi].SONARBMP.hBmp
				pop		edx
				mov		[edi].SONARBMP.hBmp,0
			.endif
		.endif
		lea		edi,[edi-sizeof SONARBMP]
		dec		edx
	.endw
	.if [edi].SONARBMP.wt<MAXXECHO
		inc		[edi].SONARBMP.wt
		dec		[edi].SONARBMP.xpos
	.endif
	retn

Update:
	;Battery
	movzx	eax,sonardata.ADCBattery
	call	SetBattery
	;Water temprature
	movzx	eax,sonardata.ADCWaterTemp
	call	SetWTemp
	;Air temprature
	movzx	eax,sonardata.ADCAirTemp
	call	SetATemp
	;Check if range is still the same
	movzx	eax,STM32Echo
	.if eax!=sonardata.sonarbmp.RangeInx
		;Get bitmap
		call	GetBitmap
		call	ScrollBitmapArray
		invoke GetRangePtr,sonardata.sonarbmp.RangeInx
		invoke UpdateBitmap,sonardata.sonarrange.range[eax]
	.endif
	call	UpdateBitmapArray
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,MAXXECHO
	mov		rect.bottom,MAXYECHO
	invoke ScrollDC,sonardata.mDC,-1,0,addr rect,addr rect,NULL,NULL
	mov		rect.left,MAXXECHO-1
	mov		rect.top,0
	mov		rect.right,MAXXECHO
	mov		rect.bottom,MAXYECHO
	invoke FillRect,sonardata.mDC,addr rect,sonardata.hBrBack
	;Draw echo
	mov		ebx,1
	.while ebx<MAXYECHO
		movzx	eax,sonardata.EchoArray[ebx]
		.if eax
			.if eax>0D0h
				;Red
			.elseif eax>060h
				;Green
				shl		eax,8
			.elseif eax>040h
				;Yellow
				add		al,080h
				mov		ah,al
			.else
				;Gray
				add		al,08h
				xor		eax,0FFh
				mov		ah,al
				shl		eax,8
				mov		al,ah
			.endif
			invoke SetPixel,sonardata.mDC,MAXXECHO-1,ebx,eax
		.endif
		inc		ebx
	.endw
	;Draw signal bar
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,SIGNALBAR
	mov		rect.bottom,MAXYECHO
	invoke FillRect,sonardata.mDCS,addr rect,sonardata.hBrBack
	mov		ebx,1
	.while ebx<MAXYECHO
		movzx	eax,sonardata.EchoArray[ebx]
		mov		ecx,SIGNALBAR
		mul		ecx
		shr		eax,8
		.if eax
			push	eax
			invoke MoveToEx,sonardata.mDCS,0,ebx,NULL
			pop		eax
			invoke LineTo,sonardata.mDCS,eax,ebx
		.endif
		inc		ebx
	.endw
	invoke InvalidateRect,hSonar,NULL,TRUE
	invoke UpdateWindow,hSonar
	retn

SonarUpdateProc endp

GainUploadThread proc uses ebx,lParam:DWORD

	;Setup gain array
	movzx	ebx,sonardata.RangeInx
	invoke GetRangePtr,ebx
	mov		ebx,eax
	xor		ecx,ecx
	.if sonardata.AutoGain
		;Time dependent gain
		.while ecx<MAXYECHO
			mov		eax,sonardata.sonarrange.gain[ebx+ecx*DWORD]
			;Add fixed gain
			add		eax,sonardata.GainSet
			.if eax>4095
				mov		eax,4095
			.endif
			mov		sonardata.GainArray[ecx*WORD],ax
			inc		ecx
		.endw
	.else
		;Fixed gain
		mov		eax,sonardata.GainSet
		.while ecx<MAXYECHO
			mov		sonardata.GainArray[ecx*WORD],ax
			inc		ecx
		.endw
	.endif
	;Upload Gain array
	invoke STLinkWrite,hWnd,STM32_Sonar+16+MAXYECHO,addr sonardata.GainArray,MAXYECHO*WORD
	xor		eax,eax
	ret

GainUploadThread endp

STM32Thread proc uses ebx esi edi,lParam:DWORD
	LOCAL	status:DWORD
	LOCAL	dwread:DWORD
	LOCAL	dwwrite:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	pixcnt:DWORD
	LOCAL	pixdir:DWORD
	LOCAL	pixmov:DWORD
	LOCAL	pixdpt:DWORD
	LOCAL	rngchanged:DWORD
	LOCAL	nTrail:DWORD
	LOCAL	iLon:DWORD
	LOCAL	iLat:DWORD
	LOCAL	fDist:REAL10
	LOCAL	fBear:REAL10
	LOCAL	iSumDist:DWORD
	LOCAL	ft:FILETIME
	LOCAL	lft:FILETIME
	LOCAL	lst:SYSTEMTIME

	mov		pixcnt,0
	mov		pixdir,0
	mov		pixmov,0
	mov		pixdpt,250
	mov		rngchanged,4
	mov		nTrail,0
	mov		iLat,-1
	mov		iLon,-1
	invoke RtlZeroMemory,addr STM32Echo,sizeof STM32Echo
  Again:
	invoke IsDlgButtonChecked,hWnd,IDC_CHKCHART
	.if eax
		invoke Sleep,250
	.else
		.if sonardata.hReply
			;Copy old echo
			call	MoveEcho
			;Read echo from file
			.if sonarreplay.Version<200
				invoke ReadFile,sonardata.hReply,addr STM32Echo,MAXYECHO,addr dwread,NULL
			.else
				invoke ReadFile,sonardata.hReply,addr sonarreplay,sizeof SONARREPLAY,addr dwread,NULL
				.if dwread==sizeof SONARREPLAY
					movzx	eax,sonarreplay.SoundSpeed
					mov		sonardata.SoundSpeed,eax
					mov		ax,sonarreplay.ADCBattery
					mov		sonardata.ADCBattery,ax
					mov		ax,sonarreplay.ADCWaterTemp
					mov		sonardata.ADCWaterTemp,ax
					mov		ax,sonarreplay.ADCAirTemp
					mov		sonardata.ADCAirTemp,ax
					mov		eax,sonarreplay.iTime
					mov		map.iTime,eax
					mov		ecx,eax
					movzx	edx,ax
					shr		ecx,16
					invoke DosDateTimeToFileTime,ecx,edx,addr ft
					invoke FileTimeToLocalFileTime,addr ft,addr lft
					invoke FileTimeToSystemTime,addr lft,addr lst
					movzx	eax,lst.wSecond
					push	eax
					movzx	eax,lst.wMinute
					push	eax
					movzx	eax,lst.wHour
					push	eax
					movzx	eax,lst.wYear
					sub		eax,1980
					push	eax
					movzx	eax,lst.wMonth
					push	eax
					movzx	eax,lst.wDay
					push	eax
					invoke wsprintf,addr map.options.text[sizeof OPTIONS*4],offset szFmtTime
					mov		eax,sonarreplay.iLon
					mov		map.iLon,eax
					mov		eax,sonarreplay.iLat
					mov		map.iLat,eax
					movzx	eax,sonarreplay.iSpeed
					mov		map.iSpeed,eax
					movzx	eax,sonarreplay.iBear
					mov		map.iBear,eax
					.if eax>360-22 || eax<45-22
						;N
						mov		map.ncursor,0
					.elseif eax<90-22
						;NE
						mov		map.ncursor,1
					.elseif eax<135-22
						;E
						mov		map.ncursor,2
					.elseif eax<180-22
						;SE
						mov		map.ncursor,3
					.elseif eax<225-22
						;S
						mov		map.ncursor,4
					.elseif eax<270-22
						;SW
						mov		map.ncursor,5
					.elseif eax<315-22
						;W
						mov		map.ncursor,6
					.else
						;NW
						mov		map.ncursor,7
					.endif
					mov		eax,map.iLon
					mov		edx,map.iLat
					.if eax!=iLon || edx!=iLat
						mov		iLon,eax
						mov		iLat,edx
						invoke DoGoto,map.iLon,map.iLat,map.gpslock,TRUE
						invoke SetDlgItemInt,hWnd,IDC_EDTEAST,map.iLon,TRUE
						invoke SetDlgItemInt,hWnd,IDC_EDTNORTH,map.iLat,TRUE
						invoke SetDlgItemInt,hWnd,IDC_EDTBEAR,map.iBear,FALSE
						movzx	eax,sonarreplay.iSpeed
						invoke wsprintf,addr buffer,addr szFmtDec2,eax
						invoke strlen,addr buffer
						movzx	ecx,word ptr buffer[eax-1]
						shl		ecx,8
						mov		cl,'.'
						mov		dword ptr buffer[eax-1],ecx
						invoke strcpy,addr map.options.text,addr buffer
						invoke AddTrailPoint,map.iLon,map.iLat,map.iBear,map.iTime
						.if nTrail
							mov		eax,map.iLon
							mov		edx,map.iLat
							.if eax!=iLon || edx!=iLat
								invoke BearingDistanceInt,iLon,iLat,map.iLon,map.iLat,addr fDist,addr fBear
								fld		fDist
								fld		map.fSumDist
								faddp	st(1),st(0)
								fst		st(1)
								lea		eax,map.fSumDist
								fstp	REAL10 PTR [eax]
								lea		eax,iSumDist
								fistp	dword ptr [eax]
								invoke SetDlgItemInt,hWnd,IDC_EDTDIST,iSumDist,FALSE
								invoke SetDlgItemInt,hWnd,IDC_EDTBEAR,map.iBear,FALSE
							.endif
						.endif
						inc		nTrail
						inc		map.paintnow
					.endif
					invoke ReadFile,sonardata.hReply,addr STM32Echo,MAXYECHO,addr dwread,NULL
				.endif
			.endif
			.if dwread!=MAXYECHO
				invoke CloseHandle,sonardata.hReply
				mov		sonardata.hReply,0
				invoke SetScrollPos,hSonar,SB_HORZ,0,TRUE
				mov		sonardata.dptinx,0
				invoke EnableScrollBar,hSonar,SB_HORZ,ESB_DISABLE_BOTH
				mov		nTrail,0
				mov		iLat,-1
				mov		iLon,-1
				jmp		Again
			.endif
			invoke GetScrollPos,hSonar,SB_HORZ
			inc		eax
			invoke SetScrollPos,hSonar,SB_HORZ,eax,TRUE
			movzx	eax,STM32Echo
			.if al!=STM32Echo[MAXYECHO]
				mov		rngchanged,4
			.endif
			invoke SetRange,eax
		.elseif sonardata.fSTLink && sonardata.fSTLink!=IDIGNORE
			;Download Start status (first byte)
			invoke STLinkRead,hWnd,STM32_Sonar,addr status,4
			.if !eax || eax==IDABORT || eax==IDIGNORE
				jmp		STLinkErr
			.endif
			.if !(status & 255)
				;Download ADCBattery, ADCWaterTemp and ADCAirTemp
				invoke STLinkRead,hWnd,STM32_Sonar+8,addr sonardata.ADCBattery,8
				.if !eax || eax==IDABORT || eax==IDIGNORE
					jmp		STLinkErr
				.endif
				;Copy old echo
				call	MoveEcho
				;Download sonar echo array
				invoke STLinkRead,hWnd,STM32_Sonar+16,addr STM32Echo,MAXYECHO
				.if !eax || eax==IDABORT || eax==IDIGNORE
					jmp		STLinkErr
				.endif
				movzx	ebx,sonardata.RangeInx
				invoke GetRangePtr,ebx
				mov		ebx,eax
				.if sonardata.fGainUpload
					;Upload Gain array
					mov		sonardata.fGainUpload,FALSE
					invoke CreateThread,NULL,NULL,addr GainUploadThread,0,0,addr tid
					invoke CloseHandle,eax
				.endif
			 	;Upload Start, PingPulses, PingTimer, RangeInx and PixelTimer to init the next reading
				mov		eax,sonardata.PingInit
				.if sonardata.AutoPing
					add		eax,sonardata.sonarrange.pingadd[ebx]
					.if eax>MAXPING
						mov		eax,MAXPING
					.endif
				.endif
				mov		sonardata.PingPulses,al
			 	mov		sonardata.Start,0
				invoke STLinkWrite,hWnd,STM32_Sonar,addr sonardata.Start,8
				.if !eax || eax==IDABORT || eax==IDIGNORE
					jmp		STLinkErr
				.endif
				;Start the next phase
			 	mov		sonardata.Start,1
				invoke STLinkWrite,hWnd,STM32_Sonar,addr sonardata.Start,4
				.if !eax || eax==IDABORT || eax==IDIGNORE
					jmp		STLinkErr
				.endif
			.else
				;Data not ready yet
				invoke Sleep,10
				jmp		Again
			.endif
		.elseif sonardata.fSTLink==IDIGNORE
			;Copy old echo
			call	MoveEcho
			;Clear echo
			xor		eax,eax
			lea		edi,STM32Echo
			mov		ecx,MAXYECHO/4
			rep		stosd
			;Set range index
			movzx	eax,sonardata.RangeInx
			mov		STM32Echo,al
			;Show ping
			invoke GetRangePtr,eax
			mov		eax,sonardata.sonarrange.pixeltimer[eax]
			mov		ecx,sonardata.sonarrange.pixeltimer
			xor		edx,edx
			div		ecx
			mov		ecx,eax
			mov		eax,100
			xor		edx,edx
			div		ecx
			.if eax<3
				mov		eax,3
			.endif
			push	eax
			mov		edi,eax
			mov		edx,1
			.while edx<edi
				invoke Random,50
				add		eax,255-50
				mov		STM32Echo[edx],al
				inc		edx
			.endw
			;Show surface clutter
			invoke Random,edi
			mov		ecx,edi
			add		ecx,eax
			.while edx<ecx
				invoke Random,255
				mov		STM32Echo[edx],al
				inc		edx
			.endw
			.if !(pixcnt & 63)
				;Random direction
				invoke Random,8
				mov		pixdir,eax
			.endif
			.if !(pixcnt & 31)
				;Random move
				invoke Random,4
				mov		pixmov,eax
			.endif
			mov		ebx,pixdpt
			mov		eax,pixdir
			.if eax<=1 && ebx>100
				;Up
				sub		ebx,pixmov
			.elseif eax>=3 && ebx<15000
				;Down
				add		ebx,pixmov
			.endif
			mov		pixdpt,ebx
			inc		pixcnt
			mov		eax,ebx
			mov		ecx,1024
			mul		ecx
			push	eax
			;Get current range index
			movzx	eax,STM32Echo
			invoke GetRangePtr,eax
			mov		ecx,sonardata.sonarrange.range[eax]
			pop		eax
			xor		edx,edx
			div		ecx
			mov		ecx,100
			xor		edx,edx
			div		ecx
			mov		ebx,eax
			invoke Random,edi
			mov		edx,eax
			sub		ebx,eax
			.if sdword ptr ebx<=0
				mov		ebx,1
			.endif
			.while edx
				;Random bottom vegetation
				.if ebx<MAXYECHO
					invoke Random,64
					add		eax,32
					mov		STM32Echo[ebx],al
				.endif
				inc		ebx
				dec		edx
			.endw
			pop		edx
			push	ebx
			shl		edx,2
			xor		ecx,ecx
			.while ecx<edx
				;Random bottom echo
				invoke Random,64
				.if ebx<MAXYECHO
					add		eax,255-64
					sub		eax,ecx
					mov		STM32Echo[ebx],al
				.endif
				inc		ebx
				inc		ecx
			.endw
			mov		eax,edx
			shl		edx,2
			invoke Random,eax
			add		edx,eax
			xor		ecx,ecx
			.while ecx<edx
				;Random bottom weak echo
				mov		eax,ecx
				xor		al,0FFh
				.if !eax
					inc		eax
				.endif
				invoke Random,eax
				.if ebx<MAXYECHO
					mov		STM32Echo[ebx],al
				.endif
				inc		ebx
				inc		ecx
			.endw
			pop		ebx
			invoke Random,ebx
			.if eax>100 && eax<MAXYECHO-1
				mov		edx,eax
				invoke Random,255
				.if eax>124 && eax<130
					;Random fish
					mov		ah,al
					mov		word ptr STM32Echo[edx],ax
					mov		word ptr STM32Echo[edx+MAXYECHO],ax
					mov		word ptr STM32Echo[edx+MAXYECHO*2],ax
				.endif
			.endif
			mov		sonardata.ADCBattery,08E0h
			mov		sonardata.ADCWaterTemp,06A0h
			mov		sonardata.ADCAirTemp,0780h
		.endif
		.if sonardata.hLog
			;Write to log file
			mov		sonarreplay.Version,200
			mov		al,sonardata.PingPulses
			mov		sonarreplay.PingPulses,al
			mov		eax,sonardata.GainSet
			mov		sonarreplay.GainSet,ax
			mov		eax,sonardata.SoundSpeed
			mov		sonarreplay.SoundSpeed,ax
			mov		sonarreplay.ADCBattery,ax
			mov		ax,sonardata.ADCBattery
			mov		sonarreplay.ADCBattery,ax
			mov		ax,sonardata.ADCWaterTemp
			mov		sonarreplay.ADCWaterTemp,ax
			mov		ax,sonardata.ADCAirTemp
			mov		sonarreplay.ADCAirTemp,ax
			mov		eax,map.iTime
			mov		sonarreplay.iTime,eax
			mov		eax,map.iLon
			mov		sonarreplay.iLon,eax
			mov		eax,map.iLat
			mov		sonarreplay.iLat,eax
			mov		eax,map.iSpeed
			mov		sonarreplay.iSpeed,ax
			mov		eax,map.iBear
			mov		sonarreplay.iBear,ax
			invoke WriteFile,sonardata.hLog,addr sonarreplay,sizeof SONARREPLAY,addr dwwrite,NULL
			invoke WriteFile,sonardata.hLog,addr STM32Echo,MAXYECHO,addr dwwrite,NULL
		.endif
		movzx	eax,STM32Echo
		.if al!=STM32Echo[MAXYECHO]
			call	CopyEcho
		.endif
		.if rngchanged
			call	FindDepth
			dec		rngchanged
		.else
			call	FindDepth
			call	FindFish
			call	TestRangeChange
		.endif
		;Get current range index
		movzx	eax,STM32Echo
		mov		sonardata.EchoArray,al
		invoke GetRangePtr,eax
		mov		eax,sonardata.sonarrange.interval[eax]
		.if sonardata.hReply!=0 || sonardata.fSTLink==IDIGNORE
			mov		ecx,REPLYSPEED
			xor		edx,edx
			div		ecx
		.endif
		mov		esi,sonardata.ChartSpeed
		xor		edx,edx
		div		esi
		mov		edi,eax
		.if esi==1
			call	Show0
		.elseif esi==2
			call	Show50
			call	Show0
		.elseif esi==3
			call	Show66
			call	Show33
			call	Show0
		.else
			call	Show75
			call	Show50
			call	Show25
			call	Show0
		.endif
	.endif
	.if !sonardata.fTreadExit
		jmp		Again
	.endif
	mov		sonardata.fTreadExit,2
	ret

STLinkErr:
	invoke SendMessage,hWnd,WM_CLOSE,0,0
	xor		eax,eax
	ret

Show0:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.else
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	push	edi
	call	ScrollFish
	invoke SonarUpdateProc
	pop		edi
	invoke Sleep,edi
	retn

Show25:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.else
				;Blend in 25% of previous echo
				movzx	edx,ah
				movzx	eax,al
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.else
				;Blend in 25% of previous echo
				movzx	edx,dl
				movzx	eax,al
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.else
				;Blend in 25% of previous echo
				movzx	edx,dl
				movzx	eax,al
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.else
		.while esi<MAXYECHO
			;Blend in 25% of previous echo
			movzx	eax,STM32Echo[esi]
			shl		eax,2
			movzx	edx,STM32Echo[esi+MAXYECHO]
			add		eax,edx
			mov		ecx,5
			xor		edx,edx
			div		ecx
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	call	ScrollFish
	invoke SonarUpdateProc
	invoke Sleep,edi
	retn

Show33:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.else
				;Blend in 33% of previous echo
				movzx	eax,ah
				mov		ecx,3
				xor		edx,edx
				div		ecx
				mov		edx,eax
				movzx	eax,STM32Echo[esi]
				add		eax,edx
				mov		ecx,3
				mul		ecx
				shr		eax,2
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.else
				;Blend in 33% of previous echo
				movzx	eax,dl
				mov		ecx,3
				xor		edx,edx
				div		ecx
				mov		edx,eax
				movzx	eax,STM32Echo[esi]
				add		eax,edx
				mov		ecx,3
				mul		ecx
				shr		eax,2
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.else
				;Blend in 33% of previous echo
				movzx	eax,dl
				mov		ecx,3
				xor		edx,edx
				div		ecx
				mov		edx,eax
				movzx	eax,STM32Echo[esi]
				add		eax,edx
				mov		ecx,3
				mul		ecx
				shr		eax,2
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.else
		.while esi<MAXYECHO
			;Blend in 33% of previous echo
			movzx	eax,STM32Echo[esi+MAXYECHO]
			mov		ecx,3
			xor		edx,edx
			div		ecx
			mov		edx,eax
			movzx	eax,STM32Echo[esi]
			add		eax,edx
			mov		ecx,3
			mul		ecx
			shr		eax,2
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	call	ScrollFish
	invoke SonarUpdateProc
	invoke Sleep,edi
	retn

Show50:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.else
				;Blend in 50% of previous echo
				movzx	edx,ah
				movzx	eax,al
				add		eax,edx
				shr		eax,1
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.else
				;Blend in 50% of previous echo
				movzx	edx,dl
				movzx	eax,al
				add		eax,edx
				shr		eax,1
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.else
				;Blend in 50% of previous echo
				movzx	edx,dl
				movzx	eax,al
				add		eax,edx
				shr		eax,1
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.else
		.while esi<MAXYECHO
			;Blend in 50% of previous echo
			movzx	eax,STM32Echo[esi]
			movzx	edx,STM32Echo[esi+MAXYECHO]
			add		eax,edx
			shr		eax,1
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	call	ScrollFish
	invoke SonarUpdateProc
	invoke Sleep,edi
	retn

Show66:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.else
				;Blend in 66% of previous echo
				movzx	eax,al
				mov		ecx,3
				xor		edx,edx
				div		ecx
				mov		edx,eax
				movzx	eax,STM32Echo[esi+MAXYECHO]
				add		eax,edx
				mov		ecx,3
				mul		ecx
				shr		eax,2
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.else
				;Blend in 66% of previous echo
				movzx	eax,al
				mov		ecx,3
				xor		edx,edx
				div		ecx
				mov		edx,eax
				movzx	eax,STM32Echo[esi+MAXYECHO]
				add		eax,edx
				mov		ecx,3
				mul		ecx
				shr		eax,2
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.else
		.while esi<MAXYECHO
			;Blend in 66% of previous echo
			movzx	eax,STM32Echo[esi]
			mov		ecx,3
			xor		edx,edx
			div		ecx
			mov		edx,eax
			movzx	eax,STM32Echo[esi+MAXYECHO]
			add		eax,edx
			mov		ecx,3
			mul		ecx
			shr		eax,2
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	call	ScrollFish
	invoke SonarUpdateProc
	invoke Sleep,edi
	retn

Show75:
	mov		esi,1
	mov		eax,sonardata.NoiseReject
	mov		ebx,sonardata.NoiseLevel
	.if eax==1
		;1*2
		.while esi<MAXYECHO
			mov		al,STM32Echo[esi]
			mov		ah,STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl
				mov		al,0
			.else
				;Blend in 75% of previous echo
				movzx	edx,al
				movzx	eax,ah
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.elseif eax==2
		;2*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			.if al<bl || ah<bl || dl<bl || dh<bl 
				mov		al,0
			.else
				;Blend in 75% of previous echo
				movzx	edx,al
				movzx	eax,STM32Echo[esi+MAXYECHO]
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.elseif eax==3
		;3*2
		.while esi<MAXYECHO-1
			mov		ax,word ptr STM32Echo[esi]
			mov		dx,word ptr STM32Echo[esi+MAXYECHO]
			mov		cx,word ptr STM32Echo[esi+MAXYECHO*2]
			.if al<bl || ah<bl || dl<bl || dh<bl || cl<bl || ch<bl 
				mov		al,0
			.else
				;Blend in 75% of previous echo
				movzx	edx,al
				movzx	eax,STM32Echo[esi+MAXYECHO]
				shl		eax,2
				add		eax,edx
				mov		ecx,5
				xor		edx,edx
				div		ecx
				.if al<bl
					mov		al,0
				.endif
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
		mov		sonardata.EchoArray[esi],al
	.else
		.while esi<MAXYECHO
			;Blend in 75% of previous echo
			movzx	eax,STM32Echo[esi+MAXYECHO]
			shl		eax,2
			movzx	edx,STM32Echo[esi]
			add		eax,edx
			mov		ecx,5
			xor		edx,edx
			div		ecx
			.if al<bl
				mov		al,0
			.endif
			mov		sonardata.EchoArray[esi],al
			inc		esi
		.endw
	.endif
	call	ScrollFish
	invoke SonarUpdateProc
	invoke Sleep,edi
	retn

MoveEcho:
	;Move echo arrays
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*3],addr STM32Echo[MAXYECHO*2],MAXYECHO
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*2],addr STM32Echo[MAXYECHO*1],MAXYECHO
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*1],addr STM32Echo[MAXYECHO*0],MAXYECHO
	retn

CopyEcho:
	;Copy echo arrays
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*3],addr STM32Echo,MAXYECHO
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*2],addr STM32Echo,MAXYECHO
	invoke RtlMoveMemory,addr STM32Echo[MAXYECHO*1],addr STM32Echo,MAXYECHO
	retn

FindDepth:
	and		sonardata.ShowDepth,1
	;Skip blank
	mov		ebx,1
	mov		ecx,sonardata.NoiseLevel
	.while ebx<32
		mov		ax,word ptr STM32Echo[ebx]
		.break .if al>=cl && ah>cl
		inc		ebx
	.endw
	;Skip ping and surface clutter
	.while ebx<256
		xor		ch,ch
		mov		ax,word ptr STM32Echo[ebx+MAXYECHO*0]
		mov		dx,word ptr STM32Echo[ebx+MAXYECHO*0+2]
		.if al<cl && ah<cl && dl<cl && dh<cl
			inc		ch
		.endif
		mov		ax,word ptr STM32Echo[ebx+MAXYECHO*1]
		mov		dx,word ptr STM32Echo[ebx+MAXYECHO*1+2]
		.if al<cl && ah<cl && dl<cl && dh<cl
			inc		ch
		.endif
		mov		ax,word ptr STM32Echo[ebx+MAXYECHO*2]
		mov		dx,word ptr STM32Echo[ebx+MAXYECHO*2+2]
		.if al<cl && ah<cl && dl<cl && dh<cl
			inc		ch
		.endif
		mov		ax,word ptr STM32Echo[ebx+MAXYECHO*3]
		mov		dx,word ptr STM32Echo[ebx+MAXYECHO*3+2]
		.if al<cl && ah<cl && dl<cl && dh<cl
			inc		ch
		.endif
		.break .if ch==4
		inc		ebx
	.endw
	mov		sonardata.minyecho,ebx
	;Find the strongest echo in a 4x16 sqare
	xor		esi,esi
	xor		edi,edi
	.while ebx<MAXYECHO
		xor		ecx,ecx
		xor		edx,edx
		.while ecx<16
			lea		eax,[ebx+ecx]
			.break .if eax>=MAXYECHO
			movzx	eax,STM32Echo[ebx+ecx+MAXYECHO*0]
			add		edx,eax
			movzx	eax,STM32Echo[ebx+ecx+MAXYECHO*1]
			add		edx,eax
			movzx	eax,STM32Echo[ebx+ecx+MAXYECHO*2]
			add		edx,eax
			movzx	eax,STM32Echo[ebx+ecx+MAXYECHO*3]
			add		edx,eax
			inc		ecx
		.endw
		;Put in a little hysteresis
		lea		eax,[edx-4096]
		.if sdword ptr eax>esi
			mov		esi,edx
			mov		edi,ebx
		.endif
		inc		ebx
	.endw
	.if edi>10
		;A valid bottom signal has been found
		mov		sonardata.nodptinx,0
		mov		eax,sonardata.dptinx
		.if eax
			sub		eax,edi
			.if sdword ptr eax>MAXDEPTHJUMP
				mov		edi,sonardata.dptinx
				sub		edi,MAXDEPTHJUMP
			.elseif sdword ptr eax<-MAXDEPTHJUMP
				mov		edi,sonardata.dptinx
				add		edi,MAXDEPTHJUMP
			.endif
		.endif
		mov		ebx,edi
		mov		sonardata.dptinx,ebx
		call	CalculateDepth
		call	SetDepth
		or		sonardata.ShowDepth,2
	.else
		inc		sonardata.nodptinx
	.endif
	retn

CalculateDepth:
	push	ecx
	push	edx
	movzx	eax,STM32Echo
	invoke GetRangePtr,eax
	mov		eax,sonardata.sonarrange.range[eax]
	mov		ecx,10
	mul		ecx
	mul		ebx
	mov		ecx,MAXYECHO
	div		ecx
	pop		edx
	pop		ecx
	retn

SetDepth:
	invoke wsprintf,addr buffer,addr szFmtDec2,eax
	invoke strlen,addr buffer
	.if eax>3
		;Remove the decimal
		mov		byte ptr buffer[eax-1],0
	.else
		;Add a decimal point
		movzx	ecx,word ptr buffer[eax-1]
		shl		ecx,8
		mov		cl,'.'
		mov		dword ptr buffer[eax-1],ecx
	.endif
	invoke strcpy,addr sonardata.options.text[1*sizeof OPTIONS],addr buffer
	retn

ScrollFish:
	mov		esi,offset sonardata.fishdata
	mov		ecx,MAXFISH
	.while ecx
		dec		[esi].FISH.xpos
		lea		esi,[esi+sizeof FISH]
		dec		ecx
	.endw
	retn

CheckFish:
	push	esi
	push	edi
	mov		edi,MAXFISH
	mov		esi,offset sonardata.fishdata
	.while edi
		.if sdword ptr [esi].FISH.xpos>MAXXECHO-16
			.if sdword ptr [esi].FISH.depth>ecx && sdword ptr [esi].FISH.depth<edx
				;The detected fish is close to a previously detected fish, ignore it
				xor		eax,eax
				.break
			.endif
		.endif
		dec		edi
		lea		esi,[esi+sizeof FISH]
	.endw
	pop		edx
	pop		esi
	retn

FindFish:
	.if sonardata.FishDetect || sonardata.FishAlarm
		mov		ebx,sonardata.minyecho
		mov		edi,sonardata.dptinx
		.if !edi
			;Depth unknowm
			retn
		.elseif edi>sonardata.minyecho
			;Skip bottom vegetation
			mov		ecx,sonardata.NoiseLevel
			.while edi>ebx
				dec		edi
				mov		ax,word ptr STM32Echo[edi]
				mov		dx,word ptr STM32Echo[edi+MAXYECHO]
				.if al<cl && ah<cl && dl<cl && dh<cl
					inc		ch
				.else
					xor		ch,ch
				.endif
				.break .if ch==5
			.endw
		.else
			;Too shallow
			retn
		.endif
		.while ebx<edi
			mov		ax,word ptr STM32Echo[ebx]
			;2x3
			mov		dx,word ptr STM32Echo[ebx+MAXYECHO]
			mov		cx,word ptr STM32Echo[ebx+MAXYECHO*2]
			.if sonardata.FishDetect==2
				;2x2
				mov		cx,ax
			.elseif sonardata.FishDetect==3
				;2x1
				mov		dx,ax
				mov		cx,ax
			.endif
			.if al>=SMALLFISHECHO && ah>=SMALLFISHECHO && dl>=SMALLFISHECHO && dh>=SMALLFISHECHO && cl>=SMALLFISHECHO && ch>=SMALLFISHECHO
				.if sonardata.FishDetect
					mov		eax,sonardata.fishinx
					mov		ecx,sizeof FISH
					mul		ecx
					mov		esi,eax
					movzx	eax,STM32Echo
					invoke GetRangePtr,eax
					mov		edx,sonardata.sonarrange.range[eax]
					shr		edx,1
					call	CalculateDepth
					mov		ecx,eax
					sub		ecx,edx
					lea		edx,[eax+edx]
					call	CheckFish
					.if eax
						movzx	edx,STM32Echo[ebx]
						.if edx>=LARGEFISHECHO
							;Large fish
							mov		edx,18
						.else
							;Small fish
							mov		edx,17
						.endif
						;Update the fishdata array
						mov		sonardata.fishdata.fishtype[esi],edx
						mov		sonardata.fishdata.xpos[esi],511
						mov		sonardata.fishdata.depth[esi],eax
						;Increment the fishdata index
						mov		eax,sonardata.fishinx
						inc		eax
						.if eax==MAXFISH
							xor		eax,eax
						.endif
						mov		sonardata.fishinx,eax
					.endif
				.endif
				.if sonardata.FishAlarm && !sonardata.fFishSound
					;Play a wav file
					mov		sonardata.fFishSound,3
					invoke PlaySound,addr sonardata.szFishSound,hInstance,SND_ASYNC
				.endif
				.break
			.endif
			inc		ebx
		.endw
	.endif
	retn

TestRangeChange:
	.if sonardata.AutoRange && !sonardata.hReply
		movzx	eax,STM32Echo
		mov		edx,sonardata.MaxRange
		dec		edx
		mov		ebx,sonardata.dptinx
		.if sonardata.nodptinx
			;Bottom not found
			.if sonardata.nodptinx>=10
				mov		sonardata.nodptinx,0
				.if eax<edx
					;Range increment
					inc		eax
					invoke SetRange,eax
					mov		rngchanged,8
					mov		sonardata.dptinx,0
					mov		sonardata.fGainUpload,TRUE
				.endif
			.endif
		.else
			;Check if range should be changed
			.if eax && ebx<MAXYECHO/3
				;Range decrement
				dec		eax
				invoke SetRange,eax
				mov		rngchanged,10
				mov		sonardata.dptinx,0
				mov		sonardata.fGainUpload,TRUE
			.elseif eax<edx && ebx>(MAXYECHO-MAXYECHO/5)
				;Range increment
				inc		eax
				invoke SetRange,eax
				mov		rngchanged,10
				mov		sonardata.dptinx,0
				mov		sonardata.fGainUpload,TRUE
			.endif
		.endif
	.endif
	retn

STM32Thread endp

ShowRangeDepthTempScaleFish proc uses ebx esi edi,hDC:HDC
	LOCAL	rcsonar:RECT
	LOCAL	rect:RECT
	LOCAL	x:DWORD
	LOCAL	tmp:DWORD
	LOCAL	nticks:DWORD
	LOCAL	ntick:DWORD

	invoke GetClientRect,hSonar,addr rcsonar
	call	ShowFish
	invoke SetBkMode,hDC,TRANSPARENT
	call	ShowScale
	xor		ebx,ebx
	mov		esi,offset sonardata.options
	.while ebx<MAXSONAROPTION
		.if [esi].OPTIONS.show
			.if ebx==1
				.if (sonardata.ShowDepth & 1) || (sonardata.ShowDepth>1)
					call ShowOption
				.endif
			.else
				call ShowOption
			.endif
		.endif
		lea		esi,[esi+sizeof OPTIONS]
		inc		ebx
	.endw
	ret

ShowFish:
	movzx	eax,sonardata.EchoArray
	invoke GetRangePtr,eax
	mov		eax,sonardata.sonarrange.range[eax]
	mov		ebx,10
	mul		ebx
	mov		ebx,eax
	mov		ecx,MAXFISH
	mov		esi,offset sonardata.fishdata
	.while ecx
		push	ecx
		.if [esi].FISH.fishtype && sdword ptr [esi].FISH.xpos>=-10 && [esi].FISH.depth<=ebx
			mov		eax,[esi].FISH.depth
			mov		edx,rcsonar.bottom
			mul		edx
			xor		edx,edx
			div		ebx
			mov		edx,[esi].FISH.xpos
			sub		edx,MAXXECHO+SIGNALBAR
			add		edx,rcsonar.right
			invoke ImageList_Draw,hIml,[esi].FISH.fishtype,hDC,addr [edx-8],eax,ILD_TRANSPARENT
		.endif
		pop		ecx
		lea		esi,[esi+sizeof FISH]
		dec		ecx
	.endw
	retn

ShowOption:
	mov		ecx,[esi].OPTIONS.pt.x
	mov		edx,[esi].OPTIONS.pt.y
	mov		rect.left,ecx
	mov		rect.top,edx
	mov		eax,rcsonar.right
	sub		eax,ecx
	mov		rect.right,eax
	mov		eax,rcsonar.bottom
	sub		eax,edx
	mov		rect.bottom,eax
	mov		eax,[esi].OPTIONS.font
	add		eax,7
	mov		ecx,map.font[eax*4]
	mov		edx,[esi].OPTIONS.position
	.if !edx
		;Left, Top
		mov		eax,DT_LEFT or DT_SINGLELINE
	.elseif edx==1
		;Center, Top
		mov		eax,DT_LEFT or DT_SINGLELINE
	.elseif edx==2
		;Rioght, Top
		mov		eax,DT_RIGHT or DT_SINGLELINE
	.elseif edx==3
		;Left, Bottom
		mov		eax,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
	.elseif edx==4
		;Center, Bottom
		mov		eax,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
	.elseif edx==5
		;Right, Bottom
		mov		eax,DT_RIGHT or DT_BOTTOM or DT_SINGLELINE
	.endif
	invoke TextDraw,hDC,ecx,addr rect,addr [esi].OPTIONS.text,eax
	retn

DrawTick:
	mov		eax,rect.bottom
	sub		eax,rect.top
	mov		tmp,eax
	fild	tmp
	fild	nticks
	fdivp	st(1),st
	fild	ntick
	fmulp	st(1),st
	fistp	tmp
	mov		eax,rect.top
	add		tmp,eax
	invoke MoveToEx,hDC,rect.left,tmp,NULL
	invoke LineTo,hDC,rect.right,tmp
	.if !ntick
		add		tmp,2
	.else
		sub		tmp,18
	.endif
	push	rect.left
	push	rect.top
	push	rect.right
	sub		rect.left,20
	add		rect.right,20
	mov		eax,tmp
	mov		rect.top,eax
	invoke TextDraw,hDC,NULL,addr rect,esi,DT_CENTER or DT_TOP or DT_SINGLELINE
	pop		rect.right
	pop		rect.top
	pop		rect.left
	retn

DrawScaleBar:
	mov		ebx,rect.right
	sub		ebx,rect.left
	shr		ebx,1
	add		ebx,rect.left
	invoke MoveToEx,hDC,ebx,rect.top,NULL
	invoke LineTo,hDC,ebx,rect.bottom
	movzx	eax,sonardata.EchoArray
	invoke GetRangePtr,eax
	mov		edx,sonardata.sonarrange.nticks[eax]
	mov		nticks,edx
	mov		ntick,0
	lea		esi,sonardata.sonarrange.scale[eax]
	.while dword ptr ntick<=edx
		push	edx
		call	DrawTick
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		pop		edx
		inc		ntick
	.endw
	retn

ShowScale:
	invoke CopyRect,addr rect,addr rcsonar
	mov		eax,rect.right
	sub		eax,SIGNALBAR
	mov		rect.right,eax
	sub		eax,RANGESCALE
	mov		rect.left,eax
	mov		rect.top,6
	sub		rect.bottom,5
	invoke CreatePen,PS_SOLID,5,0FFFFFFh
	invoke SelectObject,hDC,eax
	push	eax
	call	DrawScaleBar
	pop		eax
	invoke SelectObject,hDC,eax
	invoke DeleteObject,eax
	invoke GetStockObject,BLACK_PEN
	invoke SelectObject,hDC,eax
	push	eax
	call	DrawScaleBar
	pop		eax
	invoke SelectObject,hDC,eax
	retn

ShowRangeDepthTempScaleFish endp

SaveSonarToIni proc
	LOCAL	buffer[256]:BYTE

	mov		buffer,0
	;Width,AutoRange,AutoGain,AutoPing,FishDetect,FishAlarm,RangeInx,NoiseLevel,PingInit,GainSet,ChartSpeed,NoiseReject,PingTimer,SoundSpeed
	invoke PutItemInt,addr buffer,sonardata.wt
	invoke PutItemInt,addr buffer,sonardata.AutoRange
	invoke PutItemInt,addr buffer,sonardata.AutoGain
	invoke PutItemInt,addr buffer,sonardata.AutoPing
	invoke PutItemInt,addr buffer,sonardata.FishDetect
	invoke PutItemInt,addr buffer,sonardata.FishAlarm
	movzx	eax,sonardata.RangeInx
	invoke PutItemInt,addr buffer,eax
	invoke PutItemInt,addr buffer,sonardata.NoiseLevel
	invoke PutItemInt,addr buffer,sonardata.PingInit
	invoke PutItemInt,addr buffer,sonardata.GainSet
	invoke PutItemInt,addr buffer,sonardata.ChartSpeed
	invoke PutItemInt,addr buffer,sonardata.NoiseReject
	movzx	eax,sonardata.PingTimer
	invoke PutItemInt,addr buffer,eax
	invoke PutItemInt,addr buffer,sonardata.SoundSpeed
	invoke WritePrivateProfileString,addr szIniSonar,addr szIniSonar,addr buffer[1],addr szIniFileName
	ret

SaveSonarToIni endp

LoadSonarFromIni proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	
	invoke RtlZeroMemory,addr buffer,sizeof buffer
	invoke GetPrivateProfileString,addr szIniSonar,addr szIniSonar,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
	;Width,AutoRange,AutoGain,AutoPing,FishDetect,FishAlarm,RangeInx,NoiseLevel,PingInit,GainSet,ChartSpeed,NoiseReject,PingTimer,SoundSpeed
	invoke GetItemInt,addr buffer,250
	mov		sonardata.wt,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.AutoRange,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.AutoGain,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.AutoPing,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.FishDetect,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.FishAlarm,eax
	invoke GetItemInt,addr buffer,0
	mov		sonardata.RangeInx,al
	invoke GetItemInt,addr buffer,15
	mov		sonardata.NoiseLevel,eax
	invoke GetItemInt,addr buffer,63
	mov		sonardata.PingInit,eax
	invoke GetItemInt,addr buffer,630
	mov		sonardata.GainSet,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.ChartSpeed,eax
	invoke GetItemInt,addr buffer,1
	mov		sonardata.NoiseReject,eax
	invoke GetItemInt,addr buffer,STM32_PingTimer
	mov		sonardata.PingTimer,al
	invoke GetItemInt,addr buffer,(SOUNDSPEEDMAX+SOUNDSPEEDMIN)/2
	mov		sonardata.SoundSpeed,eax
	invoke GetPrivateProfileString,addr szIniSonarRange,addr szIniGainDef,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
	invoke GetItemInt,addr buffer,0
	mov		sonardata.gainofs,eax
	invoke GetItemInt,addr buffer,0
	mov		sonardata.gainmax,eax
	;Get the range definitions
	xor		ebx,ebx
	xor		edi,edi
	.while ebx<32
		invoke wsprintf,addr buffer,addr szFmtDec,ebx
		invoke GetPrivateProfileString,addr szIniSonarRange,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
		.break .if !eax
		invoke GetItemInt,addr buffer,0
		mov		sonardata.sonarrange.range[edi],eax
		invoke GetItemInt,addr buffer,0
		mov		sonardata.sonarrange.interval[edi],eax
		invoke GetItemInt,addr buffer,0
		mov		sonardata.sonarrange.pingadd[edi],eax
		xor		esi,esi
		.while esi<=MAXYECHO
			invoke GetItemInt,addr buffer,0
			mov		sonardata.sonarrange.gain[edi+esi*DWORD],eax
			lea		esi,[esi+32]
		.endw
		lea		esi,sonardata.sonarrange.scale[edi]
		invoke strcpy,esi,addr buffer
		xor		eax,eax
		.while byte ptr [esi]
			.if byte ptr [esi]==','
				inc		eax
				mov		byte ptr [esi],0
			.endif
			inc		esi
		.endw
		mov		sonardata.sonarrange.nticks[edi],eax
		inc		ebx
		lea		edi,[edi+sizeof RANGE]
	.endw
	;Store the number of range definitions read from ini
	mov		sonardata.MaxRange,ebx
	invoke SetupPixelTimer
	invoke SetupGainArray
	ret

LoadSonarFromIni endp

SonarClear proc uses ebx esi
	LOCAL	rect:RECT

	invoke RtlZeroMemory,addr sonardata.fishdata,MAXFISH*sizeof FISH
	invoke RtlZeroMemory,addr STM32Echo,sizeof STM32Echo
	invoke RtlZeroMemory,addr sonardata.EchoArray,sizeof sonardata.EchoArray
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,MAXXECHO
	mov		rect.bottom,MAXYECHO
	invoke FillRect,sonardata.mDC,addr rect,sonardata.hBrBack
	invoke GetClientRect,hSonar,addr rect
	mov		rect.right,SIGNALBAR
	
	invoke FillRect,sonardata.mDCS,addr rect,sonardata.hBrBack
	mov		esi,offset sonardata.sonarbmp
	mov		ebx,MAXSONARBMP
	.while ebx
		.if [esi].SONARBMP.hBmp
			invoke DeleteObject,[esi].SONARBMP.hBmp
			mov		[esi].SONARBMP.hBmp,0
		.endif
		lea		esi,[esi+sizeof SONARBMP]
		dec		ebx
	.endw
	movzx	eax,sonardata.RangeInx
	mov		sonardata.sonarbmp.RangeInx,eax
	mov		sonardata.sonarbmp.xpos,MAXXECHO
	mov		sonardata.sonarbmp.wt,0
	mov		sonardata.sonarbmp.hBmp,0
	invoke InvalidateRect,hSonar,NULL,TRUE
	ret

SonarClear endp

SonarProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:HBITMAP
	LOCAL	pt:POINT
	LOCAL	msg:MSG

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		eax,hWin
		mov		hSonar,eax
		invoke CreateSolidBrush,SONARBACKCOLOR
		mov		sonardata.hBrBack,eax
		invoke CreatePen,PS_SOLID,1,SONARPENCOLOR
		mov		sonardata.hPen,eax
		invoke GetDC,hWin
		mov		hDC,eax

		invoke CreateCompatibleDC,hDC
		mov		sonardata.mDC,eax
		invoke CreateCompatibleBitmap,hDC,MAXXECHO,MAXYECHO
		mov		sonardata.hBmp,eax
		invoke SelectObject,sonardata.mDC,eax
		mov		sonardata.hBmpOld,eax
		mov		rect.left,0
		mov		rect.top,0
		mov		rect.right,MAXXECHO
		mov		rect.bottom,MAXYECHO
		invoke FillRect,sonardata.mDC,addr rect,sonardata.hBrBack

		invoke CreateCompatibleDC,hDC
		mov		sonardata.mDCS,eax
		invoke CreateCompatibleBitmap,hDC,SIGNALBAR,MAXYECHO
		mov		sonardata.hBmpS,eax
		invoke SelectObject,sonardata.mDCS,eax
		mov		sonardata.hBmpOldS,eax
		invoke SelectObject,sonardata.mDCS,sonardata.hPen
		mov		sonardata.hPenOld,eax
		mov		rect.left,0
		mov		rect.top,0
		mov		rect.right,SIGNALBAR
		mov		rect.bottom,MAXYECHO
		invoke FillRect,sonardata.mDCS,addr rect,sonardata.hBrBack

		invoke ReleaseDC,hWin,hDC
		invoke strcpy,addr sonardata.szFishSound,addr szAppPath
		invoke strcat,addr sonardata.szFishSound,addr szFishWav

		;Sonar init
		invoke EnableScrollBar,hSonar,SB_HORZ,ESB_DISABLE_BOTH
		invoke LoadCursor,hInstance,101
		mov		hSplittV,eax
		invoke LoadSonarFromIni
		movzx	eax,sonardata.RangeInx
		invoke SetRange,eax

		movzx	eax,sonardata.RangeInx
		mov		sonardata.sonarbmp.RangeInx,eax
		mov		sonardata.sonarbmp.xpos,MAXXECHO
		mov		sonardata.sonarbmp.wt,0
		mov		sonardata.sonarbmp.hBmp,0

		invoke SetTimer,hWin,1000,800,NULL
		invoke SetTimer,hWin,1001,500,NULL
	.elseif eax==WM_TIMER
		.if wParam==1000
			.if !sonardata.fSTLink
				mov		sonardata.fSTLink,IDIGNORE
				invoke STLinkConnect,hWnd
				.if eax==IDABORT
					invoke SendMessage,hWnd,WM_CLOSE,0,0
				.else
					mov		sonardata.fSTLink,eax
				.endif
				.if sonardata.fSTLink && sonardata.fSTLink!=IDIGNORE
					invoke STLinkReset,hWnd
					mov		sonardata.fGainUpload,TRUE
				.endif
				invoke CreateThread,NULL,NULL,addr STM32Thread,hWin,0,addr tid
				invoke CloseHandle,eax
			.endif
		.elseif wParam==1001
			xor		sonardata.ShowDepth,1
			.if sonardata.ShowDepth<2
				invoke InvalidateRect,hSonar,NULL,TRUE
			.endif
			.if sonardata.fFishSound
				dec		sonardata.fFishSound
			.endif
		.endif
	.elseif eax==WM_CONTEXTMENU
		mov		eax,lParam
		.if eax!=-1
			movsx	edx,ax
			mov		mousept.x,edx
			mov		pt.x,edx
			shr		eax,16
			movsx	edx,ax
			mov		mousept.y,edx
			mov		pt.y,edx
			invoke GetSubMenu,hContext,5
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,mousept.x,mousept.y,0,hWnd,0
		.endif
	.elseif eax==WM_DESTROY
		mov		sonardata.fTreadExit,1
		.while sonardata.fTreadExit!=2
			invoke GetMessage,addr msg,NULL,0,0
			invoke Sleep,100
		.endw
		.if sonardata.fSTLink && sonardata.fSTLink!=IDIGNORE
			invoke STLinkDisconnect
		.endif
		invoke SonarClear
		invoke DeleteObject,sonardata.hBrBack
		invoke SelectObject,sonardata.mDC,sonardata.hBmpOld
		invoke DeleteObject,sonardata.hBmp
		invoke DeleteDC,sonardata.mDC
		invoke SelectObject,sonardata.mDCS,sonardata.hBmpOldS
		invoke DeleteObject,sonardata.hBmpS
		invoke SelectObject,sonardata.mDCS,sonardata.hPenOld
		invoke DeleteObject,sonardata.hPen
		invoke DeleteDC,sonardata.mDCS
		invoke SaveSonarToIni
	.elseif eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke FillRect,mDC,addr rect,sonardata.hBrBack
		sub		rect.right,RANGESCALE+SIGNALBAR
		sub		rect.bottom,12
		mov		ecx,MAXXECHO
		sub		ecx,rect.right
		invoke StretchBlt,mDC,0,6,rect.right,rect.bottom,sonardata.mDC,ecx,0,rect.right,MAXYECHO,SRCCOPY
		add		rect.right,RANGESCALE
		invoke StretchBlt,mDC,rect.right,6,SIGNALBAR,rect.bottom,sonardata.mDCS,0,0,SIGNALBAR,MAXYECHO,SRCCOPY
		add		rect.right,SIGNALBAR
		invoke ShowRangeDepthTempScaleFish,mDC
		add		rect.bottom,12
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_HSCROLL
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==SB_THUMBPOSITION
			.if sonardata.hReply
				push	eax
				invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
				pop		eax
				mov		ecx,MAXYECHO
				.if sonarreplay.Version>=200
					add		ecx,sizeof SONARREPLAY
				.endif
				mul		ecx
				invoke SetFilePointer,sonardata.hReply,eax,NULL,FILE_BEGIN
			.endif
		.elseif edx==SB_LINERIGHT
			.if sonardata.hReply
				invoke GetScrollPos,hWin,SB_HORZ
				add		eax,16
				push	eax
				invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
				pop		eax
				mov		ecx,MAXYECHO
				.if sonarreplay.Version>=200
					add		ecx,sizeof SONARREPLAY
				.endif
				mul		ecx
				invoke SetFilePointer,sonardata.hReply,eax,NULL,FILE_BEGIN
			.endif
		.elseif edx==SB_LINELEFT
			.if sonardata.hReply
				invoke GetScrollPos,hWin,SB_HORZ
				sub		eax,16
				.if CARRY?
					xor		eax,eax
				.endif
				push	eax
				invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
				pop		eax
				mov		ecx,MAXYECHO
				.if sonarreplay.Version>=200
					add		ecx,sizeof SONARREPLAY
				.endif
				mul		ecx
				invoke SetFilePointer,sonardata.hReply,eax,NULL,FILE_BEGIN
			.endif
		.elseif edx==SB_PAGERIGHT
			.if sonardata.hReply
				invoke GetScrollPos,hWin,SB_HORZ
				add		eax,256
				push	eax
				invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
				pop		eax
				mov		ecx,MAXYECHO
				.if sonarreplay.Version>=200
					add		ecx,sizeof SONARREPLAY
				.endif
				mul		ecx
				invoke SetFilePointer,sonardata.hReply,eax,NULL,FILE_BEGIN
			.endif
		.elseif edx==SB_PAGELEFT
			.if sonardata.hReply
				invoke GetScrollPos,hWin,SB_HORZ
				sub		eax,256
				.if CARRY?
					xor		eax,eax
				.endif
				push	eax
				invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
				pop		eax
				mov		ecx,MAXYECHO
				.if sonarreplay.Version>=200
					add		ecx,sizeof SONARREPLAY
				.endif
				mul		ecx
				invoke SetFilePointer,sonardata.hReply,eax,NULL,FILE_BEGIN
			.endif
		.endif
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

SonarProc endp
