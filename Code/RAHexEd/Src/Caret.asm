
.code

SetCaret proc uses ebx esi,hWin:HWND
	LOCAL	xp:DWORD
	LOCAL	yp:DWORD
	LOCAL	buffer[32]:BYTE

	.if hWin
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,hWin
		.if eax==[ebx].EDIT.edta.hwnd
			lea		esi,[ebx].EDIT.edta
		.else
			lea		esi,[ebx].EDIT.edtb
		.endif
		invoke GetFocus
		.if eax==hWin
			.if [ebx].EDIT.fOvr
				mov		edx,[ebx].EDIT.fntinfo.fntwt
			.else
				mov		edx,2
			.endif
			invoke CreateCaret,hWin,NULL,edx,[ebx].EDIT.fntinfo.fntht
			mov		eax,[ebx].EDIT.cpMin
			mov		ecx,eax
			shr		eax,1
			and		eax,0Fh
			mov		edx,3
			mul		edx
			sub		eax,[ebx].EDIT.cpx
			mov		edx,[ebx].EDIT.fntinfo.fntwt
			mul		edx
			add		eax,[ebx].EDIT.linenrwt
			add		eax,[ebx].EDIT.selbarwt
			add		eax,[ebx].EDIT.dataxp
			test	ecx,1
			.if !ZERO?
				add		eax,[ebx].EDIT.fntinfo.fntwt
			.endif
			mov		xp,eax
			mov		eax,ecx
			shr		eax,5
			sub		eax,[esi].HEEDT.nline
			mov		edx,[ebx].EDIT.fntinfo.fntht
			mul		edx
			mov		yp,eax
			invoke SetCaretPos,xp,yp
			mov		eax,[ebx].EDIT.linenrwt
			add		eax,[ebx].EDIT.selbarwt
			mov		edx,[esi].HEEDT.rc.right
			sub		edx,[ebx].EDIT.fntinfo.fntwt
			.if sdword ptr eax>xp || sdword ptr edx<xp
				.if ![ebx].EDIT.fCaretHide
					invoke HideCaret,hWin
					mov		[ebx].EDIT.fCaretHide,TRUE
				.endif
			.else
				mov		eax,[ebx].EDIT.cpMin
				.if eax!=[ebx].EDIT.cpMax
					.if ![ebx].EDIT.fCaretHide
						invoke HideCaret,hWin
						mov		[ebx].EDIT.fCaretHide,TRUE
					.endif
				.else
					invoke ShowCaret,hWin
					mov		[ebx].EDIT.fCaretHide,FALSE
				.endif
			.endif
		.endif
	.endif
	ret

SetCaret endp

TestScrollX proc uses ebx esi,hWin:HWND
	LOCAL	xp:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		eax,[ebx].EDIT.cpMin
	mov		ecx,eax
	shr		eax,1
	and		eax,0Fh
	mov		edx,3
	mul		edx
	sub		eax,[ebx].EDIT.cpx
	mov		edx,[ebx].EDIT.fntinfo.fntwt
	mul		edx
	add		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	add		eax,[ebx].EDIT.dataxp
	test	ecx,1
	.if !ZERO?
		add		eax,[ebx].EDIT.fntinfo.fntwt
	.endif
	mov		xp,eax
	mov		eax,[ebx].EDIT.linenrwt
	add		eax,[ebx].EDIT.selbarwt
	.if sdword ptr eax>xp
		sub		eax,xp
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		xor		edx,edx
		div		ecx
		sub		eax,[ebx].EDIT.cpx
		neg		eax
		sub		eax,4
	.else
		mov		eax,[esi].HEEDT.rc.right
		sub		eax,[ebx].EDIT.fntinfo.fntwt
		.if sdword ptr eax<xp
			sub		eax,xp
			neg		eax
			mov		ecx,[ebx].EDIT.fntinfo.fntwt
			xor		edx,edx
			div		ecx
			add		eax,[ebx].EDIT.cpx
			add		eax,4
		.else
			mov		eax,[ebx].EDIT.cpx
		.endif
	.endif
	ret

TestScrollX endp

TestScrollY proc uses ebx esi,hWin:HWND
	LOCAL	sinf:SCROLLINFO

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL
	invoke GetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf
	mov		eax,[ebx].EDIT.cpMin
	mov		edx,[esi].HEEDT.nline
	mov		ecx,edx
	add		ecx,sinf.nPage
	dec		ecx
	shr		eax,5
	.if eax<edx
		sub		eax,edx
	.elseif eax>ecx
		sub		eax,ecx
	.else
		xor		eax,eax
	.endif
	add		eax,[esi].HEEDT.nline
	ret

TestScrollY endp

