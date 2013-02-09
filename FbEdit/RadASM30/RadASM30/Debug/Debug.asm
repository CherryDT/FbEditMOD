
.const

szDump							db 'Reg Hex               Dec Bin',0Dh,0
szRegs							db 'EAX %08Xh %11d ',0,
								   'ECX %08Xh %11d ',0,
								   'EDX %08Xh %11d ',0,
								   'EBX %08Xh %11d ',0,
								   'ESP %08Xh %11d ',0,
								   'EBP %08Xh %11d ',0,
								   'ESI %08Xh %11d ',0,
								   'EDI %08Xh %11d ',0,
								   'EIP %08Xh %11d ',0,
								   '    AV-R NIODIT-SZ A P C',0Dh,
								   'EFL ',0

szFpu							db 'Reg Dec',0Dh,0
szFpuReg						db 'ST%d ',0
szFpuCTW						db '       XRCPC-  PUOZDI',0Dh,
								   'CTW ',0
szFpuSTW						db '    B3TOP210-ESPUOZDI',0Dh,
								   'STW ',0

szMMX							db 'Reg  Hex',0Dh,0
szMMXReg						db 'XMM%d %08X%08Xh',0

.data?

szContext						db 1024 dup(?)
LineChanged						dd 32 dup(?)

.code

ShowRegContext proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	decbuff[32]:BYTE
	LOCAL	nLine:DWORD
	LOCAL	szContextPtr:DWORD
	LOCAL	LineChangedInx:DWORD

	mov		szContextPtr,offset szContext
	mov		LineChangedInx,0
	mov		LineChanged,0
	mov		eax,offset szDump
	call	AddText
	mov		nLine,1
	mov		esi,offset szRegs
	mov		ebx,dbg.context.regEax
	mov		edi,dbg.prevcontext.regEax
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEcx
	mov		edi,dbg.prevcontext.regEcx
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEdx
	mov		edi,dbg.prevcontext.regEdx
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEbx
	mov		edi,dbg.prevcontext.regEbx
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEsp
	mov		edi,dbg.prevcontext.regEsp
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEbp
	mov		edi,dbg.prevcontext.regEbp
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEsi
	mov		edi,dbg.prevcontext.regEsi
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEdi
	mov		edi,dbg.prevcontext.regEdi
	mov		eax,32
	call	RegOut
	mov		ebx,dbg.context.regEip
	mov		edi,dbg.prevcontext.regEip
	mov		eax,32
	call	RegOut
	inc		nLine
	mov		ebx,dbg.context.regFlag
	mov		edi,dbg.prevcontext.regFlag
	shl		ebx,32-18
	shl		edi,32-18
	mov		eax,18
	call	RegOut
	invoke SetWindowText,hDbgReg,addr szContext
	invoke SendMessage,hDbgReg,REM_SETHILITELINE,0,1
	invoke SendMessage,hDbgReg,REM_SETHILITELINE,10,1
	mov		ebx,offset LineChanged
	.while dword ptr [ebx]
		invoke SendMessage,hDbgReg,REM_LINEREDTEXT,[ebx],TRUE
		lea		ebx,[ebx+4]
	.endw
	ret

AddText:
	invoke strcpy,szContextPtr,eax
	invoke strlen,szContextPtr
	add		szContextPtr,eax
	retn

RegOut:
	push	eax
	invoke wsprintf,addr buffer,esi,ebx,ebx
	invoke strlen,addr buffer
	pop		edx
	invoke BinOut,addr buffer[eax],ebx,edx
	invoke strcat,addr buffer,addr szCR
	lea		eax,buffer
	call	AddText
	.if ebx!=edi
		mov		edx,LineChangedInx
		lea		edx,[edx*4+offset LineChanged]
		mov		eax,nLine
		mov		[edx],eax
		mov		dword ptr [edx+4],0
		inc		LineChangedInx
	.endif
	invoke strlen,esi
	lea		esi,[esi+eax+1]
	inc		nLine
	retn

ShowRegContext endp

