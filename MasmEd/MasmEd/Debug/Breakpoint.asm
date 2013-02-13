
.code

ClearBreakpoints proc

	invoke RtlZeroMemory,offset breakpoint,sizeof breakpoint
	invoke RtlZeroMemory,offset szBPSourceName,sizeof szBPSourceName
	ret

ClearBreakpoints endp

AddBreakpoint proc uses ebx esi,nLine:DWORD,lpFileName:DWORD

	mov		esi,offset szBPSourceName
	mov		ebx,0
	.while byte ptr [esi]
		invoke strcmpi,esi,lpFileName
		.break .if !eax
		inc		ebx
		lea		esi,[esi+MAX_PATH]
	.endw
	.if !byte ptr [esi]
		invoke strcpy,esi,lpFileName
	.endif
	mov		esi,offset breakpoint
	.while [esi].BREAKPOINT.LineNumber
		lea		esi,[esi+sizeof BREAKPOINT]
	.endw
	mov		[esi].BREAKPOINT.FileID,ebx
	mov		eax,nLine
	mov		[esi].BREAKPOINT.LineNumber,eax
	ret

AddBreakpoint endp

MapBreakPoints proc uses ebx esi edi
	LOCAL	CountBP:DWORD
	LOCAL	CountSource:DWORD
	LOCAL	Unhandled:DWORD

	mov		esi,dbg.hMemLine
	xor		ecx,ecx
	.while ecx<dbg.inxline
		mov		[esi].DEBUGLINE.BreakPoint,FALSE
		inc		ecx
		add		esi,sizeof DEBUGLINE
	.endw
	mov		Unhandled,0
	mov		CountBP,512
	mov		esi,offset breakpoint
	.while CountBP
		mov		eax,[esi].BREAKPOINT.LineNumber
		.if eax
			push	esi
			call	MatchIt
			pop		esi
		.endif
		dec		CountBP
		add		esi,sizeof BREAKPOINT
	.endw
	mov		eax,Unhandled
	ret

MatchIt:
	mov		eax,[esi].BREAKPOINT.FileID
	mov		edx,MAX_PATH
	mul		edx
	mov		edi,offset szBPSourceName
	lea		edi,[edi+eax]
	mov		eax,dbg.inxsource
	mov		CountSource,eax
	mov		ebx,dbg.hMemSource
	.while CountSource
		invoke strcmpi,edi,addr [ebx].DEBUGSOURCE.FileName
		.if !eax
			mov		edx,[ebx].DEBUGSOURCE.FileID
			mov		eax,[esi].BREAKPOINT.LineNumber
			mov		esi,dbg.hMemLine
			inc		Unhandled
			xor		ecx,ecx
			.while ecx<dbg.inxline
				.if eax==[esi].DEBUGLINE.LineNumber
					.if dx==[esi].DEBUGLINE.FileID
						mov		[esi].DEBUGLINE.BreakPoint,TRUE
						mov		[esi].DEBUGLINE.NoDebug,0
						dec		Unhandled
						.break
					.endif
				.endif
				inc		ecx
				add		esi,sizeof DEBUGLINE
			.endw
			.break
		.endif
		dec		CountSource
		add		ebx,sizeof DEBUGSOURCE
	.endw
	retn

MapBreakPoints endp

SetBreakPointsAll proc

	mov		edx,dbg.minadr
	mov		ecx,dbg.maxadr
	sub		ecx,edx
	invoke WriteProcessMemory,dbg.hdbghand,edx,dbg.hMemBP,ecx,0
	ret

SetBreakPointsAll endp

SetBreakPoints proc uses ebx edi

	mov		edi,dbg.hMemLine
	mov		ebx,dbg.inxline
	.while ebx
		.if [edi].DEBUGLINE.BreakPoint && ![edi].DEBUGLINE.NoDebug
			invoke WriteProcessMemory,dbg.hdbghand,[edi].DEBUGLINE.Address,addr szBP,1,0
		.endif
		lea		edi,[edi+sizeof DEBUGLINE]
		dec		ebx
	.endw
	ret

SetBreakPoints endp

IsLineCode proc uses ebx esi edi,nLine:DWORD,lpFileName:DWORD

	mov		edi,dbg.inxsource
	mov		ebx,dbg.hMemSource
	.while edi
		invoke strcmpi,lpFileName,addr [ebx].DEBUGSOURCE.FileName
		.if !eax
			mov		edx,[ebx].DEBUGSOURCE.FileID
			mov		eax,nLine
			mov		esi,dbg.hMemLine
			xor		ecx,ecx
			.while ecx<dbg.inxline
				.if eax==[esi].DEBUGLINE.LineNumber
					.if dx==[esi].DEBUGLINE.FileID
						mov		eax,TRUE
						jmp		Ex
					.endif
				.endif
				inc		ecx
				add		esi,sizeof DEBUGLINE
			.endw
			.break
		.endif
		dec		edi
		lea		ebx,[ebx+sizeof DEBUGSOURCE]
	.endw
	xor		eax,eax
  Ex:
	ret

