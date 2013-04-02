
.code

FindTheText proc uses ebx esi edi,hMem:DWORD,pFind:DWORD,fMC:DWORD,fWW:DWORD,fWhiteSpace:DWORD,cpMin:DWORD,cpMax:DWORD,fDir:DWORD
	LOCAL	nLine:DWORD
	LOCAL	lnlen:DWORD
	LOCAL	lpFind[15]:DWORD
	LOCAL	len[15] :DWORD
	LOCAL	findbuff[512]:BYTE
	LOCAL	nIgnore:DWORD
	LOCAL	prev:DWORD
	LOCAL	cp:DWORD

	xor		esi,esi
	mov		lnlen,esi
	.while esi<16
		mov		lpFind[esi*4],0
		mov		len[esi*4],0
		inc		esi
	.endw
	mov		esi,pFind
	lea		edi,findbuff
	mov		lpFind[0],edi
	xor		ecx,ecx
	xor		edx,edx
	.while byte ptr [esi] && ecx<255 && edx<16
		mov		al,[esi]
		mov		[edi],al
		.if al==VK_RETURN
			inc		edi
			mov		byte ptr [edi],0
			inc		edi
			inc		ecx
			mov		len[edx*4],ecx
			xor		ecx,ecx
			inc		edx
			mov		lpFind[edx*4],edi
			dec		edi
			dec		ecx
		.endif
		inc		esi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],0
	mov		len[edx*4],ecx
	mov		ebx,hMem
	.if fDir==1
		; Down
		invoke GetCharPtr,ebx,cpMin
		mov		nLine,edx
		mov		ecx,eax
		sub		cpMin,ecx
		mov		edx,cpMin
		mov		eax,-1
		.while edx<=cpMax
			mov		nIgnore,0
			push	nLine
			xor		esi,esi
			.while len[esi*4]
				call	TstLnDown
				.break .if eax==-1
				inc		nLine
				inc		esi
				xor		ecx,ecx
			.endw
			pop		nLine
			.break .if eax!=-1
			mov		edx,lnlen
			add		cpMin,edx
			mov		edx,cpMin
			inc		nLine
			xor		ecx,ecx
			mov		eax,-1
		.endw
		.if eax>cpMax
			mov		eax,-1
		.endif
	.else
		; Up
		mov		eax,cpMin
		mov		cp,eax
		invoke GetCharPtr,ebx,cpMin
		mov		nLine,edx
		mov		ecx,eax
		mov		edx,cpMin
		mov		eax,-1
		.while sdword ptr edx>=cpMax
			mov		nIgnore,0
			push	nLine
			xor		esi,esi
			.while len[esi*4]
				call	TstLnUp
				.break .if eax==-1
				inc		nLine
				inc		esi
				xor		ecx,ecx
			.endw
			pop		nLine
			.break .if eax!=-1 && eax<=cp
			dec		nLine
			mov		edi,nLine
			shl		edi,2
			mov		eax,-1
			.break .if edi>=[ebx].EDIT.rpLineFree
			invoke GetCpFromLine,ebx,nLine
			mov		cpMin,eax
			add		edi,[ebx].EDIT.hLine
			mov		edi,[edi].LINE.rpChars
			add		edi,[ebx].EDIT.hChars
			mov		ecx,[edi].CHARS.len
			add		cpMin,ecx
			mov		edx,cpMin
			mov		eax,-1
		.endw
	.endif
	mov		edx,nIgnore
	ret

TstFind:
	mov		prev,1
	push	ecx
	push	esi
	mov		esi,lpFind[esi*4]
	dec		esi
	dec		ecx
  TstFind1:
	inc		esi
	inc		ecx
  TstFind3:
	mov		al,[esi]
	or		al,al
	je		TstFind2
	mov		ah,[edi+ecx+sizeof CHARS]
	.if fWhiteSpace
		movzx	edx,al
		movzx	edx,CharTab[edx]
		.if (al==VK_SPACE || al==VK_TAB) && (ah==VK_SPACE || ah==VK_TAB)
			.while (byte ptr [edi+ecx+sizeof CHARS]==VK_SPACE || byte ptr [edi+ecx+sizeof CHARS]==VK_TAB) && ecx<[edi].CHARS.len
				inc		ecx
				inc		nIgnore
			.endw
			.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
				inc		esi
				dec		nIgnore
			.endw
			jmp		TstFind3
		.elseif (ah==VK_SPACE || ah==VK_TAB) && (!ecx || edx!=1 || prev!=1)
			;Ignore whitespace
			.while (byte ptr [edi+ecx+sizeof CHARS]==VK_SPACE || byte ptr [edi+ecx+sizeof CHARS]==VK_TAB) && ecx<[edi].CHARS.len
				inc		ecx
				inc		nIgnore
			.endw
			mov		prev,edx
			jmp		TstFind3
		.endif
	.endif
	cmp		al,ah
	je		TstFind1
	.if !fMC
		movzx	edx,al
		mov		al,CaseTab[edx]
		cmp		al,ah
		je		TstFind1
	.endif
	xor		eax,eax
	dec		eax
  TstFind2:
	.if fWW && !al
		.if ecx<=[edi].CHARS.len
			movzx	eax,byte ptr [edi+ecx+sizeof CHARS]
			lea		eax,[eax+offset CharTab]
			mov		al,[eax]
			.if al==CT_CHAR
				xor		eax,eax
				dec		eax
			.else
				xor		eax,eax
			.endif
		.endif
	.endif
	pop		esi
	pop		ecx
	or		al,al
	retn

TstLnDown:
	mov		edi,nLine
	shl		edi,2
	.if edi<[ebx].EDIT.rpLineFree
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		.if !esi
			mov		eax,[edi].CHARS.len
			mov		lnlen,eax
		.endif
	  Nxt:
		mov		eax,len[esi*4]
		add		eax,ecx
		.if eax<=[edi].CHARS.len
			.if fWW && ecx
				movzx	eax,byte ptr [edi+ecx+sizeof CHARS-1]
				.if byte ptr CharTab[eax]==CT_CHAR
					inc		ecx
					jmp		Nxt
				.endif
			.endif
			call	TstFind
			je		Found
			.if !esi
				inc		ecx
				jmp		Nxt
			.endif
		.endif
	.else
		; EOF
		.if fDir==1
			mov		cpMin,-1
			mov		lnlen,0
		.else
			mov		cpMax,-1
			mov		lnlen,0
		.endif
	.endif
	mov		eax,-1
	retn
  Found:
	.if !esi
		add		cpMin,ecx
		sub		lnlen,ecx
	.endif
	mov		eax,cpMin
	retn

TstLnUp:
	mov		edi,nLine
	shl		edi,2
	.if edi<[ebx].EDIT.rpLineFree
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		.if !esi
			mov		eax,[edi].CHARS.len
			mov		lnlen,eax
			sub		cpMin,ecx
		.endif
		.if !CARRY?
		  NxtUp:
			.if fWW && ecx
				movzx	eax,byte ptr [edi+ecx+sizeof CHARS-1]
				.if byte ptr CharTab[eax]==CT_CHAR
					dec		ecx
					jge		NxtUp
					jmp		NotFoundUp
				.endif
			.endif
			call	TstFind
			je		FoundUp
			.if !esi
				dec		ecx
				jge		NxtUp
			.endif
		.endif
	.else
		; EOF
		.if fDir==1
			mov		cpMin,-1
			mov		lnlen,0
		.else
			mov		cpMax,-1
			mov		lnlen,0
		.endif
	.endif
  NotFoundUp:
	mov		eax,-1
	retn
  FoundUp:
	.if !esi
		add		cpMin,ecx
		sub		lnlen,ecx
	.endif
	mov		eax,cpMin
	retn

