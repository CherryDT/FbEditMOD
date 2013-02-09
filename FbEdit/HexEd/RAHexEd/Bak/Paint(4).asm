
.code

HexAddr:
  @@:
	call	Nybble
	mov		[edi],dl
	inc		edi
	dec		ecx
	jne		@b
	mov		[edi],cl
	retn

HexByte:
	mov		al,[esi+ebx]
	shl		eax,24
	call	Nybble
	mov		[edi],dl
	inc		edi
	call	Nybble
	mov		[edi],dl
	inc		edi
	inc		ecx
	inc		ebx
	.if ecx==8
		mov		word ptr [edi],'-'
	.else
		mov		word ptr [edi],' '
	.endif
	inc		edi
	retn

Nybble:
	rol		eax,4
	push	eax
	and		eax,0Fh
	.if eax<=9
		add		eax,'0'
	.else
		add		eax,hex
	.endif
	mov		edx,eax
	pop		eax
	retn

Ascii:
	.if ecx<16
		push	ecx
		sub		ecx,16
		neg		ecx
		mov		eax,ecx
		shl		ecx,1
		add		ecx,eax
		mov		al,' '
		rep stosb
		pop		ecx
	.endif
	sub		ebx,ecx
	push	ecx
	.while ecx
		mov		al,[esi+ebx]
		.if al<20h || al>7Eh
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ebx
		dec		ecx
	.endw
	pop		ecx
	sub		ecx,16
	neg		ecx
	mov		al,' '
	rep stosb
	retn

HexLine proc uses ebx esi edi,lpMem:DWORD,fstyle:DWORD,nBytes:DWORD,nLine:DWORD,nOfs:DWORD,lpString:DWORD

	mov		esi,lpMem
	mov		edi,lpString
	mov		byte ptr [edi],0
	mov		ebx,nLine
	shl		ebx,4
	.if ebx<=nBytes
		mov		eax,ebx
		sub		eax,nOfs
		test	fstyle,HEX_STYLE_ADDRESSBITS16 or HEX_STYLE_ADDRESSBITS8
		.if ZERO?
			mov		ecx,8
		.else
			test	fstyle,HEX_STYLE_ADDRESSBITS16
			.if ZERO?
				mov		ecx,4
				shl		eax,16
			.else
				mov		ecx,2
				shl		eax,24
			.endif
		.endif
		push	edi
		call	HexAddr
		pop		edi
		lea		edi,[edi+8]
		xor		ecx,ecx
		.while ebx<nBytes && ecx<16
			call	HexByte
		.endw
		call	Ascii
		xor		eax,eax
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

HexLine endp

