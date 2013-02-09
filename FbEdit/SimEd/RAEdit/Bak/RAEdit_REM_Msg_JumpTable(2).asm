		align 4
		_REM_SETHILITEWORDS:
			;wParam=Color
			;lParam=lpszWords
			invoke SetHiliteWords,wParam,lParam
			xor		eax,eax
			ret
		align 4
		_REM_SETFONT:
			;wParam=nLineSpacing
			;lParam=lpRAFONT
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			.if ecx
				mov		eax,[ebx].EDIT.edta.cpy
				xor		edx,edx
				div		ecx
				push	eax
				mov		eax,[ebx].EDIT.edtb.cpy
				xor		edx,edx
				div		ecx
				push	eax
			.else
				push	0
				push	0
			.endif
			mov		eax,wParam
			mov		[ebx].EDIT.fntinfo.linespace,eax
			invoke SetFont,ebx,lParam
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			pop		eax
			mul		ecx
			mov		[ebx].EDIT.edtb.cpy,eax
			pop		eax
			mul		ecx
			mov		[ebx].EDIT.edta.cpy,eax
			xor		eax,eax
			mov		[ebx].EDIT.edta.topyp,eax
			mov		[ebx].EDIT.edta.topln,eax
			mov		[ebx].EDIT.edta.topcp,eax
			mov		[ebx].EDIT.edtb.topyp,eax
			mov		[ebx].EDIT.edtb.topln,eax
			mov		[ebx].EDIT.edtb.topcp,eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			.if ![ebx].EDIT.fntinfo.monospace
				mov		eax,[ebx].EDIT.nMode
				test	eax,MODE_BLOCK
				.if !ZERO?
					xor		eax,MODE_BLOCK
					invoke SendMessage,hWin,REM_SETMODE,eax,0
				.endif
			.endif
			invoke GetFocus
			.if eax==[ebx].EDIT.focus && eax
				invoke SetFocus,hWin
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_GETFONT:
			;wParam=0
			;lParam=lpRAFONT
			mov		edx,lParam
			mov		eax,[ebx].EDIT.fnt.hFont
			mov		[edx].RAFONT.hFont,eax
			mov		eax,[ebx].EDIT.fnt.hIFont
			mov		[edx].RAFONT.hIFont,eax
			mov		eax,[ebx].EDIT.fnt.hLnrFont
			mov		[edx].RAFONT.hLnrFont,eax
			mov		eax,[ebx].EDIT.fntinfo.linespace
			ret
		align 4
		_REM_SETCOLOR:
			;wParam=0
			;lParam=lpRACOLOR
			mov		edx,lParam
			mov		eax,[edx].RACOLOR.bckcol
			mov		[ebx].EDIT.clr.bckcol,eax
			mov		eax,[edx].RACOLOR.txtcol
			mov		[ebx].EDIT.clr.txtcol,eax
			mov		eax,[edx].RACOLOR.selbckcol
			.if eax==[edx].RACOLOR.bckcol
				xor		eax,03F3F3Fh
			.endif
			mov		[ebx].EDIT.clr.selbckcol,eax
			mov		eax,[edx].RACOLOR.seltxtcol
			mov		[ebx].EDIT.clr.seltxtcol,eax
			mov		eax,[edx].RACOLOR.cmntcol
			mov		[ebx].EDIT.clr.cmntcol,eax
			mov		eax,[edx].RACOLOR.strcol
			mov		[ebx].EDIT.clr.strcol,eax
			mov		eax,[edx].RACOLOR.oprcol
			mov		[ebx].EDIT.clr.oprcol,eax
			mov		eax,[edx].RACOLOR.hicol1
			mov		[ebx].EDIT.clr.hicol1,eax
			mov		eax,[edx].RACOLOR.hicol2
			mov		[ebx].EDIT.clr.hicol2,eax
			mov		eax,[edx].RACOLOR.hicol3
			mov		[ebx].EDIT.clr.hicol3,eax
			mov		eax,[edx].RACOLOR.selbarbck
			mov		[ebx].EDIT.clr.selbarbck,eax
			mov		eax,[edx].RACOLOR.selbarpen
			mov		[ebx].EDIT.clr.selbarpen,eax
			mov		eax,[edx].RACOLOR.lnrcol
			mov		[ebx].EDIT.clr.lnrcol,eax
			mov		eax,[edx].RACOLOR.numcol
			mov		[ebx].EDIT.clr.numcol,eax
			mov		eax,[edx].RACOLOR.cmntback
			mov		[ebx].EDIT.clr.cmntback,eax
			mov		eax,[edx].RACOLOR.strback
			mov		[ebx].EDIT.clr.strback,eax
			mov		eax,[edx].RACOLOR.numback
			mov		[ebx].EDIT.clr.numback,eax
			mov		eax,[edx].RACOLOR.oprback
			mov		[ebx].EDIT.clr.oprback,eax
			mov		eax,[edx].RACOLOR.changed
			mov		[ebx].EDIT.clr.changed,eax
			mov		eax,[edx].RACOLOR.changesaved
			mov		[ebx].EDIT.clr.changesaved,eax
			invoke CreateBrushes,ebx
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,FALSE
			xor		eax,eax
			ret
		align 4
		_REM_GETCOLOR:
			;wParam=0
			;lParam=lpRACOLOR
			mov		edx,lParam
			mov		eax,[ebx].EDIT.clr.bckcol
			mov		[edx].RACOLOR.bckcol,eax
			mov		eax,[ebx].EDIT.clr.txtcol
			mov		[edx].RACOLOR.txtcol,eax
			mov		eax,[ebx].EDIT.clr.selbckcol
			mov		[edx].RACOLOR.selbckcol,eax
			mov		eax,[ebx].EDIT.clr.seltxtcol
			mov		[edx].RACOLOR.seltxtcol,eax
			mov		eax,[ebx].EDIT.clr.cmntcol
			mov		[edx].RACOLOR.cmntcol,eax
			mov		eax,[ebx].EDIT.clr.strcol
			mov		[edx].RACOLOR.strcol,eax
			mov		eax,[ebx].EDIT.clr.oprcol
			mov		[edx].RACOLOR.oprcol,eax
			mov		eax,[ebx].EDIT.clr.hicol1
			mov		[edx].RACOLOR.hicol1,eax
			mov		eax,[ebx].EDIT.clr.hicol2
			mov		[edx].RACOLOR.hicol2,eax
			mov		eax,[ebx].EDIT.clr.hicol3
			mov		[edx].RACOLOR.hicol3,eax
			mov		eax,[ebx].EDIT.clr.selbarbck
			mov		[edx].RACOLOR.selbarbck,eax
			mov		eax,[ebx].EDIT.clr.selbarpen
			mov		[edx].RACOLOR.selbarpen,eax
			mov		eax,[ebx].EDIT.clr.lnrcol
			mov		[edx].RACOLOR.lnrcol,eax
			mov		eax,[ebx].EDIT.clr.numcol
			mov		[edx].RACOLOR.numcol,eax
			mov		eax,[ebx].EDIT.clr.cmntback
			mov		[edx].RACOLOR.cmntback,eax
			mov		eax,[ebx].EDIT.clr.strback
			mov		[edx].RACOLOR.strback,eax
			mov		eax,[ebx].EDIT.clr.numback
			mov		[edx].RACOLOR.numback,eax
			mov		eax,[ebx].EDIT.clr.oprback
			mov		[edx].RACOLOR.oprback,eax
			mov		eax,[ebx].EDIT.clr.changed
			mov		[edx].RACOLOR.changed,eax
			mov		eax,[ebx].EDIT.clr.changesaved
			mov		[edx].RACOLOR.changesaved,eax
			xor		eax,eax
			ret
		align 4
		_REM_SETHILITELINE:
			;wParam=Line
			;lParam=nColor
			invoke HiliteLine,ebx,wParam,lParam
			ret
		align 4
		_REM_GETHILITELINE:
			;wParam=Line
			;lParam=0
			xor		eax,eax
			dec		eax
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				mov		eax,[edx].CHARS.state
				and		eax,STATE_HILITEMASK
			.endif
			ret
		align 4
		_REM_SETBOOKMARK:
			;wParam=Line
			;lParam=nType
			invoke SetBookMark,ebx,wParam,lParam
			push	eax
			invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			pop		eax
			ret
		align 4
		_REM_GETBOOKMARK:
			;wParam=Line
			;lParam=0
			invoke GetBookMark,ebx,wParam
			ret
		align 4
		_REM_CLRBOOKMARKS:
			;wParam=0
			;lParam=nType
			invoke ClearBookMarks,ebx,lParam
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			xor		eax,eax
			ret
		align 4
		_REM_NXTBOOKMARK:
			;wParam=Line
			;lParam=nType
			invoke NextBookMark,ebx,wParam,lParam
			ret
		align 4
		_REM_PRVBOOKMARK:
			;wParam=Line
			;lParam=nType
			invoke PreviousBookMark,ebx,wParam,lParam
			ret
		align 4
		_REM_FINDBOOKMARK:
			;wParam=BmID
			;lParam=0
			xor		eax,eax
			dec		eax
			mov		ecx,wParam
			xor		edi,edi
			.while edi<[ebx].EDIT.rpLineFree
				mov		edx,edi
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				.if ecx==[edx].CHARS.bmid
					mov		eax,edi
					shr		eax,2
					.break
				.endif
				add		edi,sizeof LINE
			.endw
			ret
		align 4
		_REM_SETBLOCKS:
			;wParam=[lpLINERANGE]
			;lParam=0
			invoke GetCursor
			push	eax
			push	nBmid
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			mov		esi,offset blockdefs
			lea		edi,[esi+32*4]
			.while dword ptr [esi]
				mov		eax,[edi].RABLOCKDEF.flag
				shr		eax,16
				.if eax==[ebx].EDIT.nWordGroup
					invoke SetBlocks,ebx,wParam,edi
				.endif
				mov		edi,[esi]
				add		esi,4
			.endw
			pop		eax
			.if eax!=nBmid
				invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
				invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
			.endif
			pop		eax
			invoke SetCursor,eax
			xor		eax,eax
			ret
		align 4
		_REM_ISLINE:
			;wParam=Line
			;lParam=lpszDef
			invoke IsLine,ebx,wParam,lParam
			ret
		align 4
		_REM_GETWORD:
			;wParam=BuffSize
			;lParam=lpBuff
			invoke GetWordStart,ebx,[ebx].EDIT.cpMin,0
			mov		esi,[ebx].EDIT.rpChars
			mov		ecx,eax
			sub		ecx,[ebx].EDIT.cpLine
			push	ecx
			push	eax
			invoke GetWordEnd,ebx,eax,0
			pop		ecx
			pop		edx
			sub		eax,ecx
			mov		ecx,eax
			mov		edi,lParam
			.if ecx>=wParam
				mov		ecx,wParam
				dec		ecx
			.endif
			add		esi,[ebx].EDIT.hChars
			add		esi,edx
			add		esi,sizeof CHARS
			mov		eax,ecx
			rep movsb
			mov		byte ptr [edi],0
			ret
		align 4
		_REM_COLLAPSE:
			;wParam=Line
			;lParam=0
			invoke Collapse,ebx,wParam
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			ret
		align 4
		_REM_COLLAPSEALL:
			;wParam=0
			;lParam=0
			invoke CollapseAll,ebx
			.if eax
				push	esi
				push	edi
				invoke GetLineFromCp,ebx,[ebx].EDIT.cpMin
				mov		esi,eax
				mov		edi,eax
			  @@:
				invoke IsLineHidden,ebx,esi
				.if eax
					dec		esi
					jmp		@b
				.endif
				.if esi!=edi
					invoke GetCpFromLine,ebx,esi
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
				.endif
				pop		esi
				pop		edi
				.if [ebx].EDIT.fsplitt
					invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
					invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
				.endif
				invoke SendMessage,hWin,REM_VCENTER,0,0
			.endif
			ret
		align 4
		_REM_EXPAND:
			;wParam=Line
			;lParam=0
			invoke Expand,ebx,wParam
			push	eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			pop		eax
			ret
		align 4
		_REM_EXPANDALL:
			;wParam=0
			;lParam=0
			invoke ExpandAll,ebx
			.if eax
				.if [ebx].EDIT.fsplitt
					invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
					invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
				.endif
				invoke SendMessage,hWin,REM_VCENTER,0,0
			.endif
			ret
		align 4
		_REM_LOCKLINE:
			;wParam=Line
			;lParam=TRUE/FALSE
			invoke LockLine,ebx,wParam,lParam
			ret
		align 4
		_REM_ISLINELOCKED:
			;wParam=Line
			;lParam=0
			invoke IsLineLocked,ebx,wParam
			.if eax
				mov		eax,TRUE
			.endif
			ret
		align 4
		_REM_HIDELINE:
			;wParam=Line
			;lParam=TRUE/FALSE
			invoke HideLine,ebx,wParam,lParam
			push	eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			pop		eax
			ret
		align 4
		_REM_ISLINEHIDDEN:
			;wParam=Line
			;lParam=0
			invoke IsLineHidden,ebx,wParam
			.if eax
				mov		eax,TRUE
			.endif
			ret
		align 4
		_REM_AUTOINDENT:
			;wParam=0
			;lParam=TRUE/FALSE
			mov		eax,lParam
			mov		[ebx].EDIT.fIndent,eax
			ret
		align 4
		_REM_TABWIDTH:
			;wParam=nChars
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.nTab,eax
			mov		eax,lParam
			mov		[ebx].EDIT.fExpandTab,eax
			invoke SetFont,ebx,addr [ebx].EDIT.fnt
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			xor		eax,eax
			ret
		align 4
		_REM_SELBARWIDTH:
			;wParam=nWidth
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.selbarwt,eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			xor		eax,eax
			ret
		align 4
		_REM_LINENUMBERWIDTH:
			;wParam=nWidth
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.nlinenrwt,eax
			.if [ebx].EDIT.linenrwt
				mov		[ebx].EDIT.linenrwt,eax
				invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
				invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_MOUSEWHEEL:
			;wParam=nLines
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.nScroll,eax
			ret
		align 4
		_REM_SUBCLASS:
			;wParam=0
			;lParam=lpWndProc
			invoke SetWindowLong,[ebx].EDIT.edta.hwnd,GWL_WNDPROC,lParam
			invoke SetWindowLong,[ebx].EDIT.edtb.hwnd,GWL_WNDPROC,lParam
			ret
		align 4
		_REM_SETSPLIT:
			;wParam=nSplit
			;lParam=0
			mov		eax,wParam
			and		eax,1FFh
			mov		[ebx].EDIT.fsplitt,eax
			.if !eax
				mov		eax,[ebx].EDIT.focus
				.if eax==[ebx].EDIT.edta.hwnd
					mov		eax,[ebx].EDIT.edta.cpxmax
					mov		[ebx].EDIT.edtb.cpxmax,eax
					mov		eax,[ebx].EDIT.edta.cpy
					mov		[ebx].EDIT.edtb.cpy,eax
				.endif
			.endif
			call	SizeIt
			invoke SetFocus,[ebx].EDIT.edtb.hwnd
			invoke SetCaretVisible,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.edtb.cpy
			ret
		align 4
		_REM_GETSPLIT:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.fsplitt
			ret
		align 4
		_REM_VCENTER:
			;wParam=0
			;lParam=0
			mov		eax,[esi].RAEDT.rc.bottom
			shr		eax,1
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			xor		edx,edx
			div		ecx
			mul		ecx
			push	eax
			invoke GetLineFromCp,ebx,[ebx].EDIT.cpMin
			invoke GetYpFromLine,ebx,eax
			pop		edx
			sub		eax,edx
			jnb		@f
			xor		eax,eax
		  @@:
			mov		[esi].RAEDT.cpy,eax
			invoke SetCaretVisible,[esi].RAEDT.hwnd,[esi].RAEDT.cpy
			invoke InvalidateEdit,ebx,[esi].RAEDT.hwnd
			xor		eax,eax
			ret
		align 4
		_REM_REPAINT:
			;wParam=0
			;lParam=TRUE/FALSE (Paint Now)
			invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
			invoke InvalidateRect,[ebx].EDIT.edta.hvscroll,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
			invoke InvalidateRect,[ebx].EDIT.edtb.hvscroll,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hhscroll,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hgrip,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hnogrip,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hsbtn,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hlin,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hexp,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hcol,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hlock,NULL,TRUE
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
			.if lParam
				invoke UpdateWindow,[ebx].EDIT.edta.hwnd
				invoke UpdateWindow,[ebx].EDIT.edtb.hwnd
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_BMCALLBACK:
			;wParam=0
			;lParam=lpBmProc
			mov		eax,lParam
			mov		[ebx].EDIT.lpBmCB,eax
			ret
		align 4
		_REM_READONLY:
			;wParam=0
			;lParam=TRUE/FALSE
			invoke GetWindowLong,hWin,GWL_STYLE
			.if lParam
				or		eax,STYLE_READONLY
			.else
				and		eax,-1 xor STYLE_READONLY
			.endif
			mov		[ebx].EDIT.fstyle,eax
			invoke SetWindowLong,hWin,GWL_STYLE,eax
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
			xor		eax,eax
			ret
		align 4
		_REM_INVALIDATELINE:
			;wParam=nLine
			;lParam=0
			invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			xor		eax,eax
			ret
		align 4
		_REM_SETPAGESIZE:
			;wParam=nLines
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.nPageBreak,eax
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			xor		eax,eax
			ret
		align 4
		_REM_GETPAGESIZE:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.nPageBreak
			ret
		align 4
		_REM_GETCHARTAB:
			;wParam=nChar
			;lParam=0
			mov		edx,wParam
			and		edx,0FFh
			movzx	eax,byte ptr [edx+offset CharTab]
			ret
		align 4
		_REM_SETCHARTAB:
			;wParam=nChar
			;lParam=nType
			mov		edx,wParam
			and		edx,0FFh
			mov		eax,lParam
			mov		byte ptr [edx+offset CharTab],al
			ret
		align 4
		_REM_SETCOMMENTBLOCKS:
			;wParam=lpStart
			;lParam=lpEnd
			invoke SetCommentBlocks,ebx,wParam,lParam
			ret
		align 4
		_REM_SETWORDGROUP:
			;wParam=0
			;lParam=nGroup (0-15)
			mov		eax,lParam
			and		eax,0Fh
			mov		[ebx].EDIT.nWordGroup,eax
			ret
		align 4
		_REM_GETWORDGROUP:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.nWordGroup
			ret
		align 4
		_REM_SETBMID:
			;wParam=nLine
			;lParam=nBmID
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				mov		eax,lParam
				mov		[edx].CHARS.bmid,eax
			.endif
			ret
		align 4
		_REM_GETBMID:
			;wParam=nLine
			;lParam=0
			xor		eax,eax
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				mov		eax,[edx].CHARS.bmid
			.endif
			ret
		align 4
		_REM_ISCHARPOS:
			;wParam=CP
			;lParam=0
			invoke IsCharPos,ebx,wParam
			ret
		align 4
		_REM_HIDELINES:
			;wParam=nLine
			;lParam=nLines
			xor		eax,eax
			.if lParam>1
				invoke GetBookMark,ebx,wParam
				.if !eax
					push	[ebx].EDIT.nHidden
					mov		ecx,lParam
					mov		edx,wParam
					dec		ecx
					.while ecx
						inc		edx
						push	ecx
						push	edx
						invoke HideLine,ebx,edx,TRUE
						.if eax
							pop		edx
							push	edx
							shl		edx,2
							.if edx<[ebx].EDIT.rpLineFree
								add		edx,[ebx].EDIT.hLine
								mov		edx,[edx].LINE.rpChars
								add		edx,[ebx].EDIT.hChars
								mov		eax,nBmid
								inc		eax
								mov		[edx].CHARS.bmid,eax
							.endif
						.endif
						pop		edx
						pop		ecx
						dec		ecx
					.endw
					pop		edx
					mov		eax,[ebx].EDIT.nHidden
					sub		eax,edx
					.if eax
						push	eax
						invoke SetBookMark,ebx,wParam,8
						mov		eax,[ebx].EDIT.cpMin
						.if eax>[ebx].EDIT.cpMax
							mov		eax,[ebx].EDIT.cpMax
						.endif
						mov		[ebx].EDIT.cpMin,eax
						mov		[ebx].EDIT.cpMax,eax
						mov		eax,[ebx].EDIT.rpLineFree
						shr		eax,2
						sub		eax,[ebx].EDIT.nHidden
						mov		ecx,[ebx].EDIT.fntinfo.fntht
						mul		ecx
						xor		ecx,ecx
						.if eax<[ebx].EDIT.edta.cpy
							mov		[ebx].EDIT.edta.cpy,eax
							mov		[ebx].EDIT.edta.topyp,ecx
							mov		[ebx].EDIT.edta.topln,ecx
							mov		[ebx].EDIT.edta.topcp,ecx
						.endif
						.if eax<[ebx].EDIT.edtb.cpy
							mov		[ebx].EDIT.edtb.cpy,eax
							mov		[ebx].EDIT.edtb.topyp,ecx
							mov		[ebx].EDIT.edtb.topln,ecx
							mov		[ebx].EDIT.edtb.topcp,ecx
						.endif
						invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
						invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
						pop		eax
					.endif
				.else
					xor		eax,eax
				.endif
			.endif
			ret
		align 4
		_REM_SETDIVIDERLINE:
			;wParam=nLine
			;lParam=TRUE/FALSE
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				.if lParam
					or		[edx].CHARS.state,STATE_DIVIDERLINE
				.else
					and		[edx].CHARS.state,-1 xor STATE_DIVIDERLINE
				.endif
				invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
				invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_ISINBLOCK:
			;wParam=nLine
			;lParam=lpRABLOCKDEF
			invoke IsInBlock,ebx,wParam,lParam
			ret
		align 4
		_REM_TRIMSPACE:
			;wParam=nLine
			;lParam=fLeft
			invoke TrimSpace,ebx,wParam,lParam
			.if eax
				push	eax
				invoke SelChange,ebx,SEL_TEXT
				pop		eax
			.endif
			ret
		align 4
		_REM_SAVESEL:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.cpMin
			mov		[ebx].EDIT.savesel.cpMin,eax
			mov		eax,[ebx].EDIT.cpMax
			mov		[ebx].EDIT.savesel.cpMax,eax
			xor		eax,eax
			ret
		align 4
		_REM_RESTORESEL:
			;wParam=0
			;lParam=0
			.if ![ebx].EDIT.fHideSel
				mov		eax,[ebx].EDIT.cpMin
				.if eax!=[ebx].EDIT.cpMax
					invoke InvalidateSelection,ebx,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
					invoke InvalidateSelection,ebx,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				.endif
			.endif
			invoke GetCharPtr,ebx,[ebx].EDIT.savesel.cpMax
			mov		[ebx].EDIT.cpMax,ecx
			invoke GetCharPtr,ebx,[ebx].EDIT.savesel.cpMin
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
			xor		eax,eax
			ret
		align 4
		_REM_GETCURSORWORD:
			;wParam=BuffSize
			;lParam=lpBuff
			mov		edi,lParam
			mov		byte ptr [edi],0
			invoke GetCursorPos,addr pt
			invoke ScreenToClient,hWin,addr pt
			mov		eax,[ebx].EDIT.selbarwt
			add		eax,[ebx].EDIT.linenrwt
			.if eax<=pt.x
				invoke ChildWindowFromPoint,hWin,pt.x,pt.y
				.if eax==[ebx].EDIT.edta.hwnd
					lea		esi,[ebx].EDIT.edta
				.else
					lea		esi,[ebx].EDIT.edtb
				.endif
				invoke ClientToScreen,hWin,addr pt
				invoke ScreenToClient,[esi].RAEDT.hwnd,addr pt
				invoke GetCharFromPos,ebx,[esi].RAEDT.cpy,pt.x,pt.y
				push	eax
				mov		edx,eax
				push	pt.x
				invoke GetPosFromChar,ebx,edx,addr pt
				pop		edx
				pop		eax
				sub		edx,[ebx].EDIT.fntinfo.fntwt
				.if edx<=pt.x
					invoke GetWordStart,ebx,eax,[ebx].EDIT.nCursorWordType
					mov		esi,[ebx].EDIT.rpChars
					mov		ecx,eax
					sub		ecx,[ebx].EDIT.cpLine
					push	ecx
					push	eax
					invoke GetWordEnd,ebx,eax,[ebx].EDIT.nCursorWordType
					pop		ecx
					pop		edx
					sub		eax,ecx
					mov		ecx,eax
					.if ecx>=wParam
						mov		ecx,wParam
						dec		ecx
					.endif
					add		esi,[ebx].EDIT.hChars
					add		esi,edx
					add		esi,sizeof CHARS
					mov		eax,ecx
					rep movsb
					mov		byte ptr [edi],0
					mov		eax,[ebx].EDIT.line
				.else
					mov		eax,-1
				.endif
			.else
				mov		eax,-1
			.endif
			ret
		align 4
		_REM_SETSEGMENTBLOCK:
			;wParam=nLine
			;lParam=TRUE/FALSE
			mov		edx,wParam
			shl		edx,2
			.if edx<[ebx].EDIT.rpLineFree
				add		edx,[ebx].EDIT.hLine
				mov		edx,[edx].LINE.rpChars
				add		edx,[ebx].EDIT.hChars
				.if lParam
					or		[edx].CHARS.state,STATE_SEGMENTBLOCK
				.else
					and		[edx].CHARS.state,-1 xor STATE_SEGMENTBLOCK
				.endif
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_GETMODE:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.nMode
;			.if [ebx].EDIT.fOvr
;				or		eax,MODE_OVERWRITE
;			.endif
			ret
		align 4
		_REM_SETMODE:
			;wParam=nMode
			;lParam=0
			mov		eax,wParam
			test	eax,MODE_OVERWRITE
			.if ZERO?
				mov		[ebx].EDIT.fOvr,FALSE
			.else
				mov		[ebx].EDIT.fOvr,TRUE
			.endif
			
			.if ![ebx].EDIT.fntinfo.monospace
				and		eax,-1 xor MODE_BLOCK
			.endif
			mov		edx,[ebx].EDIT.nMode
			mov		[ebx].EDIT.nMode,eax
			xor		eax,edx
			test	eax,MODE_BLOCK
			.if !ZERO?
				.if ![ebx].EDIT.fntinfo.monospace
					and		[ebx].EDIT.nMode,-1 xor MODE_BLOCK
				.endif
