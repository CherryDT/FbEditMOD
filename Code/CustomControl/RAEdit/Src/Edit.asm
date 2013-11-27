
.code

InsertNewLine proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,nSize:DWORD

	mov		ebx,hMem
	mov		eax,nSize
;	shl		eax,1
	invoke ExpandCharMem,ebx,eax
	invoke ExpandLineMem,ebx
	mov		eax,nLine
	shl		eax,2
	mov		esi,[ebx].EDIT.hLine
	add		esi,eax
	.if eax<[ebx].EDIT.rpLineFree
		push	esi
		mov		edi,[ebx].EDIT.rpLineFree
		add		edi,[ebx].EDIT.hLine
		mov		ecx,edi
		sub		ecx,esi
		mov		esi,edi
		sub		esi,sizeof LINE
		shr		ecx,2
		std
		rep movsd
		cld
		pop		esi
	.endif
	add		[ebx].EDIT.rpLineFree,sizeof LINE
	mov		eax,[ebx].EDIT.rpCharsFree
	mov		[esi].LINE.rpChars,eax
	sub		esi,[ebx].EDIT.hLine
	mov		[ebx].EDIT.rpLine,esi
	mov		esi,eax
	add		esi,[ebx].EDIT.hChars
	mov		eax,nSize
	shr		eax,8
	shl		eax,8
	add		eax,MAXFREE
	mov		[esi].CHARS.max,eax
	add		eax,sizeof CHARS
	add		[ebx].EDIT.rpCharsFree,eax
	mov		[esi].CHARS.len,0
	mov		[esi].CHARS.state,STATE_CHANGED
	sub		esi,[ebx].EDIT.hChars
	mov		[ebx].EDIT.rpChars,esi
	ret

InsertNewLine endp

AddNewLine proc uses ebx esi edi,hMem:DWORD,lpLine:DWORD,nSize:DWORD

	mov		ebx,hMem
	invoke ExpandLineMem,ebx
	invoke ExpandCharMem,ebx,nSize
	mov		edx,[ebx].EDIT.rpCharsFree
	mov		esi,[ebx].EDIT.hLine
	mov		eax,[ebx].EDIT.rpLineFree
	lea		esi,[esi+eax-sizeof LINE]
	mov		eax,[esi].LINE.rpChars
	mov		[esi+sizeof LINE].LINE.rpChars,eax
	add		[ebx].EDIT.rpLineFree,sizeof LINE
	mov		[esi].LINE.rpChars,edx
	mov		edi,[ebx].EDIT.hChars
	add		edi,edx
	mov		eax,nSize
	mov		[edi].CHARS.len,eax
	mov		[edi].CHARS.max,eax
	mov		[edi].CHARS.state,0
	mov		[edi].CHARS.bmid,0
	mov		[edi].CHARS.errid,0
	add		eax,sizeof CHARS
	add		[ebx].EDIT.rpCharsFree,eax
	mov		ecx,nSize
	mov		esi,lpLine
	lea		edi,[edi+sizeof CHARS]
	rep movsb
	ret

AddNewLine endp

ExpandCharLine proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.rpChars
	mov		eax,esi
	add		esi,[ebx].EDIT.hChars
	add		eax,[esi].CHARS.max
	add		eax,sizeof CHARS
	.if eax==[ebx].EDIT.rpCharsFree
		;Is at end of chars, just expand
		add		[esi].CHARS.max,MAXFREE
		add		[ebx].EDIT.rpCharsFree,MAXFREE
		mov		eax,[ebx].EDIT.rpCharsFree
	.else
		;Move the line to end of buffer
		mov		eax,[esi].CHARS.max
		add		eax,MAXFREE+sizeof CHARS
		invoke ExpandCharMem,ebx,eax
		mov		esi,[ebx].EDIT.rpChars
		add		esi,[ebx].EDIT.hChars
		mov		edi,[ebx].EDIT.rpCharsFree
		add		edi,[ebx].EDIT.hChars
		mov		ecx,[esi].CHARS.max
		add		ecx,sizeof CHARS
		add		[ebx].EDIT.rpCharsFree,ecx
		mov		edx,[ebx].EDIT.rpLine
		add		edx,[ebx].EDIT.hLine
		mov		eax,edi
		sub		eax,[ebx].EDIT.hChars
		mov		[edx].LINE.rpChars,eax
		mov		[ebx].EDIT.rpChars,eax
		push	esi
		push	edi
		rep movsb
		pop		edi
		pop		esi
		add		[edi].CHARS.max,MAXFREE
		add		[ebx].EDIT.rpCharsFree,MAXFREE
		or		[esi].CHARS.state,STATE_GARBAGE
	.endif
	ret

