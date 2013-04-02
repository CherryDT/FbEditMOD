
.code

SetClipData proc lpData:LPSTR,dwSize:dword
	LOCAL	hMem:HANDLE
	LOCAL	pMem:dword

	mov		eax,dwSize
	inc		eax
	invoke GlobalAlloc,GHND or GMEM_DDESHARE,eax
	test	eax,eax
	je		@exit2
	mov		hMem,eax
	invoke GlobalLock,eax	;hGlob
	test	eax,eax
	je		@exit1
	mov		pMem,eax
	invoke RtlMoveMemory,eax,lpData,dwSize
	mov		eax,pMem
	add		eax,dwSize
	mov		byte ptr [eax],0
	invoke GlobalUnlock,hMem
	invoke OpenClipboard,NULL
	.if eax
		invoke EmptyClipboard
		invoke SetClipboardData,CF_TEXT,hMem
		invoke CloseClipboard
		xor		eax,eax		;0 - Ok
		jmp		@exit3
	.endif
  @exit1:
	invoke  GlobalFree,hMem
	xor     eax,eax
  @exit2:
	dec     eax          ; -1 - error
  @exit3:
	ret

SetClipData endp

EditGetSelText proc uses ebx esi edi,hMem:DWORD,lpBuff:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD

	mov		ebx,hMem
	mov		edi,lpBuff
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.cpMax
	shr		eax,1
	shr		edx,1
	.if eax!=edx
		.if eax>edx
			xchg	eax,edx
		.endif
		mov		cpMin,eax
		mov		cpMax,edx
		invoke GlobalLock,[ebx].EDIT.hmem
		mov		esi,eax
		xor		ecx,ecx
		mov		edx,cpMin
		.while edx<cpMax
			push	edx
			mov		al,[esi+edx]
			shl		eax,24
			call	Nybble
			mov		[edi],dl
			inc		edi
			call	Nybble
			mov		[edi],dl
			inc		edi
			inc		ecx
			.if ecx==16
				mov		byte ptr [edi],0Dh
				inc		edi
				mov		byte ptr [edi],0Ah
				inc		edi
				xor		ecx,ecx
			.endif
			pop		edx
			inc		edx
		.endw
		.if ecx
			mov		byte ptr [edi],0Dh
			inc		edi
			mov		byte ptr [edi],0Ah
			inc		edi
		.endif
		mov		byte ptr [edi],0
		invoke GlobalUnlock,[ebx].EDIT.hmem
	.endif
	sub		edi,lpBuff
	mov		eax,edi
	ret

EditGetSelText endp

EditCopy proc uses ebx esi edi,hMem:DWORD
	LOCAL	hCMem:DWORD
	LOCAL	lpCMem:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.cpMax
	shr		eax,1
	shr		edx,1
	.if eax!=edx
		.if eax>edx
			xchg	eax,edx
		.endif
		mov		cpMin,eax
		mov		cpMax,edx
		sub		edx,eax
		mov		eax,edx
		shr		edx,4
		add		eax,edx
		shl		eax,1
		add		eax,3
		invoke GlobalAlloc,GMEM_ZEROINIT,eax
		mov     hCMem,eax
		invoke GlobalLock,hCMem
		mov		lpCMem,eax
		mov		edi,lpCMem
		invoke GlobalLock,[ebx].EDIT.hmem
		mov		esi,eax
		xor		ecx,ecx
		mov		edx,cpMin
		.while edx<cpMax
			push	edx
			mov		al,[esi+edx]
			shl		eax,24
			call	Nybble
			mov		[edi],dl
			inc		edi
			call	Nybble
			mov		[edi],dl
			inc		edi
			inc		ecx
			.if ecx==16
				mov		byte ptr [edi],0Dh
				inc		edi
				mov		byte ptr [edi],0Ah
				inc		edi
				xor		ecx,ecx
			.endif
			pop		edx
			inc		edx
		.endw
		.if ecx
			mov		byte ptr [edi],0Dh
			inc		edi
			mov		byte ptr [edi],0Ah
			inc		edi
		.endif
		invoke GlobalUnlock,[ebx].EDIT.hmem
		sub		edi,lpCMem
		invoke SetClipData,lpCMem,edi
		invoke GlobalUnlock,hCMem
		invoke GlobalFree,hCMem
	.endif
	ret

EditCopy endp

EditPaste proc uses ebx,hMem:DWORD

	mov		ebx,hMem
	invoke OpenClipboard,[ebx].EDIT.hwnd
	.if eax
		invoke GetClipboardData,CF_TEXT
		.if eax
			push	eax
			invoke GlobalLock,eax
			push	eax
			invoke SendMessage,[ebx].EDIT.hwnd,WM_CLEAR,0,0
			pop		eax
			mov		edx,[ebx].EDIT.cpMin
			.if edx>[ebx].EDIT.cpMax
				mov		edx,[ebx].EDIT.cpMax
			.endif
			shr		edx,1
			shl		edx,1
			push	edx
			shr		edx,1
			invoke InsertHexString,ebx,edx,eax
			shl		eax,1
			pop		edx
			add		eax,edx
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			pop		eax
			invoke GlobalUnlock,eax
			invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
			invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
			mov		[ebx].EDIT.fChanged,TRUE
			inc		[ebx].EDIT.nchange
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,FALSE
			invoke ScrollCaret,[ebx].EDIT.focus
			invoke SelChange,ebx,SEL_TEXT
		.endif
		invoke CloseClipboard
	.endif
	ret

EditPaste endp

