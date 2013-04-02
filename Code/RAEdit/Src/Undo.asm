
.code

DoUndo proc uses ebx edi,hMem:DWORD
	LOCAL	undoid:DWORD

	mov		ebx,hMem
	mov		edi,[ebx].EDIT.hUndo
  Nxt:
	mov		edx,[ebx].EDIT.rpUndo
	.if edx
		mov		edx,[edi+edx].RAUNDO.rpPrev
		mov		[ebx].EDIT.rpUndo,edx
		mov		eax,[edi+edx].RAUNDO.undoid
		mov		undoid,eax
		mov		eax,[edi+edx].RAUNDO.cp
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		push	edx
		invoke SelChange,ebx,SEL_TEXT
		pop		edx
		mov		al,[edi+edx].RAUNDO.fun
		.if al==UNDO_INSERT
			mov		eax,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			invoke DeleteChar,ebx,eax
		.elseif al==UNDO_OVERWRITE
			movzx	eax,byte ptr [edi+edx+sizeof RAUNDO]
			.if al!=0Dh
				push	[ebx].EDIT.fOvr
				mov		[ebx].EDIT.fOvr,TRUE
				mov		ecx,[edi+edx].RAUNDO.cp
				mov		[ebx].EDIT.cpMin,ecx
				mov		[ebx].EDIT.cpMax,ecx
				push	edx
				invoke InsertChar,ebx,ecx,eax
				pop		edx
				mov		[edi+edx+sizeof RAUNDO],al
				pop		[ebx].EDIT.fOvr
			.else
				mov		eax,[edi+edx].RAUNDO.cp
				mov		[ebx].EDIT.cpMin,eax
				mov		[ebx].EDIT.cpMax,eax
				invoke DeleteChar,ebx,eax
			.endif
		.elseif al==UNDO_DELETE
			movzx	eax,byte ptr [edi+edx+sizeof RAUNDO]
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			invoke InsertChar,ebx,ecx,eax
		.elseif al==UNDO_BACKDELETE
			movzx	eax,byte ptr [edi+edx+sizeof RAUNDO]
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			invoke InsertChar,ebx,ecx,eax
			inc		[ebx].EDIT.cpMin
			inc		[ebx].EDIT.cpMax
		.elseif al==UNDO_INSERTBLOCK
			push	edx
			invoke GetCursor
			pop		edx
			push	eax
			push	edx
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			pop		edx
			mov		eax,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			mov		ecx,[edi+edx].RAUNDO.cb
			.while ecx
				push	ecx
				invoke DeleteChar,ebx,[ebx].EDIT.cpMin
				pop		ecx
				dec		ecx
			.endw
			pop		eax
			invoke SetCursor,eax
		.elseif al==UNDO_DELETEBLOCK
			push	[ebx].EDIT.fOvr
			mov		[ebx].EDIT.fOvr,FALSE
			push	edx
			invoke GetCursor
			pop		edx
			push	eax
			push	edx
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			pop		edx
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			mov		ecx,[edi+edx].RAUNDO.cb
			add		edx,sizeof RAUNDO
			.while ecx
				push	ecx
				push	edx
				movzx	eax,byte ptr [edi+edx]
				invoke InsertChar,ebx,[ebx].EDIT.cpMin,eax
				inc		[ebx].EDIT.cpMin
				pop		edx
				pop		ecx
				inc		edx
				dec		ecx
			.endw
			pop		eax
			invoke SetCursor,eax
			pop		[ebx].EDIT.fOvr
		.endif
		mov		edx,[ebx].EDIT.rpUndo
		.if edx
			mov		edx,[edi+edx].RAUNDO.rpPrev
			mov		eax,undoid
			.if eax==[edi+edx].RAUNDO.undoid
				jmp		Nxt
			.endif
		.endif
	.endif
	ret

DoUndo endp

