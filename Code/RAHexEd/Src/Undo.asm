
.code

ExpandUndoMem proc uses ebx edi,hMem:DWORD,cb:DWORD

	invoke GetProcessHeap
	mov		edi,eax
	mov		ebx,hMem
	mov		eax,[ebx].EDIT.rpundo
	add		eax,cb
	add		eax,sizeof HEUNDO*2
	.if eax>[ebx].EDIT.cbundo
		and		eax,-1 xor (MAXUNDOMEM-1)
		add		eax,MAXUNDOMEM
		mov		[ebx].EDIT.cbundo,eax
		invoke HeapReAlloc,edi,HEAP_GENERATE_EXCEPTIONS or HEAP_NO_SERIALIZE or HEAP_ZERO_MEMORY,[ebx].EDIT.hundo,[ebx].EDIT.cbundo
		.if !eax
			invoke MessageBox,[ebx].EDIT.hwnd,offset szMemFailUndo,offset szToolTip,MB_OK
			xor		eax,eax
		.else
			mov		[ebx].EDIT.hundo,eax
		.endif
	.endif
	ret

ExpandUndoMem endp

DoUndo proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	mov		edi,[ebx].EDIT.hundo
	mov		edx,[ebx].EDIT.rpundo
	.if edx
		mov		edx,[edi+edx].HEUNDO.rpPrev
		mov		[ebx].EDIT.rpundo,edx
		mov		al,[edi+edx].HEUNDO.fun
		.if al==UNDO_CHARINSERT
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke DeleteChars,ebx,esi,1
		.elseif al==UNDO_CHAROVERWRITE
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke GetChar,ebx,esi
			push	eax
			invoke PutChar,ebx,esi,addr [edi+sizeof HEUNDO],1
			pop		eax
			mov		[edi+sizeof HEUNDO],al
		.elseif al==UNDO_INSERTBLOCK
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke DeleteChars,ebx,esi,[edi].HEUNDO.cb
		.elseif al==UNDO_DELETEBLOCK
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			shr		esi,1
			invoke InsertChars,ebx,esi,[edi].HEUNDO.cb
			invoke PutChar,ebx,esi,addr [edi+sizeof HEUNDO],[edi].HEUNDO.cb
			add		esi,[edi].HEUNDO.cb
			shl		esi,1
			mov		[ebx].EDIT.cpMax,esi
		.endif
	.endif
	ret

DoUndo endp

DoRedo proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	mov		edi,[ebx].EDIT.hundo
	mov		edx,[ebx].EDIT.rpundo
	mov		eax,[edi+edx].HEUNDO.cb
	.if eax
		mov		al,[edi+edx].HEUNDO.fun
		.if al==UNDO_CHARINSERT
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke InsertChars,ebx,esi,1
			invoke PutChar,ebx,esi,addr [edi+sizeof HEUNDO],1
			inc		[ebx].EDIT.cpMin
			inc		[ebx].EDIT.cpMax
			add		[ebx].EDIT.rpundo,sizeof HEUNDO+1
		.elseif al==UNDO_CHAROVERWRITE
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke GetChar,ebx,esi
			push	eax
			invoke PutChar,ebx,esi,addr [edi+sizeof HEUNDO],1
			pop		eax
			mov		[edi+sizeof HEUNDO],al
			inc		[ebx].EDIT.cpMin
			inc		[ebx].EDIT.cpMax
			add		[ebx].EDIT.rpundo,sizeof HEUNDO+1
		.elseif al==UNDO_INSERTBLOCK
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke InsertChars,ebx,esi,[edi].HEUNDO.cb
			invoke PutChar,ebx,esi,addr [edi+sizeof HEUNDO],[edi].HEUNDO.cb
			mov		eax,[edi].HEUNDO.cb
			add		eax,sizeof HEUNDO
			add		[ebx].EDIT.rpundo,eax
		.elseif al==UNDO_DELETEBLOCK
			lea		edi,[edi+edx]
			mov		esi,[edi].HEUNDO.cp
			mov		[ebx].EDIT.cpMin,esi
			mov		[ebx].EDIT.cpMax,esi
			shr		esi,1
			invoke DeleteChars,ebx,esi,[edi].HEUNDO.cb
			mov		eax,[edi].HEUNDO.cb
			add		eax,sizeof HEUNDO
			add		[ebx].EDIT.rpundo,eax
		.endif
	.endif
	ret

DoRedo endp

SaveUndo proc uses ebx esi edi,hMem:DWORD,nFun:DWORD,cp:DWORD,cr:DWORD,cb:DWORD

	mov		ebx,hMem
	invoke ExpandUndoMem,ebx,cb
	or		eax,eax
	je		Ex
	mov		edi,[ebx].EDIT.hundo
	mov		edx,[ebx].EDIT.rpundo
	mov		eax,nFun
	.if eax==UNDO_CHARINSERT || eax==UNDO_CHAROVERWRITE
		lea		edi,[edi+edx]
		mov		[edi].HEUNDO.fun,al
		mov		eax,cp
		mov		[edi].HEUNDO.cp,eax
		mov		[edi].HEUNDO.cb,1
		mov		eax,cr
		mov		[edi+sizeof HEUNDO],al
		mov		[edi+sizeof HEUNDO+1].HEUNDO.rpPrev,edx
		add		[ebx].EDIT.rpundo,sizeof HEUNDO+1
	.elseif eax==UNDO_INSERTBLOCK || eax==UNDO_DELETEBLOCK
		lea		edi,[edi+edx]
		mov		[edi].HEUNDO.fun,al
		mov		esi,cp
		mov		[edi].HEUNDO.cp,esi
		mov		ecx,cb
		mov		[edi].HEUNDO.cb,ecx
		mov		eax,sizeof HEUNDO
		add		eax,cb
		mov		[edi+eax].HEUNDO.rpPrev,edx
		add		eax,edx
		mov		[ebx].EDIT.rpundo,eax

		shr		esi,1
		add		edi,sizeof HEUNDO
		.while ecx
			push	ecx
			invoke GetChar,ebx,esi
			pop		ecx
			dec		ecx
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
	.endif
  Ex:
	ret

SaveUndo endp

Undo proc uses ebx,hMem:DWORD,hWin:DWORD

	mov		ebx,hMem
	invoke DoUndo,ebx
	invoke ScrollCaret,hWin
	invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
	invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
	invoke SetCaret,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Undo endp

Redo proc uses ebx,hMem:DWORD,hWin:DWORD

	mov		ebx,hMem
	invoke DoRedo,ebx
	invoke ScrollCaret,hWin
	invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
	invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
	invoke SetCaret,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Redo endp

