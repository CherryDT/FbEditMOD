
.code

SetFont proc uses ebx edi,hMem:DWORD,lpRafont:DWORD
	LOCAL	hDC:HDC
	LOCAL	dtp:DRAWTEXTPARAMS
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	tm:TEXTMETRIC

	mov		ebx,hMem
	mov		edx,lpRafont
	mov		eax,[edx].RAFONT.hFont
	mov		[ebx].EDIT.fnt.hFont,eax
	mov		eax,[edx].RAFONT.hIFont
	mov		[ebx].EDIT.fnt.hIFont,eax
	mov		eax,[edx].RAFONT.hLnrFont
	mov		[ebx].EDIT.fnt.hLnrFont,eax
	invoke GetDC,[ebx].EDIT.hwnd
	mov		hDC,eax
	invoke SelectObject,hDC,[ebx].EDIT.fnt.hFont
	push	eax
	;Get height & width
	invoke GetTextExtentPoint32,hDC,addr szX,1,addr pt
	mov		eax,pt.x
	mov		[ebx].EDIT.fntinfo.fntwt,eax
	mov		eax,pt.y
	add		eax,[ebx].EDIT.fntinfo.linespace
	mov		[ebx].EDIT.fntinfo.fntht,eax
	;Test if monospaced font
	invoke GetTextExtentPoint32,hDC,addr szW,1,addr pt
	push	pt.x
	invoke GetTextExtentPoint32,hDC,addr szI,1,addr pt
	pop		eax
	.if eax==pt.x
		mov		[ebx].EDIT.fntinfo.monospace,TRUE
	.else
		mov		[ebx].EDIT.fntinfo.monospace,FALSE
	.endif
	;Get space width
	invoke GetTextExtentPoint32,hDC,addr szSpace,1,addr pt
	mov		eax,pt.x
	mov		[ebx].EDIT.fntinfo.spcwt,eax
	;Get tab width
	mov		dtp.cbSize,sizeof dtp
	mov		eax,[ebx].EDIT.nTab
	mov		dtp.iTabiLength,eax
	mov		dtp.iLeftMargin,0
	mov		dtp.iRightMargin,0
	mov		dtp.uiiLengthDrawn,0
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,0
	mov		rect.bottom,0
	invoke DrawTextEx,hDC,addr szTab,1,addr rect,DT_EDITCONTROL or DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_EXPANDTABS or DT_TABSTOP,addr dtp
	mov		eax,rect.right
	mov		[ebx].EDIT.fntinfo.tabwt,eax
	;Check if DBCS
	invoke GetTextMetrics,hDC,addr tm
	movzx	eax,byte ptr tm.tmCharSet
	mov		[ebx].EDIT.fntinfo.charset,eax
	;SHIFTJIS_CHARSET		equ 128
	;HANGEUL_CHARSET		equ 129
	;GB2312_CHARSET			equ 134
	;CHINESEBIG5_CHARSET	equ 136
	mov		[ebx].EDIT.fntinfo.fDBCS,0
	.if eax==134 || eax==136 || eax==128 || eax==129
		mov		[ebx].EDIT.fntinfo.fDBCS,eax
	.endif
	;Check if italic has same height
	invoke SelectObject,hDC,[ebx].EDIT.fnt.hIFont
	invoke GetTextExtentPoint32,hDC,addr szX,1,addr pt
	mov		eax,pt.y
	add		eax,[ebx].EDIT.fntinfo.linespace
	sub		eax,[ebx].EDIT.fntinfo.fntht
	mov		[ebx].EDIT.fntinfo.italic,eax
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,0,hDC
	ret

SetFont endp

