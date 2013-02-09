.code

strcpy proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		esi,lpSource
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpy endp

strcpyn proc uses esi edi,lpDest:DWORD,lpSource:DWORD,nLen:DWORD

	mov		esi,lpSource
	mov		edx,nLen
	dec		edx
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	.if sdword ptr ecx<edx
		mov		al,[esi+ecx]
		mov		[edi+ecx],al
		inc		ecx
		or		al,al
		jne		@b
	.else
		mov		byte ptr [edi+ecx],0
	.endif
	ret

strcpyn endp

strcat proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	xor		eax,eax
	xor		ecx,ecx
	dec		eax
	mov		edi,lpDest
  @@:
	inc		eax
	cmp		[edi+eax],cl
	jne		@b
	mov		esi,lpSource
	lea		edi,[edi+eax]
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

strlen proc uses esi,lpSource:DWORD

	xor		eax,eax
	dec		eax
	mov		esi,lpSource
  @@:
	inc		eax
	cmp		byte ptr [esi+eax],0
	jne		@b
	ret

strlen endp

strcmp proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmp endp

strcmpn proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpn endp

strcmpi proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpi endp

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

GetCharType proc nChar:DWORD
	
	mov		eax,nChar
	add		eax,da.lpCharTab
	movzx	eax,byte ptr [eax]
	ret

GetCharType endp

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
	LOCAL	buffer[8]:BYTE

	mov		dword ptr buffer,'d%'
	invoke wsprintf,lpAscii,addr buffer,dwVal
	ret

;    push    ebx
;    push    ecx
;    push    edx
;    push    esi
;    push    edi
;	mov		eax,dwVal
;	mov		edi,lpAscii
;	or		eax,eax
;	jns		pos
;	mov		byte ptr [edi],'-'
;	neg		eax
;	inc		edi
;  pos:      
;	mov		ecx,429496730
;	mov		esi,edi
;  @@:
;	mov		ebx,eax
;	mul		ecx
;	mov		eax,edx
;	lea		edx,[edx*4+edx]
;	add		edx,edx
;	sub		ebx,edx
;	add		bl,'0'
;	mov		[edi],bl
;	inc		edi
;	or		eax,eax
;	jne		@b
;	mov		byte ptr [edi],al
;	.while esi<edi
;		dec		edi
;		mov		al,[esi]
;		mov		ah,[edi]
;		mov		[edi],al
;		mov		[esi],ah
;		inc		esi
;	.endw
;    pop     edi
;    pop     esi
;    pop     edx
;    pop     ecx
;    pop     ebx
;    ret

BinToDec endp

BinToHex proc uses edi,dwVal:DWORD,lpAscii:DWORD

	mov		edi,lpAscii
	add		edi,7
	mov		eax,dwVal
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
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
	retn

BinToHex endp

HexToBin proc uses esi,lpAscii:DWORD

	mov		esi,lpAscii
	xor		edx,edx
	xor		ecx,ecx
	xor		eax,eax
	.while ecx<8
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
		invoke strcpy,edi,esi
		pop		eax
	.else
		mov		eax,nDefVal
	.endif
	ret

GetItemInt endp

PutItemInt proc uses esi edi,lpBuff:DWORD,nVal:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
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
		invoke strcpyn,lpResult,edi,eax
		.if byte ptr [esi]
			inc		esi
		.endif
		invoke strcpy,edi,esi
	.else
		invoke strcpyn,lpResult,lpDefVal,ccMax
	.endif
	ret

GetItemStr endp

PutItemStr proc uses esi,lpBuff:DWORD,lpStr:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
	mov		byte ptr [esi+eax],','
	invoke strcpy,addr [esi+eax+1],lpStr
	ret

PutItemStr endp

;'"Str,Str","Str",1,2','Str',1
GetItemQuotedStr proc uses esi edi,lpBuff:DWORD,lpDefVal:DWORD,lpResult:DWORD,ccMax:DWORD

	mov		esi,lpBuff
	.if byte ptr [esi]=="'"
		mov		edi,esi
		inc		esi
		.while byte ptr [esi] && byte ptr [esi]!="'"
			inc		esi
		.endw
		.if byte ptr [esi]=="'"
			inc		esi
		.endif
		lea		eax,[esi+1]
		sub		eax,edi
		.if eax>ccMax
			mov		eax,ccMax
			lea		eax,[eax+2]
		.endif
		invoke strcpyn,lpResult,addr [edi+1],addr [eax-2]
		.if byte ptr [esi]
			inc		esi
		.endif
		invoke strcpy,edi,esi
	.elseif byte ptr [esi]
		invoke GetItemStr,lpBuff,lpDefVal,lpResult,ccMax
	.else
		invoke strcpyn,lpResult,lpDefVal,ccMax
	.endif
	ret

GetItemQuotedStr endp

PutItemQuotedStr proc uses esi,lpBuff:DWORD,lpStr:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
	lea		esi,[esi+eax]
	mov		word ptr [esi],"',"
	invoke strcpy,addr [esi+2],lpStr
	invoke strlen,esi
	mov		word ptr [esi+eax],"'"
	ret

PutItemQuotedStr endp

MemGetPrivateProfileString proc uses ebx esi edi,lpKeyName:DWORD,lpDefault:DWORD,lpReturnedString:DWORD,nSize:DWORD,hMem:HGLOBAL

	mov		edi,lpKeyName
	mov		esi,hMem
	invoke strlen,edi
	mov		ebx,eax
	call	FindKey
	.if eax
		invoke strcpyn,lpReturnedString,esi,nSize
	.else
		.if lpDefault
			invoke strcpyn,lpReturnedString,lpDefault,nSize
		.else
			invoke strcpyn,lpReturnedString,addr szNULL,nSize
		.endif
	.endif
	invoke strlen,lpReturnedString
	ret

FindKey:
	invoke strcmpn,esi,edi,ebx
	.if eax || byte ptr [esi+ebx]!='='
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.if byte ptr [esi]
			jmp		FindKey
		.endif
		xor		eax,eax
		jmp		Ex
	.endif
	.while byte ptr [esi]!='=' && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]=='='
		inc		esi
	.endif
	mov		eax,TRUE
  Ex:
	retn

MemGetPrivateProfileString endp

RemoveFileExt proc uses esi,lpFileName:DWORD

	mov		esi,lpFileName
	invoke strlen,esi
	.while byte ptr [esi+eax]!='.' && eax
		dec		eax
	.endw
	.if byte ptr [esi+eax]=='.'
		mov		byte ptr [esi+eax],0
	.endif
	ret

RemoveFileExt endp

FixPath proc lpStr:DWORD,lpPth:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
  FixPath1:
	invoke iniInStr,lpStr,lpSrc
	.if eax!=-1
		push	eax
		invoke strcpy,addr buffer,lpStr
		lea		esi,buffer
		mov		edi,lpStr
		pop		eax
		.if eax!=0
		  @@:
			movsb
			dec		eax
			jne		@b
		.endif
		invoke strlen,lpSrc
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

RemoveFileName proc uses esi,lpFileName:DWORD

	mov		esi,lpFileName
	invoke strlen,esi
	.while byte ptr [esi+eax]!='\' && eax
		dec		eax
	.endw
	.if byte ptr [esi+eax]=='\'
		mov		byte ptr [esi+eax],0
	.endif
	ret

RemoveFileName endp

UpdateAll proc uses ebx esi edi,nFunction:DWORD,lParam:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	hexcol:HECOLOR
	LOCAL	rescol:RESCOLOR
	LOCAL	nLn:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
	mov		nInx,eax
	mov		tci.imask,TCIF_PARAM
	.while nInx
		dec		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,nFunction
			.if eax==UAM_ISOPEN
				invoke lstrcmpi,lParam,addr [ebx].TABMEM.filename
				.if !eax
					mov		eax,[ebx].TABMEM.hwnd
					jmp		Ex
				.endif
			.elseif eax==UAM_ISOPENACTIVATE
				invoke lstrcmpi,lParam,addr [ebx].TABMEM.filename
				.if !eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					mov		eax,[ebx].TABMEM.hwnd
					jmp		Ex
				.endif
			.elseif eax==UAM_ISRESOPEN
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITRES
					mov		eax,[ebx].TABMEM.hwnd
					jmp		Ex
				.endif
			.elseif eax==UAM_SAVEALL
				mov		eax,[ebx].TABMEM.hwnd
				.if eax!=lParam
					invoke GetModify,eax
					.if eax
						.if lParam
							invoke WantToSave,[ebx].TABMEM.hwnd
							.if eax
								xor		eax,eax
								jmp		Ex
							.endif
						.else
							invoke SaveTheFile,[ebx].TABMEM.hwnd
						.endif
					.endif
				.endif
			.elseif eax==UAM_CLOSEALL
				mov		eax,[ebx].TABMEM.hwnd
				.if eax!=lParam
					invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
					.if eax==ID_EDITCODE || eax==ID_EDITTEXT || eax==ID_EDITHEX
						invoke SendMessage,[ebx].TABMEM.hedt,EM_SETMODIFY,FALSE,0
					.elseif eax==ID_EDITRES
						invoke SendMessage,[ebx].TABMEM.hedt,PRO_SETMODIFY,FALSE,0
					.elseif eax==ID_EDITUSER
						xor		eax,eax
					.endif
					invoke SendMessage,[ebx].TABMEM.hwnd,WM_CLOSE,0,0
				.endif
			.elseif eax==UAM_SETCOLORS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					invoke SendMessage,[ebx].TABMEM.hedt,REM_SETCOLOR,0,addr da.radcolor.racol
				.elseif eax==ID_EDITTEXT
					invoke SendMessage,[ebx].TABMEM.hedt,REM_SETCOLOR,0,addr da.radcolor.racol
				.elseif eax==ID_EDITHEX
					mov		eax,da.radcolor.racol.bckcol
					mov		hexcol.bckcol,eax
					mov		eax,da.radcolor.racol.txtcol
					mov		hexcol.adrtxtcol,eax
					mov		hexcol.dtatxtcol,eax
					mov		hexcol.asctxtcol,eax
					mov		eax,da.radcolor.racol.selbckcol
					mov		hexcol.selbckcol,eax
					mov		hexcol.selascbckcol,eax
					mov		eax,da.radcolor.racol.seltxtcol
					mov		hexcol.seltxtcol,eax
					mov		eax,da.radcolor.racol.selbarbck
					mov		hexcol.selbarbck,eax
					mov		eax,da.radcolor.racol.selbarpen
					mov		hexcol.selbarpen,eax
					mov		eax,da.radcolor.racol.lnrcol
					mov		hexcol.lnrcol,eax
					invoke SendMessage,[ebx].TABMEM.hedt,HEM_SETCOLOR,0,addr hexcol
				.elseif eax==ID_EDITRES
					mov		eax,da.radcolor.dialogback
					mov		rescol.back,eax
					mov		eax,da.radcolor.dialogtext
					mov		rescol.text,eax
					mov		eax,da.radcolor.styles
					mov		rescol.styles,eax
					mov		eax,da.radcolor.words
					mov		rescol.words,eax
					invoke SendMessage,[ebx].TABMEM.hedt,DEM_SETCOLOR,0,addr rescol
				.elseif eax==ID_EDITUSER
				.endif
			.elseif eax==UAM_SETFONTS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					invoke SendMessage,[ebx].TABMEM.hedt,REM_SETFONT,0,addr ha.racf
					invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_STYLE
					test	da.edtopt.fopt,EDTOPT_CMNTHI
					.if !ZERO?
						or		eax,STYLE_HILITECOMMENT
					.else
						and		eax,-1 xor STYLE_HILITECOMMENT
					.endif
					invoke SetWindowLong,[ebx].TABMEM.hedt,GWL_STYLE,eax
					xor		eax,eax
					test	da.edtopt.fopt,EDTOPT_EXPTAB
					.if !ZERO?
						mov		eax,TRUE
					.endif
					invoke SendMessage,[ebx].TABMEM.hedt,REM_TABWIDTH,da.edtopt.tabsize,eax
					;Set autoindent
					xor		eax,eax
					test	da.edtopt.fopt,EDTOPT_INDENT
					.if !ZERO?
						mov		eax,TRUE
					.endif
					invoke SendMessage,[ebx].TABMEM.hedt,REM_AUTOINDENT,0,eax
					xor		eax,eax
					test	da.edtopt.fopt,EDTOPT_LINEHI
					.if !ZERO?
						mov		eax,2
					.endif
					invoke SendMessage,[ebx].TABMEM.hedt,REM_HILITEACTIVELINE,0,eax
				.elseif eax==ID_EDITTEXT
					invoke SendMessage,[ebx].TABMEM.hedt,REM_SETFONT,0,addr ha.ratf
				.elseif eax==ID_EDITHEX
					invoke SendMessage,[ebx].TABMEM.hedt,HEM_SETFONT,0,addr ha.rahf
				.elseif eax==ID_EDITRES
					invoke SendMessage,[ebx].TABMEM.hedt,WM_SETFONT,ha.hToolFont,TRUE
				.elseif eax==ID_EDITUSER
				.endif
			.elseif eax==UAM_PARSE
				.if [ebx].TABMEM.fupdate==2
					mov		[ebx].TABMEM.fupdate,0
					invoke ParseEdit,[ebx].TABMEM.hwnd,[ebx].TABMEM.pid
				.endif
			.elseif eax==UAM_ANYBOOKMARKS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE || eax==ID_EDITTEXT
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NXTBOOKMARK,eax,3
						.break .if eax==-1
						mov		eax,TRUE
						jmp		Ex
					.endw
				.endif
			.elseif eax==UAM_CLEARBOOKMARKS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE || eax==ID_EDITTEXT
					invoke SendMessage,[ebx].TABMEM.hedt,REM_CLRBOOKMARKS,0,3
				.endif
			.elseif eax==UAM_ANYBREAKPOINTS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NEXTBREAKPOINT,-1,0
						.break .if eax==-1
						mov		eax,TRUE
						jmp		Ex
					.endw
				.endif
			.elseif eax==UAM_CLEARBREAKPOINTS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					mov		edi,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NEXTBREAKPOINT,edi,0
						.break .if eax==-1
						mov		edi,eax
						invoke SendMessage,[ebx].TABMEM.hedt,REM_SETBREAKPOINT,edi,FALSE
					.endw
				.endif
			.elseif eax==UAM_CLEARERRORS
				mov		da.ErrID,0
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NEXTERROR,eax,0
						.break .if eax==-1
						push	eax
						invoke SendMessage,[ebx].TABMEM.hedt,REM_SETERROR,eax,FALSE
						pop		eax
					.endw
				.endif
			.elseif eax==UAM_FINDERROR
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					mov		nLn,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NEXTERROR,nLn,0
						.break .if eax==-1
						mov		nLn,eax
						invoke SendMessage,[ebx].TABMEM.hedt,REM_GETERROR,nLn,0
						mov		edx,lParam
						.if eax==edx
							invoke TabToolGetInx,[ebx].TABMEM.hwnd
							invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
							invoke TabToolActivate
							invoke SendMessage,[ebx].TABMEM.hedt,EM_LINEINDEX,nLn,0
							mov		chrg.cpMin,eax
							mov		chrg.cpMax,eax
							invoke SendMessage,[ebx].TABMEM.hedt,EM_EXSETSEL,0,addr chrg
							invoke SendMessage,[ebx].TABMEM.hedt,EM_SCROLLCARET,0,0
							invoke SendMessage,[ebx].TABMEM.hedt,REM_VCENTER,0,0
							invoke SetFocus,[ebx].TABMEM.hedt
							mov		eax,TRUE
							jmp		Ex
						.endif
					.endw
				.endif
			.elseif eax==UAM_UNSAVED_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					.if eax
						invoke SendMessage,[ebx].TABMEM.hedt,EM_GETMODIFY,0,0
						.if eax
							inc		nUnsaved
						.endif
					.endif
				.endif
			.elseif eax==UAM_NEWER_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					invoke CompareFileTime,addr [ebx].TABMEM.ft,addr ftexe
					.if sdword ptr eax>0
						inc		nNewer
					.endif
				.endif
			.elseif eax==UAM_SET_BREAKPOINTS
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hedt,REM_NEXTBREAKPOINT,eax,0
						.break .if eax==-1
						push	eax
						lea		edx,[eax+1]
						invoke DebugCommand,FUNC_BPADDLINE,edx,addr [ebx].TABMEM.filename
						pop		eax
					.endw
				.endif
			.elseif eax==UAM_LOCK_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					invoke SendMessage,[ebx].TABMEM.hedt,REM_READONLY,0,TRUE
				.endif
			.elseif eax==UAM_UNLOCK_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
				.if eax==ID_EDITCODE
					invoke SendMessage,[ebx].TABMEM.hedt,REM_READONLY,0,FALSE
				.endif
			.elseif eax==UAM_IS_CHANGED && !da.fNoChangeNotify
				mov		[ebx].TABMEM.fnonotify,FALSE
				.if [ebx].TABMEM.nchange