HexPaint proc uses ebx esi edi,hWin:HWND
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	lpMem:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	cpx:DWORD
	LOCAL	hRgn:DWORD
	LOCAL	nSt:DWORD
	LOCAL	nEn:DWORD
	LOCAL	nLeft:DWORD
	LOCAL	nHilite:DWORD
	LOCAL	nRight:DWORD
	LOCAL	selbr:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		edx,[ebx].EDIT.br.hBrLfSelBck
	mov		eax,hWin
	.if eax==[ebx].EDIT.focus
		mov		edx,[ebx].EDIT.br.hBrSelBck
	.endif
	mov		selbr,edx
	mov		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	mov		edx,SW_SHOWNA
	.if !eax
		mov		edx,SW_HIDE
	.endif
	invoke ShowWindow,[ebx].EDIT.hsta,edx
	test	[ebx].EDIT.fstyle,HEX_STYLE_NOUPPERCASE
	.if ZERO?
		mov		hex,'A'-10
	.else
		mov		hex,'a'-10
	.endif
	mov		eax,[ebx].EDIT.cpMin
	mov		ecx,[ebx].EDIT.cpMax
	shr		eax,1
	shr		ecx,1
	.if eax>ecx
		xchg	eax,ecx
	.endif
	mov		nSt,eax
	mov		nEn,ecx
	mov		eax,[ebx].EDIT.cpx
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mul		ecx
	mov		cpx,eax
	invoke GetClientRect,hWin,addr rect
	invoke BeginPaint,hWin,addr ps
	invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hFont
	push	eax
	invoke SelectObject,ps.hdc,[ebx].EDIT.br.hPenSelbar
	push	eax
	invoke SetBkMode,ps.hdc,TRANSPARENT
	invoke GlobalLock,[ebx].EDIT.hmem
	mov		lpMem,eax
	mov		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	.if !eax
		dec		eax
	.endif
	add		eax,SPCWT
	mov		rect.left,eax
	mov		eax,[ebx].EDIT.fstyle
	and		eax,HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
	.if eax!=HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
		sub		rect.right,SBWT
	.endif
	invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
	mov		hRgn,eax
	sub		rect.left,SPCWT-1
	xor		edx,edx
	mov		edi,[esi].HEEDT.nline
	.while edx<rect.bottom
		push	edx
		mov		eax,rect.top
		.if eax<ps.rcPaint.bottom
			add		eax,[ebx].EDIT.fntinfo.fntht
			.if eax>ps.rcPaint.top
				push	rect.bottom
				mov		rect.bottom,eax
				invoke FillRect,ps.hdc,addr rect,[ebx].EDIT.br.hBrBck
				invoke SelectClipRgn,ps.hdc,hRgn
				push	edi
				test	[ebx].EDIT.fstyle,HEX_STYLE_NOADDRESS
				.if ZERO?
					mov		edi,[ebx].EDIT.dataxp
					add		edi,[ebx].EDIT.linenrwt
					add		edi,[ebx].EDIT.selbarwt
					sub		edi,cpx
					sub		edi,SPCWT+1
					invoke MoveToEx,ps.hdc,edi,0,NULL
					invoke LineTo,ps.hdc,edi,rect.bottom
				.endif
				test	[ebx].EDIT.fstyle,HEX_STYLE_NOASCII
				.if ZERO?
					mov		edi,[ebx].EDIT.asciixp
					add		edi,[ebx].EDIT.linenrwt
					add		edi,[ebx].EDIT.selbarwt
					sub		edi,cpx
					sub		edi,SPCWT+1
					invoke MoveToEx,ps.hdc,edi,0,NULL
					invoke LineTo,ps.hdc,edi,rect.bottom
				.endif
				pop		edi
				invoke HexLine,lpMem,[ebx].EDIT.fstyle,[ebx].EDIT.nbytes,edi,[ebx].EDIT.ofs,addr buffer
				mov		esi,eax
				.if eax
					call	DrawSelBack
					invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hFont
					test	[ebx].EDIT.fstyle,HEX_STYLE_NOADDRESS
					.if ZERO?
						invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.adrtxtcol
						mov		edx,[ebx].EDIT.addrxp
						add		edx,[ebx].EDIT.linenrwt
						add		edx,[ebx].EDIT.selbarwt
						sub		edx,cpx
						test	[ebx].EDIT.fstyle,HEX_STYLE_ADDRESSBITS16 or HEX_STYLE_ADDRESSBITS8
						.if ZERO?
							mov		ecx,8
						.else
							test	[ebx].EDIT.fstyle,HEX_STYLE_ADDRESSBITS16
							.if ZERO?
								mov		ecx,4
							.else
								mov		ecx,2
							.endif
						.endif
						invoke TextOut,ps.hdc,edx,rect.top,addr buffer,ecx
					.endif
					mov		edx,[ebx].EDIT.dataxp
					add		edx,[ebx].EDIT.linenrwt
					add		edx,[ebx].EDIT.selbarwt
					sub		edx,cpx
					.if nHilite
						.if nLeft
							push	edx
							invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
							pop		edx
							mov		eax,nLeft
							shl		eax,1
							add		eax,nLeft
							push	eax
							push	edx
							invoke TextOut,ps.hdc,edx,rect.top,addr buffer[8],eax
							pop		ecx
							pop		eax
							mov		edx,[ebx].EDIT.fntinfo.fntwt
							mul		edx
							mov		edx,ecx
							add		edx,eax
						.endif
						push	edx
						invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.seltxtcol
						pop		edx
						mov		eax,nHilite
						shl		eax,1
						add		eax,nHilite
						mov		ecx,nLeft
						shl		ecx,1
						add		ecx,nLeft
						push	eax
						push	edx
						invoke TextOut,ps.hdc,edx,rect.top,addr buffer[ecx+8],eax
						pop		ecx
						pop		eax
						dec		eax
						mov		edx,[ebx].EDIT.fntinfo.fntwt
						mul		edx
						mov		edx,ecx
						add		edx,eax
						.if nRight
							push	edx
							invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
							pop		edx
							mov		eax,nRight
							shl		eax,1
							add		eax,nRight
							mov		ecx,nLeft
							add		ecx,nHilite
							shl		ecx,1
							add		ecx,nLeft
							add		ecx,nHilite
							dec		ecx
							inc		eax
							invoke TextOut,ps.hdc,edx,rect.top,addr buffer[ecx+8],eax
						.endif
					.else
						push	edx
						invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
						pop		edx
						invoke TextOut,ps.hdc,edx,rect.top,addr buffer[8],47
					.endif
					test	[ebx].EDIT.fstyle,HEX_STYLE_NOASCII
					.if ZERO?
						call	DrawSelAsciiBack
						;.if nHilite                                                 ; *** MOD
							;invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.asctxtcol     ; *** MOD
						;.else                                                       ; *** MOD 
						;	invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol     ; *** MOD
						;.endif	                                                    ; *** MOD
						mov		edx,[ebx].EDIT.asciixp
						add		edx,[ebx].EDIT.linenrwt
						add		edx,[ebx].EDIT.selbarwt
						sub		edx,cpx


						PrintDec nLeft
						PrintDec nRight
						PrintDec nHilite
						
						.if nHilite
							.if nLeft
								push	edx
								invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
								pop		edx
								mov		eax,nLeft
								push	eax
								push	edx
								invoke TextOut,ps.hdc,edx,rect.top,addr buffer[8+47+1],eax
								pop		ecx
								pop		eax
								mov		edx,[ebx].EDIT.fntinfo.fntwt
								mul		edx
								mov		edx,ecx
								add		edx,eax
							.endif
							push	edx
							invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.seltxtcol
							pop		edx
							mov		eax,nHilite
							mov		ecx,nLeft
							push	eax
							push	edx
							invoke TextOut,ps.hdc,edx,rect.top,addr buffer[ecx+8+47+1],eax
							pop		ecx
							pop		eax
							;dec		eax
							mov		edx,[ebx].EDIT.fntinfo.fntwt
							mul		edx
							mov		edx,ecx
							add		edx,eax
							.if nRight
								push	edx
								invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
								pop		edx
								mov		eax,nRight
								mov		ecx,nLeft
								add		ecx,nHilite
								dec		ecx
								inc		eax
								invoke TextOut,ps.hdc,edx,rect.top,addr buffer[ecx+8+47+1],eax
							.endif
						.else
							push	edx
							invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.dtatxtcol
							pop		edx
							invoke TextOut,ps.hdc,edx,rect.top,addr buffer[8+47+1],16
						.endif































						;invoke TextOut,ps.hdc,edx,rect.top,addr buffer[8+47+1],16
					.endif
				.endif
				invoke SelectClipRgn,ps.hdc,NULL
				push	rect.left
				push	rect.right
				mov		rect.left,0
				mov		eax,[ebx].EDIT.linenrwt
				add		eax,[ebx].EDIT.selbarwt
				.if eax
					mov		rect.right,eax
					invoke FillRect,ps.hdc,addr rect,[ebx].EDIT.br.hBrSelBar
					invoke MoveToEx,ps.hdc,rect.right,0,NULL
					invoke LineTo,ps.hdc,rect.right,rect.bottom
					.if esi
						invoke FindBookmark,[ebx].EDIT.hwnd,edi
						.if eax!=-1
							mov		eax,[ebx].EDIT.selbarwt
							add		eax,[ebx].EDIT.linenrwt
							sub		eax,12
							mov		edx,[ebx].EDIT.fntinfo.fntht
							sub		edx,7
							shr		edx,1
							add		edx,rect.top
							invoke ImageList_Draw,hIml,2,ps.hdc,eax,edx,ILD_NORMAL
						.endif
					.endif
					mov		eax,[ebx].EDIT.linenrwt
					.if eax && esi
						mov		rect.right,eax
						dec		rect.bottom
						invoke SelectObject,ps.hdc,[ebx].EDIT.fnt.hLnrFont
						mov		edx,edi
						inc		edx
						invoke DwToAscii,edx,addr buffer
						invoke SetTextColor,ps.hdc,[ebx].EDIT.clr.lnrcol
						invoke DrawText,ps.hdc,addr buffer,-1,addr rect,DT_RIGHT or DT_SINGLELINE or DT_BOTTOM; or DT_VCENTER;
					.endif
				.endif
				pop		rect.right
				pop		rect.left
				pop		rect.bottom
			.endif
		.endif
		pop		edx
		inc		edi
		add		edx,[ebx].EDIT.fntinfo.fntht
		mov		rect.top,edx
	.endw
	invoke GlobalUnlock,[ebx].EDIT.hmem
	;Restore pen
	pop		eax
	invoke SelectObject,ps.hdc,eax
	;Restore font
	pop		eax
	invoke SelectObject,ps.hdc,eax
	invoke DeleteObject,hRgn
	invoke EndPaint,hWin,addr ps
	ret

