
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

include STM32_Scope.inc
include Frequency.asm
include Scope.asm
include WaveGenerator.asm
include LogicAnalyser.asm
include HSClock.asm
include DDSWaveGenerator.asm

.code

GetSample proc uses ebx esi edi,hWin:HWND,lpCommand:DWORD,lpCommandDone:DWORD
	LOCAL	ADC_Command:STM32_CommandStructDef

	.if !fConnected
		;Connect to the STLink
		invoke STLinkConnect,hWin
		mov		fConnected,eax
		.if fConnected
			invoke STLinkReset,hWin
		.endif
	.endif
  Again:
	.if fConnected
		;Make a local copy of initialisation data
		invoke RtlMoveMemory,addr ADC_Command,lpCommand,sizeof STM32_CommandStructDef
		.if ADC_Command.STM32_Mode>=STM32_ModeWriteByte && ADC_Command.STM32_Mode<=STM32_ModeReadFullWord
			;Send all initialisation data
			mov		ADC_Command.STM32_Command,STM32_CommandWait
			invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,sizeof STM32_CommandStructDef
			.if eax
				;Send initialisation command
				mov		ADC_Command.STM32_Command,STM32_CommandInit
				invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,4
				xor		ebx,ebx
				.while ebx<200
					invoke Sleep,10
					invoke STLinkRead,hWin,STM32CommandStart,addr ADC_Command,sizeof STM32_CommandStructDef
					.break .if ADC_Command.STM32_Command==STM32_CommandWait
					inc		ebx
				.endw
				invoke RtlMoveMemory,lpCommandDone,addr ADC_Command,sizeof STM32_CommandStructDef
				add		lpCommand,sizeof STM32_CommandStructDef
				add		lpCommandDone,sizeof STM32_CommandStructDef
				jmp		Again
			.endif
		.elseif ADC_Command.STM32_Mode!=STM32_ModeNone && ADC_Command.STM32_Mode!=STM32_ModeDDSWave
			;Copy the PWM initialization values
			mov		al,scopedata.ADC_CommandStruct.ADC_TriggerValueCHA
			mov		ADC_Command.ADC_TriggerValueCHA,al
			mov		al,scopedata.ADC_CommandStruct.ADC_DCNullOutCHA
			mov		ADC_Command.ADC_DCNullOutCHA,al
			mov		al,scopedata.ADC_CommandStruct.ADC_TriggerValueCHB
			mov		ADC_Command.ADC_TriggerValueCHB,al
			mov		al,scopedata.ADC_CommandStruct.ADC_DCNullOutCHB
			mov		ADC_Command.ADC_DCNullOutCHB,al
			;Copy the logic analyser trigger values
			mov		al,lgadata.LGA_CommandStruct.LGA_TriggerValue
			mov		ADC_Command.LGA_TriggerValue,al
			mov		al,lgadata.LGA_CommandStruct.LGA_TriggerMask
			mov		ADC_Command.LGA_TriggerMask,al
			mov		al,lgadata.LGA_CommandStruct.LGA_TriggerEdge
			mov		ADC_Command.LGA_TriggerEdge,al
			;Set the timeout to 5 seconds
			mov		ADC_Command.TIM3_TimeOut,5
			.if ADC_Command.STM32_Mode==STM32_ModeScopeCHACHB && ADC_Command.STM32_DataBlocks==1
				;If CHA and CHB then minimum 2 blocks are needed
				mov		ADC_Command.STM32_DataBlocks,2
			.endif
			;Send all initialisation data
			mov		ADC_Command.STM32_Command,STM32_CommandWait
			invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,sizeof STM32_CommandStructDef
			.if eax
				;Send initialisation command
				mov		ADC_Command.STM32_Command,STM32_CommandInit
				invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,4
				invoke Sleep,50
				;Send command to start data sampling
				mov		ADC_Command.STM32_Command,STM32_CommandSampleStart
				invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,4
				;Wait for sampled data to be ready
				xor		ebx,ebx
				.while ebx<200
					invoke Sleep,100
					invoke STLinkRead,hWin,STM32CommandStart,addr ADC_Command,4
					.break .if ADC_Command.STM32_Command==STM32_CommandDone
					inc		ebx
				.endw
				invoke RtlZeroMemory,addr STM32_Data,STM32_DataSize
				;Read sampled ADC data
				movzx	eax,ADC_Command.STM32_DataBlocks
				mov		ecx,STM32_BlockSize
				mul		ecx
				invoke STLinkRead,hWin,STM32DataStart,addr STM32_Data,eax
				;Signal that the data has been read
				mov		ADC_Command.STM32_Command,STM32_CommandWait
				invoke STLinkWrite,hWin,STM32CommandStart,addr ADC_Command,4
				;Copy executed command to 'done' command
				invoke RtlMoveMemory,lpCommandDone,addr ADC_Command,sizeof STM32_CommandStructDef
				;Update the screen
				.if ADC_Command.STM32_Mode==STM32_ModeScopeCHA
					mov		esi,offset STM32_Data
					mov		edi,offset scopedata.scopeCHAdata.ADC_Data
					mov		ecx,STM32_DataSize
					rep		movsb
					mov		al,scopedata.ADC_CommandStructDone.STM32_TriggerMode
					mov		scopedata.scopeCHAdata.ADC_TriggerEdge,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_TriggerValueCHA
					mov		scopedata.scopeCHAdata.ADC_TriggerValue,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_DCNullOutCHA
					mov		scopedata.scopeCHAdata.ADC_DCNullOut,al
					;Get frequency and period for CHA
					fld		nsinasec
					fild	scopedata.scopeCHAdata.frq_data.Frequency
					fst		scopedata.scopeCHAdata.frequency
					fdivp	st(1),st
					fstp	scopedata.scopeCHAdata.period
					;Update the scope screen
					.if scopedata.scopeCHAdata.fSubsampling
						invoke Subsampling,childdialogs.hWndScopeCHA
					.endif
					invoke InvalidateRect,scopedata.scopeCHAdata.hWndScope,NULL,TRUE
					invoke UpdateWindow,scopedata.scopeCHAdata.hWndScope
				.elseif ADC_Command.STM32_Mode==STM32_ModeScopeCHB
					mov		esi,offset STM32_Data
					mov		edi,offset scopedata.scopeCHBdata.ADC_Data
					mov		ecx,STM32_DataSize
					rep		movsb
					mov		al,scopedata.ADC_CommandStructDone.STM32_TriggerMode
					mov		scopedata.scopeCHBdata.ADC_TriggerEdge,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_TriggerValueCHB
					mov		scopedata.scopeCHBdata.ADC_TriggerValue,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_DCNullOutCHB
					mov		scopedata.scopeCHBdata.ADC_DCNullOut,al
					;Get frequency and period for CHB
					fld		nsinasec
					fild	scopedata.scopeCHBdata.frq_data.Frequency
					fst		scopedata.scopeCHBdata.frequency
					fdivp	st(1),st
					fstp	scopedata.scopeCHBdata.period
					;Update the scope screen
					.if scopedata.scopeCHBdata.fSubsampling
						invoke Subsampling,childdialogs.hWndScopeCHB
					.endif
					invoke InvalidateRect,scopedata.scopeCHBdata.hWndScope,NULL,TRUE
					invoke UpdateWindow,scopedata.scopeCHBdata.hWndScope
				.elseif ADC_Command.STM32_Mode==STM32_ModeScopeCHACHB
					mov		esi,offset STM32_Data
					mov		edi,offset scopedata.scopeCHAdata.ADC_Data
					mov		ebx,offset scopedata.scopeCHBdata.ADC_Data
					xor		ecx,ecx
					.while ecx<STM32_DataSize/2
						mov		ax,[esi+ecx*WORD]
						mov		[edi+ecx],al
						mov		[ebx+ecx],ah
						inc		ecx
					.endw
					mov		al,scopedata.ADC_CommandStructDone.STM32_TriggerMode
					mov		scopedata.scopeCHAdata.ADC_TriggerEdge,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_TriggerValueCHA
					mov		scopedata.scopeCHAdata.ADC_TriggerValue,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_DCNullOutCHA
					mov		scopedata.scopeCHAdata.ADC_DCNullOut,al
					mov		al,scopedata.ADC_CommandStructDone.STM32_TriggerMode
					mov		scopedata.scopeCHBdata.ADC_TriggerEdge,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_TriggerValueCHB
					mov		scopedata.scopeCHBdata.ADC_TriggerValue,al
					mov		al,scopedata.ADC_CommandStructDone.ADC_DCNullOutCHB
					mov		scopedata.scopeCHBdata.ADC_DCNullOut,al
					movzx	eax,ADC_Command.STM32_DataBlocks
					shr		eax,1
					mov		scopedata.ADC_CommandStructDone.STM32_DataBlocks,al
					;Get frequency and period for CHA
					fld		nsinasec
					fild	scopedata.scopeCHAdata.frq_data.Frequency
					fst		scopedata.scopeCHAdata.frequency
					fdivp	st(1),st
					fstp	scopedata.scopeCHAdata.period
					;Get frequency and period for CHB
					fld		nsinasec
					fild	scopedata.scopeCHBdata.frq_data.Frequency
					fst		scopedata.scopeCHBdata.frequency
					fdivp	st(1),st
					fstp	scopedata.scopeCHBdata.period
					;Update the CHA scope screen
					.if scopedata.scopeCHAdata.fSubsampling
						invoke Subsampling,childdialogs.hWndScopeCHA
					.endif
					;Update the CHB scope screen
					.if scopedata.scopeCHBdata.fSubsampling
						invoke Subsampling,childdialogs.hWndScopeCHB
					.endif
					invoke InvalidateRect,scopedata.scopeCHAdata.hWndScope,NULL,TRUE
					invoke UpdateWindow,scopedata.scopeCHAdata.hWndScope
					invoke InvalidateRect,scopedata.scopeCHBdata.hWndScope,NULL,TRUE
					invoke UpdateWindow,scopedata.scopeCHBdata.hWndScope
				.elseif ADC_Command.STM32_Mode==STM32_ModeLGA
					;Update the logic analyser screen
					mov		esi,offset STM32_Data
					mov		edi,offset lgadata.LGA_Data
					mov		ecx,STM32_DataSize
					rep		movsb
					invoke InvalidateRect,lgadata.hWndLGA,NULL,TRUE
					invoke UpdateWindow,lgadata.hWndLGA
				.endif
			.endif
		.endif
	.else
		invoke CheckDlgButton,hWnd,IDC_CHKAUTO,BST_UNCHECKED
	.endif
	ret