FindTheText endp

FindTextEx proc uses ebx esi edi,hMem:DWORD,fFlag:DWORD,lpFindTextEx:DWORD
	LOCAL	lpText:DWORD
	LOCAL	len:DWORD
	LOCAL	fMC:DWORD
	LOCAL	fWW:DWORD

	mov		ebx,hMem
	mov		esi,lpFindTextEx
	mov		eax,[esi].FINDTEXTEX.lpstrText
	mov		lpText,eax
	invoke strlen,eax
	.if eax
		mov		len,eax
		xor		eax,eax
		mov		fMC,eax
		mov		fWW,eax
		test	fFlag,FR_WHOLEWORD
		.if !ZERO?
			inc		fWW
		.endif
		test	fFlag,FR_MATCHCASE
		.if !ZERO?
			inc		fMC
		.endif
		mov		eax,[esi].FINDTEXTEX.chrg.cpMin
		test	fFlag,FR_DOWN
		.if !ZERO?
			;Down
			xor		eax,eax
			test	fFlag,FR_IGNOREWHITESPACE
			.if !ZERO?
				inc		eax
			.endif
			mov		ecx,[esi].FINDTEXTEX.chrg.cpMax
			.if ecx==-1
				mov		ecx,-2
			.endif
			invoke FindTheText,ebx,lpText,fMC,fWW,eax,[esi].FINDTEXTEX.chrg.cpMin,ecx,1
			add		len,edx
		.else
			;Up
			xor		eax,eax
			test	fFlag,FR_IGNOREWHITESPACE
			.if !ZERO?
				inc		eax
			.endif
			invoke FindTheText,ebx,lpText,fMC,fWW,eax,[esi].FINDTEXTEX.chrg.cpMin,[esi].FINDTEXTEX.chrg.cpMax,-1
			add		len,edx
		.endif
		.if eax!=-1
			mov		[esi].FINDTEXTEX.chrgText.cpMin,eax
			mov		edx,len
			add		edx,eax
			mov		[esi].FINDTEXTEX.chrgText.cpMax,edx
		.endif
	.else
		mov		eax,-1
	.endif
	ret

FindTextEx endp

IsLine proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,lpszTest:DWORD
	LOCAL	tmpesi:DWORD
	LOCAL	fCmnt:DWORD
	LOCAL	espsave:DWORD
	LOCAL	esisave:DWORD

	mov		eax,esp
	sub		eax,4
	mov		espsave,eax
	mov		ebx,hMem
	mov		edi,nLine
	shl		edi,2
	mov		esi,lpszTest
	.if edi<[ebx].EDIT.rpLineFree && byte ptr [esi]
		.while byte ptr [esi]
			mov		esisave,esi
			mov		edi,nLine
			shl		edi,2
			call	TestLine
			.break .if eax!=-1
			mov		esi,esisave
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			mov		eax,-1
		.endw
	.else
		mov		eax,-1
	.endif
	ret

TestLine:
	xor		ecx,ecx
	mov		fCmnt,ecx
	add		edi,[ebx].EDIT.hLine
	mov		edi,[edi].LINE.rpChars
	add		edi,[ebx].EDIT.hChars
	test	[edi].CHARS.state,STATE_COMMENT
	.if !ZERO?
		mov		ax,[esi]
		.if [ebx].EDIT.ccmntblocks==1 && ax!="/*" && ax!="*/"
			jmp		Nf
		.elseif [ebx].EDIT.ccmntblocks==2 && ax!="/'" && ax!="'/"
			jmp		Nf
		.endif
	.else
		call	SkipSpc
		or		eax,eax
		jne		Nf
	.endif
  Nxt:
	mov		ax,[esi]
	.if ah
		.if ax==' $'
			call	SkipCmnt
			inc		esi
			call	SkipWord
			or		eax,eax
			jne		Nf
			mov		al,[esi]
			.if al==' '
				inc		esi
				call	SkipSpc
				call	SkipCmnt
				or		eax,eax
				jne		Nf
			.endif
		.elseif ax==' ?'
			call	SkipCmnt
			add		esi,2
			push	esi
			call	TestWord
			pop		esi
			or		eax,eax
			je		Found
			dec		esi
			call	SkipWord
			or		eax,eax
			jne		Nf
			mov		al,[esi]
			.if al==' '
				inc		esi
				call	SkipSpc
				call	SkipCmnt
				or		eax,eax
				jne		Nf
			.endif
		.elseif al=='%'
			call	SkipCmnt
			inc		esi
			call	OptSkipWord
			jmp		Nxt
		.elseif ax=="'/"
			; comment init
			.while ecx<[edi].CHARS.len
				movzx	eax,byte ptr [edi+ecx+sizeof CHARS]
				movzx	eax,byte ptr [eax+offset CharTab]
				.if eax==CT_STRING
					call	SkipString
				.elseif word ptr [edi+ecx+sizeof CHARS]=="'/"
					inc		ecx
					inc		fCmnt
				.elseif word ptr [edi+ecx+sizeof CHARS]=="/'"
					inc		ecx
					dec		fCmnt
				.elseif byte ptr [edi+ecx+sizeof CHARS]=="'" && !fCmnt
					mov		ecx,[edi].CHARS.len
				.endif
				inc		ecx
			.endw
			.if sdword ptr fCmnt>0
				xor		eax,eax
				jmp		Found
			.endif
			jmp		Nf
		.elseif ax=="/'"
			; Comment end
			.while ecx<[edi].CHARS.len
				movzx	eax,byte ptr [edi+ecx+sizeof CHARS]
				movzx	eax,byte ptr [eax+offset CharTab]
				.if eax==CT_STRING
					call	SkipString
				.elseif word ptr [edi+ecx+sizeof CHARS]=="/'"
					test	[edi].CHARS.state,STATE_COMMENT
					.if !ZERO?
						dec		fCmnt
					.endif
					inc		ecx
				.elseif word ptr [edi+ecx+sizeof CHARS]=="'/"
					inc		fCmnt
					inc		ecx
				.elseif byte ptr [edi+ecx+sizeof CHARS]=="'" && !fCmnt
					mov		ecx,[edi].CHARS.len
				.endif
				inc		ecx
			.endw
			.if sdword ptr fCmnt<0
				xor		eax,eax
				jmp		Found
			.endif
			jmp		Nf
		.elseif ax=="*/"
			; comment init
			.while ecx<[edi].CHARS.len
				movzx	esi,byte ptr [edi+ecx+sizeof CHARS]
				movzx	esi,byte ptr [esi+offset CharTab]
				.if esi==CT_STRING
					call	SkipString
				.elseif word ptr [edi+ecx+sizeof CHARS]=="*/"
					inc		ecx
					inc		fCmnt
				.elseif word ptr [edi+ecx+sizeof CHARS]=="/*"
					inc		ecx
					dec		fCmnt
				.endif
				inc		ecx
			.endw
			.if sdword ptr fCmnt>0
				xor		eax,eax
				jmp		Found
			.endif
			jmp		Nf
		.elseif ax=="/*"
			; Comment end
			.while ecx<[edi].CHARS.len
				.if word ptr [edi+ecx+sizeof CHARS]=="/*"
					dec		fCmnt
				.elseif word ptr [edi+ecx+sizeof CHARS]=="*/"
					inc		fCmnt
				.endif
				inc		ecx
			.endw
			.if sdword ptr fCmnt<0
				xor		eax,eax
				jmp		Found
			.endif
			jmp		Nf
		.endif
		call	SkipCmnt
		call	TestWord
		or		eax,eax
		jne		Nf
		xor		edx,edx
	.else
		call	SkipCmnt
		.while ecx<[edi].CHARS.len
			xor		edx,edx
			cmp		al,[edi+ecx+sizeof CHARS]
			.break .if ZERO?
			dec		edx
			movzx	esi,byte ptr [edi+ecx+sizeof CHARS]
			movzx	esi,byte ptr [esi+offset CharTab]
			.if esi==CT_CMNTCHAR
				.break
			.elseif esi==CT_CMNTDBLCHAR
				movzx	esi,byte ptr [edi+ecx+sizeof CHARS+1]
				movzx	esi,byte ptr [esi+offset CharTab]
				.break .if esi==CT_CMNTDBLCHAR
			.elseif esi==CT_STRING
				call	SkipString
			.endif
			inc		ecx
		.endw
	.endif
	mov		eax,edx
  Found:
	retn
  Nf:
	mov		eax,-1
	retn