DoRedo proc uses ebx edi,hMem:DWORD
	LOCAL	undoid:DWORD

	mov		ebx,hMem
	mov		edi,[ebx].EDIT.hUndo
  Nxt:
	mov		edx,[ebx].EDIT.rpUndo
	mov		eax,[edi+edx].RAUNDO.cb
	.if eax
		mov		eax,[edi+edx].RAUNDO.undoid
		mov		undoid,eax
		mov		eax,[edi+edx].RAUNDO.cp
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		push	edx
		invoke SelChange,ebx,SEL_TEXT
		pop		edx
		mov		al,[edi+edx].RAUNDO.fun
		.if al==UNDO_INSERT
			push	[ebx].EDIT.fOvr
			mov		[ebx].EDIT.fOvr,FALSE
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			movzx	eax,byte ptr [edi+edx+sizeof RAUNDO]
			add		edx,sizeof RAUNDO+1
			mov		[ebx].EDIT.rpUndo,edx
			invoke InsertChar,ebx,ecx,eax
			inc		[ebx].EDIT.cpMin
			inc		[ebx].EDIT.cpMax
			pop		[ebx].EDIT.fOvr
		.elseif al==UNDO_OVERWRITE
			movzx	eax,byte ptr [edi+edx+sizeof RAUNDO]
			.if al!=0Dh
				push	[ebx].EDIT.fOvr
				mov		[ebx].EDIT.fOvr,TRUE
				mov		ecx,[edi+edx].RAUNDO.cp
				mov		[ebx].EDIT.cpMin,ecx
				mov		[ebx].EDIT.cpMax,ecx
				push	edx
				invoke InsertChar,ebx,ecx,eax
				pop		edx
				mov		[edi+edx+sizeof RAUNDO],al
				pop		[ebx].EDIT.fOvr
				add		edx,sizeof RAUNDO+1
				mov		[ebx].EDIT.rpUndo,edx
				inc		[ebx].EDIT.cpMin
				inc		[ebx].EDIT.cpMax
			.else
				mov		ecx,[edi+edx].RAUNDO.cp
				add		edx,sizeof RAUNDO+1
				mov		[ebx].EDIT.rpUndo,edx
				mov		[ebx].EDIT.cpMin,ecx
				mov		[ebx].EDIT.cpMax,ecx
				invoke InsertChar,ebx,ecx,eax
				inc		[ebx].EDIT.cpMin
				inc		[ebx].EDIT.cpMax
			.endif
		.elseif al==UNDO_DELETE
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			add		edx,sizeof RAUNDO+1
			mov		[ebx].EDIT.rpUndo,edx
			invoke DeleteChar,ebx,ecx
		.elseif al==UNDO_BACKDELETE
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			add		edx,sizeof RAUNDO+1
			mov		[ebx].EDIT.rpUndo,edx
			invoke DeleteChar,ebx,ecx
		.elseif al==UNDO_INSERTBLOCK
			push	[ebx].EDIT.fOvr
			mov		[ebx].EDIT.fOvr,FALSE
			push	edx
			invoke GetCursor
			pop		edx
			push	eax
			push	edx
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			pop		edx
			mov		ecx,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			mov		ecx,[edi+edx].RAUNDO.cb
			add		edx,sizeof RAUNDO
			.while ecx
				push	ecx
				push	edx
				movzx	eax,byte ptr [edi+edx]
				invoke InsertChar,ebx,[ebx].EDIT.cpMin,eax
				inc		[ebx].EDIT.cpMin
				inc		[ebx].EDIT.cpMax
				pop		edx
				pop		ecx
				inc		edx
				dec		ecx
			.endw
			mov		[ebx].EDIT.rpUndo,edx
			pop		eax
			invoke SetCursor,eax
			pop		[ebx].EDIT.fOvr
		.elseif al==UNDO_DELETEBLOCK
			push	edx
			invoke GetCursor
			pop		edx
			push	eax
			push	edx
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			pop		edx
			mov		eax,[edi+edx].RAUNDO.cp
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			mov		ecx,[edi+edx].RAUNDO.cb
			add		edx,ecx
			add		edx,sizeof RAUNDO
			mov		[ebx].EDIT.rpUndo,edx
			.while ecx
				push	ecx
				invoke DeleteChar,ebx,[ebx].EDIT.cpMin
				pop		ecx
				dec		ecx
			.endw
			pop		eax
			invoke SetCursor,eax
		.endif
		mov		edx,[ebx].EDIT.rpUndo
		.if edx
			mov		eax,undoid
			.if eax==[edi+edx].RAUNDO.undoid
				jmp		Nxt
			.endif
		.endif
	.endif
	ret

