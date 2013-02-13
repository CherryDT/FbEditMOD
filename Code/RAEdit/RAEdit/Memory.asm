
.code

xGlobalAlloc proc t:DWORD,s:DWORD

	shr		s,3
	inc		s
	shl		s,3
	invoke GlobalAlloc,t,s
	.if !eax
		invoke MessageBox,NULL,addr szGlobalFail,addr szToolTip,MB_OK
		xor		eax,eax
	.endif
	ret

xGlobalAlloc endp

xHeapAlloc proc h:DWORD,t:DWORD,s:DWORD
	
	shr		s,3
	inc		s
	shl		s,3
	invoke HeapAlloc,h,t,s
	.if !eax
		invoke MessageBox,NULL,addr szHeapFail,addr szToolTip,MB_OK
		xor		eax,eax
	.endif
	ret

xHeapAlloc endp

ExpandLineMem proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.rpLineFree
	add		eax,MAXLINEMEM
	shr		eax,12
	inc		eax
	shl		eax,12
	.if eax>[ebx].EDIT.cbLine
		mov		esi,[ebx].EDIT.hLine
		mov		edi,[ebx].EDIT.cbLine
		add		[ebx].EDIT.cbLine,MAXLINEMEM
		invoke HeapAlloc,[ebx].EDIT.hHeap,HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY,[ebx].EDIT.cbLine
		.if !eax
			mov		[ebx].EDIT.cbLine,edi
			invoke MessageBox,[ebx].EDIT.hwnd,offset szMemFailLine,offset szToolTip,MB_OK
			xor		eax,eax
		.else
			mov		[ebx].EDIT.hLine,eax
			mov		ecx,edi
			mov		edi,eax
			push	esi
			shr		ecx,2
			rep movsd
			pop		esi
			invoke HeapFree,[ebx].EDIT.hHeap,0,esi
		.endif
	.endif
	ret

ExpandLineMem endp

GarbageCollection proc lpLine:DWORD,lpSrc:DWORD,lpDst:DWORD

	mov		eax,lpLine
	mov		ecx,[ebx].EDIT.rpLineFree
	add		lpLine,ecx
	mov		edi,lpDst
  @@:
	mov		esi,lpSrc
	add		esi,[eax].LINE.rpChars
	mov		edx,edi
	sub		edx,lpDst
	mov		[eax].LINE.rpChars,edx
	mov		ecx,[esi].CHARS.len
	mov		edx,[esi].CHARS.max
	lea		ecx,[ecx+sizeof CHARS]
	lea		edx,[edx+sizeof CHARS]
	sub		edx,ecx
	push	ecx
	shr		ecx,2
	rep movsd
	pop		ecx
	and		ecx,3
	rep movsb
	add		edi,edx
	lea		eax,[eax+sizeof LINE]
	cmp		eax,lpLine
	jne		@b
	sub		edi,lpDst
	mov		[ebx].EDIT.rpCharsFree,edi
	ret

GarbageCollection endp

ExpandCharMem proc uses ebx,hMem:DWORD,nLen:DWORD

	mov		ebx,hMem
	mov		eax,nLen
	shr		eax,12
	inc		eax
	shl		eax,12
	add		eax,[ebx].EDIT.rpCharsFree
	add		eax,MAXCHARMEM
	.if eax>[ebx].EDIT.cbChars
		push	esi
		push	edi
		mov		esi,[ebx].EDIT.hChars
		mov		edi,[ebx].EDIT.cbChars
		mov		eax,nLen
		shr		eax,12
		inc		eax
		shl		eax,12
		add		eax,MAXCHARMEM
		add		[ebx].EDIT.cbChars,eax
		invoke HeapAlloc,[ebx].EDIT.hHeap,HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY,[ebx].EDIT.cbChars
		.if !eax
			mov		[ebx].EDIT.cbChars,edi
			invoke MessageBox,[ebx].EDIT.hwnd,offset szMemFailChar,offset szToolTip,MB_OK
			xor		eax,eax
		.else
			mov		[ebx].EDIT.hChars,eax
			push	esi
			invoke GarbageCollection,[ebx].EDIT.hLine,esi,[ebx].EDIT.hChars
			pop		esi
			invoke HeapFree,[ebx].EDIT.hHeap,0,esi
		.endif
		pop		edi
		pop		esi
	.endif
	ret

ExpandCharMem endp

ExpandUndoMem proc uses ebx,hMem:DWORD,cb:DWORD

	mov		ebx,hMem
	mov		eax,[ebx].EDIT.rpUndo
	add		eax,cb
	add		eax,8*1024
	shr		eax,12
	inc		eax
	shl		eax,12
	.if eax>[ebx].EDIT.cbUndo
		push	esi
		push	edi
		mov		esi,[ebx].EDIT.hUndo
		mov		edi,[ebx].EDIT.cbUndo
		add		eax,MAXUNDOMEM
		and		eax,0FFFFFF00h
		mov		[ebx].EDIT.cbUndo,eax
		invoke HeapAlloc,[ebx].EDIT.hHeap,HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY,[ebx].EDIT.cbUndo
		.if !eax
			mov		[ebx].EDIT.cbUndo,edi
			invoke MessageBox,[ebx].EDIT.hwnd,offset szMemFailUndo,offset szToolTip,MB_OK
			xor		eax,eax
		.else
			mov		[ebx].EDIT.hUndo,eax
			mov		ecx,edi
			mov		edi,eax
			push	esi
			shr		ecx,2
			rep movsd
			pop		esi
			invoke HeapFree,[ebx].EDIT.hHeap,0,esi
		.endif
		pop		edi
		pop		esi
	.endif
	ret

ExpandUndoMem endp

ExpandWordMem proc uses esi edi

	mov		eax,cbWrdMem
	sub		eax,rpWrdFree
	.if eax<256
		mov		esi,cbWrdMem
		add		cbWrdMem,MAXWORDMEM
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,cbWrdMem
		.if !eax
			invoke MessageBox,NULL,offset szMemFailSyntax,offset szToolTip,MB_OK
			xor		eax,eax
		.else
			mov		ecx,esi
			mov		edi,eax
			mov		esi,hWrdMem
			mov		hWrdMem,edi
			push	esi
			shr		ecx,2
			rep movsd
			pop		esi
			invoke GetProcessHeap
			invoke HeapFree,eax,0,esi
		.endif
	.endif
	ret

ExpandWordMem endp
