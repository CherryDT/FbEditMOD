.code

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	ret

DwToAscii endp

DoToolBar proc hInst:DWORD,hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	hInst
	pop		tbab.hInst
	mov		tbab.nID,IDB_TBRBMP
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,offset tbrbtns
	mov		eax,hToolBar
	ret

DoToolBar endp

SetWinCaption proc lpFileName:DWORD
	LOCAL	buffer[sizeof szAppName+3+MAX_PATH+16]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,offset szAppName
	mov		eax,' - '
	mov		dword ptr buffer1,eax
	invoke lstrcat,addr buffer,addr buffer1
	invoke lstrcat,addr buffer,lpFileName
	invoke SendMessage,hREd,REM_GETUNICODE,0,0
	.if eax
	invoke lstrcat,addr buffer,addr szUnicode
	.endif
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

SetFormat proc hWin:HWND
	LOCAL	rafnt:RAFONT

	mov		eax,hFont
	mov		rafnt.hFont,eax
	mov		eax,hIFont
	mov		rafnt.hIFont,eax
	mov		eax,hLnrFont
	mov		rafnt.hLnrFont,eax
	;Set fonts
	invoke SendMessage,hWin,REM_SETFONT,0,addr rafnt
	;Set tab width & expand tabs
	invoke SendMessage,hWin,REM_TABWIDTH,edopt.tabsize,edopt.exptabs
	;Set autoindent
	invoke SendMessage,hWin,REM_AUTOINDENT,0,edopt.indent
	;Set number of lines mouse wheel will scroll
	;NOTE! If you have mouse software installed, set to 0
	invoke SendMessage,hWin,REM_MOUSEWHEEL,3,0
;	;Set selection bar width
;	invoke SendMessage,hWin,REM_SELBARWIDTH,20,0
;	;Set linenumber width
;	invoke SendMessage,hWin,REM_LINENUMBERWIDTH,40,0
	ret

SetFormat endp

ShowPos proc nLine:DWORD,nPos:DWORD
	LOCAL	buffer[64]:BYTE

	mov		edx,nLine
	inc		edx
	invoke DwToAscii,edx,addr buffer[4]
	mov		dword ptr buffer,' :nL'
	invoke lstrlen,addr buffer
	mov		dword ptr buffer[eax],'soP '
	mov		dword ptr buffer[eax+4],' :'
	mov		edx,nPos
	inc		edx
	invoke DwToAscii,edx,addr buffer[eax+6]
	invoke SetDlgItemText,hWnd,IDC_SBR,addr buffer
	ret

ShowPos endp

RemoveFileExt proc lpFileName:DWORD

	invoke lstrlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='.'
			mov		byte ptr [edx+eax],0
			.break
		.endif
	.endw
	ret

RemoveFileExt endp

RemoveFileName proc lpFileName:DWORD

	invoke lstrlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='\'
			mov		byte ptr [edx+eax+1],0
			.break
		.endif
	.endw
	ret

RemoveFileName endp

MakeKey proc lpszStr:DWORD,nInx:DWORD,lpszKey:DWORD

	invoke lstrcpy,lpszKey,lpszStr
	invoke lstrlen,lpszKey
	add		eax,lpszKey
	invoke DwToAscii,nInx,eax
	ret

MakeKey endp

SetBlockDefs proc uses esi,hWin:HWND

	;Reset block defs
	invoke SendMessage,hWin,REM_ADDBLOCKDEF,0,0
	mov		esi,offset blocks
	.while dword ptr [esi]
		invoke SendMessage,hWin,REM_ADDBLOCKDEF,0,[esi]
		add		esi,4
	.endw
	invoke SendMessage,hWin,REM_BRACKETMATCH,0,offset szBracketMatch
	ret

SetBlockDefs endp

SetKeyWords proc hWin:HWND
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[64]:BYTE

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	;Reset wordlist
	invoke SendMessage,hWin,REM_SETHILITEWORDS,0,0
	mov		nInx,0
	.while nInx<10
		invoke RtlZeroMemory,hMem,16384
		invoke MakeKey,offset szGroup,nInx,addr buffer
		mov		lpcbData,16384
		invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,hMem,addr lpcbData
		mov		eax,hMem
		mov		al,[eax]
		mov		edx,nInx
		shl		edx,2
		add		edx,offset kwcol
		.if !al
			mov		ecx,[edx+40]
		.else
			mov		ecx,hMem
		.endif
		mov		eax,[edx]
		invoke SendMessage,hWin,REM_SETHILITEWORDS,eax,ecx
		inc		nInx
	.endw
	invoke GlobalFree,hMem
	ret