DoRedo endp

SaveUndo proc uses ebx esi edi,hMem:DWORD,nFun:DWORD,cp:DWORD,lp:DWORD,cb:DWORD

	.if !fNoSaveUndo
		mov		ebx,hMem
		invoke ExpandUndoMem,ebx,cb
		mov		edi,[ebx].EDIT.hUndo
		mov		edx,[ebx].EDIT.rpUndo
		mov		eax,nFun
		.if eax==UNDO_INSERT || eax==UNDO_OVERWRITE || eax==UNDO_DELETE || eax==UNDO_BACKDELETE
			mov		[edi+edx].RAUNDO.fun,al
			mov		eax,[ebx].EDIT.lockundoid
			.if !eax
				mov		eax,nUndoid
			.endif
			mov		[edi+edx].RAUNDO.undoid,eax
			mov		eax,cp
			mov		[edi+edx].RAUNDO.cp,eax
			mov		[edi+edx].RAUNDO.cb,1
			mov		eax,lp
			mov		[edi+edx+sizeof RAUNDO],al
			mov		eax,edx
			add		edx,sizeof RAUNDO+1
			mov		[edi+edx].RAUNDO.rpPrev,eax
			xor		eax,eax
			mov		[edi+edx].RAUNDO.cp,eax
			mov		[edi+edx].RAUNDO.cb,eax
			mov		[edi+edx].RAUNDO.fun,al
			mov		[ebx].EDIT.rpUndo,edx
		.elseif eax==UNDO_INSERTBLOCK || eax==UNDO_DELETEBLOCK
			mov		[edi+edx].RAUNDO.fun,al
			mov		eax,[ebx].EDIT.lockundoid
			.if !eax
				mov		eax,nUndoid
			.endif
			mov		[edi+edx].RAUNDO.undoid,eax
			mov		eax,cp
			mov		[edi+edx].RAUNDO.cp,eax
			mov		ecx,cb
			mov		[edi+edx].RAUNDO.cb,ecx
			mov		esi,lp
			push	edx
			add		edx,sizeof RAUNDO
			.while ecx
				mov		al,[esi]
				inc		esi
				.if al!=0Ah
					mov		[edi+edx],al
					inc		edx
					dec		ecx
				.endif
			.endw
			pop		eax
			mov		[edi+edx].RAUNDO.rpPrev,eax
			xor		eax,eax
			mov		[edi+edx].RAUNDO.cp,eax
			mov		[edi+edx].RAUNDO.cb,eax
			mov		[edi+edx].RAUNDO.fun,al
			mov		[ebx].EDIT.rpUndo,edx
		.endif
	.endif
	ret

SaveUndo endp

Undo proc uses ebx,hMem:DWORD,hWin:DWORD
	LOCAL	pt:POINT

	mov		ebx,hMem
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		invoke DoUndo,ebx
	.else
		invoke DoUndo,ebx
		invoke SetBlockFromCp,ebx,[ebx].EDIT.cpMin,FALSE
	.endif
	invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
	invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
	invoke SetCaret,ebx,[esi].RAEDT.cpy
	invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
	invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	invoke SetCpxMax,ebx,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Undo endp

