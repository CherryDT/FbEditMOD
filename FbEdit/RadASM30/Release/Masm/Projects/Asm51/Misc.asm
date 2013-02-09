.code

strlen proc uses esi,lpSource:DWORD

	xor		eax,eax
	dec		eax
	mov		esi,lpSource
  @@:
	inc		eax
	cmp		byte ptr [esi+eax],0
	jne		@b
	ret

strlen endp

strcmp proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmp endp

strcmpi proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
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

strcmpi endp

BinToDec proc uses ebx ecx edx esi edi,dwVal:DWORD,lpAscii:DWORD

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

BinToDec endp

ReadAsmFile proc uses esi,lpFile:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,addr nBytes
		push	eax
		shr		eax,12
		inc		eax
		shl		eax,12
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		esi,eax
		pop		edx
		invoke ReadFile,hFile,esi,edx,addr nBytes,NULL
		invoke CloseHandle,hFile
		invoke strlen,esi
		.if byte ptr [esi+eax-1]==1Ah
			dec		eax
		.endif
		mov		word ptr [esi+eax],0A0Dh
		mov		eax,esi
	.else
		xor		eax,eax
	.endif
	ret

ReadAsmFile endp

PrintLineNumber proc nLine:DWORD
	LOCAL	buffer[64]:BYTE

	invoke strlen,addr InpFile
	invoke WriteFile,hOut,addr InpFile,eax,offset dwTemp,NULL
	mov		dword ptr buffer,'('
	invoke BinToDec,nLine,addr buffer[1]
	invoke strlen,addr buffer
	mov		dword ptr buffer[eax],' )'
	inc		eax
	inc		eax
	invoke WriteFile,hOut,addr buffer,eax,offset dwTemp,NULL
	invoke strlen,addr szError
	invoke WriteFile,hOut,addr szError,eax,offset dwTemp,NULL
	ret

PrintLineNumber endp

PrintStringz proc lpText:DWORD

	invoke strlen,lpText
	invoke WriteFile,hOut,lpText,eax,offset dwTemp,NULL
	ret

PrintStringz endp


