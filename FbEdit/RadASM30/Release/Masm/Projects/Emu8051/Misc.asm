
.const

szACALL			db ' ACALL ',0
szLCALL			db ' LCALL ',0

.code

DecToBin proc uses ebx esi,lpStr:DWORD
	LOCAL	fNeg:DWORD

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
    ret

DecToBin endp

BinToDec proc dwVal:DWORD,lpAscii:DWORD

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

BinToDec endp

GetItemInt proc uses esi edi,lpBuff:DWORD,nDefVal:DWORD

	mov		esi,lpBuff
	.if byte ptr [esi]
		mov		edi,esi
		invoke DecToBin,edi
		.while byte ptr [esi] && byte ptr [esi]!=','
			inc		esi
		.endw
		.if byte ptr [esi]==','
			inc		esi
		.endif
		push	eax
		invoke lstrcpy,edi,esi
		pop		eax
	.else
		mov		eax,nDefVal
	.endif
	ret

GetItemInt endp

PutItemInt proc uses esi edi,lpBuff:DWORD,nVal:DWORD

	mov		esi,lpBuff
	invoke lstrlen,esi
	mov		byte ptr [esi+eax],','
	invoke BinToDec,nVal,addr [esi+eax+1]
	ret

PutItemInt endp

GetItemStr proc uses esi edi,lpBuff:DWORD,lpDefVal:DWORD,lpResult:DWORD,ccMax:DWORD

	mov		esi,lpBuff
	.if byte ptr [esi]
		mov		edi,esi
		.while byte ptr [esi] && byte ptr [esi]!=','
			inc		esi
		.endw
		lea		eax,[esi+1]
		sub		eax,edi
		.if eax>ccMax
			mov		eax,ccMax
		.endif
		invoke lstrcpyn,lpResult,edi,eax
		.if byte ptr [esi]
			inc		esi
		.endif
		invoke lstrcpy,edi,esi
	.else
		invoke lstrcpyn,lpResult,lpDefVal,ccMax
	.endif
	ret

GetItemStr endp

PutItemStr proc uses esi,lpBuff:DWORD,lpStr:DWORD

	mov		esi,lpBuff
	invoke lstrlen,esi
	mov		byte ptr [esi+eax],','
	invoke lstrcpy,addr [esi+eax+1],lpStr
	ret

PutItemStr endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesRead:DWORD

	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor		eax,1
	ret

StreamInProc endp

LoadLstFile proc uses ebx esi
    LOCAL   hFile:HANDLE
	LOCAL	editstream:EDITSTREAM

	;Open the file
	invoke CreateFile,offset szlstfilename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke SendMessage,hREd,WM_SETTEXT,0,addr szNULL
		;stream the text into the RAEdit control
		mov		eax,hFile
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hREd,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hREd,REM_SETCHANGEDSTATE,FALSE,0
		mov		eax,FALSE
	.else
		mov		eax,TRUE
	.endif
	ret

LoadLstFile endp

SetDbgLine proc nDbgLine:DWORD

	;Remove previous line
	invoke SendMessage,hREd,REM_SETHILITELINE,SingleStepLine,0
	;Set new line
	mov		eax,nDbgLine
	mov		SingleStepLine,eax
	invoke SendMessage,hREd,REM_SETHILITELINE,SingleStepLine,2
	ret

SetDbgLine endp

;If current line is ACALL, return 2
;If current line is LCALL, return 3
;Else return 0
IsLCALLACALL proc
	LOCAL	buffer[256]:BYTE

	mov		word ptr buffer,255
	invoke SendMessage,hREd,EM_GETLINE,SingleStepLine,addr buffer
	mov		buffer[eax],0
	.if eax>47+8
		invoke lstrcpyn,addr buffer,addr buffer[47],8
		invoke lstrcmpi,addr buffer,addr szACALL
		.if !eax
			mov		eax,2
			ret
		.endif
		invoke lstrcmpi,addr buffer,addr szLCALL
		.if !eax
			mov		eax,3
			ret
		.endif
	.endif
	xor		eax,eax
	ret

IsLCALLACALL endp

IsHex proc lpHex:DWORD

	mov		edx,lpHex
	xor		ecx,ecx
	.while ecx<4
		movzx	eax,byte ptr [edx+ecx]
		.if !((eax>='0' && eax<='9') || (eax>='A' && eax<='F') || (eax>='a' && eax<='f'))
			xor		eax,eax
			ret
		.endif  
		inc		ecx
	.endw
	mov		eax,TRUE
	ret

IsHex endp

HexToBin proc uses esi,lpAscii:DWORD

	mov		esi,lpAscii
	xor		edx,edx
	xor		ecx,ecx
	xor		eax,eax
	.while ecx<4
		shl		edx,4
		mov		al,[esi+ecx]
		.if al<='9'
			and		al,0Fh
		.elseif al>='A' && al<="F"
			sub		al,41h-10
		.elseif al>='a' && al<="f"
			and		al,5Fh
			sub		al,41h-10
		.else
			xor		eax,eax
		.endif
		or		edx,eax
		inc		ecx
	.endw
	mov		eax,edx
	ret