;					invoke ReleaseCapture
					mov		da.fNoChangeNotify,TRUE
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					mov		[ebx].TABMEM.nchange,0
					invoke strcpy,addr LineTxt,addr szChanged
					invoke strcat,addr LineTxt,addr [ebx].TABMEM.filename
					invoke strcat,addr LineTxt,addr szReopen
					invoke MessageBox,ha.hWnd,addr LineTxt,addr DisplayName,MB_YESNO or MB_ICONQUESTION
					.if eax==IDYES
						invoke SendMessage,ha.hWnd,WM_COMMAND,IDM_FILE_REOPEN,0
					.endif
					mov		da.fNoChangeNotify,FALSE
				.endif
			.elseif eax==UAM_CLEAR_CHANGED
				.if [ebx].TABMEM.nchange
					mov		[ebx].TABMEM.nchange,0
				.endif
			.endif
		.endif
	.endw
	mov		eax,-1
  Ex:
	ret

UpdateAll endp

IsFileType proc uses ebx esi edi,lpFileType:DWORD,lpFileTypes:DWORD

	mov		esi,lpFileTypes
	mov		edi,lpFileType
	.while TRUE
		xor		ecx,ecx
		.while byte ptr [edi+ecx]
			mov		al,[edi+ecx]
			mov		ah,[esi+ecx]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if ah>='a' && ah<='z'
				and		ah,5Fh
			.endif
			.break .if al!=ah
			inc		ecx
		.endw
		.if !byte ptr [edi+ecx]
			mov		eax,TRUE
			jmp		Ex
		.endif
		inc		esi
		.while byte ptr [esi]!='.'
			inc		esi
		.endw
		.break .if !byte ptr [esi+1]
	.endw
	xor		eax,eax
  Ex:
	ret

IsFileType endp

ParseEdit proc uses edi,hWin:HWND,pid:DWORD
	LOCAL	hEdt:HWND
	LOCAL	hMem:HGLOBAL

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke GetWindowLong,hEdt,GWL_ID
	.if eax==ID_EDITCODE
		invoke SendMessage,hEdt,REM_GETWORDGROUP,0,0
		.if !eax
			.if da.fProject
				.if !pid
					jmp		Ex
				.endif
				mov		edi,pid
			.else
				mov		edi,hWin
			.endif
			invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,edi,0
			invoke SendMessage,hEdt,WM_GETTEXTLENGTH,0,0
			inc		eax
			push	eax
			add		eax,64
			and		eax,0FFFFFFE0h
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMem,eax
			pop		eax
			invoke SendMessage,hEdt,WM_GETTEXT,eax,hMem
			invoke SendMessage,ha.hProperty,PRM_PARSEFILE,edi,hMem
			invoke PostAddinMessage,hWin,AIM_PARSEFILE,edi,hMem,0,HOOK_PARSEFILE
			invoke GlobalFree,hMem
			invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
		.endif
	.endif
  Ex:
	ret

ParseEdit endp

ParseFile proc lpFileName:DWORD,pid:DWORD
    LOCAL   hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	dwRead:DWORD

	invoke GetTheFileType,lpFileName
	.if eax==ID_EDITCODE
		;Open the file
		invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke GetFileSize,hFile,NULL
			push	eax
			inc		eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov     hMem,eax
			pop		edx
			invoke ReadFile,hFile,hMem,edx,addr dwRead,NULL
			invoke CloseHandle,hFile
			invoke SendMessage,ha.hProperty,PRM_PARSEFILE,pid,hMem
			invoke PostAddinMessage,NULL,AIM_PARSEFILE,pid,hMem,0,HOOK_PARSEFILE
			invoke GlobalFree,hMem
		.endif
	.endif
	ret

ParseFile endp

ShowPos proc nLine:DWORD,nPos:DWORD,nChars:DWORD
	LOCAL	buffer[64]:BYTE

	mov		edx,nLine
	inc		edx
	invoke BinToDec,edx,addr buffer[4]
	mov		dword ptr buffer,' :nL'
	invoke strlen,addr buffer
	mov		dword ptr buffer[eax],'soP '
	mov		dword ptr buffer[eax+4],' :'
	mov		edx,nPos
	inc		edx
	invoke BinToDec,edx,addr buffer[eax+6]
	.if nChars
		invoke strlen,addr buffer
		mov		dword ptr buffer[eax],'neL '
		mov		dword ptr buffer[eax+4],' :'
		invoke BinToDec,nChars,addr buffer[eax+6]
	.endif
	invoke SendMessage,ha.hStatus,SB_SETTEXT,0,addr buffer
	ret

ShowPos endp

ShowProc proc uses esi,nLine:DWORD
	LOCAL	isinproc:ISINPROC
	LOCAL	buffer[512]:BYTE

	mov		buffer,0
	.if ha.hEdt
		invoke GetWindowLong,ha.hEdt,GWL_ID
		.if eax==ID_EDITCODE
			mov		eax,nLine
			mov		isinproc.nLine,eax
			mov		eax,ha.hMdi
			.if da.fProject
				invoke GetWindowLong,ha.hEdt,GWL_USERDATA
				mov		eax,[eax].TABMEM.pid
			.endif
			mov		isinproc.nOwner,eax
			mov		isinproc.lpszType,offset szCCp
			invoke SendMessage,ha.hProperty,PRM_ISINPROC,0,addr isinproc
			.if eax
				mov		esi,eax
				invoke strcpy,addr buffer,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				.if byte ptr [esi]
					invoke strcat,addr buffer,addr szComma
					invoke strcat,addr buffer,esi
				.endif
			.endif
		.endif
	.endif
	invoke SendMessage,ha.hStatus,SB_SETTEXT,3,addr buffer
	ret

ShowProc endp

IndentComment proc uses esi,hWin:HWND,nChr:DWORD,fN:DWORD
	LOCAL	ochr:CHARRANGE
	LOCAL	chr:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	len:DWORD

	invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hWin,REM_LOCKUNDOID,TRUE,0
	mov		eax,nChr
	mov		dword ptr buffer[0],eax
	invoke strlen,addr buffer
	mov		len,eax
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr ochr
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chr
	invoke SendMessage,hWin,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chr.cpMin
	mov		LnSt,eax
	mov		eax,chr.cpMax
	dec		eax
	invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxt:
	mov		eax,LnSt
	.if eax<=LnEn
		invoke SendMessage,hWin,EM_LINEINDEX,LnSt,0
		mov		chr.cpMin,eax
		inc		LnSt
		.if fN
			; Indent / Comment
			mov		chr.cpMax,eax
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chr
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr buffer
			mov		eax,len
			add		ochr.cpMax,eax
			jmp		nxt
		.else
			; Outdent / Uncomment
			invoke SendMessage,hWin,EM_LINEINDEX,LnSt,0
			mov		chr.cpMax,eax
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chr
			invoke SendMessage,hWin,EM_GETSELTEXT,0,addr tmpbuff
			mov		esi,offset tmpbuff
			xor		eax,eax
			.if len==1
				mov		al,[esi]
			.elseif len==2
				mov		ax,[esi]
			.endif
			.if eax==nChr
				add		esi,len
				invoke SendMessage,hWin,EM_REPLACESEL,TRUE,esi
				mov		eax,len
				sub		ochr.cpMax,eax
			.elseif nChr==09h
				mov		ecx,da.edtopt.tabsize
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
				mov		eax,da.edtopt.tabsize
				sub		eax,ecx
				sub		ochr.cpMax,eax
				invoke SendMessage,hWin,EM_REPLACESEL,TRUE,esi
			.endif
			jmp		nxt
		.endif
	.endif
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr ochr
	invoke SendMessage,hWin,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	invoke SendMessage,hWin,REM_LOCKUNDOID,FALSE,0
	invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0
	invoke SendMessage,hWin,REM_REPAINT,0,0
	ret

IndentComment endp

