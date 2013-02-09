
.code

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

ConvToTwips proc lSize:DWORD

	mov		eax,lSize
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
	ret

ConvToTwips endp

Print proc uses ebx,fPrint:DWORD
	LOCAL	doci:DOCINFO
	LOCAL	pX:DWORD
	LOCAL	pY:DWORD
	LOCAL	pML:DWORD
	LOCAL	pMT:DWORD
	LOCAL	pMR:DWORD
	LOCAL	pMB:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	rect:RECT
	LOCAL	buffer[32]:BYTE
	LOCAL	lf:LOGFONT
	LOCAL	hPrFont:DWORD
	LOCAL	nLine:DWORD
	LOCAL	nPageno:DWORD
	LOCAL	nMLine:DWORD
	LOCAL	ptY:DWORD
	LOCAL	fmr:FORMATRANGE

	invoke GetPrnCaps
	invoke GetDeviceCaps,pd.hDC,LOGPIXELSX
	mov		ebx,eax
	invoke ConvToPix,ebx,psd.ptPaperSize.x
	mov		pX,eax
	mov		rcPrnPage.right,eax
	mov		rcPrn.right,eax
	invoke ConvToPix,ebx,psd.rtMargin.left
	mov		pML,eax
	mov		rcPrnPage.left,0
	mov		rcPrn.left,eax
	invoke ConvToPix,ebx,psd.rtMargin.right
	mov		pMR,eax
	sub		rcPrn.right,eax
	invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
	mov		ebx,eax
	invoke ConvToPix,ebx,psd.ptPaperSize.y
	mov		pY,eax
	mov		rcPrnPage.bottom,eax
	mov		rcPrn.bottom,eax
	invoke ConvToPix,ebx,psd.rtMargin.top
	mov		pMT,eax
	mov		rcPrnPage.top,0
	mov		rcPrn.top,eax
	invoke ConvToPix,ebx,psd.rtMargin.bottom
	mov		pMB,eax
	sub		rcPrn.bottom,eax
;	invoke RtlZeroMemory,addr lf,sizeof lf
;	invoke lstrcpy,addr lf.lfFaceName,addr lfnt.lfFaceName
;	invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
;	mov		ecx,lfnt.lfHeight
;	neg		ecx
;	mul		ecx
;	xor		edx,edx
;	mov		ecx,96
;	div		ecx
;	neg		eax
;	mov		lf.lfHeight,eax
;	neg		eax
;	mov		prnfntht,eax
;	mov		ecx,eax
;	mov		eax,pY
;	sub		eax,pMT
;	sub		eax,pMB
;	xor		edx,edx
;	div		ecx
;	mov		ppos.nlinespage,eax
;	invoke RegSetValueEx,hReg,addr szPrnPos,0,REG_BINARY,addr ppos,sizeof ppos
;	mov		eax,lfnt.lfWeight
;	mov		lf.lfWeight,eax
;	invoke CreateFontIndirect,addr lf
;	mov		hPrFont,eax
	invoke ConvToTwips,psd.ptPaperSize.x
	mov		pX,eax
	invoke ConvToTwips,psd.rtMargin.left
	mov		pML,eax
	invoke ConvToTwips,psd.rtMargin.right
	mov		pMR,eax
	invoke ConvToTwips,psd.ptPaperSize.y
	mov		pY,eax
	invoke ConvToTwips,psd.rtMargin.top
	mov		pMT,eax
	invoke ConvToTwips,psd.rtMargin.bottom
	mov		pMB,eax
	mov		fmr.rcPage.left,0
	mov		eax,pML
	mov		fmr.rc.left,eax
	mov		eax,pX
	mov		fmr.rcPage.right,eax
	sub		eax,pMR
	mov		fmr.rc.right,eax
	mov		fmr.rcPage.top,0
	mov		eax,pMT
	mov		fmr.rc.top,eax
	mov		eax,pY
	mov		fmr.rcPage.bottom,eax
	sub		eax,pMB
	mov		fmr.rc.bottom,eax
;	invoke SelectObject,pd.hDC,hPrFont
	invoke GetDC,hREd
	mov		fmr.hdc,eax
	invoke SelectObject,fmr.hdc,hFont
	push	eax
	mov		eax,pd.hDC
	mov		fmr.hdcTarget,eax

	mov		doci.cbSize,sizeof doci
	mov		doci.lpszDocName,offset szAppName
	test	pd.Flags,PD_PRINTTOFILE
	.if !ZERO?
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
	test	pd.Flags,PD_SELECTION
	.if !ZERO?
		invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		nLine,eax
		mov		ecx,ppos.nlinespage
		xor		edx,edx
		div		ecx
		mov		nPageno,eax
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMax
		mov		nMLine,eax
		mov		pd.nToPage,-1
		mov		eax,chrg.cpMin
		mov		fmr.chrg.cpMin,eax
		mov		eax,chrg.cpMax
		mov		fmr.chrg.cpMax,eax
	.else
		movzx	eax,pd.nFromPage
		dec		eax
		mov		nPageno,eax
		mov		edx,ppos.nlinespage
		mul		edx
		mov		nLine,eax
		invoke SendMessage,hREd,EM_GETLINECOUNT,0,0
		or		eax,eax
		je		Ed
		mov		nMLine,eax
		invoke SendMessage,hREd,EM_LINEINDEX,nLine,0
		mov		fmr.chrg.cpMin,eax
		mov		fmr.chrg.cpMax,-1
	.endif
  NxtPage:
	inc		nPageno
	mov		eax,nPageno
	.if ax>pd.nToPage
		jmp		Ed
	.endif
	invoke StartPage,pd.hDC
	mov		eax,pMT
	mov		ptY,eax
	invoke SendMessage,hREd,EM_FORMATRANGE,TRUE,addr fmr
	mov		fmr.chrg.cpMin,eax
	.if !fPrint
		invoke AbortDoc,pd.hDC
		invoke DeleteDC,pd.hDC
		dec		fmr.chrg.cpMin
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,fmr.chrg.cpMin
		inc		eax
		ret
	.endif
	invoke EndPage,pd.hDC
	.if sdword ptr eax>0
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,fmr.chrg.cpMin
		.if eax<nMLine
			jmp		NxtPage
		.endif
	.endif
  Ed:
	invoke EndDoc,pd.hDC
	invoke DeleteDC,pd.hDC
;	invoke DeleteObject,hPrFont
	pop		eax
	invoke SelectObject,fmr.hdc,eax
	invoke ReleaseDC,hREd,fmr.hdc
	ret

Print endp
