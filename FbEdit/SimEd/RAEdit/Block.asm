
.code

GetBlock proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,lpBlockDef:DWORD
	LOCAL	nLines:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nNest:DWORD
	LOCAL	flag:DWORD

	mov		ebx,hMem
	mov		nNest,1
	mov		esi,lpBlockDef
	mov		eax,[esi].RABLOCKDEF.flag
	mov		flag,eax
	mov		esi,[esi].RABLOCKDEF.lpszEnd
	.if esi
		mov		edi,nLine
		shl		edi,2
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		xor		ecx,ecx
		call	SkipWhSp
		mov		al,[esi]
		.if al=='$'
			;$ endp
			mov		nNest,0
			lea		edx,buffer
			call	CopyWrd
			mov		byte ptr [edx],' '
			inc		edx
		  @@:
			inc		esi
			mov		al,[esi]
			cmp		al,' '
			je		@b
			invoke lstrcpy,edx,esi
			lea		esi,buffer
			call	TestBlock
		.elseif al=='?'
			;? endp
			mov		nNest,0
			lea		edx,buffer
			call	CopyWrd
			mov		byte ptr [edx],' '
			inc		edx
		  @@:
			inc		esi
			mov		al,[esi]
			cmp		al,' '
			je		@b
			invoke lstrcpy,edx,esi
			push	esi
			lea		esi,buffer
			call	TestBlock
			pop		esi
			.if eax==-1
				call	TestBlock
			.endif
		.else
			push	ecx
			invoke strlen,esi
			pop		ecx
			.if eax
				mov		al,[esi+eax-1]
			.endif
			.if al=='$'
				;endp $
				mov		nNest,0
				lea		edx,buffer
			  @@:
				mov		al,[esi]
				cmp		al,' '
				je		@f
				cmp		al,'$'
				je		@f
				mov		[edx],al
				inc		esi
				inc		edx
				jmp		@b
			  @@:
				mov		byte ptr [edx],' '
				inc		edx
				call	SkipWrd
				call	SkipWhSp
				call	CopyWrd
				lea		esi,buffer
				call	TestBlock
			.else
				;endp
				call TestBlock
			.endif
		.endif
	.else
		mov		nLines,0
		.if flag & BD_SEGMENTBLOCK
			mov		esi,[ebx].EDIT.rpLineFree
			sub		esi,4
			inc		nLine
			.while TRUE
				mov		edi,nLine
				shl		edi,2
				.break .if edi>=esi
				add		edi,[ebx].EDIT.hLine
				mov		edi,[edi].LINE.rpChars
				add		edi,[ebx].EDIT.hChars
				test	[edi].CHARS.state,STATE_SEGMENTBLOCK
				.break .if !ZERO?
				inc		nLine
				inc		nLines
			.endw
		.elseif flag & BD_COMMENTBLOCK
			mov		esi,[ebx].EDIT.rpLineFree
			sub		esi,4
			inc		nLine
			.while TRUE
				mov		edi,nLine
				shl		edi,2
				.break .if edi>=esi
				add		edi,[ebx].EDIT.hLine
				mov		edi,[edi].LINE.rpChars
				add		edi,[ebx].EDIT.hChars
				test	[edi].CHARS.state,STATE_COMMENT
				.break .if ZERO?
				inc		nLine
				inc		nLines
			.endw
		.endif
		mov		eax,nLines
	.endif
	ret

TestBlock:
	mov		nLines,0
	mov		edi,nLine
	.while TRUE
		xor		eax,eax
		dec		eax
		mov		ecx,edi
		shl		ecx,2
		.break .if ecx>[ebx].EDIT.rpLineFree
		.if nNest
			mov		ecx,lpBlockDef
			invoke IsLine,ebx,edi,[ecx].RABLOCKDEF.lpszStart
			.if eax!=-1
				inc		nNest
			.endif
		.endif
		invoke IsLine,ebx,edi,esi
		.if eax!=-1
			cmp		dword ptr nNest,0
			.break .if ZERO?
			dec		nNest
			.break .if ZERO?
			cmp		dword ptr nNest,1
			.break .if ZERO?
		.endif
		inc		edi
		inc		nLines
	.endw
	.if nNest
		dec		nNest
	.endif
	.if nLines
		dec		nLines
	.endif
	.if eax!=-1 && !nNest
		test	flag,BD_INCLUDELAST
		je		@f
		mov		ecx,edi
		inc		ecx
		shl		ecx,2
		cmp		ecx,[ebx].EDIT.rpLineFree
		je		@f
		inc		nLines
	  @@:
		mov		eax,nLines
		test	flag,BD_LOOKAHEAD
		.if !ZERO?
			push	eax
			mov		ecx,edi
			add		ecx,500
			.while edi<ecx
				inc		edi
				mov		eax,edi
				shl		eax,2
				.break .if eax>[ebx].EDIT.rpLineFree
				inc		nLines
				push	ecx
				invoke IsLine,ebx,edi,esi
				.if eax!=-1
					pop		ecx
					pop		eax
					push	nLines
					mov		ecx,edi
					add		ecx,500
					push	ecx
				.endif
				mov		eax,lpBlockDef
				mov		eax,[eax].RABLOCKDEF.lpszStart
				invoke IsLine,ebx,edi,eax
				pop		ecx
				.break .if eax!=-1
			.endw
			pop		eax
		.endif
	.else
		xor		eax,eax
		dec		eax
	.endif
	retn