UpdateSubMenu proc uses ebx esi edi,hMnu:HMENU
	LOCAL	mii:MENUITEMINFO
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT

	invoke SelectObject,ha.hDCMnu,ha.hFontMnu
	push	eax
	xor		ebx,ebx
	mov		rect.left,ebx
	mov		rect.top,ebx
	.while TRUE
		mov		mii.cbSize,sizeof MENUITEMINFO
		mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
		lea		eax,buffer
		mov		mii.dwTypeData,eax
		mov		mii.cch,sizeof buffer
		invoke GetMenuItemInfo,hMnu,ebx,TRUE,addr mii
		.break.if !eax
		test	mii.fType,MFT_OWNERDRAW
		.if ZERO?
			mov		esi,ha.hMemMnu
			mov		eax,mii.wID
			.while TRUE
				.break .if eax==[esi].RAMNUITEM.wid || ![esi].RAMNUITEM.hMnu
				lea		esi,[esi+sizeof RAMNUITEM]
			.endw
			mov		eax,hMnu
			mov		[esi].RAMNUITEM.hMnu,eax
			mov		eax,mii.wID
			mov		[esi].RAMNUITEM.wid,eax
			test	mii.fType,MFT_SEPARATOR
			.if ZERO?
				mov		[esi].RAMNUITEM.ntype,1
				lea		edx,buffer
				.while byte ptr [edx]
					.break .if byte ptr [edx]==VK_TAB
					inc		edx
				.endw
				.if byte ptr [edx]==VK_TAB
					mov		byte ptr [edx],0
					push	edx
					invoke strcpyn,addr [esi].RAMNUITEM.caption,addr buffer,sizeof RAMNUITEM.caption
					pop		edx
					invoke strcpyn,addr [esi].RAMNUITEM.accel,addr [edx+1],sizeof RAMNUITEM.accel
				.else
					invoke strcpyn,addr [esi].RAMNUITEM.caption,addr buffer,sizeof RAMNUITEM.caption
					mov		[esi].RAMNUITEM.accel,0
				.endif
				invoke strlen,addr [esi].RAMNUITEM.caption
				mov		edx,eax
				invoke DrawText,ha.hDCMnu,addr [esi].RAMNUITEM.caption,edx,addr rect,DT_CALCRECT Or DT_SINGLELINE
				mov		eax,rect.right
				add		eax,32
				mov		[esi].RAMNUITEM.wdt,eax
				.if [esi].RAMNUITEM.accel
					invoke strlen,addr [esi].RAMNUITEM.accel
					mov		edx,eax
					invoke DrawText,ha.hDCMnu,addr [esi].RAMNUITEM.accel,edx,addr rect,DT_CALCRECT Or DT_SINGLELINE
					mov		eax,rect.right
					add		eax,8
					add		[esi].RAMNUITEM.wdt,eax
				.endif
				invoke SendMessage,ha.hTbrFile,TB_COMMANDTOINDEX,mii.wID,0
				mov		edx,ha.hTbrFile
				.if sdword ptr eax<0
					invoke SendMessage,ha.hTbrEdit1,TB_COMMANDTOINDEX,mii.wID,0
					mov		edx,ha.hTbrEdit1
					.if sdword ptr eax<0
						invoke SendMessage,ha.hTbrEdit2,TB_COMMANDTOINDEX,mii.wID,0
						mov		edx,ha.hTbrEdit2
						.if sdword ptr eax<0
							invoke SendMessage,ha.hTbrView,TB_COMMANDTOINDEX,mii.wID,0
							mov		edx,ha.hTbrView
							.if sdword ptr eax<0
								invoke SendMessage,ha.hTbrMake,TB_COMMANDTOINDEX,mii.wID,0
								mov		edx,ha.hTbrMake
							.endif
						.endif
					.endif
				.endif
				.if sdword ptr eax>=0
					invoke SendMessage,edx,TB_GETBITMAP,mii.wID,0
					inc		eax
					mov		[esi].RAMNUITEM.img,eax
				.endif
				or		mii.fType,MFT_OWNERDRAW
				mov		mii.dwItemData,esi
				mov		eax,rect.bottom
				add		eax,6
				mov		[esi].RAMNUITEM.hgt,eax
				invoke SetMenuItemInfo,hMnu,ebx,TRUE,addr mii
			.else
				mov		[esi].RAMNUITEM.ntype,2
				mov		[esi].RAMNUITEM.hgt,10
				or		mii.fType,MFT_OWNERDRAW
				mov		mii.dwItemData,esi
				invoke SetMenuItemInfo,hMnu,ebx,TRUE,addr mii
			.endif
		.endif
		.if mii.hSubMenu
			invoke UpdateSubMenu,mii.hSubMenu
		.endif
		inc		ebx
	.endw
	pop		eax
	invoke SelectObject,ha.hDCMnu,eax
	ret

UpdateSubMenu endp

; Create a bitmap for the menu back brush
MakeBitMap proc uses ebx esi edi,barwidth:DWORD,barcolor:DWORD,bodycolor:DWORD
	LOCAL	hDC:HDC
	LOCAL	hBmp:HBITMAP

	invoke GetDC,NULL
	push	eax
	push	eax
	invoke CreateCompatibleDC,eax
	mov		hDC,eax
	pop		eax
	invoke CreateCompatibleBitmap,eax,1200,8
	mov		hBmp,eax
	pop		eax
	invoke ReleaseDC,NULL,eax
	invoke SelectObject,hDC,hBmp
	push	eax
	xor		edi,edi
	.while edi<8
		xor		esi,esi
		mov		ebx,barcolor
		.while esi<barwidth
			invoke SetPixel,hDC,esi,edi,ebx
			sub		ebx,040404h
			inc		esi
		.endw
		.while esi<1200
			invoke SetPixel,hDC,esi,edi,bodycolor
			inc		esi
		.endw
		inc		edi
	.endw
	pop		eax
	invoke SelectObject,hDC,eax
	invoke DeleteDC,hDC
	mov		eax,hBmp
	ret

MakeBitMap endp

CheckMenu proc uses ebx esi edi,hMnu:HMENU,nPos:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	buffer[32]:BYTE

	push	0
	push	0
	mov		eax,nPos
	.if eax==2
		;View
		push	da.fLockToolbar
		push	IDM_VIEW_LOCK
		invoke IsWindowVisible,ha.hTbrFile
		push	eax
		push	IDM_VIEW_TBFILE
		invoke IsWindowVisible,ha.hTbrEdit1
		push	eax
		push	IDM_VIEW_TBEDIT
		invoke IsWindowVisible,ha.hTbrEdit2
		push	eax
		push	IDM_VIEW_TBBOOKMARK
		invoke IsWindowVisible,ha.hTbrView
		push	eax
		push	IDM_VIEW_TBVIEW
		invoke IsWindowVisible,ha.hTbrMake
		push	eax
		push	IDM_VIEW_TBMAKE
		invoke IsWindowVisible,ha.hStcBuild
		push	eax
		push	IDM_VIEW_TBBUILD
		mov		eax,da.win.fView
		and		eax,VIEW_STATUSBAR
		push	eax
		push	IDM_VIEW_STATUSBAR
		invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolProject
		push	eax
		push	IDM_VIEW_PROJECT
		invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolProperties
		push	eax
		push	IDM_VIEW_PROPERTIES
		invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolOutput
		push	eax
		push	IDM_VIEW_OUTPUT
		invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolTab
		push	eax
		push	IDM_VIEW_TAB
		invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolDebug
		push	 eax
		push	 IDM_VIEW_DEBUG
	.elseif eax==3
		;Format
		invoke UpdateAll,UAM_ISRESOPEN,0
		.if eax==-1
			xor		eax,eax
			test	da.resopt.fopt,RESOPT_LOCK
			.if !ZERO?
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_FORMAT_LOCK
			xor		eax,eax
			test	da.resopt.fopt,RESOPT_GRID
			.if !ZERO?
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_FORMAT_SHOW
			xor		eax,eax
			test	da.resopt.fopt,RESOPT_SNAP
			.if !ZERO?
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_FORMAT_SNAP
		.else
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		ebx,eax
			invoke SendMessage,ebx,DEM_ISLOCKED,0,0
			push	eax
			push	IDM_FORMAT_LOCK
			invoke GetWindowLong,ebx,GWL_STYLE
			and		eax,DES_GRID
			push	eax
			push	IDM_FORMAT_SHOW
			invoke GetWindowLong,ebx,GWL_STYLE
			and		eax,DES_SNAPTOGRID
			push	eax
			push	IDM_FORMAT_SNAP
		.endif
	.elseif eax==4
		;Project
		mov		mii.cbSize,sizeof MENUITEMINFO
		mov		mii.fMask,MIIM_SUBMENU
		invoke GetMenuItemInfo,ha.hMenu,IDM_PROJECT_LANGUAGE,FALSE,addr mii
		mov		eax,mii.hSubMenu
		mov		hMnu,eax
		xor		edi,edi
		.while edi<20
			mov		mii.cbSize,sizeof MENUITEMINFO
			mov		mii.fMask,MIIM_ID
			invoke GetMenuItemInfo,hMnu,addr [edi+IDM_PROJECT_LANGUAGE_START],FALSE,addr mii
			.break .if !eax
			mov		esi,ha.hMemMnu
			lea		edx,[edi+IDM_PROJECT_LANGUAGE_START]
			.while [esi].RAMNUITEM.hMnu
				.if edx==[esi].RAMNUITEM.wid
					invoke strcmpi,addr [esi].RAMNUITEM.caption,addr da.szAssembler
					.break
				.endif
				lea		esi,[esi+sizeof RAMNUITEM]
			.endw
			.if !eax
				push	TRUE
			.else
				push	FALSE
			.endif
			lea		edx,[edi+IDM_PROJECT_LANGUAGE_START]
			push	edx
			inc		edi
		.endw
	.endif
	.while TRUE
		pop		edx
		pop		eax
		.break .if !edx
		.if eax
			mov		eax,MF_BYCOMMAND or MF_CHECKED
		.else
			mov		eax,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		invoke CheckMenuItem,hMnu,edx,eax
		invoke EnableMenuItem,hMnu,edx,eax
	.endw
	ret

CheckMenu endp

