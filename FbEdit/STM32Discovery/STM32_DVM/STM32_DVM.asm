.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include STM32_DVM.inc

.code

;########################################################################

DlgProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[32]:BYTE

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke CreateFontIndirect,addr Tahoma_72
		mov		hFont,eax
		invoke SendDlgItemMessage,hWin,IDC_STC1,WM_SETFONT,hFont,FALSE
	.elseif	eax==WM_COMMAND
		mov edx,wParam
		movzx eax,dx
		shr edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				.if !connected
					;Connect to the STLink
					invoke STLinkConnect,hWin
					.if eax && eax!=IDIGNORE && eax!=IDABORT
						mov		connected,eax
						;Create a timer. The event will read the ADCConvertedValue, format it and display the result
						invoke SetTimer,hWin,1000,500,NULL
					.endif
				.endif
			.elseif eax==IDCANCEL
				invoke	SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif	eax==WM_TIMER
		;Read 4 bytes from STM32F100 ram and store it in adcres.
		invoke STLinkRead,hWin,20000000h,addr adcres,4
		.if eax
			;The ADCConvertedValue is a 16 bit variable stored at 20000002h in STM32F100 ram
			mov		eax,adcres
			shr		eax,16
			;The ADC VREF+ is at 3.0 volts since the 3V3 regulators output is connected to
			;a scottky diode before powering the mcu.
			;Multiply by 3.000 volts
			mov		ecx,3000
			mul		ecx
			;Divide by 4095 (the ADC value when the ADC input is at 3.000 volts.
			mov		ecx,0FFFh
			div		ecx
			invoke wsprintf,addr buffer,addr szFmtDec,eax
			;Insert a'.' after the first digit
			mov		eax,dword ptr buffer[1]
			mov		buffer[1],'.'
			mov		dword ptr buffer[2],eax
			invoke SetDlgItemText,hWin,IDC_STC1,addr buffer
		.else
			invoke KillTimer,hWin,1000
			mov		connected,FALSE
		.endif
	.elseif	eax==WM_CLOSE
		invoke KillTimer,hWin,1000
		invoke STLinkDisconnect
		invoke DeleteObject,hFont
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke	ExitProcess,0

end start
