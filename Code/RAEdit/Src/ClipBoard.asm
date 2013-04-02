
.code

SetClipData proc lpData:LPSTR,dwSize:dword
	LOCAL	hMem:HANDLE
	LOCAL	pMem:dword

	mov		eax,dwSize
	shr		eax,3
	inc		eax
	shl		eax,3
	invoke xGlobalAlloc, GHND or GMEM_DDESHARE, eax
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
	invoke  GlobalFree, hMem
	xor     eax, eax
  @exit2:
	dec     eax          ; -1 - error
  @exit3:
	ret

SetClipData endp

EditCopy proc uses ebx esi edi,hMem:DWORD,lpCMem:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.cpMax
	.if eax>edx
		xchg	eax,edx
	.endif
	mov		cpMin,eax
	mov		cpMax,edx
	invoke GetCharPtr,ebx,cpMin
	mov		ecx,eax
	mov		edi,lpCMem
	mov		edx,cpMin
	mov		esi,[ebx].EDIT.hLine
	add		esi,[ebx].EDIT.rpLine
	.while edx<cpMax
		mov		eax,[ebx].EDIT.hChars
		add		eax,[esi].LINE.rpChars
		push	eax
		mov		al,[eax+ecx+sizeof CHARS]
		inc		ecx
		mov		[edi],al
		inc		edi
		.if al==0Dh
			mov		byte ptr [edi],0Ah
			inc		edi
		.endif
		pop		eax
		.if ecx==[eax].CHARS.len
			xor		ecx,ecx
			add		esi,sizeof LINE
		.endif
		inc		edx
	.endw
	sub		edi,lpCMem
	mov		eax,edi
	ret

EditCopy endp

EditCopyBlock proc uses ebx esi,hMem:DWORD,lpCMem:DWORD
	LOCAL	blrg:BLOCKRANGE

	mov		ebx,hMem
	invoke GetBlockRange,addr [ebx].EDIT.blrg,addr blrg
	mov		esi,lpCMem
	mov		edx,blrg.lnMin
	.while edx<=blrg.lnMax
		call	CopyBlockLine
		inc		edx
	.endw
	mov		eax,esi
	sub		eax,lpCMem
	ret

CopyBlockChar:
	invoke GetBlockCp,ebx,edx,eax
	invoke GetChar,ebx,eax
	.if eax==VK_RETURN || eax==VK_TAB
		mov		eax,VK_SPACE
	.endif
	mov		[esi],al
	inc		esi
	retn

CopyBlockLine:
	mov		eax,blrg.clMin
	.while eax<blrg.clMax
		push	eax
		push	edx
		call	CopyBlockChar
		pop		edx
		pop		eax
		inc		eax
	.endw
	mov		eax,0A0Dh
	mov		[esi],eax
	add		esi,2
	retn

EditCopyBlock endp

EditCopyNoLF proc uses ebx esi edi,hMem:DWORD,lpCMem:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.cpMax
	.if eax>edx
		xchg	eax,edx
	.endif
	mov		cpMin,eax
	mov		cpMax,edx
	invoke GetCharPtr,ebx,cpMin
	mov		ecx,eax
	mov		edi,lpCMem
	mov		edx,cpMin
	mov		esi,[ebx].EDIT.hLine
	add		esi,[ebx].EDIT.rpLine
	.while edx<cpMax
		mov		eax,[ebx].EDIT.hChars
		add		eax,[esi].LINE.rpChars
		push	eax
		mov		al,[eax+ecx+sizeof CHARS]
		inc		ecx
		mov		[edi],al
		inc		edi
		pop		eax
		.if ecx==[eax].CHARS.len
			xor		ecx,ecx
			add		esi,sizeof LINE
		.endif
		inc		edx
	.endw
	sub		edi,lpCMem
	mov		eax,edi
	ret

EditCopyNoLF endp