EnableMenu proc uses ebx esi edi,hMnu:HMENU,nPos:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	ID:DWORD
	LOCAL	fNoLink:DWORD
	LOCAL	fHasModules:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenuItemInfo,ha.hMenu,nPos,TRUE,addr mii
	mov		eax,hMnu
	.if eax==mii.hSubMenu
		invoke UpdateSubMenu,mii.hSubMenu
		mov		ebx,ha.hEdt
		xor		esi,esi
		mov		fNoLink,esi
		mov		fHasModules,esi
		.if ebx
			invoke GetWindowLong,ebx,GWL_ID
			mov		esi,eax
		.endif
		push	0
		push	0
		.if da.win.fcldmax && ha.hEdt
			dec		nPos
		.endif
		mov		eax,nPos
		.if eax==0
			;File
			mov		ID,IDM_FILE
			push	ebx
			push	IDM_FILE_REOPEN
			push	ebx
			push	IDM_FILE_CLOSE
			push	ebx
			push	IDM_FILE_SAVE
			push	ebx
			push	IDM_FILE_SAVEAS
			push	ebx
			push	IDM_FILE_SAVEALL
			.if esi==ID_EDITCODE || esi==ID_EDITTEXT
				push	TRUE
			.else
				push	FALSE
			.endif
			push	IDM_FILE_PRINT
		.elseif eax==1
			;Edit
			mov		ID,IDM_EDIT
			.if !ebx
				;No edit window open
				xor		eax,eax
				push	eax
				push	IDM_EDIT_UNDO
				push	eax
				push	IDM_EDIT_REDO
				push	eax
				push	IDM_EDIT_EMPTYUNDO
				push	eax
				push	IDM_EDIT_PASTE
				push	eax
				push	IDM_EDIT_CUT
				push	eax
				push	IDM_EDIT_COPY
				push	eax
				push	IDM_EDIT_DELETE
				push	eax
				push	IDM_EDIT_SELECTALL
				push	eax
				push	IDM_EDIT_FIND
				push	eax
				push	IDM_EDIT_FINDNEXT
				push	eax
				push	IDM_EDIT_FINDPREV
				push	eax
				push	IDM_EDIT_REPLACE
				push	eax
				push	IDM_EDIT_GOTODECLARE
				push	eax
				push	IDM_EDIT_RETURN
				push	eax
				push	IDM_EDIT_GOTOLINE
				push	eax
				push	IDM_EDIT_INDENT
				push	eax
				push	IDM_EDIT_OUTDENT
				push	eax
				push	IDM_EDIT_COMMENT
				push	eax
				push	IDM_EDIT_UNCOMMENT
				push	eax
				push	IDM_EDIT_UPPERCASE
				push	eax
				push	IDM_EDIT_LOWERCASE
				push	eax
				push	IDM_EDIT_TOSPACES
				push	eax
				push	IDM_EDIT_TOTABS
				push	eax
				push	IDM_EDIT_TRIM
				push	eax
				push	IDM_EDIT_BLOCKMODE
				push	eax
				push	IDM_EDIT_BLOCKINSERT
				push	eax
				push	IDM_EDIT_TOGGLEBM
				push	eax
				push	IDM_EDIT_NEXTBM
				push	eax
				push	IDM_EDIT_PREVBM
				push	eax
				push	IDM_EDIT_CLEARBM
				push	eax
				push	IDM_EDIT_NEXTERROR
				push	eax
				push	IDM_EDIT_CLEARERRORS
				push	eax
				push	IDM_EDIT_OPENINCLUE
			.else
				.if esi==ID_EDITCODE || esi==ID_EDITTEXT || esi==ID_EDITHEX
					invoke SendMessage,ebx,EM_CANUNDO,0,0
					mov		edi,eax
					push	eax
					push	IDM_EDIT_UNDO
					invoke SendMessage,ebx,EM_CANREDO,0,0
					or		edi,eax
					push	eax
					push	IDM_EDIT_REDO
					.if esi==ID_EDITHEX
						xor		edi,edi
					.endif
					push	edi
					push	IDM_EDIT_EMPTYUNDO
					invoke SendMessage,ebx,EM_CANPASTE,CF_TEXT,0
					push	eax
					push	IDM_EDIT_PASTE
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					mov		eax,chrg.cpMax
					sub		eax,chrg.cpMin
					push	eax
					push	IDM_EDIT_CUT
					push	eax
					push	IDM_EDIT_COPY
					push	eax
					push	IDM_EDIT_DELETE
					mov		eax,TRUE
					push	eax
					push	IDM_EDIT_SELECTALL
					push	eax
					push	IDM_EDIT_FIND
					push	eax
					push	IDM_EDIT_FINDNEXT
					push	eax
					push	IDM_EDIT_FINDPREV
					push	eax
					push	IDM_EDIT_REPLACE
					.if esi==ID_EDITHEX
						xor		eax,eax
					.endif
					push	eax
					push	IDM_EDIT_GOTODECLARE
					push	eax
					push	IDM_EDIT_RETURN
					push	eax
					push	IDM_EDIT_GOTOLINE
					push	eax
					push	IDM_EDIT_OPENINCLUE
					push	eax
					push	IDM_EDIT_BLOCKMODE
					.if eax
						invoke SendMessage,ha.hReBar,EM_EXGETSEL,0,addr chrg
						mov		eax,chrg.cpMax
						sub		eax,chrg.cpMin
					.endif
					push	eax
					push	IDM_EDIT_INDENT
					push	eax
					push	IDM_EDIT_OUTDENT
					push	eax
					push	IDM_EDIT_COMMENT
					push	eax
					push	IDM_EDIT_UNCOMMENT
					push	eax
					push	IDM_EDIT_UPPERCASE
					push	eax
					push	IDM_EDIT_LOWERCASE
					push	eax
					push	IDM_EDIT_TOSPACES
					push	eax
					push	IDM_EDIT_TOTABS
					push	eax
					push	IDM_EDIT_TRIM
					push	TRUE
					push	IDM_EDIT_TOGGLEBM
					.if esi==ID_EDITHEX
						push	FALSE
						push	IDM_EDIT_BLOCKINSERT
						invoke SendMessage,ebx,HEM_ANYBOOKMARKS,0,0
					.else
						invoke SendMessage,ebx,REM_GETMODE,0,0
						and		eax,MODE_BLOCK
						push	eax
						push	IDM_EDIT_BLOCKINSERT
						invoke UpdateAll,UAM_ANYBOOKMARKS,0
						inc		eax
					.endif
					push	eax
					push	IDM_EDIT_NEXTBM
					push	eax
					push	IDM_EDIT_PREVBM
					push	eax
					push	IDM_EDIT_CLEARBM
					mov		eax,da.ErrID
					push	eax
					push	IDM_EDIT_NEXTERROR
					push	eax
					push	IDM_EDIT_CLEARERRORS
				.elseif esi==ID_EDITRES
					invoke SendMessage,ebx,DEM_CANUNDO,0,0
					push	eax
					push	IDM_EDIT_UNDO
					invoke SendMessage,ebx,DEM_CANREDO,0,0
					push	eax
					push	IDM_EDIT_REDO
					push	FALSE
					push	IDM_EDIT_EMPTYUNDO
					invoke SendMessage,ebx,DEM_CANPASTE,CF_TEXT,0
					push	eax
					push	IDM_EDIT_PASTE
					invoke SendMessage,ebx,DEM_ISSELECTION,0,0
					push	eax
					push	IDM_EDIT_CUT
					push	eax
					push	IDM_EDIT_COPY
					push	eax
					push	IDM_EDIT_DELETE
					invoke SendMessage,ebx,PRO_GETSELECTED,0,0
					.if eax==TPE_DIALOG
						mov		eax,TRUE
						xor		eax,eax
					.else
						xor		eax,eax
					.endif
					push	eax
					push	IDM_EDIT_SELECTALL
					xor		eax,eax
					push	eax
					push	IDM_EDIT_FIND
					push	eax
					push	IDM_EDIT_FINDNEXT
					push	eax
					push	IDM_EDIT_FINDPREV
					push	eax
					push	IDM_EDIT_REPLACE
					push	eax
					push	IDM_EDIT_GOTODECLARE
					push	eax
					push	IDM_EDIT_RETURN
					push	eax
					push	IDM_EDIT_GOTOLINE
					push	eax
					push	IDM_EDIT_INDENT
					push	eax
					push	IDM_EDIT_OUTDENT
					push	eax
					push	IDM_EDIT_COMMENT
					push	eax
					push	IDM_EDIT_UNCOMMENT
					push	eax
					push	IDM_EDIT_UPPERCASE
					push	eax
					push	IDM_EDIT_LOWERCASE
					push	eax
					push	IDM_EDIT_TOSPACES
					push	eax
					push	IDM_EDIT_TOTABS
					push	eax
					push	IDM_EDIT_TRIM
					push	eax
					push	IDM_EDIT_BLOCKMODE
					push	eax
					push	IDM_EDIT_BLOCKINSERT
					push	eax
					push	IDM_EDIT_TOGGLEBM
					push	eax
					push	IDM_EDIT_NEXTBM
					push	eax
					push	IDM_EDIT_PREVBM
					push	eax
					push	IDM_EDIT_CLEARBM
					push	eax
					push	IDM_EDIT_NEXTERROR
					push	eax
					push	IDM_EDIT_CLEARERRORS
					push	eax
					push	IDM_EDIT_OPENINCLUE
				.elseif esi==ID_EDITUSER
				.endif
			.endif
		.elseif eax==2
			;View
			mov		ID,IDM_VIEW
			invoke CheckMenu,hMnu,nPos
		.elseif eax==3
			;Format
			mov		ID,IDM_FORMAT
			invoke CheckMenu,hMnu,nPos
			.if esi==ID_EDITRES
				mov		eax,TRUE
				push	eax
				push	IDM_FORMAT_LOCK
				push	eax
				push	IDM_FORMAT_SHOW
				push	eax
				push	IDM_FORMAT_SNAP
				invoke SendMessage,ebx,DEM_GETMEM,DEWM_DIALOG,0
				push	eax
				push	IDM_FORMAT_INDEX
				invoke SendMessage,ebx,DEM_ISSELECTION,0,0
				push	eax
				push	IDM_FORMAT_CENTERHORIZONTAL
				push	eax
				push	IDM_FORMAT_CENTERVERTICAL
				.if eax!=2
					xor		eax,eax
				.endif
				push	eax
				push	IDM_FORMAT_ALIGNLEFT
				push	eax
				push	IDM_FORMAT_ALIGNCENTER
				push	eax
				push	IDM_FORMAT_ALIGNRIGHT
				push	eax
				push	IDM_FORMAT_ALIGNTOP
				push	eax
				push	IDM_FORMAT_ALIGNMIDDLE
				push	eax
				push	IDM_FORMAT_ALIGNBOTTOM
				push	eax
				push	IDM_FORMAT_SIZEWIDTH
				push	eax
				push	IDM_FORMAT_SIZEHEIGHT
				push	eax
				push	IDM_FORMAT_SIZEBOTH
				invoke SendMessage,ebx,DEM_ISFRONT,0,0
				xor		eax,TRUE
				push	eax
				push	IDM_FORMAT_FRONT
				invoke SendMessage,ebx,DEM_ISBACK,0,0
				xor		eax,TRUE
				push	eax
				push	IDM_FORMAT_BACK
			.else
				xor		eax,eax
				push	eax
				push	IDM_FORMAT_LOCK
				push	eax
				push	IDM_FORMAT_FRONT
				push	eax
				push	IDM_FORMAT_BACK
				push	eax
				push	IDM_FORMAT_SHOW
				push	eax
				push	IDM_FORMAT_SNAP
				push	eax
				push	IDM_FORMAT_ALIGNLEFT
				push	eax
				push	IDM_FORMAT_ALIGNCENTER
				push	eax
				push	IDM_FORMAT_ALIGNRIGHT
				push	eax
				push	IDM_FORMAT_ALIGNTOP
				push	eax
				push	IDM_FORMAT_ALIGNMIDDLE
				push	eax
				push	IDM_FORMAT_ALIGNBOTTOM
				push	eax
				push	IDM_FORMAT_SIZEWIDTH
				push	eax
				push	IDM_FORMAT_SIZEHEIGHT
				push	eax
				push	IDM_FORMAT_SIZEBOTH
				push	eax
				push	IDM_FORMAT_CENTERHORIZONTAL
				push	eax
				push	IDM_FORMAT_CENTERVERTICAL
				push	eax
				push	IDM_FORMAT_INDEX
			.endif
		.elseif eax==4
			;Project
			mov		ID,IDM_PROJECT
			xor		edi,edi
			mov		eax,TRUE
			push	eax
			push	IDM_PROJECT_NEW
			push	eax
			push	IDM_PROJECT_OPEN
			mov		eax,da.fProject
			push	eax
			push	IDM_PROJECT_CLOSE
			push	eax
			push	IDM_PROJECT_OPTION
			.if eax
				invoke SendMessage,ha.hProjectBrowser,RPBM_GETSELECTED,0,0
				mov		edi,eax
				.if edi
					mov		edi,[edi].PBITEM.id
				.endif
			.endif
			push	eax
			push	IDM_PROJECT_ADDNEWFILE
			push	eax
			push	IDM_PROJET_ADDEXISTING
			push	eax
			push	IDM_PROJECT_ADDOPEN
			push	eax
			push	IDM_PROJECT_ADDALLOPEN
			push	eax
			push	IDM_PROJECT_ADDGROUP
			.if sdword ptr edi<0
				mov		edi,TRUE
				xor		eax,eax
			.elseif sdword ptr edi>0
				mov		eax,TRUE
				xor		edi,edi
			.else
				xor		edi,edi
				xor		eax,eax
			.endif
			push	eax
			push	IDM_PROJECT_REMOVEFILE
			push	eax
			push	IDM_PROJECT_EDITFILE
			push	eax
			push	IDM_PROJECT_OPENITEMFILE
			push	edi
			push	IDM_PROJECT_EDITGROUP
			push	edi
			push	IDM_PROJECT_OPENITEMGROUP
			.if edi==-1
				xor		edi,edi
			.endif
			push	edi
			push	IDM_PROJECT_REMOVEGROUP
			push	eax
			push	IDM_PROJECT_TEMPLATE
			mov		eax,TRUE
			.if da.fProject
				xor		eax,eax
			.endif
			xor		edi,edi
			.while edi<20
				push	eax
				lea		edx,[edi+IDM_PROJECT_LANGUAGE_START]
				push	edx
				inc		edi
			.endw
			invoke CheckMenu,hMnu,nPos
		.elseif eax==5
			;Resource
			mov		ID,IDM_RESOURCE
			xor		eax,eax
			.if esi==ID_EDITRES
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_RESOURCE_ADDDIALOG
			push	eax
			push	IDM_RESOURCE_ADDMENU
			push	eax
			push	IDM_RESOURCE_ADDACCELERATOR
			push	eax
			push	IDM_RESOURCE_ADDVERSION
			push	eax
			push	IDM_RESOURCE_ADDSTRING
			push	eax
			push	IDM_RESOURCE_ADDMANIFEST
			push	eax
			push	IDM_RESOURCE_ADDRCDATA
			push	eax
			push	IDM_RESOURCE_ADDTOLBAR
			push	eax
			push	IDM_RESOURCE_LANGUAGE
			push	eax
			push	IDM_RESOURCE_INCLUDE
			push	eax
			push	IDM_RESOURCE_RESOURCE
			push	eax
			push	IDM_RESOURCE_NAMES
			push	eax
			push	IDM_RESOURCE_EXPORT
			invoke SendMessage,ebx,PRO_GETSELECTED,0,0
			.if eax<=1
				xor		eax,eax
			.endif
			push	eax
			push	IDM_RESOURCE_REMOVE
			invoke SendMessage,ebx,PRO_CANUNDO,0,0
			push	eax
			push	IDM_RESOURCE_UNDO
		.elseif eax==6
			;Make
			mov		ID,IDM_MAKE
			;Get relative pointer to selected build command
			invoke SendMessage,ha.hCboBuild,CB_GETCURSEL,0,0
			mov		edx,sizeof MAKE
			mul		edx
			mov		edi,eax
			invoke iniInStr,addr da.make.szOutAssemble[edi],addr szDotExe
			inc		eax
			mov		fNoLink,eax
			;Any modules
			.if da.make.szAssemble[edi]
				push	ebx
				xor		ebx,ebx
				.while TRUE
					invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
					.break .if !eax
					mov		ebx,[eax].PBITEM.id
					.if [eax].PBITEM.flag==FLAG_MODULE
						mov		fHasModules,TRUE
						.break
					.endif
				.endw
				pop		ebx
			.endif
			xor		eax,eax
			.if da.szMainRC && da.make.szOutCompileRC[edi]
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_MAKE_COMPILE
			xor		eax,eax
			.if da.make.szOutAssemble[edi] && (da.szMainAsm || (esi==ID_EDITCODE && fHasModules))
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_MAKE_ASSEMBLE
			xor		eax,eax
			.if fNoLink && da.szMainAsm
				inc		eax
			.elseif da.make.szAssemble[edi] && (da.make.szLink[edi] || da.make.szLib[edi]) && (da.szMainAsm || (esi==ID_EDITCODE && fHasModules))
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_MAKE_BUILD
			xor		eax,eax
			.if fNoLink && da.szMainAsm
				inc		eax
			.elseif da.szMainAsm && da.make.szAssemble[edi] && da.make.szLink[edi]
				invoke iniInStr,addr da.make.szOutLink[edi],addr szDotExe
				inc		eax
			.endif
			push	eax
			push	IDM_MAKE_GO
			xor		eax,eax
			.if da.make.szAssemble[edi] && (da.make.szLink[edi] || da.make.szLib[edi]) && (da.szMainAsm || fHasModules)
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_MAKE_LINK
			xor		eax,eax
			.if fNoLink && da.szMainAsm
				inc		eax
			.else
				.if da.szMainAsm && da.make.szAssemble[edi] && da.make.szLink[edi]
					invoke iniInStr,addr da.make.szOutLink[edi],addr szDotExe
					inc		eax
				.endif
			.endif
			push	eax
			push	IDM_MAKE_RUN
			.if !da.szDebug
				xor		eax,eax
			.endif
			push	eax
			push	IDM_MAKE_DEBUG
			push	fHasModules
			push	IDM_MAKE_MODULES
			.if esi==ID_EDITCODE
				push	TRUE
				push	IDM_MAKE_TOGGLEMAIN
				invoke GetTheFileType,addr da.szFileName
				.if eax==ID_EDITRES
					xor		eax,eax
				.else
					mov		eax,da.fProject
				.endif
				push	eax
				push	IDM_MAKE_TOGGLEMODULE
			.elseif esi==ID_EDITRES
				push	TRUE
				push	IDM_MAKE_TOGGLEMAIN
				push	FALSE
				push	IDM_MAKE_TOGGLEMODULE
			.else
				xor		eax,eax
				push	eax
				push	IDM_MAKE_TOGGLEMAIN
				push	eax
				push	IDM_MAKE_TOGGLEMODULE
			.endif
		.elseif eax==7
			;Debug
			mov		ID,IDM_DEBUG
			xor		eax,eax
			.if da.fCanDebug
				.if esi==ID_EDITCODE
					invoke UpdateAll,UAM_ANYBREAKPOINTS,0
					inc		eax
				.endif
				push	eax
				push	IDM_DEBUG_CLEAR
				xor		eax,eax
				.if esi==ID_EDITCODE
					mov		eax,TRUE
				.endif
				push	eax
				push	IDM_DEBUG_TOGGLE
				push	TRUE
				push	IDM_DEBUG_RUN
				mov		eax,da.fDebugging
				push	eax
				push	IDM_DEBUG_BREAK
				push	eax
				push	IDM_DEBUG_STOP
				push	eax
				push	IDM_DEBUG_INTO
				push	eax
				push	IDM_DEBUG_OVER
				push	eax
				push	IDM_DEBUG_CARET
				xor		eax,TRUE
				push	eax
				push	IDM_DEBUG_NODEBUG
			.else
				push	eax
				push	IDM_DEBUG_CLEAR
				push	eax
				push	IDM_DEBUG_TOGGLE
				push	eax
				push	IDM_DEBUG_RUN
				push	eax
				push	IDM_DEBUG_BREAK
				push	eax
				push	IDM_DEBUG_STOP
				push	eax
				push	IDM_DEBUG_INTO
				push	eax
				push	IDM_DEBUG_OVER
				push	eax
				push	IDM_DEBUG_CARET
				push	eax
				push	IDM_DEBUG_NODEBUG
			.endif
		.elseif eax==8
			;Tools
			mov		ID,IDM_TOOLS
		.elseif eax==9
			;Window
			mov		ID,IDM_WINDOW
			xor		eax,eax
			.if ebx
				mov		eax,TRUE
			.endif
			push	eax
			push	IDM_WINDOW_CLOSE
			push	eax
			push	IDM_WINDOW_CLOSEALL
			push	eax
			push	IDM_WINDOW_CLOSEALLBUT
			push	eax
			push	IDM_WINDOW_HORIZONTAL
			push	eax
			push	IDM_WINDOW_VERTICAL
			push	eax
			push	IDM_WIDDOW_CASCADE
			push	eax
			push	IDM_WINDOW_ICONS
			push	eax
			push	IDM_WINDOW_MAXIMIZE
			push	eax
			push	IDM_WINDOW_RESTORE
			push	eax
			push	IDM_WINDOW_MINIMIZE
		.elseif eax==10
			;Option
			mov		ID,IDM_OPTION
		.elseif eax==11
			;Help
			mov		ID,IDM_HELP
		.endif
		.while TRUE
			pop		edx
			pop		eax
			.break .if !edx
			.if eax
				mov		eax,MF_BYCOMMAND or MF_ENABLED
			.else
				mov		eax,MF_BYCOMMAND or MF_GRAYED
			.endif
			invoke EnableMenuItem,hMnu,edx,eax
		.endw
		invoke PostAddinMessage,ha.hWnd,AIM_MENUENABLE,ID,0,0,HOOK_MENUENABLE
	.endif
	ret