SkipWhSp:
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,[edi].CHARS.len
	jnc		@f
	mov		al,[edi+ecx+sizeof CHARS]
	cmp		al,VK_TAB
	je		@b
	cmp		al,' '
	je		@b
  @@:
	retn

SkipWrd:
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,[edi].CHARS.len
	jnc		@f
	mov		al,[edi+ecx+sizeof CHARS]
	cmp		al,VK_TAB
	je		@f
	cmp		al,' '
	je		@f
	cmp		al,0Dh
	jne		@b
  @@:
	retn

CopyWrd:
  @@:
	cmp		ecx,[edi].CHARS.len
	jnc		@f
	mov		al,[edi+ecx+sizeof CHARS]
	cmp		al,VK_TAB
	je		@f
	cmp		al,' '
	je		@f
	cmp		al,0Dh
	je		@f
	mov		[edx],al
	inc		ecx
	inc		edx
	jmp		@b
  @@:
	mov		byte ptr [edx],0
	retn

GetBlock endp

SetBlocks proc uses ebx esi edi,hMem:DWORD,lpLnrg:DWORD,lpBlockDef:DWORD
	LOCAL	nLine:DWORD

	mov		ebx,hMem
	mov		nLine,0
	mov		eax,lpLnrg
	.if eax
		mov		eax,[eax].LINERANGE.lnMin
		mov		nLine,eax
		mov		eax,[eax].LINERANGE.lnMax
		inc		eax
		inc		eax
	.endif
	dec		eax
	shl		eax,2
	mov		esi,eax
	.if esi>[ebx].EDIT.rpLineFree
		mov		esi,[ebx].EDIT.rpLineFree
	.endif
	dec		nLine
  @@:
	inc		nLine
	mov		edi,nLine
	shl		edi,2
	.if edi<esi
		invoke IsLine,ebx,nLine,offset szInclude
		inc		eax
		jne		@b
		invoke IsLine,ebx,nLine,offset szIncludelib
		inc		eax
		jne		@b
		mov		eax,lpBlockDef
		mov		eax,[eax].RABLOCKDEF.lpszStart
		invoke IsLine,ebx,nLine,eax
		inc		eax
		je		@b
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		test	[edi].CHARS.state,STATE_NOBLOCK
		.if !ZERO?
			jmp		@b
		.endif
		inc		nBmid
		mov		eax,nBmid
		mov		[edi].CHARS.bmid,eax
		and		[edi].CHARS.state,-1 xor STATE_BMMASK
		or		[edi].CHARS.state,STATE_BM1
		mov		eax,lpBlockDef
		test	[eax].RABLOCKDEF.flag,BD_SEGMENTBLOCK
		.if !ZERO?
			or		[edi].CHARS.state,STATE_SEGMENTBLOCK
		.else
			and		[edi].CHARS.state,-1 xor STATE_SEGMENTBLOCK
		.endif
		test	[eax].RABLOCKDEF.flag,BD_DIVIDERLINE
		.if !ZERO?
			or		[edi].CHARS.state,STATE_DIVIDERLINE
		.else
			and		[edi].CHARS.state,-1 xor STATE_DIVIDERLINE
		.endif
		test	[eax].RABLOCKDEF.flag,BD_NONESTING
		.if !ZERO?
			invoke GetBlock,ebx,nLine,lpBlockDef
			.if eax!=-1
				add		nLine,eax
				jmp		@b
			.endif
		.endif
		mov		eax,lpBlockDef
		test	[eax].RABLOCKDEF.flag,BD_ALTHILITE
		.if !ZERO?
			or		[edi].CHARS.state,STATE_ALTHILITE
		.else
			and		[edi].CHARS.state,-1 xor STATE_ALTHILITE
		.endif
		test	[eax].RABLOCKDEF.flag,BD_NOBLOCK
		.if !ZERO?
			invoke GetBlock,ebx,nLine,lpBlockDef
			.if eax!=-1
				mov		edx,nLine
				add		nLine,eax
				mov		eax,lpBlockDef
				mov		eax,[eax].RABLOCKDEF.flag
				and		eax,BD_ALTHILITE
				.while edx<=nLine
					inc		edx
					mov		edi,edx
					shl		edi,2
					.if edi<esi
						add		edi,[ebx].EDIT.hLine
						mov		edi,[edi].LINE.rpChars
						add		edi,[ebx].EDIT.hChars
						and		[edi].CHARS.state,-1 xor (STATE_BMMASK or STATE_SEGMENTBLOCK or STATE_DIVIDERLINE)
						or		[edi].CHARS.state,STATE_NOBLOCK
						.if eax
							or		[edi].CHARS.state,STATE_ALTHILITE
						.endif
					.endif
				.endw
			.endif
		.else
			mov		eax,lpBlockDef
			test	[eax].RABLOCKDEF.flag,BD_ALTHILITE
			.if !ZERO?
				invoke GetBlock,ebx,nLine,lpBlockDef
				.if eax!=-1
					mov		edx,nLine
					add		nLine,eax
					.while edx<=nLine
						inc		edx
						mov		edi,edx
						shl		edi,2
						.if edi<esi
							add		edi,[ebx].EDIT.hLine
							mov		edi,[edi].LINE.rpChars
							add		edi,[ebx].EDIT.hChars
							or		[edi].CHARS.state,STATE_ALTHILITE
						.endif
					.endw
				.endif
			.endif
		.endif
		jmp		@b
	.endif
	ret

