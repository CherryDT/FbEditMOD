
.code

GetTopFromYp proc uses ebx esi edi,hMem:DWORD,hWin:DWORD,yp:DWORD
	LOCAL	cp:DWORD

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		edx,[ebx].EDIT.edta
	.else
		lea		edx,[ebx].EDIT.edtb
	.endif
	push	edx
	mov		esi,[ebx].EDIT.hLine
	push	[ebx].EDIT.hChars
	push	edx
	mov		edi,[ebx].EDIT.fntinfo.fntht
	mov		eax,yp
	xor		edx,edx
	div		edi
	mul		edi
	mov		yp,eax
	pop		edx
	mov		ecx,[edx].RAEDT.topln
	.if eax>=[edx].RAEDT.topyp
		sub		eax,[edx].RAEDT.topyp
		xor		edx,edx
		div		edi
		pop		edi
		mov		cp,0
		.if eax
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
		  Nxt1:
			mov		edx,[edi+edx].CHARS.len
			add		cp,edx
			lea		edx,[ecx*sizeof LINE]
			.if edx<[ebx].EDIT.rpLineFree
				inc		ecx
				mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
				test	[edi+edx].CHARS.state,STATE_HIDDEN
				jne		Nxt1
				dec		eax
				jne		Nxt1
			.endif
		.endif
	.else
		sub		eax,[edx].RAEDT.topyp
		neg		eax
		xor		edx,edx
		div		edi
		pop		edi
		mov		cp,0
		.if eax
		  Nxt2:
			.if !ecx
				pop		esi
				push	esi
				mov		[esi].RAEDT.topcp,ecx
				mov		cp,ecx
				mov		yp,ecx
				jmp		@f
			.endif
			dec		ecx
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			push	eax
			mov		eax,[edi+edx].CHARS.len
			sub		cp,eax
			pop		eax
			test	[edi+edx].CHARS.state,STATE_HIDDEN
			jne		Nxt2
			dec		eax
			jne		Nxt2
		.endif
	.endif
  @@:
	pop		esi
	mov		eax,cp
	add		[esi].RAEDT.topcp,eax
	mov		[esi].RAEDT.topln,ecx
	mov		eax,yp
	mov		[esi].RAEDT.topyp,eax
	.if ![ebx].EDIT.edta.rc.bottom
		lea		edx,[ebx].EDIT.edta
		push	[esi].RAEDT.cpy
		pop		[edx].RAEDT.cpy
		push	[esi].RAEDT.topyp
		pop		[edx].RAEDT.topyp
		push	[esi].RAEDT.topln
		pop		[edx].RAEDT.topln
		push	[esi].RAEDT.topcp
		pop		[edx].RAEDT.topcp
	.endif
	ret

GetTopFromYp endp

;eax=Char index in line
;ecx=Char index
;edx=Line number
GetCharPtr proc uses ebx esi edi,hMem:DWORD,cp:DWORD
	LOCAL	rpLineMax:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hLine
	mov		eax,[ebx].EDIT.rpLineFree
	add		eax,esi
	mov		rpLineMax,eax
	mov		edi,[ebx].EDIT.hChars
	xor		ecx,ecx
	mov		eax,cp
	mov		edx,[ebx].EDIT.cpLine
	.if eax>=edx
		mov		ecx,edx
		add		esi,[ebx].EDIT.rpLine
	.else
		shr		edx,1
		.if eax>=edx
			mov		ecx,[ebx].EDIT.cpLine
			add		esi,[ebx].EDIT.rpLine
			.while ecx>eax
				sub		esi,sizeof LINE
				mov		edx,[esi].LINE.rpChars
				sub		ecx,[edi+edx].CHARS.len
			.endw
		.endif
	.endif
	mov		ebx,sizeof LINE
  @@:
	.if esi>=rpLineMax
		xor		edx,edx
		dec		edx
		jmp		@f
	.endif
	mov		edx,[esi].LINE.rpChars
	add		ecx,[edi+edx].CHARS.len
	add		esi,ebx
	cmp		eax,ecx
	jnc		@b
	sub		ecx,[edi+edx].CHARS.len
  @@:
	mov		ebx,hMem
	sub		esi,sizeof LINE
	mov		edi,[ebx].EDIT.hChars
	add		edi,[esi].LINE.rpChars
	inc		edx
	.if !ZERO?
		push	ecx
		mov		[ebx].EDIT.cpLine,ecx
		sub		ecx,eax
		neg		ecx
		pop		eax
		add		eax,ecx
		push	eax
	.else
		push	ecx
		sub		ecx,[edi].CHARS.len
		mov		[ebx].EDIT.cpLine,ecx
		mov		ecx,[edi].CHARS.len
	.endif
	sub		esi,[ebx].EDIT.hLine
	mov		[ebx].EDIT.rpLine,esi
	mov		edx,esi
	shr		edx,2
	sub		edi,[ebx].EDIT.hChars
	mov		[ebx].EDIT.rpChars,edi
	mov		[ebx].EDIT.line,edx
	mov		eax,ecx
	pop		ecx
	ret