EnableMenu endp

EnableContextMenu proc uses ebx esi edi,hMnu:HMENU,nPos:DWORD

	invoke UpdateSubMenu,hMnu
	push	0
	push	0
	mov		eax,nPos
	mov		ebx,ha.hEdt
	.if eax==0
		;Resource
		;Edit
		invoke SendMessage,ebx,DEM_CANUNDO,0,0
		push	eax
		push	IDM_EDIT_UNDO
		invoke SendMessage,ebx,DEM_CANREDO,0,0
		push	eax
		push	IDM_EDIT_REDO
		invoke SendMessage,ebx,DEM_CANPASTE,CF_TEXT,0
		push	eax
		push	IDM_EDIT_PASTE
		invoke SendMessage,ebx,DEM_ISSELECTION,0,0
		push	eax
		push	IDM_EDIT_CUT
		push	eax
		push	IDM_EDIT_COPY
		push	eax
		push	IDM_EDIT_DELETE
		;Format
		mov		eax,TRUE
		push	eax
		push	IDM_FORMAT_LOCK
		push	eax
		push	IDM_FORMAT_SHOW
		push	eax
		push	IDM_FORMAT_SNAP
		invoke SendMessage,ebx,DEM_GETMEM,DEWM_DIALOG,0
		push	eax
		push	IDM_FORMAT_INDEX
		invoke SendMessage,ebx,DEM_ISSELECTION,0,0
		push	eax
		push	IDM_FORMAT_CENTERHORIZONTAL
		push	eax
		push	IDM_FORMAT_CENTERVERTICAL
		.if eax!=2
			xor		eax,eax
		.endif
		push	eax
		push	IDM_FORMAT_ALIGNLEFT
		push	eax
		push	IDM_FORMAT_ALIGNCENTER
		push	eax
		push	IDM_FORMAT_ALIGNRIGHT
		push	eax
		push	IDM_FORMAT_ALIGNTOP
		push	eax
		push	IDM_FORMAT_ALIGNMIDDLE
		push	eax
		push	IDM_FORMAT_ALIGNBOTTOM
		push	eax
		push	IDM_FORMAT_SIZEWIDTH
		push	eax
		push	IDM_FORMAT_SIZEHEIGHT
		push	eax
		push	IDM_FORMAT_SIZEBOTH
		invoke SendMessage,ebx,DEM_ISFRONT,0,0
		xor		eax,TRUE
		push	eax
		push	IDM_FORMAT_FRONT
		invoke SendMessage,ebx,DEM_ISBACK,0,0
		xor		eax,TRUE
		push	eax
		push	IDM_FORMAT_BACK
	.endif
	.while TRUE
		pop		edx
		pop		eax
		.break .if !edx
		.if eax
			mov		eax,MF_BYCOMMAND or MF_ENABLED
		.else
			mov		eax,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMnu,edx,eax
	.endw
	ret

EnableContextMenu endp

EnableToolBar proc uses ebx esi edi
	LOCAL	chrg:CHARRANGE
	LOCAL	fNoLink:DWORD
	LOCAL	fHasModules:DWORD

	mov		ebx,ha.hEdt
	xor		esi,esi
	.if ebx
		invoke GetWindowLong,ebx,GWL_ID
		mov		esi,eax
	.endif
	push	0
	push	0
	push	0
	.if !ebx
		;No edit window open
		xor		eax,eax
		;File toolbar
		mov		edi,ha.hTbrFile
		push	eax
		push	IDM_FILE_SAVE
		push	edi
		push	eax
		push	IDM_FILE_SAVEALL
		push	edi
		push	eax
		push	IDM_FILE_PRINT
		push	edi
		;Edit1 toolbar
		mov		edi,ha.hTbrEdit1
		push	eax
		push	IDM_EDIT_UNDO
		push	edi
		push	eax
		push	IDM_EDIT_REDO
		push	edi
		push	eax
		push	IDM_EDIT_PASTE
		push	edi
		push	eax
		push	IDM_EDIT_CUT
		push	edi
		push	eax
		push	IDM_EDIT_COPY
		push	edi
		push	eax
		push	IDM_EDIT_DELETE
		push	edi
		push	eax
		push	IDM_EDIT_FIND
		push	edi
		push	eax
		push	IDM_EDIT_REPLACE
		push	edi
		;Edit2 toolbar
		mov		edi,ha.hTbrEdit2
		push	eax
		push	IDM_EDIT_INDENT
		push	edi
		push	eax
		push	IDM_EDIT_OUTDENT
		push	edi
		push	eax
		push	IDM_EDIT_COMMENT
		push	edi
		push	eax
		push	IDM_EDIT_UNCOMMENT
		push	edi
		push	eax
		push	IDM_EDIT_TOGGLEBM
		push	edi
		push	eax
		push	IDM_EDIT_NEXTBM
		push	edi
		push	eax
		push	IDM_EDIT_PREVBM
		push	edi
		push	eax
		push	IDM_EDIT_CLEARBM
		push	edi
	.else
		mov		eax,TRUE
		;File toolbar
		mov		edi,ha.hTbrFile
		push	eax
		push	IDM_FILE_SAVE
		push	edi
		push	eax
		push	IDM_FILE_SAVEALL
		push	edi
		.if esi==ID_EDITCODE || esi==ID_EDITTEXT || esi==ID_EDITHEX
			;File toolbar
			mov		edi,ha.hTbrFile
			mov		eax,TRUE
			.if esi==ID_EDITHEX
				xor		eax,eax
			.endif
			push	eax
			push	IDM_FILE_PRINT
			push	edi
			;Edit1 toolbar
			mov		edi,ha.hTbrEdit1
			invoke SendMessage,ebx,EM_CANUNDO,0,0
			push	eax
			push	IDM_EDIT_UNDO
			push	edi
			invoke SendMessage,ebx,EM_CANREDO,0,0
			push	eax
			push	IDM_EDIT_REDO
			push	edi
			invoke SendMessage,ebx,EM_CANPASTE,CF_TEXT,0
			push	eax
			push	IDM_EDIT_PASTE
			push	edi
			invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
			mov		eax,chrg.cpMax
			sub		eax,chrg.cpMin
			push	eax
			push	IDM_EDIT_CUT
			push	edi
			push	eax
			push	IDM_EDIT_COPY
			push	edi
			push	eax
			push	IDM_EDIT_DELETE
			push	edi
			mov		eax,TRUE
			push	eax
			push	IDM_EDIT_FIND
			push	edi
			push	eax
			push	IDM_EDIT_REPLACE
			push	edi
			;Edit2 toolbar
			mov		edi,ha.hTbrEdit2
			push	TRUE
			push	IDM_EDIT_TOGGLEBM
			push	edi
			.if esi==ID_EDITHEX
				invoke SendMessage,ebx,HEM_ANYBOOKMARKS,0,0
			.else
				invoke UpdateAll,UAM_ANYBOOKMARKS,0
				inc		eax
			.endif
			push	eax
			push	IDM_EDIT_NEXTBM
			push	edi
			push	eax
			push	IDM_EDIT_PREVBM
			push	edi
			push	eax
			push	IDM_EDIT_CLEARBM
			push	edi
			.if esi==ID_EDITHEX
				xor		eax,eax
			.else
				invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMax
				sub		eax,chrg.cpMin
			.endif
			push	eax
			push	IDM_EDIT_INDENT
			push	edi
			push	eax
			push	IDM_EDIT_OUTDENT
			push	edi
			push	eax
			push	IDM_EDIT_COMMENT
			push	edi
			push	eax
			push	IDM_EDIT_UNCOMMENT
			push	edi
		.elseif esi==ID_EDITRES
			;File toolbar
			mov		edi,ha.hTbrFile
			push	FALSE
			push	IDM_FILE_PRINT
			push	edi
			;Edit1 toolbar
			mov		edi,ha.hTbrEdit1
			invoke SendMessage,ebx,DEM_CANUNDO,0,0
			push	eax
			push	IDM_EDIT_UNDO
			push	edi
			invoke SendMessage,ebx,DEM_CANREDO,0,0
			push	eax
			push	IDM_EDIT_REDO
			push	edi
			invoke SendMessage,ebx,DEM_CANPASTE,0,0
			push	eax
			push	IDM_EDIT_PASTE
			push	edi
			invoke SendMessage,ebx,DEM_ISSELECTION,0,0
			push	eax
			push	IDM_EDIT_CUT
			push	edi
			push	eax
			push	IDM_EDIT_COPY
			push	edi
			push	eax
			push	IDM_EDIT_DELETE
			push	edi
			xor		eax,eax
			push	eax
			push	IDM_EDIT_FIND
			push	edi
			push	eax
			push	IDM_EDIT_REPLACE
			push	edi
			;Edit2 toolbar
			xor		eax,eax
			mov		edi,ha.hTbrEdit2
			push	eax
			push	IDM_EDIT_TOGGLEBM
			push	edi
			push	eax
			push	IDM_EDIT_NEXTBM
			push	edi
			push	eax
			push	IDM_EDIT_PREVBM
			push	edi
			push	eax
			push	IDM_EDIT_CLEARBM
			push	edi
			push	eax
			push	IDM_EDIT_INDENT
			push	edi
			push	eax
			push	IDM_EDIT_OUTDENT
			push	edi
			push	eax
			push	IDM_EDIT_COMMENT
			push	edi
			push	eax
			push	IDM_EDIT_UNCOMMENT
			push	edi
		.endif
	.endif
	;Make toolbar
	invoke SendMessage,ha.hCboBuild,CB_GETCURSEL,0,0
	mov		edx,sizeof MAKE
	mul		edx
	mov		edi,eax
	;Any modules
	mov		fHasModules,FALSE
	.if da.make.szAssemble[edi]
		push	ebx
		xor		ebx,ebx
		.while TRUE
			invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
			.break .if !eax
			mov		ebx,[eax].PBITEM.id
			.if [eax].PBITEM.flag==FLAG_MODULE
				mov		fHasModules,TRUE
				.break
			.endif
		.endw
		pop		ebx
	.endif
	invoke iniInStr,addr da.make.szOutAssemble[edi],addr szDotExe
	inc		eax
	mov		fNoLink,eax
	xor		eax,eax
	.if da.make.szAssemble[edi] && (da.szMainAsm || (esi==ID_EDITCODE && fHasModules))
		mov		eax,TRUE
	.endif
	push	eax
	push	IDM_MAKE_ASSEMBLE
	push	ha.hTbrMake
	xor		eax,eax
	.if fNoLink && da.szMainAsm
		inc		eax
	.elseif da.make.szAssemble[edi] && (da.make.szLink[edi] || da.make.szLib[edi]) && (da.szMainAsm || (esi==ID_EDITCODE && fHasModules))
		mov		eax,TRUE
	.endif
	push	eax
	push	IDM_MAKE_BUILD
	push	ha.hTbrMake
	xor		eax,eax
	.if fNoLink && da.szMainAsm
		inc		eax
	.elseif da.szMainAsm && da.make.szAssemble[edi] && da.make.szLink[edi]
		invoke iniInStr,addr da.make.szOutLink[edi],addr szDotExe
		inc		eax
		.if !eax
			.if da.szCommandLine
				inc eax
			.endif
		.endif
	.endif
	push	eax
	push	IDM_MAKE_RUN
	push	ha.hTbrMake
	push	eax
	push	IDM_MAKE_GO
	push	ha.hTbrMake
	.while TRUE
		pop		ecx
		pop		edx
		pop		eax
		.break .if !edx
		invoke SendMessage,ecx,TB_ENABLEBUTTON,edx,eax
	.endw
	ret

