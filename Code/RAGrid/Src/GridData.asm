
MEM_SIZE			equ 128*1024

.code

ExpandMem proc uses esi edi,hMem1:DWORD,nSize:DWORD
	LOCAL	hMem2:DWORD

	mov		eax,nSize
	add		eax,MEM_SIZE
	invoke GlobalAlloc,GMEM_MOVEABLE,eax
	mov		hMem2,eax
	invoke GlobalLock,hMem2
	mov		edi,eax
	invoke GlobalLock,hMem1
	mov		esi,eax
	mov		ecx,nSize
	shr		ecx,2
	rep movsd
	invoke GlobalUnlock,hMem1
	invoke GlobalFree,hMem1
	xor		eax,eax
	mov		ecx,MEM_SIZE/4
	stosd
	invoke GlobalUnlock,hMem2
	mov		eax,hMem2
	ret

ExpandMem endp

GridGetText proc uses ebx edi,hMem:DWORD,rpData:DWORD,lpData:DWORD

	mov		ebx,hMem
	.if rpData
		invoke GlobalLock,[ebx].GRID.hstr
		mov		edi,eax
		add		edi,rpData
		invoke strcpy,lpData,edi
		invoke GlobalUnlock,[ebx].GRID.hstr
	.else
		mov		edi,lpData
		mov		byte ptr [edi],0
	.endif
	ret

GridGetText endp

GridGetFixed proc uses ebx esi edi,hMem:DWORD,rpData:DWORD,lpData:DWORD,len:DWORD

	mov		ebx,hMem
	.if rpData
		invoke GlobalLock,[ebx].GRID.hstr
		mov		esi,eax
		add		esi,rpData
		mov		edi,lpData
		mov		ecx,len
		rep movsb
		invoke GlobalUnlock,[ebx].GRID.hstr
	.else
		xor		eax,eax
		mov		edi,lpData
		mov		ecx,len
		rep stosb
	.endif
	ret

GridGetFixed endp

GridAddText proc uses ebx edi,hMem:DWORD,lpData:DWORD
	LOCAL	len:DWORD

	mov		ebx,hMem
	mov		eax,lpData
	.if eax
		invoke strlen,eax
		inc		eax
		mov		len,eax
		.if ![ebx].GRID.hstr
			invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
			mov		[ebx].GRID.hstr,eax
			mov		[ebx].GRID.rpstrfree,4
			mov		[ebx].GRID.strsize,MEM_SIZE
		.endif
		mov		eax,[ebx].GRID.rpstrfree
		push	eax
		add		eax,len
		.if eax>[ebx].GRID.strsize
			invoke ExpandMem,[ebx].GRID.hstr,[ebx].GRID.strsize
			mov		[ebx].GRID.hstr,eax
			add		[ebx].GRID.strsize,MEM_SIZE
		.endif
		invoke GlobalLock,[ebx].GRID.hstr
		mov		edi,eax
		add		edi,[ebx].GRID.rpstrfree
		invoke strcpy,edi,lpData
		mov		eax,len
		add		[ebx].GRID.rpstrfree,eax
		invoke GlobalUnlock,[ebx].GRID.hstr
		pop		eax
	.endif
	ret

GridAddText endp

GridAddFixed proc uses ebx esi edi,hMem:DWORD,lpData:DWORD,len:DWORD

	mov		ebx,hMem
	.if ![ebx].GRID.hstr
		invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
		mov		[ebx].GRID.hstr,eax
		mov		[ebx].GRID.rpstrfree,4
		mov		[ebx].GRID.strsize,MEM_SIZE
	.endif
	mov		eax,[ebx].GRID.rpstrfree
	push	eax
	add		eax,len
	.if eax>[ebx].GRID.strsize
		invoke ExpandMem,[ebx].GRID.hstr,[ebx].GRID.strsize
		mov		[ebx].GRID.hstr,eax
		add		[ebx].GRID.strsize,MEM_SIZE
	.endif
	invoke GlobalLock,[ebx].GRID.hstr
	mov		edi,eax
	add		edi,[ebx].GRID.rpstrfree
	mov		esi,lpData
	mov		ecx,len
	.if ecx>4
		mov		esi,[esi]
	.endif
	rep movsb
	mov		eax,len
	add		[ebx].GRID.rpstrfree,eax
	invoke GlobalUnlock,[ebx].GRID.hstr
	pop		eax
	ret