SetBlocks endp

IsBlockDefEqual proc uses esi edi,lpRABLOCKDEF1:DWORD,lpRABLOCKDEF2:DWORD

	mov		esi,lpRABLOCKDEF1
	mov		edi,lpRABLOCKDEF2
	mov		eax,[esi].RABLOCKDEF.flag
	.if eax==[edi].RABLOCKDEF.flag
		mov		eax,[esi].RABLOCKDEF.lpszStart
		mov		edx,[edi].RABLOCKDEF.lpszStart
		.if eax && edx
			invoke lstrcmp,eax,edx
			jne		NotEq
		.elseif (eax && !edx) || (!eax && edx)
			jmp		NotEq
		.endif
		mov		eax,[esi].RABLOCKDEF.lpszEnd
		mov		edx,[edi].RABLOCKDEF.lpszEnd
		.if eax && edx
			invoke lstrcmp,eax,edx
			jne		NotEq
		.elseif (eax && !edx) || (!eax && edx)
			jmp		NotEq
		.endif
		mov		eax,[esi].RABLOCKDEF.lpszNot1
		mov		edx,[edi].RABLOCKDEF.lpszNot1
		.if eax && edx
			invoke lstrcmp,eax,edx
			jne		NotEq
		.elseif (eax && !edx) || (!eax && edx)
			jmp		NotEq
		.endif
		mov		eax,[esi].RABLOCKDEF.lpszNot2
		mov		edx,[edi].RABLOCKDEF.lpszNot2
		.if eax && edx
			invoke lstrcmp,eax,edx
			jne		NotEq
		.elseif (eax && !edx) || (!eax && edx)
			jmp		NotEq
		.endif
	.else
		jmp		NotEq
	.endif
	xor		eax,eax
	inc		eax
	ret
  NotEq:
	xor		eax,eax
	ret

IsBlockDefEqual endp

IsInBlock proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,lpBlockDef:DWORD

	mov		ebx,hMem
	mov		edi,nLine
	mov		esi,lpBlockDef
	mov		esi,[esi].RABLOCKDEF.lpszStart
  @@:
	invoke PreviousBookMark,ebx,edi,1
	mov		edi,eax
	inc		eax
	.if eax
		invoke IsLine,ebx,edi,esi
		inc		eax
		je		@b
		invoke GetBlock,ebx,edi,lpBlockDef
		add		edi,eax
		mov		eax,lpBlockDef
		test	[eax].RABLOCKDEF.flag,BD_INCLUDELAST
		.if ZERO?
			inc		edi
		.endif
		xor		eax,eax
		.if edi>=nLine
			inc		eax
		.endif
	.endif
	ret

IsInBlock endp

TestBlockStart proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		esi,nLine
	shl		esi,2
	.if esi<[ebx].EDIT.rpLineFree
		add		esi,[ebx].EDIT.hLine
		mov		esi,[esi]
		add		esi,[ebx].EDIT.hChars
		test	[esi].CHARS.state,STATE_NOBLOCK
		.if ZERO?
			mov		esi,offset blockdefs
			lea		edi,[esi+32*4]
			.while dword ptr [esi]
				mov		eax,[edi].RABLOCKDEF.flag
				shr		eax,16
				.if eax==[ebx].EDIT.nWordGroup
					invoke IsLine,ebx,nLine,[edi].RABLOCKDEF.lpszStart
					.if eax!=-1
						mov		eax,edi
						jmp		Ex
					.endif
				.endif
				mov		edi,dword ptr [esi]
				add		esi,4
			.endw
		.endif
	.endif
	xor		eax,eax
	dec		eax
  Ex:
	ret

TestBlockStart endp

