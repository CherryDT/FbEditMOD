
WRDMEM		equ	256*1024

PROPERTIES	struct
	nSize			dd ?
	nOwner			dd ?
	nLine			dd ?
	nEnd			dd ?
	nType			db ?
PROPERTIES ends

.code

ClearWordList proc

	.if [ebx].RAPROPERTY.cbsize
		invoke RtlZeroMemory,[ebx].RAPROPERTY.lpmem,[ebx].RAPROPERTY.cbsize
	.endif
	xor		eax,eax
	mov		[ebx].RAPROPERTY.rpfree,eax
	mov		[ebx].RAPROPERTY.rpproject,eax
	ret

ClearWordList endp

AddWordToWordList proc uses	esi	edi,nType:DWORD,nOwner:DWORD,nLine:DWORD,nEnd:DWORD,lpszStr:DWORD,nParts:DWORD

	mov		eax,[ebx].RAPROPERTY.rpfree
	add		eax,16384
	mov		edi,[ebx].RAPROPERTY.cbsize
	.if	eax>edi
		add		edi,WRDMEM
		invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,edi
		push	eax
		invoke GlobalLock,eax
		push	eax
		.if [ebx].RAPROPERTY.cbsize
			push	edi
			mov		esi,[ebx].RAPROPERTY.lpmem
			mov		edi,eax
			mov		ecx,[ebx].RAPROPERTY.cbsize
			shr		ecx,2
			rep movsd
			pop		edi
			invoke GlobalUnlock,[ebx].RAPROPERTY.hmem
			invoke GlobalFree,[ebx].RAPROPERTY.hmem
		.endif
		pop		eax
		mov		[ebx].RAPROPERTY.lpmem,eax
		pop		eax
		mov		[ebx].RAPROPERTY.hmem,eax
		mov		[ebx].RAPROPERTY.cbsize,edi
	.endif
	mov		edi,[ebx].RAPROPERTY.lpmem
	add		edi,[ebx].RAPROPERTY.rpfree
	xor		ecx,ecx
	mov		esi,lpszStr
	.if	esi
		mov		edx,nParts
		.while edx
			mov		al,[esi]
			.if al==1
				xor		al,al
				mov		[edi+ecx+sizeof	PROPERTIES],al
				;inc		esi
				inc		ecx
			.elseif	al==0Dh || al==0Ah
				dec		esi
				xor		al,al
			.endif
			mov		[edi+ecx+sizeof	PROPERTIES],al
			inc		esi
			inc		ecx
			.if	!al
				dec		edx
			.endif
		.endw
		mov		eax,nOwner
		mov		[edi].PROPERTIES.nOwner,eax
		mov		eax,nLine
		mov		[edi].PROPERTIES.nLine,eax
		mov		eax,nEnd
		mov		[edi].PROPERTIES.nEnd,eax
		mov		eax,nType
		mov		[edi].PROPERTIES.nType,al
		mov		[edi].PROPERTIES.nSize,ecx
		lea		edi,[edi+ecx+sizeof	PROPERTIES]
		mov		[edi].PROPERTIES.nSize,0
		sub		edi,[ebx].RAPROPERTY.lpmem
		mov		[ebx].RAPROPERTY.rpfree,edi
	.endif
	sub		esi,lpszStr
	mov		eax,esi
	ret

AddWordToWordList endp

AddFileToWordList proc uses	esi,nType:DWORD,lpFileName:DWORD,nParts:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hList:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if	eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,addr nBytes
		mov		nBytes,eax
		shr		eax,12
		inc		eax
		shl		eax,12
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hList,eax
		invoke ReadFile,hFile,hList,nBytes,addr	nBytes,FALSE
		invoke CloseHandle,hFile
		mov		esi,hList
		mov		al,[esi]
		or		al,al
		je		Ex
		invoke strcat,esi,addr szCRLF
		dec		esi
	  Nx:
		inc		esi
		mov		al,[esi]
		.if al==';'
			.while al!=0Ah && al
				inc		esi
				mov		al,[esi]
			.endw
		.endif
		cmp		al,0Dh
		je		Nx
		cmp		al,0Ah
		je		Nx
		.if	al
			.if !nType
				movzx	eax,byte ptr [esi]
				mov		nType,eax
				movzx	eax,byte ptr [esi+1]
				and		eax,0Fh
				mov		nParts,eax
				inc		esi
				jmp		Nx
			.endif
			.if	nParts>1
				call	ZeroTerminateParts
			.endif
			invoke AddWordToWordList,nType,0,0,0,esi,nParts
			add		esi,eax
			or		eax,eax
			jne		Nx
		.endif
	  Ex:
		mov		eax,[ebx].RAPROPERTY.rpfree
		mov		[ebx].RAPROPERTY.rpproject,eax
		invoke GlobalFree,hList
		xor		eax,eax
	.else
		xor		eax,eax
		dec		eax
	.endif
	ret

ZeroTerminateParts:
	push	esi
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,0Dh
	je		@f
	cmp		al,0Ah
	je		@f
	.if al=='|'
		mov		byte ptr [esi],1
		inc		esi
		jmp		@f
	.endif
	.if al=='('
		mov		al,','
	.endif
	cmp		al,','
	jne		@b
	xor		al,al
	mov		[esi],al
	inc		esi
  @@:
	.if nParts>2
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		or		al,al
		je		@f
		cmp		al,0Dh
		je		@f
		cmp		al,0Ah
		je		@f
		cmp		al,'|'
		jne		@b
		xor		al,al
		mov		[esi],al
	  @@:
	.endif
	pop		esi
	retn

AddFileToWordList endp

DeleteProperties proc uses esi,nOwner:DWORD

	mov		esi,[ebx].RAPROPERTY.lpmem
	.if esi
		add		esi,[ebx].RAPROPERTY.rpproject
		mov		edx,nOwner
		.while [esi].PROPERTIES.nSize
			.if edx==[esi].PROPERTIES.nOwner || edx==0
				mov		[esi].PROPERTIES.nType,255
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
	ret

DeleteProperties endp

CompactProperties proc uses esi edi,fProject:DWORD

	mov		esi,[ebx].RAPROPERTY.lpmem
	.if esi
		.if fProject
			add		esi,[ebx].RAPROPERTY.rpproject
			mov		edx,[ebx].RAPROPERTY.rpfree
			mov		edi,esi
			call	CompactIt
			mov		[edi].PROPERTIES.nSize,0
			sub		edi,[ebx].RAPROPERTY.lpmem
			mov		[ebx].RAPROPERTY.rpfree,edi
		.else
			mov		edx,[ebx].RAPROPERTY.rpproject
			mov		edi,esi
			call	CompactIt
			mov		eax,edi
			sub		eax,[ebx].RAPROPERTY.lpmem
			mov		[ebx].RAPROPERTY.rpproject,eax
			mov		edx,[ebx].RAPROPERTY.rpfree
			call	CompactIt
			mov		[edi].PROPERTIES.nSize,0
			sub		edi,[ebx].RAPROPERTY.lpmem
			mov		[ebx].RAPROPERTY.rpfree,edi
		.endif
	.endif
	ret

CompactIt:
	add		edx,[ebx].RAPROPERTY.lpmem
	.while esi<edx
		.if [esi].PROPERTIES.nType==255
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.elseif esi!=edi
			mov		ecx,[esi].PROPERTIES.nSize
			lea		ecx,[ecx+sizeof PROPERTIES]
			rep movsb
		.else
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
			mov		edi,esi
		.endif
	.endw
	retn

CompactProperties endp
