
; STM32 value line Discovery Digital Oscilloscope demo project.
; -------------------------------------------------------------------------------
;
; IMPORTANT NOTICE!
; -----------------
; The use of the evaluation board is restricted:
; "This device is not, and may not be, offered for sale or lease, or sold or
; leased or otherwise distributed".
;
; For more info see this license agreement:
; http://www.st.com/internet/com/LEGAL_RESOURCES/LEGAL_AGREEMENT/
; LICENSE_AGREEMENT/EvaluationProductLicenseAgreement.pdf

.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include DDSWaveGen.inc
include Frequency.asm
include HSClock.asm
include DDSWave.asm

.code

MakeCommand proc

	mov		command.cmnd,STM32_CMNDWait
	;High speed clock
	mov		eax,hsclockdata.hsclockenable
	mov		command.HSC_enable,al
	mov		eax,hsclockdata.hsclockdivisor
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
	mov		command.HSC_div,ax
	mov		eax,65536
	sub		eax,hsclockdata.hsclockfrequency
	mov		command.HSC_frq,ax
	mov		eax,hsclockdata.hsclockccr
	mov		command.HSC_dutycycle,ax
	;DDS wave generator
	mov		eax,ddswavedata.DDS_PhaseFrq
	mov		command.DDS_PhaseFrq,eax
	.if ddswavedata.DDS_Enable
		mov		eax,ddswavedata.SWEEP_SubMode
		mov		command.DDS_SubMode,al
	.else
		mov		command.DDS_SubMode,0
	.endif
	mov		eax,ddswavedata.DDS_DacBuffer
	mov		command.DDS_DacBuffer,al
	mov		eax,ddswavedata.SWEEP_StepTime
	mov		command.SWEEP_StepTime,ax
	mov		eax,ddswavedata.DDS_Sweep.SWEEP_UpDovn
	mov		command.SWEEP_UpDovn,eax
	mov		eax,ddswavedata.DDS_Sweep.SWEEP_Min
	mov		command.SWEEP_Min,eax
	mov		eax,ddswavedata.DDS_Sweep.SWEEP_Max
	mov		command.SWEEP_Max,eax
	mov		eax,ddswavedata.DDS_Sweep.SWEEP_Add
	mov		command.SWEEP_Add,eax
	ret

MakeCommand endp

SampleThreadProc proc lParam:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	tmp:DWORD

	;Get frequency and DVM
	invoke STLinkRead,hWnd,STM32_Frequency,addr tmp,4
	invoke FormatFrequency,addr buffer,addr szNULL,tmp
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCFREQUENCY,addr buffer
	invoke STLinkRead,hWnd,STM32_DVM,addr tmp,4
	mov		eax,tmp
	mov		ecx,DVMMUL
	mul		ecx
	mov		ecx,DVMMAX
	div		ecx
	invoke FormatVoltage,addr buffer,addr szFmtVolts,eax
	invoke SetDlgItemText,childdialogs.hWndFrequency,IDC_UDCVOLTSDVM,addr buffer
	.if fCommand
		mov		fCommand,0
		invoke STLinkReset,hWnd
		.if ddswavedata.DDS_Enable
			invoke STLinkWrite,hWnd,STM32_Wave,addr ddswavedata.DDS_WaveData,4096
		.endif
		invoke MakeCommand
		invoke STLinkWrite,hWnd,STM32_Command,addr command,sizeof COMMAND
		.if ddswavedata.FRQ_Enable
			mov		command.cmnd,STM32_CMNDFrqEnable
			invoke STLinkWrite,hWnd,STM32_Command,addr command,4
		.endif
		mov		command.cmnd,STM32_CMNDStart
		invoke STLinkWrite,hWnd,STM32_Command,addr command,4
	.endif
	.if command.DDS_SubMode==SWEEP_SubModePeak && ddswavedata.DDS_Enable
		invoke STLinkRead,hWnd,STM32_Peak,addr ddswavedata.DDS_PeakData,1536*WORD
		invoke InvalidateRect,childdialogs.hWndDDSPeak,NULL,TRUE
	.endif
	mov		fThread,FALSE
	ret

SampleThreadProc endp

MainDlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	tid:DWORD
	LOCAL	tci:TC_ITEM

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_MAINTAB
		mov		childdialogs.hWndMainTab,eax
		mov		tci.imask,TCIF_TEXT
		mov		tci.lpReserved1,0
		mov		tci.lpReserved2,0
		mov		tci.iImage,-1
		mov		tci.lParam,0
		mov		tci.pszText,offset szTabTitleDDS
		invoke SendMessage,childdialogs.hWndMainTab,TCM_INSERTITEM,0,addr tci
		mov		tci.pszText,offset szTabTitleHSC
		invoke SendMessage,childdialogs.hWndMainTab,TCM_INSERTITEM,1,addr tci
		invoke CreateFontIndirect,addr Tahoma
		mov		hFont,eax
		;Create DDS Wave child dialog
		invoke CreateDialogParam,hInstance,IDD_DDSWAVE,childdialogs.hWndMainTab,addr DDSWaveChildProc,0
		mov		childdialogs.hWndDDSWaveDialog,eax
		;Create HS Clock child dialog
		invoke CreateDialogParam,hInstance,IDD_HSCLOCK,childdialogs.hWndMainTab,addr HSClockChildProc,0
		mov		childdialogs.hWndHSClockDialog,eax
		;Create frequency and DVM child dialog
		invoke CreateDialogParam,hInstance,IDD_FREQUENCY,childdialogs.hWndDDSWaveDialog,addr FrequencyChildProc,0
		mov		childdialogs.hWndFrequency,eax
		invoke SetTimer,hWin,1000,333,NULL
	.elseif eax==WM_TIMER
		.if !fConnected
			mov		fConnected,IDIGNORE
			invoke STLinkConnect,hWin
			.if eax==IDABORT
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.else
				mov		fConnected,eax
			.endif
			.if fConnected && fConnected!=IDIGNORE
				invoke STLinkReset,hWnd
				.if ddswavedata.FRQ_Enable
					mov		command.cmnd,STM32_CMNDFrqEnable
					invoke STLinkWrite,hWnd,STM32_Command,addr command,4
				.endif
			.endif
		.endif
		.if fConnected && fConnected!=IDIGNORE && !fThread
			mov		fThread,TRUE
			invoke CreateThread,NULL,NULL,addr SampleThreadProc,hWin,0,addr tid
			invoke CloseHandle,eax
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		.if [eax].NMHDR.code==TCN_SELCHANGE
			invoke SendMessage,childdialogs.hWndMainTab,TCM_GETCURSEL,0,0
			.if !eax
				invoke ShowWindow,childdialogs.hWndDDSWaveDialog,SW_SHOWNA
				invoke SetParent,childdialogs.hWndFrequency,childdialogs.hWndDDSWaveDialog
				invoke ShowWindow,childdialogs.hWndHSClockDialog,SW_HIDE
			.else
				invoke ShowWindow,childdialogs.hWndHSClockDialog,SW_SHOWNA
				invoke SetParent,childdialogs.hWndFrequency,childdialogs.hWndHSClockDialog
				invoke ShowWindow,childdialogs.hWndDDSWaveDialog,SW_HIDE
			.endif
		.endif
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,childdialogs.hWndMainTab,0,0,rect.right,rect.bottom,TRUE
		add		rect.left,5
		sub		rect.right,10
		add		rect.top,25
		sub		rect.bottom,30
		invoke MoveWindow,childdialogs.hWndDDSWaveDialog,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke MoveWindow,childdialogs.hWndHSClockDialog,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.elseif	eax==WM_CLOSE
		invoke KillTimer,hWin,1000
		.if fConnected
			invoke STLinkDisconnect
		.endif
		invoke DeleteObject,hFont
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MainDlgProc endp

start:
	
	invoke	GetModuleHandle,NULL
	mov		hInstance,eax
	invoke	InitCommonControls
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset TextProc
	mov		wc.lpszClassName,offset szTEXTCLASS
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,0
	mov		eax,hInstance
	mov		wc.hInstance,eax
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,0,IDC_ARROW
	mov		wc.hCursor,eax
	mov		wc.hbrBackground,NULL
	invoke RegisterClassEx,addr wc
	invoke LoadCursor,0,IDC_CROSS
	mov		wc.hCursor,eax
	mov		wc.lpfnWndProc,offset DDSWaveProc
	mov		wc.lpszClassName,offset szDDSWAVECLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset DDSPeakProc
	mov		wc.lpszClassName,offset szDDSPEAKCLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset HSClockProc
	mov		wc.lpszClassName,offset szHSCLOCKCLASS
	invoke RegisterClassEx,addr wc
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr MainDlgProc,NULL
	invoke	ExitProcess,0

end start
