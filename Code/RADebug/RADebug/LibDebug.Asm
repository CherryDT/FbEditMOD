;#########################################################################
; Assembler directives

.486
.model flat,stdcall
option casemap:none
option proc:private

;#########################################################################
;		Include file

include LibDebug.inc
include Misc.asm
include Math.asm
include DbgHelp.asm
include BreakPoint.asm
include Debug.asm
include Immediate.asm

.code

;#########################################################################

EnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	pid:DWORD

	invoke GetWindowThreadProcessId,hWin,addr pid
	.if eax==dbg.thread.threadid
		mov		eax,hWin
		.while eax
			mov		dbg.hWnd,eax
			invoke GetParent,eax
		.endw
		invoke SetForegroundWindow,dbg.hWnd
		xor		eax,eax
		jmp		Ex
	.endif
	mov		eax,TRUE
  Ex:
	ret

EnumProc endp

BringWindowToFront proc uses ebx

	xor		ebx,ebx
	.while ebx<10
		invoke EnumWindows,offset EnumProc,0
		.if dbg.hWnd
			invoke GetForegroundWindow
			.break .if eax==dbg.hWnd
		.endif
		invoke Sleep,10
		inc		ebx
	.endw
	ret

BringWindowToFront endp

SetDebugInfo proc public lpDEBUGINFO:DWORD

	mov		edx,lpDEBUGINFO
	mov		eax,[edx].DEBUGINFO.hWnd
	mov		hWnd,eax
	mov		eax,[edx].DEBUGINFO.hOut
	mov		hOut,eax
	mov		eax,[edx].DEBUGINFO.hDbgReg
	mov		hDbgReg,eax
	mov		eax,[edx].DEBUGINFO.hDbgFpu
	mov		hDbgFpu,eax
	mov		eax,[edx].DEBUGINFO.hDbgMMX
	mov		hDbgMMX,eax
	mov		eax,[edx].DEBUGINFO.hDbgWatch
	mov		hDbgWatch,eax
	mov		eax,[edx].DEBUGINFO.hPrp
	mov		hPrp,eax
	mov		eax,[edx].DEBUGINFO.lpNoDebug
	mov		lpNoDebug,eax
	mov		eax,[edx].DEBUGINFO.fMainThread
	mov		fMainThread,eax
	mov		eax,[edx].DEBUGINFO.lpCallBack
	mov		lpCallBack,eax
	mov		eax,[edx].DEBUGINFO.fProject
	mov		fProject,eax
	invoke strcpy,addr szExeName,addr [edx].DEBUGINFO.FileName
	ret

SetDebugInfo endp