SkipString:
	push	eax
	mov		al,[edi+ecx+sizeof CHARS]
	inc		ecx
	.while ecx<[edi].CHARS.len
		.break .if al==[edi+ecx+sizeof CHARS]
		inc		ecx
	.endw
	pop		eax
	retn

SkipCmnt:
	.if word ptr [edi+ecx+sizeof CHARS]=="'/"
		push	eax
		inc		ecx
		.while ecx<[edi].CHARS.len
			inc		ecx
			.break .if word ptr [edi+ecx+sizeof CHARS]=="/'"
		.endw
		.if word ptr [edi+ecx+sizeof CHARS]=="/'"
			add		ecx,2
		.endif
		call	SkipSpc
		pop		eax
	.endif
	retn

SkipSpc:
	.if ecx<[edi].CHARS.len
		mov		al,[edi+ecx+sizeof CHARS]
		.if al==VK_TAB || al==' ' || al==':' || (al=='*' && [ebx].EDIT.ccmntblocks!=1)
			inc		ecx
			jmp		SkipSpc
		.elseif al=='"'
			call	SkipString
			.if byte ptr [edi+ecx+sizeof CHARS]=='"'
				inc		ecx
			.endif
			jmp		SkipSpc
		.elseif al==byte ptr bracketcont
			.if byte ptr [edi+ecx+sizeof CHARS+1]==VK_RETURN
				inc		nLine
				mov		edi,nLine
				shl		edi,2
				.if edi<[ebx].EDIT.rpLineFree
					add		edi,[ebx].EDIT.hLine
					mov		edi,[edi].LINE.rpChars
					add		edi,[ebx].EDIT.hChars
					test	[edi].CHARS.state,STATE_COMMENT
					jne		SkipSpcNf
					xor		ecx,ecx
					jmp		SkipSpc
				.else
					jmp		SkipSpcNf
				.endif
			.endif
		.endif
		xor		eax,eax
	.else
		xor		eax,eax
		dec		eax
	.endif
	retn
SkipSpcNf:
	mov		esp,espsave
	jmp		Nf

OptSkipWord:
	push	ecx
	.while ecx<[edi].CHARS.len
		mov		al,[esi]
		inc		esi
		mov		ah,[edi+ecx+sizeof CHARS]
		inc		ecx
		.if al==VK_SPACE && (ah==VK_SPACE || ah==VK_TAB)
			pop		eax
			retn
		.endif
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		.if al!=ah
			.while byte ptr [esi-1]!=VK_SPACE
				inc		esi
			.endw
			.break
		.endif
	.endw
	pop		ecx
	retn

SkipWord:
	.if ecx<[edi].CHARS.len
		movzx	eax,byte ptr [edi+ecx+sizeof CHARS]
		.if eax!=VK_TAB && eax!=' ' && eax!=':'
			lea		eax,[eax+offset CharTab]
			mov		al,[eax]
			.if al==CT_CHAR || al==CT_HICHAR
				inc		ecx
				jmp		SkipWord
			.else
				.if al==CT_CMNTCHAR
					mov		ecx,[edi].CHARS.len
				.endif
				xor		eax,eax
				dec		eax
				retn
			.endif
		.endif
		xor		eax,eax
	.else
		xor		eax,eax
		dec		eax
	.endif
	retn

  @@:
	inc		esi
	inc		ecx
	mov		al,[esi]
	.if ecx>=[edi].CHARS.len && al
		xor		eax,eax
		dec		eax
		retn
	.endif
TestWord:
	mov		ax,[esi]
	or		al,al
	je		@f
	.if al==' '
		mov		ax,[edi+ecx+sizeof CHARS]
		.if al==' ' || al==VK_TAB
			call	SkipSpc
			call	SkipCmnt
			dec		ecx
			jmp		@b
		.elseif al=='('
			dec		ecx
			jmp		@b
		.else
			xor		eax,eax
			dec		eax
			retn
		.endif
	.elseif ax=='(#'
		inc		esi
		.while ecx<[edi].CHARS.len
			.break .if byte ptr [edi+ecx+sizeof CHARS]=='('
			inc		ecx
		.endw
		xor		eax,eax
		.if byte ptr [edi+ecx+sizeof CHARS]!='('
			dec		eax
		.endif
		retn
	.elseif ax=='$$'
		add		esi,3
		.while ecx<[edi].CHARS.len
			push	esi
			call	TestWord
			.if !eax
				pop		eax
				xor		eax,eax
				retn
			.endif
			pop		esi
			inc		ecx
		.endw
	.elseif ax=='!$'
		add		esi,3
		.while ecx<[edi].CHARS.len
			push	esi
			call	SkipSpc
			call	SkipCmnt
			call	TestWord
			.if !eax
				call	SkipSpc
				call	SkipCmnt
				pop		eax
				mov		al,[edi+ecx+sizeof CHARS]
				.if al==VK_RETURN || ecx==[edi].CHARS.len
					xor		eax,eax
				.else
					movzx	eax,al
					lea		eax,[eax+offset CharTab]
					mov		al,[eax]
					.if al==CT_CMNTCHAR
						xor		eax,eax
					.else
						xor		eax,eax
						dec		eax
					.endif
				.endif
				retn
			.endif
			pop		esi
			inc		ecx
		.endw
	.elseif al=='*'
		xor		eax,eax
		push	ecx
		movzx	ecx,byte ptr [edi+ecx+sizeof CHARS]
		movzx	ecx,byte ptr [ecx+offset CharTab]
		.if ecx!=CT_CHAR
			dec		eax
		.endif
		pop		ecx
		retn
	.elseif al=='!'
		.if byte ptr [esi-1]!=' '
			mov		al,[edi+ecx+sizeof CHARS]
			.if al!=' ' && al!=VK_TAB && al!=VK_RETURN
				xor		eax,eax
				dec		eax
				retn
			.endif
		.endif
		call	SkipSpc
		call	SkipCmnt
		.if ecx==[edi].CHARS.len
			xor		eax,eax
			retn
		.endif
		inc		esi
		mov		tmpesi,esi
		mov		ax,[esi]
		.while TRUE
			push	ecx
			call	TestWord
			pop		edx
			inc		eax
		  .break .if eax
			mov		esi,tmpesi
			mov		ecx,edx
			call	SkipWord
			.if eax
				inc		ecx
			.endif
			call	SkipSpc
			call	SkipCmnt
			xor		eax,eax
		  .break .if ecx>=[edi].CHARS.len
		.endw
		retn
	.elseif ax==' $'
		call	SkipWord
		call	SkipSpc
		call	SkipCmnt
		inc		esi
		inc		esi
		jmp		TestWord
	.endif
	mov		ah,[edi+ecx+sizeof CHARS]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,'$'
	je		@f
	cmp		al,ah
	je		@b
	xor		eax,eax
	dec		eax
	retn
  @@:
	.if al=='$'
		xor		eax,eax
		.if ecx<[edi].CHARS.len
			push	ecx
			movzx	ecx,byte ptr [edi+ecx+sizeof CHARS]
			movzx	ecx,byte ptr [ecx+offset CharTab]
			.if ecx==CT_CHAR || ecx==CT_HICHAR
				inc		eax
			.endif
			pop		ecx
		.endif
		dec		eax
	.else
		xor		eax,eax
		.if ecx<[edi].CHARS.len
			push	ecx
			movzx	ecx,byte ptr [edi+ecx+sizeof CHARS]
			movzx	ecx,byte ptr [ecx+offset CharTab]
			.if ecx==CT_CHAR || ecx==CT_HICHAR
				dec		eax
			.endif
			pop		ecx
		.elseif ecx>[edi].CHARS.len
			dec		eax
		.endif
	.endif
	retn