Redo proc uses ebx,hMem:DWORD,hWin:DWORD
	LOCAL	pt:POINT
	LOCAL	oldrects[2]:RECT

	mov		ebx,hMem
	test	[ebx].EDIT.nMode,MODE_BLOCK
	.if ZERO?
		invoke DoRedo,ebx
	.else
		invoke DoRedo,ebx
		invoke SetBlockFromCp,ebx,[ebx].EDIT.cpMin,FALSE
	.endif
	invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
	invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
	invoke SetCaret,ebx,[esi].RAEDT.cpy
	invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
	invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
	invoke SetCpxMax,ebx,hWin
	invoke SelChange,ebx,SEL_TEXT
	ret

Redo endp

GetUndo proc uses ebx esi edi,hMem:DWORD,nCount:DWORD,lpMem:DWORD
	LOCAL	rpstart:DWORD
	LOCAL	rpend:DWORD

	mov		ebx,hMem
	mov		esi,[ebx].EDIT.hUndo
	mov		edx,[ebx].EDIT.rpUndo
	; Include redo
	.while [esi+edx].RAUNDO.cb
		mov		eax,[esi+edx].RAUNDO.cb
		lea		edx,[edx+eax+sizeof RAUNDO]
	.endw
	mov		rpend,edx
	mov		ecx,nCount
	.if !ecx
		dec		ecx
	.endif
	; Include undo
	.while edx!=0 && ecx!=0
		mov		eax,[esi+edx].RAUNDO.cb
		mov		edx,[esi+edx].RAUNDO.rpPrev
		dec		ecx
	.endw
	mov		rpstart,edx
	mov		edi,lpMem
	.if edi
		mov		eax,[ebx].EDIT.rpUndo
		sub		eax,rpstart
		mov		[edi],eax
		lea		edi,[edi+4]
		.while edx<rpend
			call	GetHeader
			call	GetData
			mov		ecx,[esi+edx].RAUNDO.cb
			lea		edi,[edi+ecx+sizeof RAUNDO]
			lea		edx,[edx+ecx+sizeof RAUNDO]
		.endw
		call	GetHeader
		mov		[edi].RAUNDO.undoid,0
		mov		[edi].RAUNDO.cp,0
		mov		[edi].RAUNDO.cb,0
		mov		[edi].RAUNDO.fun,0
	.endif
	mov		eax,rpend
	sub		eax,rpstart
	add		eax,sizeof RAUNDO+4
	ret

GetHeader:
	xor		ecx,ecx
	.while ecx<sizeof RAUNDO
		lea		eax,[edx+ecx]
		mov		al,[esi+eax]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		eax,[edi].RAUNDO.rpPrev
	sub		eax,rpstart
	mov		[edi].RAUNDO.rpPrev,eax
	retn

GetData:
	xor		ecx,ecx
	.while ecx<[esi+edx].RAUNDO.cb
		lea		eax,[edx+ecx]
		mov		al,[esi+eax+sizeof RAUNDO]
		mov		[edi+ecx+sizeof RAUNDO],al
		inc		ecx
	.endw
	retn

GetUndo endp

SetUndo proc uses ebx esi edi,hMem:DWORD,nSize:DWORD,lpMem:DWORD

	mov		ebx,hMem
	invoke ExpandUndoMem,ebx,nSize
	mov		esi,lpMem
	mov		edi,[ebx].EDIT.hUndo
	mov		eax,[esi]
	mov		[ebx].EDIT.rpUndo,eax
	lea		esi,[esi+4]
	sub		nSize,4
	invoke RtlMoveMemory,edi,esi,nSize
	mov		ecx,[edi].RAUNDO.undoid
	mov		edx,nUndoid
	.while [edi].RAUNDO.cb
		.if ecx!=[edi].RAUNDO.undoid
			mov		ecx,[edi].RAUNDO.undoid
			inc		edx
		.endif
		mov		[edi].RAUNDO.undoid,edx
		mov		eax,[edi].RAUNDO.cb
		lea		edi,[edi+eax+sizeof RAUNDO]
	.endw
	inc		edx
	mov		nUndoid,edx
	ret

SetUndo endp