ExpandCharLine endp

DeleteLine proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hLine
	xor		edi,edi
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		mov		edi,[ebx].EDIT.hChars
		mov		edx,[esi+eax+sizeof LINE]
		mov		[ebx].EDIT.rpChars,edx
		add		edi,[esi+eax]
		test	[edi].CHARS.state,STATE_HIDDEN
		.if !ZERO?
			dec		[ebx].EDIT.nHidden
		.endif
		or		[edi].CHARS.state,STATE_GARBAGE
		.while eax<[ebx].EDIT.rpLineFree
			mov		ecx,[esi+eax+sizeof LINE]
			mov		[esi+eax],ecx
			add		eax,sizeof LINE
		.endw
		sub		[ebx].EDIT.rpLineFree,sizeof LINE
	.endif
	mov		eax,edi
	ret

DeleteLine endp

InsertChar proc uses ebx esi edi,hMem:DWORD,cp:DWORD,nChr:DWORD

	mov		ebx,hMem
	invoke ExpandLineMem,ebx
	invoke ExpandCharMem,ebx,MAXCHARMEM
	mov		edx,cp
	xor		eax,eax
	.if edx<[ebx].EDIT.edta.topcp
		mov		[ebx].EDIT.edta.topyp,eax
		mov		[ebx].EDIT.edta.topln,eax
		mov		[ebx].EDIT.edta.topcp,eax
	.endif
	.if edx<[ebx].EDIT.edtb.topcp
		mov		[ebx].EDIT.edtb.topyp,eax
		mov		[ebx].EDIT.edtb.topln,eax
		mov		[ebx].EDIT.edtb.topcp,eax
	.endif
	invoke GetCharPtr,ebx,edx
	mov		edi,eax
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		ecx,[esi].CHARS.state
	test	ecx,STATE_HIDDEN
	.if !ZERO?
		pushad
		invoke TestExpand,ebx,[ebx].EDIT.line
		popad
	.else
		and		ecx,STATE_BMMASK
		.if (ecx==STATE_BM2 || ecx==STATE_BM8) && nChr==VK_RETURN
			pushad
			invoke Expand,ebx,[ebx].EDIT.line
			popad
		.endif
	.endif
	mov		ecx,nChr
	.if [ebx].EDIT.fOvr && ecx!=0Dh
		.if edi<[esi].CHARS.len
			movzx	eax,byte ptr [esi+edi+sizeof CHARS]
			.if al!=0Dh
				;Replace char
				and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
				or		[esi].CHARS.state,STATE_CHANGED
				mov		[esi+edi+sizeof CHARS],cl
				jmp		Ex
			.endif
		.endif
	.endif
	mov		eax,[esi].CHARS.max
	mov		eax,[esi].CHARS.len
	.if eax==[esi].CHARS.max
		invoke ExpandCharLine,ebx
	.endif
	;Insert char
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	push	esi
	push	edi
	mov		ecx,[esi].CHARS.len
	sub		ecx,edi
	.if ecx
		lea		esi,[esi+ecx+sizeof CHARS-1]
		lea		esi,[esi+edi]
		lea		edi,[esi+1]
		std
		rep movsb
		cld
	.endif
	pop		edi
	pop		esi
	mov		ecx,nChr
	mov		[esi+edi+sizeof CHARS],cl
	inc		[esi].CHARS.len
	mov		ecx,nChr
	.if ecx==0Dh
		; Break the line
		mov		eax,[ebx].EDIT.rpLine
		shr		eax,2
		mov		ecx,[esi].CHARS.state
		and		ecx,STATE_BMMASK
		.if ecx==STATE_BM2 || ecx==STATE_BM8
			pushad
			invoke TestExpand,ebx,eax
			popad
		.endif
		; Save line number
		push	eax
		inc		eax
		inc		edi
		mov		ecx,MAXFREE
		add		ecx,[esi].CHARS.len
		sub		ecx,edi
		; Insert a new line and expand the CHAR mem
		invoke InsertNewLine,ebx,eax,ecx
		; Find the pointer to old line characters
		pop		esi
		shl		esi,2
		add		esi,[ebx].EDIT.hLine
		mov		esi,[esi]
		add		esi,[ebx].EDIT.hChars
		mov		ecx,edi
		xor		edx,edx
		mov		edi,[ebx].EDIT.rpChars
		add		edi,[ebx].EDIT.hChars
		.while ecx<[esi].CHARS.len
			mov		al,[esi+ecx+sizeof CHARS]
			mov		[edi+edx+sizeof CHARS],al
			inc		ecx
			inc		edx
		.endw
		; Update lenght of old and new line
		mov		[edi].CHARS.len,edx
		sub		[esi].CHARS.len,edx
		mov		eax,[esi].CHARS.len
		add		[ebx].EDIT.cpLine,eax
		inc		[ebx].EDIT.line
		.if edx>1
			and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
			or		[esi].CHARS.state,STATE_CHANGED
		.endif
		and		[edi].CHARS.state,-1 xor STATE_CHANGESAVED
		or		[edi].CHARS.state,STATE_CHANGED
	.else
		and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
		or		[esi].CHARS.state,STATE_CHANGED
	.endif
	xor		eax,eax
  Ex:
	.if ![ebx].EDIT.fChanged
		mov		[ebx].EDIT.fChanged,TRUE
		pushad
		invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		popad
	.endif
	inc		[ebx].EDIT.nchange
	ret