GetCharPtr endp

;eax=Char index
GetCpFromLine proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hLine
	mov		edi,[ebx].EDIT.hChars
	mov		ecx,nLine
	shl		ecx,2
	.if ecx>=[ebx].EDIT.rpLineFree
		mov		ecx,[ebx].EDIT.rpLineFree
		sub		ecx,sizeof LINE
	.endif
	shr		ecx,2
	mov		nLine,ecx
	.if ecx>=[ebx].EDIT.edtb.topln
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		eax,[ebx].EDIT.edtb.topcp
		.while ecx<nLine
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			add		eax,[edi+edx].CHARS.len
			inc		ecx
		.endw
	.else
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		eax,[ebx].EDIT.edtb.topcp
		.while ecx>nLine
			dec		ecx
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			sub		eax,[edi+edx].CHARS.len
		.endw
	.endif
	ret

GetCpFromLine endp

GetLineFromCp proc uses ebx esi edi,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hLine
	mov		edi,[ebx].EDIT.hChars
	mov		eax,cp
	.if eax>=[ebx].EDIT.edtb.topcp
		mov		eax,[ebx].EDIT.edtb.topcp
		mov		ecx,[ebx].EDIT.edtb.topln
		.while eax<cp
			lea		edx,[ecx*4]
			.break.if edx>=[ebx].EDIT.rpLineFree
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			add		eax,[edi+edx].CHARS.len
			inc		ecx
		.endw
		.if eax>cp
			dec		ecx
		.endif
		mov		eax,ecx
		shl		eax,2
		.if eax>=[ebx].EDIT.rpLineFree
			mov		ecx,[ebx].EDIT.rpLineFree
			shr		ecx,2
			dec		ecx
		.endif
	.else
		mov		eax,[ebx].EDIT.edtb.topcp
		mov		ecx,[ebx].EDIT.edtb.topln
		.while eax>cp
			dec		ecx
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			sub		eax,[edi+edx].CHARS.len
		.endw
	.endif
	mov		eax,ecx
	ret

GetLineFromCp endp

GetYpFromLine proc uses ebx esi edi,hMem:DWORD,nLine:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hLine
	mov		edi,[ebx].EDIT.hChars
	mov		ecx,nLine
	shl		ecx,2
	.if ecx>=[ebx].EDIT.rpLineFree
		mov		ecx,[ebx].EDIT.rpLineFree
		sub		ecx,sizeof LINE
	.endif
	shr		ecx,2
	mov		nLine,ecx
	.if ecx>=[ebx].EDIT.edtb.topln
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		eax,[ebx].EDIT.edtb.topyp
		mov		edx,[ebx].EDIT.fntinfo.fntht
		mov		ebx,edx
		.while ecx<nLine
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			test	[edi+edx].CHARS.state,STATE_HIDDEN
			jne		@f
			add		eax,ebx
		  @@:
			inc		ecx
		.endw
	.else
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		eax,[ebx].EDIT.edtb.topyp
		mov		edx,[ebx].EDIT.fntinfo.fntht
		mov		ebx,edx
		.while ecx>nLine
			dec		ecx
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			test	[edi+edx].CHARS.state,STATE_HIDDEN
			jne		@f
			sub		eax,ebx
		  @@:
		.endw
	.endif
	ret