ShowFpuContext proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	nLine:DWORD
	LOCAL	szContextPtr:DWORD
	LOCAL	LineChangedInx:DWORD

	mov		szContextPtr,offset szContext
	mov		LineChangedInx,0
	mov		LineChanged,0
	mov		eax,offset szFpu
	call	AddText
	mov		esi,offset dbg.context.FloatSave.RegisterArea
	mov		edi,offset dbg.prevcontext.FloatSave.RegisterArea
	xor		ecx,ecx
	mov		nLine,ecx
	.while ecx<8
		inc		nLine
		push	ecx
		call	RegOut
		pop		ecx
		inc		ecx
		lea		esi,[esi+10]
		lea		edi,[edi+10]
	.endw
	add		nLine,2
	invoke strcpy,addr buffer,offset szFpuCTW
	invoke strlen,addr buffer
	mov		edx,dbg.context.FloatSave.ControlWord
	shl		edx,16
	invoke BinOut,addr buffer[eax],edx,16
	invoke strcat,addr buffer,addr szCR
	lea		eax,buffer
	call	AddText
	mov		edx,dbg.prevcontext.FloatSave.ControlWord
	.if edx!=dbg.context.FloatSave.ControlWord
		mov		edx,LineChangedInx
		lea		edx,[edx*4+offset LineChanged]
		mov		eax,nLine
		mov		[edx],eax
		mov		dword ptr [edx+4],0
		inc		LineChangedInx
	.endif
	add		nLine,2
	invoke strcpy,addr buffer,offset szFpuSTW
	invoke strlen,addr buffer
	mov		edx,dbg.context.FloatSave.StatusWord
	shl		edx,16
	invoke BinOut,addr buffer[eax],edx,16
	invoke strcat,addr buffer,addr szCR
	lea		eax,buffer
	call	AddText
	mov		edx,dbg.prevcontext.FloatSave.StatusWord
	.if edx!=dbg.context.FloatSave.StatusWord
		mov		edx,LineChangedInx
		lea		edx,[edx*4+offset LineChanged]
		mov		eax,nLine
		mov		[edx],eax
		mov		dword ptr [edx+4],0
		inc		LineChangedInx
	.endif
	invoke SetWindowText,hDbgFpu,addr szContext
	invoke SendMessage,hDbgFpu,REM_SETHILITELINE,0,1
	invoke SendMessage,hDbgFpu,REM_SETHILITELINE,9,1
	invoke SendMessage,hDbgFpu,REM_SETHILITELINE,11,1
	mov		ebx,offset LineChanged
	.while dword ptr [ebx]
		invoke SendMessage,hDbgFpu,REM_LINEREDTEXT,[ebx],TRUE
		lea		ebx,[ebx+4]
	.endw
	ret

AddText:
	invoke strcpy,szContextPtr,eax
	invoke strlen,szContextPtr
	add		szContextPtr,eax
	retn

RegOut:
	invoke wsprintf,addr buffer,offset szFpuReg,ecx
	invoke strlen,addr buffer
	invoke FpToAscii,esi,addr buffer[eax],TRUE
	invoke strcat,addr buffer,addr szCR
	lea		eax,buffer
	call	AddText
	mov		eax,[esi+6]
	sub		eax,[edi+6]
	jnz		@f
	mov		eax,[esi+2]
	sub		eax,[edi+2]
	jnz		@f
	mov		ax,[esi]
	sub		ax,[edi]
	jnz		@f
	retn
  @@:
	mov		edx,LineChangedInx
	lea		edx,[edx*4+offset LineChanged]
	mov		eax,nLine
	mov		[edx],eax
	mov		dword ptr [edx+4],0
	inc		LineChangedInx
	retn

ShowFpuContext endp

ShowMMXContext proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	decbuff[32]:BYTE
	LOCAL	nLine:DWORD
	LOCAL	szContextPtr:DWORD
	LOCAL	LineChangedInx:DWORD

	mov		szContextPtr,offset szContext
	mov		LineChangedInx,0
	mov		LineChanged,0
	mov		eax,offset szMMX
	call	AddText
	mov		nLine,1
	mov		esi,offset dbg.context.FloatSave.RegisterArea
	mov		edi,offset dbg.prevcontext.FloatSave.RegisterArea
	xor		ecx,ecx
	mov		nLine,ecx
	.while ecx<8
		inc		nLine
		push	ecx
		call	RegOut
		pop		ecx
		inc		ecx
		lea		esi,[esi+10]
		lea		edi,[edi+10]
	.endw
	invoke SetWindowText,hDbgMMX,addr szContext
	invoke SendMessage,hDbgMMX,REM_SETHILITELINE,0,1
	mov		ebx,offset LineChanged
	.while dword ptr [ebx]
		invoke SendMessage,hDbgMMX,REM_LINEREDTEXT,[ebx],TRUE
		lea		ebx,[ebx+4]
	.endw
	ret