GridAddFixed endp

GridAddPtr proc uses ebx edi,hMem:DWORD,nData:DWORD

	mov		ebx,hMem
	.if ![ebx].GRID.hmem
		invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
		mov		[ebx].GRID.hmem,eax
		mov		[ebx].GRID.rpmemfree,0
		mov		[ebx].GRID.memsize,MEM_SIZE
	.endif
	mov		eax,[ebx].GRID.rpmemfree
	add		eax,4
	.if eax>[ebx].GRID.memsize
		invoke ExpandMem,[ebx].GRID.hmem,[ebx].GRID.memsize
		mov		[ebx].GRID.hmem,eax
		add		[ebx].GRID.memsize,MEM_SIZE
	.endif
	invoke GlobalLock,[ebx].GRID.hmem
	mov		edi,eax
	add		edi,[ebx].GRID.rpmemfree
	mov		eax,nData
	mov		[edi],eax
	add		[ebx].GRID.rpmemfree,4
	invoke GlobalUnlock,[ebx].GRID.hmem
	ret

GridAddPtr endp

GridAddRowData proc uses ebx esi edi,hMem:DWORD,lpData:DWORD

	mov		ebx,hMem
	push	[ebx].GRID.rpmemfree
	mov		esi,lpData
	lea		edi,[ebx+sizeof GRID]
	invoke GridAddPtr,ebx,-1
	invoke GridAddPtr,ebx,-1
	xor		ecx,ecx
	.while ecx<[ebx].GRID.cols
		push	ecx
		mov		eax,[edi].COLUMN.ctype
		.if eax==TYPE_EDITTEXT || eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON || eax==TYPE_EDITCOMBOBOX
			xor		eax,eax
			.if esi
				mov		eax,[esi]
				invoke GridAddText,ebx,eax
			.endif
		.elseif eax==TYPE_USER
			mov		eax,[edi].COLUMN.ctextmax
			.if !eax
				.if esi
					mov		eax,[esi]
					invoke GridAddText,ebx,eax
				.endif
			.else
				.if esi
					invoke GridAddFixed,ebx,esi,eax
				.else
					xor		eax,eax
				.endif
			.endif
		.else
			xor		eax,eax
			.if esi
				invoke GridAddFixed,ebx,esi,4
			.endif
		.endif
		invoke GridAddPtr,ebx,eax
		.if esi
			add		esi,4
		.endif
		add		edi,sizeof COLUMN
		pop		ecx
		inc		ecx
	.endw
	pop		eax
	ret

GridAddRowData endp

GridGetCellData proc uses ebx esi edi,hMem:DWORD,rpData:DWORD,nCol:DWORD,lpData:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].GRID.hmem
	mov		esi,eax
	add		esi,rpData
	mov		eax,nCol
	lea		esi,[esi+eax*4+2*4]
	mov		edx,sizeof COLUMN
	mul		edx
	lea		edi,[ebx+eax+sizeof GRID]
	mov		eax,[edi].COLUMN.ctype
	push	eax
	.if eax==TYPE_EDITTEXT || eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON || eax==TYPE_EDITCOMBOBOX
		mov		eax,[esi]
		invoke GridGetText,ebx,eax,lpData
	.elseif eax==TYPE_USER
		mov		eax,[esi]
		mov		ecx,[edi].COLUMN.ctextmax
		.if !ecx
			invoke GridGetText,ebx,eax,lpData
		.else
			invoke GridGetFixed,ebx,eax,lpData,ecx
		.endif
	.else
		mov		eax,[esi]
		invoke GridGetFixed,ebx,eax,lpData,4
	.endif
	invoke GlobalUnlock,[ebx].GRID.hmem
	pop		eax
	ret