IsLine endp

SetBookMark proc uses ebx,hMem:DWORD,nLine:DWORD,nType:DWORD

	mov		ebx,hMem
	mov		edx,nLine
	shl		edx,2
	xor		eax,eax
	.if edx<[ebx].EDIT.rpLineFree
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		eax,nType
		shl		eax,4
		and		eax,STATE_BMMASK
		and		[edx].CHARS.state,-1 xor STATE_BMMASK
		or		[edx].CHARS.state,eax
		inc		nBmid
		test	[edx].CHARS.state,STATE_HIDDEN
		.if ZERO?
			mov		eax,nBmid
			mov		[edx].CHARS.bmid,eax
		.endif
	.endif
	ret

SetBookMark endp

GetBookMark proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	xor		eax,eax
	dec		eax
	mov		edx,nLine
	shl		edx,2
	.if edx<[ebx].EDIT.rpLineFree
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		eax,[edx].CHARS.state
		and		eax,STATE_BMMASK
		shr		eax,4
	.endif
	ret

GetBookMark endp

ClearBookMarks proc uses ebx esi edi,hMem:DWORD,nType:DWORD

	mov		ebx,hMem
	and		nType,15
	mov		eax,nType
	shl		eax,4
	xor		edi,edi
	.while edi<[ebx].EDIT.rpLineFree
		mov		edx,edi
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		ecx,[edx].CHARS.state
		and		ecx,STATE_BMMASK
		.if eax==ecx
			and		[edx].CHARS.state,-1 xor STATE_BMMASK
			test	[edx].CHARS.state,STATE_HIDDEN
			.if ZERO?
				mov		[edx].CHARS.bmid,0
			.endif
		.endif
		add		edi,sizeof LINE
	.endw
	ret

ClearBookMarks endp

NextBookMark proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,nType:DWORD
	LOCAL	fExpand:DWORD

	mov		ebx,hMem
	mov		eax,nType
	and		nType,15
	and		eax,80000000h
	mov		fExpand,eax
	mov		edi,nLine
	inc		edi
	shl		edi,2
	xor		eax,eax
	dec		eax
	.while edi<[ebx].EDIT.rpLineFree
		mov		edx,edi
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		ecx,[edx].CHARS.state
		and		ecx,STATE_BMMASK
		shr		ecx,4
		.if ecx==nType
			mov		eax,edi
			shr		eax,2
			.break
		.endif
		add		edi,sizeof LINE
	.endw
	ret

NextBookMark endp

NextBreakpoint proc uses ebx edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		edi,nLine
	inc		edi
	shl		edi,2
	xor		eax,eax
	dec		eax
	.while edi<[ebx].EDIT.rpLineFree
		mov		edx,edi
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		test	[edx].CHARS.state,STATE_BREAKPOINT
		.if !ZERO?
			mov		eax,edi
			shr		eax,2
			.break
		.endif
		add		edi,sizeof LINE
	.endw
	ret

NextBreakpoint endp

NextError proc uses ebx edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		edi,nLine
	inc		edi
	shl		edi,2
	xor		eax,eax
	dec		eax
	.while edi<[ebx].EDIT.rpLineFree
		mov		edx,edi
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		.if [edx].CHARS.errid
			mov		eax,edi
			shr		eax,2
			.break
		.endif
		add		edi,sizeof LINE
	.endw
	ret

NextError endp

PreviousBookMark proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,nType:DWORD
	LOCAL	fExpand:DWORD

	mov		ebx,hMem
	mov		eax,nType
	and		nType,15
	and		eax,80000000h
	mov		fExpand,eax
	xor		eax,eax
	dec		eax
	mov		edi,nLine
	dec		edi
	shl		edi,2
	.while sdword ptr edi>=0
	  @@:
		mov		edx,edi
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		ecx,[edx].CHARS.state
		and		ecx,STATE_BMMASK
		shr		ecx,4
		.if ecx==nType
			mov		eax,edi
			shr		eax,2
			.break
		.endif
		sub		edi,sizeof LINE
	.endw
	ret

PreviousBookMark endp

LockLine proc uses ebx,hMem:DWORD,nLine:DWORD,fLock:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fLock
			or		[eax].CHARS.state,STATE_LOCKED
		.else
			and		[eax].CHARS.state,-1 xor STATE_LOCKED
		.endif
	.endif
	ret

LockLine endp

IsLineLocked proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	xor		eax,eax
	test	[ebx].EDIT.fstyle,STYLE_READONLY
	.if ZERO?
		mov		edx,nLine
		shl		edx,2
		.if edx<[ebx].EDIT.rpLineFree
			add		edx,[ebx].EDIT.hLine
			mov		edx,[edx].LINE.rpChars
			add		edx,[ebx].EDIT.hChars
			mov		eax,[edx].CHARS.state
			and		eax,STATE_LOCKED
		.endif
	.else
		inc		eax
	.endif
	ret

IsLineLocked endp

HideLine proc uses ebx,hMem:DWORD,nLine:DWORD,fHide:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fHide
			test	[eax].CHARS.state,STATE_HIDDEN
			.if ZERO?
				mov		ecx,[eax].CHARS.len
				.if byte ptr [eax+ecx+sizeof CHARS-1]==0Dh
					or		[eax].CHARS.state,STATE_HIDDEN
					inc		[ebx].EDIT.nHidden
					call	SetYP
					xor		eax,eax
					inc		eax
					jmp		Ex
				.endif
			.endif
		.else
			test	[eax].CHARS.state,STATE_HIDDEN
			.if !ZERO?
				and		[eax].CHARS.state,-1 xor STATE_HIDDEN
				dec		[ebx].EDIT.nHidden
				call	SetYP
				xor		eax,eax
				inc		eax
				jmp		Ex
			.endif
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

SetYP:
	mov		edx,nLine
	xor		eax,eax
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
	retn

HideLine endp

IsLineHidden proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		mov		eax,[eax].CHARS.state
		and		eax,STATE_HIDDEN
	.else
		xor		eax,eax
	.endif
	ret

IsLineHidden endp

NoBlockLine proc uses ebx,hMem:DWORD,nLine:DWORD,fNoBlock:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fNoBlock
			or		[eax].CHARS.state,STATE_NOBLOCK
		.else
			and		[eax].CHARS.state,-1 xor STATE_NOBLOCK
		.endif
	.endif
	ret