DebugCommand proc public uses ebx esi edi,nCmnd:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL	tid:DWORD

	mov		eax,nCmnd
	.if eax==FUNC_BPCLEARALL
		; wParam=0, lParam=0
		invoke ClearBreakpoints
	.elseif eax==FUNC_BPADDLINE
		; wParan=nLine, lParam=lpFileName
		invoke AddBreakpoint,wParam,lParam
	.elseif eax==FUNC_BPUPDATE
		; wParam=0, lParam=0
		.if dbg.hDbgThread
			invoke ClearBreakPointsAll
			invoke MapBreakPoints
			invoke SetBreakPoints
		.endif
	.elseif eax==FUNC_RUN
		; wParam=0, lParam=0
		mov		dbg.func,FUNC_RUN
		.if !dbg.hDbgThread
			invoke CreateThread,NULL,0,addr Debug,addr szExeName,NULL,addr tid
			mov		dbg.hDbgThread,eax
		.else
			mov		dbg.fHandled,FALSE
			invoke ResetSelectLine
			invoke ClearBreakPointsAll
			invoke SetBreakPoints
			mov		dbg.func,FUNC_RUN
			mov		ebx,dbg.lpthread
			.if [ebx].DEBUGTHREAD.suspended
				invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
				mov		[ebx].DEBUGTHREAD.suspended,FALSE
				invoke ResumeThread,[ebx].DEBUGTHREAD.htread
				invoke BringWindowToFront
			.endif
		.endif
	.elseif eax==FUNC_BREAK
		; wParam=0, lParam=0
		.if dbg.hDbgThread
			.if !dbg.fHandled
				mov		dbg.func,FUNC_BREAK
				invoke SetBreakPointsAll
				invoke Sleep,50
				.if !dbg.fHandled
					.if dbg.hWnd
						invoke SetForegroundWindow,dbg.hWnd
					.else
						invoke BringWindowToFront
					.endif
				.endif
			.endif
		.endif
	.elseif eax==FUNC_STOP
		; wParam=0, lParam=0
		.if dbg.hDbgThread
			invoke ResetSelectLine
			mov		dbg.func,FUNC_STOP
			invoke TerminateProcess,dbg.pinfo.hProcess,0
		.endif
	.elseif eax==FUNC_STEPINTO
		; wParam=0, lParam=0
		.if dbg.hDbgThread
			.if dbg.fHandled
				mov		dbg.func,FUNC_STEPINTO
				mov		dbg.fHandled,FALSE
				invoke ResetSelectLine
				invoke SetBreakPointsAll
				mov		ebx,dbg.lpthread
				.if ![ebx].DEBUGTHREAD.suspended
					mov		[ebx].DEBUGTHREAD.suspended,TRUE
					invoke SuspendThread,[ebx].DEBUGTHREAD.htread
				.endif
				invoke SwitchThread
				mov		ebx,eax
				mov		dbg.lpthread,ebx
				.if [ebx].DEBUGTHREAD.suspended
					invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
					mov		[ebx].DEBUGTHREAD.suspended,FALSE
					invoke ResumeThread,[ebx].DEBUGTHREAD.htread
				.endif
			.endif
		.endif
	.elseif eax==FUNC_STEPOVER
		; wParam=0, lParam=0
		.if dbg.hDbgThread
			.if dbg.fHandled
				mov		dbg.func,FUNC_STEPOVER
				mov		dbg.fHandled,FALSE
				invoke ResetSelectLine
				invoke SetBreakPointsAll
				mov		ebx,dbg.lpthread
				.if [ebx].DEBUGTHREAD.suspended
					mov		eax,dbg.lpProc
					mov		dbg.lpStepOver,eax
					invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
					mov		[ebx].DEBUGTHREAD.suspended,FALSE
					invoke ResumeThread,[ebx].DEBUGTHREAD.htread
				.endif
			.endif
		.endif
	.elseif eax==FUNC_RUNTOCARET
		; wParan=nLine, lParam=lpFileName
		.if dbg.hDbgThread
			.if dbg.fHandled
				mov		dbg.func,FUNC_RUNTOCARET
				mov		dbg.fHandled,FALSE
				invoke ResetSelectLine
				invoke ClearBreakPointsAll
				invoke SetBreakPoints
				mov		ebx,dbg.lpthread
				invoke RestoreSourceByte,[ebx].DEBUGTHREAD.address
				invoke SetBreakpointAtCurrentLine,wParam,lParam
				.if [ebx].DEBUGTHREAD.suspended
					mov		[ebx].DEBUGTHREAD.suspended,FALSE
					invoke ResumeThread,[ebx].DEBUGTHREAD.htread
				.endif
			.endif
		.endif
	.elseif eax==FUNC_GETTOOLTIP
		; wParam=hREd, lParam=lpDEBUGTIP
		mov		esi,lParam
		invoke GetVarVal,[esi].DEBUGTIP.lpWord,[esi].DEBUGTIP.nLine,TRUE
		.if eax
			mov		eax,offset outbuffer
		.endif
	.elseif eax==FUNC_IMMEDIATE
		; wParam=hImmOut, lParam=0
		invoke Immediate,wParam
	.elseif eax==FUNC_FILEOPEN
		; wParam=0, lParam=0
		mov		fDoneOpen,TRUE
	.elseif eax==FUNC_ISCODELINE
		; wParan=nLine, lParam=lpFileName
		.if dbg.hDbgThread
			invoke IsLineCode,wParam,lParam
			.if !eax
				invoke PutString,addr szNotCodeLine,hOut,TRUE
				xor		eax,eax
			.endif
		.else
			mov		eax,TRUE
		.endif
	.endif
	ret

DebugCommand endp

end