GridGetCellData endp

GridGetRowColor proc uses ebx esi edi,hMem:DWORD,rpData:DWORD,lpROWCOLOR:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].GRID.hmem
	mov		esi,eax
	add		esi,rpData
	mov		edi,lpROWCOLOR
	mov		eax,[esi].ROWCOLOR.backcolor
	mov		[edi].ROWCOLOR.backcolor,eax
	mov		eax,[esi].ROWCOLOR.textcolor
	mov		[edi].ROWCOLOR.textcolor,eax
	invoke GlobalUnlock,[ebx].GRID.hmem
	ret

GridGetRowColor endp

GridSetRowColor proc uses ebx esi edi,hMem:DWORD,rpData:DWORD,lpROWCOLOR:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].GRID.hmem
	mov		esi,eax
	add		esi,rpData
	mov		edi,lpROWCOLOR
	mov		eax,[edi].ROWCOLOR.backcolor
	mov		[esi].ROWCOLOR.backcolor,eax
	mov		eax,[edi].ROWCOLOR.textcolor
	mov		[esi].ROWCOLOR.textcolor,eax
	invoke GlobalUnlock,[ebx].GRID.hmem
	ret

GridSetRowColor endp

GridSetCellData proc uses ebx esi edi,hMem:DWORD,rpData:DWORD,nCol:DWORD,lpData:DWORD
	LOCAL	len:DWORD

	mov		ebx,hMem
	invoke GlobalLock,[ebx].GRID.hmem
	mov		esi,eax
	add		esi,rpData
	mov		eax,nCol
	lea		esi,[esi+eax*4+2*4]
	mov		edx,sizeof COLUMN
	mul		edx
	lea		edi,[ebx+eax+sizeof GRID]
	mov		eax,[edi].COLUMN.ctype
	.if eax==TYPE_EDITTEXT || eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON || eax==TYPE_EDITCOMBOBOX
		call	UpdateText
	.elseif eax==TYPE_USER
		mov		ecx,[edi].COLUMN.ctextmax
		.if !ecx
			call	UpdateText
		.else
			call	UpdateFixed
		.endif
	.else
		call	UpdateLong
	.endif
	invoke GlobalUnlock,[ebx].GRID.hmem
	ret

UpdateText:
	.if lpData
		invoke strlen,lpData
		inc		eax
		mov		len,eax
		mov		eax,[ebx].GRID.rpstrfree
		add		eax,len
		.if eax>[ebx].GRID.strsize
			invoke ExpandMem,[ebx].GRID.hstr,[ebx].GRID.strsize
			mov		[ebx].GRID.hstr,eax
			add		[ebx].GRID.strsize,MEM_SIZE
		.endif
		invoke GlobalLock,[ebx].GRID.hstr
		push	eax
		mov		edx,eax
		mov		eax,[esi]
		.if eax
			add		edx,eax
			invoke strlen,edx
			inc		eax
		.endif
		pop		edx
		.if eax>=len
			add		edx,[esi]
			invoke strcpy,edx,lpData
		.else
			mov		ecx,[ebx].GRID.rpstrfree
			mov		[esi],ecx
			add		edx,ecx
			mov		eax,len
			add		[ebx].GRID.rpstrfree,eax
			invoke strcpy,edx,lpData
		.endif
		invoke GlobalUnlock,[ebx].GRID.hstr
	.else
		xor		eax,eax
		mov		[esi],eax
	.endif
	retn

UpdateLong:
	mov		eax,[esi]
	.if !eax
		mov		eax,[ebx].GRID.rpstrfree
		mov		[esi],eax
		add		eax,4
		mov		[ebx].GRID.rpstrfree,eax
		.if eax>[ebx].GRID.strsize
			invoke ExpandMem,[ebx].GRID.hstr,[ebx].GRID.strsize
			mov		[ebx].GRID.hstr,eax
			add		[ebx].GRID.strsize,MEM_SIZE
		.endif
	.endif
	invoke GlobalLock,[ebx].GRID.hstr
	push	esi
	push	edi
	mov		edi,eax
	add		edi,[esi]
	mov		eax,lpData
	.if eax
		mov		eax,[eax]
	.endif
	mov		[edi],eax
	pop		edi
	pop		esi
	invoke GlobalUnlock,[ebx].GRID.hstr
	retn