InsertChar endp

DeleteChar proc uses ebx esi edi,hMem:DWORD,cp:DWORD
	mov		ebx,hMem
	mov		edx,cp
	xor		eax,eax
	.if edx<[ebx].EDIT.edta.topcp
		mov		[ebx].EDIT.edta.topyp,eax
		mov		[ebx].EDIT.edta.topln,eax
		mov		[ebx].EDIT.edta.topcp,eax
	.endif
	.if edx<[ebx].EDIT.edtb.topcp
		mov		[ebx].EDIT.edtb.topyp,eax
		mov		[ebx].EDIT.edtb.topln,eax
		mov		[ebx].EDIT.edtb.topcp,eax
	.endif
	invoke GetCharPtr,ebx,edx
	mov		edi,eax
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	test	[esi].CHARS.state,STATE_HIDDEN
	.if !ZERO?
		invoke TestExpand,ebx,[ebx].EDIT.line
	.endif
	movzx	eax,byte ptr [esi+edi+sizeof CHARS]
	push	eax
	.if al==0Dh
		mov		edi,esi
		.if [esi].CHARS.len==1
			invoke DeleteLine,ebx,[ebx].EDIT.line
		.else
			push	[ebx].EDIT.fOvr
			mov		[ebx].EDIT.fOvr,FALSE
			mov		eax,cp
			inc		eax
			invoke GetCharPtr,ebx,eax
			mov		esi,[ebx].EDIT.rpChars
			add		esi,[ebx].EDIT.hChars
			.if [esi].CHARS.len
				invoke DeleteLine,ebx,[ebx].EDIT.line
				.if eax
					mov		esi,eax
					mov		eax,[esi].CHARS.len
					add		eax,sizeof CHARS
					push	eax
					invoke GlobalAlloc,GMEM_FIXED,eax
					mov		edi,eax
					pop		ecx
					push	edi
					rep		movsb
					pop		esi
					xor		edi,edi
					.while edi<[esi].CHARS.len
						movzx	eax,byte ptr [esi+edi+sizeof CHARS]
						.break .if eax==VK_RETURN
						invoke InsertChar,ebx,cp,eax
						inc		edi
						inc		cp
						xor		eax,eax
					.endw
					push	eax
					invoke GlobalFree,esi
					mov		esi,[ebx].EDIT.line
					shl		esi,2
					add		esi,[ebx].EDIT.hLine
					mov		esi,[esi].LINE.rpChars
					add		esi,[ebx].EDIT.hChars
					pop		eax
					.if !eax
						dec		[esi].CHARS.len
					.endif
				.endif
			.else
				dec		[edi].CHARS.len
				invoke DeleteLine,ebx,[ebx].EDIT.line
				invoke GetCharPtr,ebx,0
				mov		esi,edi
			.endif
			and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
			or		[esi].CHARS.state,STATE_CHANGED
			pop		[ebx].EDIT.fOvr
		.endif
		.if ![ebx].EDIT.fChanged
			mov		[ebx].EDIT.fChanged,TRUE
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		.endif
		inc		[ebx].EDIT.nchange
	.elseif al && [esi].CHARS.len
		dec		[esi].CHARS.len
		.if !ZERO?
			.while edi<[esi].CHARS.len
				mov		al,[esi+edi+sizeof CHARS+1]
				mov		[esi+edi+sizeof CHARS],al
				inc		edi
			.endw
			mov		byte ptr [esi+edi+sizeof CHARS],0
		.endif
		and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
		or		[esi].CHARS.state,STATE_CHANGED
		.if ![ebx].EDIT.fChanged
			mov		[ebx].EDIT.fChanged,TRUE
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		.endif
		inc		[ebx].EDIT.nchange
	.endif
	pop		eax
	ret

