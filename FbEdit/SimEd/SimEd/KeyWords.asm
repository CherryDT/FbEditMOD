
IDD_DLGKEYWORDS		equ 4000
IDC_LSTKWCOLORS		equ 4001
IDC_LSTKWACTIVE		equ 4014
IDC_LSTKWHOLD		equ 4013
IDC_LSTCOLORS		equ 4015
IDC_BTNKWAPPLY		equ 4002

IDC_BTNHOLD			equ 4009
IDC_BTNACTIVE		equ 4008
IDC_EDTKW			equ 4012
IDC_BTNADD			equ 4011
IDC_BTNDEL			equ 4010

IDC_CHKBOLD			equ 4004
IDC_CHKITALIC		equ 4003
IDC_CHKRCFILE		equ 4005
IDC_SPNTABSIZE		equ 4017
IDC_EDTTABSIZE		equ 4018
IDC_CHKEXPAND		equ 4019
IDC_CHKAUTOINDENT	equ 4020
IDC_CHKHILITELINE	equ 4021

szColors			db 'Back',0
					db 'Text',0
					db 'Selected back',0
					db 'Selected text',0
					db 'Comments',0
					db 'Strings',0
					db 'Operators',0
					db 'Hilited line #1',0
					db 'Hilited line #2',0
					db 'Hilited line #3',0
					db 'Selection bar',0
					db 'Selection bar pen',0
					db 'Line numbers',0
					db 'Numbers & hex',0
					db 'Changed line',0
					db 'Change saved',0
					db 0
szCustColors		db 'CustColors',0

.data?

nKWInx				dd ?
CustColors			dd 16 dup(?)
tempcol				RACOLOR <?>

.code

SetKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	mov		eax,nInx
	mov		nKWInx,eax
	invoke SendDlgItemMessage,hWin,idLst,LB_RESETCONTENT,0,0
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	invoke MakeKey,offset szGroup,nInx,addr buffer
	mov		lpcbData,16384
	invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,hMem,addr lpcbData
	mov		eax,hMem
	mov		al,[eax]
	mov		esi,nInx
	.if !al && esi<10
		shl		esi,2
		add		esi,offset kwcol
		mov		esi,[esi+40]
	.else
		mov		esi,hMem
	.endif
	dec		esi
  Nxt:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		Ex
	cmp		al,VK_SPACE
	je		Nxt
	lea		edi,buffer
  @@:
	mov		al,[esi]
	.if al==VK_SPACE || !al
		mov		byte ptr [edi],0
		invoke SendDlgItemMessage,hWin,idLst,LB_ADDSTRING,0,addr buffer
		dec		esi
		jmp		Nxt
	.endif
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  Ex:
	invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0
	.if eax!=LB_ERR
		shr		eax,24
		mov		esi,eax
		mov		eax,BST_UNCHECKED
		test	esi,1
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKBOLD,eax
		mov		eax,BST_UNCHECKED
		test	esi,2
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKITALIC,eax
		mov		eax,BST_UNCHECKED
		test	esi,10h
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKRCFILE,eax
	.endif
	invoke GlobalFree,hMem
	ret

SetKeyWordList endp

SaveKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	mov		edi,eax
	xor		esi,esi
  @@:
	invoke SendDlgItemMessage,hWin,idLst,LB_GETTEXT,esi,edi
	.if eax!=LB_ERR
		invoke lstrlen,edi
		add		edi,eax
		mov		byte ptr [edi],VK_SPACE
		inc		edi
		inc		esi
		jmp		@b
	.endif
	.if edi!=hMem
		mov		byte ptr [edi-1],0
	.endif
	sub		edi,hMem
	invoke MakeKey,offset szGroup,nInx,addr buffer
	invoke RegSetValueEx,hReg,addr buffer,0,REG_SZ,hMem,edi
	invoke GlobalFree,hMem
	ret

SaveKeyWordList endp

DeleteKeyWords proc hWin:HWND,idFrom:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

DeleteKeyWords endp

MoveKeyWords proc hWin:HWND,idFrom:DWORD,idTo:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_GETTEXT,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			invoke SendDlgItemMessage,hWin,idTo,LB_ADDSTRING,0,addr buffer
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

MoveKeyWords endp

UpdateKeyWords proc hWin:HWND
	LOCAL	nInx:DWORD

	mov		nInx,0
	.while nInx<10
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0
		mov		edx,nInx
		mov		[edx*4+offset kwcol],eax
		inc		nInx
	.endw
	invoke RegSetValueEx,hReg,addr szKeyWordColor,0,REG_BINARY,addr kwcol,40
	invoke SetKeyWords,hREd
	invoke UpdateAll,WM_PAINT
	ret

UpdateKeyWords endp

KeyWordsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	hBr:DWORD
	LOCAL	cc:CHOOSECOLOR
	LOCAL	pt:POINT
	LOCAL	fback:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	esi
		push	edi
		mov		esi,offset col
		mov		edi,offset tempcol
		mov		ecx,sizeof RACOLOR
		rep		movsb
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETRANGE,0,00010014h		; Set range
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETPOS,0,edopt.tabsize	; Set default value
		mov		eax,edopt.exptabs
		invoke CheckDlgButton,hWin,IDC_CHKEXPAND,eax
		mov		eax,edopt.indent
		invoke CheckDlgButton,hWin,IDC_CHKAUTOINDENT,eax
		mov		eax,edopt.hiliteline
		invoke CheckDlgButton,hWin,IDC_CHKHILITELINE,eax
		mov		esi,offset szColors
		mov		edi,offset col
		xor		ecx,ecx
	  @@:
		push	ecx
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,[edi]
		invoke lstrlen,esi
		pop		ecx
		add		esi,eax
		inc		esi
		.if ecx==13
			add		edi,16
		.endif
		add		edi,4
		inc		ecx
		mov		al,[esi]
		or		al,al
		jne		@b
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETCURSEL,0,0
		mov		edi,offset kwcol
		mov		nInx,0
		.while nInx<10
			invoke MakeKey,offset szGroup,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,[edi]
			add		edi,4
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETCURSEL,0,0
		invoke SetKeyWordList,hWin,IDC_LSTKWHOLD,10
		invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,0
		invoke SendDlgItemMessage,hWin,IDC_EDTKW,EM_LIMITTEXT,63,0
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		pop		edi
		pop		esi
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				call	Update
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNKWAPPLY
				call	Update
				mov		eax,IDC_BTNKWAPPLY
				xor		edx,edx
				call	EnButton
			.elseif eax==IDC_BTNHOLD
				invoke MoveKeyWords,hWin,IDC_LSTKWACTIVE,IDC_LSTKWHOLD
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNACTIVE
				invoke MoveKeyWords,hWin,IDC_LSTKWHOLD,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNACTIVE
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNADD
				invoke GetDlgItemText,hWin,IDC_EDTKW,addr buffer,64
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,addr buffer
				mov		buffer,0
				invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNDEL
				invoke DeleteKeyWords,hWin,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKBOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,01000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKITALIC
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,02000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKRCFILE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,10000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKEXPAND
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKAUTOINDENT
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKHILITELINE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTKW
				invoke SendDlgItemMessage,hWin,IDC_EDTKW,WM_GETTEXTLENGTH,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNADD
				call	EnButton
			.elseif eax==IDC_EDTTABSIZE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTKWCOLORS
				invoke SaveKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,eax
				invoke GetDlgItem,hWin,IDC_BTNHOLD
				invoke EnableWindow,eax,FALSE
				invoke GetDlgItem,hWin,IDC_BTNDEL
				invoke EnableWindow,eax,FALSE
			.elseif eax==IDC_LSTKWACTIVE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				push	eax
				mov		edx,eax
				mov		eax,IDC_BTNHOLD
				call	EnButton
				pop		edx
				mov		eax,IDC_BTNDEL
				call	EnButton
			.elseif eax==IDC_LSTKWHOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNACTIVE
				call	EnButton
			.endif
		.elseif edx==LBN_DBLCLK
			.if eax==IDC_LSTKWCOLORS
				mov		cc.lStructSize,sizeof CHOOSECOLOR
				mov		eax,hWin
				mov		cc.hwndOwner,eax
				mov		eax,hInstance
				mov		cc.hInstance,eax
				mov		cc.lpCustColors,offset CustColors
				mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
				mov		cc.lCustData,0
				mov		cc.lpfnHook,0
				mov		cc.lpTemplateName,0
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				push	eax
				;Mask off group/font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
					pop		ecx
					mov		edx,cc.rgbResult
					;Group/Font
					and		ecx,0FF000000h
					or		edx,ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,edx
					invoke GetDlgItem,hWin,IDC_LSTKWCOLORS
					invoke InvalidateRect,eax,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_LSTKWACTIVE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETTEXT,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				.endif
			.elseif eax==IDC_LSTKWHOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETTEXT,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				.endif
			.elseif eax==IDC_LSTCOLORS
				mov		cc.lStructSize,sizeof CHOOSECOLOR
				mov		eax,hWin
				mov		cc.hwndOwner,eax
				mov		eax,hInstance
				mov		cc.hInstance,eax
				mov		cc.lpCustColors,offset CustColors
				mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
				mov		cc.lCustData,0
				mov		cc.lpfnHook,0
				mov		cc.lpTemplateName,0
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
				mov		fback,0
				.if (eax>=4 && eax<=6) || eax==13
					push	eax
					invoke GetCursorPos,addr pt
					invoke GetDlgItem,hWin,IDC_LSTCOLORS
					mov		edx,eax
					invoke ScreenToClient,edx,addr pt
					.if pt.x>30 && pt.x<60
						inc		fback
					.endif
					pop		eax
				.endif
				.if fback
					.if eax==4
						mov		eax,tempcol.cmntback
					.elseif eax==5
						mov		eax,tempcol.strback
					.elseif eax==6
						mov		eax,tempcol.oprback
					.elseif eax==13
						mov		eax,tempcol.numback
					.endif
				.else
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,eax,0
				.endif
				push	eax
				;Mask off font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
					pop		ecx
					mov		edx,cc.rgbResult
					.if fback
						.if eax==4 && ecx
							mov		tempcol.cmntback,edx
						.elseif eax==5
							mov		tempcol.strback,edx
						.elseif eax==6
							mov		tempcol.oprback,edx
						.elseif eax==13
							mov		tempcol.numback,edx
						.endif
					.else
						;Font
						and		ecx,0FF000000h
						or		edx,ecx
						invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,edx
					.endif
					invoke GetDlgItem,hWin,IDC_LSTCOLORS
					invoke InvalidateRect,eax,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.endif
		.endif
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		test	[esi].itemState,ODS_SELECTED
		.if ZERO?
			push	COLOR_WINDOW
			mov		eax,COLOR_WINDOWTEXT
		.else
			push	COLOR_HIGHLIGHT
			mov		eax,COLOR_HIGHLIGHTTEXT
		.endif
		invoke GetSysColor,eax
		invoke SetTextColor,[esi].hdc,eax
		pop		eax
		invoke GetSysColor,eax
		invoke SetBkColor,[esi].hdc,eax
		invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
		mov		eax,[esi].rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,25
		mov		rect.right,eax
		mov		eax,[esi].rcItem.top
		inc		eax
		mov		rect.top,eax
		mov		eax,[esi].rcItem.bottom
		dec		eax
		mov		rect.bottom,eax
		mov		eax,[esi].itemData
		and		eax,0FFFFFFh
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		invoke FillRect,[esi].hdc,addr rect,hBr
		invoke DeleteObject,hBr
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,[esi].hdc,addr rect,eax
		.if [esi].CtlID==IDC_LSTCOLORS
			mov		ecx,[esi].itemID
			.if (ecx>=4 && ecx<=6) || ecx==13
				add		rect.left,30
				add		rect.right,30
				.if ecx==4
					mov		eax,tempcol.cmntback
				.elseif ecx==5
					mov		eax,tempcol.strback
				.elseif ecx==6
					mov		eax,tempcol.oprback
				.elseif ecx==13
					mov		eax,tempcol.numback
				.endif
				and		eax,0FFFFFFh
				invoke CreateSolidBrush,eax
				mov		hBr,eax
				invoke FillRect,[esi].hdc,addr rect,hBr
				invoke DeleteObject,hBr
				invoke GetStockObject,BLACK_BRUSH
				invoke FrameRect,[esi].hdc,addr rect,eax
			.endif
		.endif
		invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
		invoke lstrlen,addr buffer
		mov		edx,[esi].rcItem.left
		mov		ecx,[esi].itemID
		.if [esi].CtlID==IDC_LSTCOLORS
			.if (ecx>=4 && ecx<=6) || ecx==13
				add		edx,30
			.endif
		.endif
		add		edx,30
		invoke TextOut,[esi].hdc,edx,[esi].rcItem.top,addr buffer,eax
		assume esi:nothing
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EnButton:
	push	edx
	invoke GetDlgItem,hWin,eax
	pop		edx
	invoke EnableWindow,eax,edx
	retn