NoBlockLine endp

IsLineNoBlock proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		mov		eax,[eax].CHARS.state
		and		eax,STATE_NOBLOCK
	.else
		xor		eax,eax
	.endif
	ret

IsLineNoBlock endp

AltHiliteLine proc uses ebx,hMem:DWORD,nLine:DWORD,fAltHilite:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fAltHilite
			or		[eax].CHARS.state,STATE_ALTHILITE
		.else
			and		[eax].CHARS.state,-1 xor STATE_ALTHILITE
		.endif
	.endif
	ret

AltHiliteLine endp

IsLineAltHilite proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		mov		eax,[eax].CHARS.state
		and		eax,STATE_ALTHILITE
	.else
		xor		eax,eax
	.endif
	ret

IsLineAltHilite endp

SetBreakpoint proc uses ebx,hMem:DWORD,nLine:DWORD,fBreakpoint:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fBreakpoint
			or		[eax].CHARS.state,STATE_BREAKPOINT
		.else
			and		[eax].CHARS.state,-1 xor STATE_BREAKPOINT
		.endif
	.endif
	ret

SetBreakpoint endp

SetError proc uses ebx,hMem:DWORD,nLine:DWORD,nErrID:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		mov		edx,nErrID
		mov		[eax].CHARS.errid,edx
	.endif
	ret

SetError endp

GetError proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		edx,nLine
	shl		edx,2
	xor		eax,eax
	.if edx<[ebx].EDIT.rpLineFree
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		eax,[edx].CHARS.errid
	.endif
	ret

GetError endp

SetRedText proc uses ebx,hMem:DWORD,nLine:DWORD,fRed:DWORD

	mov		ebx,hMem
	mov		eax,nLine
	shl		eax,2
	.if eax<[ebx].EDIT.rpLineFree
		add		eax,[ebx].EDIT.hLine
		mov		eax,[eax].LINE.rpChars
		add		eax,[ebx].EDIT.hChars
		.if fRed
			or		[eax].CHARS.state,STATE_REDTEXT
		.else
			and		[eax].CHARS.state,-1 xor STATE_REDTEXT
		.endif
	.endif
	ret

SetRedText endp

GetLineState proc uses ebx,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		edx,nLine
	shl		edx,2
	xor		eax,eax
	.if edx<[ebx].EDIT.rpLineFree
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		eax,[edx].CHARS.state
	.endif
	ret

GetLineState endp

IsSelectionLocked proc uses ebx,hMem:DWORD,cpMin:DWORD,cpMax:DWORD
	LOCAL	nLineMax:DWORD

	mov		ebx,hMem
	mov		eax,cpMin
	.if eax>cpMax
		xchg	eax,cpMax
		mov		cpMin,eax
	.endif
	invoke GetCharPtr,ebx,cpMax
	mov		nLineMax,edx
	invoke GetCharPtr,ebx,cpMin
	.while edx<=nLineMax
		push	edx
		invoke IsLineLocked,ebx,edx
		pop		edx
		or		eax,eax
		jne		Ex
		inc		edx
	.endw
  Ex:
	ret

IsSelectionLocked endp


TrimSpace proc uses ebx edi,hMem:DWORD,nLine:DWORD,fLeft:DWORD
	LOCAL	cp:DWORD

	mov		ebx,hMem
	mov		edi,nLine
	invoke GetCpFromLine,ebx,edi
	mov		cp,eax
	shl		edi,2
	xor		edx,edx
	.if edi<[ebx].EDIT.rpLineFree
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		mov		edx,[edi].CHARS.len
		.if edx
			.if fLeft
				;Left trim (Not implemented)
				xor		ecx,ecx
			.else
				;Right trim
				push	edx
				mov		al,[edi+edx+sizeof CHARS-1]
				push	eax
				.if al==0Dh
					dec		edx
				.endif
				mov		ecx,edx
			  @@:
				mov		al,[edi+ecx+sizeof CHARS-1]
				.if al==' ' || al==VK_TAB
					dec		ecx
					jne		@b
				.endif
				mov		eax,cp
				add		eax,ecx
				sub		edx,ecx
				push	edx
				lea		edx,[edi+ecx+sizeof CHARS]
				pop		ecx
				.if ecx
					push	ecx
					invoke SaveUndo,ebx,UNDO_DELETEBLOCK,eax,edx,ecx
					pop		ecx
				.endif
				pop		eax
				.if ecx
					sub		[edi].CHARS.len,ecx
					mov		edx,[edi].CHARS.len
					.if al==0Dh
						mov		[edi+edx+sizeof CHARS-1],al
					.endif
					and		[edi].CHARS.state,-1 xor (STATE_CHANGED or STATE_CHANGESAVED)
					or		[edi].CHARS.state,STATE_CHANGED
				.endif
				pop		edx
				sub		edx,ecx
			.endif
		.endif
	.endif
	.if ecx
		push	edx
		xor		eax,eax
		mov		[ebx].EDIT.edta.topyp,eax
		mov		[ebx].EDIT.edta.topln,eax
		mov		[ebx].EDIT.edta.topcp,eax
		mov		[ebx].EDIT.edtb.topyp,eax
		mov		[ebx].EDIT.edtb.topln,eax
		mov		[ebx].EDIT.edtb.topcp,eax
		.if ![ebx].EDIT.fChanged
			mov		[ebx].EDIT.fChanged,TRUE
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		.endif
		invoke GetTopFromYp,ebx,[ebx].EDIT.edta.hwnd,[ebx].EDIT.edta.cpy
		invoke GetTopFromYp,ebx,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.edtb.cpy
		invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,nLine
		invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,nLine
		inc		[ebx].EDIT.nchange
		pop		edx
	.endif
  Ex:
	mov		eax,edx
	ret

TrimSpace endp

SkipSpace proc uses ebx esi,hMem:DWORD,cp:DWORD,fLeft:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
	.if !fLeft
	  @@:
		.if edx<[esi].CHARS.len
			mov		al,[esi+edx+sizeof CHARS]
			.if al==' ' || al==VK_TAB
				inc		edx
				jmp		@b
			.endif
		.endif
	.else
	  @@:
		.if edx
			mov		al,[esi+edx+sizeof CHARS-1]
			.if al==' ' || al==VK_TAB
				dec		edx
				jmp		@b
			.endif
		.endif
	.endif
	mov		eax,[ebx].EDIT.cpLine
	add		eax,edx
	ret

SkipSpace endp

SkipWhiteSpace proc uses ebx esi,hMem:DWORD,cp:DWORD,fLeft:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
	.if !fLeft
	  @@:
		.if edx<[esi].CHARS.len
			mov		al,[esi+edx+sizeof CHARS]
			invoke IsChar
			.if al!=1
				inc		edx
				jmp		@b
			.endif
		.endif
	.else
	  @@:
		.if edx
			mov		al,[esi+edx+sizeof CHARS]
			invoke IsChar
			.if al!=1
				dec		edx
				jmp		@b
			.endif
		.endif
	.endif
	mov		eax,[ebx].EDIT.cpLine
	add		eax,edx
	ret

SkipWhiteSpace endp

