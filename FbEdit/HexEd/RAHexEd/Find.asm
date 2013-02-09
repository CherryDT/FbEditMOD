
.code

FindTextUp proc uses ebx esi edi,hMem:DWORD,lpText:DWORD,len:DWORD,cpMin:DWORD,cpMax:DWORD
	LOCAL	lpMem:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		lpMem,eax
	mov		esi,eax
	mov		eax,cpMin
	mov		ecx,cpMax
	.if eax>ecx
		xchg	eax,ecx
	.endif
	shr		eax,1
	shr		ecx,1
	mov		cpMin,eax
	add		ecx,len
	mov		cpMax,ecx
	mov		eax,[ebx].EDIT.nbytes
	.if eax<cpMax
		mov		cpMax,eax
	.endif
	add		cpMin,esi
	add		cpMax,esi
	mov		esi,cpMax
	.while esi>=cpMin
		call	Compare
		.break .if !eax
		dec		esi
	.endw
	.if eax
		xor		eax,eax
		dec		eax
	.else
		mov		eax,esi
		sub		eax,lpMem
		shl		eax,1
	.endif
	push	eax
	invoke GlobalUnlock,[ebx].EDIT.hmem
	pop		eax
	ret

Compare:
	mov		edi,lpText
	mov		ecx,len
	lea		eax,[esi+ecx]
	cmp		eax,cpMax
	jg		Ex
	xor		eax,eax
  @@:
	dec		ecx
	js		Ex
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	je		@b
  Ex:
	retn

FindTextUp endp

FindTextDown proc uses ebx esi edi,hMem:DWORD,lpText:DWORD,len:DWORD,cpMin:DWORD,cpMax:DWORD
	LOCAL	lpMem:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		lpMem,eax
	mov		esi,eax
	mov		eax,cpMin
	mov		ecx,cpMax
	.if eax>ecx
		xchg	eax,ecx
	.endif
	shr		eax,1
	shr		ecx,1
	mov		cpMin,eax
	mov		cpMax,ecx
	mov		eax,[ebx].EDIT.nbytes
	.if eax<cpMax
		mov		cpMax,eax
	.endif
	add		cpMin,esi
	add		cpMax,esi
	mov		esi,cpMin
	.while esi<cpMax
		call	Compare
		.break .if !eax
		inc		esi
	.endw
	.if eax
		xor		eax,eax
		dec		eax
	.else
		mov		eax,esi
		sub		eax,lpMem
		shl		eax,1
	.endif
	push	eax
	invoke GlobalUnlock,[ebx].EDIT.hmem
	pop		eax
	ret

Compare:
	mov		edi,lpText
	mov		ecx,len
	lea		eax,[esi+ecx]
	cmp		eax,cpMax
	jg		Ex
	xor		eax,eax
  @@:
	dec		ecx
	js		Ex
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	je		@b
  Ex:
	retn

FindTextDown endp

FindTextEx proc uses ebx esi edi,hMem:DWORD,fFlag:DWORD,lpFindTextEx:DWORD
	LOCAL	lpText:DWORD
	LOCAL	len:DWORD

	mov		ebx,hMem
	mov		esi,lpFindTextEx
	mov		eax,[esi].FINDTEXTEX.lpstrText
	mov		lpText,eax
	invoke lstrlen,eax
	.if eax
		mov		len,eax
		mov		eax,fFlag
		and		eax,FR_HEX
		.if eax
			invoke ConvertHexString,lpText
			mov		len,eax
			mov		lpText,offset charbuff
		.endif
		mov		eax,[esi].FINDTEXTEX.chrg.cpMin
		.if eax<[esi].FINDTEXTEX.chrg.cpMax
			;Down
			invoke FindTextDown,ebx,lpText,len,[esi].FINDTEXTEX.chrg.cpMin,[esi].FINDTEXTEX.chrg.cpMax
		.elseif eax>[esi].FINDTEXTEX.chrg.cpMax
			;Up
			invoke FindTextUp,ebx,lpText,len,[esi].FINDTEXTEX.chrg.cpMax,[esi].FINDTEXTEX.chrg.cpMin
		.else
			mov		eax,-1
		.endif
		.if eax!=-1
			mov		[esi].FINDTEXTEX.chrgText.cpMin,eax
			mov		edx,len
			shl		edx,1
			add		edx,eax
			mov		[esi].FINDTEXTEX.chrgText.cpMax,edx
		.endif
	.else
		xor		eax,eax
		dec		eax
	.endif
	ret

FindTextEx endp