SetKeyWords endp

IndentComment proc uses esi,nChr:DWORD,fN:DWORD
	LOCAL	ochr:CHARRANGE
	LOCAL	chr:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	buffer[32]:BYTE

	invoke SendMessage,hREd,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hREd,REM_LOCKUNDOID,TRUE,0
	.if fN
		mov		eax,nChr
		mov		dword ptr buffer[0],eax
	.endif
	invoke SendMessage,hREd,EM_EXGETSEL,0,addr ochr
	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chr
	invoke SendMessage,hREd,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chr.cpMin
	mov		LnSt,eax
	mov		eax,chr.cpMax
	dec		eax
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxt:
	mov		eax,LnSt
	.if eax<=LnEn
;		invoke SendMessage,hREd,REM_GETBOOKMARK,LnSt,0
;		.if eax==2
;			invoke SendMessage,hREd,REM_EXPAND,LnSt,0
;		.endif
		invoke SendMessage,hREd,EM_LINEINDEX,LnSt,0
		mov		chr.cpMin,eax
		inc		LnSt
		.if fN
			mov		chr.cpMax,eax
			invoke SendMessage,hREd,EM_EXSETSEL,0,addr chr
			invoke SendMessage,hREd,EM_REPLACESEL,TRUE,addr buffer
			invoke lstrlen,addr buffer
			add		ochr.cpMax,eax
			jmp		nxt
		.else
			invoke SendMessage,hREd,EM_LINEINDEX,LnSt,0
			mov		chr.cpMax,eax
			invoke SendMessage,hREd,EM_EXSETSEL,0,addr chr
			invoke SendMessage,hREd,EM_GETSELTEXT,0,addr LineTxt
			mov		esi,offset LineTxt
			xor		eax,eax
			mov		al,[esi]
			.if eax==nChr
				inc		esi
				invoke SendMessage,hREd,EM_REPLACESEL,TRUE,esi
				dec		ochr.cpMax
			.elseif nChr==09h
				mov		ecx,edopt.tabsize
				dec		esi
			  @@:
				inc		esi
				mov		al,[esi]
				cmp		al,' '
				jne		@f
				loop	@b
				inc		esi
			  @@:
				.if al==09h
					inc		esi
					dec		ecx
				.endif
				mov		eax,edopt.tabsize
				sub		eax,ecx
				sub		ochr.cpMax,eax
				invoke SendMessage,hREd,EM_REPLACESEL,TRUE,esi
			.endif
			jmp		nxt
		.endif
	.endif
	invoke SendMessage,hREd,EM_EXSETSEL,0,addr ochr
	invoke SendMessage,hREd,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,hREd,EM_SCROLLCARET,0,0
	invoke SendMessage,hREd,REM_LOCKUNDOID,FALSE,0
	invoke SendMessage,hREd,WM_SETREDRAW,TRUE,0
	invoke SendMessage,hREd,REM_REPAINT,0,0
	ret

IndentComment endp

GetSelText proc lpBuff:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	sub		eax,chrg.cpMin
	.if eax && eax<256
		invoke SendMessage,hREd,EM_GETSELTEXT,0,lpBuff
	.endif
	ret

GetSelText endp

GetPrnCaps proc
	LOCAL	buffer[256]:BYTE

	invoke GetUserDefaultLCID
	mov		edx,eax
	invoke GetLocaleInfo,edx,LOCALE_IMEASURE,addr buffer,sizeof buffer
	mov		al,buffer
	.if al=='1'
		mov		eax,1
	.else
		mov		eax,0
	.endif
	mov		prnInches,eax
	ret

GetPrnCaps endp