SetColor proc uses ebx,hMem:DWORD,lpRAColor:DWORD

	mov		ebx,hMem
	assume edx:ptr RACOLOR
	mov		edx,lpRAColor
	mov		eax,[edx].RACOLOR.bckcol
	mov		[ebx].EDIT.clr.bckcol,eax
	mov		eax,[edx].RACOLOR.txtcol
	mov		[ebx].EDIT.clr.txtcol,eax
	mov		eax,[edx].RACOLOR.selbckcol
	mov		[ebx].EDIT.clr.selbckcol,eax
	mov		eax,[edx].RACOLOR.seltxtcol
	mov		[ebx].EDIT.clr.seltxtcol,eax
	mov		eax,[edx].RACOLOR.cmntcol
	mov		[ebx].EDIT.clr.cmntcol,eax
	mov		eax,[edx].RACOLOR.strcol
	mov		[ebx].EDIT.clr.strcol,eax
	mov		eax,[edx].RACOLOR.oprcol
	mov		[ebx].EDIT.clr.oprcol,eax
	mov		eax,[edx].RACOLOR.selbarbck
	mov		[ebx].EDIT.clr.selbarbck,eax
	mov		eax,[edx].RACOLOR.lnrcol
	mov		[ebx].EDIT.clr.lnrcol,eax
	assume edx:nothing
	ret

SetColor endp

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
	mov		eax,[ebx].EDIT.br.hBrHilite1
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrHilite2
	.if eax
		invoke DeleteObject,eax
	.endif
	mov		eax,[ebx].EDIT.br.hBrHilite3
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
	invoke CreateSolidBrush,[ebx].EDIT.clr.hicol1
	mov		[ebx].EDIT.br.hBrHilite1,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.hicol2
	mov		[ebx].EDIT.br.hBrHilite2,eax
	invoke CreateSolidBrush,[ebx].EDIT.clr.hicol3
	mov		[ebx].EDIT.br.hBrHilite3,eax
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

strlen proc lpSource:DWORD

	mov	eax,lpSource
	sub	eax,4
align 4
@@:
	add	eax, 4
	movzx	edx,word ptr [eax]
	test	dl,dl
	je	@lb1
	
	test	dh, dh
	je	@lb2
	
	movzx	edx,word ptr [eax+2]
	test	dl, dl
	je	@lb3

	test	dh, dh
	jne	@B
	
	sub	eax,lpSource
	add	eax,3
	ret

@lb3:
	sub	eax,lpSource
	add	eax,2
	ret

@lb2:
	sub	eax,lpSource
	add	eax,1
	ret

@lb1:
	sub	eax,lpSource
	ret

strlen endp

GetChar proc uses ebx,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	invoke GetCharPtr,ebx,cp
	shl		edx,2
	.if edx==[ebx].EDIT.rpLineFree
		xor		eax,eax
	.else
		add		eax,[ebx].EDIT.rpChars
		add		eax,[ebx].EDIT.hChars
		movzx	eax,byte ptr [eax+sizeof CHARS]
	.endif
	ret

GetChar endp

IsChar proc

	movzx	eax,al
	lea		eax,[eax+offset CharTab]
	mov		al,[eax]
	ret

IsChar endp

IsCharLeadByte proc uses ebx,hMem:DWORD,cp:DWORD

	mov		ebx,hMem
	.if [ebx].EDIT.fntinfo.fDBCS
		invoke GetCharPtr,ebx,cp
		mov		cp,eax
		mov		edx,[ebx].EDIT.rpChars
		add		edx,[ebx].EDIT.hChars
		add		edx,sizeof CHARS
		xor		ecx,ecx
		.while ecx<=cp
			mov		al,[edx+ecx]
			.if al>=80h
				inc		ecx
			.endif
			inc		ecx
		.endw
		sub		ecx,cp
		.if al>80h && ecx==2
			mov		eax,TRUE
		.else
			mov		eax,FALSE
		.endif
	.else
		mov		eax,FALSE
	.endif
	ret

IsCharLeadByte endp