EnableToolBar endp

MemGetFileInfo proc uses edi,hMem:HGLOBAL,nInx:DWORD,lpFILEINFO:DWORD
	LOCAL	buffer[8]:BYTE

	mov		edi,lpFILEINFO
	mov		buffer,'F'
	invoke BinToDec,nInx,addr buffer[1]
	invoke MemGetPrivateProfileString,addr buffer,NULL,addr tmpbuff,sizeof tmpbuff,hMem
	.if eax
		.if da.fProject
			invoke GetItemInt,addr tmpbuff,0
			mov		[edi].FILEINFO.idparent,eax
			invoke GetItemInt,addr tmpbuff,0
			mov		[edi].FILEINFO.flag,eax
			mov		eax,nInx
			mov		[edi].FILEINFO.pid,eax
		.endif
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.ID,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.left,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.top,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.right,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.bottom,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.nline,eax
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].FILEINFO.filename,sizeof FILEINFO.filename
		.if da.fProject
			invoke strcpy,addr tmpbuff,addr da.szProjectPath
			invoke strcat,addr tmpbuff,addr szBS
			invoke strcat,addr tmpbuff,addr [edi].FILEINFO.filename
			invoke strcpy,addr [edi].FILEINFO.filename,addr tmpbuff
		.endif
		mov		eax,TRUE
	.endif
	ret

MemGetFileInfo endp

GetFileInfo proc uses edi,nInx:DWORD,lpSection:DWORD,lpFileName:DWORD,lpFILEINFO:DWORD
	LOCAL	buffer[8]:BYTE

	mov		edi,lpFILEINFO
	mov		buffer,'F'
	invoke BinToDec,nInx,addr buffer[1]
	invoke GetPrivateProfileString,lpSection,addr buffer,NULL,addr tmpbuff,sizeof tmpbuff,lpFileName
	.if eax
		.if da.fProject
			invoke GetItemInt,addr tmpbuff,0
			mov		[edi].FILEINFO.idparent,eax
			invoke GetItemInt,addr tmpbuff,0
			mov		[edi].FILEINFO.flag,eax
			mov		eax,nInx
			mov		[edi].FILEINFO.pid,eax
		.endif
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.ID,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.left,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.top,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.right,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.rect.bottom,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		[edi].FILEINFO.nline,eax
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].FILEINFO.filename,sizeof FILEINFO.filename
		.if da.fProject
			invoke strcpy,addr tmpbuff,addr da.szProjectPath
			invoke strcat,addr tmpbuff,addr szBS
			invoke strcat,addr tmpbuff,addr [edi].FILEINFO.filename
			invoke strcpy,addr [edi].FILEINFO.filename,addr tmpbuff
		.endif
		mov		eax,TRUE
	.endif
	ret

GetFileInfo endp

RemovePath proc	uses ebx esi edi,lpFileName:DWORD,lpPath:DWORD,lpOut:DWORD

	mov		esi,lpFileName
	mov		ebx,lpPath
	mov		edi,lpOut
	or		ecx,-1
	xor		edx,edx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[ebx+ecx]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	.if al=='\' && ah=='\'
		mov		edx,ecx
	.endif
	cmp		al,ah
	je		@b
	.if al=='\' && ah==0
		invoke lstrcpy,edi,addr [esi+ecx+1]
	.else
		push	edx
		.while byte ptr [ebx+edx]
			.if byte ptr [ebx+edx]=='\'
				mov		dword ptr [edi],'\..'
				lea		edi,[edi+3]
			.endif
			inc		edx
		.endw
		pop		ecx
		invoke lstrcpy,edi,addr [esi+ecx+1]
	.endif
	ret

RemovePath endp

SetFileInfo proc uses ebx esi edi,nInx:DWORD,lpFILEINFO:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	chrg:CHARRANGE

	mov		edi,lpFILEINFO
	invoke RtlZeroMemory,edi,sizeof FILEINFO
	.if da.fProject
		invoke SendMessage,ha.hProjectBrowser,RPBM_GETITEM,nInx,0
		.if eax
			mov		esi,eax
			.if sdword ptr [esi].PBITEM.id<=0
				;Item is a group
				xor		eax,eax
				jmp		Ex
			.endif
			invoke GetFileInfo,[esi].PBITEM.id,addr szIniProject,addr da.szProjectFile,lpFILEINFO
			mov		eax,[esi].PBITEM.id
			mov		[edi].FILEINFO.pid,eax
			mov		eax,[esi].PBITEM.idparent
			mov		[edi].FILEINFO.idparent,eax
			mov		eax,[esi].PBITEM.flag
			mov		[edi].FILEINFO.flag,eax
			invoke RemovePath,addr [esi].PBITEM.szitem,addr da.szProjectPath,addr [edi].FILEINFO.filename
			invoke UpdateAll,UAM_ISOPEN,addr [esi].PBITEM.szitem
			.if eax==-1
				mov		eax,TRUE
				jmp		Ex
			.endif
			invoke GetWindowLong,eax,GWL_USERDATA
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		ebx,eax
		.else
			;Item does not exist
			xor		eax,eax
			jmp		Ex
		.endif
	.else
		mov		tci.imask,TCIF_PARAM
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if !eax
			;Tab does not exist
			xor		eax,eax
			jmp		Ex
		.endif
		mov		ebx,tci.lParam
		invoke strcpy,addr [edi].FILEINFO.filename,addr [ebx].TABMEM.filename
	.endif
	invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
	mov		[edi].FILEINFO.ID,eax
	invoke GetWindowRect,[ebx].TABMEM.hwnd,addr [edi].FILEINFO.rect
	mov		eax,[edi].FILEINFO.rect.right
	sub		eax,[edi].FILEINFO.rect.left
	mov		[edi].FILEINFO.rect.right,eax
	mov		eax,[edi].FILEINFO.rect.bottom
	sub		eax,[edi].FILEINFO.rect.top
	mov		[edi].FILEINFO.rect.bottom,eax
	invoke ScreenToClient,ha.hClient,addr [edi].FILEINFO.rect
	mov		eax,[edi].FILEINFO.ID
	.if eax==ID_EDITCODE || eax==ID_EDITTEXT
		invoke SendMessage,[ebx].TABMEM.hedt,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,[ebx].TABMEM.hedt,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		[edi].FILEINFO.nline,eax
	.endif
	mov		eax,TRUE
  Ex:
	ret

SetFileInfo endp

PushGoto proc uses esi edi,hWin:HWND,cp:DWORD

	mov		ecx,31
	mov		esi,offset gotostack+30*sizeof DECLARE
	mov		edi,offset gotostack+31*sizeof DECLARE
	.repeat
		mov		eax,[esi].DECLARE.hWin
		mov		[edi].DECLARE.hWin,eax
		mov		eax,[esi].DECLARE.cp
		mov		[edi].DECLARE.cp,eax
		lea		esi,[esi-sizeof DECLARE]
		lea		edi,[edi-sizeof DECLARE]
	.untilcxz
	mov		edi,offset gotostack
	mov		eax,hWin
	mov		[edi].DECLARE.hWin,eax
	mov		eax,cp
	mov		[edi].DECLARE.cp,eax
	ret

PushGoto endp

PopGoto proc uses esi edi

	mov		ecx,31
	mov		esi,offset gotostack+sizeof DECLARE
	mov		edi,offset gotostack
	.repeat
		mov		eax,[esi].DECLARE.hWin
		mov		[edi].DECLARE.hWin,eax
		mov		eax,[esi].DECLARE.cp
		mov		[edi].DECLARE.cp,eax
		lea		esi,[esi+sizeof DECLARE]
		lea		edi,[edi+sizeof DECLARE]
	.untilcxz
	mov		edi,offset gotostack+31*sizeof DECLARE
	xor		eax,eax
	mov		[edi].DECLARE.hWin,eax
	mov		[edi].DECLARE.cp,eax
	ret

PopGoto endp

DeleteGoto proc uses esi edi,hWin:HWND

	mov		ecx,32
	mov		edi,offset gotostack
	xor		edx,edx
	mov		eax,hWin
	.repeat
		.if eax==[edi].DECLARE.hWin
			mov		[edi].DECLARE.hWin,0
			mov		[edi].DECLARE.cp,0
			inc		edx
		.endif
		lea		edi,[edi+sizeof DECLARE]
	.untilcxz
	.if edx
		mov		ecx,32
		mov		esi,offset gotostack
		mov		edi,offset gotostack
		.repeat
			.if [esi].DECLARE.hWin
				.if esi!=edi
					mov		eax,[esi].DECLARE.hWin
					mov		[edi].DECLARE.hWin,eax
					mov		eax,[esi].DECLARE.cp
					mov		[edi].DECLARE.cp,eax
					mov		[esi].DECLARE.hWin,0
					mov		[esi].DECLARE.cp,0
				.endif
				lea		edi,[edi+sizeof DECLARE]
			.endif
			lea		esi,[esi+sizeof DECLARE]
		.untilcxz
	.endif
	ret

DeleteGoto endp

UpdateGoto proc uses ebx esi edi,hWin:HWND,cp:DWORD,n:DWORD
	LOCAL	chrg:CHARRANGE

	;Delete
	mov		eax,cp
	mov		edx,n
	.if sdword ptr edx<0
		neg		edx
	.endif
	mov		chrg.cpMin,eax
	add		eax,edx
	mov		chrg.cpMax,eax
	;Delete
	mov		ecx,32
	mov		edi,offset gotostack
	mov		edx,hWin
	xor		ebx,ebx
	.repeat
		.if edx==[edi].DECLARE.hWin
			mov		eax,[edi].DECLARE.cp
			.if eax>chrg.cpMin && eax<chrg.cpMax
				mov		[edi].DECLARE.hWin,0
				mov		[edi].DECLARE.cp,0
				inc		ebx
			.endif
		.endif
		lea		edi,[edi+sizeof DECLARE]
	.untilcxz
	.if ebx
		;Compress
		mov		ecx,32
		mov		esi,offset gotostack
		mov		edi,offset gotostack
		.repeat
			.if [esi].DECLARE.hWin
				.if esi!=edi
					mov		eax,[esi].DECLARE.hWin
					mov		[edi].DECLARE.hWin,eax
					mov		eax,[esi].DECLARE.cp
					mov		[edi].DECLARE.cp,eax
					mov		[esi].DECLARE.hWin,0
					mov		[esi].DECLARE.cp,0
				.endif
				lea		edi,[edi+sizeof DECLARE]
			.endif
			lea		esi,[esi+sizeof DECLARE]
		.untilcxz
	.endif
	;Update
	mov		ecx,32
	mov		edi,offset gotostack
	mov		edx,hWin
	.repeat
		.if edx==[edi].DECLARE.hWin
			mov		eax,cp
			.if eax<[edi].DECLARE.cp
				mov		eax,n
				add		[edi].DECLARE.cp,eax
			.endif
		.endif
		lea		edi,[edi+sizeof DECLARE]
	.untilcxz
	ret

UpdateGoto endp