GetYpFromLine endp

GetLineFromYp proc uses ebx esi edi,hMem:DWORD,y:DWORD
	LOCAL	maxln:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.rpLineFree
	shr		eax,2
	dec		eax
	mov		maxln,eax
	mov		esi,[ebx].EDIT.hLine
	mov		edi,[ebx].EDIT.hChars
	mov		eax,y
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	xor		edx,edx
	div		ecx
	mul		ecx
	mov		y,eax
	.if eax>=[ebx].EDIT.edtb.topyp
		mov		eax,[ebx].EDIT.edtb.topyp
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		edx,[ebx].EDIT.fntinfo.fntht
		mov		ebx,edx
		.while eax<y
			inc		ecx
			.break .if ecx>=maxln
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			test	[edi+edx].CHARS.state,STATE_HIDDEN
			jne		@f
			add		eax,ebx
		  @@:
		.endw
	.else
		mov		eax,[ebx].EDIT.edtb.topyp
		mov		ecx,[ebx].EDIT.edtb.topln
		mov		edx,[ebx].EDIT.fntinfo.fntht
		mov		ebx,edx
		.while eax>y
			dec		ecx
			mov		edx,[esi+ecx*sizeof LINE].LINE.rpChars
			test	[edi+edx].CHARS.state,STATE_HIDDEN
			jne		@f
			sub		eax,ebx
		  @@:
		.endw
	.endif
	mov		eax,ecx
	ret

GetLineFromYp endp

GetCpFromXp proc uses ebx esi edi,hMem:DWORD,lpChars:DWORD,x:DWORD,fNoAdjust:DWORD
	LOCAL	hDC:DWORD
	LOCAL	rect:RECT
	LOCAL	lastright:DWORD

	mov		ebx,hMem
	invoke GetDC,[ebx].EDIT.hwnd
	mov		hDC,eax
	invoke SelectObject,hDC,[ebx].EDIT.fnt.hFont
	push	eax
	mov		eax,[ebx].EDIT.cpx
	neg		eax
	add		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	sub		x,eax
	xor		eax,eax
	mov		rect.left,eax
	mov		rect.right,eax
	mov		rect.top,eax
	mov		rect.bottom,eax
	mov		lastright,eax
	mov		esi,lpChars
	mov		edi,[esi].CHARS.len
	shr		edi,1
	mov		edx,edi
	xor		ecx,ecx
  @@:
	push	ecx
	push	edx
	call	TestIt
	pop		edx
	pop		ecx
	shr		edx,1
	.if sdword ptr eax>x
		sub		edi,edx
		or		edx,edx
		jne		@b
	.elseif sdword ptr eax<x
		mov		eax,rect.right
		mov		lastright,eax
		mov		ecx,edi
		add		edi,edx
		or		edx,edx
		jne		@b
	.endif
	mov		edi,ecx
	.if edi
		mov		eax,lastright
		mov		rect.right,eax
	.else
		mov		rect.right,edi
	.endif
	.while edi<[esi].CHARS.len
		.break .if byte ptr [esi+edi+sizeof CHARS]==0Dh
		push	rect.right
		inc		edi
		call	TestIt
		dec		edi
		pop		edx
		.if !fNoAdjust
			sub		edx,eax
			neg		edx
			shr		edx,1
			sub		eax,edx
		.endif
		.break .if sdword ptr eax>x
		inc		edi
	.endw
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,[ebx].EDIT.hwnd,hDC
	mov		eax,edi
	ret

TestIt:
	invoke GetTextWidth,ebx,hDC,addr [esi+sizeof CHARS],edi,addr rect
	mov		eax,rect.right
	retn

