.code

;SetupCasetab proc uses ebx
;
;	;Setup whole CaseTab
;	xor		ebx,ebx
;	.while ebx<256
;		invoke IsCharAlpha,ebx
;		.if eax
;			invoke CharUpper,ebx
;			.if eax==ebx
;				invoke CharLower,ebx
;			.endif
;			mov		Casetab[ebx],al
;		.else
;			mov		Casetab[ebx],bl
;		.endif
;		inc		ebx
;	.endw
;	ret
;
;SetupCasetab endp

strlen proc lpSource:DWORD

	mov	eax,lpSource
	sub	eax,4
align 4
@@:
	add	eax, 4
	movzx	edx,word ptr [eax]
	test	dl,dl
	je	@lb1
	
	test	dh, dh
	je	@lb2
	
	movzx	edx,word ptr [eax+2]
	test	dl, dl
	je	@lb3

	test	dh, dh
	jne	@B
	
	sub	eax,lpSource
	add	eax,3
	ret

@lb3:
	sub	eax,lpSource
	add	eax,2
	ret

@lb2:
	sub	eax,lpSource
	add	eax,1
	ret

@lb1:
	sub	eax,lpSource
	ret

strlen endp

strcpy proc uses ebx,lpdest:DWORD,lpsource:DWORD

	mov		ebx,lpsource
	mov		edx,lpdest
	xor		ecx,ecx
  @@:
	mov		al,[ebx+ecx]
	mov		[edx+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpy endp

strcpyn proc uses ebx,lpdest:DWORD,lpsource:DWORD,nmax:DWORD

	.if nmax
		mov		ebx,lpsource
		mov		edx,lpdest
		dec		nmax
		xor		ecx,ecx
	  @@:
		mov		al,[ebx+ecx]
		.if ecx==nmax
			xor		al,al
		.endif
		mov		[edx+ecx],al
		inc		ecx
		or		al,al
		jne		@b
	.endif
	ret

strcpyn endp

strcat proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	invoke strlen,esi
	xor		ecx,ecx
	lea		esi,[esi+eax]
  @@:
	mov		al,[edi+ecx]
	mov		[esi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

strcatn proc uses esi edi,lpword1:DWORD,lpword2:DWORD,nmax:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	invoke strlen,esi
	xor		ecx,ecx
	lea		esi,[esi+eax]
	dec		nmax
  @@:
	mov		al,[edi+ecx]
	.if ecx==nmax
		xor		al,al
	.endif
	mov		[esi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcatn endp

strcmp proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	xor		ecx,ecx
	dec		ecx
	mov		eax,ecx
	mov		edx,ecx
  @@:
	or		eax,edx
	je		Found
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	movzx	edx,byte ptr [edi+ecx]
	sub		eax,edx
	je		@b
  Found:
	ret

strcmp endp

strcmpn proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpn endp

;strcmpi proc uses esi edi,lpword1:DWORD,lpword2:DWORD
;
;	mov		esi,lpword1
;	mov		edi,lpword2
;	xor		ecx,ecx
;	dec		ecx
;	mov		eax,ecx
;	mov		edx,ecx
;  @@:
;	or		eax,edx
;	je		Found
;	inc		ecx
;	movzx	eax,byte ptr [esi+ecx]
;	movzx	edx,byte ptr [edi+ecx]
;	cmp		eax,edx
;	je		@b
;	movzx	edx,byte ptr Casetab[edx]
;	cmp		eax,edx
;	je		@b
;	movzx	edx,byte ptr Casetab[edx]
;	sub		eax,edx
;  Found:
;	ret
;
;strcmpi endp

strcmpin proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpin endp

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	ret

DwToAscii endp

AsciiToDw proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpStr
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    pop     esi
    pop     ebx
    ret

AsciiToDw endp

SearchMemDown proc uses ebx ecx edx esi edi,hMem:DWORD,lpFind:DWORD,fMCase:DWORD,fWWord:DWORD,lpCharTab:DWORD

	mov		cl,byte ptr fWWord
	mov		ch,byte ptr fMCase
	mov		edi,hMem
	dec		edi
	mov		esi,lpFind
  Nx:
	xor		edx,edx
	inc		edi
	dec		edx
  Mr:
	inc		edx
	mov		al,[edi+edx]
	mov		ah,[esi+edx]
	.if ah && al
		cmp		al,ah
		je		Mr
		.if !ch
			;Try other case (upper/lower)
			movzx	ebx,ah
			add		ebx,lpCharTab
			cmp		al,[ebx+256]
			je		Mr
		.endif
		jmp		Nx					;Test next char
	.else
		.if !ah
			or		cl,cl
			je		@f
			;Whole word
			movzx	eax,al
			add		eax,lpCharTab
			mov		al,[eax]
			dec		al
			je		Nx				;Not found yet
			lea		eax,[edi-1]
			.if sdword ptr eax>=hMem
				movzx	eax,byte ptr [eax]
				add		eax,lpCharTab
				mov		al,[eax]
				dec		al
				je		Nx			;Not found yet
			.endif
		  @@:
			mov		eax,edi			;Found, return pos in eax
		.else
			xor		eax,eax			;Not found
		.endif
	.endif
	ret

SearchMemDown endp

SearchMemUp proc uses ebx ecx edx esi edi,hMem:DWORD,lpFind:DWORD,fMCase:DWORD,fWWord:DWORD,lpCharTab:DWORD

	mov		cl,byte ptr fWWord
	mov		ch,byte ptr fMCase
	mov		edi,hMem
	.while byte ptr [edi]
		inc		edi
	.endw
	mov		esi,lpFind
  Nx:
	xor		edx,edx
	dec		edi
	dec		edx
	.if edi<hMem
		; Not found
		xor		eax,eax
		ret
	.endif
  Mr:
	inc		edx
	mov		al,[edi+edx]
	mov		ah,[esi+edx]
	.if ah && al
		cmp		al,ah
		je		Mr
		.if !ch
			;Try other case (upper/lower)
			movzx	ebx,ah
			add		ebx,lpCharTab
			cmp		al,[ebx+256]
			je		Mr
		.endif
		jmp		Nx					;Test next char
	.else
		.if !ah
			or		cl,cl
			je		@f				;Found
			;Whole word
			movzx	eax,al
			add		eax,lpCharTab
			mov		al,[eax]
			dec		al
			je		Nx				;Not found yet
			lea		eax,[edi-1]
			.if eax>=hMem
				movzx	eax,byte ptr [eax]
				add		eax,lpCharTab
				mov		al,[eax]
				dec		al
				je		Nx			;Not found yet
			.endif
		  @@:
			mov		eax,edi			;Found, return pos in eax
		.else
			xor		eax,eax			;Not found
		.endif
	.endif
	ret

SearchMemUp endp

DestroyToEol proc lpMem:DWORD

	mov		eax,lpMem
	.while byte ptr [eax]!=0 && byte ptr [eax]!=0Dh
		mov		byte ptr [eax],20h
		inc		eax
	.endw
	ret

DestroyToEol endp

DestroyToEof proc lpMem:DWORD

	mov		eax,lpMem
	.while byte ptr [eax]
		.if byte ptr [eax]!=0Dh && byte ptr [eax]!=0Ah
			mov		byte ptr [eax],20h
		.endif
		inc		eax
	.endw
	ret

DestroyToEof endp

Compare proc uses esi,lpWord1:DWORD,lpWord2:DWORD,len:DWORD

	mov		esi,lpWord1
	mov		edx,lpWord2
	mov		ecx,len
	.while ecx
		dec		ecx
		mov		al,[esi+ecx]
		mov		ah,[edx+ecx]
		.if al>='A' && al<='Z'
			or		al,20h
		.endif
		.if ah>='A' && ah<='Z'
			or		ah,20h
		.endif
		sub		al,ah
		.break .if !ZERO?
	.endw
	mov		ecx,len
	movsx	eax,al
	ret

Compare endp

PrintWord proc lpWord,len
	
	pushad
	mov		edx,lpWord
	mov		ecx,len
	mov		al,[edx+ecx]
	mov		byte ptr [edx+ecx],0
	PrintStringByAddr edx
	mov		[edx+ecx],al
	popad
	ret

PrintWord endp