GotoDeclare proc uses esi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	chrg:CHARRANGE
	LOCAL	isinproc:ISINPROC
	LOCAL	nln:DWORD
	LOCAL	ftxt:FINDTEXTEX

	invoke SendMessage,ha.hEdt,REM_GETWORD,sizeof buffer,addr buffer
	.if buffer
		mov		eax,ha.hMdi
		.if da.fProject
			invoke GetWindowLong,ha.hEdt,GWL_USERDATA
			mov		eax,[eax].TABMEM.pid
		.endif
		mov		isinproc.nOwner,eax
		mov		isinproc.lpszType,offset szCCp
		invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,ha.hEdt,EM_LINEFROMCHAR,chrg.cpMin,0
		mov		isinproc.nLine,eax
		invoke SendMessage,ha.hProperty,PRM_ISINPROC,0,addr isinproc
		.if eax
			mov		esi,eax
			mov		eax,[eax-sizeof PROPERTIES].PROPERTIES.nLine
			mov		nln,eax
			;Skip proc name and point to params
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke SendMessage,ha.hProperty,PRM_ISINLIST,addr buffer,esi
			.if !eax
				;Skip params and point to locals
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke SendMessage,ha.hProperty,PRM_ISINLIST,addr buffer,esi
			.endif
			.if eax
				.if byte ptr [eax-1]!=':'
					lea		eax,buffer
					mov		ftxt.lpstrText,eax
					invoke SendMessage,ha.hEdt,EM_LINEINDEX,nln,0
					mov		ftxt.chrgText.cpMin,eax
					mov		ftxt.chrgText.cpMax,-1
					mov		ftxt.chrg.cpMin,eax
					mov		ftxt.chrg.cpMax,-1
					invoke SendMessage,ha.hEdt,EM_FINDTEXTEX,FR_WHOLEWORD or FR_MATCHCASE or FR_DOWN,addr ftxt
					.if eax!=-1
						mov		ftxt.chrg.cpMin,eax
						mov		ftxt.chrg.cpMax,eax
						invoke PushGoto,ha.hEdt,chrg.cpMin
						invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr ftxt.chrg
						invoke SendMessage,ha.hEdt,REM_VCENTER,0,0
						invoke SetFocus,ha.hEdt
						jmp		Ex
					.endif
				.endif
			.endif
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr szGotoTypes,addr buffer
		.while eax
			invoke strcpy,addr buffer1,eax
			xor		ecx,ecx
			.while buffer1[ecx]
				.if buffer1[ecx]==':' || buffer1[ecx]=='['
					mov		buffer1[ecx],0
					.break
				.endif
				inc		ecx
			.endw
			invoke strcmp,addr buffer1,addr buffer
			.if !eax
				invoke PushGoto,ha.hEdt,chrg.cpMin
				invoke SendMessage,ha.hProperty,PRM_FINDGETOWNER,0,0
				.if da.fProject
					push	eax
					invoke TabToolGetInxFromPid,eax
					pop		edx
					.if eax==-1
						;The file is not open
						invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,edx,0
						.if eax
							invoke OpenTheFile,addr [eax].PBITEM.szitem,ID_EDITCODE
						.else
							jmp		Ex
						.endif
					.else
						;The file is open
						invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
						invoke TabToolActivate
					.endif
				.else
					invoke TabToolGetInx,eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
				.endif
				invoke SendMessage,ha.hProperty,PRM_FINDGETLINE,0,0
				invoke SendMessage,ha.hEdt,EM_LINEINDEX,eax,0
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,ha.hEdt,REM_VCENTER,0,0
				invoke SetFocus,ha.hEdt
				.break
			.endif
			invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		.endw
	.endif
  Ex:
	ret

GotoDeclare endp

ReturnDeclare proc uses esi
	LOCAL	chrg:CHARRANGE

	mov		esi,offset gotostack
	.if [esi].DECLARE.hWin
		invoke GetParent,[esi].DECLARE.hWin
		invoke TabToolGetInx,eax
		.if eax!=-1
			invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
			mov		eax,[esi].DECLARE.cp
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,ha.hEdt,REM_VCENTER,0,0
			invoke SetFocus,ha.hEdt
			invoke PopGoto
		.endif
	.endif
	ret

ReturnDeclare endp

SetProjectTab proc nTab:DWORD

	.if nTab
		invoke SendMessage,ha.hTabProject,TCM_SETCURSEL,1,0
		invoke ShowWindow,ha.hProjectBrowser,SW_SHOWNA
		invoke ShowWindow,ha.hFileBrowser,SW_HIDE
	.else
		invoke SendMessage,ha.hTabProject,TCM_SETCURSEL,0,0
		invoke ShowWindow,ha.hFileBrowser,SW_SHOWNA
		invoke ShowWindow,ha.hProjectBrowser,SW_HIDE
	.endif
	ret

SetProjectTab endp

SetOutputTab proc nTab:DWORD

	.if nTab
		invoke SendMessage,ha.hTabOutput,TCM_SETCURSEL,1,0
		invoke ShowWindow,ha.hImmediate,SW_SHOWNA
		invoke ShowWindow,ha.hOutput,SW_HIDE
	.else
		invoke SendMessage,ha.hTabOutput,TCM_SETCURSEL,0,0
		invoke ShowWindow,ha.hOutput,SW_SHOWNA
		invoke ShowWindow,ha.hImmediate,SW_HIDE
	.endif
	ret

SetOutputTab endp

SetDebugTab proc nTab:DWORD

	invoke SendMessage,ha.hTabOutput,TCM_SETCURSEL,nTab,0
	.if nTab==0
		;Register
		invoke ShowWindow,ha.hREGDebug,SW_SHOWNA
		invoke ShowWindow,ha.hFPUDebug,SW_HIDE
		invoke ShowWindow,ha.hMMXDebug,SW_HIDE
		invoke ShowWindow,ha.hWATCHDebug,SW_HIDE
	.elseif nTab==1
		;FPU
		invoke ShowWindow,ha.hFPUDebug,SW_SHOWNA
		invoke ShowWindow,ha.hREGDebug,SW_HIDE
		invoke ShowWindow,ha.hMMXDebug,SW_HIDE
		invoke ShowWindow,ha.hWATCHDebug,SW_HIDE
	.elseif nTab==2
		;MMX
		invoke ShowWindow,ha.hMMXDebug,SW_SHOWNA
		invoke ShowWindow,ha.hREGDebug,SW_HIDE
		invoke ShowWindow,ha.hFPUDebug,SW_HIDE
		invoke ShowWindow,ha.hWATCHDebug,SW_HIDE
	.elseif nTab==3
		;Watch
		invoke ShowWindow,ha.hWATCHDebug,SW_SHOWNA
		invoke ShowWindow,ha.hREGDebug,SW_HIDE
		invoke ShowWindow,ha.hFPUDebug,SW_HIDE
		invoke ShowWindow,ha.hMMXDebug,SW_HIDE
	.endif
	ret

SetDebugTab endp

ShowOutput proc fShow:DWORD

	invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolOutput
	.if fShow
		mov		fShow,FALSE
		.if !eax
			invoke SendMessage,ha.hTool,TLM_HIDE,0,ha.hToolOutput
			mov		fShow,TRUE
		.endif
	.else
		.if eax
			invoke SendMessage,ha.hTool,TLM_HIDE,0,ha.hToolOutput
			mov		fShow,TRUE
		.endif
	.endif
	mov		eax,fShow
	ret

ShowOutput endp

TextOutput proc lpText:DWORD
	LOCAL	chrg:CHARRANGE

	mov		chrg.cpMin,-1
	mov		chrg.cpMax,-1
	invoke SendMessage,ha.hOutput,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,lpText
	invoke SendMessage,ha.hOutput,EM_SCROLLCARET,0,0
	ret

TextOutput endp

ShowDebug proc fShow:DWORD

	invoke SendMessage,ha.hTool,TLM_GETVISIBLE,0,ha.hToolDebug
	.if fShow
		mov		fShow,FALSE
		.if !eax
			invoke SendMessage,ha.hTool,TLM_HIDE,0,ha.hToolDebug
			mov		fShow,TRUE
		.endif
	.else
		.if eax
			invoke SendMessage,ha.hTool,TLM_HIDE,0,ha.hToolDebug
			mov		fShow,TRUE
		.endif
	.endif
	mov		eax,fShow
	ret

ShowDebug endp

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

SetWinCaption proc hWin:HWND,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetFullPathName,lpFileName,sizeof buffer,addr buffer,NULL
	invoke SetWindowText,hWin,addr buffer
	ret

SetWinCaption endp

SetMainWinCaption proc uses esi
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr buffer,addr DisplayName
	.if da.fProject
		invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,-1,0
		.if eax
			mov		esi,eax
			invoke strcat,addr buffer,addr szSpc
			invoke strcat,addr buffer,addr szMinus
			invoke strcat,addr buffer,addr szSpc
			invoke strcat,addr buffer,addr [esi].PBITEM.szitem
		.endif
	.endif
	invoke SetWindowText,ha.hWnd,addr buffer
	ret

SetMainWinCaption endp

BrowseFolder proc hWin:HWND,nID:DWORD,lpTitle:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	bri:BROWSEINFO
	LOCAL	pidl:DWORD

	invoke RtlZeroMemory,addr bri,sizeof BROWSEINFO
	mov		eax,lpTitle
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS; or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,addr bri
	.if !eax
		jmp		GetOut
	.endif      
	mov		pidl,eax
	invoke SHGetPathFromIDList,pidl,addr buffer
	; set new path back to edit
	invoke SendDlgItemMessage,hWin,nID,WM_SETTEXT,0,addr buffer
  GetOut:
	ret

BrowseFolder endp

;Set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpBCData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpBCData
;		invoke PostMessage,hwnd,BFFM_SETSTATUSTEXT,0,addr szBrowse
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

;Mru files/projects
UpdateMRUMenu proc uses ebx esi edi,lpMRU:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		esi,lpMRU
	.if esi==offset da.szMruFiles
		invoke GetMenuItemInfo,ha.hMenu,IDM_FILE_RECENTFILES,FALSE,addr mii
		mov		edi,12000
	.else
		invoke GetMenuItemInfo,ha.hMenu,IDM_FILE_RECENTPROJECTS,FALSE,addr mii
		mov		edi,12100
	.endif
	.while TRUE
		invoke DeleteMenu,mii.hSubMenu,0,MF_BYPOSITION
		.break .if !eax
	.endw
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_ID or MIIM_TYPE
	mov		mii.fType,MFT_STRING
	mov		ebx,10
	.while byte ptr [esi] && ebx
		mov		mii.wID,edi
		mov		mii.dwTypeData,esi
		invoke InsertMenuItem,mii.hSubMenu,edi,FALSE,addr mii
		lea		esi,[esi+MAX_PATH]
		inc		edi
		dec		ebx
	.endw
	ret

UpdateMRUMenu endp

DelMRU proc uses ebx esi edi,lpMRU:DWORD,lpFileName:DWORD

	mov		esi,lpMRU
	xor		ebx,ebx
	.while ebx<10
		.break .if !byte ptr [esi]
		invoke strcmpi,esi,lpFileName
		.if !eax
			call	DelIt
		.else
			lea		esi,[esi+MAX_PATH]
			inc		ebx
		.endif
	.endw
	ret

DelIt:
	push	ebx
	push	esi
	mov		ebx,lpMRU
	lea		ebx,[ebx+MAX_PATH*10]
	mov		edi,esi
	lea		esi,[esi+MAX_PATH]
	.while esi<ebx
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	xor		eax,eax
	.while edi<ebx
		mov		[edi],al
		inc		edi
	.endw
	pop		esi
	pop		ebx
	retn

DelMRU endp

AddMRU proc uses ebx esi edi,lpMRU:DWORD,lpFileName:DWORD

	invoke DelMRU,lpMRU,lpFileName
	mov		ebx,lpMRU
	lea		esi,[ebx+MAX_PATH*9-1]
	lea		edi,[ebx+MAX_PATH*10-1]
	.while esi>=ebx
		mov		al,[esi]
		mov		[edi],al
		dec		esi
		dec		edi
	.endw
	invoke strcpy,ebx,lpFileName
	ret

AddMRU endp

OpenMRU proc uses ebx esi edi,nID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		ebx,nID
	.if ebx<12100
		sub		ebx,12000
		mov		esi,offset da.szMruFiles
	.else
		sub		ebx,12100
		mov		esi,offset da.szMruProjects
	.endif
	mov		eax,MAX_PATH
	mul		ebx
	lea		esi,[esi+eax]
	invoke strcpy,addr buffer,esi
	invoke OpenTheFile,addr buffer,0
	ret

OpenMRU endp

LoadMRU proc uses ebx esi edi,lpKey:DWORD,lpMRU:DWORD

	invoke GetPrivateProfileString,addr szIniMru,lpKey,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szRadASMIni
	mov		edi,lpMRU
	mov		esi,offset tmpbuff
	.while byte ptr [esi]
		push	edi
		.while byte ptr [esi] && byte ptr [esi]!=','
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		.if byte ptr [esi]==','
			inc		esi
		.endif
		pop		edi
		invoke GetFileAttributes,edi
		.if eax==INVALID_HANDLE_VALUE
			mov byte ptr [edi],0
		.else
			lea		edi,[edi+MAX_PATH]
		.endif
	.endw
	ret

LoadMRU endp

SaveMRU proc uses ebx esi edi,lpKey:DWORD,lpMRU:DWORD

	invoke RtlZeroMemory,offset tmpbuff,sizeof tmpbuff
	mov		edi,offset tmpbuff
	mov		esi,lpMRU
	xor		ebx,ebx
	.while ebx<10
		.break .if !byte ptr [esi]
		mov		byte ptr [edi],','
		inc		edi
		push	esi
		.while byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		pop		esi
		lea		esi,[esi+MAX_PATH]
		inc		ebx
	.endw
	invoke WritePrivateProfileString,addr szIniMru,lpKey,addr tmpbuff[1],addr da.szRadASMIni
	ret

SaveMRU endp

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
			.if al=='$'
				call	CopyPro
			.else
				mov		[edi],al
				inc		edi
				jmp		CopyQuoted
			.endif
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
			.if al=='$'
				call	CopyPro
			.else
				mov		[edi],al
				inc		edi
				jmp		CopyToSpace
			.endif
		.endif
		xor		al,al
	.endif
	mov		[edi],al
	retn

CopyAll:
	mov		al,[esi]
	.if al
		inc		esi
		.if al=='$'
			call	CopyPro
		.else
			mov		[edi],al
			inc		edi
			jmp		CopyAll
		.endif
		xor		al,al
	.endif
	mov		[edi],al
	retn

CopyPro:
	push	esi
	mov		esi,offset da.szFileName
	.while al!='.' && al
		mov		al,[esi]
		.if al!='.' && al
			mov		[edi],al
			inc		esi
			inc		edi
		.endif
	.endw
	pop		esi
	.while byte ptr [esi]
		mov		al,[esi]
		.if al!='"'
			mov		[edi],al
		.endif
		inc		esi
		inc		edi
	.endw
	xor		al,al
	mov		[edi],al
	retn

ParseCmnd endp

