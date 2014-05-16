
.code

DrawLine proc uses ebx esi edi,hMem:DWORD,lpChars:DWORD,nLine:DWORD,cp:DWORD,hDC:DWORD,lpRect:DWORD
	LOCAL	dtp:DRAWTEXTPARAMS
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD
	LOCAL	lpCR:DWORD
	LOCAL	rect:RECT
	LOCAL	srect:RECT
	LOCAL	lCol:DWORD
	LOCAL	rcleft:DWORD
	LOCAL	fCmnt:DWORD
	LOCAL	fStr:DWORD
	LOCAL	fWrd:DWORD
	LOCAL	wCol:DWORD
	LOCAL	fEnd:DWORD
	LOCAL	fTmp:DWORD
	LOCAL	nGroup:DWORD
	LOCAL	fLc:DWORD
	LOCAL	fChr:DWORD
	LOCAL	tmp:BYTE
	LOCAL	fDot:DWORD
	LOCAL	fRed:DWORD
	LOCAL	fBack:DWORD
	LOCAL	bCol:DWORD
	LOCAL	fOpr:DWORD
	LOCAL	fNum:DWORD
	LOCAL	fCmntNest:DWORD
	LOCAL	nStr:DWORD
	LOCAL	nCmnt:DWORD
	LOCAL	nStringMode:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.nWordGroup
	mov		nGroup,eax
	mov		eax,[ebx].EDIT.fstyleex
	shr		eax,3
	and		eax,3
	mov		nStringMode,eax
	mov		fRed,0
	mov		eax,'.'
	movzx	eax,byte ptr [eax+offset CharTab]
	and		eax,1
	mov		fDot,eax
	mov		esi,lpChars
	mov		edi,[esi].CHARS.len
	test	[esi].CHARS.state,STATE_HIDDEN
	.if ZERO?
		mov		nCmnt,0
		invoke CopyRect,addr rect,lpRect
		mov		eax,rect.top
		add		eax,[ebx].EDIT.fntinfo.fntht
		mov		rect.bottom,eax
		mov		edx,[esi].CHARS.state
		test	edx,STATE_ALTHILITE
		.if !ZERO?
			inc		nGroup
		.endif
		test	edx,STATE_REDTEXT
		.if !ZERO?
			inc		fRed
		.endif
		mov		eax,edx
		and		eax,STATE_COMMENT
		mov		fCmnt,eax
		mov		eax,edx
		and		eax,STATE_COMMENTNEST
		mov		fCmntNest,eax
		and		edx,STATE_HILITEMASK
		.if edx
			.if edx==STATE_HILITE1
				mov		edx,[ebx].EDIT.br.hBrHilite1
			.elseif edx==STATE_HILITE2
				mov		edx,[ebx].EDIT.br.hBrHilite2
			.elseif edx==STATE_HILITE3
				mov		edx,[ebx].EDIT.br.hBrHilite3
			.endif
			invoke FillRect,hDC,addr rect,edx
		.endif
		mov		eax,rect.top
		mov		edx,eax
		add		edx,[ebx].EDIT.fntinfo.fntht
		.if edi && sdword ptr eax<rect.bottom && sdword ptr edx>0
			add		esi,sizeof CHARS
			mov		al,[esi+edi-1]
			mov		lpCR,0
			.if al==0Dh
				lea		eax,[esi+edi-1]
				mov		lpCR,eax
				mov		byte ptr [eax],' '
			.endif
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				mov		eax,[ebx].EDIT.cpMin
				mov		ecx,[ebx].EDIT.cpMax
				.if ![ebx].EDIT.fHideSel && eax!=ecx
					sub		eax,cp
					jnb		@f
					xor		eax,eax
				  @@:
					sub		ecx,cp
					jnb		@f
					xor		ecx,ecx
				  @@:
				.else
					xor		eax,eax
					xor		ecx,ecx
				.endif
			.else
				mov		ecx,[ebx].EDIT.blrg.lnMin
				mov		edx,[ebx].EDIT.blrg.lnMax
				.if ecx>edx
					xchg	ecx,edx
				.endif
				mov		eax,nLine
				.if eax>=ecx && eax<=edx
					invoke GetBlockCp,ebx,nLine,[ebx].EDIT.blrg.clMin
					sub		eax,cp
					push	eax
					invoke GetBlockCp,ebx,nLine,[ebx].EDIT.blrg.clMax
					sub		eax,cp
					pop		ecx
				.else
					xor		eax,eax
					xor		ecx,ecx
				.endif
			.endif
			.if eax>ecx
				xchg	eax,ecx
			.endif
			mov		cpMin,eax
			mov		cpMax,ecx
			mov		dtp.cbSize,sizeof dtp
			mov		eax,[ebx].EDIT.nTab
			mov		dtp.iTabiLength,eax
			mov		dtp.iLeftMargin,0
			mov		dtp.iRightMargin,0
			mov		dtp.uiiLengthDrawn,0
			mov		eax,rect.left
			mov		rcleft,eax
			mov		lCol,-1
			mov		fStr,0
			mov		fWrd,0
			mov		fEnd,0
			mov		fChr,0
			mov		fNum,0
			mov		fOpr,0
			mov		nStr,0
			mov		nCmnt,0
			mov		edx,[esi-sizeof CHARS].CHARS.state
			mov		eax,edx
			and		eax,STATE_COMMENT
			mov		fCmnt,eax
			.if eax
				mov		nCmnt,1
			.endif
			and		edx,3
			call	DrawSelBck
			mov		eax,[ebx].EDIT.fstyle
			test	eax,STYLE_NOHILITE
			.if !ZERO?
				mov		fEnd,99
			.endif
			.if fCmnt
				call	DrawCmntBack
			.endif
			mov		ecx,edi
			xor		edi,edi
			.while edi<ecx
				push	ecx
				mov		fBack,0
				mov		fOpr,0
				.if edi>=2 && [ebx].EDIT.ccmntblocks && fCmnt && !fCmntNest && !nStr && nCmnt
					movzx	eax,word ptr [esi+edi-2]
					.if ((eax=='/*' && [ebx].EDIT.ccmntblocks==1) || (eax=="/'" && [ebx].EDIT.ccmntblocks==2) || (ah=="}" && [ebx].EDIT.ccmntblocks==3))
						mov		fCmnt,0
						dec		nCmnt
					.endif
				.endif
				.if fEnd==99
					mov		eax,[ebx].EDIT.clr.txtcol
				.elseif fEnd==1
					movzx	eax,byte ptr [esi+edi]
					mov		al,byte ptr [eax+offset CharTab]
					.if al==CT_CMNTCHAR
						mov		fEnd,0
						mov		fStr,0
						mov		fCmnt,eax
						mov		eax,[ebx].EDIT.clr.cmntcol
					.elseif al==CT_CMNTDBLCHAR
						movzx	eax,word ptr [esi+edi]
						.if al==ah || ah=='*'
							mov		fEnd,0
							mov		fStr,0
							mov		fCmnt,eax
							mov		eax,[ebx].EDIT.clr.cmntcol
						.else
							mov		eax,[ebx].EDIT.clr.strcol
						.endif
					.elseif al==CT_CMNTINITCHAR
						movzx	eax,word ptr [esi+edi]
						.if ah=="'"
							mov		fEnd,0
							mov		fStr,0
							mov		fCmnt,eax
							mov		eax,[ebx].EDIT.clr.cmntcol
						.else
							mov		eax,[ebx].EDIT.clr.strcol
						.endif
					.else
						mov		eax,[ebx].EDIT.clr.strcol
					.endif
				.elseif fCmnt
					mov		eax,[ebx].EDIT.clr.cmntback
					call	SetBack
					mov		eax,[ebx].EDIT.clr.cmntcol
				.elseif fWrd
					mov		eax,wCol
				.elseif fStr
					movzx	eax,byte ptr [esi+edi]
					.if eax==fStr
						movzx	eax,byte ptr [esi+edi-1]
						.if nStringMode==2 && eax=='\'
							mov		eax,[ebx].EDIT.clr.strback
							call	SetBack
							mov		eax,[ebx].EDIT.clr.strcol
							mov		wCol,eax
						.else
							mov		fStr,0
							mov		eax,[ebx].EDIT.fstyleex
							shr		eax,3
							and		eax,3
							mov		nStringMode,eax
							mov		eax,[ebx].EDIT.clr.oprback
							call	SetBack
							mov		eax,[ebx].EDIT.clr.oprcol
						.endif
					.else
						mov		eax,[ebx].EDIT.clr.strback
						call	SetBack
						mov		eax,[ebx].EDIT.clr.strcol
						mov		wCol,eax
					.endif
				.else
					movzx	eax,byte ptr [esi+edi]
					movzx	edx,word ptr [esi+edi]
					mov		al,byte ptr [eax+offset CharTab]
					.if al==CT_CHAR || edx=='h&' || edx=='H&'
						call	ScanWord
						.if fNum
							push	eax
							mov		eax,[ebx].EDIT.clr.numback
							call	SetBack
							pop		eax
						.endif
						.if fEnd==2
							call	DrawCmntBack
						.endif
					.elseif al==CT_HICHAR
						call	ScanWord
						.if eax==[ebx].EDIT.clr.txtcol
							mov		fWrd,1
							mov		eax,[ebx].EDIT.clr.oprcol
						.endif
					.elseif al==CT_OPER
						mov		eax,[ebx].EDIT.clr.oprback
						call	SetBack
						mov		eax,[ebx].EDIT.clr.oprcol
						mov		fOpr,1
					.elseif al==CT_CMNTCHAR
						mov		fCmnt,eax
						mov		eax,[ebx].EDIT.clr.cmntback
						call	SetBack
						mov		eax,[ebx].EDIT.clr.cmntcol
						call	DrawCmntBack
					.elseif al==CT_STRING
						.if edi && nStringMode==1
							movzx	eax,byte ptr [esi+edi-1]
							.if eax=='!'
								mov		nStringMode,2
							.endif
						.endif
						movzx	eax,byte ptr [esi+edi]
						mov		fStr,eax
						mov		fOpr,1
						mov		eax,[ebx].EDIT.clr.oprback
						call	SetBack
						mov		eax,[ebx].EDIT.clr.oprcol
					.elseif al==CT_CMNTDBLCHAR
						movzx	eax,word ptr [esi+edi]
						.if al==ah || ah=='*'
							.if ah=='*'
								inc		nCmnt
							.endif
							mov		fCmnt,eax
							mov		eax,[ebx].EDIT.clr.cmntback
							call	SetBack
							mov		eax,[ebx].EDIT.clr.cmntcol
							call	DrawCmntBack
						.else
							mov		eax,[ebx].EDIT.clr.oprcol
						.endif
					.elseif al==CT_CMNTINITCHAR
						movzx	eax,word ptr [esi+edi]
						.if ah=="'" || al=='{'
							inc		nCmnt
							mov		fCmnt,eax
							mov		eax,[ebx].EDIT.clr.cmntback
							call	SetBack
							mov		eax,[ebx].EDIT.clr.cmntcol
							call	DrawCmntBack
						.else
							mov		eax,[ebx].EDIT.clr.oprcol
						.endif
					.else
						mov		eax,[ebx].EDIT.clr.txtcol
					.endif
				.endif
				.if edi>=2 && fWrd!=0
					.if word ptr [edi+esi-2]=='>-'
						mov		eax,[ebx].EDIT.clr.txtcol
						mov		wCol,eax
					.endif
				.endif
				.if fRed
					mov		eax,0FFh
				.endif
				.if fStr && !fOpr
					push	eax
					mov		eax,[ebx].EDIT.clr.strback
					call	SetBack
					pop		eax
				.endif
				call	DrawWord
				.if fEnd==1 && !fWrd
					mov		fStr,1
				.elseif fEnd==2 && !fWrd
					mov		fCmnt,1
				.endif
				mov		eax,rect.right
				mov		rect.left,eax
				mov		edx,lpRect
				mov		edx,[edx].RECT.right
				mov		rect.right,edx
				pop		ecx
				cmp		eax,edx
				jg		@f
			.endw
		  @@:
			mov		eax,lpCR
			.if eax
				mov		byte ptr [eax],0Dh
			.endif
		.endif
	.endif
	ret