AddText:
	invoke strcpy,szContextPtr,eax
	invoke strlen,szContextPtr
	add		szContextPtr,eax
	retn

RegOut:
	invoke wsprintf,addr buffer,offset szMMXReg,ecx,dword ptr [esi+4],dword ptr [esi]
	invoke strlen,addr buffer
	invoke strcat,addr buffer,addr szCR
	lea		eax,buffer
	call	AddText
	mov		eax,[esi+4]
	sub		eax,[edi+4]
	mov		eax,[esi]
	sbb		eax,[edi]
	.if !ZERO?
		mov		edx,LineChangedInx
		lea		edx,[edx*4+offset LineChanged]
		mov		eax,nLine
		mov		[edx],eax
		mov		dword ptr [edx+4],0
		inc		LineChangedInx
	.endif
	retn

ShowMMXContext endp

RestoreSourceByte proc uses ebx edi,Address:DWORD
	
	mov		eax,Address
	.if eax
		call	Restore
	.else
		lea		ebx,dbg.thread
		.while [ebx].DEBUGTHREAD.htread
			mov		eax,[ebx].DEBUGTHREAD.address
			.if eax
				call	Restore
			.endif
			lea		ebx,[ebx+sizeof DEBUGTHREAD]
		.endw
	.endif
	ret

Restore:
	mov		edi,dbg.hMemNoBP
	add		edi,eax
	sub		edi,dbg.minadr
	invoke WriteProcessMemory,dbg.hdbghand,eax,edi,1,0
	retn

RestoreSourceByte endp

ResetSelectLine proc

	.if dbg.prevline!=-1
		push	dbg.prevhwnd
		push	dbg.prevline
		push	CB_DESELECTLINE
		call	lpCallBack
	.endif
	ret

ResetSelectLine endp

SelectLine proc uses ebx esi edi,lpDEBUGLINE:DWORD
	LOCAL	chrg:CHARRANGE

	mov		ebx,lpDEBUGLINE
	movzx	eax,[ebx].DEBUGLINE.FileID
	mov		edx,sizeof DEBUGSOURCE
	mul		edx
	mov		esi,dbg.hMemSource
	lea		esi,[esi+eax]
	lea		eax,[esi].DEBUGSOURCE.FileName
	push	eax
	push	0
	push	CB_OPENFILE
	call	lpCallBack
	; Let MasmEd do its things
	xor		edi,edi
	mov		fDoneOpen,edi
	.while edi<250 && !fDoneOpen
		invoke Sleep,15
		inc		edi
	.endw
	push	0
	mov		eax,[ebx].DEBUGLINE.LineNumber
	mov		dbg.prevline,eax
	push	eax
	push	CB_SELECTLINE
	call	lpCallBack
	mov		dbg.prevhwnd,eax
	ret

SelectLine endp

FindThread proc uses ebx,ThreadID:DWORD

	lea		ebx,dbg.thread
	mov		eax,ThreadID
	.while [ebx].DEBUGTHREAD.htread
		.if eax==[ebx].DEBUGTHREAD.threadid
			mov		eax,ebx
			jmp		Ex
		.endif
		add		ebx,sizeof DEBUGTHREAD
	.endw
	xor		eax,eax
  Ex:
	ret

FindThread endp

AddThread proc uses ebx,hThread:HANDLE,ThreadID:DWORD

	lea		ebx,dbg.thread
	.while [ebx].DEBUGTHREAD.htread
		lea		ebx,[ebx+sizeof DEBUGTHREAD]
	.endw
	mov		eax,hThread
	mov		[ebx].DEBUGTHREAD.htread,eax
	mov		eax,ThreadID
	mov		[ebx].DEBUGTHREAD.threadid,eax
	mov		[ebx].DEBUGTHREAD.lpline,0
	mov		[ebx].DEBUGTHREAD.suspended,FALSE
	mov		eax,ebx
	ret

AddThread endp