GetCpFromXp endp

GetPosFromChar proc uses ebx esi,hMem:DWORD,cp:DWORD,lpPoint:DWORD
	LOCAL	hDC:HDC
	LOCAL	rect:RECT
	LOCAL	ln:DWORD
	LOCAL	y:DWORD

	mov		ebx,hMem
	invoke GetLineFromCp,ebx,cp
	mov		ln,eax
	invoke GetYpFromLine,ebx,ln
	mov		y,eax
	invoke GetCpFromLine,ebx,ln
	sub		cp,eax
	mov		esi,ln
	shl		esi,2
	add		esi,[ebx].EDIT.hLine
	mov		esi,[esi].LINE.rpChars
	add		esi,[ebx].EDIT.hChars
	invoke GetDC,[ebx].EDIT.hwnd
	mov		hDC,eax
	invoke SelectObject,hDC,[ebx].EDIT.fnt.hFont
	push	eax
	mov		rect.left,0
	mov		rect.right,0
	mov		rect.top,0
	mov		rect.bottom,0
	invoke GetTextWidth,ebx,hDC,addr [esi+sizeof CHARS],cp,addr rect
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,[ebx].EDIT.hwnd,hDC
	mov		esi,lpPoint
	mov		eax,rect.right
	add		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	inc		eax
	mov		[esi].POINT.x,eax
	mov		eax,y
	mov		[esi].POINT.y,eax
	ret

GetPosFromChar endp

GetCharFromPos proc uses ebx,hMem:DWORD,cpy:DWORD,x:DWORD,y:DWORD
	LOCAL	cp:DWORD

	mov		ebx,hMem
	mov		eax,y
	add		eax,cpy
	.if sdword ptr eax<0
		xor		eax,eax
	.else
		invoke GetLineFromYp,ebx,eax
	.endif
	push	eax
	invoke GetCpFromLine,ebx,eax
	mov		cp,eax
	mov		[ebx].EDIT.cpLine,eax
	pop		edx
	shl		edx,2
	.if edx>=[ebx].EDIT.rpLineFree
		mov		edx,[ebx].EDIT.rpLineFree
		sub		edx,sizeof LINE
	.endif
	mov		eax,edx
	shr		eax,2
	mov		[ebx].EDIT.line,eax
	mov		[ebx].EDIT.rpLine,edx
	add		edx,[ebx].EDIT.hLine
	mov		edx,[edx].LINE.rpChars
	mov		[ebx].EDIT.rpChars,edx
	add		edx,[ebx].EDIT.hChars
	mov		eax,x
	sub		eax,[ebx].EDIT.cpx
	je		Ex
	mov		eax,[ebx].EDIT.nMode
	and		eax,MODE_BLOCK
	invoke GetCpFromXp,ebx,edx,x,eax
	add		cp,eax
  Ex:
	mov		eax,cp
	ret

GetCharFromPos endp

GetCaretPoint proc uses ebx esi,hMem:DWORD,cp:DWORD,cpy:DWORD,lpPoint:DWORD
	LOCAL	pt:POINT

	mov		ebx,hMem
	invoke GetPosFromChar,ebx,cp,addr pt
	mov		esi,lpPoint
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if !ZERO?
		mov		eax,[ebx].EDIT.blrg.clMin
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		mul		ecx
		add		eax,[ebx].EDIT.linenrwt
		add		eax,[ebx].EDIT.selbarwt
	.else
		mov		eax,pt.x
	.endif
	sub		eax,[ebx].EDIT.cpx
	mov		[esi].POINT.x,eax
	mov		eax,pt.y
	sub		eax,cpy
	mov		[esi].POINT.y,eax
	ret

GetCaretPoint endp