SetBack:
	.if eax!=[ebx].EDIT.clr.bckcol
		mov		bCol,eax
		invoke SetBkColor,hDC,eax
		mov		fBack,TRUE
	.else
		mov		fBack,FALSE
	.endif
	retn

DrawWord:
	push	eax
	mov		eax,TRANSPARENT
	.if fBack
		mov		eax,OPAQUE
	.endif
	invoke SetBkMode,hDC,eax
	pop		eax
	movzx	edx,byte ptr [esi+edi]
	.if edx==VK_TAB
		mov		ecx,[ebx].EDIT.fntinfo.tabwt
		mov		eax,rect.left
		sub		eax,rcleft
		xor		edx,edx
		div		ecx
		mul		ecx
		add		eax,rcleft
		.while byte ptr [esi+edi]==VK_TAB && edi<[esi-sizeof CHARS].CHARS.len
			call	DrawTabMarker
			add		eax,ecx
			inc		edi
			mov		rect.right,eax
			.if fBack && (edi<=cpMin || edi>cpMax)
				push	eax
				push	ecx
				push	edx
				invoke CreateSolidBrush,bCol
				push	eax
				call	BackFill
				pop		eax
				invoke DeleteObject,eax
				pop		edx
				pop		ecx
				pop		eax
				push	rect.right
				pop		rect.left
			.endif
			.if fWrd
				dec		fWrd
			.endif
		.endw
	.elseif edx==VK_SPACE
		mov		ecx,[ebx].EDIT.fntinfo.spcwt
		mov		eax,rect.left
		mov		edx,[ebx].EDIT.fntinfo.tabwt
		add		edx,eax
		mov		edx,eax
		.while byte ptr [esi+edi]==VK_SPACE && edi<[esi-sizeof CHARS].CHARS.len
			.if eax==edx
				add		edx,[ebx].EDIT.fntinfo.tabwt
				call	DrawTabMarker
			.endif
			add		eax,ecx
			inc		edi
			mov		rect.right,eax
			.if fBack && (edi<=cpMin || edi>cpMax)
				push	eax
				push	ecx
				push	edx
				invoke CreateSolidBrush,bCol
				push	eax
				call	BackFill
				pop		eax
				invoke DeleteObject,eax
				pop		edx
				pop		ecx
				pop		eax
				push	rect.right
				pop		rect.left
			.endif
			.if fWrd
				dec		fWrd
			.endif
		.endw
	.else
		.if edx=='"'
			.if nStr
				dec		nStr
			.else
				inc		nStr
			.endif
		.endif
		mov		fChr,TRUE
		.if !fWrd
			push	eax
			call	GetWord
			mov		fWrd,ecx
			pop		eax
		.endif
		mov		ecx,fWrd
		add		ecx,edi
		.if edi>=cpMax || ecx<cpMin
			;Word outside selection
			mov		ecx,fWrd
		.elseif edi<cpMin && ecx>=cpMin
			;Word starts before selection, ends in selection
			mov		ecx,cpMin
			sub		ecx,edi
		.elseif edi>=cpMin && ecx<=cpMax
			;Word is in selection
			push	eax
			push	ecx
			.if fBack
				invoke SetBkMode,hDC,TRANSPARENT
			.endif
			pop		ecx
			pop		eax
			mov		ecx,fWrd
			and		eax,03000000h
			or		eax,[ebx].EDIT.clr.seltxtcol
		.else
			;Part of word is selected
			push	eax
			push	ecx
			.if fBack
				invoke SetBkMode,hDC,TRANSPARENT
			.endif
			pop		ecx
			pop		eax
			mov		ecx,cpMax
			sub		ecx,edi
			and		eax,03000000h
			or		eax,[ebx].EDIT.clr.seltxtcol
		.endif
		.if eax!=lCol
			push	ecx
			mov		lCol,eax
			and		eax,0FFFFFFh
			invoke SetTextColor,hDC,eax
			pop		ecx
		.endif
		movzx	eax,byte ptr [esi+edi]
		.if eax>80h && [ebx].EDIT.fntinfo.fDBCS
			invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],2
			invoke DrawTextEx,hDC,addr [esi+edi],2,addr rect,DT_EDITCONTROL or DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_EXPANDTABS or DT_TABSTOP,addr dtp
			inc		edi
			inc		edi
			.if fWrd
				dec		fWrd
			.endif
			.if fWrd
				dec		fWrd
			.endif
		.else
			.if ecx
				mov		fTmp,ecx
				sub		fWrd,ecx
			.else
				mov		fTmp,1
				.if fWrd
					dec		fWrd
				.endif
			.endif
			.if [ebx].EDIT.fntinfo.monospace
				mov		eax,fTmp
				mov		edx,[ebx].EDIT.fntinfo.fntwt
				mul		edx
				add		eax,rect.left
				mov		rect.right,eax
			.else
				invoke GetTextWidth,ebx,hDC,addr [esi+edi],fTmp,addr rect
			.endif
			.if sdword ptr rect.right>0
				push	rect.top
				mov		eax,[ebx].EDIT.fntinfo.linespace
				shr		eax,1
				add		rect.top,eax
				mov		eax,lCol
				shr		eax,24
				and		eax,3
				mov		ecx,cp
				add		ecx,edi
				.if ecx==[ebx].EDIT.cpbrst || ecx==[ebx].EDIT.cpbren
					mov		eax,[ebx].EDIT.clr.numcol
					.if [ebx].EDIT.cpbrst==-1 || [ebx].EDIT.cpbren==-1
						invoke SetBkMode,hDC,OPAQUE
						invoke SetBkColor,hDC,[ebx].EDIT.clr.hicol1
						mov		eax,[ebx].EDIT.clr.cmntcol
					.endif
					.if eax!=lCol
						mov		lCol,eax
						and		eax,0FFFFFFh
						invoke SetTextColor,hDC,eax
					.endif
					;Bold
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					invoke SetBkMode,hDC,TRANSPARENT
					inc		rect.left
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					inc		rect.left
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					sub		rect.left,2
					mov		eax,-1
				.endif
				.if !eax
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
				.elseif eax==1
					;Bold
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					inc		rect.left
					invoke SetBkMode,hDC,TRANSPARENT
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					dec		rect.left
				.elseif eax==2
					;Italic
					push	rect.top
					mov		eax,[ebx].EDIT.fntinfo.italic
					sub		rect.top,eax
					invoke SelectObject,hDC,[ebx].EDIT.fnt.hIFont
					push	eax
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					pop		eax
					invoke SelectObject,hDC,eax
					pop		rect.top
				.elseif eax==3
					;Bold italic
					push	rect.top
					mov		eax,[ebx].EDIT.fntinfo.italic
					sub		rect.top,eax
					invoke SelectObject,hDC,[ebx].EDIT.fnt.hIFont
					push	eax
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					inc		rect.left
					invoke SetBkMode,hDC,TRANSPARENT
					invoke TextOut,hDC,rect.left,rect.top,addr [esi+edi],fTmp
					pop		eax
					invoke SelectObject,hDC,eax
					dec		rect.left
					pop		rect.top
				.endif
				pop		rect.top
			.endif
			add		edi,fTmp
		.endif
	.endif
	retn