RemoveThread proc uses esi edi,ThreadID:DWORD

	invoke FindThread,ThreadID
	mov		edi,eax
	lea		esi,[edi+sizeof DEBUGTHREAD]
	.while [edi].DEBUGTHREAD.htread
		mov		ecx,sizeof DEBUGTHREAD
		rep movsb
	.endw
	ret

RemoveThread endp

SwitchThread proc uses ebx

	mov		ebx,dbg.lpthread
	add		ebx,sizeof DEBUGTHREAD
	.while [ebx].DEBUGTHREAD.htread
		.if [ebx].DEBUGTHREAD.suspended
			jmp		Ex
		.endif
		add		ebx,sizeof DEBUGTHREAD
	.endw
	lea		ebx,dbg.thread
  Ex:
	mov		eax,ebx
	ret

SwitchThread endp

IsInProc proc uses esi,Address:DWORD

	mov		esi,dbg.hMemSymbol
	mov		eax,Address
	.while [esi].DEBUGSYMBOL.szName
		.if [esi].DEBUGSYMBOL.nType=='p'
			mov		edx,[esi].DEBUGSYMBOL.Address
			mov		ecx,[esi].DEBUGSYMBOL.nSize
			lea		ecx,[edx+ecx]
			.if eax>=edx && eax<ecx
				mov		eax,esi
				jmp		Ex
			.endif
		.endif
		lea		esi,[esi+sizeof DEBUGSYMBOL]
	.endw
	xor		eax,eax
  Ex:
	ret

IsInProc endp

IsOnBP proc uses esi,Address:DWORD

	mov		esi,dbg.hMemLine
	mov		eax,Address
	invoke FindLine,Address
	movzx	eax,[eax].DEBUGLINE.BreakPoint
	ret

IsOnBP endp

Debug proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	sinfo:STARTUPINFO
	LOCAL	de:DEBUG_EVENT
	LOCAL	fContinue:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	fOnBP:DWORD

	invoke RtlZeroMemory,addr sinfo,sizeof STARTUPINFO
	mov		sinfo.cb,SizeOf STARTUPINFO
	mov		sinfo.dwFlags,STARTF_USESHOWWINDOW
	mov		sinfo.wShowWindow,SW_NORMAL
	;Create the process to be debugged
	invoke CreateProcess,NULL,lpFileName,NULL,NULL,FALSE,NORMAL_PRIORITY_CLASS Or DEBUG_PROCESS Or DEBUG_ONLY_THIS_PROCESS,NULL,NULL,addr sinfo,addr dbg.pinfo
	.if eax
		invoke SendMessage,hOut,WM_SETTEXT,0,addr szNULL
		invoke WaitForSingleObject,dbg.pinfo.hProcess,10
		invoke OpenProcess,PROCESS_ALL_ACCESS,TRUE,dbg.pinfo.dwProcessId
		mov		dbg.hdbghand,eax
		invoke DbgHelp,offset DbgHelpDLL,dbg.pinfo.hProcess,addr szExeName
		.if !dbg.inxline
			invoke PutString,addr szNoDebugInfo,hOut,TRUE
			invoke PutString,addr szExeName,hOut,TRUE
			mov		fNoDebugInfo,TRUE
			push	0
			push	FALSE
			push	CB_DEBUG
			call	lpCallBack
		.else
			push	0
			push	TRUE
			push	CB_DEBUG
			call	lpCallBack
			invoke wsprintf,addr buffer,addr szFinal,dbg.inxsource,dbg.inxline,dbg.inxsymbol,dbg.nNotFound
			invoke PutString,addr buffer,hOut,dbg.nNotFound
			invoke wsprintf,offset outbuffer,addr szDebuggingStarted,addr szExeName
			invoke PutString,offset outbuffer,hOut,FALSE
			mov		fNoDebugInfo,FALSE