DoHelp proc lpszHelpFile:DWORD,lpszWord:DWORD
	LOCAL	hhaklink:HH_AKLINK
	LOCAL	hHHwin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,lpszHelpFile
	.if byte ptr [eax]
		.if dword ptr [eax]=='ptth'
			;URL
			invoke ShellExecute,ha.hWnd,addr szIniOpen,lpszHelpFile,NULL,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
		.else
			invoke strcpy,addr buffer,lpszHelpFile
			invoke FixPath,addr buffer,addr da.szAppPath,addr szDollarA
			invoke strlen,addr buffer
			lea		edx,buffer
			mov		edx,[edx+eax-4]
			and		edx,5F5F5FFFh
			.if edx=='MHC.'
				;Chm file
				invoke RtlZeroMemory,addr hhaklink,sizeof HH_AKLINK
				.if !ha.hHtmlOcx
					invoke LoadLibrary,offset szhhctrl
					mov		ha.hHtmlOcx,eax
					invoke GetProcAddress,ha.hHtmlOcx,offset szHtmlHelpA
					mov		da.pHtmlHelpProc,eax
				.endif
				.if ha.hHtmlOcx
					mov		hhaklink.cbStruct,SizeOf HH_AKLINK
					mov		hhaklink.fReserved,FALSE
					mov		eax,lpszWord
					mov		hhaklink.pszKeywords,eax
					mov		hhaklink.pszUrl,NULL
					mov		hhaklink.pszMsgText,NULL
					mov		hhaklink.pszMsgTitle,NULL
					mov		hhaklink.pszWindow,NULL
					mov		hhaklink.fIndexOnFail,TRUE
					push	0
					push	HH_DISPLAY_TOPIC
					lea		eax,buffer
					push	eax
					push	0
					Call	[da.pHtmlHelpProc]
					mov		hHHwin,eax
					lea		eax,hhaklink
					push	eax
					push	HH_KEYWORD_LOOKUP
					lea		eax,buffer
					push	eax
					push	0
					Call	[da.pHtmlHelpProc]
				.endif
			.elseif edx=='PLH.'
				;Hlp file
				invoke WinHelp,ha.hWnd,addr buffer,HELP_KEY,lpszWord
			.else
				;Other
				invoke ShellExecute,ha.hWnd,addr szIniOpen,addr buffer,NULL,NULL,SW_SHOWNORMAL
			.endif
		.endif
	.endif
	ret

DoHelp endp

IsWordKeyWord proc uses ebx,lpWord:DWORD,fDot:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	buffword[MAX_PATH]:BYTE
	LOCAL	ms:MEMSEARCH

	.if fDot
		mov		buffword,'.'
		invoke strcpyn,addr buffword[1],lpWord,sizeof buffword-1
		call	TestWord
		.if !eax
			invoke strcpyn,addr buffword,lpWord,sizeof buffword
			call	TestWord
		.endif
	.else
		invoke strcpyn,addr buffword,lpWord,sizeof buffword
		call	TestWord
	.endif
	.if eax
		push	eax
		invoke strcpy,lpWord,addr buffword
		pop		eax
	.endif
	ret

TestWord:
	xor		ebx,ebx
	mov		buffer,'C'
	mov		tmpbuff,VK_SPACE
	.while ebx<16
		invoke BinToDec,ebx,addr buffer[1]
		invoke GetPrivateProfileString,addr szIniKeywords,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			mov		ms.lpMem,offset tmpbuff
			lea		eax,buffword
			mov		ms.lpFind,eax
			mov		eax,da.lpCharTab
			mov		ms.lpCharTab,eax
			mov		ms.fr,FR_DOWN or FR_WHOLEWORD
			invoke SendMessage,ha.hProperty,PRM_MEMSEARCH,0,addr ms
			.if eax
				mov		eax,da.radcolor.kwcol[ebx*4]
				shr		eax,28
				.if !eax
					mov		eax,1
				.else
					mov		eax,2
				.endif
				jmp		Ex
			.endif
		.endif
		inc		ebx
	.endw
	xor		eax,eax
  Ex:
	retn

IsWordKeyWord endp

PropertyIsInList proc uses ebx esi edi,lpWord:DWORD,lpList:DWORD

	mov		esi,lpWord
	mov		edi,lpList
	.while byte ptr [edi]
		mov		ebx,edi
		xor		ecx,ecx
		.while byte ptr [esi+ecx]
			mov		al,[edi]
			mov		ah,[esi+ecx]
			.break.if al!=ah
			inc		ecx
			inc		edi
		.endw
		.if !byte ptr [esi+ecx] && (byte ptr [edi]==':' || byte ptr [edi]==',' || byte ptr [edi]=='[' || !byte ptr [edi])
			sub		ebx,lpList
			mov		eax,ebx
			jmp		Ex
		.endif
		.while byte ptr [edi] && byte ptr [edi]!=','
			inc		edi
		.endw
		.if byte ptr [edi]==','
			inc		edi
		.endif
	.endw
	mov		eax,-1
  Ex:
	ret

PropertyIsInList endp

PropertyFindExact proc uses ebx,lpType:DWORD,lpWord:DWORD,fMatchCase:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	xor		ebx,ebx
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,lpType,lpWord
	.while eax
		mov		ebx,eax
		invoke SendMessage,ha.hProperty,PRM_FINDGETTYPE,0,0
		.if eax=='d'
			invoke strcpy,addr buffer,ebx
			xor		eax,eax
			.while buffer[eax] && buffer[eax]!=':' && buffer[eax]!='['
				inc		eax
			.endw
			mov		buffer[eax],0
			.if fMatchCase
				invoke strcmp,addr buffer,lpWord
			.else
				invoke strcmpi,addr buffer,lpWord
			.endif
			.if !eax
				mov		eax,ebx
				jmp		Ex
			.endif
		.else
			.if fMatchCase
				invoke strcmp,ebx,lpWord
			.else
				invoke strcmpi,ebx,lpWord
			.endif
			.if !eax
				mov		eax,ebx
				jmp		Ex
			.endif
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
  Ex:
	ret

PropertyFindExact endp

ConvertToFind proc uses esi edi,lpszIn:DWORD,lpszOut:DWORD

	mov		esi,lpszIn
	mov		edi,lpszOut
	.while byte ptr [esi]
		mov		ax,[esi]
		.if ax=='I^'
			mov		al,VK_TAB
			inc		esi
		.elseif ax=='M^'
			mov		al,VK_RETURN
			inc		esi
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	ret

ConvertToFind endp

SelectBookmark proc hWin:HWND,nLine:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hWin,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hWin,REM_VCENTER,0,0
	invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	ret

SelectBookmark endp

NextBookmark proc uses ebx esi edi
	LOCAL	chrg:CHARRANGE
	LOCAL	nTab:DWORD
	LOCAL	nTabs:DWORD
	LOCAL	tci:TC_ITEM

	invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,ha.hEdt,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		edi,eax
	invoke SendMessage,ha.hEdt,REM_NXTBOOKMARK,edi,3
	.if eax!=-1
		invoke SelectBookmark,ha.hEdt,eax
	.else
		invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
		mov		nTab,eax
		invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
		mov		nTabs,eax
		mov		edi,nTab
		inc		edi
		mov		tci.imask,TCIF_PARAM
		.while edi<nTabs
			invoke SendMessage,ha.hTab,TCM_GETITEM,edi,addr tci
			mov		ebx,tci.lParam
			invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
			.if eax==ID_EDITCODE || eax==ID_EDITTEXT
				invoke SendMessage,[ebx].TABMEM.hedt,REM_NXTBOOKMARK,-1,3
				.if eax!=-1
					push	eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,edi,0
					invoke TabToolActivate
					pop		eax
					invoke SelectBookmark,[ebx].TABMEM.hedt,eax
					jmp		Ex
				.endif
			.endif
			inc		edi
		.endw
		xor		edi,edi
		mov		tci.imask,TCIF_PARAM
		.while edi<=nTab
			invoke SendMessage,ha.hTab,TCM_GETITEM,edi,addr tci
			mov		ebx,tci.lParam
			invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
			.if eax==ID_EDITCODE || eax==ID_EDITTEXT
				invoke SendMessage,[ebx].TABMEM.hedt,REM_NXTBOOKMARK,-1,3
				.if eax!=-1
					push	eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,edi,0
					invoke TabToolActivate
					pop		eax
					invoke SelectBookmark,[ebx].TABMEM.hedt,eax
					jmp		Ex
				.endif
			.endif
			inc		edi
		.endw
	.endif
  Ex:
	ret

NextBookmark endp

PreviousBookmark proc uses ebx esi edi
	LOCAL	chrg:CHARRANGE
	LOCAL	nTab:DWORD
	LOCAL	nTabs:DWORD
	LOCAL	tci:TC_ITEM

	invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,ha.hEdt,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		edi,eax
	invoke SendMessage,ha.hEdt,REM_PRVBOOKMARK,edi,3
	.if eax!=-1
		invoke SelectBookmark,ha.hEdt,eax
	.else
		invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
		mov		nTab,eax
		invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
		mov		nTabs,eax
		mov		edi,nTab
		dec		edi
		mov		tci.imask,TCIF_PARAM
		.while sdword ptr edi>=0
			invoke SendMessage,ha.hTab,TCM_GETITEM,edi,addr tci
			mov		ebx,tci.lParam
			invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
			.if eax==ID_EDITCODE || eax==ID_EDITTEXT
				invoke SendMessage,[ebx].TABMEM.hedt,EM_GETLINECOUNT,0,0
				invoke SendMessage,[ebx].TABMEM.hedt,REM_PRVBOOKMARK,eax,3
				.if eax!=-1
					push	eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,edi,0
					invoke TabToolActivate
					pop		eax
					invoke SelectBookmark,[ebx].TABMEM.hedt,eax
					jmp		Ex
				.endif
			.endif
			dec		edi
		.endw
		mov		edi,nTabs
		dec		edi
		mov		tci.imask,TCIF_PARAM
		.while sdword ptr edi>=nTab
			invoke SendMessage,ha.hTab,TCM_GETITEM,edi,addr tci
			mov		ebx,tci.lParam
			invoke GetWindowLong,[ebx].TABMEM.hedt,GWL_ID
			.if eax==ID_EDITCODE || eax==ID_EDITTEXT
				invoke SendMessage,[ebx].TABMEM.hedt,EM_GETLINECOUNT,0,0
				invoke SendMessage,[ebx].TABMEM.hedt,REM_PRVBOOKMARK,eax,3
				.if eax!=-1
					push	eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,edi,0
					invoke TabToolActivate
					pop		eax
					invoke SelectBookmark,[ebx].TABMEM.hedt,eax
					jmp		Ex
				.endif
			.endif
			dec		edi
		.endw
	.endif
  Ex:
	ret

PreviousBookmark endp

AutoBrace proc uses ebx esi edi,hWin:HWND,nChar:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	hMem:HGLOBAL

	.if da.edtopt.fopt & EDTOPT_BRACE
		invoke SendMessage,hWin,WM_GETTEXTLENGTH,0,0
		shr		eax,12
		inc		eax
		shl		eax,12
		push	eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hMem,eax
		mov		esi,eax
		pop		eax
		invoke SendMessage,hWin,WM_GETTEXT,eax,esi
		mov		eax,nChar
		.if eax=='[' || eax==']'
			mov		ebx,']['
		.endif
		xor		edi,edi
		.while byte ptr [esi]
			.if bl==[esi]
				mov		eax,esi
				sub		eax,hMem
				invoke SendMessage,hWin,REM_ISCHARPOS,0,0
				.if !eax
					inc		edi
				.endif
			.elseif bh==[esi]
				mov		eax,esi
				sub		eax,hMem
				invoke SendMessage,hWin,REM_ISCHARPOS,0,0
				.if !eax
					dec		edi
				.endif
			.endif
			lea		esi,[esi+1]
		.endw
		invoke GlobalFree,hMem
		.if edi
			invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
			mov		eax,nChar
			.if eax==']' && sdword ptr edi>0
				invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr nChar
				invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,hWin,EM_SCROLLCARET,0,0
			.elseif eax=='[' && sdword ptr edi<0
				mov		eax,chrg.cpMin
				dec		eax
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr nChar
			.endif
		.endif
	.endif
	ret

AutoBrace endp

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

SetAssemblers proc uses ebx esi edi
	LOCAL	mii:MENUITEMINFO
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetPrivateProfileString,addr szIniAssembler,addr szIniAssembler,addr szMasm,addr da.szAssemblers,sizeof da.szAssemblers,addr da.szRadASMIni
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenuItemInfo,ha.hMenu,IDM_PROJECT_LANGUAGE,FALSE,addr mii
	mov		edi,mii.hSubMenu
	xor		ebx,ebx
	.while ebx<20
		lea		eax,[ebx+IDM_PROJECT_LANGUAGE_START]
		invoke DeleteMenu,edi,eax,MF_BYCOMMAND
		inc		ebx
	.endw
	invoke strcpy,addr tmpbuff,addr da.szAssemblers
	xor		ebx,ebx
	.while tmpbuff && ebx<20
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
		lea		edx,[ebx+IDM_PROJECT_LANGUAGE_START]
		invoke AppendMenu,edi,MF_STRING,edx,addr buffer
		inc		ebx
	.endw
	ret

SetAssemblers endp

RTrim proc uses esi,lpBuff:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
	.if eax
		.while (byte ptr [esi+eax-1]==VK_SPACE || byte ptr [esi+eax-1]==VK_TAB) && eax
			dec		eax
		.endw
		mov		byte ptr [esi+eax],0
	.endif
	ret

RTrim endp

