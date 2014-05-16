		align 4 
		_EM_CHARFROMPOS:
			;wParam=0
			;lParam=lpPoint
			mov		edx,lParam
			invoke GetCharFromPos,ebx,[esi].RAEDT.cpy,[edx].POINT.x,[edx].POINT.y
			ret
		align 4 
		_EM_POSFROMCHAR:
			;wParam=lpPoint
			;lParam=cp
			invoke GetPosFromChar,ebx,lParam,wParam
			mov		edx,wParam
			mov		eax,[ebx].EDIT.cpx
			sub		[edx].POINT.x,eax
			mov		eax,[esi].RAEDT.cpy
			sub		[edx].POINT.y,eax
			xor		eax,eax
			ret
		align 4 
		_EM_LINEFROMCHAR:
			;wParam=cp
			;lParam=0
			mov		eax,wParam
			.if eax==-1
				mov		eax,[ebx].EDIT.cpMin
			.endif
			invoke GetCharPtr,ebx,eax
			mov		eax,edx
			ret
		align 4 
		_EM_LINEINDEX:
			;wParam=line
			;lParam=0
			mov		eax,wParam
			.if eax==-1
				mov		eax,[ebx].EDIT.line
			.endif
			invoke GetCpFromLine,ebx,eax
			ret
		align 4 
		_EM_GETLINE:
			;wParam=line
			;lParam=lpBuff
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				mov		ecx,[edx].CHARS.len
				.if byte ptr [edx+ecx+sizeof CHARS-1]==VK_RETURN && ecx
					dec		ecx
				.endif
				mov		edi,lParam
				.if cx>word ptr [edi]
					movzx	ecx,word ptr [edi]
				.endif
				push	ecx
				lea		esi,[edx+sizeof CHARS]
				rep movsb
				pop		eax
			.else
				xor		eax,eax
			.endif
			ret
		align 4 
		_EM_LINELENGTH:
			;wParam=cp
			;lParam=0
			invoke GetLineFromCp,ebx,wParam
			mov		edx,eax
			shl		edx,2
			add		edx,[ebx].EDIT.hLine
			mov		edx,[edx].LINE.rpChars
			add		edx,[ebx].EDIT.hChars
			mov		eax,[edx].CHARS.len
			.if eax
				.if byte ptr [edx+eax+sizeof CHARS-1]==0Dh
					dec		eax
				.endif
			.endif
			ret
		align 4 
		_EM_GETFIRSTVISIBLELINE:
			;wParam=0
			;lParam=0
			mov		eax,[esi].RAEDT.topln
			ret
		align 4 
		_EM_LINESCROLL:
			;wParam=cxScroll
			;lParam=cyScroll
			mov		eax,wParam
			mov		edx,[ebx].EDIT.fntinfo.fntwt
			.if sdword ptr eax<0
				neg		eax
				mul		edx
				neg		eax
			.else
				mul		edx
			.endif
			add		eax,[ebx].EDIT.cpx
			mov		[ebx].EDIT.cpx,eax
			mov		eax,lParam
			mov		edx,[ebx].EDIT.fntinfo.fntht
			.if sdword ptr eax<0
				neg		eax
				mul		edx
				neg		eax
			.else
				mul		edx
			.endif
			add		eax,[esi].RAEDT.cpy
			.if sdword ptr eax<0
				xor		eax,eax
			.endif
			mov		[esi].RAEDT.cpy,eax
			invoke InvalidateEdit,ebx,[esi].RAEDT.hwnd
			mov		eax,TRUE
			ret
		align 4 
		_EM_SCROLLCARET:
			;wParam=0
			;lParam=0
			invoke SetCaretVisible,[esi].RAEDT.hwnd,[esi].RAEDT.cpy
			invoke SetCaret,ebx,[esi].RAEDT.cpy
			mov		eax,TRUE
			ret
		align 4 
		_EM_SETSEL:
			;wParam=cpMin
			;lParam=cpMax
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				.if ![ebx].EDIT.fHideSel
					mov		eax,[ebx].EDIT.cpMin
					.if eax!=[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
					.endif
				.endif
				invoke GetCharPtr,ebx,lParam
				mov		[ebx].EDIT.cpMax,ecx
				invoke GetCharPtr,ebx,wParam
				mov		[ebx].EDIT.cpMin,ecx
				.if ![ebx].EDIT.fHideSel
					invoke TestExpand,ebx,[ebx].EDIT.line
					mov		eax,[ebx].EDIT.cpMin
					.if eax!=[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
						invoke SetCaret,ebx,[esi].RAEDT.cpy
						invoke SetCpxMax,ebx,[esi].RAEDT.hwnd
					.endif
				.endif
				invoke SelChange,ebx,SEL_TEXT
			.endif
			xor		eax,eax
			ret
		align 4 
		_EM_GETSEL:
			;wParam=lpcpMin
			;lParam=lpcpMax
			mov		eax,[ebx].EDIT.cpMin
			mov		ecx,[ebx].EDIT.cpMax
			.if eax>ecx
				xchg	eax,ecx
			.endif
			mov		edx,wParam
			.if edx
				mov		[edx],eax
			.endif
			mov		edx,lParam
			.if edx
				mov		[edx],ecx
			.endif
			and		eax,0FFFFh
			shl		ecx,16
			or		eax,ecx
			ret
		align 4 
		_EM_GETMODIFY:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.fChanged
			ret
		align 4 
		_EM_SETMODIFY:
			;wParam=TRUE/FALSE
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.fChanged,eax
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
			ret
		align 4 
		_EM_REPLACESEL:
			;wParam=TRUE/FALSE
			;lParam=lpText
			.if !wParam
				inc		fNoSaveUndo
			.endif
			invoke IsSelectionLocked,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
			or		eax,eax
			jne		ErrBeep
			inc		nUndoid
			invoke DeleteSelection,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			push	eax
			
			push	[ebx].EDIT.fOvr
			mov		[ebx].EDIT.fOvr,0
			invoke EditInsert,ebx,[ebx].EDIT.cpMin,lParam
			pop		[ebx].EDIT.fOvr
			pop		ecx
			add		[ebx].EDIT.cpMin,eax
			add		[ebx].EDIT.cpMax,eax
			.if wParam && eax
				invoke SaveUndo,ebx,UNDO_INSERTBLOCK,ecx,lParam,eax
			.endif
			invoke GetCharPtr,ebx,[ebx].EDIT.cpMin
			invoke SetCaretVisible,[esi].RAEDT.hwnd,[esi].RAEDT.cpy
			invoke SetCaret,ebx,[esi].RAEDT.cpy
			
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			invoke SetCpxMax,ebx,[esi].RAEDT.hwnd
			invoke SelChange,ebx,SEL_TEXT
            
			inc		nUndoid
			xor		eax,eax
			mov		fNoSaveUndo,eax
			ret                                                         ; *** MOD testing
			;jmp ExDef                                                    ; *** MOD testing
		align 4 
		_EM_GETLINECOUNT:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.rpLineFree
			shr		eax,2
			dec		eax
			ret
		align 4 
		_EM_GETRECT:
			;wParam=0
			;lParam=lpRECT
			mov		edx,lParam
			mov		eax,[esi].RAEDT.rc.left
			mov		[edx].RECT.left,eax
			mov		eax,[esi].RAEDT.rc.top
			mov		[edx].RECT.top,eax
			mov		eax,[esi].RAEDT.rc.right
			mov		[edx].RECT.right,eax
			mov		eax,[esi].RAEDT.rc.bottom
			mov		[edx].RECT.bottom,eax
			mov		eax,[ebx].EDIT.focus
			.if eax==[ebx].EDIT.edtb.hwnd && [ebx].EDIT.nsplitt
				mov		eax,[ebx].EDIT.nsplitt
				add		eax,BTNHT
				add		[edx].RECT.top,eax
				add		[edx].RECT.bottom,eax
			.endif
			ret
		align 4 
		_EM_CANUNDO:
			;wParam=0
			;lParam=0
			xor		eax,eax
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				mov		eax,[ebx].EDIT.rpUndo
				.if eax
					mov		eax,TRUE
				.endif
			.endif
			ret
		align 4 
		_EM_UNDO:
			;wParam=0
			;lParam=0
			inc		nUndoid
			;PrintText "Start Undo"
			invoke Undo,ebx,[esi].RAEDT.hwnd
			inc		nUndoid
			ret
		align 4 
		_EM_EMPTYUNDOBUFFER:
			;wParam=0
			;lParam=0
			mov		edi,[ebx].EDIT.hUndo
			mov		ecx,[ebx].EDIT.cbUndo
			xor		eax,eax
			mov		[ebx].EDIT.rpUndo,eax
			rep stosb
			inc		nUndoid
			ret
		align 4
		_DefEditMsg:
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
			ret

.data
align 4
_EDIT_MSG \
	dd _EM_GETSEL				;0x00B0
	dd _EM_SETSEL				;0x00B1
	dd _EM_GETRECT				;0x00B2
	dd _DefEditMsg				;0x00B3 _EM_SETRECT					<- DefWindowProc
	dd _DefEditMsg				;0x00B4 _EM_SETRECTNP				<- DefWindowProc
	dd _DefEditMsg				;0x00B5 _EM_SCROLL					<- DefWindowProc
	dd _EM_LINESCROLL			;0x00B6
	dd _EM_SCROLLCARET			;0x00B7
	dd _EM_GETMODIFY			;0x00B8
	dd _EM_SETMODIFY			;0x00B9
	dd _EM_GETLINECOUNT			;0x00BA
	dd _EM_LINEINDEX			;0x00BB
	dd _DefEditMsg				;0x00BC _EM_SETHANDLE				<- DefWindowProc
	dd _DefEditMsg				;0x00BD _EM_GETHANDLE				<- DefWindowProc
	dd _DefEditMsg				;0x00BE _EM_GETTHUMB				<- DefWindowProc
	dd _DefEditMsg				;0x00BF _UNKNOW_MSG					<- DefWindowProc
	dd _DefEditMsg				;0x00C0 _UNKNOW_MSG					<- DefWindowProc
	dd _EM_LINELENGTH			;0x00C1
	dd _EM_REPLACESEL			;0x00C2
	dd _DefEditMsg				;0x00C3 _UNKNOW_MSG					<- DefWindowProc
	dd _EM_GETLINE				;0x00C4
	dd _DefEditMsg				;0x00C5 _EM_LIMITTEXT				<- DefWindowProc
	dd _EM_CANUNDO				;0x00C6
	dd _EM_UNDO					;0x00C7
	dd _DefEditMsg				;0x00C8 _EM_FMTLINES				<- DefWindowProc
	dd _EM_LINEFROMCHAR			;0x00C9
	dd _DefEditMsg				;0x00CA _UNKNOW_MSG					<- DefWindowProc
	dd _DefEditMsg				;0x00CB _EM_SETTABSTOPS				<- DefWindowProc
	dd _DefEditMsg				;0x00CC _EM_SETPASSWORDCHAR			<- DefWindowProc
	dd _EM_EMPTYUNDOBUFFER		;0x00CD
	dd _EM_GETFIRSTVISIBLELINE	;0x00CE
	dd _DefEditMsg				;0x00CF _EM_SETREADONLY				<- DefWindowProc
	dd _DefEditMsg				;0x00D0 _EM_SETWORDBREAKPROC		<- DefWindowProc
	dd _DefEditMsg				;0x00D1 _EM_GETWORDBREAKPROC		<- DefWindowProc
	dd _DefEditMsg				;0x00D2 _EM_GETPASSWORDCHAR			<- DefWindowProc
	dd _DefEditMsg				;0x00D3 _EM_SETMARGINS				<- DefWindowProc
	dd _DefEditMsg				;0x00D4 _EM_GETMARGINS				<- DefWindowProc
	dd _DefEditMsg				;0x00D5 _EM_GETLIMITTEXT			<- DefWindowProc
	dd _EM_POSFROMCHAR			;0x00D6
	dd _EM_CHARFROMPOS			;0x00D7
	dd _DefEditMsg				;0x00D8 _EM_SETIMESTATUS			<- DefWindowProc
	dd _DefEditMsg				;0x00D9 _EM_GETIMESTATUS			<- DefWindowProc
	;dd _EM_SETLIMITTEXT		;EM_LIMITTEXT   /* ;win40 Name change */

.code
align 4