;				test	[ebx].EDIT.nMode,MODE_BLOCK
;				.if ZERO?
;					mov		eax,4
;				.else
;					mov		eax,8
;				.endif
;				mov		edx,[ebx].EDIT.fntinfo.fntht
;				invoke CreateCaret,[ebx].EDIT.focus,NULL,eax,edx
				invoke GetCaretPos,addr pt
				invoke GetCharFromPos,ebx,[esi].RAEDT.cpy,pt.x,pt.y
				mov		[ebx].EDIT.cpMin,eax
				mov		[ebx].EDIT.cpMax,eax
				test	[ebx].EDIT.nMode,MODE_BLOCK
				.if ZERO?
					xor		eax,eax
					mov		[ebx].EDIT.blrg.lnMin,eax
					mov		[ebx].EDIT.blrg.clMin,eax
					mov		[ebx].EDIT.blrg.lnMax,eax
					mov		[ebx].EDIT.blrg.clMax,eax
				.else
					invoke SetBlockFromCp,ebx,[ebx].EDIT.cpMin,FALSE
				.endif
				invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
				invoke SetCaret,ebx,[esi].RAEDT.cpy
				invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,TRUE
				invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,TRUE
				invoke SelChange,ebx,SEL_TEXT
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_GETBLOCK:
			;wParam=0
			;lParam=lpBLOCKRANGE
			mov		edx,lParam
			mov		eax,[ebx].EDIT.blrg.lnMin
			mov		[edx].BLOCKRANGE.lnMin,eax
			mov		eax,[ebx].EDIT.blrg.clMin
			mov		[edx].BLOCKRANGE.clMin,eax
			mov		eax,[ebx].EDIT.blrg.lnMax
			mov		[edx].BLOCKRANGE.lnMax,eax
			mov		eax,[ebx].EDIT.blrg.clMax
			mov		[edx].BLOCKRANGE.clMax,eax
			xor		eax,eax
			ret
		align 4
		_REM_SETBLOCK:
			;wParam=0
			;lParam=lpBLOCKRANGE
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if !ZERO?
				invoke GetBlockRects,ebx,addr oldrects
				mov		edx,lParam
				mov		eax,[edx].BLOCKRANGE.lnMin
				mov		[ebx].EDIT.blrg.lnMin,eax
				mov		eax,[edx].BLOCKRANGE.clMin
				mov		[ebx].EDIT.blrg.clMin,eax
				mov		eax,[edx].BLOCKRANGE.lnMax
				mov		[ebx].EDIT.blrg.lnMax,eax
				mov		eax,[edx].BLOCKRANGE.clMax
				mov		[ebx].EDIT.blrg.clMax,eax
				invoke GetBlockCp,ebx,[ebx].EDIT.blrg.lnMin,[ebx].EDIT.blrg.clMin
				mov		[ebx].EDIT.cpMin,eax
				mov		[ebx].EDIT.cpMax,eax
				invoke InvalidateBlock,ebx,addr oldrects
				invoke SetCaretVisible,hWin,[esi].RAEDT.cpy
				invoke SetCaret,ebx,[esi].RAEDT.cpy
				invoke SelChange,ebx,SEL_TEXT
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_BLOCKINSERT:
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if !ZERO?
				invoke IsSelectionLocked,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				or		eax,eax
				jne		ErrBeep
				inc		nUndoid
				mov		eax,[ebx].EDIT.blrg.lnMin
				mov		edx,[ebx].EDIT.blrg.lnMax
				.if eax<edx
					xchg	eax,edx
				.endif
				sub		eax,edx
				inc		eax
				mov		edi,eax
				invoke strlen,lParam
				mov		esi,eax
				add		eax,2
				mul		edi
				inc		eax
				invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
				push	eax
				mov		edx,eax
				.while edi
					push	esi
					mov		ecx,lParam
					.while esi
						mov		al,[ecx]
						mov		[edx],al
						inc		ecx
						inc		edx
						dec		esi
					.endw
					mov		byte ptr [edx],0Dh
					inc		edx
					mov		byte ptr [edx],0Ah
					inc		edx
					pop		esi
					dec		edi
				.endw
				pop		eax
				push	eax
				invoke Paste,ebx,[ebx].EDIT.focus,eax
				pop		eax
				invoke GlobalFree,eax
				inc		nUndoid
				invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
				invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_LOCKUNDOID:
			.if wParam
				mov		eax,nUndoid
				inc		eax
				mov		[ebx].EDIT.lockundoid,eax
				inc		eax
				mov		nUndoid,eax
			.else
				mov		[ebx].EDIT.lockundoid,0
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_ADDBLOCKDEF:
			invoke SetBlockDef,lParam
			xor		eax,eax
			ret
		align 4
		_REM_CONVERT:
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				invoke IsSelectionLocked,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				or		eax,eax
				jne		ErrBeep
				.if wParam==CONVERT_TABTOSPACE || wParam==CONVERT_SPACETOTAB
					invoke ConvertIndent,ebx,wParam
				.else
					invoke ConvertCase,ebx,wParam
				.endif
				invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
				invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
				invoke SetCaret,ebx,[esi].RAEDT.cpy
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_BRACKETMATCH:
			.if lParam
				mov		edx,lParam
				mov		ecx,offset bracketstart
				.while byte ptr [edx] && byte ptr [edx]!=','
					mov		al,[edx]
					mov		[ecx],al
					inc		edx
					inc		ecx
				.endw
				mov		byte ptr [ecx],0
				mov		ecx,offset bracketend
				.if byte ptr [edx]==','
					inc		edx
					.while byte ptr [edx] && byte ptr [edx]!=','
						mov		al,[edx]
						mov		[ecx],al
						inc		edx
						inc		ecx
					.endw
				.endif
				mov		byte ptr [ecx],0
				mov		ecx,offset bracketcont
				.if byte ptr [edx]==','
					inc		edx
					.while byte ptr [edx]
						mov		al,[edx]
						mov		[ecx],al
						inc		edx
						inc		ecx
					.endw
				.endif
				mov		byte ptr [ecx],0FFh
				xor		eax,eax
			.else
				mov		eax,[ebx].EDIT.cpMin
				.if eax==[ebx].EDIT.cpMax
					invoke GetChar,ebx,[ebx].EDIT.cpMin
					invoke BracketMatch,ebx,eax,[ebx].EDIT.cpMin
				.endif
			.endif
			ret
		align 4
		_REM_COMMAND:
			invoke GetFocus
			.if eax==[ebx].EDIT.edta.hwnd || eax==[ebx].EDIT.edtb.hwnd
				mov		ecx,wParam
				mov		fAlt,0
				mov		fControl,0
				mov		fShift,0
				test	ecx,CMD_ALT
				.if !ZERO?
					mov		fAlt,TRUE
				.endif
				test	ecx,CMD_CTRL
				.if !ZERO?
					mov		fControl,TRUE
				.endif
				test	ecx,CMD_SHIFT
				.if !ZERO?
					mov		fShift,TRUE
				.endif
				movzx	ecx,cl
				invoke EditFunc,eax,ecx,fAlt,fShift,fControl
			.endif
			xor		eax,eax
			ret
		align 4
		_REM_CASEWORD:
			;wParam=cp
			;lParam=lpBuff
			mov		edx,wParam
			invoke GetWordStart,ebx,edx,0
			mov		esi,[ebx].EDIT.rpChars
			sub		eax,[ebx].EDIT.cpLine
			add		esi,[ebx].EDIT.hChars
			mov		ecx,[esi].CHARS.len
			add		esi,eax
			sub		ecx,eax
			add		esi,sizeof CHARS
			mov		edi,lParam
			.while byte ptr [edi] && sdword ptr ecx>=0
				mov		al,[edi]
				mov		[esi],al
				inc		edi
				inc		esi
				dec		ecx
			.endw
			xor		eax,eax
			ret
		align 4
		_REM_GETBLOCKEND:
			;wParam=nLine
			;lParam=0
			invoke CollapseGetEnd,ebx,wParam
			ret
		align 4
		_REM_SETLOCK:
			;wParam=TRUE/FALSE
			;lParam=0
			.if wParam
				mov		eax,TRUE
			.else
				xor		eax,eax
			.endif
			mov		[ebx].EDIT.fLock,eax
			invoke CheckDlgButton,hWin,-5,eax
			xor		eax,eax
			ret
		align 4
		_REM_GETLOCK:
			;wParam=0
			;lParam=0
			mov		eax,[ebx].EDIT.fLock
			ret
		align 4
		_REM_GETWORDFROMPOS:
			;wParam=cp
			;lParam=lpBuff
			invoke GetWordStart,ebx,wParam,0
			mov		esi,[ebx].EDIT.rpChars
			mov		ecx,eax
			sub		ecx,[ebx].EDIT.cpLine
			push	ecx
			push	eax
			invoke GetWordEnd,ebx,eax,0
			pop		ecx
			pop		edx
			sub		eax,ecx
			mov		ecx,eax
			mov		edi,lParam
			add		esi,[ebx].EDIT.hChars
			add		esi,edx
			add		esi,sizeof CHARS
			mov		eax,ecx
			rep movsb
			mov		byte ptr [edi],0
			ret
		align 4
		_REM_SETNOBLOCKLINE:
			;wParam=Line
			;lParam=TRUE/FALSE
			invoke NoBlockLine,ebx,wParam,lParam
			ret
		align 4
		_REM_ISLINENOBLOCK:
			;wParam=Line
			;lParam=0
			invoke IsLineNoBlock,ebx,wParam
			.if eax
				mov		eax,TRUE
			.endif
			ret
		align 4
		_REM_SETALTHILITELINE:
			;wParam=nLine
			;lParam=TRUE/FALSE
			invoke AltHiliteLine,ebx,wParam,lParam
			ret
		align 4
		_REM_ISLINEALTHILITE:
			;wParam=nLine
			;lParam=0
			invoke IsLineAltHilite,ebx,wParam
			.if eax
				mov		eax,TRUE
			.endif
			ret
		align 4
		_REM_SETCURSORWORDTYPE:
			;wParam=Type
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.nCursorWordType,eax
			ret
		align 4
		_REM_SETBREAKPOINT:
			;wParam=nLine
			;lParam=TRUE/FALSE
			invoke SetBreakpoint,ebx,wParam,lParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			ret
		align 4
		_REM_NEXTBREAKPOINT:
			;wParam=nLine
			;lParam=0
			invoke NextBreakpoint,ebx,wParam
			ret
		align 4
		_REM_GETLINESTATE:
			;wParam=nLine
			;lParam=0
			invoke GetLineState,ebx,wParam
			ret
		align 4
		_REM_SETERROR:
			;wParam=nLine
			;lParam=nErrID
			invoke SetError,ebx,wParam,lParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			ret
		_REM_GETERROR:
			;wParam=nLine
			;lParam=0
			invoke GetError,ebx,wParam
			ret
		align 4
		_REM_NEXTERROR:
			;wParam=nLine
			;lParam=0
			invoke NextError,ebx,wParam
			ret
		align 4
		_REM_CHARTABINIT:
			;wParam=0
			;lParam=0
			mov		esi,offset CharTabInit
			mov		edi,offset CharTab
			mov		ecx,256
			rep		movsb
			ret
		align 4
		_REM_LINEREDTEXT:
			;wParam=nLine
			;lParam=TRUE/FALSE
			invoke SetRedText,ebx,wParam,lParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edta.hwnd,wParam
			invoke InvalidateLine,ebx,[ebx].EDIT.edtb.hwnd,wParam
			ret
		align 4
		_REM_SETSTYLEEX:
			mov		eax,wParam
			mov		[ebx].EDIT.fstyleex,eax
			invoke InvalidateRect,hWin,NULL,TRUE
			ret
		align 4
		_REM_GETUNICODE:
			mov		eax,[ebx].EDIT.funicode
			ret
		align 4
		_REM_SETUNICODE:
			mov		eax,wParam
			mov		[ebx].EDIT.funicode,eax
			ret
		align 4
		_REM_SETCHANGEDSTATE:
			invoke SetChangedState,ebx,wParam
			ret
		align 4
		_REM_SETTOOLTIP:
			mov		eax,wParam
			.if eax==1
				mov		eax,[ebx].EDIT.hsta
			.elseif eax==2
				mov		eax,[ebx].EDIT.hsbtn
			.elseif eax==3
				mov		eax,[ebx].EDIT.hlin
			.elseif eax==4
				mov		eax,[ebx].EDIT.hexp
			.elseif eax==5
				mov		eax,[ebx].EDIT.hcol
			.elseif eax==6
				mov		eax,[ebx].EDIT.hlock
			.else
				xor		eax,eax
			.endif
			.if eax
				mov		edx,lParam
				call SetToolTip
			.endif
			ret
		align 4
		_REM_HILITEACTIVELINE:
			mov		eax,lParam
			mov		[ebx].EDIT.fhilite,eax
			invoke HiliteLine,ebx,[ebx].EDIT.line,[ebx].EDIT.fhilite
			ret
		align 4
		_REM_GETUNDO:
			invoke GetUndo,ebx,wParam,lParam
			ret
		align 4
		_REM_SETUNDO:
			invoke SetUndo,ebx,wParam,lParam
			ret
		align 4
		_REM_GETLINEBEGIN:
			invoke GetLineBegin,ebx,wParam
			ret
        align 4
        _REM_GETCELLHEIGHT:
        	mov eax,[ebx].EDIT.fntinfo.fntht                    ; *** MOD ***
			ret
		align 4
		_REM_FOCUSEDSPLITT:
			invoke GetFocus                                     ; *** MOD ***
			.if     eax == [ebx].EDIT.edta.hwnd
				mov eax, 1
			.elseif eax == [ebx].EDIT.edtb.hwnd	
				mov eax, 2
			.else
				xor eax,eax	
			.endif
			ret
			