DrawTabMarker:
	.if edi && !fChr
		pushad
		lea		esi,[eax+2]
		sub		eax,rcleft
		.if eax
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			shr		ecx,1
			mov		edi,rect.top
			.while ecx
				push	ecx
				inc		edi
				invoke SetPixel,hDC,esi,edi,[ebx].EDIT.clr.hicol3
				inc		edi
				pop		ecx
				dec		ecx
			.endw
		.endif
		popad
	.endif
	retn

ScanWord:
	xor		ecx,ecx
	mov		fNum,ecx
	call	GetWord
	mov		fWrd,ecx
	.if ecx
		call	TestWord
		.if !ecx
			call	GetNum
			.if !ecx
				mov		eax,[ebx].EDIT.clr.txtcol
			.else
				mov		fWrd,ecx
				mov		fNum,1
				mov		eax,[ebx].EDIT.clr.numcol
			.endif
		.endif
	.else
		mov		eax,[ebx].EDIT.clr.txtcol
	.endif
	mov		wCol,eax
	retn

GetWord:
	xor		ecx,ecx
	mov		edx,offset CharTab
	cmp		word ptr [edi+esi],'h&'
	je		@f
	cmp		word ptr [edi+esi],'H&'
	je		@f
;	.if word ptr [edi+esi]=='>-'
;		inc		ecx
;		jmp		@f
;	.endif
	lea		eax,[edi+esi]
	movzx	eax,byte ptr [eax+ecx]
	cmp		byte ptr [eax+edx],3
	je		@f
	dec		ecx
  @@:
	inc		ecx
	lea		eax,[edi+esi]
	movzx	eax,byte ptr [eax+ecx]
	cmp		byte ptr [eax+edx],1
	je		@b
	retn

GetNum:
	push	ebx
	xor		ebx,ebx
	xor		ecx,ecx
	movzx	eax,byte ptr [edi+esi]
	movzx	edx,byte ptr [edi+esi+1]
	.if (eax>='0' && eax<='9') || (eax=='&' && (edx=='h' || edx=='H'))
		.if eax=='0' && (edx=='x' || edx=='X')
			inc		ecx
			mov		ebx,80000000h
		.elseif edx=='h' || edx=='H'
			inc		ecx
;			mov		ebx,80000000h
		.endif
		mov		edx,offset CharTab
	  @@:
		inc		ecx
		lea		eax,[edi+esi]
		movzx	eax,byte ptr [eax+ecx]
		.if byte ptr [eax+edx]==1
			.if (eax>='0' && eax<='9') || (eax>='A' && eax<='F') || (eax>='a' && eax<='f')
				inc		ebx
				jmp		@b
			.elseif eax=='H' || eax=='h'
				inc		ecx
				lea		eax,[edi+esi]
				movzx	eax,byte ptr [eax+ecx]
				.if byte ptr [eax+edx]==1 || sdword ptr ebx<0
					xor		ecx,ecx
				.else
					xor		ebx,ebx
				.endif
			.else
				xor		ecx,ecx
			.endif
		.endif
		.if ebx==80000000h
			xor		ecx,ecx
		.endif
	.endif
	pop		ebx
	retn