UpdateFixed:
	.if lpData
		mov		eax,[esi]
		.if !eax
			mov		eax,[ebx].GRID.rpstrfree
			mov		[esi],eax
			add		eax,ecx
			mov		[ebx].GRID.rpstrfree,eax
			.if eax>[ebx].GRID.strsize
				invoke ExpandMem,[ebx].GRID.hstr,[ebx].GRID.strsize
				mov		[ebx].GRID.hstr,eax
				add		[ebx].GRID.strsize,MEM_SIZE
			.endif
		.endif
		invoke GlobalLock,[ebx].GRID.hstr
		mov		ecx,[edi].COLUMN.ctextmax
		push	esi
		push	edi
		mov		edi,eax
		add		edi,[esi]
		mov		esi,lpData
		.if esi
			rep movsb
		.else
			xor		eax,eax
			rep stosb
		.endif
		pop		edi
		pop		esi
		invoke GlobalUnlock,[ebx].GRID.hstr
	.else
		xor		eax,eax
		mov		[esi],eax
	.endif
	retn

GridSetCellData endp

GridSort proc uses ebx esi edi,hMem:DWORD,lpLBMem:DWORD,nCol:DWORD,fString:DWORD,fDescending:DWORD
	LOCAL	nVal:DWORD
	LOCAL	lpStrMem:DWORD
	LOCAL	nStr:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].GRID.hpar
	mov		hpar,eax
	invoke GetWindowLong,eax,GWL_WNDPROC
	mov		lpwndproc,eax
	mov		eax,[ebx].GRID.hgrd
	mov		cis.hwndItem,eax
	mov		eax,[ebx].GRID.nid
	mov		cis.CtlID,eax
	mov		cis.CtlType,ODT_GRID
	invoke GlobalLock,[ebx].GRID.hstr
	mov		lpStrMem,eax
	invoke GlobalLock,[ebx].GRID.hmem
	mov		edi,nCol
	lea		edi,[edi*4+eax+2*4]
	mov		eax,[ebx].GRID.rows
;	dec		eax
;	invoke QuickSort,lpLBMem,0,eax,edi,lpStrMem,fString,fDescending
	invoke CombSort,lpLBMem,eax,edi,lpStrMem,fString,fDescending
	mov		ebx,hMem
	invoke GlobalUnlock,[ebx].GRID.hmem
	invoke GlobalUnlock,[ebx].GRID.hstr
	ret

GridSort endp

GridSortColumn proc uses ebx esi,hMem:DWORD,nCol:DWORD,nSort:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].GRID.rpitemdata
	lea		esi,[ebx+eax]
	mov		ecx,nCol
	mov		eax,sizeof COLUMN
	mul		ecx
	lea		edx,[ebx+eax+sizeof GRID]
	mov		eax,[edx].COLUMN.ctype
	xor		ecx,ecx
	.if eax==TYPE_EDITTEXT || eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON || eax==TYPE_EDITCOMBOBOX || (eax==TYPE_USER && ![edx].COLUMN.ctextmax)
		dec		ecx
	.elseif eax==TYPE_USER && [edx].COLUMN.ctextmax
		mov		ecx,[edx].COLUMN.ctextmax
	.endif
	.if nSort==SORT_ASCENDING
		and		[edx].COLUMN.hdrflag,-1 xor 2
		xor		edx,edx
	.elseif nSort==SORT_DESCENDING
		or		[edx].COLUMN.hdrflag,2
		xor		edx,edx
		inc		edx
	.else
		;Sort invert
		xor		[edx].COLUMN.hdrflag,2
		mov		edx,[edx].COLUMN.hdrflag
		and		edx,2
	.endif
	invoke GridSort,ebx,esi,nCol,ecx,edx
	ret

GridSortColumn endp