DrawSelBack:
	xor		eax,eax
	mov		nLeft,eax
	mov		nHilite,eax
	mov		nRight,eax
	mov		eax,nSt
	mov		ecx,nEn
	mov		edx,edi
	shl		edx,4
	.if eax>=edx && eax!=ecx
		sub		eax,edx
		.if eax<16
			mov		nLeft,eax
			add		edx,16
			.if ecx<=edx
				sub		edx,ecx
				mov		nRight,edx
				sub		ecx,eax

				mov		edx,edi
				shl		edx,4
				sub		ecx,edx
				mov		nHilite,ecx
			.else
				.if edx>16
					mov		edx,16
				.endif
				sub		edx,eax
				mov		nHilite,edx
			.endif
		.endif
	.elseif ecx>edx && eax!=ecx
		sub		ecx,edx
		.if ecx>16
			mov		ecx,16
		.endif
		mov		nHilite,ecx
		mov		eax,16
		sub		eax,ecx
		mov		nRight,eax
	.endif
	.if nHilite
		push	rect.left
		push	rect.right
		mov		eax,[ebx].EDIT.cpx
		mov		edx,[ebx].EDIT.fntinfo.fntwt
		mul		edx
		mov		edx,eax
		mov		eax,[ebx].EDIT.dataxp
		add		eax,[ebx].EDIT.linenrwt
		add		eax,[ebx].EDIT.selbarwt
		sub		eax,edx
		mov		rect.left,eax
		add		eax,[ebx].EDIT.datawt
		mov		rect.right,eax
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		mov		eax,nLeft
		mul		ecx
		mov		edx,3
		mul		edx
		add		rect.left,eax
		mov		eax,nRight
		mul		ecx
		mov		edx,3
		mul		edx
		sub		rect.right,eax
		invoke FillRect,ps.hdc,addr rect,selbr;[ebx].EDIT.br.hBrSelBck
		pop		rect.right
		pop		rect.left
	.endif
	retn