TestWord:
	push	ebx
	movzx	eax,byte ptr [esi+edi]
	mov		fLc,0
	.if eax>='a' && eax<='z'
		mov		fLc,1
		and		eax,5Fh
	.endif
	mov		ebx,hWrdMem
	mov		edx,[ebx+eax*4]
  TestWord1:
	.if edx
		mov		eax,[ebx+edx].WORDINFO.color
		shr		eax,28
		cmp		eax,nGroup
		jne		TestWord2
		cmp		ecx,[ebx+edx].WORDINFO.len
		je		@f
	  TestWord2:
		mov		edx,[ebx+edx].WORDINFO.rpprev
		jmp		TestWord1
	  @@:
		mov		ah,byte ptr [ebx+edx].WORDINFO.fend
		call	CmpWord
		.if !ZERO?
			mov		edx,[ebx+edx].WORDINFO.rpprev
			jmp		TestWord1
		.endif
		.if ah & 4
			and		ah, not 4
			call	SetCaseWord
		.endif
		mov		byte ptr fEnd,ah
		mov		eax,[ebx+edx].WORDINFO.color
	.else
		xor		ecx,ecx
	.endif
	pop		ebx
	retn

CmpWord:
	push	ecx
	push	ebx
	push	esi
	lea		ebx,[ebx+edx+sizeof WORDINFO]
	lea		esi,[esi+edi]
	mov		al,[esi]
	.if al=='.' && edi && fDot
		mov		al,[esi-1]
		.if al!=' ' && al!=VK_TAB
			or		eax,eax
			jmp		CmpWord2
		.endif
	.elseif edi
		mov		al,[esi-1]
		.if al=='.' && fDot
			or		eax,eax
			jmp		CmpWord2
		.endif
	.endif
  @@:
	mov		al,[esi+ecx-1]
	.if al>='a' && al <='z' && ah!=3
		and		al,5Fh
	.endif
	mov		tmp, al
	mov		al,[ebx+ecx-1]
	.IF al>='a' && al <='z' && ah!=3
		and		al,5Fh
	.ENDIF
	cmp		al, tmp
	jne		CmpWord2
  CmpWord1:
	dec		ecx
	jne		@b
  CmpWord2:
	pop		esi
	pop		ebx
	pop		ecx
	retn

SetCaseWord:
	push	ecx
	push	ebx
	push	esi
	lea		ebx,[ebx+edx+SIZEOF WORDINFO]
	lea		esi,[esi+edi]
  @@:
	mov		al,[ebx+ecx-1]
	mov		[esi+ecx-1],al
	dec		ecx
	jnz		@b
	pop		esi
	pop		ebx
	pop		ecx
	retn

BackFill:
	push	rect.left
	push	rect.right
	.if sdword ptr rect.left<0
		mov		rect.left,0
	.endif
	.if sdword ptr rect.right>2048
		mov		rect.right,2048
	.endif
	invoke FillRect,hDC,addr rect,eax
	pop		rect.right
	pop		rect.left
	retn

DrawCmntBack:
	test	[ebx].EDIT.fstyle,STYLE_HILITECOMMENT
	.if !ZERO?
		push	eax
		push	rect.left
		push	rect.right
		mov		eax,rect.left
		mov		edx,rect.right
		.if sdword ptr edx<=srect.left || sdword ptr eax>=srect.right
			;Whole line
			mov		eax,[ebx].EDIT.br.hBrHilite1
			call 	BackFill
		.elseif sdword ptr eax<srect.left
			;Middle
			mov		eax,srect.left
			mov		rect.right,eax
			mov		eax,[ebx].EDIT.br.hBrHilite1
			call 	BackFill
			mov		rect.right,2048
			mov		eax,srect.right
			mov		rect.left,eax
			mov		eax,[ebx].EDIT.br.hBrHilite1
			call 	BackFill
		.elseif sdword ptr eax<srect.right
			;Right
			mov		eax,srect.right
			mov		rect.left,eax
			mov		rect.right,2048
			mov		eax,[ebx].EDIT.br.hBrHilite1
			call 	BackFill
		.endif
		pop		rect.right
		pop		rect.left
		pop		eax
	.endif
	retn

DrawSelBck:
	mov		srect.left,4096
	mov		srect.right,4096
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		mov		eax,cpMin
		.if eax!=cpMax
			.if !cpMin && edi<=cpMax
				;Whole line
				invoke GetTextWidth,ebx,hDC,esi,edi,addr rect
				mov		eax,[ebx].EDIT.br.hBrSelBck
				call BackFill
				invoke CopyRect,addr srect,addr rect
			.elseif !cpMin
				;Left part
				invoke GetTextWidth,ebx,hDC,esi,cpMax,addr rect
				mov		eax,[ebx].EDIT.br.hBrSelBck
				call BackFill
				invoke CopyRect,addr srect,addr rect
			.elseif edi>cpMin
				;Right or middle part
				invoke GetTextWidth,ebx,hDC,esi,cpMin,addr rect
				push	rect.right
				mov		ecx,cpMax
				.if ecx>edi
					mov		ecx,edi
				.endif
				invoke GetTextWidth,ebx,hDC,esi,ecx,addr rect
				pop		rect.left
				mov		eax,[ebx].EDIT.br.hBrSelBck
				call BackFill
				invoke CopyRect,addr srect,addr rect
				mov		eax,rcleft
				mov		rect.left,eax
			.endif
		.endif
	.else
		mov		ecx,[ebx].EDIT.blrg.lnMin
		mov		edx,[ebx].EDIT.blrg.lnMax
		.if ecx>edx
			xchg	ecx,edx
		.endif
		mov		eax,nLine
		.if eax>=ecx && eax<=edx
			mov		ecx,[ebx].EDIT.fntinfo.fntwt
			mov		eax,[ebx].EDIT.blrg.clMin
			.if eax>[ebx].EDIT.blrg.clMax
				mov		eax,[ebx].EDIT.blrg.clMax
			.endif
			mul		ecx
			add		rect.left,eax
			mov		eax,[ebx].EDIT.blrg.clMax
			sub		eax,[ebx].EDIT.blrg.clMin
			.if CARRY?
				neg		eax
			.endif
			mul		ecx
			add		eax,rect.left
			inc		eax
			mov		rect.right,eax
			mov		eax,rect.top
			add		eax,[ebx].EDIT.fntinfo.fntht
			mov		rect.bottom,eax
			mov		eax,[ebx].EDIT.br.hBrSelBck
			call BackFill
			invoke CopyRect,addr srect,addr rect
			mov		eax,rcleft
			mov		rect.left,eax
		.endif
	.endif
	retn

DrawLine endp

