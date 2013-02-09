
.code

BinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
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
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

DecToBin proc lpStr:DWORD
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

DecToBin endp

GetStrItem proc	lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
  @@:
	mov		al,[esi]
	cmp		al,','
	jz		@f
	or		al,al
	jz		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	or		al,al
	jz		@f
	inc		esi
	mov		al,0
  @@:
	mov		[edi],al
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

GetStrItem endp

PutIntItem proc uses edi,Value:DWORD,lpDest:DWORD,fComma:DWORD

	mov		edi,lpDest
	invoke lstrlen,edi
	lea		edi,[edi+eax]
	invoke BinToDec,Value,edi
	.if fComma
		invoke lstrlen,edi
		mov		word ptr [edi+eax],','
	.endif
	ret

PutIntItem endp

iniInStr proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
iniInStr0:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		iniInStr0
	mov		edi,lpStr
	dec		edi
iniInStr1:
	inc		edi
	push	edi
	lea		esi,buffer
iniInStr2:
	mov		ah,[esi]
	or		ah,ah
	je		iniInStr8;Found
	mov		al,[edi]
	or		al,al
	je		iniInStr9;Not found
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		iniInStr2
	pop		edi
	jmp		iniInStr1
iniInStr8:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
iniInStr9:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

iniInStr endp

FixPath proc lpStr:DWORD,lpPth:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
  FixPath1:
	invoke iniInStr,lpStr,lpSrc
	.if eax!=-1
		push	eax
		invoke lstrcpy,addr buffer,lpStr
		lea		esi,buffer
		mov		edi,lpStr
		pop		eax
		.if eax!=0
		  @@:
			movsb
			dec		eax
			jne		@b
		.endif
		invoke lstrlen,lpSrc
		add		esi,eax
		push	esi
		mov		esi,lpPth
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		dec		edi
		pop		esi
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		jmp		FixPath1
	.endif
	popad
	ret

FixPath endp

RemovePath proc	uses ebx esi edi,lpFileName:DWORD,lpPath:DWORD,lpOut:DWORD

	mov		esi,lpFileName
	mov		ebx,lpPath
	mov		edi,lpOut
	or		ecx,-1
	xor		edx,edx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[ebx+ecx]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	.if al=='\' && ah=='\'
		mov		edx,ecx
	.endif
	cmp		al,ah
	je		@b
	.if al=='\' && ah==0
		invoke lstrcpy,edi,addr [esi+ecx+1]
	.else
		push	edx
		.while byte ptr [ebx+edx]
			.if byte ptr [ebx+edx]=='\'
				mov		dword ptr [edi],'\..'
				lea		edi,[edi+3]
			.endif
			inc		edx
		.endw
		pop		ecx
		invoke lstrcpy,edi,addr [esi+ecx+1]
	.endif
	ret

RemovePath endp

