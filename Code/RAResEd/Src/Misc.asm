
.code

SetupCasetab proc uses ebx

	;Setup whole CaseTab
	xor		ebx,ebx
	.while ebx<256
		invoke IsCharAlpha,ebx
		.if eax
			invoke CharUpper,ebx
			.if eax==ebx
				invoke CharLower,ebx
			.endif
			mov		Casetab[ebx],al
		.else
			mov		Casetab[ebx],bl
		.endif
		inc		ebx
	.endw
	ret

SetupCasetab endp

strlen proc lpSource:DWORD

	xor		eax,eax
	dec		eax
	mov		edx,lpSource
  @@:
	inc		eax
	cmp		byte ptr [edx+eax],0
	jne		@b
	ret

strlen endp

strcpy proc uses ebx,lpdest:DWORD,lpsource:DWORD

	mov		ebx,lpsource
	mov		edx,lpdest
	xor		ecx,ecx
  @@:
	mov		al,[ebx+ecx]
	mov		[edx+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpy endp

strcpyn proc uses ebx,lpdest:DWORD,lpsource:DWORD,nmax:DWORD

	mov		ebx,lpsource
	mov		edx,lpdest
	dec		nmax
	xor		ecx,ecx
  @@:
	mov		al,[ebx+ecx]
	.if ecx==nmax
		xor		al,al
	.endif
	mov		[edx+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpyn endp

strcat proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	invoke strlen,esi
	xor		ecx,ecx
	lea		esi,[esi+eax]
  @@:
	mov		al,[edi+ecx]
	mov		[esi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

strcmp proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	xor		ecx,ecx
	dec		ecx
	mov		eax,ecx
	mov		edx,ecx
  @@:
	or		eax,edx
	je		Found
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	movzx	edx,byte ptr [edi+ecx]
	sub		eax,edx
	je		@b
  Found:
	ret

strcmp endp

strcmpi proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	xor		ecx,ecx
	dec		ecx
	mov		eax,ecx
	mov		edx,ecx
  @@:
	or		eax,edx
	je		Found
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	movzx	edx,byte ptr [edi+ecx]
	cmp		eax,edx
	je		@b
	movzx	edx,byte ptr Casetab[edx]
	cmp		eax,edx
	je		@b
	movzx	edx,byte ptr Casetab[edx]
	sub		eax,edx
  Found:
	ret

strcmpi endp

xGlobalAlloc proc fFlags:DWORD,nSize:DWORD

	invoke GlobalAlloc,fFlags,nSize
	.if !eax
		invoke MessageBox,hDEd,addr szMemFail,addr szAppName,MB_OK or MB_ICONERROR
		xor		eax,eax
	.endif
	ret

xGlobalAlloc endp

ResEdBinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
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
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

ResEdBinToDec endp

ResEdDecToBin proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpStr
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    pop     esi
    pop     ebx
    ret

ResEdDecToBin endp

HexToBin proc lpStr:DWORD

	push	esi
	xor		eax,eax
	xor		edx,edx
	mov		esi,lpStr
  @@:
	shl		eax,4
	add		eax,edx
	movzx	edx,byte ptr [esi]
	.if edx>='0' && edx<='9'
		sub		edx,'0'
		inc		esi
		jmp		@b
	.elseif  edx>='A' && edx<='F'
		sub		edx,'A'-10
		inc		esi
		jmp		@b
	.elseif  edx>='a' && edx<='f'
		sub		edx,'a'-10
		inc		esi
		jmp		@b
	.endif
	pop		esi
	ret

HexToBin endp

hexEax proc

	pushad
	mov     edi,offset strHex+7
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	popad
	ret

  hexNibble:
	push    eax
	and     eax,0fh
	cmp     eax,0ah
	jb      hexNibble1
	add     eax,07h
  hexNibble1:
	add     eax,30h
	mov     [edi],al
	dec     edi
	pop     eax
	shr     eax,4
	ret
	
hexEax endp

UnQuoteWord proc uses esi edi,lpWord:DWORD

	mov		esi,lpWord
	mov		edi,esi
	.if byte ptr [esi]=='"'
		inc		esi
	.endif
	.while byte ptr [esi]
		mov		ax,[esi]
		inc		esi
		.if ax=='""'
			mov		[edi],al
			inc		edi
			inc		esi
		.elseif ax=='"\'
			mov		[edi],ax
			inc		edi
			inc		edi
			inc		esi
		.elseif al!='"'
			mov		[edi],al
			inc		edi
		.endif
	.endw
	mov		dword ptr [edi],0
	ret

UnQuoteWord endp

GetStrItem proc	lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
	.if !edi
		mov		edi,offset namebuff
	.endif
  @@:
	mov		al,[esi]
	cmp		al,','
	jz		@f
	or		al,al
	jz		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	or		al,al
	jz		@f
	inc		esi
	mov		al,0
  @@:
	mov		[edi],al
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

GetStrItem endp

IsNameDefault proc uses ebx esi,lpName:DWORD

	mov		esi,offset szIDOK
	xor		ebx,ebx
	.while byte ptr [esi]
		inc		ebx
		invoke strcmp,esi,lpName
		.if !eax
			invoke strcmp,addr szIDC_STATIC,lpName
			.if !eax
				mov		ebx,-1
			.endif
			mov		eax,ebx
			jmp		Ex
		.endif
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	xor		eax,eax
  Ex:
	ret

IsNameDefault endp

ResEdDo_ImageList proc phInst:HINSTANCE,pidBmp:DWORD,nSize:DWORD,nImg:DWORD,fMap:DWORD,fBack:DWORD,fFore:DWORD
	LOCAL	lhIml:DWORD
	LOCAL	cm[2]:COLORMAP

	invoke ImageList_Create,nSize,nSize,ILC_COLOR8 or ILC_MASK,nImg,0
	mov		lhIml,eax
	.if	fMap
		mov		cm.From,0FFFFFFh
		mov		eax,fBack
		mov		cm.To,eax
		mov		cm[sizeof COLORMAP].From,0h
		mov		eax,fFore
		mov		cm[sizeof COLORMAP].To,eax
		invoke CreateMappedBitmap,phInst,pidBmp,NULL,addr cm,fMap
	.else
		invoke LoadBitmap,phInst,pidBmp
	.endif
	push	eax
	invoke ImageList_AddMasked,lhIml,eax,fBack
	pop		eax
	invoke DeleteObject,eax
	mov		eax,lhIml
	ret

ResEdDo_ImageList endp

NotifyParent proc uses ebx
	LOCAL	nmhdr:NMHDR

	lea		ebx,nmhdr
	mov		eax,hRes
	mov		[ebx].NMHDR.hwndFrom,eax
	invoke GetWindowLong,hRes,GWL_ID
	push	eax
	mov		[ebx].NMHDR.idFrom,eax
	mov		[ebx].NMHDR.code,0
	invoke GetParent,hRes
	pop		edx
	invoke SendMessage,eax,WM_NOTIFY,edx,ebx
	ret

NotifyParent endp

RemovePath proc uses esi edi,lpFileName:DWORD,lpPath:DWORD

	mov		edi,lpFileName
	mov		esi,lpPath
	jmp		@f
  Nxt:
	inc		esi
	inc		edi
  @@:
	mov		al,[esi]
	or		al,al
	je		@f
	mov		ah,[edi]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		Nxt
  @@:
	.if byte ptr [edi]=='\'
		inc		edi
	.else
		mov		edi,lpFileName
	.endif
	mov		eax,edi
	ret

RemovePath endp

SaveHexVal proc pVal:DWORD,fComma:DWORD

	push	esi
	push	edi
	;mov		al,'0'
	;stosb
	;mov		al,'x'
	;stosb
	mov ax, 'x0'            ; *** MOD
	stosw
	
	mov		eax,pVal
	invoke hexEax
	invoke strcpy,edi,addr strHex
	pop		edi
	pop		esi
	add		edi,10
	.if fComma
		mov		al,','
		stosb
	.endif
	ret

SaveHexVal endp

SaveVal proc pVal:DWORD,fComma:DWORD
	LOCAL	buffer[16]:BYTE

	push	esi
	push	edi
	invoke ResEdBinToDec,pVal,addr buffer
	invoke strcpy,edi,addr buffer
	invoke strlen,addr buffer
	pop		edi
	pop		esi
	add		edi,eax
	.if fComma
		mov		al,','
		stosb
	.endif
	ret

SaveVal endp

SaveStr proc uses ecx esi edi,lpDest:DWORD,lpSrc:DWORD

	mov		esi,lpSrc
	mov		edi,lpDest
	dec		esi
	dec		edi
	mov		ecx,-1
  @@:
	inc		ecx
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	jne		@b
	mov		eax,ecx
	ret

SaveStr endp

SaveText proc uses ecx esi edi,lpDest:DWORD,lpSrc:DWORD

	mov		esi,lpSrc
	mov		edi,lpDest
	dec		esi
	dec		edi
	mov		ecx,-1
  @@:
	inc		ecx
	inc		esi
	inc		edi
	mov		al,[esi]
	.if al=='"'
		mov		[edi],al
		inc		edi
		inc		ecx
	.endif
	mov		[edi],al
	or		al,al
	jne		@b
	mov		eax,ecx
	ret

SaveText endp

GetTypeMem proc uses esi,lpProMem:DWORD,nType:DWORD

	mov		esi,lpProMem
	xor		eax,eax
	mov		edx,nType
	.while [esi].PROJECT.hmem
		.if edx==[esi].PROJECT.ntype
			jmp		Ex
		.endif
		add		esi,sizeof PROJECT
	.endw
  Ex:
	mov		eax,esi
	ret

GetTypeMem endp

AddTypeMem proc uses esi,lpProMem:DWORD,nSize:DWORD,nType:DWORD
	LOCAL	hMem:DWORD

	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		add		esi,sizeof PROJECT
	.endw
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,nSize
	mov     hMem,eax
	invoke GlobalLock,hMem
	mov		eax,hMem
	mov		[esi].PROJECT.hmem,eax
	mov		eax,nType
	mov		[esi].PROJECT.ntype,eax
	mov		eax,hMem
	ret

AddTypeMem endp

FindName proc uses esi,lpProMem:DWORD,lpName:DWORD,fDeleted:DWORD

	invoke GetTypeMem,lpProMem,TPE_NAME
	mov		eax,[eax].PROJECT.hmem
	.if eax
		mov		esi,eax
		.while [esi].NAMEMEM.szname || [esi].NAMEMEM.value
			.if ![esi].NAMEMEM.delete
				invoke strcmp,addr [esi].NAMEMEM.szname,lpName
				.if !eax
					mov		eax,esi
					jmp		Ex
				.endif
			.endif
			add		esi,sizeof NAMEMEM
		.endw
		xor		eax,eax
	.endif
	.if fDeleted
		invoke GetTypeMem,lpProMem,TPE_NAME
		mov		eax,[eax].PROJECT.hmem
		.if eax
			mov		esi,eax
			.while [esi].NAMEMEM.szname || [esi].NAMEMEM.value
				invoke strcmp,addr [esi].NAMEMEM.szname,lpName
				.if !eax
					mov		eax,esi
					jmp		Ex
				.endif
				add		esi,sizeof NAMEMEM
			.endw
			xor		eax,eax
		.endif
	.endif
  Ex:
	ret

FindName endp

AddName proc uses esi,lpProMem:DWORD,lpName:DWORD,lpValue:DWORD

	invoke GetTypeMem,lpProMem,TPE_NAME
	mov		esi,[eax].PROJECT.hmem
	.while [esi].NAMEMEM.szname || [esi].NAMEMEM.value
		add		esi,sizeof NAMEMEM
	.endw
	invoke strcpyn,addr [esi].NAMEMEM.szname,lpName,MaxName
	mov		eax,lpValue
	.if eax>65535
		.if word ptr [eax]=='x0'
			invoke HexToBin,addr [eax+2]
		.else
			invoke ResEdDecToBin,eax
		.endif
	.endif
	mov		[esi].NAMEMEM.value,eax
	mov		[esi].NAMEMEM.delete,FALSE
	ret

AddName endp

ClipDataSet proc lpData:LPSTR,dwSize:dword
	LOCAL	hMem:HANDLE
	LOCAL	pMem:dword

	mov		eax,dwSize
	inc		eax
	invoke xGlobalAlloc, GHND or GMEM_DDESHARE, eax
	test	eax,eax
	je		@exit2
	mov		hMem,eax
	invoke GlobalLock,eax	;hGlob
	test	eax,eax
	je		@exit1
	mov		pMem,eax
	invoke RtlMoveMemory,eax,lpData,dwSize
	mov		eax,pMem
	add		eax,dwSize
	mov		byte ptr [eax],0
	invoke GlobalUnlock,hMem
	invoke OpenClipboard,NULL
	.if eax
		invoke EmptyClipboard
		invoke SetClipboardData,CF_TEXT,hMem
		invoke CloseClipboard
		xor		eax,eax		;0 - Ok
		jmp		@exit3
	.endif
  @exit1:
	invoke  GlobalFree, hMem
	xor     eax, eax
  @exit2:
	dec     eax          ; -1 - error
  @exit3:
	ret

ClipDataSet endp

ConvertDpiSize proc nPix:DWORD
	LOCAL	lpx:DWORD

	invoke GetDC,NULL
	push	eax
	invoke GetDeviceCaps,eax,LOGPIXELSX
	mov		lpx,eax
	pop		eax
	invoke ReleaseDC,NULL,eax
	mov		eax,nPix
	shl		eax,16
	cdq
	mov		ecx,96
	div		ecx
	mov		ecx,lpx
	mul		ecx
	shr		eax,16
	ret

ConvertDpiSize endp

StreamOutProc proc pMem:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesWritten:DWORD

	mov		eax,NumBytes
	push	eax
	inc		eax
	mov		edx,pMem
	invoke strcpyn,[edx],pBuffer,eax
	pop		eax
	mov		edx,pMem
	add		[edx],eax
	mov		edx,pBytesWritten
	mov		[edx],eax
	mov		eax,0
	ret

StreamOutProc endp

SaveToMem proc hWin:DWORD,hMem:DWORD
	LOCAL	editstream:EDITSTREAM

	;stream the text to the memory
	lea		eax,hMem
	mov		editstream.dwCookie,eax
	mov		editstream.pfnCallback,offset StreamOutProc
	invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
	ret

SaveToMem endp

CombSort proc uses ebx esi edi,Arr:DWORD,count:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	mov		eax,count
	mov		Gap,eax
	mov		ebx,Arr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	push	edx
	mov		eax,[ebx+ecx*4]
	mov		edx,[ebx+edx*4]
	mov		eax,[eax]
	sub		eax,[edx]
	pop		edx
	neg		eax
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSort endp

SortStyles proc uses ebx esi edi

	; Dialog / window styles
	mov		edi,offset srtstyledefdlg
	mov		esi,offset rsstyledefdlg
	xor		ecx,ecx
	.while byte ptr [esi+8]
		push	ecx
		mov		[edi],esi
		invoke strlen,addr [esi+8]
		lea		edi,[edi+4]
		lea		esi,[esi+eax+8+1]
		pop		ecx
		inc		ecx
	.endw
	invoke CombSort,offset srtstyledefdlg,ecx
	; Control styles
	mov		edi,offset srtstyledef
	mov		esi,offset rsstyledef
	xor		ecx,ecx
	.while byte ptr [esi+8]
		push	ecx
		mov		[edi],esi
		invoke strlen,addr [esi+8]
		lea		edi,[edi+4]
		lea		esi,[esi+eax+8+1]
		pop		ecx
		inc		ecx
	.endw
	invoke CombSort,offset srtstyledef,ecx
	; Extended styles
	mov		edi,offset srtexstyledef
	mov		esi,offset rsexstyledef
	xor		ecx,ecx
	.while byte ptr [esi+8]
		push	ecx
		mov		[edi],esi
		invoke strlen,addr [esi+8]
		lea		edi,[edi+4]
		lea		esi,[esi+eax+8+1]
		pop		ecx
		inc		ecx
	.endw
	invoke CombSort,offset srtexstyledef,ecx
	ret

SortStyles endp

CombSortStr proc uses ebx esi edi,Arr:DWORD,count:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	mov		eax,count
	mov		Gap,eax
	mov		ebx,Arr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	push	edx
	push	ecx
	mov		eax,[ebx+ecx*4]
	mov		edx,[ebx+edx*4]
	lea		eax,[eax+8]
	lea		edx,[edx+8]
	invoke strcmpi,eax,edx
	pop		ecx
	pop		edx
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSortStr endp

SortStylesStr proc uses ebx esi edi,lpSource:DWORD,lpDest:DWORD

	mov		esi,lpSource
	mov		edi,lpDest
	xor		ecx,ecx
	.while dword ptr [esi+ecx*4]
		mov		eax,[esi+ecx*4]
		mov		[edi+ecx*4],eax
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx*4],0
	invoke CombSortStr,edi,ecx
	ret

SortStylesStr endp

ConvertCaption proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		edi,lpDest
	mov		esi,lpSource
	.while byte ptr [esi]
		mov		ax,[esi]
		.if ax=='a\'
			add		esi,2
			mov		byte ptr [edi],08h
			inc		edi
		.elseif ax=='n\'
			add		esi,2
			mov		byte ptr [edi],0Ah
			inc		edi
		.elseif ax=='r\'
			add		esi,2
			mov		byte ptr [edi],VK_RETURN
			inc		edi
		.elseif ax=='t\'
			add		esi,2
			mov		byte ptr [edi],VK_TAB
			inc		edi
		.elseif ax=='x\'
			add		esi,2
			mov		byte ptr [edi],0
			inc		edi
		.else
			mov		[edi],al
			inc		esi
			inc		edi
		.endif
	.endw
	mov		byte ptr [edi],0
	ret

ConvertCaption endp

DeConvertCaption proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		edi,lpDest
	mov		esi,lpSource
	xor		ecx,ecx
	.while byte ptr [esi] && ecx<MaxCap-1
		mov		al,[esi]
		.if al==0Dh
			.break .if ecx>MaxCap-3
			mov		word ptr [edi],'r\'
			add		edi,2
			add		ecx,2
		.elseif al==0Ah
			.break .if ecx>MaxCap-3
			mov		word ptr [edi],'n\'
			add		edi,2
			add		ecx,2
		.elseif al==09h
			.break .if ecx>MaxCap-3
			mov		word ptr [edi],'t\'
			add		edi,2
			add		ecx,2
		.elseif al==08h
			.break .if ecx>MaxCap-3
			mov		word ptr [edi],'a\'
			add		edi,2
			add		ecx,2
		.else
			mov		[edi],al
			inc		edi
			inc		ecx
		.endif
		inc		esi
	.endw
	mov		byte ptr [edi],0
	ret

DeConvertCaption endp

CreateSubMenu proc uses esi ebx,lpMenu:DWORD,nInx:DWORD
	LOCAL	hMnu[8]:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[32]:BYTE

	mov		hMnu,0
	mov		esi,lpMenu
	mov		edx,nInx
  @@:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			mov		eax,(MNUITEM ptr [esi]).level
			.if !eax
				dec		edx
				.if !edx
				  Nx:
					add		esi,sizeof MNUITEM
					mov		eax,(MNUITEM ptr [esi]).level
					.if eax
						dec		eax
						lea		ebx,[hMnu+eax*4]
						mov		eax,[ebx]
						.if !eax
							invoke CreatePopupMenu
							mov		[ebx],eax
						.endif
						mov		al,(MNUITEM ptr [esi]).itemcaption
						.if al=='-'
							invoke AppendMenu,[ebx],MF_SEPARATOR,0,0
						.else
							mov		buffer1,VK_TAB
							invoke MnuSaveAccel,[esi].MNUITEM.shortcut,addr buffer1[1]
							invoke strcpy,addr buffer,addr (MNUITEM ptr [esi]).itemcaption
							invoke ConvertCaption,addr buffer,addr buffer
							.if buffer1[1]
								invoke strcat,addr buffer,addr buffer1
							.endif
							push	esi
							call	GetNextLevel
							pop		esi
							mov		edx,(MNUITEM ptr [esi]).level
							mov		ecx,(MNUITEM ptr [esi]).nstate
							or		ecx,MF_STRING
							.if eax>edx
								push	ecx
								invoke CreatePopupMenu
								mov		[ebx+4],eax
								pop		ecx
								or		ecx,MF_POPUP
								invoke AppendMenu,[ebx],ecx,[ebx+4],addr buffer
							.elseif eax==edx
								invoke AppendMenu,[ebx],ecx,(MNUITEM ptr [esi]).itemid,addr buffer
							.elseif eax
								invoke AppendMenu,[ebx],ecx,(MNUITEM ptr [esi]).itemid,addr buffer
								mov		dword ptr [ebx],0
							.else
								invoke AppendMenu,[ebx],ecx,(MNUITEM ptr [esi]).itemid,addr buffer
							.endif
						.endif
						jmp		Nx
					.endif
				.endif
			.endif
		.endif
		add		esi,sizeof MNUITEM
		jmp		@b
	.endif
	mov		eax,hMnu
	ret

GetNextLevel:
	add		esi,sizeof MNUITEM
	.if [esi].MNUITEM.itemflag==-1
		jmp		GetNextLevel
	.endif
	mov		eax,(MNUITEM ptr [esi]).level
	retn

CreateSubMenu endp

MakeMnuBar proc uses ebx esi edi,lpMnuMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	hMnu:HMENU

	invoke CreateMenu
	mov		hMnu,eax
	mov		esi,lpMnuMem
	add		esi,sizeof MNUHEAD
	mov		nInx,0
  @@:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			mov		eax,(MNUITEM ptr [esi]).level
			.if !eax
				mov		edx,(MNUITEM ptr [esi]).ntype
				and		edx,MFT_RIGHTJUSTIFY
				or		edx,MF_STRING
				invoke AppendMenu,hMnu,edx,(MNUITEM ptr [esi]).itemid,addr [esi].MNUITEM.itemcaption
				mov		eax,lpMnuMem
				add		eax,sizeof MNUHEAD
				mov		edx,nInx
				inc		edx
				invoke CreateSubMenu,eax,edx
				.if eax
					mov		mii.hSubMenu,eax
					mov		mii.cbSize,sizeof MENUITEMINFO
					mov		mii.fMask,MIIM_SUBMENU
					invoke SetMenuItemInfo,hMnu,nInx,TRUE,addr mii
				.endif
				inc		nInx
			.endif
		.endif
		add		esi,sizeof MNUITEM
		jmp		@b
	.endif
	mov		eax,hMnu
	ret

MakeMnuBar endp

IsNotStyle proc uses esi edi,lpStyle:DWORD,lpNot:DWORD
	
	mov		edi,lpStyle
	mov		esi,lpNot
	.while TRUE
		invoke strcmp,esi,edi
		.if !eax
			inc		eax
			ret
		.endif
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.break .if !byte ptr [esi]
	.endw
	xor		eax,eax
	ret

IsNotStyle endp

SaveWideChar proc lpStringA:DWORD,lpStringW:DWORD

	invoke strlen,lpStringA
	invoke MultiByteToWideChar,CP_ACP,0,lpStringA,eax,lpStringW,256
	lea		eax,[eax*2]
	mov		edx,lpStringW
	mov		word ptr [edx+eax],0
	add		eax,2
	ret

SaveWideChar endp

GetCtrlMem proc uses esi,hWin:HWND

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	mov		esi,eax
	invoke GetWindowLong,hWin,GWL_ID
	mov		edx,sizeof DIALOG
	mul		edx
	lea		eax,[esi+eax+sizeof DLGHEAD]
	ret

GetCtrlMem endp

GetCtrlID proc hMem:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	lea		edx,[eax+sizeof DLGHEAD]
	mov		eax,hMem
	sub		eax,edx
	mov		ecx,sizeof DIALOG
	xor		edx,edx
	div		ecx
	ret

GetCtrlID endp

ConvertToDux proc uses ebx,px:DWORD

	.if sdword ptr px<0
		neg		px
		call	ConvertIt
		neg		eax
	.else
		call	ConvertIt
	.endif
	ret

ConvertIt:
	invoke GetDialogBaseUnits
	movzx	ecx,ax
	mov		eax,px
	sal		eax,3
	mov		ebx,dfntwt
	imul	ebx
	cdq
	mov		ebx,ecx
	idiv	ebx
	cdq
	mov		ebx,fntwt
	idiv	ebx
	sar		eax,1
	adc		eax,0
	retn

ConvertToDux endp

ConvertToDuy proc uses ebx,py:DWORD

	.if sdword ptr py<0
		neg		py
		call	ConvertIt
		neg		eax
	.else
		call	ConvertIt
	.endif
	ret

ConvertIt:
	invoke GetDialogBaseUnits
	shr		eax,16
	mov		ecx,eax
	mov		eax,py
	sal		eax,4
	mov		ebx,dfntht
	imul	ebx
	cdq
	mov		ebx,ecx
	idiv	ebx
	cdq
	mov		ebx,fntht
	idiv	ebx
	sar		eax,1
	adc		eax,0
	retn

ConvertToDuy endp

ConvertDuxToPix proc dux:DWORD
	LOCAL	bux:DWORD

	.if sdword ptr dux<0
		neg		dux
		call	ConvertIt
		neg		eax
	.else
		call	ConvertIt
	.endif
	ret

ConvertIt:
	invoke GetDialogBaseUnits
	and		eax,0FFFFh
	mov		bux,eax
	mov		eax,dux
	sal		eax,1
	cdq
	mov		ecx,fntwt
	imul	ecx
	mov		ecx,bux
	imul	ecx
	mov		ecx,dfntwt
	idiv	ecx
	cdq
	mov		ecx,4
	idiv	ecx
	sar		eax,1
	adc		eax,0
	retn

ConvertDuxToPix endp

ConvertDuyToPix proc duy:DWORD
	LOCAL	buy:DWORD

	.if sdword ptr duy<0
		neg		duy
		call	ConvertIt
		neg		eax
	.else
		call	ConvertIt
	.endif
	ret

ConvertIt:
	invoke GetDialogBaseUnits
	shr		eax,16
	mov		buy,eax
	mov		eax,duy
	sal		eax,1
	cdq
	mov		ecx,fntht
	imul	ecx
	mov		ecx,buy
	imul	ecx
	mov		ecx,dfntht
	idiv	ecx
	cdq
	mov		ecx,8
	idiv	ecx
	sar		eax,1
	adc		eax,0
	retn

ConvertDuyToPix endp

ConvertToDlgPt proc lpPoint:ptr POINT

	invoke ClientToScreen,hInvisible,lpPoint
	invoke ScreenToClient,des.hdlg,lpPoint
	ret

ConvertToDlgPt endp

RSnapToGrid proc 

	push	eax
	push	ecx
	push	edx
	invoke	GetAsyncKeyState,VK_MENU
	cmp		eax,0
	mov		eax,0
	setne 	al
	xor		eax,fSnapToGrid
	mov		fRSnapToGrid,eax
	pop		edx
	pop		ecx
	pop		eax
	ret

RSnapToGrid endp

SizeX proc

	call RSnapToGrid
	.if fRSnapToGrid
		.if sdword ptr eax<0
			neg		eax
			call	SnapIt
			neg		eax
		.else
			call	SnapIt
		.endif
	.endif
	ret

SnapIt:
	xor		edx,edx
	sal		eax,1
	idiv	Gridcx
	sar		eax,1
	adc		eax,0
	imul	Gridcx
	retn

SizeX endp

SizeY proc

	call RSnapToGrid
	.if fRSnapToGrid
		.if sdword ptr eax<0
			neg		eax
			call	SnapIt
			neg		eax
		.else
			call	SnapIt
		.endif
	.endif
	ret

SnapIt:
	xor		edx,edx
	sal		eax,1
	idiv	Gridcy
	sar		eax,1
	adc		eax,0
	imul	Gridcy
	retn

SizeY endp

SnapPtDu proc uses ebx,lpPoint:ptr POINT

	call RSnapToGrid
	.if fRSnapToGrid
		mov		ebx,lpPoint
		invoke ConvertToDlgPt,ebx
		invoke ConvertToDux,[ebx].POINT.x
		invoke SizeX
		invoke ConvertDuxToPix,eax
		mov		[ebx].POINT.x,eax
		invoke ConvertToDuy,[ebx].POINT.y
		invoke SizeY
		invoke ConvertDuyToPix,eax
		mov		[ebx].POINT.y,eax
		invoke ClientToScreen,des.hdlg,lpPoint
		invoke MapWindowPoints,NULL,hInvisible,lpPoint,1
	.endif
	ret

SnapPtDu endp

GetTypePtr proc nType:DWORD

	push	edx
	mov		eax,sizeof TYPES
	mov		edx,nType
	mul		edx
	add		eax,offset ctltypes
	pop		edx
	ret

GetTypePtr endp

FindTab proc uses esi,nTab:DWORD,hMem:HWND
	LOCAL	hCtl:HWND

	xor		edx,edx
	mov		hCtl,edx
	mov		eax,hMem
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].tab
		jne		@b
		invoke GetCtrlID,esi
		push	eax
		invoke GetWindowLong,hDEd,DEWM_DIALOG
		pop		edx
		invoke GetDlgItem,eax,edx
		mov		hCtl,eax
		mov		edx,esi
	  @@:
	.endif
	mov		eax,hCtl
	assume esi:nothing
	ret

FindTab endp

CreateGridBrush proc hWin:HWND
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	bline:DWORD

	mov		eax,Gridc
	shr		eax,24
	mov		bline,eax
	invoke GetClientRect,hWin,addr rect
	invoke GetWindowDC,hWin
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,rect.right,rect.bottom
	invoke SelectObject,mDC,eax
	push	eax
	invoke FillRect,mDC,addr rect,COLOR_BTNFACE+1
	invoke ConvertToDux,rect.right
	mov		pt.x,eax
	invoke ConvertToDuy,rect.bottom
	mov		pt.y,eax
	.if bline
		mov		eax,Gridc
		and		eax,0FFFFFFh
		invoke CreatePen,PS_SOLID,1,eax
		invoke SelectObject,mDC,eax
		push	eax
		;Horizontal lines
		xor		edx,edx
		.while edx<=pt.y
			push	edx
			invoke ConvertDuyToPix,edx
			mov		edx,eax
			push	edx
			invoke MoveToEx,mDC,0,edx,NULL
			pop		edx
			invoke LineTo,mDC,rect.right,edx
			pop		edx
			add		edx,Gridcy
		.endw
		;Vertical lines
		xor		ecx,ecx
		.while ecx<=pt.x
			push	ecx
			invoke ConvertDuxToPix,ecx
			mov		ecx,eax
			push	ecx
			invoke MoveToEx,mDC,ecx,0,NULL
			pop		ecx
			invoke LineTo,mDC,ecx,rect.bottom
			pop		ecx
			add		ecx,Gridcx
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
	.else
		xor		edx,edx
		.while edx<=pt.y
			xor		ecx,ecx
			.while ecx<=pt.x
				push	ecx
				push	edx
				push	edx
				invoke ConvertDuxToPix,ecx
				mov		ecx,eax
				pop		edx
				push	ecx
				invoke ConvertDuyToPix,edx
				mov		edx,eax
				pop		ecx
				invoke SetPixel,mDC,ecx,edx,Gridc
				pop		edx
				pop		ecx
				add		ecx,Gridcx
			.endw
			add		edx,Gridcy
		.endw
	.endif
	pop		eax
	invoke SelectObject,mDC,eax
	push	eax
	invoke CreatePatternBrush,eax
	mov		hGridBr,eax
	pop		eax
	invoke DeleteObject,eax
	invoke DeleteDC,mDC
	invoke ReleaseDC,hWin,hDC
	ret

CreateGridBrush endp

GetLangString proc uses ebx esi edi,nLang:DWORD,nSubLang:DWORD,lpBuff:DWORD

	.if nLang
		mov		edi,lpBuff
		mov		esi,offset langdef
		.while byte ptr [esi+4]
			mov		eax,[esi]
			shr		eax,16
			.if eax==nLang
				invoke lstrcat,edi,addr szSPACE
				invoke lstrcat,edi,addr szLSQ
				invoke lstrcat,edi,addr [esi+4+5]
				invoke lstrlen,addr [esi+4]
				lea		esi,[esi+eax+5]
				.while byte ptr [esi+4] && dword ptr [esi]<10000h
					mov		eax,[esi]
					.if eax==nSubLang
						invoke lstrcat,edi,addr szLPA
						invoke lstrcat,edi,addr [esi+4+8]
						invoke lstrcat,edi,addr szRPA
						.break
					.endif
					invoke lstrlen,addr [esi+4]
					lea		esi,[esi+eax+5]
				.endw
				invoke lstrcat,edi,addr szRSQ
				.break
			.endif
			invoke lstrlen,addr [esi+4]
			lea		esi,[esi+eax+5]
		.endw
	.endif
	ret

GetLangString endp

InitGridSize proc uses ebx esi edi,nSize:DWORD,lpInit:DWORD,lpSize:DWORD

	mov		edi,lpSize
	.if !dword ptr [edi]
		xor		ebx,ebx
		mov		esi,lpInit
		.while ebx<nSize
			mov		eax,[esi+ebx*4]
			invoke ConvertDpiSize,eax 
			mov		[edi+ebx*4],eax
			inc		ebx
		.endw
	.endif
	ret

InitGridSize endp

SaveGrdSize proc uses ebx edi,hGrd:HWND,nSize:DWORD,lpSize:DWORD

	xor		ebx,ebx
	mov		edi,lpSize
	.while ebx<nSize
		invoke SendMessage,hGrd,GM_GETCOLWIDTH,ebx,0
		mov		[edi+ebx*4],eax
		inc		ebx
	.endw
	ret

SaveGrdSize endp

ConvFontToUnicode proc lpDest:DWORD,lpSource:DWORD

	invoke RtlZeroMemory,lpDest,64
	invoke strlen,lpSource
	invoke MultiByteToWideChar,CP_ACP,0,lpSource,eax,lpDest,32
	ret

ConvFontToUnicode endp

ExportName proc uses ebx esi edi,lpName:DWORD,nID:DWORD,lpExport:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	fIFNDEF:DWORD

	mov		ebx,lpExport
	mov		eax,lpName
	.if byte ptr [eax] && nID
		mov		esi,hMemExported
		.if !esi
			call	Export
		.else
			.while byte ptr [esi].NAMEMEM.szname || [esi].NAMEMEM.value
				mov		eax,nID
				.if eax==[esi].NAMEMEM.value
					invoke strcmp,lpName,addr [esi].NAMEMEM.szname
					.if !eax
						jmp		Ex
					.endif
				.endif
				add		esi,sizeof NAMEMEM
			.endw
			call	Export
			invoke strcpy,addr [esi].NAMEMEM.szname,lpName
			mov		eax,nID
			mov		[esi].NAMEMEM.value,eax
		.endif
	.endif
  Ex:
	sub		ebx,lpExport
	mov		eax,ebx
	ret

Export:
	mov		fIFNDEF,FALSE
	invoke IsNameDefault,lpName
	.if eax
		mov		fIFNDEF,TRUE
		invoke SaveStr,ebx,offset szIFNDEF
		add		ebx,eax
		mov		byte ptr [ebx],' '
		inc		ebx
		invoke SaveStr,ebx,lpName
		add		ebx,eax
		mov		byte ptr [ebx],0Dh
		inc		ebx
		mov		byte ptr [ebx],0Ah
		inc		ebx
		mov		byte ptr [ebx],' '
		inc		ebx
		mov		byte ptr [ebx],' '
		inc		ebx
	.endif
	invoke SaveStr,ebx,offset szDEFINE
	add		ebx,eax
	mov		byte ptr [ebx],' '
	inc		ebx
	invoke SaveStr,ebx,lpName
	add		ebx,eax
	mov		byte ptr [ebx],' '
	inc		ebx
	invoke ResEdBinToDec,nID,addr buffer
	invoke strcpy,ebx,addr buffer
	invoke strlen,addr buffer
	add		ebx,eax
	mov		byte ptr [ebx],0Dh
	inc		ebx
	mov		byte ptr [ebx],0Ah
	inc		ebx
	.if fIFNDEF
		invoke SaveStr,ebx,offset szENDIF
		add		ebx,eax
		mov		byte ptr [ebx],0Dh
		inc		ebx
		mov		byte ptr [ebx],0Ah
		inc		ebx
	.endif
	mov		byte ptr [ebx],0
	retn

ExportName endp

CheckName proc uses ebx esi,lpName:DWORD

	mov		esi,lpName
	.while byte ptr [esi]
		movzx	ebx,byte ptr[esi]
		invoke IsCharAlphaNumeric,ebx
		.if !eax && ebx!='_'
			inc		eax
			jmp		Ex
		.endif
		inc		esi
	.endw
	xor		eax,eax
  Ex:
	ret

CheckName endp