SetBlockMarkers proc uses ebx esi edi,hMem:DWORD,nLine:DWORD,nMax:DWORD
	LOCAL	nLines:DWORD
	LOCAL	nLnMax:DWORD
	LOCAL	nLnSt:DWORD
	LOCAL	nLnEn:DWORD
	LOCAL	lpBlockDef:DWORD
	LOCAL	fcmnt:DWORD

	mov		ebx,hMem
	test	[ebx].EDIT.fstyleex,STYLEEX_BLOCKGUIDE
	.if !ZERO?
		mov		fcmnt,0
		;Clear block markers
		mov		edx,[ebx].EDIT.rpLineFree
		shr		edx,2
		dec		edx
		mov		nLnMax,edx
		mov		eax,nLine
		mov		edx,nMax
		mov		nLines,edx
		.while eax<=nLnMax && nLines
			mov		edx,eax
			shl		edx,2
			add		edx,[ebx].EDIT.hLine
			mov		edx,[edx]
			add		edx,[ebx].EDIT.hChars
			and		[edx].CHARS.state,-1 xor (STATE_BLOCKSTART or STATE_BLOCK or STATE_BLOCKEND)
			test	[edx].CHARS.state,STATE_HIDDEN
			.if ZERO?
				dec		nLines
			.endif
			inc		eax
		.endw
		mov		edx,nMax
		mov		nLines,edx
		;Find root block
		mov		esi,-1
	  Nxt:
		call	BlockRoot
		.if nLnEn
			mov		esi,nLnSt
			inc		esi
			.if esi<nLine
				mov		esi,nLine
			.endif
			.while esi<=nLnEn && nLines
				mov		edi,esi
				shl		edi,2
				add		edi,[ebx].EDIT.hLine
				mov		edi,[edi]
				add		edi,[ebx].EDIT.hChars
				test	[edi].CHARS.state,STATE_HIDDEN
				.if ZERO?
					test	[edi].CHARS.state,STATE_COMMENT
					.if !ZERO?
						mov		fcmnt,edi
					.elseif fcmnt
						mov		edx,fcmnt
						mov		fcmnt,0
						.if esi==nLnEn
							and		[edx].CHARS.state,-1 xor (STATE_BLOCKSTART or STATE_BLOCK or STATE_BLOCKEND)
						.endif
						or		[edx].CHARS.state,STATE_BLOCKEND
					.endif
					and		[edi].CHARS.state,-1 xor (STATE_BLOCKSTART or STATE_BLOCK or STATE_BLOCKEND)
					.if esi<nLnEn
						or		[edi].CHARS.state,STATE_BLOCK
					.endif
					invoke TestBlockEnd,ebx,esi
					mov		edx,esi
					inc		edx
					shl		edx,2
					.if eax!=-1 || edx==[ebx].EDIT.rpLineFree
						or		[edi].CHARS.state,STATE_BLOCKEND
					.endif
					dec		nLines
				.endif
				inc		esi
			.endw
			.if esi<nLnMax && nLines
				mov		edx,lpBlockDef
				test	[edx].RABLOCKDEF.flag,BD_SEGMENTBLOCK
				.if !ZERO?
					dec		esi
					inc		nLines
					mov		edi,esi
					dec		edi
					shl		edi,2
					add		edi,[ebx].EDIT.hLine
					mov		edi,[edi]
					add		edi,[ebx].EDIT.hChars
					and		[edi].CHARS.state,-1 xor (STATE_BLOCKSTART or STATE_BLOCK or STATE_BLOCKEND)
					or		[edi].CHARS.state,STATE_BLOCKEND
				.endif
				dec		esi
				jmp		Nxt
			.endif
		.endif
	.endif
	ret

BlockRoot:
	mov		nLnSt,0
	mov		nLnEn,0
	invoke NextBookMark,ebx,esi,1
	.if eax!=-1
		mov		esi,eax
		invoke TestBlockStart,ebx,esi
		.if eax!=-1
			mov		lpBlockDef,eax
			invoke GetBlock,ebx,esi,lpBlockDef
			mov		edx,lpBlockDef
			test	[edx].RABLOCKDEF.flag,BD_INCLUDELAST
			.if ZERO?
				inc		eax
			.endif
			add		eax,esi
			.if eax>=nLine
				mov		nLnSt,esi
				mov		nLnEn,eax
			.else
				.if sdword ptr eax>esi
					mov		esi,eax
				.endif
				test	[edx].RABLOCKDEF.flag,BD_SEGMENTBLOCK
				.if !ZERO?
					dec		esi
				.endif
				jmp		BlockRoot
			.endif
		.endif
	.endif
	retn

SetBlockMarkers endp

DrawChangedState proc uses ebx edi,hMem:DWORD,hDC:HDC,lpLine:DWORD,x:DWORD,y:DWORD
	LOCAL	hBr:HBRUSH
	LOCAL	rect:RECT

	mov		ebx,hMem
	test	[ebx].EDIT.fstyleex,STILEEX_LINECHANGED
	.if !ZERO?
		mov		edi,lpLine
		test	[edi].CHARS.state,STATE_CHANGESAVED
		.if !ZERO?
			invoke CreateSolidBrush,[ebx].EDIT.clr.changesaved
			mov		hBr,eax
			xor		eax,eax
			sub		eax,x
			add		eax,[ebx].EDIT.linenrwt
			add		eax,20
			mov		rect.left,eax
			add		eax,5
			mov		rect.right,eax
			mov		eax,y
			mov		rect.top,eax
			add		eax,[ebx].EDIT.fntinfo.fntht
			mov		rect.bottom,eax
			invoke FillRect,hDC,addr rect,hBr
			invoke DeleteObject,hBr
		.else
			test	[edi].CHARS.state,STATE_CHANGED
			.if !ZERO?
				invoke CreateSolidBrush,[ebx].EDIT.clr.changed
				mov		hBr,eax
				xor		eax,eax
				sub		eax,x
				add		eax,[ebx].EDIT.linenrwt
				add		eax,20
				mov		rect.left,eax
				add		eax,5
				mov		rect.right,eax
				mov		eax,y
				mov		rect.top,eax
				add		eax,[ebx].EDIT.fntinfo.fntht
				mov		rect.bottom,eax
				invoke FillRect,hDC,addr rect,hBr
				invoke DeleteObject,hBr
			.endif
		.endif
	.endif
	ret

DrawChangedState endp

;This proc does all the painting and drawing
RAEditPaint proc uses ebx esi edi,hWin:HWND
	LOCAL	ps:PAINTSTRUCT
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT
	LOCAL	cp:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	hRgn1:DWORD
	LOCAL	rcRgn1:RECT
	LOCAL	pt:POINT

	;Get the memory pointer
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	invoke GetFocus
	.if eax==hWin
		.if ![ebx].EDIT.fCaretHide
			invoke HideCaret,hWin
			mov		[ebx].EDIT.fCaretHide,TRUE                    ; *** MOD
		.endif
	.endif
	invoke BeginPaint,hWin,addr ps
	.if [ebx].EDIT.linenrwt
		test	[ebx].EDIT.fstyle,STYLE_AUTOSIZELINENUM
		.if !ZERO?
			xor		eax,eax
			mov		rect1.left,eax
			mov		rect1.top,eax
			mov		rect1.right,eax
			mov		rect1.bottom,eax
			invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hLnrFont
			push	eax
			mov		edx,[ebx].EDIT.rpLineFree
			shr		edx,2
			invoke DwToAscii,edx,addr buffer
			invoke DrawText,ps.hdc,addr buffer,-1,addr rect1,DT_CALCRECT or DT_SINGLELINE
			pop		eax
			invoke SelectObject,ps.hdc,eax
			mov		eax,rect1.right
			add		eax,10
			.if eax!=[ebx].EDIT.linenrwt
				mov		[ebx].EDIT.linenrwt,eax
				mov		eax,hWin
				.if eax==[ebx].EDIT.edta.hwnd
					lea		esi,[ebx].EDIT.edta
				.else
					lea		esi,[ebx].EDIT.edtb
				.endif