SetCaret proc uses ebx,hMem:DWORD,cpy:DWORD
	LOCAL	pt:POINT

	mov		ebx,hMem
	invoke GetFocus
	.if eax==[ebx].EDIT.focus
		invoke GetCaretPoint,ebx,[ebx].EDIT.cpMin,cpy,addr pt
		invoke SetCaretPos,pt.x,pt.y
		mov		eax,[ebx].EDIT.selbarwt
		add		eax,[ebx].EDIT.linenrwt
		mov		ecx,pt.x
		inc		ecx
		mov		edx,[ebx].EDIT.cpMax
		sub		edx,[ebx].EDIT.cpMin
		.if sdword ptr eax<=pt.x && sdword ptr ecx<[ebx].EDIT.edtb.rc.right && !edx
			invoke ShowCaret,[ebx].EDIT.focus
			invoke ShowCaret,[ebx].EDIT.focus
			mov		[ebx].EDIT.fCaretHide,FALSE
		.elseif ![ebx].EDIT.fCaretHide
			invoke HideCaret,[ebx].EDIT.focus
			mov		[ebx].EDIT.fCaretHide,TRUE
		.endif
	.endif
	ret

SetCaret endp

ScrollEdit proc uses ebx esi,hMem:DWORD,hWin:DWORD,x:DWORD,y:DWORD

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	.if [esi].RAEDT.rc.bottom
		.if x || y
			.if x
				push	[esi].RAEDT.rc.left
				mov		eax,[ebx].EDIT.selbarwt
				add		eax,[ebx].EDIT.linenrwt
				add		[esi].RAEDT.rc.left,eax
				invoke ScrollWindow,hWin,x,0,addr [esi].RAEDT.rc,addr [esi].RAEDT.rc
				pop		[esi].RAEDT.rc.left
			.endif
			.if y
				invoke GetTopFromYp,ebx,[esi].RAEDT.hwnd,[esi].RAEDT.cpy
				mov		eax,y
				.if sdword ptr eax<0
					neg		eax
				.endif
				add		eax,[ebx].EDIT.fntinfo.fntht
				.if eax<[esi].RAEDT.rc.bottom
					invoke ScrollWindow,hWin,0,y,addr [esi].RAEDT.rc,addr [esi].RAEDT.rc
				.else
					invoke InvalidateRect,hWin,NULL,FALSE
				.endif
			.endif
			invoke UpdateWindow,hWin
			mov		eax,hWin
			.if eax==[ebx].EDIT.focus
				invoke SetCaret,ebx,[esi].RAEDT.cpy
			.endif
		.endif
	.endif
	ret

ScrollEdit endp

InvalidateEdit proc uses ebx esi,hMem:DWORD,hWin:DWORD

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	.if [esi].RAEDT.rc.bottom
		invoke GetTopFromYp,ebx,[esi].RAEDT.hwnd,[esi].RAEDT.cpy
		invoke InvalidateRect,[esi].RAEDT.hwnd,NULL,FALSE
;		invoke UpdateWindow,[esi].RAEDT.hwnd
	.endif
	ret

InvalidateEdit endp

InvalidateLine proc uses ebx esi,hMem:DWORD,hWin:DWORD,nLine:DWORD
	LOCAL	rect:RECT

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	.if [esi].RAEDT.rc.bottom
		invoke GetYpFromLine,ebx,nLine
		sub		eax,[esi].RAEDT.cpy
		mov		ecx,eax
		add		ecx,[ebx].EDIT.fntinfo.fntht
		.if sdword ptr ecx>0 && sdword ptr eax<[esi].RAEDT.rc.bottom
			mov		rect.top,eax
			add		eax,[ebx].EDIT.fntinfo.fntht
			mov		rect.bottom,eax
			mov		rect.left,0
			mov		eax,[esi].RAEDT.rc.right
			mov		rect.right,eax
			invoke InvalidateRect,hWin,addr rect,FALSE
		.endif
	.endif
	ret

InvalidateLine endp