IsLineCode endp

SetBreakpointAtCurrentLine proc uses ebx esi edi,nLine:DWORD,lpFileName:DWORD

	mov		edi,dbg.inxsource
	mov		ebx,dbg.hMemSource
	.while edi
		invoke strcmpi,lpFileName,addr [ebx].DEBUGSOURCE.FileName
		.if !eax
			mov		edx,[ebx].DEBUGSOURCE.FileID
			mov		eax,nLine
			mov		esi,dbg.hMemLine
			xor		ecx,ecx
			.while ecx<dbg.inxline
				.if eax==[esi].DEBUGLINE.LineNumber
					.if dx==[esi].DEBUGLINE.FileID
						invoke WriteProcessMemory,dbg.hdbghand,[esi].DEBUGLINE.Address,addr szBP,1,0
						jmp		Ex
					.endif
				.endif
				inc		ecx
				add		esi,sizeof DEBUGLINE
			.endw
			.break
		.endif
		dec		edi
		lea		ebx,[ebx+sizeof DEBUGSOURCE]
	.endw
  Ex:
	ret

SetBreakpointAtCurrentLine endp

ClearBreakPointsAll proc

	mov		edx,dbg.minadr
	mov		ecx,dbg.maxadr
	sub		ecx,edx
	invoke WriteProcessMemory,dbg.hdbghand,edx,dbg.hMemNoBP,ecx,0
	ret

ClearBreakPointsAll endp

MapNoDebug proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[8]:BYTE
	LOCAL	nInx:DWORD

	mov		edi,dbg.hMemSymbol
	mov		ebx,dbg.inxsymbol
	xor		eax,eax
	.while ebx
		mov		[edi].DEBUGSYMBOL.NoDebug,ax
		dec		ebx
		add		edi,sizeof DEBUGSYMBOL
	.endw
	mov		ecx,dbg.inxline
	mov		esi,dbg.hMemLine
	.while ecx
		mov		[esi].DEBUGLINE.NoDebug,al
		dec		ecx
		lea		esi,[esi+sizeof DEBUGLINE]
	.endw
	; Do not debug the proc line
	mov		esi,dbg.hMemSymbol
	mov		ecx,dbg.inxsymbol
	.while ecx
		.if [esi].DEBUGSYMBOL.nType=='p'
			push	ecx
			invoke FindWord,addr [esi].DEBUGSYMBOL.szName,addr szPrpp
			.if eax
				mov		edi,eax
				; Point to parameters
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				movzx	eax,byte ptr [edi]
				.if !eax
					; Point to return type
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					; Point to locals
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					movzx	eax,byte ptr [edi]
				.endif
				.if eax
					mov		eax,[esi].DEBUGSYMBOL.Address
					mov		ebx,dbg.inxline
					mov		edi,dbg.hMemLine
					.while ebx
						.if eax==[edi].DEBUGLINE.Address
							mov		[edi].DEBUGLINE.NoDebug,TRUE
							.break
						.endif
						dec		ebx
						lea		edi,[edi+sizeof DEBUGLINE]
					.endw
				.endif
			.endif
			pop		ecx
		.endif
		dec		ecx
		lea		esi,[esi+sizeof DEBUGSYMBOL]
	.endw
	; Map procs that sould not be debugged
	mov		esi,lpNoDebug
	.while TRUE
		.break .if !byte ptr [esi]
		mov		edi,dbg.hMemSymbol
		mov		ebx,dbg.inxsymbol
		.while ebx
			invoke strcmp,esi,addr [edi].DEBUGSYMBOL.szName
			.if !eax
				mov		[edi].DEBUGSYMBOL.NoDebug,1
				mov		edx,[edi].DEBUGSYMBOL.Address
				mov		eax,edx
				add		edx,[edi].DEBUGSYMBOL.nSize
				mov		ecx,dbg.inxline
				push	esi
				mov		esi,dbg.hMemLine
				.while ecx
					.if [esi].DEBUGLINE.Address>=eax
						.if [esi].DEBUGLINE.Address<edx
							mov		[esi].DEBUGLINE.NoDebug,1
						.endif
					.endif
					dec		ecx
					lea		esi,[esi+sizeof DEBUGLINE]
				.endw
				pop		esi
			.endif
			dec		ebx
			lea		edi,[edi+sizeof DEBUGSYMBOL]
		.endw
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	ret

MapNoDebug endp