.data

align 4
_REM_BASE \
	dd _REM_SETHILITEWORDS		;equ REM_BASE+0
	dd _REM_SETFONT				;equ REM_BASE+1
	dd _REM_GETFONT				;equ REM_BASE+2	
	dd _REM_SETCOLOR			;equ REM_BASE+3	
	dd _REM_GETCOLOR			;equ REM_BASE+4	
	dd _REM_SETHILITELINE		;equ REM_BASE+5	
	dd _REM_GETHILITELINE		;equ REM_BASE+6	
	dd _REM_SETBOOKMARK			;equ REM_BASE+7	
	dd _REM_GETBOOKMARK			;equ REM_BASE+8	
	dd _REM_CLRBOOKMARKS		;equ REM_BASE+9	
	dd _REM_NXTBOOKMARK			;equ REM_BASE+10
	dd _REM_PRVBOOKMARK			;equ REM_BASE+11
	dd _REM_FINDBOOKMARK		;equ REM_BASE+12
	dd _REM_SETBLOCKS			;equ REM_BASE+13
	dd _REM_ISLINE				;equ REM_BASE+14
	dd _REM_GETWORD				;equ REM_BASE+15
	dd _REM_COLLAPSE			;equ REM_BASE+16
	dd _REM_COLLAPSEALL			;equ REM_BASE+17
	dd _REM_EXPAND				;equ REM_BASE+18
	dd _REM_EXPANDALL			;equ REM_BASE+19
	dd _REM_LOCKLINE			;equ REM_BASE+20
	dd _REM_ISLINELOCKED		;equ REM_BASE+21
	dd _REM_HIDELINE			;equ REM_BASE+22
	dd _REM_ISLINEHIDDEN		;equ REM_BASE+23
	dd _REM_AUTOINDENT			;equ REM_BASE+24
	dd _REM_TABWIDTH			;equ REM_BASE+25
	dd _REM_SELBARWIDTH			;equ REM_BASE+26
	dd _REM_LINENUMBERWIDTH		;equ REM_BASE+27
	dd _REM_MOUSEWHEEL			;equ REM_BASE+28
	dd _REM_SUBCLASS			;equ REM_BASE+29
	dd _REM_SETSPLIT			;equ REM_BASE+30
	dd _REM_GETSPLIT			;equ REM_BASE+31
	dd _REM_VCENTER				;equ REM_BASE+32
	dd _REM_REPAINT				;equ REM_BASE+33
	dd _REM_BMCALLBACK			;equ REM_BASE+34
	dd _REM_READONLY			;equ REM_BASE+35
	dd _REM_INVALIDATELINE		;equ REM_BASE+36
	dd _REM_SETPAGESIZE			;equ REM_BASE+37
	dd _REM_GETPAGESIZE			;equ REM_BASE+38
	dd _REM_GETCHARTAB			;equ REM_BASE+39
	dd _REM_SETCHARTAB			;equ REM_BASE+40
	dd _REM_SETCOMMENTBLOCKS	;equ REM_BASE+41
	dd _REM_SETWORDGROUP		;equ REM_BASE+42
	dd _REM_GETWORDGROUP		;equ REM_BASE+43
	dd _REM_SETBMID				;equ REM_BASE+44
	dd _REM_GETBMID				;equ REM_BASE+45
	dd _REM_ISCHARPOS			;equ REM_BASE+46
	dd _REM_HIDELINES			;equ REM_BASE+47
	dd _REM_SETDIVIDERLINE		;equ REM_BASE+48
	dd _REM_ISINBLOCK			;equ REM_BASE+49
	dd _REM_TRIMSPACE			;equ REM_BASE+50
	dd _REM_SAVESEL				;equ REM_BASE+51
	dd _REM_RESTORESEL			;equ REM_BASE+52
	dd _REM_GETCURSORWORD		;equ REM_BASE+53
	dd _REM_SETSEGMENTBLOCK		;equ REM_BASE+54
	dd _REM_GETMODE				;equ REM_BASE+55
	dd _REM_SETMODE				;equ REM_BASE+56
	dd _REM_GETBLOCK			;equ REM_BASE+57
	dd _REM_SETBLOCK			;equ REM_BASE+58
	dd _REM_BLOCKINSERT			;equ REM_BASE+59
	dd _REM_LOCKUNDOID			;equ REM_BASE+60
	dd _REM_ADDBLOCKDEF			;equ REM_BASE+61
	dd _REM_CONVERT				;equ REM_BASE+62
	dd _REM_BRACKETMATCH		;equ REM_BASE+63
	dd _REM_COMMAND				;equ REM_BASE+64
	dd _REM_CASEWORD			;equ REM_BASE+65
	dd _REM_GETBLOCKEND			;equ REM_BASE+66
	dd _REM_SETLOCK				;equ REM_BASE+67
	dd _REM_GETLOCK				;equ REM_BASE+68
	dd _REM_GETWORDFROMPOS		;equ REM_BASE+69
	dd _REM_SETNOBLOCKLINE		;equ REM_BASE+70
	dd _REM_ISLINENOBLOCK		;equ REM_BASE+71
	dd _REM_SETALTHILITELINE	;equ REM_BASE+72
	dd _REM_ISLINEALTHILITE		;equ REM_BASE+73
	dd _REM_SETCURSORWORDTYPE	;equ REM_BASE+74
	dd _REM_SETBREAKPOINT		;equ REM_BASE+75
	dd _REM_NEXTBREAKPOINT		;equ REM_BASE+76
	dd _REM_GETLINESTATE		;equ REM_BASE+77
	dd _REM_SETERROR			;equ REM_BASE+78
	dd _REM_GETERROR			;equ REM_BASE+79
	dd _REM_NEXTERROR			;equ REM_BASE+80
	dd _REM_CHARTABINIT			;equ REM_BASE+81
	dd _REM_LINEREDTEXT			;equ REM_BASE+82
	dd _REM_SETSTYLEEX			;equ REM_BASE+83
	dd _REM_GETUNICODE			;equ REM_BASE+84
	dd _REM_SETUNICODE			;equ REM_BASE+85
	dd _REM_SETCHANGEDSTATE		;equ REM_BASE+86
	dd _REM_SETTOOLTIP			;equ REM_BASE+87
	dd _REM_HILITEACTIVELINE	;equ REM_BASE+88
	dd _REM_GETUNDO				;equ REM_BASE+89
	dd _REM_SETUNDO				;equ REM_BASE+90
	dd _REM_GETLINEBEGIN		;equ REM_BASE+91
    dd _REM_GETCELLHEIGHT       ;equ REM_BASE+92
    dd _REM_FOCUSEDSPLITT       ;equ REM_BASE+93
.code
align 4
