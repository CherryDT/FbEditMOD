		align 4 
		_EM_EXLINEFROMCHAR:
			;wParam=0
			;lParam=cp
			invoke GetCharPtr,ebx,lParam
			mov		eax,edx
			ret
		align 4 
		_EM_EXSETSEL:
			;wParam=0
			;lParam=lpCHARRANGE
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				.if ![ebx].EDIT.fHideSel
					mov		eax,[ebx].EDIT.cpMin
					.if eax!=[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
						invoke InvalidateSelection,ebx,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
					.endif
				.endif
				mov		edi,lParam
				invoke GetCharPtr,ebx,[edi].CHARRANGE.cpMax
				mov		[ebx].EDIT.cpMax,ecx
				invoke GetCharPtr,ebx,[edi].CHARRANGE.cpMin
				mov		[ebx].EDIT.cpMin,ecx
				push	edx
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
				pop		eax
			.else
				xor		eax,eax
				dec		eax
			.endif
			ret
		align 4 
		_EM_EXGETSEL:
			;wParam=0
			;lParam=lpCHARRANGE
			mov		edx,lParam
			mov		eax,[ebx].EDIT.cpMin
			mov		ecx,[ebx].EDIT.cpMax
			.if eax>ecx
				xchg	eax,ecx
			.endif
			mov		[edx].CHARRANGE.cpMin,eax
			mov		[edx].CHARRANGE.cpMax,ecx
			xor		eax,eax
			ret
		align 4 
		_EM_FINDTEXTEX:
			;wParam=Flags
			;lParam=lpFINDTEXTEX
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				invoke FindTextEx,ebx,wParam,lParam
			.else
				xor		eax,eax
				dec		eax
			.endif
			ret
		align 4 
		_EM_GETTEXTRANGE:
			;wParam=0
			;lParam=lpTEXTRANGE
			mov		edx,lParam
			invoke GetText,ebx,[edx].TEXTRANGE.chrg.cpMin,[edx].TEXTRANGE.chrg.cpMax,[edx].TEXTRANGE.lpstrText,FALSE
			ret
		align 4 
		_EM_FINDWORDBREAK:
			;wParam=uFlags
			;lParam=cp
			mov		eax,wParam
			.if eax==WB_MOVEWORDLEFT
				invoke GetWordStart,ebx,lParam,0
			.elseif eax==WB_MOVEWORDRIGHT
				invoke GetWordEnd,ebx,lParam,0
			.else
				mov		eax,lParam
			.endif
			ret
		align 4 
		_EM_CANREDO:
			;wParam=0
			;lParam=0
			xor		eax,eax
			test	[ebx].EDIT.nMode,MODE_BLOCK
			.if ZERO?
				mov		edx,[ebx].EDIT.hUndo
				add		edx,[ebx].EDIT.rpUndo
				mov		eax,[edx].RAUNDO.cb
				.if eax
					mov		eax,TRUE
				.endif
			.endif
			ret
		align 4 
		_EM_REDO:
			;wParam=0
			;lParam=0
			inc		nUndoid
			invoke Redo,ebx,[esi].RAEDT.hwnd
			inc		nUndoid
			ret
		align 4 
		_EM_HIDESELECTION:
			;wParam=TRUE/FALSE
			;lParam=0
			mov		eax,wParam
			mov		[ebx].EDIT.fHideSel,eax
			ret
		align 4 
		_EM_GETSELTEXT:
			;wParam=0
			;lParam=lpBuff
			invoke GetText,ebx,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax,lParam,FALSE
			ret
		align 4 
		_EM_CANPASTE:
			;wParam=CF_TEXT
			;lParam=0
			invoke IsClipboardFormatAvailable,wParam
			ret
		align 4 
		_EM_STREAMIN:
			;wParam=SF_TEXT
			;lParam=lpStream
			invoke GetCursor
			push	eax
			invoke xSetCursor, IDC_WAIT, FALSE
			invoke StreamIn,ebx,lParam
			xor		eax,eax
			mov		[ebx].EDIT.edta.cpy,eax
			mov		[ebx].EDIT.edta.cpxmax,eax
			mov		[ebx].EDIT.edta.topyp,eax
			mov		[ebx].EDIT.edta.topln,eax
			mov		[ebx].EDIT.edta.topcp,eax
			mov		[ebx].EDIT.edtb.cpy,eax
			mov		[ebx].EDIT.edtb.cpxmax,eax
			mov		[ebx].EDIT.edtb.topyp,eax
			mov		[ebx].EDIT.edtb.topln,eax
			mov		[ebx].EDIT.edtb.topcp,eax
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,eax
			mov		[ebx].EDIT.blrg.lnMin,eax
			mov		[ebx].EDIT.blrg.clMin,eax
			mov		[ebx].EDIT.blrg.lnMax,eax
			mov		[ebx].EDIT.blrg.clMax,eax
			mov		[ebx].EDIT.line,eax
			mov		[ebx].EDIT.cpx,eax
			mov		[ebx].EDIT.cpLine,eax
			mov		[ebx].EDIT.rpLine,eax
			mov		[ebx].EDIT.rpChars,eax
			invoke GetCharPtr,ebx,0
			invoke InvalidateEdit,ebx,[ebx].EDIT.edta.hwnd
			invoke InvalidateEdit,ebx,[ebx].EDIT.edtb.hwnd
			invoke SetCaret,ebx,0
			invoke SelChange,ebx,SEL_TEXT
			pop		eax
			invoke xSetCursor, eax, TRUE
			inc		nUndoid
			xor		eax,eax
			ret
		align 4 
		_EM_STREAMOUT:
			;wParam=SF_TEXT
			;lParam=lpStream
			invoke GetCursor
			push	eax
			invoke xSetCursor, IDC_WAIT, FALSE
			invoke StreamOut,ebx,lParam
			pop		eax
			invoke xSetCursor, eax, TRUE
			xor		eax,eax
			ret
		align 4 
		_EM_FORMATRANGE:
			mov		edi,lParam
			.if edi
				invoke GetStockObject,SYSTEM_FONT
				invoke SelectObject,[edi].FORMATRANGE.hdc,eax
				push	eax
				mov		edx,eax
				invoke GetObject,edx,sizeof lf,addr lf
				pop		eax
				invoke SelectObject,[edi].FORMATRANGE.hdc,eax
				invoke GetDeviceCaps,[edi].FORMATRANGE.hdc,LOGPIXELSY
				push	eax
				invoke GetDeviceCaps,[edi].FORMATRANGE.hdcTarget,LOGPIXELSY
				mov		ecx,eax
				mov		eax,lf.lfHeight
				.if sdword ptr eax<0
					neg		eax
				.endif
				mul		ecx
				pop		ecx
				xor		edx,edx
				div		ecx
				;neg		eax
				mov		lf.lfHeight,eax

				invoke GetDeviceCaps,[edi].FORMATRANGE.hdc,LOGPIXELSX
				push	eax
				invoke GetDeviceCaps,[edi].FORMATRANGE.hdcTarget,LOGPIXELSX
				mov		ecx,eax
				mov		eax,lf.lfWidth
				mul		ecx
				pop		ecx
				xor		edx,edx
				div		ecx
				mov		lf.lfWidth,eax
				invoke CreateFontIndirect,addr lf
				invoke SelectObject,[edi].FORMATRANGE.hdcTarget,eax
				push	eax
				;Get tab width
				mov		eax,'WWWW'
				mov		pt.x,eax
				invoke GetTextExtentPoint32,[edi].FORMATRANGE.hdcTarget,addr pt.x,4,addr pt
				mov		eax,pt.x
				shr		eax,2
				mov		ecx,[ebx].EDIT.nTab
				mul		ecx
				mov		tabWt,eax
				invoke xGlobalAlloc,GMEM_FIXED,16384
				mov		esi,eax
				invoke ConvTwipsToPixels,[edi].FORMATRANGE.hdcTarget,TRUE,[edi].FORMATRANGE.rc.left
				mov		rect.left,eax
				invoke ConvTwipsToPixels,[edi].FORMATRANGE.hdcTarget,FALSE,[edi].FORMATRANGE.rc.top
				mov		rect.top,eax
				invoke ConvTwipsToPixels,[edi].FORMATRANGE.hdcTarget,TRUE,[edi].FORMATRANGE.rc.right
				mov		rect.right,eax
				invoke ConvTwipsToPixels,[edi].FORMATRANGE.hdcTarget,FALSE,[edi].FORMATRANGE.rc.bottom
				mov		rect.bottom,eax
				invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
				invoke SelectObject,[edi].FORMATRANGE.hdcTarget,eax
				push	eax
				invoke SendMessage,hWin,EM_LINEFROMCHAR,[edi].FORMATRANGE.chrg.cpMin,0
				mov		nLine,eax
			  @@:
				mov		word ptr [esi],16383
				invoke SendMessage,hWin,EM_GETLINE,nLine,esi
				mov		len,eax
				mov		eax,rect.top
				add		eax,pt.y
				.if eax<rect.bottom
					.if wParam
						invoke TabbedTextOut,[edi].FORMATRANGE.hdcTarget,rect.left,rect.top,esi,len,1,addr tabWt,rect.left
					.endif
					mov		eax,pt.y
					add		rect.top,eax
					inc		nLine
					invoke SendMessage,hWin,EM_LINEINDEX,nLine,0
					.if eax<[edi].FORMATRANGE.chrg.cpMax
						jmp		@b
					.endif
				.endif
				invoke GlobalFree,esi
				pop		eax
				invoke SelectObject,[edi].FORMATRANGE.hdcTarget,eax
				invoke DeleteObject,eax
				pop		eax
				invoke SelectObject,[edi].FORMATRANGE.hdcTarget,eax
				invoke DeleteObject,eax
				invoke SendMessage,hWin,EM_LINEINDEX,nLine,0
			.endif
			ret
		align 4
		_DefRichEditMsg:
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
			ret

.data
align 4
_RICHEDIT_MSG \
	dd _EM_CANPASTE				;(1024+50)
	dd _DefRichEditMsg			;(1024+51) _EM_DISPLAYBAND			<- DefWindowProc
	dd _EM_EXGETSEL				;(1024+52)
	dd _DefRichEditMsg			;(1024+53) _EM_EXLIMITTEXT			<- DefWindowProc
	dd _EM_EXLINEFROMCHAR		;(1024+54)
	dd _EM_EXSETSEL				;(1024+55)
	dd _DefRichEditMsg			;(1024+56) _EM_FINDTEXT				<- DefWindowProc
	dd _EM_FORMATRANGE			;(1024+57)
	dd _DefRichEditMsg			;(1024+58) _EM_GETCHARFORMAT		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+59) _EM_GETEVENTMASK			<- DefWindowProc
	dd _DefRichEditMsg			;(1024+60) _EM_GETOLEINTERFACE		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+61) _EM_GETPARAFORMAT		<- DefWindowProc
	dd _EM_GETSELTEXT			;(1024+62)
	dd _EM_HIDESELECTION		;(1024+63)
	dd _DefRichEditMsg			;(1024+64) _EM_PASTESPECIAL			<- DefWindowProc
	dd _DefRichEditMsg			;(1024+65) _EM_REQUESTRESIZE		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+66) _EM_SELECTIONTYPE		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+67) _EM_SETBKGNDCOLOR		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+68) _EM_SETCHARFORMAT		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+69) _EM_SETEVENTMASK			<- DefWindowProc
	dd _DefRichEditMsg			;(1024+70) _EM_SETOLECALLBACK		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+71) _EM_SETPARAFORMAT		<- DefWindowProc
	dd _DefRichEditMsg			;(1024+72) _EM_SETTARGETDEVICE		<- DefWindowProc
	dd _EM_STREAMIN				;(1024+73)
	dd _EM_STREAMOUT			;(1024+74)
	dd _EM_GETTEXTRANGE			;(1024+75)
	dd _EM_FINDWORDBREAK		;(1024+76)
	dd _DefRichEditMsg			;(1024+77) _EM_SETOPTIONS			<- DefWindowProc
	dd _DefRichEditMsg			;(1024+78) _EM_GETOPTIONS			<- DefWindowProc
	dd _EM_FINDTEXTEX			;(1024+79)
	dd _DefRichEditMsg			;(1024+80) _EM_GETWORDBREAKPROCEX	<- DefWindowProc
	dd _DefRichEditMsg			;(1024+81) _EM_SETWORDBREAKPROCEX	<- DefWindowProc
	dd _DefRichEditMsg			;(1024+82) _EM_SETUNDOLIMIT			<- DefWindowProc
	dd _DefRichEditMsg			;(1024+83) _UNKNOW_MSG				<- DefWindowProc
	dd _EM_REDO					;(1024+84)
	dd _EM_CANREDO				;(1024+85)

.code
align 4
