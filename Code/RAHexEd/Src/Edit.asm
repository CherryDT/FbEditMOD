
.code

GetChar proc uses ebx edi,hMem:DWORD,ncp:DWORD

	mov		ebx,hMem
	xor		eax,eax
	mov		edi,ncp
	.if edi<[ebx].EDIT.nbytes
		invoke GlobalLock,[ebx].EDIT.hmem
		movzx	edi,byte ptr [edi+eax]
		invoke GlobalUnlock,[ebx].EDIT.hmem
		mov		eax,edi
	.endif
	ret

GetChar endp

PutChar proc uses ebx esi edi,hMem:DWORD,ncp:DWORD,lpChar:DWORD,nChars:DWORD

	mov		ebx,hMem
	mov		edi,ncp
	mov		eax,[ebx].EDIT.nbytes
	add		eax,nChars
	.if eax>=[ebx].EDIT.nsize
		and		eax,-1 xor (MAXCHARMEM-1)
		add		eax,MAXCHARMEM
		mov		[ebx].EDIT.nsize,eax
		invoke GlobalReAlloc,[ebx].EDIT.hmem,eax,GMEM_MOVEABLE or GMEM_ZEROINIT
		.if !eax
			invoke MessageBox,NULL,addr szMemFailChar,addr szToolTip,MB_OK
			mov		eax,[ebx].EDIT.hmem
		.endif
		mov		[ebx].EDIT.hmem,eax
	.endif
	invoke GlobalLock,[ebx].EDIT.hmem
	add		edi,eax
	mov		esi,lpChar
	mov		ecx,nChars
	rep movsb
	invoke GlobalUnlock,[ebx].EDIT.hmem
	ret

PutChar endp

InsertChars proc uses ebx esi edi,hMem:DWORD,ncp:DWORD,nChars:DWORD
	LOCAL	lpMem:DWORD

	mov		ebx,hMem
	mov		edi,ncp
	.if edi>[ebx].EDIT.nbytes
		mov		edi,[ebx].EDIT.nbytes
		mov		ncp,edi
	.endif
	mov		eax,[ebx].EDIT.nbytes
	add		eax,nChars
	.if eax>=[ebx].EDIT.nsize
		and		eax,-1 xor (MAXCHARMEM-1)
		add		eax,MAXCHARMEM
		mov		[ebx].EDIT.nsize,eax
		invoke GlobalReAlloc,[ebx].EDIT.hmem,eax,GMEM_MOVEABLE or GMEM_ZEROINIT
		.if !eax
			invoke MessageBox,NULL,addr szMemFailChar,addr szToolTip,MB_OK
			mov		eax,[ebx].EDIT.hmem
		.endif
		mov		[ebx].EDIT.hmem,eax
	.endif
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		lpMem,eax
	mov		esi,eax
	add		esi,[ebx].EDIT.nbytes
	mov		edi,esi
	add		edi,nChars
	mov		ecx,[ebx].EDIT.nbytes
	inc		ecx
	sub		ecx,ncp
	std
	rep movsb
	cld
	mov		edi,ncp
	add		edi,lpMem
	mov		ecx,nChars
	xor		eax,eax
	rep stosb
	invoke GlobalUnlock,[ebx].EDIT.hmem
	mov		eax,nChars
	add		[ebx].EDIT.nbytes,eax
	ret

InsertChars endp

DeleteChars proc uses ebx esi edi,hMem:DWORD,ncp:DWORD,nChars:DWORD
	LOCAL	lpMem:DWORD

	mov		ebx,hMem
	mov		eax,ncp
	.if eax>[ebx].EDIT.nbytes
		mov		eax,[ebx].EDIT.nbytes
		mov		ncp,eax
	.endif
	add		eax,nChars
	.if eax>[ebx].EDIT.nbytes
		mov		eax,[ebx].EDIT.nbytes
		sub		eax,ncp
		mov		nChars,eax
	.endif
	mov		edi,ncp
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		lpMem,eax
	add		edi,eax
	mov		esi,edi
	add		esi,nChars
	mov		ecx,[ebx].EDIT.nbytes
	add		ecx,lpMem
	sub		ecx,esi
	rep movsb
	invoke GlobalUnlock,[ebx].EDIT.hmem
	mov		eax,nChars
	sub		[ebx].EDIT.nbytes,eax
	ret

DeleteChars endp