GetWordStart proc uses ebx esi,hMem:DWORD,cp:DWORD,nType:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
  @@:
	.if edx
		mov		al,[esi+edx+sizeof CHARS-1]
		.if al=='.' && nType
			dec		edx
			jmp		@b
		.elseif al=='>' && nType==2 && edx>2
			.if byte ptr [esi+edx+sizeof CHARS-2]=='-'
				dec		edx
				dec		edx
				jmp		@b
			.endif
		.elseif al==')' && nType==2
			xor		ecx,ecx
			.while edx>1
				mov		al,[esi+edx+sizeof CHARS-1]
				.if al==")"
					inc		ecx
				.elseif al=='('
					dec		ecx
					.if !ecx
						dec	edx
						.break
					.endif
				.endif
				dec		edx
			.endw
			jmp		@b
		.else
			invoke IsChar
		.endif
		.if al==1
			dec		edx
			jmp		@b
		.endif
	.endif
	mov		eax,[ebx].EDIT.cpLine
	add		eax,edx
	ret

GetWordStart endp

GetLineStart proc uses ebx,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		eax,[ebx].EDIT.cpLine
	ret

GetLineStart endp

GetTabPos proc uses ebx esi,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
	xor		eax,eax
	xor		ecx,ecx
	.while sdword ptr ecx<edx
		inc		eax
		.if byte ptr [esi+ecx+sizeof CHARS]==VK_TAB || eax==[ebx].EDIT.nTab
			xor		eax,eax
		.endif
		inc		ecx
	.endw
	ret

GetTabPos endp

GetWordEnd proc uses ebx esi,hMem:DWORD,cp:DWORD,nType:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
  @@:
	.if edx<[esi].CHARS.len
		mov		al,[esi+edx+sizeof CHARS]
		.if al=='.' && nType
			inc		edx
			jmp		@b
		.elseif al=='-' && nType==2 && byte ptr [esi+edx+sizeof CHARS+1]=='>'
			inc		edx
			inc		edx
			jmp		@b
		.elseif al=='(' && nType==2
			xor		ecx,ecx
			.while edx<[esi].CHARS.len
				mov		al,[esi+edx+sizeof CHARS]
				.if al=="("
					inc		ecx
				.elseif al==')'
					dec		ecx
					.if !ecx
						inc		edx
						.break
					.endif
				.endif
				inc		edx
			.endw
			jmp		@b
		.else
			invoke IsChar
		.endif
		.if al==1
			inc		edx
			jmp		@b
		.endif
	.endif
	mov		eax,[ebx].EDIT.cpLine
	add		eax,edx
	ret


GetWordEnd endp

GetLineEnd proc uses ebx esi,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	mov		edx,eax
  @@:
	.if edx<[esi].CHARS.len
		mov		al,[esi+edx+sizeof CHARS]
		invoke IsChar
		.if al==1
			inc		edx
			jmp		@b
		.endif
	.endif
	mov		eax,[ebx].EDIT.cpLine
	add		eax,[esi].CHARS.len
	dec		eax
	.if byte ptr [esi+eax+sizeof CHARS]==VK_RETURN
		dec		eax
	.endif
	ret

GetLineEnd endp

StreamIn proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	hCMem:DWORD
	LOCAL	dwRead:DWORD
	LOCAL	fUnicode:DWORD

	mov		ebx,hMem
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM*3+4096
	mov     hCMem,eax
	invoke GlobalLock,hCMem
	xor		edi,edi
	mov		dwRead,edi
	mov		fUnicode,edi
  @@:
	mov		esi,hCMem
	add		esi,MAXSTREAM
	call	ReadChars
	or		eax,eax
	jne		@f
	.if dwRead
		.if !fUnicode
			movzx	eax,word ptr [esi]
			.if eax==0FEFFh && dwRead>=2
				;Unicode
				mov		eax,2
				mov		[ebx].EDIT.funicode,TRUE
				mov		fUnicode,eax
				add		esi,eax
				sub		dwRead,eax
			.else
				mov		fUnicode,1
				mov		[ebx].EDIT.funicode,FALSE
			.endif
		.endif
		.if fUnicode==2
			mov		edx,dwRead
			shr		edx,1
			invoke WideCharToMultiByte,CP_ACP,0,esi,edx,hCMem,MAXSTREAM,NULL,NULL
			mov		dwRead,eax
			mov		esi,hCMem
		.endif
		xor		ecx,ecx
		.while ecx<dwRead
			push	ecx
			movzx	eax,byte ptr [esi+ecx]
			.if eax!=0Ah
				invoke InsertChar,ebx,edi,eax
			.endif
			pop		ecx
			inc		edi
			inc		ecx
		.endw
		jmp		@b
	.endif
  @@:
	invoke GlobalUnlock,hCMem
	invoke GlobalFree,hCMem
	mov		[ebx].EDIT.nHidden,0
	ret

ReadChars:
	mov		edx,lParam
	mov		[edx].EDITSTREAM.dwError,0
	lea		eax,dwRead
	push	eax
	mov		eax,MAXSTREAM
	push	eax
	mov		eax,esi
	push	eax
	push	[edx].EDITSTREAM.dwCookie
	call	[edx].EDITSTREAM.pfnCallback
	retn

StreamIn endp

StreamOut proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	dwWrite:DWORD
	LOCAL	hCMem:DWORD
	LOCAL	nChars:DWORD

	mov		ebx,hMem
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM*3+4096
	mov     hCMem,eax
	invoke GlobalLock,hCMem
	mov		esi,[ebx].EDIT.hLine
	.if [ebx].EDIT.funicode
		; Save as unicode
		mov		eax,hCMem
		mov		word ptr [eax],0FEFFh
		mov		nChars,2
		call	StreamAnsi
	  @@:
		call	FillCMem
		or		ecx,ecx
		je		Ex
		call	StreamUnicode
		or		eax,eax
		je		@b
	.else
		; Save as ansi
	  @@:
		call	FillCMem
		or		ecx,ecx
		je		Ex
		call	StreamAnsi
		or		eax,eax
		je		@b
	.endif
  Ex:
	invoke GlobalUnlock,hCMem
	invoke GlobalFree,hCMem
	ret

StreamUnicode:
	mov		eax,hCMem
	add		eax,MAXSTREAM+1024
	invoke MultiByteToWideChar,CP_ACP,0,hCMem,nChars,eax,MAXSTREAM+1024
	mov		edx,lParam
	mov		[edx].EDITSTREAM.dwError,0
	lea		eax,dwWrite
	push	eax
	mov		eax,nChars
	shl		eax,1
	push	eax
	mov		eax,hCMem
	add		eax,MAXSTREAM+1024
	push	eax
	mov		eax,[edx].EDITSTREAM.dwCookie
	push	eax
	call	[edx].EDITSTREAM.pfnCallback
	retn

StreamAnsi:
	mov		edx,lParam
	mov		[edx].EDITSTREAM.dwError,0
	lea		eax,dwWrite
	push	eax
	push	nChars
	push	hCMem
	mov		eax,[edx].EDITSTREAM.dwCookie
	push	eax
	call	[edx].EDITSTREAM.pfnCallback
	retn

FillCMem:
	xor		ecx,ecx
	xor		edx,edx
	mov		nChars,ecx
	mov		eax,esi
	sub		eax,[ebx].EDIT.hLine
	.if eax<[ebx].EDIT.rpLineFree
		push	esi
		mov		edi,hCMem
		mov		esi,[esi].LINE.rpChars
		add		esi,[ebx].EDIT.hChars
		.while ecx<[esi].CHARS.len
			mov		al,[esi+ecx+sizeof CHARS]
			mov		[edi],al
			inc		ecx
			inc		edi
			inc		nChars
			.if al==0Dh
				mov		byte ptr [edi],0Ah
				inc		edx
				inc		edi
				inc		nChars
			.endif
			.if nChars>=MAXSTREAM
				pushad
				.if [ebx].EDIT.funicode
					call	StreamUnicode
				.else
					call	StreamAnsi
				.endif
				popad
				mov		edi,hCMem
				mov		nChars,0
			.endif
		.endw
		pop		esi
		add		esi,sizeof LINE
	.endif
	add		ecx,edx
	retn