GetTextWidth proc uses ebx,hMem:DWORD,hDC:HDC,lpText:DWORD,nChars:DWORD,lpRect:DWORD
	LOCAL	dtp:DRAWTEXTPARAMS

	mov		ebx,hMem
	.if [ebx].EDIT.fntinfo.monospace
		push	esi
		mov		eax,[ebx].EDIT.fntinfo.fntht
		mov		esi,lpRect
		add		eax,[esi].RECT.top
		mov		[esi].RECT.bottom,eax
		mov		esi,lpText
		xor		ecx,ecx
		xor		eax,eax
		.while ecx<nChars
			.if byte ptr [esi+ecx]==VK_TAB
				add		eax,[ebx].EDIT.nTab
				xor		edx,edx
				div		[ebx].EDIT.nTab
				mul		[ebx].EDIT.nTab
			.else
				inc		eax
			.endif
			inc		ecx
		.endw
		mul		[ebx].EDIT.fntinfo.fntwt
		mov		esi,lpRect
		add		eax,[esi].RECT.left
		mov		[esi].RECT.right,eax
		pop		esi
	.else
		mov		dtp.cbSize,sizeof dtp
		mov		eax,[ebx].EDIT.nTab
		mov		dtp.iTabiLength,eax
		xor		eax,eax
		mov		dtp.iLeftMargin,eax
		mov		dtp.iRightMargin,eax
		mov		dtp.uiiLengthDrawn,eax
		invoke DrawTextEx,hDC,lpText,nChars,lpRect,DT_EDITCONTROL or DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_EXPANDTABS or DT_TABSTOP,addr dtp
		mov		edx,lpRect
		mov		eax,[edx].RECT.top
		add		eax,[ebx].EDIT.fntinfo.fntht
		mov		[edx].RECT.bottom,eax
	.endif
	ret

GetTextWidth endp

GetBlockRange proc uses esi edi,lpSrc:DWORD,lpDst:DWORD

	mov		esi,lpSrc
	mov		edi,lpDst
	mov		eax,[esi].BLOCKRANGE.lnMin
	mov		edx,[esi].BLOCKRANGE.lnMax
	.if eax>edx
		xchg	eax,edx
	.endif
	mov		[edi].BLOCKRANGE.lnMin,eax
	mov		[edi].BLOCKRANGE.lnMax,edx
	mov		eax,[esi].BLOCKRANGE.clMin
	mov		edx,[esi].BLOCKRANGE.clMax
	.if eax>edx
		xchg	eax,edx
	.endif
	mov		[edi].BLOCKRANGE.clMin,eax
	mov		[edi].BLOCKRANGE.clMax,edx
	ret

GetBlockRange endp

GetBlockRects proc uses ebx esi edi,hMem:DWORD,lpRects:DWORD
	LOCAL	blrg:BLOCKRANGE

	mov		ebx,hMem
	invoke GetBlockRange,addr [ebx].EDIT.blrg,addr blrg
	mov		edi,lpRects
	lea		esi,[ebx].EDIT.edta
	call	GetRect
	add		edi,sizeof RECT
	lea		esi,[ebx].EDIT.edtb
	call	GetRect
	ret

GetRect:
	invoke GetYpFromLine,ebx,blrg.lnMin
	sub		eax,[esi].RAEDT.cpy
	mov		[edi].RECT.top,eax
	mov		eax,blrg.lnMax
	inc		eax
	invoke GetYpFromLine,ebx,eax
	sub		eax,[esi].RAEDT.cpy
	mov		[edi].RECT.bottom,eax
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mov		eax,blrg.clMin
	mul		ecx
	mov		[edi].RECT.left,eax
	mov		eax,blrg.clMax
	inc		eax
	mul		ecx
	mov		[edi].RECT.right,eax
	mov		eax,[ebx].EDIT.cpx
	neg		eax
	add		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	add		[edi].RECT.left,eax
	add		[edi].RECT.right,eax
	retn

GetBlockRects endp

InvalidateBlock proc uses ebx esi edi,hMem:DWORD,lpOldRects:DWORD
	LOCAL	newrects[2]:RECT
	LOCAL	rect:RECT
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.fntinfo.fntwt
	mov		wt,eax
	mov		eax,[ebx].EDIT.fntinfo.fntht
	mov		ht,eax
	mov		esi,lpOldRects
	lea		edi,newrects
	invoke GetBlockRects,ebx,edi
	mov		eax,[ebx].EDIT.edta.rc.bottom
	sub		eax,[ebx].EDIT.edta.rc.top
	.if eax
		mov		eax,[ebx].EDIT.edta.hwnd
		call	DoRect
	.endif
	add		esi,sizeof RECT
	add		edi,sizeof RECT
	mov		eax,[ebx].EDIT.edtb.hwnd
	call	DoRect
	ret