GetSample endp

SampleThreadProc proc lParam:DWORD
	LOCAL	DVM[2]:DWORD

	.while !fThreadExit
		.if !ddsdata.DDS_Enable
			mov		fDDSWave,0
			.if fWave==1
				mov		fWave,2
				invoke GetSample,lParam,offset rwdata.RW_CommandStruct,offset rwdata.RW_CommandStructDone
				mov		fWave,0
			.endif
			.if fSample==1
				mov		fSample,2
				mov		eax,lpSTM32_Command
				movzx	eax,[eax].STM32_CommandStructDef.STM32_Mode
				.if eax==STM32_ModeDDSWave
					invoke GetSample,lParam,lpSTM32_Command,lpSTM32_CommandDone
				.else
					.if !fWaveFile
						invoke GetSample,lParam,lpSTM32_Command,lpSTM32_CommandDone
					.endif
				.endif
				mov		fSample,0
			.endif
		.else
			.if fDDSWave
				invoke DDSSetWave
				.if fDDSWave>1
					mov		fDDSWave,1
				.else
					dec		fDDSWave
				.endif
			.endif
		.endif
		.if fFRQDVM
			.if fConnected
				;Read frequency for CHA
				invoke STLinkRead,hWnd,STM32FrequencyCHA,addr scopedata.scopeCHAdata.frq_data,4
				.if fConnected
					;Read frequency for CHB
					invoke STLinkRead,hWnd,STM32FrequencyCHB,addr scopedata.scopeCHBdata.frq_data,4
					.if fConnected
						;Read DVM data for CHA and CHB from injected channels
						invoke STLinkRead,hWnd,4001243Ch,addr DVM,8
						mov		eax,DVM[0]
						mov		scopedata.scopeCHAdata.frq_data.DVM,ax
						mov		eax,DVM[4]
						mov		scopedata.scopeCHBdata.frq_data.DVM,ax
						;Set frequency and DVM data
						fild	scopedata.scopeCHAdata.frq_data.Frequency
						fstp	scopedata.scopeCHAdata.frequency
						fild	scopedata.scopeCHBdata.frq_data.Frequency
						fstp	scopedata.scopeCHBdata.frequency
						invoke SetFrequencyAndDVM
					.endif
				.endif
			.endif
			mov		fFRQDVM,0
		.endif
		.if fPeakDetect
			.if fConnected
				;Read peak detect data
				mov		eax,ddsdata.SWEEP_StepCount
				shl		eax,1
				add		eax,DDSSWEEP
				invoke STLinkRead,hWnd,STM32DataStart+4096,addr ddsdata.DDS_PeakData,eax
				invoke InvalidateRect,ddsdata.hWndDDSPeak,NULL,TRUE
			.endif
			mov		fPeakDetect,0
		.endif
	.endw
	mov		fThreadExit,0
	ret