;			invoke MapNoDebug
			mov		ebx,dbg.hMemLine
			mov		eax,[ebx].DEBUGLINE.Address
			mov		dbg.minadr,eax
			mov		eax,dbg.inxline
			dec		eax
			mov		edx,sizeof DEBUGLINE
			mul		edx
			lea		ebx,[ebx+eax]
			mov		eax,[ebx].DEBUGLINE.Address
			mov		dbg.lastadr,eax
			add		eax,4
			mov		dbg.maxadr,eax
			sub		eax,dbg.minadr
			mov		ebx,eax
			invoke GlobalAlloc,GMEM_FIXED,ebx
			mov		dbg.hMemNoBP,eax
			invoke GlobalAlloc,GMEM_FIXED,ebx
			mov		dbg.hMemBP,eax
			invoke ReadProcessMemory,dbg.hdbghand,dbg.minadr,dbg.hMemNoBP,ebx,0
			invoke ReadProcessMemory,dbg.hdbghand,dbg.minadr,dbg.hMemBP,ebx,0
			invoke MapBreakPoints
			.if eax
				invoke wsprintf,addr buffer,addr szUnhandledBreakpoints,eax
				invoke MessageBox,hOut,addr buffer,addr szDebug,MB_OK or MB_ICONEXCLAMATION
			.endif
			mov		ebx,dbg.hMemLine
			mov		ecx,dbg.inxline
			mov		edx,dbg.hMemBP
			.while ecx
				.if ![ebx].DEBUGLINE.NoDebug
					mov		eax,[ebx].DEBUGLINE.Address
					sub		eax,dbg.minadr
					mov		byte ptr [edx+eax],0CCh
				.endif
				lea		ebx,[ebx+sizeof DEBUGLINE]
				dec		ecx
			.endw
			invoke SetBreakPoints
			.if dbg.nErrors
				mov		eax,dbg.hMemVar
				mov		dbg.lpvar,eax
				invoke RtlZeroMemory,eax,256*1024
				invoke wsprintf,addr outbuffer,addr szErrorParsing,dbg.nErrors
				invoke PutString,addr outbuffer,hOut,TRUE
			.endif
		.endif
		mov		dbg.prevline,-1
		invoke AddThread,dbg.pinfo.hThread,dbg.pinfo.dwThreadId
		mov		[eax].DEBUGTHREAD.isdebugged,TRUE
		.while TRUE
			invoke WaitForDebugEvent,addr de,INFINITE
			mov		fContinue,DBG_CONTINUE
			mov		eax,de.dwDebugEventCode
			.if eax==EXCEPTION_DEBUG_EVENT
				mov		eax,de.u.Exception.pExceptionRecord.ExceptionCode
				.if eax==EXCEPTION_BREAKPOINT
					.if de.u.Exception.pExceptionRecord.ExceptionAddress<800000h
						invoke FindThread,de.dwThreadId
						mov		ebx,eax
						invoke IsOnBP,de.u.Exception.pExceptionRecord.ExceptionAddress
						mov		fOnBP,eax
						mov		edx,de.dwThreadId
						.if fMainThread && edx!=dbg.thread.threadid && !fOnBP
							invoke SuspendThread,[ebx].DEBUGTHREAD.htread
							mov		dbg.tmpcontext.ContextFlags,CONTEXT_FULL or CONTEXT_FLOATING_POINT
							invoke GetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.tmpcontext
							mov		eax,de.u.Exception.pExceptionRecord.ExceptionAddress
							mov		dbg.tmpcontext.regEip,eax
							mov		[ebx].DEBUGTHREAD.address,eax
							invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
							invoke SetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.tmpcontext
							invoke ResumeThread,[ebx].DEBUGTHREAD.htread
						.else
							.if ![ebx].DEBUGTHREAD.isdebugged
								mov		[ebx].DEBUGTHREAD.suspended,TRUE
								mov		[ebx].DEBUGTHREAD.isdebugged,TRUE
								invoke SuspendThread,[ebx].DEBUGTHREAD.htread
								mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
							.else
								mov		dbg.lpthread,ebx
								invoke IsInProc,de.u.Exception.pExceptionRecord.ExceptionAddress
								.if dbg.func==FUNC_STEPOVER && eax!=dbg.lpStepOver && !fOnBP
									mov		dbg.context.ContextFlags,CONTEXT_FULL or CONTEXT_FLOATING_POINT
									invoke GetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.context
									mov		eax,de.u.Exception.pExceptionRecord.ExceptionAddress
									mov		dbg.context.regEip,eax
									mov		[ebx].DEBUGTHREAD.address,eax
									invoke SetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.context
									invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
								.else
									.if ![ebx].DEBUGTHREAD.suspended
										mov		[ebx].DEBUGTHREAD.suspended,TRUE
										mov		[ebx].DEBUGTHREAD.isdebugged,TRUE
										invoke SuspendThread,[ebx].DEBUGTHREAD.htread
									.endif
									invoke FindLine,de.u.Exception.pExceptionRecord.ExceptionAddress
									mov		edx,[ebx].DEBUGTHREAD.lpline
									mov		[ebx].DEBUGTHREAD.lpline,eax
									.if eax!=edx
										push	TRUE
									.else
										push	FALSE
									.endif
									.if eax
										invoke SelectLine,eax
									.endif
									mov		dbg.context.ContextFlags,CONTEXT_FULL or CONTEXT_FLOATING_POINT
									invoke GetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.context
									mov		eax,de.u.Exception.pExceptionRecord.ExceptionAddress
									mov		dbg.context.regEip,eax
									mov		[ebx].DEBUGTHREAD.address,eax
									invoke SetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.context
									invoke IsInProc,[ebx].DEBUGTHREAD.address
									mov		dbg.lpProc,eax
									pop		eax
									.if eax
										invoke ShowRegContext
										invoke ShowFpuContext
										invoke ShowMMXContext
										invoke RtlMoveMemory,addr dbg.prevcontext,addr dbg.context,sizeof CONTEXT
									.endif
									invoke WatchVars
								.endif
								mov		dbg.fHandled,TRUE
							.endif
						.endif
					.endif
				.elseif eax==EXCEPTION_ACCESS_VIOLATION
					invoke wsprintf,addr outbuffer,addr szEXCEPTION_ACCESS_VIOLATION,de.u.Exception.pExceptionRecord.ExceptionAddress,de.dwThreadId
					invoke PutString,addr outbuffer,hOut,TRUE
					invoke WriteProcessMemory,dbg.hdbghand,de.u.Exception.pExceptionRecord.ExceptionAddress,addr szBP,1,0
					.if !eax
						invoke ResetSelectLine
						mov		dbg.func,FUNC_STOP
						invoke TerminateProcess,dbg.pinfo.hProcess,0
					.endif
				.elseif eax==EXCEPTION_FLT_DIVIDE_BY_ZERO
					invoke wsprintf,addr outbuffer,addr szEXCEPTION_FLT_DIVIDE_BY_ZERO,de.u.Exception.pExceptionRecord.ExceptionAddress,de.dwThreadId
					invoke PutString,addr outbuffer,hOut,TRUE
					invoke WriteProcessMemory,dbg.hdbghand,de.u.Exception.pExceptionRecord.ExceptionAddress,addr szBP,1,0
				.elseif eax==EXCEPTION_INT_DIVIDE_BY_ZERO
					invoke wsprintf,addr outbuffer,addr szEXCEPTION_INT_DIVIDE_BY_ZERO,de.u.Exception.pExceptionRecord.ExceptionAddress,de.dwThreadId
					invoke PutString,addr outbuffer,hOut,TRUE
					invoke WriteProcessMemory,dbg.hdbghand,de.u.Exception.pExceptionRecord.ExceptionAddress,addr szBP,1,0
				.elseif eax==EXCEPTION_DATATYPE_MISALIGNMENT
					invoke PutString,addr szEXCEPTION_DATATYPE_MISALIGNMENT,hOut,TRUE
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==EXCEPTION_SINGLE_STEP
					invoke PutString,addr szEXCEPTION_SINGLE_STEP,hOut,TRUE
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==DBG_CONTROL_C
					invoke PutString,addr szDBG_CONTROL_C,hOut,TRUE
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.else
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.endif
			.elseif eax==CREATE_PROCESS_DEBUG_EVENT
				.if !dbg.hdbgfile
					mov		eax,de.u.CreateProcessInfo.hFile
					mov		dbg.hdbgfile,eax
				.endif
				invoke wsprintf,addr outbuffer,addr szCREATE_PROCESS_DEBUG_EVENT,de.dwProcessId,de.dwThreadId
				invoke PutString,addr outbuffer,hOut,FALSE
			.elseif eax==EXIT_PROCESS_DEBUG_EVENT
				invoke wsprintf,addr outbuffer,addr szEXIT_PROCESS_DEBUG_EVENT,de.dwProcessId,de.dwThreadId,de.u.ExitProcess.dwExitCode
				invoke PutString,addr outbuffer,hOut,FALSE
				mov		eax,de.dwProcessId
				.if eax==dbg.pinfo.dwProcessId
					invoke ContinueDebugEvent,de.dwProcessId,de.dwThreadId,DBG_CONTINUE
					.break
				.endif
			.elseif eax==CREATE_THREAD_DEBUG_EVENT
				invoke AddThread,de.u.CreateThread.hThread,de.dwThreadId
				invoke wsprintf,addr outbuffer,addr szCREATE_THREAD_DEBUG_EVENT,de.dwThreadId
				invoke PutString,addr outbuffer,hOut,FALSE
			.elseif eax==EXIT_THREAD_DEBUG_EVENT
				invoke wsprintf,addr outbuffer,addr szEXIT_THREAD_DEBUG_EVENT,de.dwThreadId,de.u.ExitThread.dwExitCode
				invoke PutString,addr outbuffer,hOut,FALSE
				invoke FindThread,de.dwThreadId
				.if eax
					mov		dbg.lpthread,eax
					invoke RemoveThread,de.dwThreadId
					invoke SwitchThread
					mov		ebx,eax
					.if [ebx].DEBUGTHREAD.suspended
						mov		dbg.lpthread,ebx
						mov		[ebx].DEBUGTHREAD.suspended,FALSE
						invoke ResumeThread,[ebx].DEBUGTHREAD.htread
					.endif
				.endif
			.elseif eax==LOAD_DLL_DEBUG_EVENT
				mov		buffer,0
				invoke GetModuleFileName,de.u.LoadDll.lpBaseOfDll,addr buffer,sizeof buffer
				invoke wsprintf,addr outbuffer,addr szLOAD_DLL_DEBUG_EVENT,addr buffer
				invoke PutString,addr outbuffer,hOut,FALSE
			.elseif eax==UNLOAD_DLL_DEBUG_EVENT
				mov		buffer,0
				invoke GetModuleFileName,de.u.UnloadDll.lpBaseOfDll,addr buffer,sizeof buffer
				invoke wsprintf,addr outbuffer,addr szUNLOAD_DLL_DEBUG_EVENT,addr buffer
				invoke PutString,addr outbuffer,hOut,FALSE
			.elseif eax==OUTPUT_DEBUG_STRING_EVENT
				movzx	eax,de.u.DebugString.nDebugStringiLength
				.if eax>255
					mov		eax,255
				.endif
				invoke ReadProcessMemory,dbg.hdbghand,de.u.DebugString.lpDebugStringData,addr buffer,eax,0
				invoke wsprintf,addr outbuffer,addr szOUTPUT_DEBUG_STRING_EVENT,addr buffer
				invoke PutString,addr outbuffer,hOut,FALSE
			.elseif eax==RIP_EVENT
				invoke PutString,addr szRIP_EVENT,hOut,TRUE
			.endif
			invoke ContinueDebugEvent,de.dwProcessId,de.dwThreadId,fContinue
		.endw