InvalidateSelection proc uses ebx esi,hMem:DWORD,hWin:DWORD,cpMin:DWORD,cpMax:DWORD
	LOCAL	nLine:DWORD

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	.if [esi].RAEDT.rc.bottom
		mov		eax,cpMin
		.if eax>cpMax
			xchg	eax,cpMax
			mov		cpMin,eax
		.endif
		sub		eax,cpMax
		neg		eax
		.if eax<10000
			invoke GetCharPtr,ebx,cpMin
			mov		nLine,edx
			mov		eax,[ebx].EDIT.cpLine
		  @@:
			mov		cpMin,eax
			invoke InvalidateLine,ebx,hWin,nLine
			inc		nLine
			invoke GetCpFromLine,ebx,nLine
			.if eax<cpMax && eax!=cpMin
				jmp		@b
			.endif
		.else
			invoke InvalidateRect,hWin,NULL,FALSE
		.endif
	.endif
	ret

InvalidateSelection endp

SetCaretVisible proc uses ebx esi edi,hWin:DWORD,cpy:DWORD
	LOCAL	pt:POINT
	LOCAL	cpx:DWORD
	LOCAL	ht:DWORD
	LOCAL	fExpand:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		eax,[esi].RAEDT.rc.bottom
	.if sdword ptr eax>0
		mov		fExpand,0
		mov		ecx,[ebx].EDIT.line
		inc		ecx
	  @@:
		dec		ecx
		mov		eax,[ebx].EDIT.hLine
		mov		edx,[eax+ecx*sizeof LINE].LINE.rpChars
		add		edx,[ebx].EDIT.hChars
		mov		eax,[edx].CHARS.state
		and		eax,STATE_BMMASK
		.if eax==STATE_BM2
			push	ecx
			inc		fExpand
		.endif
		test	[edx].CHARS.state,STATE_HIDDEN
		jne		@b
		mov		edi,fExpand
		mov		fExpand,0
		.while edi
			pop		ecx
			.if ecx!=[ebx].EDIT.line
				invoke Expand,ebx,ecx
				inc		fExpand
			.endif
			dec		edi
		.endw
		mov		eax,[esi].RAEDT.rc.bottom
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		xor		edx,edx
		div		ecx
		.if !eax
			inc		eax
		.endif
		mul		ecx
		mov		ht,eax
		mov		eax,[ebx].EDIT.cpx
		mov		cpx,eax
		invoke GetYpFromLine,ebx,[ebx].EDIT.line
		.if eax<cpy
			mov		[esi].RAEDT.cpy,eax
		.else
			add		eax,[ebx].EDIT.fntinfo.fntht
			sub		eax,cpy
			sub		eax,ht
			.if !CARRY?
				add		[esi].RAEDT.cpy,eax
			.endif
		.endif
		invoke GetCaretPoint,ebx,[ebx].EDIT.cpMin,cpy,addr pt
		mov		edx,[esi].RAEDT.rc.right
		sub		edx,16
		mov		eax,pt.x
		mov		ecx,[ebx].EDIT.linenrwt
		add		ecx,[ebx].EDIT.selbarwt
		add		ecx,16+1
		.if sdword ptr eax<ecx
			.if sdword ptr eax>0
				mov		ecx,[ebx].EDIT.fntinfo.fntwt
				shl		ecx,3
				add		eax,ecx
				sub		[ebx].EDIT.cpx,eax
				jnb		@f
			.else
				mov		ecx,[ebx].EDIT.fntinfo.fntwt
				shl		ecx,3
				sub		eax,ecx
				add		[ebx].EDIT.cpx,eax
				jb		@f
			.endif
			mov		[ebx].EDIT.cpx,0
		  @@:
		.elseif eax>edx
			mov		ecx,[ebx].EDIT.fntinfo.fntwt
			shl		ecx,3
			sub		eax,edx
			add		eax,ecx
			add		[ebx].EDIT.cpx,eax
		.endif
		invoke GetTopFromYp,ebx,hWin,[esi].RAEDT.cpy
		mov		ecx,cpx
		sub		ecx,[ebx].EDIT.cpx
		mov		edx,cpy
		sub		edx,[esi].RAEDT.cpy
		xor		eax,eax
		dec		eax
		.if fExpand
			invoke InvalidateEdit,ebx,hWin
			xor		eax,eax
		.elseif ecx || edx
			.if ecx
				push	ecx
				push	edx
				invoke ScrollEdit,ebx,[ebx].EDIT.edta.hwnd,ecx,edx
				pop		edx
				pop		ecx
				invoke ScrollEdit,ebx,[ebx].EDIT.edtb.hwnd,ecx,edx
			.else
				invoke ScrollEdit,ebx,hWin,ecx,edx
			.endif
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
		dec		eax
	.endif
	ret