DeleteChar endp

DeleteSelection proc uses ebx edi,hMem:DWORD,cpMin:DWORD,cpMax:DWORD

	mov		ebx,hMem
	mov		eax,cpMin
	.if eax>cpMax
		xchg	cpMax,eax
		mov		cpMin,eax
	.endif
	push	eax
	invoke GetLineFromCp,ebx,cpMin
	mov		edi,eax
	invoke GetLineFromCp,ebx,cpMax
	.while edi<eax
		push	eax
		invoke TestExpand,ebx,edi
		pop		eax
		inc		edi
	.endw
	pop		eax
	.if eax!=cpMax
		invoke GetCursor
		push	eax
		invoke ShowCursor, FALSE                ; *** MOD
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke ShowCursor, TRUE
		mov		eax,cpMax
		sub		eax,cpMin
		push	eax
		invoke xGlobalAlloc,GMEM_FIXED,eax
		mov		edi,eax
		push	edi
		mov		eax,cpMin
		.while eax!=cpMax
			invoke DeleteChar,hMem,eax
			mov		[edi],al
			inc		edi
			dec		cpMax
			mov		eax,cpMin
		.endw
		pop		edi
		pop		eax
		invoke SaveUndo,ebx,UNDO_DELETEBLOCK,cpMin,edi,eax
		invoke GlobalFree,edi
		invoke ShowCursor, FALSE                ; *** MOD
		pop		eax
		invoke SetCursor,eax
		invoke ShowCursor, TRUE
		mov		eax,cpMin
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
	.endif
	ret

DeleteSelection endp

DeleteSelectionBlock proc uses ebx esi edi,hMem:DWORD,lnMin:DWORD,clMin:DWORD,lnMax:DWORD,clMax:DWORD

	mov		ebx,hMem
	mov		eax,clMin
	mov		edx,clMax
	.if eax!=edx
		.if eax>edx
			mov		clMax,eax
			mov		clMin,edx
		.endif
		mov		eax,lnMin
		mov		edx,lnMax
		.if eax>edx
			mov		lnMax,eax
			mov		lnMin,edx
		.endif
		mov		eax,lnMin
		.while eax<=lnMax
			invoke GetBlockCp,ebx,lnMin,clMin
			mov		esi,eax
			invoke GetChar,ebx,esi
			.if eax && eax!=VK_RETURN
				invoke GetBlockCp,ebx,lnMin,clMax
				mov		edi,eax
			  @@:
				.if sdword ptr edi>esi
					dec		edi
					invoke GetChar,ebx,edi
					.if !eax || eax==VK_RETURN
						jmp		@b
					.endif
					inc		edi
					invoke DeleteSelection,ebx,esi,edi
				.endif
			.endif
			inc		lnMin
			mov		eax,lnMin
		.endw
	.endif
	ret

DeleteSelectionBlock endp

EditInsert proc uses ebx esi edi,hMem:DWORD,cp:DWORD,lpBuff:DWORD

	mov		ebx,hMem
	mov		esi,lpBuff
	mov		edi,cp
	.if esi
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		mov		al,[esi]
		.while al
			.if al!=0Ah
				movzx	eax,al
				invoke InsertChar,ebx,edi,eax
				inc		edi
			.endif
			inc		esi
			mov		al,[esi]
		.endw
		pop		eax
		invoke SetCursor,eax
	.endif
	mov		eax,edi
	sub		eax,cp
	ret

EditInsert endp