StreamOut endp

HiliteLine proc uses ebx,hMem:DWORD,nLine:DWORD,nColor:DWORD

	mov		ebx,hMem
	mov		edx,nLine
	shl		edx,2
	.if edx<[ebx].EDIT.rpLineFree
		add		edx,[ebx].EDIT.hLine
		mov		edx,[edx].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		and		[edx].CHARS.state,-1 xor STATE_HILITEMASK
		mov		eax,nColor
		and		eax,STATE_HILITEMASK
		or		[edx].CHARS.state,eax
		invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,nLine
		invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,nLine
	.endif
	xor		eax,eax
	ret

HiliteLine endp

SelChange proc uses ebx,hMem:DWORD,nType:DWORD
	LOCAL	sc:RASELCHANGE

	mov		ebx,hMem
	.if [ebx].EDIT.cpbrst!=-1
		mov		[ebx].EDIT.cpbrst,-1
		mov		[ebx].EDIT.cpbren,-1
		invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
		invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	.endif
	invoke GetCharPtr,hMem,[ebx].EDIT.cpMin
	mov		edx,[ebx].EDIT.ID
	mov		eax,[ebx].EDIT.hwnd
	mov		sc.nmhdr.hwndFrom,eax
	mov		sc.nmhdr.idFrom,edx
	mov		sc.nmhdr.code,EN_SELCHANGE
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		mov		eax,[ebx].EDIT.cpMin
		mov		sc.chrg.cpMin,eax
		mov		eax,[ebx].EDIT.cpMax
		mov		sc.chrg.cpMax,eax
	.else
		mov		eax,[ebx].EDIT.cpLine
		add		eax,[ebx].EDIT.blrg.clMin
		mov		sc.chrg.cpMin,eax
		mov		sc.chrg.cpMax,eax
	.endif
	mov		eax,nType
	mov		sc.seltyp,ax
	mov		eax,[ebx].EDIT.line
	mov		sc.line,eax
	mov		eax,[ebx].EDIT.cpLine
	mov		sc.cpLine,eax
	mov		eax,[ebx].EDIT.rpChars
	add		eax,[ebx].EDIT.hChars
	mov		sc.lpLine,eax
	mov		eax,[ebx].EDIT.rpLineFree
	shr		eax,2
	dec		eax
	mov		sc.nlines,eax
	mov		eax,[ebx].EDIT.nHidden
	mov		sc.nhidden,eax
	mov		eax,[ebx].EDIT.nchange
	sub		eax,[ebx].EDIT.nlastchange
	.if eax
		add		[ebx].EDIT.nlastchange,eax
		mov		eax,TRUE
	.endif
	mov		sc.fchanged,eax
	mov		ecx,[ebx].EDIT.nPageBreak
	xor		eax,eax
	.if ecx
		mov		eax,[ebx].EDIT.line
		xor		edx,edx
		div		ecx
	.endif
	mov		sc.npage,eax
	mov		eax,[ebx].EDIT.nWordGroup
	mov		sc.nWordGroup,eax
	.if ![ebx].EDIT.nsplitt
		mov		eax,[ebx].EDIT.cpMin
		mov		[ebx].EDIT.edta.cp,eax
		mov		[ebx].EDIT.edtb.cp,eax
	.endif
	mov		eax,[ebx].EDIT.line
	.if eax!=[ebx].EDIT.lastline
		.if [ebx].EDIT.fhilite
			invoke HiliteLine,ebx,[ebx].EDIT.lastline,0
			invoke HiliteLine,ebx,[ebx].EDIT.line,[ebx].EDIT.fhilite
		.endif
		mov		eax,[ebx].EDIT.line
		mov		[ebx].EDIT.lastline,eax
	.endif
	invoke SendMessage,[ebx].EDIT.hpar,WM_NOTIFY,[ebx].EDIT.ID,addr sc
	ret

SelChange endp

AutoIndent proc uses ebx esi,hMem:DWORD
	LOCAL	nLine:DWORD

	mov		ebx,hMem
	invoke GetLineFromCp,ebx,[ebx].EDIT.cpMin
	.if eax
		mov		nLine,eax
		xor		edx,edx
		push	[ebx].EDIT.fOvr
		mov		[ebx].EDIT.fOvr,FALSE
	  @@:
		mov		eax,nLine
		mov		esi,[ebx].EDIT.hLine
		lea		esi,[esi+eax*sizeof LINE-sizeof LINE]
		mov		esi,[esi].LINE.rpChars
		add		esi,[ebx].EDIT.hChars
		.if edx<[esi].CHARS.len
			movzx	eax,byte ptr [esi+edx+sizeof CHARS]
			.if al==' ' || al==VK_TAB
				push	edx
				push	eax
				invoke InsertChar,ebx,[ebx].EDIT.cpMin,eax
				pop		eax
				invoke SaveUndo,ebx,UNDO_INSERT,[ebx].EDIT.cpMin,eax,1
				mov		eax,[ebx].EDIT.cpMin
				inc		eax
				mov		[ebx].EDIT.cpMin,eax
				mov		[ebx].EDIT.cpMax,eax
				pop		edx
				inc		edx
				jmp		@b
			.endif
		.endif
		pop		[ebx].EDIT.fOvr
	.endif
	ret

AutoIndent endp

IsCharPos proc uses ebx esi,hMem:DWORD,cp:DWORD
	LOCAL	nMax:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	mov		nMax,eax
	mov		esi,[ebx].EDIT.rpChars
	add		esi,[ebx].EDIT.hChars
	test	[esi].CHARS.state,STATE_COMMENT
	.if ZERO?
		xor		ecx,ecx
		.while ecx<nMax
			.if [ebx].EDIT.ccmntblocks==1 && word ptr [esi+ecx+sizeof CHARS]=="*/"
				add		ecx,2
				.while ecx<nMax
					.break .if word ptr [esi+ecx+sizeof CHARS]=="/*"
					inc		ecx
				.endw
				.if word ptr [esi+ecx+sizeof CHARS]=="/*"
					add		ecx,2
				.else
					;On comment block
					mov		eax,1
					jmp		Ex
				.endif
			.elseif [ebx].EDIT.ccmntblocks==2 && word ptr [esi+ecx+sizeof CHARS]=="'/"
				add		ecx,2
				.while ecx<nMax
					.break .if word ptr [esi+ecx+sizeof CHARS]=="/'"
					inc		ecx
				.endw
				.if word ptr [esi+ecx+sizeof CHARS]=="/'"
					add		ecx,2
				.else
					;On comment block
					mov		eax,1
					jmp		Ex
				.endif
			.else
				movzx	eax,byte ptr [esi+ecx+sizeof CHARS]
				mov		al,byte ptr [eax+offset CharTab]
				.if al==CT_CMNTCHAR
					mov		eax,2
					jmp		Ex
				.elseif al==CT_CMNTDBLCHAR
					mov		al,byte ptr [esi+ecx+sizeof CHARS]
					mov		ah,byte ptr [esi+ecx+sizeof CHARS+1]
					.if al==ah || ah=='*'
						mov		eax,2
						jmp		Ex
					.endif
				.elseif al==CT_STRING
					mov		al,byte ptr [esi+ecx+sizeof CHARS]
					.while ecx<nMax
						inc		ecx
						.break .if al==byte ptr [esi+ecx+sizeof CHARS]
					.endw
					.if ecx>=nMax
						mov		eax,3
						jmp		Ex
					.endif
				.endif
				inc		ecx
			.endif
		.endw
		xor		eax,eax
	.else
		;On comment block
		mov		eax,1
	.endif
  Ex:
	ret