HexToBin endp

GetCaretAdress proc
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		edx,eax
	invoke SendMessage,hREd,EM_GETLINE,edx,addr buffer
	mov		buffer[eax],0
	.if eax>14
		invoke lstrcpyn,addr buffer,addr buffer[10],5
		invoke IsHex,addr buffer
		.if eax
			invoke HexToBin,addr buffer
			ret
		.endif
	.endif
	xor		eax,eax
	ret

GetCaretAdress endp

Find proc lpText:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	ft:FINDTEXTEX
	LOCAL	ft2:FINDTEXTEX

	mov		eax,20202020h
	mov		dword ptr buffer,eax
	invoke lstrcpy,addr buffer[4],lpText
	mov		word ptr buffer[8],20h
	mov		ft.chrg.cpMin,0
	mov		ft.chrg.cpMax,-1
	mov		ft2.chrg.cpMax,-1
	lea		eax,buffer
	mov		ft.lpstrText,eax
	mov		ft2.lpstrText,eax
	invoke SendMessage,hREd,EM_FINDTEXTEX,FR_DOWN,addr ft
	.if eax!=-1
		;Check for next occurance
		mov		eax,ft.chrgText.cpMax
		mov		ft2.chrg.cpMin,eax
		invoke SendMessage,hREd,EM_FINDTEXTEX,FR_DOWN,addr ft2
		.if eax!=-1
			mov		eax,ft2.chrgText.cpMin
			mov		ft.chrgText.cpMin,eax
			mov		eax,ft2.chrgText.cpMax
			mov		ft.chrgText.cpMax,eax
		.endif
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,ft.chrgText.cpMin
		push	eax
		invoke SetDbgLine,eax
		pop		eax
		invoke SendMessage,hREd,EM_LINEINDEX,eax,0
		mov		ft.chrgText.cpMin,eax
		mov		ft.chrgText.cpMax,eax
		invoke SendMessage,hREd,EM_EXSETSEL,0,addr ft.chrgText
;		invoke SendMessage,hREd,REM_VCENTER,0,0
		invoke SendMessage,hREd,EM_SCROLLCARET,0,0
		invoke SendMessage,hREd,EM_EXSETSEL,0,addr ft.chrgText
		mov		eax,TRUE
	.else
		xor		eax,eax
	.endif
	ret

Find endp

iniInStr proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
iniInStr0:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		iniInStr0
	mov		edi,lpStr
	dec		edi
iniInStr1:
	inc		edi
	push	edi
	lea		esi,buffer
iniInStr2:
	mov		ah,[esi]
	or		ah,ah
	je		iniInStr8;Found
	mov		al,[edi]
	or		al,al
	je		iniInStr9;Not found
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		iniInStr2
	pop		edi
	jmp		iniInStr1
iniInStr8:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
iniInStr9:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

iniInStr endp

FixPath proc lpStr:DWORD,lpPth:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
  FixPath1:
	invoke iniInStr,lpStr,lpSrc
	.if eax!=-1
		push	eax
		invoke lstrcpy,addr buffer,lpStr
		lea		esi,buffer
		mov		edi,lpStr
		pop		eax
		.if eax!=0
		  @@:
			movsb
			dec		eax
			jne		@b
		.endif
		invoke lstrlen,lpSrc
		add		esi,eax
		push	esi
		mov		esi,lpPth
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		dec		edi
		pop		esi
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		jmp		FixPath1
	.endif
	popad
	ret

FixPath endp

ParseCmnd proc uses esi edi,lpStr:DWORD,lpCmnd:DWORD,lpParam:DWORD

	mov		esi,lpStr
	call	SkipSpc
	mov		edi,lpCmnd
	mov		al,[esi]
	.if al=='"'
		inc		esi
		call	CopyQuoted
	.else
		call	CopyToSpace
	.endif
	call	SkipSpc
	mov		edi,lpParam
	mov		al,[esi]
	.if al=='"'
		inc		esi
		call	CopyQuoted
	.else
		call	CopyAll
	.endif
	ret

SkipSpc:
	.while byte ptr [esi]==' '
		inc		esi
	.endw
	retn

CopyQuoted:
	mov		al,[esi]
	.if al
		inc		esi
		.if al!='"'
			mov		[edi],al
			inc		edi
			jmp		CopyQuoted
		.endif
		xor		al,al
	.endif
	mov		[edi],al
	retn

CopyToSpace:
	mov		al,[esi]
	.if al
		inc		esi
		.if al!=' '
			mov		[edi],al
			inc		edi
			jmp		CopyToSpace
		.endif
		xor		al,al
	.endif
	mov		[edi],al
	retn

CopyAll:
	mov		al,[esi]
	.if al
		inc		esi
		mov		[edi],al
		inc		edi
		jmp		CopyAll
		xor		al,al
	.endif
	mov		[edi],al
	retn

ParseCmnd endp