TestBlockEnd proc uses ebx esi edi,hMem:DWORD,nLine:DWORD
	LOCAL	lpSecond:DWORD

	mov		ebx,hMem
	mov		esi,offset blockdefs
	lea		edi,[esi+32*4]
	.while dword ptr [esi]
		mov		lpSecond,0
		.if [edi].RABLOCKDEF.lpszEnd
			invoke strlen,[edi].RABLOCKDEF.lpszEnd
			mov		edx,[edi].RABLOCKDEF.lpszEnd
			lea		eax,[edx+eax+1]
			.if byte ptr [eax]
				mov		lpSecond,eax
			.endif
		.endif
		mov		eax,[edi].RABLOCKDEF.flag
		shr		eax,16
		.if [edi].RABLOCKDEF.lpszEnd && eax==[ebx].EDIT.nWordGroup
			mov		eax,nLine
			shl		eax,2
			add		eax,[ebx].EDIT.hLine
			mov		eax,[eax].LINE.rpChars
			add		eax,[ebx].EDIT.hChars
			test	[eax].CHARS.state,STATE_ALTHILITE
			.if !ZERO?
				test	[edi].RABLOCKDEF.flag,BD_ALTHILITE
				.if ZERO?
					xor		eax,eax
				.else
					or		eax,1
				.endif
			.else
				or		eax,1
			.endif
			.if eax
				invoke IsLine,ebx,nLine,[edi].RABLOCKDEF.lpszEnd
				.if eax!=-1
					mov		eax,edi
					jmp		Ex
				.elseif lpSecond
					invoke IsLine,ebx,nLine,lpSecond
					.if eax!=-1
						mov		eax,edi
						jmp		Ex
					.endif
				.endif
			.endif
		.endif
		mov		edi,dword ptr [esi]
		add		esi,4
	.endw
	xor		eax,eax
	dec		eax
  Ex:
	ret

TestBlockEnd endp

CollapseGetEnd proc uses ebx esi edi,hMem:DWORD,nLine:DWORD
	LOCAL	nLines:DWORD
	LOCAL	nNest:DWORD
	LOCAL	nMax:DWORD
	LOCAL	Nest[256]:DWORD

	mov		ebx,hMem
	mov		nLines,0
	mov		nNest,0
	mov		eax,[ebx].EDIT.rpLineFree
	shr		eax,2
	mov		nMax,eax
	mov		edi,nLine
	invoke TestBlockStart,ebx,edi
	.if eax!=-1
		mov		edx,nNest
		mov		Nest[edx*4],eax
		test	[eax].RABLOCKDEF.flag,BD_SEGMENTBLOCK
		.if !ZERO?
			inc		edi
			.while edi<nMax
				mov		esi,edi
				shl		esi,2
				add		esi,[ebx].EDIT.hLine
				mov		esi,[esi]
				add		esi,[ebx].EDIT.hChars
				test	[esi].CHARS.state,STATE_SEGMENTBLOCK
			  .break .if !ZERO?
				inc		edi
			.endw
			mov		eax,edi
			jmp		Ex
		.else
			inc		nNest
			inc		edi
			test	[eax].RABLOCKDEF.flag,BD_LOOKAHEAD
			.if !ZERO?
				mov		esi,eax
				mov		eax,edi
				add		eax,500
				.if eax<nMax
					mov		nMax,eax
				.endif
				.while edi<nMax
					invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszStart
				  .break .if eax!=-1
					invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszEnd
					.if eax!=-1
						mov		nLines,edi
					.endif
					inc		edi
				.endw
				mov		edi,nLines
				mov		eax,edi
				jmp		Ex
			.else
				.while edi<nMax
					invoke TestBlockStart,ebx,edi
					.if eax!=-1
						test	[eax].RABLOCKDEF.flag,BD_SEGMENTBLOCK
						.if ZERO?
							mov		edx,nNest
							mov		Nest[edx*4],eax
							inc		nNest
						.endif
					.else
						invoke TestBlockEnd,ebx,edi
						.if eax!=-1
							mov		edx,nNest
							dec		edx
							.if eax!=Nest[edx*4]
								xor		eax,eax
								dec		eax
								jmp		Ex
							.endif
							dec		nNest
							.if ZERO?
								mov		eax,edi
								jmp		Ex
							.endif
						.endif
					.endif
					inc		edi
				.endw
			.endif
		.endif
	.endif
	xor		eax,eax
	dec		eax
  Ex:
	ret

CollapseGetEnd endp