;				invoke SetCaret,ebx,[esi].RAEDT.cpy
				invoke GetCaretPoint,ebx,[ebx].EDIT.cpMin,[esi].RAEDT.cpy,addr pt
				invoke SetCaretPos,pt.x,pt.y
			.endif
		.endif
	.endif
	;Create a memory DC
	invoke CreateCompatibleDC,ps.hdc
	mov		mDC,eax
	invoke GetClientRect,hWin,addr rect
	test	[ebx].EDIT.fstyle,STYLE_NOVSCROLL
	.if ZERO?
		mov		eax,SBWT
		sub		rect.right,eax
	.endif
	mov		eax,rect.right
	.if eax<ps.rcPaint.right
		mov		ps.rcPaint.right,eax
	.endif
	;Create a bitmap for the DC
	mov		eax,ps.rcPaint.bottom
	sub		eax,ps.rcPaint.top
	mov		rect1.bottom,eax
	mov		edx,ps.rcPaint.right
	sub		edx,ps.rcPaint.left
	mov		rect1.right,edx
	mov		rect1.left,0
	mov		rect1.top,0
	invoke CreateCompatibleBitmap,ps.hdc,edx,eax
	;and select it
	invoke SelectObject,mDC,eax
	push	eax
	;Select pen
	invoke SelectObject,mDC,[ebx].EDIT.br.hPenSelbar
	push	eax
	;Select the font into the DC
	invoke SelectObject,mDC,[ebx].EDIT.fnt.hFont
	push	eax
	;Draw text transparent
	invoke SetBkMode,mDC,TRANSPARENT
	mov		eax,[ebx].EDIT.selbarwt
	add		eax,[ebx].EDIT.linenrwt
	sub		eax,ps.rcPaint.left
	jb		@f
	mov		rect1.left,eax
  @@:
	invoke FillRect,mDC,addr rect1,[ebx].EDIT.br.hBrBck
	invoke CopyRect,addr rcRgn1,addr rect1
	invoke CreateRectRgn,rect1.left,rect1.top,rect1.right,rect1.bottom
	mov		hRgn1,eax
	.if rect1.left
		mov		eax,rect1.left
		mov		rect1.right,eax
		mov		rect1.left,0
		invoke FillRect,mDC,addr rect1,[ebx].EDIT.br.hBrSelBar
		dec		rect1.right
		invoke MoveToEx,mDC,rect1.right,rect1.top,NULL
		invoke LineTo,mDC,rect1.right,rect1.bottom
	.endif
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	push	[esi].RAEDT.cpy
	mov		eax,[esi].RAEDT.topcp
	mov		cp,eax
	mov		esi,[esi].RAEDT.topln
	mov		eax,rect.bottom
	sub		eax,rect.top
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	xor		edx,edx
	div		ecx
	inc		eax
	invoke SetBlockMarkers,ebx,esi,eax
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	pop		eax
	push	eax
	xor		edx,edx
	div		ecx
	mul		ecx
	pop		edx
	sub		eax,edx
	mov		rect.top,eax
	;Draw rect a or b
	mov		eax,[ebx].EDIT.cpx
	neg		eax
	add		eax,[ebx].EDIT.selbarwt
	add		eax,[ebx].EDIT.linenrwt
	inc		eax
	mov		rect.left,eax
	xor		eax,eax
	mov		edx,rect.top
	.while sdword ptr edx<ps.rcPaint.bottom
		invoke CopyRect,addr rect1,addr rect
		mov		eax,ps.rcPaint.top
		sub		rect1.top,eax
		sub		rect1.bottom,eax
		mov		eax,ps.rcPaint.left
		sub		rect1.left,eax
		sub		rect1.right,eax
	  @@:
		mov		edi,esi
		shl		edi,2
		cmp		edi,[ebx].EDIT.rpLineFree
		jnb		@f
		inc		esi
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		xor		edx,edx
		test	[edi].CHARS.state,STATE_HIDDEN
		.if ZERO?
			mov		eax,rect.top
			add		eax,[ebx].EDIT.fntinfo.fntht
			.if eax>ps.rcPaint.top
				invoke CreateRectRgn,rcRgn1.left,rect1.top,rcRgn1.right,rect1.bottom
				push	eax
				invoke SelectClipRgn,mDC,eax
				pop		eax
				invoke DeleteObject,eax
				mov		edx,esi
				dec		edx
				invoke DrawLine,ebx,edi,edx,cp,mDC,addr rect1
				invoke SelectClipRgn,mDC,hRgn1
				test	[edi].CHARS.state,STATE_DIVIDERLINE
				.if !ZERO?
					test	[ebx].EDIT.fstyle,STYLE_NODIVIDERLINE
					.if ZERO?
						invoke MoveToEx,mDC,rcRgn1.left,rect1.top,NULL
						invoke LineTo,mDC,rcRgn1.right,rect1.top
					.endif
				.endif
				mov		eax,[ebx].EDIT.selbarwt
				add		eax,[ebx].EDIT.linenrwt
				.if ps.rcPaint.left<eax
					invoke SelectClipRgn,mDC,NULL
					call	DrawBlockMarker
					test	[edi].CHARS.state,STATE_BREAKPOINT
					.if !ZERO?
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15+12
						sub		eax,ps.rcPaint.left
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,3,mDC,eax,edx,ILD_TRANSPARENT
					.endif
					.if [edi].CHARS.errid
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15+12
						sub		eax,ps.rcPaint.left
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,6,mDC,eax,edx,ILD_TRANSPARENT
					.endif
					mov		eax,[ebx].EDIT.lpBmCB
					mov		ecx,[edi].CHARS.state
					and		ecx,STATE_BMMASK
					.if ecx
						shr		ecx,4
					.elseif eax
						dec		esi
						push	esi
						inc		esi
						push	[ebx].EDIT.hwnd
						call	eax
						mov		ecx,eax
					.endif
					.if ecx
						dec		ecx
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15
						sub		eax,ps.rcPaint.left
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,ecx,mDC,eax,edx,ILD_NORMAL
					.endif
					call	DrawPageBreak
					.if [ebx].EDIT.linenrwt
						invoke SetBkMode,mDC,TRANSPARENT
						invoke SetTextColor,mDC,[ebx].EDIT.clr.lnrcol
						invoke SelectObject,mDC,[ebx].EDIT.fnt.hLnrFont
						push	eax
						mov		eax,[ebx].EDIT.linenrwt
						sub		eax,ps.rcPaint.left
						sub		eax,2
						mov		rect1.right,eax
						sub		eax,[ebx].EDIT.linenrwt
						mov		rect1.left,eax
						mov		eax,[ebx].EDIT.fntinfo.fntht
						add		eax,rect1.top
						dec		eax
						mov		rect1.bottom,eax
						invoke DwToAscii,esi,addr buffer
						invoke DrawText,mDC,addr buffer,-1,addr rect1,DT_RIGHT or DT_SINGLELINE or DT_BOTTOM
						pop		eax
						invoke SelectObject,mDC,eax
					.endif
				.endif
			.endif
			mov		edx,[ebx].EDIT.fntinfo.fntht
		.endif
		mov		eax,[edi].CHARS.len
		add		cp,eax
		or		edx,edx
		je		@b
		add		rect.top,edx
		mov		edx,rect.top
	.endw
  @@:
	mov		eax,ps.rcPaint.right
	sub		eax,ps.rcPaint.left
	mov		edx,ps.rcPaint.bottom
	sub		edx,ps.rcPaint.top
	invoke BitBlt,ps.hdc,ps.rcPaint.left,ps.rcPaint.top,eax,edx,mDC,0,0,SRCCOPY
	;Restore old font
	pop		eax
	invoke SelectObject,mDC,eax
	;Restore old pen
	pop		eax
	invoke SelectObject,mDC,eax
	;Restore old bitmap
	pop		eax
	invoke SelectObject,mDC,eax
	;Delete created bitmap
	invoke DeleteObject,eax
	;Delete created memory DC
	invoke DeleteDC,mDC
	invoke EndPaint,hWin,addr ps
	invoke DeleteObject,hRgn1
	invoke GetFocus
	.if eax==hWin
		.if [ebx].EDIT.fCaretHide
			invoke ShowCaret,hWin
			mov		[ebx].EDIT.fCaretHide,FALSE
		.endif
	.endif
	ret