DoRect:
	push	ebx
	mov		ebx,eax
	;Left part
	mov		eax,[esi].RECT.left
	mov		edx,[edi].RECT.left
	.if eax!=edx
		.if sdword ptr eax>edx
			;Old>New
			mov		rect.right,eax
			mov		rect.left,edx
		.else
			;Old<New
			mov		rect.right,edx
			mov		rect.left,eax
		.endif
		mov		eax,[esi].RECT.top
		mov		edx,[edi].RECT.top
		.if sdword ptr eax>edx
			mov		eax,edx
		.endif
		mov		rect.top,eax
		mov		eax,[esi].RECT.bottom
		mov		edx,[edi].RECT.bottom
		.if sdword ptr eax<edx
			mov		eax,edx
		.endif
		mov		rect.bottom,eax
		inc		rect.right
		invoke InvalidateRect,ebx,addr rect,TRUE
		invoke UpdateWindow,ebx
	.endif
	;Right part
	mov		eax,[esi].RECT.right
	mov		edx,[edi].RECT.right
	.if eax!=edx
		sub		edx,wt
		inc		edx
		inc		edx
		sub		eax,wt
		inc		eax
		inc		eax
		.if sdword ptr eax>edx
			;Old>New
			mov		rect.right,eax
			mov		rect.left,edx
		.else
			;Old<New
			mov		rect.right,edx
			mov		rect.left,eax
		.endif
		mov		eax,[esi].RECT.top
		mov		edx,[edi].RECT.top
		.if sdword ptr eax>edx
			mov		eax,edx
		.endif
		mov		rect.top,eax
		mov		eax,[esi].RECT.bottom
		mov		edx,[edi].RECT.bottom
		.if sdword ptr eax<edx
			mov		eax,edx
		.endif
		mov		rect.bottom,eax
		invoke InvalidateRect,ebx,addr rect,TRUE
		invoke UpdateWindow,ebx
	.endif
	;Top part
	mov		eax,[esi].RECT.top
	mov		edx,[edi].RECT.top
	.if eax!=edx
		.if sdword ptr eax>edx
			;Old>New
			mov		rect.bottom,eax
			mov		rect.top,edx
		.else
			;Old<New
			mov		rect.bottom,edx
			mov		rect.top,eax
		.endif
		mov		eax,[esi].RECT.left
		mov		edx,[edi].RECT.left
		.if sdword ptr eax>edx
			mov		eax,edx
		.endif
		mov		rect.left,eax
		mov		eax,[esi].RECT.right
		mov		edx,[edi].RECT.right
		.if sdword ptr eax<edx
			mov		eax,edx
		.endif
		mov		rect.right,eax
		invoke InvalidateRect,ebx,addr rect,TRUE
		invoke UpdateWindow,ebx
	.endif
	;Bottom part
	mov		eax,[esi].RECT.bottom
	mov		edx,[edi].RECT.bottom
	.if eax!=edx
		.if sdword ptr eax>edx
			;Old>New
			mov		rect.top,eax
			mov		rect.bottom,edx
		.else
			;Old<New
			mov		rect.top,edx
			mov		rect.bottom,eax
		.endif
		mov		eax,[esi].RECT.left
		mov		edx,[edi].RECT.left
		.if sdword ptr eax>edx
			mov		eax,edx
		.endif
		mov		rect.left,eax
		mov		eax,[esi].RECT.right
		mov		edx,[edi].RECT.right
		.if sdword ptr eax<edx
			mov		eax,edx
		.endif
		mov		rect.right,eax
		invoke InvalidateRect,ebx,addr rect,TRUE
		invoke UpdateWindow,ebx
	.endif
	pop		ebx
	retn

InvalidateBlock endp