SetCaretVisible endp

GetBlockCp proc uses ebx edi,hMem:DWORD,nLine:DWORD,nPos:DWORD

	invoke GetCpFromLine,ebx,nLine
	mov		edi,eax
	mov		eax,nPos
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mul		ecx
	add		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	sub		eax,[ebx].EDIT.cpx
	mov		edx,nLine
	shl		edx,2
	.if edx>=[ebx].EDIT.rpLineFree
		mov		edx,[ebx].EDIT.rpLineFree
		sub		edx,sizeof LINE
	.endif
	add		edx,[ebx].EDIT.hLine
	mov		edx,[edx].LINE.rpChars
	add		edx,[ebx].EDIT.hChars
	invoke GetCpFromXp,ebx,edx,eax,TRUE
	add		eax,edi
	ret

GetBlockCp endp

SetCpxMax proc uses ebx esi,hMem:DWORD,hWin:DWORD
	LOCAL	pt:POINT

	mov		ebx,hMem
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	invoke GetCaretPos,addr pt
	mov		eax,pt.x
	sub		eax,[ebx].EDIT.selbarwt
	sub		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.cpx
	mov		[esi].RAEDT.cpxmax,eax
	ret

SetCpxMax endp

SetBlockFromCp proc uses ebx,hMem:DWORD,cp:DWORD,fShift:DWORD
	LOCAL	pt:POINT

	mov		ebx,hMem
	mov		eax,cp
	mov		[ebx].EDIT.cpMin,eax
	mov		[ebx].EDIT.cpMax,eax
	invoke GetCharPtr,ebx,cp
	invoke GetPosFromChar,ebx,cp,addr pt
	mov		eax,pt.x
	sub		eax,[ebx].EDIT.linenrwt
	sub		eax,[ebx].EDIT.selbarwt
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	cdq
	idiv		ecx
	.if sdword ptr eax<0
		xor		eax,eax
	.endif
	mov		edx,[ebx].EDIT.line
	mov		[ebx].EDIT.blrg.lnMin,edx
	mov		[ebx].EDIT.blrg.clMin,eax
	.if !fShift
		mov		[ebx].EDIT.blrg.lnMax,edx
		mov		[ebx].EDIT.blrg.clMax,eax
	.endif
	ret

SetBlockFromCp endp

AdjustTopLine proc uses ebx ecx, hMem:DWORD, CpMin:DWORD, CpMax:DWORD, CpTop:DWORD
	
	LOCAL NewCpTop:DWORD 
	
	
	PrintText "AdjustTopLine"
	
	mov ebx, hMem
	
	mov eax, CpMin
	.if eax > CpMax
		xchg	CpMax, eax
		mov		CpMin, eax
	.endif
	
;   PrintDec CpMin, "CpMin"
;   PrintDec CpMax, "CpMax"
;	PrintDec CpTopA, "CpTopA"
;	PrintDec CpTopB, "CpTopB"	
;	PrintDec CpAB, "CpAB"   
   
    mov eax, CpMin
	.if eax < CpTop
		mov sdword ptr eax, CpTop
		sub sdword ptr eax, CpMax
		add sdword ptr eax, CpMin
	.else
		mov eax, CpTop
	.endif
	.if sdword ptr eax < 0
		mov eax, 0
	.endif
	mov NewCpTop, eax

	invoke GetCharPtr, ebx, NewCpTop        ; edx = line number
	mov eax, edx
	mul [ebx].EDIT.fntinfo.fntht

	PrintText "******** End Adjust"	
	ret

AdjustTopLine endp