Copy proc uses ebx,hMem:DWORD
	LOCAL	hCMem:DWORD

	mov		ebx,hMem
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		mov		eax,[ebx].EDIT.cpMin
		sub		eax,[ebx].EDIT.cpMax
		.if eax
			.if sdword ptr eax<0
				neg		eax
			.endif
			shr		eax,3
			inc		eax
			shl		eax,4
			invoke xGlobalAlloc,GMEM_ZEROINIT,eax
			mov     hCMem,eax
			invoke GlobalLock,hCMem
			push	eax
			invoke EditCopy,ebx,eax
			pop		edx
			invoke SetClipData,edx,eax
			invoke GlobalUnlock,hCMem
			invoke GlobalFree,hCMem
		.endif
	.else
		mov		eax,[ebx].EDIT.blrg.clMin
		.if eax!=[ebx].EDIT.blrg.clMax
			invoke xGlobalAlloc,GMEM_ZEROINIT,256*1024
			mov     hCMem,eax
			invoke GlobalLock,hCMem
			push	eax
			invoke EditCopyBlock,ebx,eax
			pop		edx
			invoke SetClipData,edx,eax
			invoke GlobalUnlock,hCMem
			invoke GlobalFree,hCMem
		.endif
	.endif
	ret

Copy endp

EditPaste proc uses ebx,hMem:DWORD,hData:DWORD

	mov		ebx,hMem
	mov		eax,hData
	.if eax
		call	InsertMem
	.else
		invoke OpenClipboard,[ebx].EDIT.hwnd
		.if eax
			invoke GetClipboardData,CF_TEXT
			.if eax
				call	InsertMem
			.endif
			invoke CloseClipboard
		.endif
	.endif
	ret

InsertMem:
	push	eax
	invoke GlobalLock,eax
	push	[ebx].EDIT.fOvr
	mov		[ebx].EDIT.fOvr,FALSE
	push	[ebx].EDIT.cpMin
	push	eax
	invoke EditInsert,ebx,[ebx].EDIT.cpMin,eax
	add		[ebx].EDIT.cpMin,eax
	add		[ebx].EDIT.cpMax,eax
	pop		edx
	pop		ecx
	invoke SaveUndo,ebx,UNDO_INSERTBLOCK,ecx,edx,eax
	pop		[ebx].EDIT.fOvr
	pop		eax
	invoke GlobalUnlock,eax
	retn

EditPaste endp

EditPasteBlock proc uses ebx esi edi,hMem:DWORD,hData:DWORD
	LOCAL	nSpc:DWORD
	LOCAL	blrg:BLOCKRANGE

	mov		ebx,hMem
	invoke GetBlockRange,addr [ebx].EDIT.blrg,addr blrg
	mov		eax,hData
	.if eax
		call	InsertMem
	.else
		invoke OpenClipboard,[ebx].EDIT.hwnd
		.if eax
			invoke GetClipboardData,CF_TEXT
			.if eax
				call	InsertMem
			.endif
			invoke CloseClipboard
			mov		eax,blrg.lnMin
			mov		[ebx].EDIT.blrg.lnMin,eax
			mov		[ebx].EDIT.blrg.lnMax,eax
			mov		eax,blrg.clMin
			mov		[ebx].EDIT.blrg.clMin,eax
			mov		[ebx].EDIT.blrg.clMax,eax
		.endif
	.endif
	ret

InsertMem:
	push	eax
	invoke GlobalLock,eax
	mov		esi,eax
	push	[ebx].EDIT.fOvr
	mov		[ebx].EDIT.fOvr,FALSE
	mov		nSpc,0
  @@:
	invoke GetBlockCp,ebx,blrg.lnMin,blrg.clMin
	mov		edi,eax
	invoke GetChar,ebx,edi
	.if !eax
		invoke InsertChar,ebx,edi,VK_RETURN
	.endif
	.if blrg.clMin
		invoke GetBlockCp,ebx,blrg.lnMin,blrg.clMin
		push	eax
		mov		eax,blrg.clMin
		dec		eax
		invoke GetBlockCp,ebx,blrg.lnMin,eax
		pop		edx
		.if eax==edx
			push	edx
			invoke GetCharPtr,ebx,edx
			pop		edx
			invoke InsertChar,ebx,edx,VK_SPACE
			inc		nSpc
			jmp		@b
		.endif
	.endif
	invoke GetBlockCp,ebx,blrg.lnMin,blrg.clMin
	mov		edi,eax
	push	edi
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		movzx	eax,byte ptr [esi]
		invoke InsertChar,ebx,edi,eax
		inc		edi
		inc		esi
	.endw
	mov		[ebx].EDIT.cpMin,edi
	mov		[ebx].EDIT.cpMax,edi
	.if byte ptr [esi]==VK_RETURN
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	pop		eax
	push	eax
	invoke GetCharPtr,ebx,eax
	pop		ecx
	sub		edi,ecx
	mov		edx,[ebx].EDIT.rpChars
	add		edx,[ebx].EDIT.hChars
	add		edx,sizeof CHARS
	add		edx,eax
	sub		edx,nSpc
	sub		ecx,nSpc
	mov		eax,edi
	add		eax,nSpc
	invoke SaveUndo,ebx,UNDO_INSERTBLOCK,ecx,edx,eax
	.if byte ptr [esi]
		inc		blrg.lnMin
		mov		nSpc,0
		jmp		@b
	.endif
	add		blrg.clMin,edi
	mov		eax,blrg.clMin
	mov		blrg.clMax,eax
	mov		eax,blrg.lnMin
	mov		blrg.lnMax,eax
	pop		[ebx].EDIT.fOvr
	pop		eax
	invoke GlobalUnlock,eax
	retn