Scroll proc uses ebx esi edi,hWin:HWND,x:DWORD,y:DWORD
	LOCAL	sinf:SCROLLINFO
	LOCAL	rect:RECT

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL or SIF_DISABLENOSCROLL
	invoke GetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf
	mov		eax,y
	.if eax!=sinf.nPos
		mov		sinf.nPos,eax
		mov		sinf.nMin,0
		mov		eax,[ebx].EDIT.nbytes
		shr		eax,4
		inc		eax
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		mul		ecx
		.if eax<[esi].HEEDT.rc.bottom
			mov		eax,[esi].HEEDT.rc.bottom
		.endif
		xor		edx,edx
		div		ecx
		dec		eax
		mov		sinf.nMax,eax
		mov		eax,[esi].HEEDT.rc.bottom
		xor		edx,edx
		div		ecx
		mov		sinf.nPage,eax
		invoke SetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf,TRUE
		invoke GetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf
		mov		eax,sinf.nPos
		mov		ecx,[esi].HEEDT.nline
		.if eax!=ecx
			mov		[esi].HEEDT.nline,eax
			sub		eax,ecx
			neg		eax
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			mul		ecx
			mov		ecx,eax
			invoke ScrollWindow,hWin,0,ecx,addr [esi].HEEDT.rc,NULL
			invoke UpdateWindow,hWin
			invoke SetCaret,hWin
		.endif
	.endif
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL or SIF_DISABLENOSCROLL
	invoke GetScrollInfo,[ebx].EDIT.hhscroll,SB_CTL,addr sinf
	mov		eax,x
	.if eax!=sinf.nPos
		mov		sinf.nPos,eax
		mov		sinf.nMin,0
		mov		eax,[esi].HEEDT.rc.right
		sub		eax,[ebx].EDIT.selbarwt
		sub		eax,[ebx].EDIT.linenrwt
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		xor		edx,edx
		div		ecx
		mov		sinf.nPage,eax
		mov		eax,[ebx].EDIT.asciixp
		add		eax,[ebx].EDIT.asciiwt
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		xor		edx,edx
		div		ecx
		mov		sinf.nMax,eax
		invoke SetScrollInfo,[ebx].EDIT.hhscroll,SB_CTL,addr sinf,TRUE
		invoke GetScrollInfo,[ebx].EDIT.hhscroll,SB_CTL,addr sinf
		mov		eax,sinf.nPos
		mov		ecx,[ebx].EDIT.cpx
		.if eax!=ecx
			mov		[ebx].EDIT.cpx,eax
			sub		eax,ecx
			neg		eax
			mov		ecx,[ebx].EDIT.fntinfo.fntwt
			mul		ecx
			mov		edi,eax
			invoke CopyRect,addr rect,addr [ebx].EDIT.edta.rc
			mov		eax,[ebx].EDIT.linenrwt
			add		eax,[ebx].EDIT.selbarwt
			add		eax,SPCWT
			mov		rect.left,eax
			invoke ScrollWindow,[ebx].EDIT.edta.hwnd,edi,0,addr rect,addr rect
			invoke CopyRect,addr rect,addr [ebx].EDIT.edtb.rc
			mov		eax,[ebx].EDIT.linenrwt
			add		eax,[ebx].EDIT.selbarwt
			add		eax,SPCWT
			mov		rect.left,eax
			invoke ScrollWindow,[ebx].EDIT.edtb.hwnd,edi,0,addr rect,addr rect
			invoke UpdateWindow,hWin
			invoke SetCaret,hWin
		.endif
	.endif
	ret

Scroll endp

GetCharFromPos proc uses ebx esi,hWin:HWND,x:DWORD,y:DWORD
	LOCAL	cp:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	.if eax==[ebx].EDIT.edta.hwnd
		lea		esi,[ebx].EDIT.edta
	.else
		lea		esi,[ebx].EDIT.edtb
	.endif
	mov		eax,y
	.if sdword ptr eax<0
		xor		eax,eax
	.elseif eax>[esi].HEEDT.rc.bottom
		mov		eax,[esi].HEEDT.rc.bottom
	.endif
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	xor		edx,edx
	div		ecx
	add		eax,[esi].HEEDT.nline
	shl		eax,4
	.if eax>[ebx].EDIT.nbytes
		mov		eax,[ebx].EDIT.nbytes
		and		eax,0FFFFFFF0h
	.endif
	shl		eax,1
	mov		cp,eax
	mov		eax,[ebx].EDIT.cpx
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mul		ecx
	mov		edx,eax
	mov		eax,x
	sub		eax,[ebx].EDIT.dataxp
	sub		eax,[ebx].EDIT.linenrwt
	sub		eax,[ebx].EDIT.selbarwt
	add		eax,edx
	.if sdword ptr eax<0
		xor		eax,eax
	.endif
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mov		edx,ecx
	add		ecx,ecx
	add		ecx,edx
	shl		eax,1
	add		eax,edx
	xor		edx,edx
	div		ecx
	.if eax>31
		mov		eax,31
	.endif
	add		eax,cp
	mov		ecx,[ebx].EDIT.nbytes
	shl		ecx,1
	.if eax>ecx
		mov		eax,ecx
	.endif
	ret

GetCharFromPos endp

ScrollCaret proc uses ebx esi,hWin:HWND

	.if hWin
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,hWin
		.if eax==[ebx].EDIT.edta.hwnd
			lea		esi,[ebx].EDIT.edta
		.else
			lea		esi,[ebx].EDIT.edtb
		.endif
		invoke TestScrollY,hWin
		.if eax!=[esi].HEEDT.nline
			invoke Scroll,hWin,[ebx].EDIT.cpx,eax
		.endif
		invoke TestScrollX,hWin
		.if eax!=[ebx].EDIT.cpx
			invoke Scroll,hWin,eax,[esi].HEEDT.nline
		.endif
		invoke SetCaret,hWin
	.endif
	ret

ScrollCaret endp

