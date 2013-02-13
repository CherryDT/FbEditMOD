.data?

prnInches		dd ?

.code

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

ConvToPix proc lLPix:DWORD,lSize:DWORD

	mov		eax,lLPix
	.if !prnInches
		mov		ecx,1000
		mul		ecx
		xor		edx,edx
		mov		ecx,254
		div		ecx
	.else
		mov		ecx,10
		mul		ecx
	.endif
	mov		ecx,eax		;Pix pr. 100mm / 10"
	mov		eax,lSize
	mul		ecx
	xor		edx,edx
	mov		ecx,10000
	div		ecx
	ret

ConvToPix endp

Print proc uses ebx
	LOCAL	doci:DOCINFO
	LOCAL	pX:DWORD
	LOCAL	pY:DWORD
	LOCAL	pML:DWORD
	LOCAL	pMT:DWORD
	LOCAL	pMR:DWORD
	LOCAL	pMB:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	hRgn:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	lf:LOGFONT
	LOCAL	hPrFont:DWORD
	LOCAL	nLine:DWORD
	LOCAL	nPageno:DWORD
	LOCAL	nMPage:DWORD
	LOCAL	nMLine:DWORD
	LOCAL	ptX:DWORD
	LOCAL	ptY:DWORD
	LOCAL	tWt:DWORD

	invoke GetPrnCaps
	invoke GetDeviceCaps,pd.hDC,LOGPIXELSX
	mov		ebx,eax
	invoke ConvToPix,ebx,psd.ptPaperSize.x
	mov		pX,eax
	invoke ConvToPix,ebx,psd.rtMargin.left
	mov		pML,eax
	invoke ConvToPix,ebx,psd.rtMargin.right
	mov		pMR,eax
	invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
	mov		ebx,eax
	invoke ConvToPix,ebx,psd.ptPaperSize.y
	mov		pY,eax
	invoke ConvToPix,ebx,psd.rtMargin.top
	mov		pMT,eax
	invoke ConvToPix,ebx,psd.rtMargin.bottom
	mov		pMB,eax
	invoke RtlZeroMemory,addr lf,sizeof lf
	invoke strcpy,addr lf.lfFaceName,addr lfnt.lfFaceName
	invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
	mov		ecx,lfnt.lfHeight
	neg		ecx
	mul		ecx
	xor		edx,edx
	mov		ecx,72
	div		ecx
	mov		lf.lfHeight,eax
	mov		ecx,eax
	mov		eax,pY
	sub		eax,pMT
	sub		eax,pMB
	xor		edx,edx
	div		ecx
	mov		ppos.nlinespage,eax
	invoke RegSetValueEx,ha.hReg,addr szPrnPos,0,REG_BINARY,addr ppos,sizeof ppos
	mov		eax,lfnt.lfWeight
	mov		lf.lfWeight,eax
	invoke CreateFontIndirect,addr lf
	mov		hPrFont,eax
	mov		doci.cbSize,sizeof doci
	mov		doci.lpszDocName,offset szAppName
	mov		eax,pd.Flags
	and		eax,PD_PRINTTOFILE
	.if eax
		mov		eax,'ELIF'
		mov		dword ptr buffer,eax
		mov		eax,':'
		mov		dword ptr buffer+4,eax
		lea		eax,buffer
		mov		doci.lpszOutput,eax
	.else
		mov		doci.lpszOutput,NULL
	.endif
	mov		doci.lpszDatatype,NULL
	mov		doci.fwType,NULL
	invoke StartDoc,pd.hDC,addr doci
	mov		eax,pd.Flags
	and		eax,PD_SELECTION
	.if eax
		invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		nLine,eax
		mov		ecx,ppos.nlinespage
		xor		edx,edx
		div		ecx
		mov		nPageno,eax
		invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMax
		sub		eax,nLine
		inc		eax
		mov		nMLine,eax
		mov		pd.nToPage,-1
	.else
		movzx	eax,pd.nFromPage
		dec		eax
		mov		nPageno,eax
		mov		edx,ppos.nlinespage
		mul		edx
		mov		nLine,eax
		invoke SendMessage,ha.hREd,EM_GETLINECOUNT,0,0
		or		eax,eax
		je		Ed
		inc		eax
		inc		eax
		mov		nMLine,eax
	.endif
	mov		eax,pML
	mov		rect.left,eax
	mov		eax,pX
	sub		eax,pMR
	mov		rect.right,eax
	mov		eax,pMT
	mov		rect.top,eax
	mov		eax,pY
	sub		eax,pMB
	mov		rect.bottom,eax
	invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
	mov		hRgn,eax
  NxtPage:
	inc		nPageno
	mov		eax,nPageno
	.if ax>pd.nToPage
		jmp		Ed
	.endif
	invoke StartPage,pd.hDC
	mov		eax,pMT
	mov		ptY,eax
	invoke SelectObject,pd.hDC,hPrFont
	invoke SelectObject,pd.hDC,hRgn
	;Get tab width
	mov		eax,'WWWW'
	mov		dword ptr buffer,eax
	invoke GetTextExtentPoint32,pd.hDC,addr buffer,4,addr pt
	mov		eax,pt.x
	shr		eax,2
	mov		ecx,edopt.tabsize
	mul		ecx
	mov		tWt,eax
  NxtLine:
	mov		eax,ptY
	add		eax,pt.y
	add		eax,pt.y
	cmp		eax,rect.bottom
	jnb		Ep
	dec		nMLine
	je		Ep
	mov		eax,pML
	mov		ptX,eax
	mov		word ptr LineTxt,sizeof LineTxt-1
	invoke SendMessage,ha.hREd,EM_GETLINE,nLine,addr LineTxt
	mov		byte ptr LineTxt[eax],0
	inc		nLine
	or		eax,eax
	je		El
	invoke strlen,addr LineTxt
	mov		ecx,eax
	invoke TabbedTextOut,pd.hDC,ptX,ptY,addr LineTxt,ecx,1,addr tWt,ptX
  El:
	mov		eax,pt.y
	add		ptY,eax
	jmp		NxtLine
  Ep:
	invoke EndPage,pd.hDC
	.if nMLine
		jmp		NxtPage
	.endif
  Ed:
	invoke EndDoc,pd.hDC
	invoke DeleteDC,pd.hDC
	invoke DeleteObject,hPrFont
	invoke DeleteObject,hRgn
	ret

Print endp