EditPasteBlock endp

Paste proc uses ebx esi edi,hMem:DWORD,hWin:DWORD,hData:DWORD
	LOCAL	pt:POINT
	LOCAL	blrg:BLOCKRANGE

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		invoke DeleteSelection,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		invoke EditPaste,ebx,hData
	.else
		invoke GetBlockRange,addr [ebx].EDIT.blrg,addr blrg
		invoke DeleteSelectionBlock,ebx,blrg.lnMin,blrg.clMin,blrg.lnMax,blrg.clMax
		invoke GetBlockCp,ebx,blrg.lnMin,blrg.clMin
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		invoke EditPasteBlock,ebx,hData
	.endif
	invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
	invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
	invoke SetCaret,ebx,[esi].RAEDT.cpy
	invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
	invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	invoke SetCpxMax,ebx,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Paste endp

Cut proc uses ebx esi,hMem:DWORD,hWin:DWORD
	LOCAL	pt:POINT
    LOCAL   cpOldTopA:DWORD           ; *** MOD 
    LOCAL   cpOldTopB:DWORD           ; *** MOD
    LOCAL   cpOldMin:DWORD            ; *** MOD 
    LOCAL   cpOldMax:DWORD            ; *** MOD

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		invoke Copy,ebx
		
		; *** MOD
		mov 	eax, [ebx].EDIT.edta.topcp
		mov 	cpOldTopA, eax 
		mov 	eax, [ebx].EDIT.edtb.topcp
		mov 	cpOldTopB, eax 
	
		mov		eax,[ebx].EDIT.cpMin
		mov		cpOldMin,eax
		mov		edx,[ebx].EDIT.cpMax
		mov		cpOldMax,edx
		; ================
		
		invoke DeleteSelection,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax

		; *** MOD
		mov		ecx, hWin
		.if ecx==[ebx].EDIT.edta.hwnd
			invoke CompensateTopLineAfterDelete, ebx, cpOldMin, cpOldMax, cpOldTopB
			mov	[ebx].EDIT.edtb.cpy,eax
		.else
			invoke CompensateTopLineAfterDelete, ebx, cpOldMin, cpOldMax, cpOldTopA
			mov	[ebx].EDIT.edta.cpy,eax
		.endif 
		; ===================
	.else
		invoke GetBlockRange,addr [ebx].EDIT.blrg,addr [ebx].EDIT.blrg
		invoke Copy,ebx
		invoke DeleteSelectionBlock,ebx,[ebx].EDIT.blrg.lnMin,[ebx].EDIT.blrg.clMin,[ebx].EDIT.blrg.lnMax,[ebx].EDIT.blrg.clMax
		mov		eax,[ebx].EDIT.blrg.clMin
		mov		edx,[ebx].EDIT.blrg.lnMin
		mov		[ebx].EDIT.blrg.clMax,eax
		mov		[ebx].EDIT.blrg.lnMax,edx
		invoke GetBlockCp,ebx,edx,eax
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
	.endif
	invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
	invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
	invoke SetCaret,ebx,[esi].RAEDT.cpy
	invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
	invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	invoke SetCpxMax,ebx,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Cut endp