DeleteSelection proc uses ebx,hMem:DWORD,cpMin:DWORD,cpMax:DWORD

	mov		ebx,hMem
	mov		eax,cpMin
	mov		ecx,cpMax
	.if eax>ecx
		xchg	eax,ecx
	.endif
	mov		cpMin,eax
	mov		cpMax,ecx
	shr		eax,1
	shr		ecx,1
	sub		ecx,eax
	shl		eax,1
	invoke SaveUndo,ebx,UNDO_DELETEBLOCK,eax,0,ecx
	mov		eax,cpMin
	mov		ecx,cpMax
	shr		eax,1
	shr		ecx,1
	sub		ecx,eax
	.if ecx
		invoke DeleteChars,ebx,eax,ecx
		mov		eax,cpMin
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		mov		[ebx].EDIT.fChanged,TRUE
		inc		[ebx].EDIT.nchange
		invoke ScrollCaret,[ebx].EDIT.focus
		invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		invoke SetCaret,[ebx].EDIT.focus
		invoke SelChange,ebx,SEL_TEXT
	.endif
	ret

DeleteSelection endp

InsertBlock proc uses ebx,hMem:DWORD,ncp:DWORD,lpStr:DWORD,nBytes:DWORD

	mov		ebx,hMem
	.if nBytes
		invoke InsertChars,ebx,ncp,nBytes
		invoke PutChar,ebx,ncp,lpStr,nBytes
		mov		edx,ncp
		shl		edx,1
		invoke SaveUndo,ebx,UNDO_INSERTBLOCK,edx,0,nBytes
	.endif
	ret

InsertBlock endp

InsertHexString proc uses ebx esi,hMem:DWORD,ncp:DWORD,lpStr:DWORD

	mov		ebx,hMem
	mov		esi,lpStr
	push	ncp
  Nxt:
	invoke ConvertHexString,esi
	.if edx
		add		esi,edx
		push	eax
		invoke InsertChars,ebx,ncp,eax
		pop		eax
		push	eax
		invoke PutChar,ebx,ncp,offset charbuff,eax
		pop		eax
		add		ncp,eax
		jmp		Nxt
	.endif
	pop		eax
	push	eax
	mov		edx,eax
	sub		eax,ncp
	neg		eax
	shl		edx,1
	invoke SaveUndo,ebx,UNDO_INSERTBLOCK,edx,0,eax
	pop		eax
	sub		eax,ncp
	neg		eax
	ret

InsertHexString endp

InsertAsciiString proc uses ebx,hMem:DWORD,ncp:DWORD,lpStr:DWORD

	mov		ebx,hMem
	invoke lstrlen,lpStr
	invoke InsertBlock,ebx,ncp,lpStr,eax
	ret

InsertAsciiString endp

StreamIn proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	dwRead:DWORD
	LOCAL	hCMem:DWORD

	mov		ebx,hMem
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM
	mov     hCMem,eax
	invoke GlobalLock,hCMem
	xor		edi,edi
  @@:
	mov		esi,lParam
	mov		[esi].EDITSTREAM.dwError,0
	lea		eax,dwRead
	push	eax
	mov		eax,MAXSTREAM
	push	eax
	push	hCMem
	mov		eax,[esi].EDITSTREAM.dwCookie
	push	eax
	mov		eax,[esi].EDITSTREAM.pfnCallback
	call	eax
	or		eax,eax
	jne		@f
	.if dwRead
		mov		esi,hCMem
		invoke PutChar,ebx,edi,esi,dwRead
		add		edi,dwRead
		mov		[ebx].EDIT.nbytes,edi
		jmp		@b
	.endif
  @@:
	invoke GlobalUnlock,hCMem
	invoke GlobalFree,hCMem
	ret

StreamIn endp

StreamOut proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	dwWrite:DWORD
	LOCAL	hCMem:DWORD

	mov		ebx,hMem
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM
	mov     hCMem,eax
	invoke GlobalLock,hCMem
	xor		esi,esi
  @@:
	call	FillCMem
	or		ecx,ecx
	je		@f
	mov		edx,lParam
	mov		[edx].EDITSTREAM.dwError,0
	lea		eax,dwWrite
	push	eax
	push	ecx
	push	hCMem
	mov		eax,[edx].EDITSTREAM.dwCookie
	push	eax
	mov		eax,[edx].EDITSTREAM.pfnCallback
	call	eax
	or		eax,eax
	je		@b
  @@:
	invoke GlobalUnlock,hCMem
	invoke GlobalFree,hCMem
	ret

FillCMem:
	mov		edi,hCMem
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		edx,eax
	xor		ecx,ecx
	.while esi<[ebx].EDIT.nbytes && ecx<MAXSTREAM
		mov		al,[edx+esi]
		mov		[edi],al
		inc		ecx
		inc		esi
		inc		edi
	.endw
	push	ecx
	invoke GlobalUnlock,[ebx].EDIT.hmem
	pop		ecx
	retn

StreamOut endp