Collapse proc uses ebx esi edi,hMem:DWORD,nLine:DWORD
	LOCAL	nLines:DWORD
	LOCAL	nNest:DWORD
	LOCAL	nMax:DWORD
	LOCAL	fmasmcomment:DWORD

	mov		ebx,hMem
	xor		eax,eax
	mov		nLines,eax
	mov		nNest,eax
	mov		fmasmcomment,eax
	mov		edi,nLine
	invoke TestBlockStart,ebx,edi
	.if eax!=-1
		mov		esi,eax
		mov		eax,[ebx].EDIT.rpLineFree
		shr		eax,2
		mov		nMax,eax
		test	[esi].RABLOCKDEF.flag,BD_SEGMENTBLOCK
		.if !ZERO?
			invoke SetBookMark,ebx,edi,2
			mov		edx,eax
			inc		edi
			.while edi<nMax
				mov		esi,edi
				shl		esi,2
				add		esi,[ebx].EDIT.hLine
				mov		esi,[esi]
				add		esi,[ebx].EDIT.hChars
				test	[esi].CHARS.state,STATE_SEGMENTBLOCK
			  .break .if !ZERO?
				test	[esi].CHARS.state,STATE_HIDDEN
				.if ZERO?
					or		[esi].CHARS.state,STATE_HIDDEN
					mov		[esi].CHARS.bmid,edx
					inc		[ebx].EDIT.nHidden
				.endif
				inc		edi
			.endw
		.else
			inc		nNest
			inc		edi
			test	[esi].RABLOCKDEF.flag,BD_LOOKAHEAD
			.if !ZERO?
				mov		eax,edi
				add		eax,500
				.if eax<nMax
					mov		nMax,eax
				.endif
				.while edi<nMax
					invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszStart
				  .break .if eax!=-1
					invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszEnd
					.if eax!=-1
						mov		nLines,edi
					.endif
					inc		edi
				.endw
				test	[esi].RABLOCKDEF.flag,BD_INCLUDELAST
				.if ZERO?
					inc		nLines
				.endif
				mov		edi,nLine
				invoke SetBookMark,ebx,edi,2
				mov		edx,eax
				inc		edi
				.while edi<=nLines
					xor		eax,eax
					dec		eax
					push	edx
					.if [esi].RABLOCKDEF.lpszNot1
						invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszNot1
						.if eax==-1
							.if [esi].RABLOCKDEF.lpszNot2
								invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszNot2
							.endif
						.endif
					.endif
					pop		edx
					.if eax==-1
						push	edi
						shl		edi,2
						add		edi,[ebx].EDIT.hLine
						mov		edi,[edi]
						add		edi,[ebx].EDIT.hChars
						test	[edi].CHARS.state,STATE_HIDDEN
						.if ZERO?
							or		[edi].CHARS.state,STATE_HIDDEN
							mov		[edi].CHARS.bmid,edx
							inc		[ebx].EDIT.nHidden
						.endif
						pop		edi
					.endif
					inc		edi
				.endw
			.else
				test	[esi].RABLOCKDEF.flag,BD_COMMENTBLOCK
				.if !ZERO? && [ebx].EDIT.ccmntblocks==4
					inc		fmasmcomment
				.endif
				.while edi<nMax
					mov		eax,-1
					.if !fmasmcomment
						test	[esi].RABLOCKDEF.flag,BD_NOBLOCK
						.if ZERO?
							invoke TestBlockStart,ebx,edi
						.endif
					.endif
					.if eax!=-1
						test	[eax].RABLOCKDEF.flag,BD_SEGMENTBLOCK
						.if ZERO?
							inc		nNest
						.endif
					.else
						.if fmasmcomment
							mov		edx,edi
							inc		edx
							shl		edx,2
							add		edx,[ebx].EDIT.hLine
							mov		edx,[edx].LINE.rpChars
							add		edx,[ebx].EDIT.hChars
							test	[edx].CHARS.state,STATE_COMMENT
							.if ZERO?
								xor		eax,eax
							.endif
						.else
							invoke TestBlockEnd,ebx,edi
						.endif
						.if eax!=-1
							dec		nNest
							.if ZERO?
								test	[esi].RABLOCKDEF.flag,BD_INCLUDELAST
								.if ZERO?
									dec		edi
								.endif
								mov		nLines,edi
								mov		edi,nLine
								invoke SetBookMark,ebx,edi,2
								mov		edx,eax
								inc		edi
								.while edi<=nLines
									mov		eax,-1
									.if !fmasmcomment
										push	edx
										invoke TestBlockStart,ebx,edi
										.if eax!=-1
											inc		nNest
										.else
											invoke TestBlockEnd,ebx,edi
											.if eax!=-1
												dec		nNest
											.endif
										.endif
										pop		edx
										xor		eax,eax
										dec		eax
										.if !nNest
											push	edx
											.if [esi].RABLOCKDEF.lpszNot1
												invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszNot1
												.if eax==-1
													.if [esi].RABLOCKDEF.lpszNot2
														invoke IsLine,ebx,edi,[esi].RABLOCKDEF.lpszNot2
													.endif
												.endif
											.endif
											pop		edx
										.endif
									.endif
									.if eax==-1
										push	edi
										shl		edi,2
										add		edi,[ebx].EDIT.hLine
										mov		edi,[edi]
										add		edi,[ebx].EDIT.hChars
										test	[edi].CHARS.state,STATE_HIDDEN
										.if ZERO?
											or		[edi].CHARS.state,STATE_HIDDEN
											mov		[edi].CHARS.bmid,edx
											inc		[ebx].EDIT.nHidden
										.endif
										pop		edi
									.endif
									inc		edi
								.endw
								jmp		Ex
							.endif
						.endif
					.endif
					inc		edi
				.endw
			.endif
		.endif
	  Ex:
		xor		eax,eax
		mov		edx,nLine
		.if edx<[ebx].EDIT.edta.topln
			mov		[ebx].EDIT.edta.topyp,eax
			mov		[ebx].EDIT.edta.topln,eax
			mov		[ebx].EDIT.edta.topcp,eax
		.endif
		.if edx<[ebx].EDIT.edtb.topln
			mov		[ebx].EDIT.edtb.topyp,eax
			mov		[ebx].EDIT.edtb.topln,eax
			mov		[ebx].EDIT.edtb.topcp,eax
		.endif
		mov		eax,[ebx].EDIT.rpLineFree
		shr		eax,2
		sub		eax,[ebx].EDIT.nHidden
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		mul		ecx
		xor		ecx,ecx
		.if eax<[ebx].EDIT.edta.cpy
			mov		[ebx].EDIT.edta.cpy,eax
			mov		[ebx].EDIT.edta.topyp,ecx
			mov		[ebx].EDIT.edta.topln,ecx
			mov		[ebx].EDIT.edta.topcp,ecx
		.endif
		.if eax<[ebx].EDIT.edtb.cpy
			mov		[ebx].EDIT.edtb.cpy,eax
			mov		[ebx].EDIT.edtb.topyp,ecx
			mov		[ebx].EDIT.edtb.topln,ecx
			mov		[ebx].EDIT.edtb.topcp,ecx
		.endif
	.endif
	ret