Ex:
		; Close debug handles
		invoke CloseHandle,dbg.hdbgfile
		invoke CloseHandle,dbg.hdbghand
		invoke CloseHandle,dbg.pinfo.hThread
		invoke CloseHandle,dbg.pinfo.hProcess
		; Free debug memory
		.if dbg.hMemLine
			invoke GlobalFree,dbg.hMemLine
			mov		dbg.hMemLine,0
		.endif
		.if dbg.hMemType
			invoke GlobalFree,dbg.hMemType
			mov		dbg.hMemType,0
		.endif
		.if dbg.hMemSymbol
			invoke GlobalFree,dbg.hMemSymbol
			mov		dbg.hMemSymbol,0
		.endif
		.if dbg.hMemSource
			invoke GlobalFree,dbg.hMemSource
			mov		dbg.hMemSource,0
		.endif
		invoke GlobalFree,dbg.hMemNoBP
		invoke GlobalFree,dbg.hMemBP
	.endif
	invoke CloseHandle,dbg.hDbgThread
	mov		dbg.hDbgThread,0
	invoke ResetSelectLine
	mov		fNoDebugInfo,FALSE
	mov		dbg.fHandled,FALSE
	invoke wsprintf,offset outbuffer,addr szDebugStopped,addr szExeName
	invoke PutString,offset outbuffer,hOut,FALSE
	invoke RtlZeroMemory,addr dbg,sizeof DEBUG
	push	0
	push	FALSE
	push	CB_DEBUG
	call	lpCallBack
	ret

Debug endp