DrawSelAsciiBack:
	xor		eax,eax
	mov		nLeft,eax
	mov		nHilite,eax
	mov		nRight,eax
	mov		eax,nSt
	mov		ecx,nEn
	.if eax==ecx
		inc		ecx
	.endif
	mov		edx,edi
	shl		edx,4
	.if eax>=edx && eax!=ecx
		sub		eax,edx
		.if eax<16
			mov		nLeft,eax
			add		edx,16
			.if ecx<=edx
				sub		edx,ecx
				mov		nRight,edx
				sub		ecx,eax

				mov		edx,edi
				shl		edx,4
				sub		ecx,edx
				mov		nHilite,ecx
			.else
				.if edx>16
					mov		edx,16
				.endif
				sub		edx,eax
				mov		nHilite,edx
			.endif
		.endif
	.elseif ecx>edx && eax!=ecx
		sub		ecx,edx
		.if ecx>16
			mov		ecx,16
		.endif
		mov		nHilite,ecx
		mov		eax,16
		sub		eax,ecx
		mov		nRight,eax
	.endif
	.if nHilite
		push	rect.left
		push	rect.right
		mov		eax,[ebx].EDIT.cpx
		mov		edx,[ebx].EDIT.fntinfo.fntwt
		mul		edx
		mov		edx,eax
		mov		eax,[ebx].EDIT.asciixp
		add		eax,[ebx].EDIT.linenrwt
		add		eax,[ebx].EDIT.selbarwt
		sub		eax,edx
		mov		rect.left,eax
		add		eax,[ebx].EDIT.asciiwt
		mov		rect.right,eax
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		mov		eax,nLeft
		mul		ecx
		add		rect.left,eax
		mov		eax,nRight
		mul		ecx
		sub		rect.right,eax
		invoke FillRect,ps.hdc,addr rect,[ebx].EDIT.br.hBrAscSelBck
		pop		rect.right
		pop		rect.left
	.endif
	retn

HexPaint endp

InvalidateLine proc uses ebx esi,hWin:HWND,cp:DWORD
	LOCAL	rect:RECT

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	invoke CopyRect,addr rect,addr [esi].HEEDT.rc
	mov		eax,cp
	shr		eax,5
	sub		eax,[esi].HEEDT.nline
	.if !CARRY?
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		mul		ecx
		.if eax<rect.bottom
			mov		rect.top,eax
			add		eax,ecx
			mov		rect.bottom,eax
			invoke InvalidateRect,hWin,addr rect,TRUE
		.endif
	.endif
	ret

InvalidateLine endp

InvalidateSelection proc uses ebx esi,hWin:HWND,cpMin:DWORD,cpMax:DWORD
	LOCAL	rect:RECT

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		eax,cpMin
	mov		ecx,cpMax
	shr		eax,5
	shr		ecx,5
	.if eax>ecx
		xchg	eax,ecx
	.endif
	.if eax<[esi].HEEDT.nline
		mov		eax,[esi].HEEDT.nline
	.endif
	.while eax<=ecx
		push	eax
		push	ecx
		push	eax
		invoke CopyRect,addr rect,addr [esi].HEEDT.rc
		pop		eax
		sub		eax,[esi].HEEDT.nline
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		mul		ecx
		.if eax<rect.bottom
			mov		rect.top,eax
			add		eax,ecx
			mov		rect.bottom,eax
			invoke InvalidateRect,hWin,addr rect,TRUE
		.else
			pop		eax
			pop		eax
			.break
		.endif
		pop		ecx
		pop		eax
		inc		eax
	.endw
	ret

InvalidateSelection endp