Collapse endp

CollapseAll proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
	xor		esi,esi
	mov		edi,[ebx].EDIT.rpLineFree
	shr		edi,2
  @@:
	invoke PreviousBookMark,ebx,edi,1
	.if eax!=-1
		mov		edi,eax
		invoke Collapse,ebx,edi
		.if eax!=-1
			inc		esi
		.endif
		jmp		@b
	.endif
	mov		eax,esi
	ret

CollapseAll endp

Expand proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	push	[ebx].EDIT.nHidden
	mov		esi,nLine
	xor		eax,eax
	.if esi<[ebx].EDIT.edta.topln
		mov		[ebx].EDIT.edta.topyp,eax
		mov		[ebx].EDIT.edta.topln,eax
		mov		[ebx].EDIT.edta.topcp,eax
	.endif
	.if esi<[ebx].EDIT.edtb.topln
		mov		[ebx].EDIT.edtb.topyp,eax
		mov		[ebx].EDIT.edtb.topln,eax
		mov		[ebx].EDIT.edtb.topcp,eax
	.endif
	shl		esi,2
	cmp		esi,[ebx].EDIT.rpLineFree
	jnb		Ex
	add		esi,[ebx].EDIT.hLine
	mov		ecx,[ebx].EDIT.rpLineFree
	add		ecx,[ebx].EDIT.hLine
	mov		eax,[esi].LINE.rpChars
	add		eax,[ebx].EDIT.hChars
	test	[eax].CHARS.state,STATE_HIDDEN
	jne		Ex
	mov		edi,[esi].LINE.rpChars
	add		edi,[ebx].EDIT.hChars
	mov		eax,[edi].CHARS.state
	and		eax,STATE_BMMASK
	.if eax==STATE_BM2
		mov		eax,[edi].CHARS.state
		and		eax,-1 xor STATE_BMMASK
		or		eax,STATE_BM1
		mov		[edi].CHARS.state,eax
	.elseif eax==STATE_BM8
		mov		eax,[edi].CHARS.state
		and		eax,-1 xor STATE_BMMASK
		mov		[edi].CHARS.state,eax
	.endif
	add		esi,sizeof LINE
	.if esi<ecx
		push	ecx
		mov		eax,esi
		add		eax,(sizeof LINE)*64
		.if eax<ecx
			;Check max 64 lines ahead
			mov		ecx,eax
		.endif
		.while esi<ecx
			mov		edi,[esi].LINE.rpChars
			add		edi,[ebx].EDIT.hChars
			test	[edi].CHARS.state,STATE_HIDDEN
			.break .if !ZERO?
			add		esi,sizeof LINE
		.endw
		pop		ecx
		mov		edi,[esi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		test	[edi].CHARS.state,STATE_HIDDEN
		je		Ex
		mov		edx,[edi].CHARS.bmid
		.while esi<ecx
			mov		edi,[esi].LINE.rpChars
			add		edi,[ebx].EDIT.hChars
			.if edx==[edi].CHARS.bmid
				test	[edi].CHARS.state,STATE_HIDDEN
				.if !ZERO?
					and		[edi].CHARS.state,-1 xor STATE_HIDDEN
					dec		[ebx].EDIT.nHidden
				.endif
			.endif
			add		esi,sizeof LINE
		.endw
	.endif
  Ex:
	pop		eax
	sub		eax,[ebx].EDIT.nHidden
	ret

Expand endp

ExpandAll proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	xor		esi,esi
	xor		edi,edi
	invoke GetBookMark,ebx,edi
  @@:
	.if eax==2
		invoke Expand,ebx,edi
		inc		esi
	.endif
	invoke NextBookMark,ebx,edi,2
	.if eax!=-1
		mov		edi,eax
		mov		eax,2
		jmp		@b
	.endif
	mov		eax,esi
	ret

ExpandAll endp

TestExpand proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	push	[ebx].EDIT.nHidden
  @@:
	invoke IsLineHidden,ebx,nLine
	.if eax
		push	nLine
		.while eax && nLine
			dec		nLine
			invoke IsLineHidden,ebx,nLine
		.endw
		invoke Expand,ebx,nLine
		pop		nLine
		jmp		@b
	.endif
	pop		eax
	.if eax!=[ebx].EDIT.nHidden
		invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
		invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	.endif
	ret

TestExpand endp

SetCommentBlocks proc uses ebx esi edi,hMem:DWORD,lpStart:DWORD,lpEnd:DWORD
	LOCAL	nLine:DWORD
	LOCAL	nCmnt:DWORD
	LOCAL	fCmnt:DWORD
	LOCAL	cmntchar:DWORD
	LOCAL	fChanged:DWORD

	mov		ebx,hMem
	mov		cmntchar,0
	mov		[ebx].EDIT.ccmntblocks,0
	mov		eax,lpStart
	mov		edx,lpEnd
	.if word ptr [eax]=='*/' && word ptr [edx]=='/*'
		mov		[ebx].EDIT.ccmntblocks,1
		xor		ecx,ecx
		mov		nLine,ecx
		mov		nCmnt,ecx
		mov		fChanged,ecx
		mov		edi,[ebx].EDIT.rpLineFree
		shr		edi,2
		.while nLine<edi
			mov		esi,nLine
			shl		esi,2
			add		esi,[ebx].EDIT.hLine
			mov		esi,[esi]
			add		esi,[ebx].EDIT.hChars
			push	[esi].CHARS.state
			xor		ecx,ecx
			inc		ecx
			mov		eax,nCmnt
			mov		fCmnt,eax
			.while ecx<[esi].CHARS.len
				.if word ptr [esi+ecx+sizeof CHARS-1]=="*/"
					inc		ecx
					inc		nCmnt
				.elseif word ptr [esi+ecx+sizeof CHARS-1]=="/*"
					inc		ecx
					.if nCmnt
						dec		nCmnt
					.endif
				.endif
				inc		ecx
			.endw
			and		[esi].CHARS.state,-1 xor STATE_COMMENT or STATE_COMMENTNEST
			.if nCmnt>1 || fCmnt
				or		[esi].CHARS.state,STATE_COMMENT
				.if nCmnt && fCmnt
					or		[esi].CHARS.state,STATE_COMMENT or STATE_COMMENTNEST
				.endif
			.endif
			pop		eax
			.if eax!=[esi].CHARS.state
				inc		fChanged
			.endif
			inc		nLine
		.endw
		.if fChanged
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
		.endif
		ret
	.elseif word ptr [eax]=="'/" && word ptr [edx]=="/'"
		mov		[ebx].EDIT.ccmntblocks,2
		xor		ecx,ecx
		mov		nLine,ecx
		mov		nCmnt,ecx
		mov		fChanged,ecx
		mov		edi,[ebx].EDIT.rpLineFree
		shr		edi,2
		.while nLine<edi
			mov		esi,nLine
			shl		esi,2
			add		esi,[ebx].EDIT.hLine
			mov		esi,[esi]
			add		esi,[ebx].EDIT.hChars
			push	[esi].CHARS.state
			xor		ecx,ecx
			inc		ecx
			mov		eax,nCmnt
			mov		fCmnt,eax
			.while ecx<[esi].CHARS.len
				.if byte ptr [esi+ecx+sizeof CHARS-1]=="'" &&  word ptr [esi+ecx+sizeof CHARS-1]!="/'"
					mov		ecx,[esi].CHARS.len
				.elseif byte ptr [esi+ecx+sizeof CHARS-1]=='"'
					inc		ecx
					.while ecx<[esi].CHARS.len && byte ptr [esi+ecx+sizeof CHARS-1]!='"'
						inc		ecx
					.endw
				.elseif word ptr [esi+ecx+sizeof CHARS-1]=="'/"
					inc		ecx
					inc		nCmnt
				.elseif word ptr [esi+ecx+sizeof CHARS-1]=="/'"
					inc		ecx
					.if nCmnt
						dec		nCmnt
					.endif
				.endif
				inc		ecx
			.endw
			and		[esi].CHARS.state,-1 xor STATE_COMMENT or STATE_COMMENTNEST
			.if nCmnt>1 || fCmnt
				or		[esi].CHARS.state,STATE_COMMENT
				.if nCmnt && fCmnt
					or		[esi].CHARS.state,STATE_COMMENT or STATE_COMMENTNEST
				.endif
			.endif
			pop		eax
			.if eax!=[esi].CHARS.state
				inc		fChanged
			.endif
			inc		nLine
		.endw
		.if fChanged
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
		.endif
		ret
	.elseif word ptr [eax]=='{' && word ptr [edx]=='}'
		mov		[ebx].EDIT.ccmntblocks,3
	.else
		invoke lstrcmpi,lpStart,offset szComment
		mov		edx,lpEnd
		.if !eax && word ptr [edx]=='-'
			mov		[ebx].EDIT.ccmntblocks,4
		.endif
		mov		eax,lpStart
	.endif
	mov		al,byte ptr [eax]
	.if al
		mov		ebx,hMem
		xor		ecx,ecx
		mov		nLine,ecx
		mov		nCmnt,ecx
		mov		fChanged,ecx
		mov		fCmnt,ecx
		mov		edi,[ebx].EDIT.rpLineFree
		shr		edi,2
		.while nLine<edi
			mov		esi,nLine
			shl		esi,2
			add		esi,[ebx].EDIT.hLine
			mov		esi,[esi]
			add		esi,[ebx].EDIT.hChars
			push	[esi].CHARS.state
			mov		edx,lpStart
			mov		ax,[edx]
			call	IsLineStart
			.if !eax
				inc		nCmnt
				inc		fCmnt
			.else
				xor		ecx,ecx
			.endif
			.if nCmnt>1 || (nCmnt && !fCmnt)
				or		[esi].CHARS.state,STATE_COMMENT
			.else
				and		[esi].CHARS.state,-1 xor STATE_COMMENT
			.endif
			mov		fCmnt,0
			.if nCmnt
				mov		edx,lpEnd
				call	IsLineEnd
				.if !eax
					dec		nCmnt
				.endif
			.endif
			pop		eax
			.if eax!=[esi].CHARS.state
				inc		fChanged
			.endif
			inc		nLine
		.endw
		.if fChanged
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
		.endif
	.endif
	ret

TestWrd:
	push	ecx
	push	edx
	dec		ecx
	dec		edx
  @@:
	inc		edx
	mov		al,[edx]
	or		al,al
	je		@f
TestWrd1:
	inc		ecx
	mov		ah,[esi+ecx+sizeof CHARS]
	.if al=='+'
		cmp		ah,' '
		je		TestWrd1
		cmp		ah,VK_TAB
		je		TestWrd1
		mov		byte ptr cmntchar,ah
		jmp		@f
	.elseif al=='-'
		mov		al,byte ptr cmntchar
	.endif
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		@b
	pop		edx
	pop		ecx
	retn
  @@:
	pop		edx
	pop		eax
	xor		eax,eax
	retn

IsLineStart:
	xor		ecx,ecx
	dec		ecx
	mov		eax,ecx
  @@:
	inc		ecx
	cmp		ecx,[esi].CHARS.len
	je		@f
	mov		al,[esi+ecx+sizeof CHARS]
	cmp		al,' '
	je		@b
	cmp		al,VK_TAB
	je		@b
	movzx	eax,byte ptr [esi+ecx+sizeof CHARS]
	movzx	eax,byte ptr [eax+offset CharTab]
	cmp		eax,CT_CMNTCHAR
	je		@f
	.if [ebx].EDIT.ccmntblocks && [ebx].EDIT.ccmntblocks!=4
		.while ecx<[esi].CHARS.len
			call	TestWrd
			inc		ecx
		  .break .if !eax
		.endw
	.else
		call	TestWrd
		inc		ecx
	.endif
  @@:
	retn

IsLineEnd:
	.while ecx<[esi].CHARS.len
		call	TestWrd
		inc		ecx
	  .break .if !eax
	.endw
	retn

SetCommentBlocks endp

SetChangedState proc uses ebx esi edi,hMem:DWORD,fUpdate:DWORD
	LOCAL	nLine:DWORD
	LOCAL	fChanged:DWORD

	mov		ebx,hMem
	xor		edx,edx
	mov		nLine,edx
	mov		fChanged,edx
	mov		edx,fUpdate
	mov		edi,[ebx].EDIT.rpLineFree
	shr		edi,2
	.while nLine<edi
		mov		esi,nLine
		shl		esi,2
		add		esi,[ebx].EDIT.hLine
		mov		esi,[esi]
		add		esi,[ebx].EDIT.hChars
		mov		ecx,[esi].CHARS.state
		test	[esi].CHARS.state,STATE_CHANGED
		.if !ZERO?
			and		[esi].CHARS.state,-1 xor STATE_CHANGED
			.if edx
				or		[esi].CHARS.state,STATE_CHANGESAVED
			.endif
		.elseif !edx
			and		[esi].CHARS.state,-1 xor STATE_CHANGESAVED
		.endif
		.if ecx!=[esi].CHARS.state
			inc		fChanged
		.endif
		inc		nLine
	.endw
	.if fChanged
		invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
		invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	.endif
	mov		eax,fChanged
	ret

SetChangedState endp