SampleThreadProc endp

MainDlgProc	proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	tid:DWORD
	LOCAL	msg:MSG

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke CreateFontIndirect,addr Tahoma
		mov		hFont,eax
		;Setup scopedata
		mov		scopedata.ADC_CommandStruct.STM32_Mode,STM32_ModeScopeCHA
		mov		scopedata.ADC_CommandStruct.STM32_SampleRateL,0
		mov		scopedata.ADC_CommandStruct.STM32_SampleRateH,0
		mov		scopedata.ADC_CommandStruct.STM32_DataBlocks,4
		mov		scopedata.ADC_CommandStruct.STM32_TriggerMode,STM32_TriggerManual
		mov		scopedata.ADC_CommandStruct.ADC_TriggerValueCHA,ADCMAX/2
		mov		scopedata.ADC_CommandStruct.ADC_DCNullOutCHA,ADCMAX/2
		mov		scopedata.ADC_CommandStruct.ADC_AmplifyCHA,07h
		mov		scopedata.ADC_CommandStruct.ADC_TriggerValueCHB,ADCMAX/2
		mov		scopedata.ADC_CommandStruct.ADC_DCNullOutCHB,ADCMAX/2
		mov		scopedata.ADC_CommandStruct.ADC_AmplifyCHB,07h
		mov		scopedata.ADC_CommandStruct.LGA_TriggerValue,0FFh
		mov		scopedata.ADC_CommandStruct.LGA_TriggerMask,0FFh
		mov		scopedata.ADC_CommandStruct.STM32_Mode,STM32_ModeScopeCHA
		mov		lpSTM32_Command,offset scopedata.ADC_CommandStruct
		mov		lpSTM32_CommandDone,offset scopedata.ADC_CommandStructDone
		invoke RtlMoveMemory,offset scopedata.ADC_CommandStructDone,offset scopedata.ADC_CommandStruct,sizeof STM32_CommandStructDef
		;Create scope child dialogs
		invoke CreateDialogParam,hInstance,IDD_DLGSCOPE,hWin,addr ScopeChildProc,offset scopedata.scopeCHAdata
		mov		childdialogs.hWndScopeCHA,eax
		invoke CreateDialogParam,hInstance,IDD_DLGSCOPE,hWin,addr ScopeChildProc,offset scopedata.scopeCHBdata
		mov		childdialogs.hWndScopeCHB,eax
		;Create wave child dialogs
		invoke CreateDialogParam,hInstance,IDD_DLGWAVEGENERATOR,hWin,addr WaveGeneratorChildProc,offset wavedata.waveCHAdata
		mov		childdialogs.hWndWaveCHA,eax
		invoke CreateDialogParam,hInstance,IDD_DLGWAVEGENERATOR,hWin,addr WaveGeneratorChildProc,offset wavedata.waveCHBdata
		mov		childdialogs.hWndWaveCHB,eax
		;Create high speed clock child dialogs
		invoke CreateDialogParam,hInstance,IDD_DLGHSCLOCK,hWin,addr HSClockChildProc,offset hsclockdata.hscCHAData
		mov		childdialogs.hWndHSClockCHA,eax
		invoke CreateDialogParam,hInstance,IDD_DLGHSCLOCK,hWin,addr HSClockChildProc,offset hsclockdata.hscCHBData
		mov		childdialogs.hWndHSClockCHB,eax
		;Create logic analyser child dialog
		invoke CreateDialogParam,hInstance,IDD_DLGLOGICANALYSER,hWin,addr LogicAnalyserChildProc,0
		mov		childdialogs.hWndLogicAnalyser,eax
		;Create DDS wave generator child dialog
		invoke CreateDialogParam,hInstance,IDD_DLGDDSWAVE,hWin,addr DDSWaveGeneratorChildProc,0
		mov		childdialogs.hWndDDSWaveGenerator,eax
		;Create frequency and DVM child dialog
		invoke CreateDialogParam,hInstance,IDD_DLGFREQUENCY,hWin,addr FrequencyChildProc,0
		mov		childdialogs.hWndFrequency,eax
		;Insert some scope test data
		mov		eax,07Fh
		xor		ecx,ecx
		mov		edx,11
		mov		edi,offset STM32_Data
		mov		esi,offset scopedata.scopeCHAdata.ADC_Data
		mov		ebx,offset scopedata.scopeCHBdata.ADC_Data
		.while ecx<STM32_DataSize
			mov		[edi+ecx],al
			mov		[esi+ecx],al
			mov		[ebx+ecx],al
			.if sdword ptr eax>0E0h || sdword ptr eax<020h
				neg		edx
			.endif
			add		eax,edx
			inc		ecx
		.endw
		invoke SetupSamplePeriods,2,STM32Clock
		movzx	eax,scopedata.ADC_CommandStruct.STM32_SampleRateL
		lea		eax,SamplePeriod[eax*8]
		fld		qword ptr [eax]
		fst		scopedata.scopeCHAdata.convperiod
		fstp	scopedata.scopeCHBdata.convperiod
		invoke ShowWindow,childdialogs.hWndScopeCHA,SW_SHOWNA
		invoke GetFrequency,childdialogs.hWndScopeCHA
		invoke GetFrequency,childdialogs.hWndScopeCHB
		invoke SetFrequencyAndDVM
		invoke WaveInit
		invoke ScopeSetupSampleRate
		invoke LGASetupSampleRate
		invoke SetTimer,hWin,1000,333,NULL
		invoke CreateThread,NULL,NULL,addr SampleThreadProc,hWin,0,addr tid
		mov		hThread,eax
	.elseif eax==WM_TIMER
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTO
		.if eax && fSample==0
			mov		fSample,1
		.endif
		.if !fFRQDVM
			mov		fFRQDVM,1
		.endif
		.if !fPeakDetect
			mov		eax,lpSTM32_Command
			.if [eax].STM32_CommandStructDef.STM32_Mode==STM32_ModeDDSWave
				.if [eax].STM32_CommandStructDef.SWEEP_SubMode==SWEEP_SubModePeak
					mov		fPeakDetect,1
				.endif
			.endif
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		.if eax==IDM_FILE_OPEN_SCOPECHA
		.elseif eax==IDM_FILE_OPEN_SCOPECHB
		.elseif eax==IDM_FILE_SAVE_SCOPECHA
		.elseif eax==IDM_FILE_SAVE_SCOPECHB
		.elseif eax==IDM_FILE_EXIT || eax==IDCANCEL
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_VIEW_SCOPECHA
			mov		scopedata.ADC_CommandStruct.STM32_Mode,STM32_ModeScopeCHA
			mov		lpSTM32_Command,offset scopedata.ADC_CommandStruct
			mov		lpSTM32_CommandDone,offset scopedata.ADC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_SCOPECHB
			mov		scopedata.ADC_CommandStruct.STM32_Mode,STM32_ModeScopeCHB
			mov		lpSTM32_Command,offset scopedata.ADC_CommandStruct
			mov		lpSTM32_CommandDone,offset scopedata.ADC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_SCOPECHACHB
			mov		scopedata.ADC_CommandStruct.STM32_Mode,STM32_ModeScopeCHACHB
			mov		lpSTM32_Command,offset scopedata.ADC_CommandStruct
			mov		lpSTM32_CommandDone,offset scopedata.ADC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_WAVECHA
			mov		wavedata.WAVE_CommandStruct.STM32_Mode,STM32_ModeWaveCHA
			mov		lpSTM32_Command,offset wavedata.WAVE_CommandStruct
			mov		lpSTM32_CommandDone,offset wavedata.WAVE_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_WAVECHB
			mov		wavedata.WAVE_CommandStruct.STM32_Mode,STM32_ModeWaveCHB
			mov		lpSTM32_Command,offset wavedata.WAVE_CommandStruct
			mov		lpSTM32_CommandDone,offset wavedata.WAVE_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_WAVECHACHB
			mov		wavedata.WAVE_CommandStruct.STM32_Mode,STM32_ModeWaveCHACHB
			mov		lpSTM32_Command,offset wavedata.WAVE_CommandStruct
			mov		lpSTM32_CommandDone,offset wavedata.WAVE_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_LOGICANALYSER
			mov		lgadata.LGA_CommandStruct.STM32_Mode,STM32_ModeLGA
			mov		lpSTM32_Command,offset lgadata.LGA_CommandStruct
			mov		lpSTM32_CommandDone,offset lgadata.LGA_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_HSCLOCKCHA
			mov		hsclockdata.HSC_CommandStruct.STM32_Mode,STM32_ModeHSClockCHA
			mov		lpSTM32_Command,offset hsclockdata.HSC_CommandStruct
			mov		lpSTM32_CommandDone,offset hsclockdata.HSC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_HSCLOCKCHB
			mov		hsclockdata.HSC_CommandStruct.STM32_Mode,STM32_ModeHSClockCHB
			mov		lpSTM32_Command,offset hsclockdata.HSC_CommandStruct
			mov		lpSTM32_CommandDone,offset hsclockdata.HSC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_HSCLOCKCHACHB
			mov		hsclockdata.HSC_CommandStruct.STM32_Mode,STM32_ModeHSClockCHACHB
			mov		lpSTM32_Command,offset hsclockdata.HSC_CommandStruct
			mov		lpSTM32_CommandDone,offset hsclockdata.HSC_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_HIDE
		.elseif eax==IDM_VIEW_DDSWAVE
			mov		lpSTM32_Command,offset ddsdata.DDS_CommandStruct
			mov		lpSTM32_CommandDone,offset ddsdata.DDS_CommandStructDone
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke ShowWindow,childdialogs.hWndDDSWaveGenerator,SW_SHOWNA
			invoke ShowWindow,childdialogs.hWndLogicAnalyser,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndScopeCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndWaveCHB,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHA,SW_HIDE
			invoke ShowWindow,childdialogs.hWndHSClockCHB,SW_HIDE
		.elseif eax==IDM_SETUP_SCOPE
			.if childdialogs.hWndScopeSetup
				invoke SetFocus,childdialogs.hWndScopeSetup
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGSCOPESETUP,hWin,addr ScopeSetupProc,0
				mov		childdialogs.hWndScopeSetup,eax
			.endif
		.elseif eax==IDM_SETUP_WAVEFORM
			.if childdialogs.hWndWaveSetup
				invoke SetFocus,childdialogs.hWndWaveSetup
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGWAVESETUP,hWin,addr WaveSetupProc,0
				mov		childdialogs.hWndWaveSetup,eax
			.endif
		.elseif eax==IDM_SETUP_LOGICANALYSER
			.if childdialogs.hWndLGASetup
				invoke SetFocus,childdialogs.hWndLGASetup
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGLGASETUP,hWin,addr LGASetupProc,0
				mov		childdialogs.hWndLGASetup,eax
			.endif
		.elseif eax==IDM_SETUP_HIGHSPEEDCLOCK
			.if childdialogs.hWndHSClockSetup
				invoke SetFocus,childdialogs.hWndHSClockSetup
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGHSCLOCKSETUP,hWin,addr HSClockSetupProc,0
				mov		childdialogs.hWndHSClockSetup,eax
			.endif
		.elseif eax==IDM_SETUP_DDSWAVE
			.if childdialogs.hWndDDSSetup
				invoke SetFocus,childdialogs.hWndDDSSetup
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGDDSWAVESETUP,hWin,addr DDSWaveSetupProc,0
				mov		childdialogs.hWndDDSSetup,eax
			.endif
		.elseif eax==IDM_HELP_ABOUT
		.elseif eax==IDC_BTNSAMPLE
			mov		fSample,TRUE
		.endif
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		mov		edi,rect.right
		sub		edi,85
		mov		ebx,rect.bottom
		sub		ebx,25
		invoke GetDlgItem,hWin,IDCANCEL
		invoke MoveWindow,eax,edi,ebx,80,22,TRUE
		sub		ebx,25
		invoke GetDlgItem,hWin,IDC_BTNSAMPLE
		invoke MoveWindow,eax,edi,ebx,80,22,TRUE
		sub		ebx,20
		invoke GetDlgItem,hWin,IDC_CHKAUTO
		invoke MoveWindow,eax,edi,ebx,80,16,TRUE
		sub		rect.bottom,60
		mov		eax,rect.right
		sub		eax,135
		invoke MoveWindow,childdialogs.hWndFrequency,0,rect.bottom,rect.right,60,TRUE
		mov		eax,lpSTM32_Command
		movzx	eax,[eax].STM32_CommandStructDef.STM32_Mode
		.if eax==STM32_ModeScopeCHA || eax==STM32_ModeScopeCHB
			invoke MoveWindow,childdialogs.hWndScopeCHA,0,0,rect.right,rect.bottom,TRUE
			invoke MoveWindow,childdialogs.hWndScopeCHB,0,0,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeScopeCHACHB
			push	rect.bottom
			shr		rect.bottom,1
			invoke MoveWindow,childdialogs.hWndScopeCHA,0,0,rect.right,rect.bottom,TRUE
			mov		eax,rect.bottom
			pop		rect.bottom
			mov		rect.top,eax
			sub		rect.bottom,eax
			invoke MoveWindow,childdialogs.hWndScopeCHB,0,rect.top,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeWaveCHA || eax==STM32_ModeWaveCHB
			invoke MoveWindow,childdialogs.hWndWaveCHA,0,0,rect.right,rect.bottom,TRUE
			invoke MoveWindow,childdialogs.hWndWaveCHB,0,0,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeWaveCHACHB
			push	rect.bottom
			shr		rect.bottom,1
			invoke MoveWindow,childdialogs.hWndWaveCHA,0,0,rect.right,rect.bottom,TRUE
			mov		eax,rect.bottom
			pop		rect.bottom
			mov		rect.top,eax
			sub		rect.bottom,eax
			invoke MoveWindow,childdialogs.hWndWaveCHB,0,rect.top,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeLGA
			invoke MoveWindow,childdialogs.hWndLogicAnalyser,0,0,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeHSClockCHA
			invoke MoveWindow,childdialogs.hWndHSClockCHA,0,0,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeHSClockCHB
			invoke MoveWindow,childdialogs.hWndHSClockCHB,0,0,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeHSClockCHACHB
			push	rect.bottom
			shr		rect.bottom,1
			invoke MoveWindow,childdialogs.hWndHSClockCHA,0,0,rect.right,rect.bottom,TRUE
			mov		eax,rect.bottom
			pop		rect.bottom
			mov		rect.top,eax
			sub		rect.bottom,eax
			invoke MoveWindow,childdialogs.hWndHSClockCHB,0,rect.top,rect.right,rect.bottom,TRUE
		.elseif eax==STM32_ModeDDSWave
			invoke MoveWindow,childdialogs.hWndDDSWaveGenerator,0,0,rect.right,rect.bottom,TRUE
		.endif
	.elseif	eax==WM_CLOSE
		invoke KillTimer,hWin,1000
		mov		fThreadExit,TRUE
		.while fSample || fWave
			invoke GetMessage,addr msg,0,0,0
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endw
		invoke WaitForSingleObject,hThread,250
		invoke CloseHandle,hThread
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
	mov	hInstance,eax
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
	mov		wc.lpfnWndProc,offset ScopeProc
	invoke LoadCursor,0,IDC_CROSS
	mov		wc.hCursor,eax
	mov		wc.lpszClassName,offset szSCOPECLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset WaveGeneratorProc
	mov		wc.hbrBackground,NULL
	mov		wc.lpszClassName,offset szWAVEGENERATORCLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset LogicAnalyserProc
	mov		wc.hbrBackground,NULL
	mov		wc.lpszClassName,offset szLOGICANALYSERCLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset HSClockProc
	mov		wc.hbrBackground,NULL
	mov		wc.lpszClassName,offset szHSCLOCKCLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset DDSWaveProc
	mov		wc.hbrBackground,NULL
	mov		wc.lpszClassName,offset szDDSWAVECLASS
	invoke RegisterClassEx,addr wc
	mov		wc.lpfnWndProc,offset DDSPeakProc
	mov		wc.hbrBackground,NULL
	mov		wc.lpszClassName,offset szDDSPEAKCLASS
	invoke RegisterClassEx,addr wc
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr MainDlgProc,NULL
	invoke	ExitProcess,0

end start