ConvertCase proc uses ebx esi edi,hMem:DWORD,nFunction:DWORD

	mov		ebx,hMem
	inc		nUndoid
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.cpMax
	.if eax<edx
		xchg	eax,edx
	.endif
	sub		eax,edx
	inc		eax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
	mov		edi,eax
	invoke EditCopyNoLF,ebx,edi
	.if nFunction==CONVERT_UPPERCASE
		invoke CharUpper,edi
	.elseif nFunction==CONVERT_LOWERCASE
		invoke CharLower,edi
	.endif
	invoke Paste,ebx,[ebx].EDIT.focus,edi
	invoke GlobalFree,edi
	inc		nUndoid
	ret

ConvertCase endp

ConvertIndent proc uses ebx esi edi,hMem:DWORD,nFunction:DWORD
	LOCAL	hCMem:DWORD
	LOCAL	hLMem:DWORD
	LOCAL	cpst:DWORD
	LOCAL	cpen:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD
	LOCAL	nxt:DWORD
	LOCAL	len:DWORD
	LOCAL	spcount:DWORD

	mov		ebx,hMem
	inc		nUndoid
	mov		edx,[ebx].EDIT.cpMin
	mov		eax,[ebx].EDIT.cpMax
	.if eax<edx
		xchg	eax,edx
	.endif
	push	eax
	invoke GetLineFromCp,ebx,edx
	invoke GetCpFromLine,ebx,eax
	mov		edx,eax
	pop		eax
	mov		cpst,edx
	mov		cpMin,edx
	mov		[ebx].EDIT.cpMin,edx
	mov		cpen,eax
	mov		cpMax,eax
	mov		[ebx].EDIT.cpMax,eax
	sub		eax,edx
	inc		eax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
	mov		edi,eax
	mov		hCMem,eax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*32
	mov		hLMem,eax
	invoke EditCopyNoLF,ebx,edi
	.while byte ptr [edi]
		call	GetIndent
		.if edx
			mov		len,edx
			mov		esi,hLMem
			xor		ecx,ecx
			xor		edx,edx
			.if nFunction==CONVERT_TABTOSPACE
				mov		eax,[ebx].EDIT.nTab
				mov		nxt,eax
				.while edx<len
					mov		al,[edi+edx]
					.if al==VK_TAB
						.while ecx<nxt
							mov		byte ptr [esi+ecx],VK_SPACE
							inc		ecx
						.endw
					.elseif al==VK_SPACE
						mov		byte ptr [esi+ecx],VK_SPACE
						inc		ecx
					.endif
					.if ecx==nxt
						mov		eax,[ebx].EDIT.nTab
						add		nxt,eax
					.endif
					inc		edx
				.endw
			.elseif nFunction==CONVERT_SPACETOTAB
				mov		eax,[ebx].EDIT.nTab
				mov		nxt,eax
				mov		spcount,edx
				.while edx<len
					mov		al,[edi+edx]
					inc		edx
					.if al==VK_TAB
						mov		nxt,edx
					.elseif al==VK_SPACE
						inc		spcount
					.endif
					.if edx==nxt
						mov		spcount,0
						mov		byte ptr [esi+ecx],VK_TAB
						inc		ecx
						mov		eax,[ebx].EDIT.nTab
						add		nxt,eax
					.endif
				.endw
				.while spcount
					mov		byte ptr [esi+ecx],VK_SPACE
					inc		ecx
					dec		spcount
				.endw
			.endif
			mov		byte ptr [esi+ecx],0
			mov		eax,ecx
			sub		eax,len
			add		cpMin,eax
			add		cpMax,eax
			add		cpen,eax
			invoke DeleteSelection,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			invoke EditPaste,ebx,esi
		.endif
		call	NextLine
	.endw
	invoke GlobalFree,hLMem
	invoke GlobalFree,hCMem
	mov		eax,cpst
	mov		[ebx].EDIT.cpMin,eax
	mov		eax,cpen
	mov		[ebx].EDIT.cpMax,eax
	inc		nUndoid
	ret

NextLine:
	.while byte ptr [edi] && byte ptr [edi]!=VK_RETURN
		inc		edi
	.endw
	.if byte ptr [edi]
		inc		edi
	.endif
	retn

GetIndent:
	xor		edx,edx
	.while byte ptr [edi+edx]==VK_SPACE || byte ptr [edi+edx]==VK_TAB
		inc		edx
	.endw
	mov		eax,edi
	sub		eax,hCMem
	add		eax,cpMin
	mov		[ebx].EDIT.cpMin,eax
	add		eax,edx
	mov		[ebx].EDIT.cpMax,eax
	retn

ConvertIndent endp