IsCharPos endp

BracketMatchRight proc uses ebx esi edi,hMem:DWORD,nChr:DWORD,nMatch:DWORD,cp:DWORD
	LOCAL	nCount:DWORD

	mov		ebx,hMem
	mov		nCount,0
	invoke GetCharPtr,ebx,cp
	mov		edx,eax
	mov		edi,[ebx].EDIT.hChars
	add		edi,[ebx].EDIT.rpChars
	.while edx<=[edi].CHARS.len
		mov		al,byte ptr nMatch
		mov		ah,byte ptr nChr
		mov		cl,byte ptr bracketcont
		mov		ch,byte ptr bracketcont+1
		.if al==byte ptr [edi+edx+sizeof CHARS]
			push	edx
			invoke IsCharPos,ebx,cp
			pop		edx
			.if !eax
				dec		nCount
				.if ZERO?
					mov		eax,edx
					add		eax,[ebx].EDIT.cpLine
					ret
				.endif
			.endif
		.elseif ah==byte ptr [edi+edx+sizeof CHARS]
			push	edx
			invoke IsCharPos,ebx,cp
			pop		edx
			.if !eax
				inc		nCount
			.endif
		.elseif (cl==byte ptr [edi+edx+sizeof CHARS] || ch==byte ptr [edi+edx+sizeof CHARS]) && edx<=[edi].CHARS.len
			.if byte ptr [edi+edx+sizeof CHARS]!=VK_RETURN
				push	edx
				invoke IsCharPos,ebx,cp
				pop		edx
				inc		edx
				inc		cp
				.if !eax
					.while (byte ptr [edi+edx+sizeof CHARS]==VK_SPACE || byte ptr [edi+edx+sizeof CHARS]==VK_TAB) && edx<[edi].CHARS.len
						inc		edx
						inc		cp
					.endw
				.endif
				.if byte ptr [edi+edx+sizeof CHARS]==VK_RETURN
					inc		cp
					mov		eax,cp
					invoke GetCharPtr,ebx,eax
					mov		edx,eax
					mov		edi,[ebx].EDIT.hChars
					add		edi,[ebx].EDIT.rpChars
					xor		edx,edx
				.endif
			.else
				inc		cp
				mov		eax,cp
				invoke GetCharPtr,ebx,eax
				mov		edx,eax
				mov		edi,[ebx].EDIT.hChars
				add		edi,[ebx].EDIT.rpChars
				xor		edx,edx
			.endif
			dec		edx
			dec		cp
		.endif
		inc		edx
		inc		cp
	.endw
	xor		eax,eax
	dec		eax
	ret

BracketMatchRight endp

BracketMatchLeft proc uses ebx esi edi,hMem:DWORD,nChr:DWORD,nMatch:DWORD,cp:DWORD
	LOCAL	nCount:DWORD

	mov		ebx,hMem
	mov		nCount,0
	push	cp
	invoke GetCharPtr,ebx,cp
	mov		edx,eax
	mov		edi,[ebx].EDIT.hChars
	add		edi,[ebx].EDIT.rpChars
	.while sdword ptr edx>=0
		mov		al,byte ptr nMatch
		mov		ah,byte ptr nChr
		.if al==byte ptr [edi+edx+sizeof CHARS]
			push	edx
			invoke IsCharPos,ebx,cp
			pop		edx
			.if !eax
				dec		nCount
				.if ZERO?
					mov		eax,edx
					add		eax,[ebx].EDIT.cpLine
					jmp		Ex
				.endif
			.endif
		.elseif ah==byte ptr [edi+edx+sizeof CHARS]
			push	edx
			invoke IsCharPos,ebx,cp
			pop		edx
			.if !eax
				inc		nCount
			.endif
		.endif
		.if !edx && [ebx].EDIT.line
			dec		cp
			invoke GetCharPtr,ebx,cp
			mov		edx,eax
			mov		edi,[ebx].EDIT.hChars
			add		edi,[ebx].EDIT.rpChars
			.while (byte ptr [edi+edx+sizeof CHARS]==VK_SPACE || byte ptr [edi+edx+sizeof CHARS]==VK_TAB) && edx!=0
				dec		edx
				dec		cp
			.endw
			push	edx
			invoke IsCharPos,ebx,cp
			pop		edx
			.if !eax
				.if byte ptr bracketcont!=VK_RETURN
					.if edx
						dec		edx
						mov		al,byte ptr [edi+edx+sizeof CHARS]
						.if al!=byte ptr bracketcont && al!=byte ptr bracketcont+1
							.break
						.endif
					.endif
				.endif
			.endif
			inc		cp
			inc		edx
		.endif
		dec		edx
		dec		cp
	.endw
	xor		eax,eax
	dec		eax
  Ex:
	pop		cp
	push	eax
	invoke GetCharPtr,ebx,cp
	pop		eax
	ret

BracketMatchLeft endp

BracketMatch proc uses ebx,hMem:DWORD,nChr:DWORD,cp:DWORD

	mov		ebx,hMem
	.if [ebx].EDIT.cpbrst!=-1 || [ebx].EDIT.cpbren!=-1
		invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
		invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
		xor		eax,eax
		dec		eax
		mov		[ebx].EDIT.cpbrst,eax
		mov		[ebx].EDIT.cpbren,eax
	.endif
	mov		al,byte ptr nChr
	xor		ecx,ecx
	.while byte ptr bracketstart[ecx]
		.if al==bracketstart[ecx]
			push	ecx
			invoke IsCharPos,ebx,cp
			pop		ecx
			or		eax,eax
			jne		Ex
			movzx	eax,byte ptr bracketend[ecx]
			invoke BracketMatchRight,ebx,nChr,eax,cp
			mov		[ebx].EDIT.cpbren,eax
			mov		eax,cp
			mov		[ebx].EDIT.cpbrst,eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			mov		eax,[ebx].EDIT.cpbren
			jmp		Ex
		.endif
		inc		ecx
	.endw
	xor		ecx,ecx
	.while byte ptr bracketend[ecx]
		.if al==bracketend[ecx]
			push	ecx
			invoke IsCharPos,ebx,cp
			pop		ecx
			or		eax,eax
			jne		Ex
			movzx	eax,byte ptr bracketstart[ecx]
			invoke BracketMatchLeft,ebx,nChr,eax,cp
			mov		[ebx].EDIT.cpbrst,eax
			mov		eax,cp
			mov		[ebx].EDIT.cpbren,eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			mov		eax,[ebx].EDIT.cpbrst
			jmp		Ex
		.endif
		inc		ecx
	.endw
	mov		eax,-1
  Ex:
	ret

BracketMatch endp

GetLineBegin proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		eax,nLine
	.if eax
		.while nLine
			dec		nLine
			mov		eax,nLine
			lea		edi,[eax*4]
			add		edi,[ebx].EDIT.hLine
			mov		esi,[edi].LINE.rpChars
			add		esi,[ebx].EDIT.hChars
			mov		ecx,[esi].CHARS.len
			.break .if ecx<2
			mov		al,[esi+ecx+sizeof CHARS-2]
			.break .if al!=bracketcont && al !=bracketcont[1]
		.endw
		mov		eax,nLine
		inc		eax
	.endif
	ret

GetLineBegin endp