ConvToTwipsRects proc uses ebx esi edi,lppsd:ptr PAGESETUPDLG,lprc:ptr RECT,lprcPage:ptr RECT

	mov		ebx,lppsd
	mov		esi,lprcPage
	mov		edi,lprc
	mov		eax,[ebx].PAGESETUPDLG.rtMargin.left
	call	ConvTwips
	mov		[esi].RECT.left,0
	mov		[edi].RECT.left,eax
	mov		eax,[ebx].PAGESETUPDLG.rtMargin.top
	call	ConvTwips
	mov		[esi].RECT.top,0
	mov		[edi].RECT.top,eax
	mov		eax,[ebx].PAGESETUPDLG.ptPaperSize.x
	call	ConvTwips
	mov		[esi].RECT.right,eax
	mov		[edi].RECT.right,eax
	mov		eax,[ebx].PAGESETUPDLG.ptPaperSize.y
	call	ConvTwips
	mov		[esi].RECT.bottom,eax
	mov		[edi].RECT.bottom,eax
	mov		eax,[ebx].PAGESETUPDLG.rtMargin.right
	call	ConvTwips
	sub		[edi].RECT.right,eax
	mov		eax,[ebx].PAGESETUPDLG.rtMargin.bottom
	call	ConvTwips
	sub		[edi].RECT.bottom,eax
	ret

ConvTwips:
	.if !prnInches
		;millimeters
		mov		ecx,567
	.else
		;Inches
		mov		ecx,1440
	.endif
	mul		ecx
	mov		ecx,1000
	div		ecx
	retn

ConvToTwipsRects endp

MulDivRect proc uses ebx edi,lprc:ptr RECT,valmul:DWORD,valdiv:DWORD

	mov		edi,lprc
	mov		ecx,valmul
	mov		ebx,valdiv
	mov		eax,[edi].RECT.left
	cdq
	imul	ecx
	idiv	ebx
	mov		[edi].RECT.left,eax
	mov		eax,[edi].RECT.top
	cdq
	imul	ecx
	idiv	ebx
	mov		[edi].RECT.top,eax
	mov		eax,[edi].RECT.right
	cdq
	imul	ecx
	idiv	ebx
	mov		[edi].RECT.right,eax
	mov		eax,[edi].RECT.bottom
	cdq
	imul	ecx
	idiv	ebx
	mov		[edi].RECT.bottom,eax
	ret

MulDivRect endp

ConvToPixRects proc uses ebx esi edi,hDC:HDC,lppsd:ptr PAGESETUPDLG,lprc:ptr RECT,lprcPage:ptr RECT
	LOCAL	lpx:DWORD
	LOCAL	lpy:DWORD

	invoke GetDeviceCaps,hDC,LOGPIXELSX
	mov		lpx,eax
	invoke GetDeviceCaps,hDC,LOGPIXELSY
	mov		lpy,eax

	mov		ebx,lppsd
	mov		esi,lprcPage
	mov		edi,lprc
	mov		edx,[ebx].PAGESETUPDLG.rtMargin.left
	mov		eax,lpx
	call	ConvPix
	mov		[esi].RECT.left,0
	mov		[edi].RECT.left,eax
	mov		edx,[ebx].PAGESETUPDLG.rtMargin.top
	mov		eax,lpy
	call	ConvPix
	mov		[esi].RECT.top,0
	mov		[edi].RECT.top,eax
	mov		edx,[ebx].PAGESETUPDLG.ptPaperSize.x
	mov		eax,lpx
	call	ConvPix
	mov		[esi].RECT.right,eax
	mov		[edi].RECT.right,eax
	mov		edx,[ebx].PAGESETUPDLG.ptPaperSize.y
	mov		eax,lpy
	call	ConvPix
	mov		[esi].RECT.bottom,eax
	mov		[edi].RECT.bottom,eax
	mov		edx,[ebx].PAGESETUPDLG.rtMargin.right
	mov		eax,lpx
	call	ConvPix
	sub		[edi].RECT.right,eax
	mov		edx,[ebx].PAGESETUPDLG.rtMargin.bottom
	mov		eax,lpy
	call	ConvPix
	sub		[edi].RECT.bottom,eax
	ret

ConvPix:
	push	edx
	.if !prnInches
		mov		ecx,1000
		mul		ecx
		mov		ecx,254
		div		ecx
	.else
		mov		ecx,10
		mul		ecx
	.endif
	mov		ecx,eax		;Pix pr. 100mm / 10"
	pop		eax
	mul		ecx
	mov		ecx,10000
	div		ecx
	retn

ConvToPixRects endp
