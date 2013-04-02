
.code

xInString proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
InStr0:
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
	jne		InStr0
	mov		edi,lpStr
	dec		edi
InStr1:
	inc		edi
	push	edi
	lea		esi,buffer
InStr2:
	mov		ah,[esi]
	or		ah,ah
	je		Found
	mov		al,[edi]
	or		al,al
	je		NotFound
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		InStr2
	pop		edi
	jmp		InStr1
Found:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
NotFound:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

xInString endp

FindFileExt proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,lpszFile:DWORD
	LOCAL	buffer[64]:BYTE

	mov		esi,lpszFile
	invoke lstrlen,esi
	.while eax
		dec		eax
	  .break .if byte ptr [esi+eax]=='.'
	.endw
	.if	eax
		invoke lstrcpyn,addr buffer,addr [esi+eax],sizeof buffer
		invoke lstrlen,addr buffer
		mov		word ptr buffer[eax],'.'
		mov		ebx,lpPROJECTBROWSER
		mov		edi,[ebx].PROJECTBROWSER.hmemfileext
		.while [edi].PBFILEEXT.id
			invoke xInString,addr [edi].PBFILEEXT.szfileext,addr buffer
			.if eax!=-1
				mov		eax,[edi].PBFILEEXT.id
				jmp		Ex
			.endif
			lea		edi,[edi+sizeof PBFILEEXT]
		.endw
	.endif
	mov		eax,5
  Ex:
	ret

FindFileExt endp

RemoveThePath proc	uses esi edi,lpszFileName:DWORD,lpPath:DWORD,lpBuff:DWORD

	add		lpBuff,21
	invoke lstrcpy,lpBuff,lpszFileName
	mov		edi,lpBuff
	mov		esi,lpPath
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[edi]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		@b
	.if	al
	  @@:
		dec		esi
		dec		edi
		mov		al,[esi]
		cmp		al,'\'
		jne		@b
		inc		esi
		inc		edi
	.endif
  @@:
	mov		al,[esi]
	inc		esi
	.if	al=='\'
		dec		edi
		mov		[edi],al
		dec		edi
		dec		edi
		mov		word ptr [edi],'..'
		jmp		@b
	.elseif	al
		jmp		@b
	.endif
	lea		eax,[edi+1]
	ret

RemoveThePath endp

CombSort PROC uses ebx esi edi,lpArr:DWORD,count:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	mov		eax,count
	mov		Gap,eax
	mov		ebx,lpArr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	;Get offsets to row data
	push	edx
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get cell data
	push	ecx
	invoke lstrcmpi,edi,edx
	pop		ecx
	pop		edx
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSort ENDP

SortItems proc uses ebx esi edi,lpPROJECTBROWSER:DWORD
	LOCAL	hMemItems:HGLOBAL
	LOCAL	hMemSort:HGLOBAL
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	nCount:DWORD
	LOCAL	hMemItemsSorted:HGLOBAL

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXITEMMEM
	mov		hMemItems,eax
	mov		edi,eax
	mov		nCount,0
	.while [esi].PBITEM.id
		.if sdword ptr [esi].PBITEM.id>0
			;File
			.if [ebx].PROJECTBROWSER.style & RPBS_NOPATH
				invoke lstrlen,addr [esi].PBITEM.szitem
				.while [esi].PBITEM.szitem[eax-1]!='\' && eax
					dec		eax
				.endw
				lea		eax,[esi].PBITEM.szitem[eax]
			.else
				invoke RemoveThePath,addr [esi].PBITEM.szitem,addr [ebx].PROJECTBROWSER.projectpath,addr buffer
			.endif
			invoke lstrcpy,addr [edi].SORT.szname,eax
			mov		[edi].SORT.lpPBITEM,esi
			inc		nCount
			lea		edi,[edi+sizeof SORT]
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	mov		eax,nCount
	.if eax>1
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,addr [eax*4]
		mov		hMemSort,eax
		mov		esi,hMemItems
		mov		edi,hMemSort
		.while [esi].SORT.lpPBITEM
			mov		[edi],esi
			lea		edi,[edi+4]
			lea		esi,[esi+sizeof SORT]
		.endw
		invoke CombSort,hMemSort,nCount
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXITEMMEM
		mov		hMemItemsSorted,eax
		mov		edi,eax
		;Add groups
		mov		esi,[ebx].PROJECTBROWSER.hmemitems
		.while [esi].PBITEM.id
			mov		[edi].SORT.lpPBITEM,esi
			.if sdword ptr [esi].PBITEM.id<0
				;Group
				invoke RtlMoveMemory,edi,esi,sizeof PBITEM
				lea		edi,[edi+sizeof PBITEM]
			.endif
			lea		esi,[esi+sizeof PBITEM]
		.endw
		mov		esi,hMemSort
		.while dword ptr [esi]
			mov		edx,[esi]
			mov		edx,[edx].SORT.lpPBITEM
			invoke RtlMoveMemory,edi,edx,sizeof PBITEM
			lea		edi,[edi+sizeof PBITEM]
			lea		esi,[esi+4]
		.endw
		invoke GlobalFree,[ebx].PROJECTBROWSER.hmemitems
		mov		eax,hMemItemsSorted
		mov		[ebx].PROJECTBROWSER.hmemitems,eax
		invoke GlobalFree,hMemSort
	.endif
	invoke GlobalFree,hMemItems
	ret

SortItems endp