DrawBlockMarker:
	invoke DrawChangedState,ebx,mDC,edi,ps.rcPaint.left,rect1.top
	test	[edi].CHARS.state,STATE_BLOCK
	.if !ZERO?
		xor		eax,eax
		sub		eax,ps.rcPaint.left
		add		eax,[ebx].EDIT.linenrwt
		add		eax,15
		mov		edx,rect1.top
		push	eax
		invoke MoveToEx,mDC,eax,edx,NULL
		pop		eax
		mov		edx,[ebx].EDIT.fntinfo.fntht
		add		edx,rect1.top
		invoke LineTo,mDC,eax,edx
	.endif
	test	[edi].CHARS.state,STATE_BLOCKEND
	.if !ZERO?
		xor		eax,eax
		sub		eax,ps.rcPaint.left
		add		eax,[ebx].EDIT.linenrwt
		add		eax,15
		mov		edx,rect1.top
		push	eax
		invoke MoveToEx,mDC,eax,edx,NULL
		pop		eax
		mov		edx,[ebx].EDIT.fntinfo.fntht
		shr		edx,1
		add		edx,rect1.top
		push	edx
		invoke LineTo,mDC,eax,edx
		pop		edx
		xor		eax,eax
		sub		eax,ps.rcPaint.left
		add		eax,[ebx].EDIT.linenrwt
		add		eax,SELWT-4
		invoke LineTo,mDC,eax,edx
	.endif
	retn

DrawPageBreak:
	mov		ecx,[ebx].EDIT.nPageBreak
	.if ecx
		mov		eax,esi
		xor		edx,edx
		div		ecx
		.if !edx
			xor		eax,eax
			sub		eax,ps.rcPaint.left
			mov		edx,[ebx].EDIT.fntinfo.fntht
			add		edx,rect1.top
			dec		edx
			invoke MoveToEx,mDC,eax,edx,NULL
			mov		eax,[ebx].EDIT.selbarwt
			add		eax,[ebx].EDIT.linenrwt
			sub		eax,ps.rcPaint.left
			mov		edx,[ebx].EDIT.fntinfo.fntht
			add		edx,rect1.top
			dec		edx
			invoke LineTo,mDC,eax,edx
		.endif
	.endif
	retn

RAEditPaint endp

;This proc does all the painting and drawing
RAEditPaintNoBuff proc uses ebx esi edi,hWin:HWND
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT
	LOCAL	cp:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	hRgn1:DWORD
	LOCAL	pt:POINT

	;Get the memory pointer
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	invoke GetFocus
	.if eax==hWin
		.if ![ebx].EDIT.fCaretHide
			invoke HideCaret,hWin
			mov		[ebx].EDIT.fCaretHide,TRUE                ; *** MOD
		.endif
	.endif
	invoke BeginPaint,hWin,addr ps
	.if [ebx].EDIT.linenrwt
		test	[ebx].EDIT.fstyle,STYLE_AUTOSIZELINENUM
		.if !ZERO?
			xor		eax,eax
			mov		rect1.left,eax
			mov		rect1.top,eax
			mov		rect1.right,eax
			mov		rect1.bottom,eax
			invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hLnrFont
			push	eax
			mov		edx,[ebx].EDIT.rpLineFree
			shr		edx,2
			invoke DwToAscii,edx,addr buffer
			invoke DrawText,ps.hdc,addr buffer,-1,addr rect1,DT_CALCRECT or DT_SINGLELINE
			pop		eax
			invoke SelectObject,ps.hdc,eax
			mov		eax,rect1.right
			add		eax,10
			.if eax!=[ebx].EDIT.linenrwt
				mov		[ebx].EDIT.linenrwt,eax
				mov		eax,hWin
				.if eax==[ebx].EDIT.edta.hwnd
					lea		esi,[ebx].EDIT.edta
				.else
					lea		esi,[ebx].EDIT.edtb
				.endif
