
.data?

iBookmark			dd ?
Bookmark			HEBMK 32 dup(<?>)

.code

SetBookmark proc uses edi,hWin:DWORD,nLine:DWORD

	mov		edi,offset Bookmark
	xor		ecx,ecx
	.while ecx<sizeof Bookmark/sizeof HEBMK
		.if ![edi+ecx*sizeof HEBMK].HEBMK.hWin
			mov		eax,hWin
			mov		[edi+ecx*sizeof HEBMK].HEBMK.hWin,eax
			mov		eax,nLine
			mov		[edi+ecx*sizeof HEBMK].HEBMK.nLine,eax
			jmp		Ex
		.endif
		inc		ecx
	.endw
	xor		ecx,ecx
	dec		ecx
  Ex:
	mov		eax,ecx
	ret

SetBookmark endp

ClrBookmark proc uses edi,nInx:DWORD

	mov		edi,offset Bookmark
	mov		ecx,nInx
	mov		edx,ecx
	inc		edx
	.while edx<sizeof Bookmark/sizeof HEBMK
		mov		eax,[edi+edx*sizeof HEBMK].HEBMK.hWin
		mov		[edi+ecx*sizeof HEBMK].HEBMK.hWin,eax
		mov		eax,[edi+edx*sizeof HEBMK].HEBMK.nLine
		mov		[edi+ecx*sizeof HEBMK].HEBMK.nLine,eax
		inc		edx
		inc		ecx
	.endw
	xor		eax,eax
	mov		[edi+ecx*sizeof HEBMK].HEBMK.hWin,eax
	mov		[edi+ecx*sizeof HEBMK].HEBMK.nLine,eax
	ret

ClrBookmark endp

FindBookmark proc uses edi,hWin:DWORD,nLine:DWORD

	mov		edi,offset Bookmark
	mov		eax,hWin
	mov		edx,nLine
	xor		ecx,ecx
	.while ecx<sizeof Bookmark/sizeof HEBMK
		cmp		eax,[edi+ecx*sizeof HEBMK].HEBMK.hWin
		jne		@f
		cmp		edx,[edi+ecx*sizeof HEBMK].HEBMK.nLine
		je		Ex
	  @@:
		inc		ecx
	.endw
	xor		ecx,ecx
	dec		ecx
  Ex:
	mov		eax,ecx
	ret

FindBookmark endp

ToggleBookmark proc hWin:DWORD,nLine:DWORD

	invoke FindBookmark,hWin,nLine
	.if eax==-1
		invoke SetBookmark,hWin,nLine
		.if eax!=-1
			mov		iBookmark,eax
		.endif
	.else
		invoke ClrBookmark,eax
	.endif
	ret

ToggleBookmark endp

NxtBookmark proc uses edi,lpHEBMK:DWORD

	mov		edi,offset Bookmark
	mov		ecx,iBookmark
	inc		ecx
	.if ecx>=sizeof Bookmark/sizeof HEBMK
		xor		ecx,ecx
	.endif
	.if ![edi+ecx*sizeof HEBMK].HEBMK.hWin
		xor		ecx,ecx
	.endif
	mov		iBookmark,ecx
	mov		edx,lpHEBMK
	mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.nLine
	mov		[edx].HEBMK.nLine,eax
	mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.hWin
	mov		[edx].HEBMK.hWin,eax
	.if eax
		xor		eax,eax
		inc		eax
	.endif
	ret

NxtBookmark endp

PrvBookmark proc uses edi,lpHEBMK:DWORD

	mov		edi,offset Bookmark
	mov		ecx,iBookmark
	dec		ecx
	jns		@f
	mov		ecx,sizeof Bookmark/sizeof HEBMK-1
  @@:
	.while ecx
		.break .if [edi+ecx*sizeof HEBMK].HEBMK.hWin
		dec		ecx
	.endw
	mov		iBookmark,ecx
	mov		edx,lpHEBMK
	mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.nLine
	mov		[edx].HEBMK.nLine,eax
	mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.hWin
	mov		[edx].HEBMK.hWin,eax
	.if eax
		xor		eax,eax
		inc		eax
	.endif
	ret

PrvBookmark endp

ClearBookmarks proc uses ebx esi edi

	mov		edi,offset Bookmark
	xor		ecx,ecx
	.while ecx<sizeof Bookmark/sizeof HEBMK
		mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.hWin
		.if eax
			mov		esi,[edi+ecx*sizeof HEBMK].HEBMK.nLine
			push	ecx
			invoke GetWindowLong,eax,0
			mov		ebx,eax
			shl		esi,5
			invoke InvalidateLine,[ebx].EDIT.edta.hwnd,esi
			invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,esi
			pop		ecx
			xor		eax,eax
			mov		[edi+ecx*sizeof HEBMK].HEBMK.hWin,eax
			mov		[edi+ecx*sizeof HEBMK].HEBMK.nLine,eax
		.endif
		inc		ecx
	.endw
	ret

ClearBookmarks endp

ClearWinBookmarks proc uses edi,hWin:DWORD

	mov		edi,offset Bookmark
	xor		ecx,ecx
	.while ecx<sizeof Bookmark/sizeof HEBMK
		mov		eax,[edi+ecx*sizeof HEBMK].HEBMK.hWin
		.if eax==hWin
			push	ecx
			invoke ClrBookmark,ecx
			pop		ecx
		.endif
		inc		ecx
	.endw
	ret

ClearWinBookmarks endp
