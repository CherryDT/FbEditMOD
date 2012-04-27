.code

SetFont proc uses ebx edi,hMem:DWORD,lpRafont:DWORD
	LOCAL	hDC:HDC
	LOCAL	dtp:DRAWTEXTPARAMS
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	tm:TEXTMETRIC
	LOCAL	buffer[4]:BYTE
	LOCAL	fFixed:DWORD

	mov		ebx,hMem
	mov		edx,lpRafont
	mov		eax,[edx].HEFONT.hFont
	mov		[ebx].EDIT.fnt.hFont,eax
	mov		eax,[edx].HEFONT.hLnrFont
	mov		[ebx].EDIT.fnt.hLnrFont,eax
	invoke GetDC,[ebx].EDIT.hwnd
	mov		hDC,eax
	invoke SelectObject,hDC,[ebx].EDIT.fnt.hFont
	push	eax
	mov		dword ptr buffer,'iiii'
	invoke GetTextExtentPoint32,hDC,addr buffer,4,addr pt
	mov		eax,pt.x
	mov		fFixed,eax
	mov		dword ptr buffer,'WWWW'
	invoke GetTextExtentPoint32,hDC,addr buffer,4,addr pt
	sub		fFixed,eax
	;Get height & width
	invoke GetTextExtentPoint32,hDC,addr szX,16,addr pt
	mov		eax,pt.x
	shr		eax,4
	mov		pt.x,eax
	mov		[ebx].EDIT.fntinfo.fntwt,eax
	mov		eax,pt.y
	add		eax,[ebx].EDIT.fntinfo.linespace
	mov		[ebx].EDIT.fntinfo.fntht,eax
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,0,hDC
	test	[ebx].EDIT.fstyle,HEX_STYLE_NOADDRESS
	.if ZERO?
		mov		[ebx].EDIT.addrxp,SPCWT
		mov		eax,pt.x
		test	[ebx].EDIT.fstyle,HEX_STYLE_ADDRESSBITS16 or HEX_STYLE_ADDRESSBITS8
		.if ZERO?
			shl		eax,3
		.else
			test	[ebx].EDIT.fstyle,HEX_STYLE_ADDRESSBITS16
			.if ZERO?
				shl		eax,2
			.else
				shl		eax,1
			.endif
		.endif
		mov		[ebx].EDIT.addrwt,eax
		add		eax,SPCWT*2+1
		add		eax,[ebx].EDIT.addrxp
	.else
		mov		[ebx].EDIT.addrxp,0
		mov		[ebx].EDIT.addrwt,0
		mov		eax,SPCWT
	.endif
	mov		[ebx].EDIT.dataxp,eax
	mov		eax,pt.x
	shl		eax,4
	mov		ecx,eax
	shl		eax,1
	add		eax,ecx
	sub		eax,pt.x
	mov		[ebx].EDIT.datawt,eax
	test	[ebx].EDIT.fstyle,HEX_STYLE_NOASCII
	.if ZERO?
		add		eax,SPCWT*2+1
		add		eax,[ebx].EDIT.dataxp
		mov		[ebx].EDIT.asciixp,eax
		mov		eax,pt.x
		shl		eax,4
		mov		[ebx].EDIT.asciiwt,eax
	.else
		mov		eax,[ebx].EDIT.dataxp
		add		eax,[ebx].EDIT.datawt
		mov		[ebx].EDIT.asciixp,eax
		mov		[ebx].EDIT.asciiwt,0
	.endif
	mov		eax,fFixed
	ret

SetFont endp

DestroyBrushes proc uses ebx,hMem:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.br.hBrBck
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrSelBck
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrLfSelBck
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrAscSelBck
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrSelBar
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hPenSelbar
	.if eax
		invoke DeleteObject,eax
	.endif
	ret

DestroyBrushes endp

CreateBrushes proc uses ebx,hMem:DWORD

	mov		ebx,hMem
	invoke DestroyBrushes,ebx
	invoke CreateSolidBrush,[ebx].EDIT.clr.bckcol
	mov		[ebx].EDIT.br.hBrBck,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.selbckcol
	mov		[ebx].EDIT.br.hBrSelBck,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.sellfbckcol
	mov		[ebx].EDIT.br.hBrLfSelBck,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.selascbckcol
	mov		[ebx].EDIT.br.hBrAscSelBck,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.selbarbck
	mov		[ebx].EDIT.br.hBrSelBar,eax
	invoke CreatePen,PS_SOLID,1,[ebx].EDIT.clr.selbarpen
	mov		[ebx].EDIT.br.hPenSelbar,eax
	ret

CreateBrushes endp

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

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

DwToAscii endp

ConvertHexString proc uses esi edi,lpStr:DWORD

	mov		esi,lpStr
	mov		edi,offset charbuff
  NxtByte:
	mov		al,[esi]
	.if al
		inc		esi
		.if (al>='0' && al<='9') || (al>='A' && al<='F') || (al>='a' && al<='f')
			.if al>='a'
				and		al,5Fh
			.endif
			.if al>='A'
				sub		al,'A'-10
			.else
				sub		al,'0'
			.endif
			shl		al,4
			mov		ah,al
		.else
			jmp		NxtByte
		.endif
	  NxtNybble:
		mov		al,[esi]
		.if al
			inc		esi
			.if (al>='0' && al<='9') || (al>='A' && al<='F') || (al>='a' && al<='f')
				.if al>='a'
					and		al,5Fh
				.endif
				.if al>='A'
					sub		al,'A'-10
				.else
					sub		al,'0'
				.endif
				or		ah,al
			.else
				jmp		NxtNybble
			.endif
		.endif
		mov		[edi],ah
		inc		edi
		cmp		edi,offset charbuff+sizeof charbuff
		jne		NxtByte
	.endif
	mov		eax,edi
	sub		eax,offset charbuff
	mov		edx,esi
	sub		edx,lpStr
	ret

ConvertHexString endp

SelChange proc uses ebx,hMem:DWORD,nSelTyp:DWORD
	LOCAL	hesel:HESELCHANGE

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.hwnd
	mov		hesel.nmhdr.hwndFrom,eax
	mov		eax,[ebx].EDIT.ID
	mov		hesel.nmhdr.idFrom,eax
	mov		hesel.nmhdr.code,EN_SELCHANGE

	mov		eax,[ebx].EDIT.cpMin
	mov		hesel.chrg.cpMin,eax
	mov		eax,[ebx].EDIT.cpMax
	mov		hesel.chrg.cpMax,eax

	mov		eax,nSelTyp
	mov		hesel.seltyp,ax
	mov		eax,[ebx].EDIT.cpMin
	shr		eax,5
	mov		hesel.line,eax
	mov		eax,[ebx].EDIT.nbytes
	shr		eax,4
	mov		hesel.nlines,eax

	mov		eax,[ebx].EDIT.fChanged
	mov		hesel.fchanged,eax
	invoke SendMessage,[ebx].EDIT.hpar,WM_NOTIFY,[ebx].EDIT.ID,addr hesel
	ret

SelChange endp