;				invoke SetCaret,ebx,[esi].RAEDT.cpy
				invoke GetCaretPoint,ebx,[ebx].EDIT.cpMin,[esi].RAEDT.cpy,addr pt
				invoke SetCaretPos,pt.x,pt.y
			.endif
		.endif
	.endif
	;Select pen
	invoke SelectObject,ps.hdc,[ebx].EDIT.br.hPenSelbar
	push	eax
	;Select the font into the DC
	invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hFont
	push	eax
	;Draw text transparent
	invoke SetBkMode,ps.hdc,TRANSPARENT
	invoke GetClientRect,hWin,addr rect
	test	[ebx].EDIT.fstyle,STYLE_NOVSCROLL
	.if ZERO?
		mov		eax,SBWT
		sub		rect.right,eax
	.endif
	invoke CopyRect,addr rect1,addr rect
	mov		eax,[ebx].EDIT.selbarwt
	add		eax,[ebx].EDIT.linenrwt
	mov		rect1.left,eax
	invoke CreateRectRgn,rect1.left,rect1.top,rect1.right,rect1.bottom
	mov		hRgn1,eax
	.if rect1.left
		mov		eax,rect1.left
		mov		rect1.right,eax
		mov		rect1.left,0
		invoke FillRect,ps.hdc,addr rect1,[ebx].EDIT.br.hBrSelBar
		dec		rect1.right
		invoke MoveToEx,ps.hdc,rect1.right,rect1.top,NULL
		invoke LineTo,ps.hdc,rect1.right,rect1.bottom
	.endif
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	push	[esi].RAEDT.cpy
	mov		eax,[esi].RAEDT.topcp
	mov		cp,eax
	mov		esi,[esi].RAEDT.topln
	mov		eax,rect.bottom
	sub		eax,rect.top
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	xor		edx,edx
	div		ecx
	inc		eax
	invoke SetBlockMarkers,ebx,esi,eax
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	pop		eax
	push	eax
	xor		edx,edx
	div		ecx
	mul		ecx
	pop		edx
	sub		eax,edx
	mov		rect.top,eax
	;Draw rect a or b
	mov		eax,[ebx].EDIT.cpx
	neg		eax
	add		eax,[ebx].EDIT.selbarwt
	add		eax,[ebx].EDIT.linenrwt
	mov		rect.left,eax
	xor		eax,eax
	mov		edx,rect.top
	.while sdword ptr edx<=ps.rcPaint.bottom
		invoke CopyRect,addr rect1,addr rect;ps.rcPaint
		mov		eax,rect1.top
		add		eax,[ebx].EDIT.fntinfo.fntht
		mov		rect1.bottom,eax
		.if eax>=ps.rcPaint.top
			push	rect1.left
			mov		eax,[ebx].EDIT.selbarwt
			add		eax,[ebx].EDIT.linenrwt
			mov		rect1.left,eax
			invoke FillRect,ps.hdc,addr rect1,[ebx].EDIT.br.hBrBck
			pop		rect1.left
		.endif
		inc		rect1.left
	  @@:
		mov		edx,[ebx].EDIT.fntinfo.fntht
		mov		edi,esi
		shl		edi,2
		cmp		edi,[ebx].EDIT.rpLineFree
		jnb		@f
		inc		esi
		add		edi,[ebx].EDIT.hLine
		mov		edi,[edi].LINE.rpChars
		add		edi,[ebx].EDIT.hChars
		xor		edx,edx
		test	[edi].CHARS.state,STATE_HIDDEN
		.if ZERO?
			mov		eax,rect1.top
			add		eax,[ebx].EDIT.fntinfo.fntht
			.if eax>=ps.rcPaint.top
				mov		rect1.bottom,eax
				mov		eax,[ebx].EDIT.selbarwt
				add		eax,[ebx].EDIT.linenrwt
				invoke CreateRectRgn,eax,rect1.top,rect1.right,rect1.bottom
				push	eax
				invoke SelectClipRgn,ps.hdc,eax
				pop		eax
				invoke DeleteObject,eax
				mov		edx,esi
				dec		edx
				invoke DrawLine,ebx,edi,edx,cp,ps.hdc,addr rect1
				invoke SelectClipRgn,ps.hdc,hRgn1
				test	[edi].CHARS.state,STATE_DIVIDERLINE
				.if !ZERO?
					test	[ebx].EDIT.fstyle,STYLE_NODIVIDERLINE
					.if ZERO?
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						invoke MoveToEx,ps.hdc,eax,rect1.top,NULL
						invoke LineTo,ps.hdc,rect1.right,rect1.top
					.endif
				.endif
				mov		eax,[ebx].EDIT.selbarwt
				add		eax,[ebx].EDIT.linenrwt
				.if ps.rcPaint.left<eax
					invoke SelectClipRgn,ps.hdc,NULL
					call	DrawBlockMarker
					test	[edi].CHARS.state,STATE_BREAKPOINT
					.if !ZERO?
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15+12
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,3,ps.hdc,eax,edx,ILD_TRANSPARENT
					.endif
					.if [edi].CHARS.errid
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15+12
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,6,ps.hdc,eax,edx,ILD_TRANSPARENT
					.endif
					mov		eax,[ebx].EDIT.lpBmCB
					mov		ecx,[edi].CHARS.state
					and		ecx,STATE_BMMASK
					.if ecx
						shr		ecx,4
					.elseif eax
						dec		esi
						push	esi
						inc		esi
						push	[ebx].EDIT.hwnd
						call	eax
						mov		ecx,eax
					.endif
					.if ecx
						dec		ecx
						mov		eax,[ebx].EDIT.selbarwt
						add		eax,[ebx].EDIT.linenrwt
						sub		eax,15
						mov		edx,[ebx].EDIT.fntinfo.fntht
						;sub		edx,7
						shr		edx,1
						sub		edx,5
						add		edx,rect1.top
						invoke ImageList_Draw,hIml,ecx,ps.hdc,eax,edx,ILD_NORMAL
					.endif
					call	DrawPageBreak
					.if [ebx].EDIT.linenrwt
						invoke SetBkMode,ps.hdc,TRANSPARENT
						invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.lnrcol
						invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hLnrFont
						push	eax
						mov		eax,[ebx].EDIT.linenrwt
						sub		eax,2
						mov		rect1.right,eax
						sub		eax,[ebx].EDIT.linenrwt
						mov		rect1.left,eax
						mov		eax,[ebx].EDIT.fntinfo.fntht
						add		eax,rect1.top
						dec		eax
						mov		rect1.bottom,eax
						invoke DwToAscii,esi,addr buffer
						invoke DrawText,ps.hdc,addr buffer,-1,addr rect1,DT_RIGHT or DT_SINGLELINE or DT_BOTTOM
						pop		eax
						invoke SelectObject,ps.hdc,eax
					.endif
				.endif
			.endif
			mov		edx,[ebx].EDIT.fntinfo.fntht
		.endif
		mov		eax,[edi].CHARS.len
		add		cp,eax
		or		edx,edx
		je		@b
	  @@:
		add		rect.top,edx
		mov		edx,rect.top
	.endw
	;Restore old font
	pop		eax
	invoke SelectObject,ps.hdc,eax
	;Restore old pen
	pop		eax
	invoke SelectObject,ps.hdc,eax
	invoke EndPaint,hWin,addr ps
	invoke DeleteObject,hRgn1
	invoke GetFocus
	.if eax==hWin
		.if [ebx].EDIT.fCaretHide
			invoke ShowCaret,hWin
			mov		[ebx].EDIT.fCaretHide,FALSE
		.endif
	.endif
	ret

DrawBlockMarker:
	invoke DrawChangedState,ebx,ps.hdc,edi,0,rect1.top
	test	[edi].CHARS.state,STATE_BLOCK
	.if !ZERO?
		mov		eax,[ebx].EDIT.linenrwt
		add		eax,15
		mov		edx,rect1.top
		push	eax
		invoke MoveToEx,ps.hdc,eax,edx,NULL
		pop		eax
		mov		edx,[ebx].EDIT.fntinfo.fntht
		add		edx,rect1.top
		invoke LineTo,ps.hdc,eax,edx
	.endif
	test	[edi].CHARS.state,STATE_BLOCKEND
	.if !ZERO?
		mov		eax,[ebx].EDIT.linenrwt
		add		eax,15
		mov		edx,rect1.top
		push	eax
		invoke MoveToEx,ps.hdc,eax,edx,NULL
		pop		eax
		mov		edx,[ebx].EDIT.fntinfo.fntht
		shr		edx,1
		add		edx,rect1.top
		push	edx
		invoke LineTo,ps.hdc,eax,edx
		pop		edx
		mov		eax,[ebx].EDIT.linenrwt
		add		eax,SELWT-4
		invoke LineTo,ps.hdc,eax,edx
	.endif
	retn

DrawPageBreak:
	mov		ecx,[ebx].EDIT.nPageBreak
	.if ecx
		mov		eax,esi
		xor		edx,edx
		div		ecx
		.if !edx
			mov		edx,[ebx].EDIT.fntinfo.fntht
			add		edx,rect1.top
			dec		edx
			invoke MoveToEx,ps.hdc,0,edx,NULL
			mov		eax,[ebx].EDIT.selbarwt
			add		eax,[ebx].EDIT.linenrwt
			mov		edx,[ebx].EDIT.fntinfo.fntht
			add		edx,rect1.top
			dec		edx
			invoke LineTo,ps.hdc,eax,edx
		.endif
	.endif
	retn

RAEditPaintNoBuff endp

xSetCursor proc, NewCursor:DWORD, ParamIsHandle:BOOL
	
	LOCAL	hCursor:HCURSOR	
	
	.if ParamIsHandle
		invoke GetCursor
		.if eax != NewCursor
			invoke ShowCursor, FALSE                ; *** MOD
			invoke SetCursor, NewCursor
			invoke ShowCursor, TRUE
		.endif
	.else
		invoke LoadCursor, 0, NewCursor             ; NewCursor MUST be a "predefined cursor"
		mov hCursor, eax
		invoke GetCursor
		.if eax != hCursor
			invoke ShowCursor, FALSE                ; *** MOD
			invoke SetCursor, hCursor
			invoke ShowCursor, TRUE
		.endif
	.endif	
	ret
	
xSetCursor endp	