Update:
	invoke SaveKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
	invoke SaveKeyWordList,hWin,IDC_LSTKWHOLD,10
	invoke UpdateKeyWords,hWin
	invoke GetDlgItemInt,hWin,IDC_EDTTABSIZE,NULL,FALSE
	mov		edopt.tabsize,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKEXPAND
	mov		edopt.exptabs,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOINDENT
	mov		edopt.indent,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKHILITELINE
	mov		edopt.hiliteline,eax
	push	edi
	mov		edi,offset col
	xor		eax,eax
  @@:
	push	eax
	invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,eax,0
	mov		[edi],eax
	pop		eax
	.if eax==13
		add		edi,16
	.endif
	inc		eax
	add		edi,4
	cmp		edi,offset col+sizeof col
	jc		@b
	pop		edi
	mov		eax,tempcol.cmntback
	mov		col.cmntback,eax
	mov		eax,tempcol.strback
	mov		col.strback,eax
	mov		eax,tempcol.oprback
	mov		col.oprback,eax
	mov		eax,tempcol.numback
	mov		col.numback,eax
	invoke UpdateAll,WM_SETFONT
	invoke RegSetValueEx,hReg,addr szEditOpt,0,REG_BINARY,addr edopt,sizeof edopt
	invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
	invoke RegSetValueEx,hReg,addr szCustColors,0,REG_BINARY,addr CustColors,sizeof CustColors
	retn

KeyWordsProc endp
