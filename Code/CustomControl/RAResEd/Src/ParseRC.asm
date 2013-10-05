.data?

			dw ?
wordbuff	db 16384 dup(?)
hrcmem		dd ?
fError		dd ?
fModify		dd ?
fParseError	dd ?

.code

SkipToEndOfComment proc

	.while byte ptr [esi] && word ptr [esi]!='/*'
		inc		esi
	.endw
	.if word ptr [esi]=='/*'
		add		esi,2
	.endif
	ret

SkipToEndOfComment endp

SkipToEol proc

	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		inc		esi
	.endw
	ret

SkipToEol endp

SkipSpace proc

  @@:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.if word ptr [esi]=='*/'
		invoke SkipToEndOfComment
		jmp		@b
	.endif
	.if byte ptr [esi]==';' || word ptr [esi]=='//'
		invoke SkipToEol
	.endif
	ret

SkipSpace endp

SkipCRLF proc

  @@:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB || byte ptr [esi]==0Dh || byte ptr [esi]==0Ah
		inc		esi
	.endw
	.if byte ptr [esi]==';' || word ptr [esi]=='//'
		invoke SkipToEol
		jmp		@b
	.elseif word ptr [esi]=='*/'
		invoke SkipToEndOfComment
		jmp		@b
	.endif
	ret

SkipCRLF endp

GetWord proc uses esi edi,lpWord:DWORD,lpLine:DWORD

	mov		esi,lpLine
	mov		edi,lpWord
	invoke SkipCRLF
	.if word ptr [esi]=='""' && byte ptr [esi+2]!='"'
		mov		ax,[esi]
		mov		[edi],ax
		inc		esi
		inc		esi
		inc		edi
		inc		edi
	.elseif byte ptr [esi]=='"'
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		xor		eax,eax
		.while byte ptr [esi] && al!='"'
			mov		ax,[esi]
			.if ax=='""'
				mov		[edi],ax
				inc		esi
				inc		edi
				xor		eax,eax
			.elseif ax=='"\'
				mov		[edi],ax
				inc		esi
				inc		edi
				xor		eax,eax
			.elseif al=='\' && ah==0Dh && byte ptr [esi+2]==0Ah
				inc		esi
				inc		esi
				dec		edi
			.else
				mov		[edi],al
			.endif
			inc		esi
			inc		edi
		.endw
	.else
		.while byte ptr [esi] && byte ptr [esi]!=VK_SPACE && byte ptr [esi]!=VK_TAB && byte ptr [esi]!=0Dh && byte ptr [esi]!=0Ah && byte ptr [esi]!=',' && byte ptr [esi]!='|' && byte ptr [esi]!='"'
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
	.endif
	mov		byte ptr [edi],0
	invoke SkipSpace
	mov		dl,[esi]
	.if dl==',' || dl=='|'
		push	edx
		inc		esi
		invoke SkipCRLF
		pop		edx
	.endif
	mov		eax,esi
	sub		eax,lpLine
	ret

GetWord endp

IsBegin proc lpWord:DWORD

	push	ecx
	push	edx
	invoke strcmpi,lpWord,offset szBEGIN
	.if eax
		invoke strcmpi,lpWord,offset szBEGINSHORT
	.endif
	pop		edx
	pop		ecx
	ret

IsBegin endp

IsEnd proc lpWord:DWORD

	push	ecx
	push	edx
	invoke strcmpi,lpWord,offset szEND
	.if eax
		invoke strcmpi,lpWord,offset szENDSHORT
	.endif
	pop		edx
	pop		ecx
	ret

IsEnd endp

GetName proc uses ebx,lpProMem:DWORD,lpBuff:DWORD,lpName:DWORD,lpID:DWORD

	mov		eax,lpBuff
	mov		al,[eax]
	.if (al>='0' && al<='9') || al=='-'
		;ID
		invoke ResEdDecToBin,lpBuff
		mov		edx,lpID
		mov		[edx],eax
		mov		edx,lpName
		mov		byte ptr [edx],0
	.else
		;Name
		invoke strcpyn,lpName,lpBuff,MaxName
		;ID
		invoke FindName,lpProMem,lpName,TRUE
		.if eax
			mov		[eax].NAMEMEM.delete,TRUE
			mov		ebx,[eax].NAMEMEM.value
			invoke IsNameDefault,lpName
			.if eax
				mov		ebx,eax
			.endif
			mov		edx,lpID
			mov		[edx],ebx
		.else
			xor		ebx,ebx
			invoke IsNameDefault,lpName
			.if eax
				mov		ebx,eax
			.endif
			mov		edx,lpID
			mov		[edx],ebx
		.endif
	.endif
	mov		edx,lpID
	mov		eax,[edx]
	ret

GetName endp

ParseDefine proc uses esi,lpRCMem:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	invoke GetWord,offset namebuff,esi
	add		esi,eax
	invoke SkipSpace
	.if byte ptr [esi]==VK_RETURN
		mov		word ptr wordbuff,'0'
	.else
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
	.endif
	invoke AddName,lpProMem,offset namebuff,offset wordbuff
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseDefine endp

ParseDefsSkip proc

	invoke strcmpi,offset wordbuff,offset szUNDEF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szIF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szELIF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szELSE
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szENDIF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szIFDEF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szIFNDEF
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szPRAGMA
	.if !eax
		invoke SkipToEol
		xor		eax,eax
		jmp		Ex
	.endif
	xor		eax,eax
	inc		eax
  Ex:
	ret

ParseDefsSkip endp

ParseFileName proc uses esi edi,lpRCMem:DWORD
	LOCAL	nend:BYTE

	mov		esi,lpRCMem
	mov		edi,offset wordbuff
	call	SkipSpace
	xor		ecx,ecx
	.while TRUE
		mov		al,[esi+ecx]
		.if al==VK_RETURN
			xor		ax,ax
		.endif
		mov		[edi+ecx],ax
		inc		ecx
		.break .if !al
	.endw
	lea		esi,[esi+ecx-1]
	push	esi
	mov		esi,offset wordbuff
	mov		edi,esi
	mov		al,[esi]
	.if al=='"'
		mov		nend,al
		inc		esi
	.elseif al=='<'
		mov		nend,'>'
	.else
		mov		nend,' '
	.endif
	mov		ah,1
	.while byte ptr [esi]
		mov		al,[esi]
		.if al==nend
			.if al=='>'
				mov		[edi],al
				inc		edi
			.endif
			xor		ax,ax
			mov		[edi],al
			inc		edi
		.elseif al=='\'
			.if byte ptr [esi+1]=='\'
				inc		esi
			.endif
		.elseif al=='/'
			mov		al,'\'
		.endif
		.if ah
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	pop		esi
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseFileName endp

GetLoadOptions proc uses ebx esi,lpRCMem:DWORD

	mov		esi,lpRCMem
	xor		ebx,ebx
  @@:
	add		esi,ebx
	invoke GetWord,offset wordbuff,esi
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szPRELOAD
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szLOADONCALL
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szFIXED
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szMOVEABLE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szDISCARDABLE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szPURE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szIMPURE
	or		eax,eax
	je		@b
	mov		eax,esi
	sub		eax,lpRCMem
	ret

GetLoadOptions endp

ParseInclude proc uses esi edi,lpRCMem:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	invoke GetTypeMem,lpProMem,TPE_INCLUDE
	mov		eax,[eax].PROJECT.hmem
	.if !eax
		invoke AddTypeMem,lpProMem,64*1024,TPE_INCLUDE
	.endif
	mov		edi,eax
	.while [edi].INCLUDEMEM.szfile
		lea		edi,[edi+sizeof INCLUDEMEM]
	.endw
	invoke ParseFileName,esi
	add		esi,eax
	invoke strcpy,addr [edi].INCLUDEMEM.szfile,offset wordbuff
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseInclude endp

ParseSkip proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	xor		ebx,ebx
  @@:
	add		esi,ebx
	invoke GetWord,offset wordbuff,esi
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szPRELOAD
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szLOADONCALL
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szFIXED
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szMOVEABLE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szDISCARDABLE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szPURE
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szIMPURE
	or		eax,eax
	je		@b
	xor		ebx,ebx
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
	  Nx:
		inc		ebx
	  @@:
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmpi,offset wordbuff,offset szENDSHORT
		.endif
		.if eax
			invoke strcmpi,offset wordbuff,offset szBEGIN
			.if eax
				invoke strcmpi,offset wordbuff,offset szBEGINSHORT
			.endif
			.if !eax
				jmp		Nx
			.endif
			invoke SkipToEol
			jmp		@b
		.endif
		dec		ebx
		jne		@b
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseSkip endp

ConvNum proc lpProMem:DWORD,lpBuff:DWORD

	mov		eax,lpBuff
	.if word ptr [eax]=='x0' || word ptr [eax]=='X0'
		add		eax,2
		invoke HexToBin,eax
	.elseif (byte ptr [eax]>='0' && byte ptr [eax]<='9') || byte ptr [eax]=='-'
		invoke ResEdDecToBin,eax
	.else
		invoke FindName,lpProMem,eax,FALSE
	.endif
	ret

ConvNum endp

GetNum proc lpProMem:DWORD

	invoke GetWord,offset wordbuff,esi
	mov		ecx,eax
	invoke IsBegin,offset wordbuff
	or		eax,eax
	je		Ex
	invoke IsEnd,offset wordbuff
	or		eax,eax
	je		Ex
	add		esi,ecx
	push	edx
	invoke ConvNum,lpProMem,offset wordbuff
	pop		edx
	cmp		dl,','
	je		Ex
	cmp		dl,'|'
	je		Ex
  @@:
	push	eax
	invoke GetWord,offset wordbuff,esi
	.if byte ptr wordbuff=='+'
		add		esi,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke ConvNum,lpProMem,offset wordbuff
		pop		edx
		add		eax,edx
		jmp		@b
	.elseif byte ptr wordbuff=='-'
		add		esi,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke ConvNum,lpProMem,offset wordbuff
		pop		edx
		sub		edx,eax
		mov		eax,edx
		jmp		@b
	.endif
	pop		eax
  Ex:
	ret

GetNum endp

FindStyle proc uses ebx esi,lpWord:DWORD,lpStyles:DWORD

	mov		edx,lpWord
	.if word ptr [edx]=='x0'
		invoke HexToBin,addr [edx+2]
		mov		edx,TRUE
	.elseif byte ptr [edx]>='0' && byte ptr [edx]<='9'
		invoke ResEdDecToBin,edx
		mov		edx,TRUE
	.else
		mov		esi,lpStyles
		.while byte ptr [esi+4]
			mov		ebx,[esi]
			invoke strcmp,addr [esi+4],lpWord
			.if !eax
				mov		eax,ebx
				mov		edx,TRUE
				jmp		Ex
			.endif
			invoke strlen,addr [esi+4]
			lea		esi,[esi+eax+4+1]
		.endw
		xor		eax,eax
		xor		edx,edx
	.endif
  Ex:
	ret

FindStyle endp

FindDlgStyle proc uses ebx esi,lpWord:DWORD,lpStyles:DWORD

	mov		edx,lpWord
	.if word ptr [edx]=='x0'
		invoke HexToBin,addr [edx+2]
		mov		edx,TRUE
	.elseif byte ptr [edx]>='0' && byte ptr [edx]<='9'
		invoke ResEdDecToBin,edx
		mov		edx,TRUE
	.else
		mov		esi,lpStyles
		.while byte ptr [esi+8]
			mov		ebx,[esi]
			invoke strcmp,addr [esi+8],lpWord
			.if !eax
				mov		eax,ebx
				mov		edx,TRUE
				jmp		Ex
			.endif
			invoke strlen,addr [esi+8]
			lea		esi,[esi+eax+8+1]
		.endw
		xor		eax,eax
		xor		edx,edx
	.endif
  Ex:
	ret

FindDlgStyle endp

GetStyle proc uses ebx esi edi,lpRCMem:DWORD,lpStyles:DWORD,fDialog:DWORD

	.if !lpStyles
		mov		ebx,WS_VISIBLE
	.else
		xor		ebx,ebx
	.endif
	mov		esi,lpRCMem
	.if byte ptr [esi]==','
		inc		esi
	.else
		.while !fParseError
			mov		edi,esi
			invoke GetWord,offset wordbuff,esi
			mov		ecx,eax
			invoke IsBegin,offset wordbuff
			or		eax,eax
			jz		Ex
			invoke IsEnd,offset wordbuff
			or		eax,eax
			jz		Ex
			push	ecx
			push	edx
			invoke strcmpi,offset wordbuff,offset szNOT
			pop		edx
			pop		ecx
			.if !eax
				add		esi,ecx
				invoke GetWord,offset wordbuff,esi
				add		esi,eax
				push	edx
				.if fDialog
					.if lpStyles
						invoke FindDlgStyle,offset wordbuff,lpStyles
					.else
						invoke FindDlgStyle,offset wordbuff,offset rsstyledef
						.if !edx
							invoke FindDlgStyle,offset wordbuff,offset rsstyledefdlg
						.endif
					.endif
				.else
					invoke FindStyle,offset wordbuff,lpStyles
				.endif
				.if !edx
					invoke strcpy,addr namebuff+1000,addr szUnknownStyle
					invoke strcat,addr namebuff+1000,addr namebuff
					invoke MessageBox,hRes,addr namebuff+1000,addr wordbuff,MB_OK or MB_ICONERROR
					inc		fParseError
					mov		fClose,-1
					xor		eax,eax
				.endif
				xor		eax,-1
				and		ebx,eax
			.else
				add		esi,ecx
				push	edx
				.if fDialog
					.if lpStyles
						invoke FindDlgStyle,offset wordbuff,lpStyles
					.else
						invoke FindDlgStyle,offset wordbuff,offset rsstyledef
						.if !edx
							invoke FindDlgStyle,offset wordbuff,offset rsstyledefdlg
						.endif
					.endif
				.else
					invoke FindStyle,offset wordbuff,lpStyles
				.endif
				.if !edx
					invoke strcpy,addr namebuff+1000,addr szUnknownStyle
					invoke strcat,addr namebuff+1000,addr namebuff
					invoke MessageBox,hRes,addr namebuff+1000,addr wordbuff,MB_OK or MB_ICONERROR
					inc		fParseError
					mov		fClose,-1
					xor		eax,eax
				.endif
				or		ebx,eax
			.endif
			pop		edx
			.break .if dl==',' || dl==0Dh
		.endw
	.endif
  Ex:
	mov		edx,ebx
	mov		eax,esi
	sub		eax,lpRCMem
	ret

GetStyle endp

GetLineNo proc hRCMem:DWORD,lpRCMem:DWORD

	mov		edx,hRCMem
	xor		eax,eax
	.while edx<=lpRCMem
		.if byte ptr [edx]==VK_RETURN
			inc		eax
		.endif
		inc		edx
	.endw
	ret

GetLineNo endp

ParseStringTable proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	nErr:DWORD
	LOCAL	lang:DWORD
	LOCAL	sublang:DWORD

	xor		eax,eax
	mov		lang,eax
	mov		sublang,eax
	mov		nErr,eax
	mov		esi,lpRCMem
	invoke AddTypeMem,lpProMem,512*1024,TPE_STRING
	mov		edi,eax
	invoke GetLoadOptions,esi
	add		esi,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		sublang,eax
		jmp		@b
	.endif
	sub		esi,ebx
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
	  @@:
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke ParseDefsSkip
		or		eax,eax
		je		@b
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmpi,offset wordbuff,offset szENDSHORT
		.endif
		.if eax
			.if byte ptr wordbuff=='"'
				inc		nErr
				jmp		@b
			.endif
			invoke GetName,lpProMem,offset wordbuff,addr [edi].STRINGMEM.szname,addr [edi].STRINGMEM.value
			mov		namebuff,0
		  NxStr:
			.if byte ptr [esi]
				invoke GetWord,offset wordbuff,esi
				.if byte ptr wordbuff!='"'
					mov		[edi].STRINGMEM.szname,0
					mov		[edi].STRINGMEM.value,0
					inc		nErr
					jmp		@b
				.elseif byte ptr [esi+eax]=='"'
					add		esi,eax
					invoke UnQuoteWord,offset wordbuff
					invoke strcat,offset namebuff,offset wordbuff
					jmp		NxStr
				.elseif byte ptr [esi+eax]!=0Dh
					mov		[edi].STRINGMEM.szname,0
					mov		[edi].STRINGMEM.value,0
					inc		nErr
					jmp		@b
				.endif
				add		esi,eax
				invoke UnQuoteWord,offset wordbuff
				invoke strcat,offset namebuff,offset wordbuff
				invoke strcpyn,addr [edi].STRINGMEM.szstring,offset namebuff,sizeof STRINGMEM.szstring
				mov		eax,lang
				mov		[edi].STRINGMEM.lang.lang,eax
				mov		eax,sublang
				mov		[edi].STRINGMEM.lang.sublang,eax
				add		edi,sizeof STRINGMEM
				jmp		@b
			.endif
		.endif
	.endif
	.if nErr
		invoke strcpy,addr namebuff,addr szErrorParse
		invoke GetLineNo,hrcmem,esi
		mov		edx,eax
		invoke ResEdBinToDec,edx,addr namebuff+100
		invoke strcat,addr namebuff,addr namebuff+100
		invoke MessageBox,0,addr namebuff,addr szSTRINGTABLE,MB_OK
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseStringTable endp

ParseResource proc uses esi edi,lpRCMem:DWORD,lpProMem:DWORD,nType:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL   ErrText[512]:BYTE
	LOCAL	nSize:DWORD

	invoke strcpy,addr buffer,offset wordbuff
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
	invoke ParseFileName,esi
	add		esi,eax
	.if byte ptr wordbuff
		.if nType==7
			invoke AddTypeMem,lpProMem,10*1024,TPE_XPMANIFEST
			mov		edi,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].XPMANIFESTMEM.szname,addr [edi].XPMANIFESTMEM.value
			invoke strcpyn,addr [edi].XPMANIFESTMEM.szfilename,offset wordbuff,sizeof XPMANIFESTMEM.szfilename
			invoke strcpy,addr buffer,addr szProjectPath
			invoke strcat,addr buffer,addr szBS
			invoke strcat,addr buffer,addr [edi].XPMANIFESTMEM.szfilename
			;PrintString buffer         
			invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke ReadFile,hFile,addr [edi+sizeof XPMANIFESTMEM],8192,addr nBytes,NULL
				invoke CloseHandle,hFile
			.else
				invoke strcpy,addr ErrText,addr buffer
				invoke strcat,addr ErrText,addr szCR
				invoke strcat,addr ErrText,addr szFileSpecFail
				invoke MessageBox,hDEd,addr ErrText,addr szAppName,MB_OK or MB_ICONERROR
			.endif
		.else
			invoke GetTypeMem,lpProMem,TPE_RESOURCE
			mov		eax,[eax].PROJECT.hmem
			.if !eax
				invoke AddTypeMem,lpProMem,64*1024,TPE_RESOURCE
			.endif
			mov		edi,eax
			.while [edi].RESOURCEMEM.szfile
				lea		edi,[edi+sizeof RESOURCEMEM]
			.endw
			mov		eax,nType
			mov		[edi].RESOURCEMEM.ntype,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].RESOURCEMEM.szname,addr [edi].RESOURCEMEM.value
			invoke strcpyn,addr [edi].RESOURCEMEM.szfile,offset wordbuff,sizeof RESOURCEMEM.szfile
		.endif
	.else
		.if nType==7
			invoke AddTypeMem,lpProMem,10*1024,TPE_XPMANIFEST
			mov		edi,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].XPMANIFESTMEM.szname,addr [edi].XPMANIFESTMEM.value
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke strcmpi,offset wordbuff,offset szBEGIN
			.if eax
				invoke strcmpi,offset wordbuff,offset szBEGINSHORT
			.endif
			.if !eax
				lea		edi,[edi+sizeof XPMANIFESTMEM]
			  @@:
				call	SkipSpace
				.if byte ptr [esi]==0Dh
					inc		esi
				.endif
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
				mov		edx,offset wordbuff
				.while byte ptr [esi] && byte ptr [esi]!=0Dh
					mov		ax,[esi]
					.if al=='"' && ah=='"'
						mov		[edx],al
						inc		edx
						inc		esi
					.elseif al!='"'
						mov		[edx],al
						inc		edx
					.endif
					inc		esi
				.endw
				mov		byte ptr [edx],0
				invoke strcmpi,offset wordbuff,offset szEND
				.if eax
					invoke strcmpi,offset wordbuff,offset szENDSHORT
				.endif
				.if eax
					mov		edx,offset wordbuff
					.while byte ptr [edx]
						mov		al,[edx]
						stosb
						inc		edx
					.endw
					mov		al,0Dh
					stosb
					mov		al,0Ah
					stosb
					jmp		@b
				.endif
				.if byte ptr [edi-1]==0Ah
					sub		edi,2
				.endif
				mov		al,0
				stosb
			.endif
		.elseif nType==4
			invoke AddTypeMem,lpProMem,64*1024,TPE_RCDATA
			mov		edi,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].RCDATAMEM.szname,addr [edi].RCDATAMEM.value
			invoke GetLoadOptions,esi
			add		esi,eax
		  @@:
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			mov		ebx,eax
			invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
			.if !eax
				invoke GetNum,lpProMem
				jmp		@b
			.endif
			invoke strcmpi,offset wordbuff,offset szVERSION
			.if !eax
				invoke GetNum,lpProMem
				jmp		@b
			.endif
			invoke strcmpi,offset wordbuff,offset szLANGUAGE
			.if !eax
				invoke GetWord,offset wordbuff,esi
				add		esi,eax
				.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
					invoke ConvNum,lpProMem,offset wordbuff
				.else
					invoke FindStyle,offset wordbuff,offset langdef
					shr		eax,16
				.endif
				mov		[edi].RCDATAMEM.lang.lang,eax
				invoke GetWord,offset wordbuff,esi
				add		esi,eax
				.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
					invoke ConvNum,lpProMem,offset wordbuff
				.else
					invoke FindStyle,offset wordbuff,offset langdef
					and		eax,0FFFFh
				.endif
				mov		[edi].RCDATAMEM.lang.sublang,eax
				jmp		@b
			.endif
			sub		esi,ebx
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke strcmpi,offset wordbuff,offset szBEGIN
			.if eax
				invoke strcmpi,offset wordbuff,offset szBEGINSHORT
			.endif
			.if !eax
				lea		edi,[edi+sizeof RCDATAMEM]
			  @@:
				call	SkipSpace
				.if byte ptr [esi]==0Dh
					inc		esi
				.endif
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
				mov		edx,offset wordbuff
				.while byte ptr [esi] && byte ptr [esi]!=0Dh
					mov		al,[esi]
					mov		[edx],al
					inc		esi
					inc		edx
				.endw
				mov		byte ptr [edx],0
				invoke strcmpi,offset wordbuff,offset szEND
				.if eax
					invoke strcmpi,offset wordbuff,offset szENDSHORT
				.endif
				.if eax
					mov		edx,offset wordbuff
					.while byte ptr [edx]
						mov		al,[edx]
						stosb
						inc		edx
					.endw
					mov		al,0Dh
					stosb
					mov		al,0Ah
					stosb
					jmp		@b
				.endif
				.if byte ptr [edi-1]==0Ah
					sub		edi,2
				.endif
				mov		al,0
				stosb
			.endif
		.elseif nType>=11
			invoke AddTypeMem,lpProMem,64*1024,TPE_USERDATA
			mov		edi,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].USERDATAMEM.szname,addr [edi].USERDATAMEM.value
			mov		eax,nType
			mov		edx,sizeof RARSTYPE
			mul		edx
			push	esi
			mov		esi,offset rarstype
			lea		esi,[esi+eax]
			invoke strcpy,addr [edi].USERDATAMEM.sztype,addr [esi].RARSTYPE.sztype
			mov		eax,[esi].RARSTYPE.nid
			mov		[edi].USERDATAMEM.ntype,eax
			pop		esi
			invoke GetLoadOptions,esi
			add		esi,eax
		  @@:
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			mov		ebx,eax
			invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
			.if !eax
				invoke GetNum,lpProMem
				jmp		@b
			.endif
			invoke strcmpi,offset wordbuff,offset szVERSION
			.if !eax
				invoke GetNum,lpProMem
				jmp		@b
			.endif
;			invoke strcmpi,offset wordbuff,offset szLANGUAGE
;			.if !eax
;				invoke GetWord,offset wordbuff,esi
;				add		esi,eax
;				.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
;					invoke ConvNum,lpProMem,offset wordbuff
;				.else
;					invoke FindStyle,offset wordbuff,offset langdef
;					shr		eax,16
;				.endif
;				mov		[edi].USERDATAMEM.lang.lang,eax
;				invoke GetWord,offset wordbuff,esi
;				add		esi,eax
;				.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
;					invoke ConvNum,lpProMem,offset wordbuff
;				.else
;					invoke FindStyle,offset wordbuff,offset langdef
;					and		eax,0FFFFh
;				.endif
;				mov		[edi].USERDATAMEM.lang.sublang,eax
;				jmp		@b
;			.endif
			sub		esi,ebx
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke strcmpi,offset wordbuff,offset szBEGIN
			.if eax
				invoke strcmpi,offset wordbuff,offset szBEGINSHORT
			.endif
			.if !eax
				lea		edi,[edi+sizeof USERDATAMEM]
			  @@:
				call	SkipSpace
				.if byte ptr [esi]==0Dh
					inc		esi
				.endif
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
				mov		edx,offset wordbuff
				.while byte ptr [esi] && byte ptr [esi]!=0Dh
					mov		al,[esi]
					mov		[edx],al
					inc		esi
					inc		edx
				.endw
				mov		byte ptr [edx],0
				invoke strcmpi,offset wordbuff,offset szEND
				.if eax
					invoke strcmpi,offset wordbuff,offset szENDSHORT
				.endif
				.if eax
					mov		edx,offset wordbuff
					.while byte ptr [edx]
						mov		al,[edx]
						stosb
						inc		edx
					.endw
					mov		al,0Dh
					stosb
					mov		al,0Ah
					stosb
					jmp		@b
				.endif
				.if byte ptr [edi-1]==0Ah
					sub		edi,2
				.endif
				mov		al,0
				stosb
			.endif
		.else
			mov		ecx,nType
			mov		eax,1
			shl		eax,cl
			test	eax,fError
			.if ZERO?
				invoke strcpy,addr namebuff+1024,addr szLine
				invoke GetLineNo,hrcmem,esi
				mov		edx,eax
				invoke ResEdBinToDec,edx,addr namebuff+1024+100
				invoke strcat,addr namebuff+1024,addr namebuff+1024+100
				invoke strcat,addr namebuff+1024,addr szCrLf
				invoke strcat,addr namebuff+1024,addr szNotSupported
				invoke MessageBox,0,addr namebuff+1024,addr buffer,MB_ICONEXCLAMATION or MB_OKCANCEL
				.if eax==IDCANCEL
					mov		eax,-1
					ret
				.endif
			.endif
			invoke GetTypeMem,lpProMem,TPE_RESOURCE
			mov		eax,[eax].PROJECT.hmem
			.if !eax
				invoke AddTypeMem,lpProMem,64*1024,TPE_RESOURCE
			.endif
			mov		edi,eax
			.while [edi].RESOURCEMEM.szfile
				lea		edi,[edi+sizeof RESOURCEMEM]
			.endw
			mov		eax,nType
			mov		[edi].RESOURCEMEM.ntype,eax
			.if byte ptr namebuff
				invoke strcpy,offset wordbuff,offset namebuff
			.else
				invoke strcpy,offset wordbuff,addr buffer
				invoke strcat,offset wordbuff,addr namebuff+1024+100
			.endif
			invoke strlen,offset wordbuff
			.if nType==0
				; BITMAP
				mov		dword ptr wordbuff[eax],'pmb.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==1
				; CURSOR
				mov		dword ptr wordbuff[eax],'ruc.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==2
				; ICON
				mov		dword ptr wordbuff[eax],'oci.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==3
				; AVI
				mov		dword ptr wordbuff[eax],'iva.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==4
				; RCDATA
				mov		dword ptr wordbuff[eax],'tad.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==5
				; WAVE
				mov		dword ptr wordbuff[eax],'vaw.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==6
				; IMAGE
				mov		dword ptr wordbuff[eax],'gmi.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==7
				; MANIFEST
				mov		dword ptr wordbuff[eax],'lmx.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==8
				; ANICURSOR
				mov		dword ptr wordbuff[eax],'ina.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==9
				; FONT
				mov		dword ptr wordbuff[eax],'nof.'
				mov		dword ptr wordbuff[eax+4],0
			.elseif nType==10
				; MESSAGETABLE
				mov		dword ptr wordbuff[eax],'gsm.'
				mov		dword ptr wordbuff[eax+4],0
			.else
				; Unknown
				mov		dword ptr wordbuff[eax],'xxx.'
				mov		dword ptr wordbuff[eax+4],0
			.endif
			mov		ecx,nType
			mov		eax,1
			shl		eax,cl
			or		fError,eax
			invoke GetName,lpProMem,offset namebuff,addr [edi].RESOURCEMEM.szname,addr [edi].RESOURCEMEM.value
			invoke strcpyn,addr [edi].RESOURCEMEM.szfile,offset wordbuff,sizeof RESOURCEMEM.szfile
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke strcmpi,offset wordbuff,offset szBEGIN
			.if eax
				invoke strcmpi,offset wordbuff,offset szBEGINSHORT
			.endif
			.if !eax
				mov		nSize,0
				invoke CreateFile,addr [edi].RESOURCEMEM.szfile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
				mov		hFile,eax
			  @@:
				call	SkipSpace
				.if byte ptr [esi]==0Dh
					inc		esi
				.endif
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
				mov		edx,offset wordbuff
				.while byte ptr [esi] && byte ptr [esi]!=0Dh
					mov		al,[esi]
					mov		[edx],al
					inc		esi
					inc		edx
				.endw
				mov		byte ptr [edx],0
				invoke strcmpi,offset wordbuff,offset szEND
				.if eax
					invoke strcmpi,offset wordbuff,offset szENDSHORT
				.endif
				.if eax
					mov		edx,offset wordbuff
					mov		ecx,edx
					.while byte ptr [edx]
						mov		al,[edx]
						.if (al>='0' && al<='9') || (al>='A' && al<="F") || (al>='a' && al<="f")
							.if al>='a'
								sub		al,'a'-10
							.elseif al>='A'
								sub		al,'A'-10
							.else
								sub		al,'0'
							.endif
							mov		ah,al
							inc		edx
							mov		al,[edx]
							.if (al>='0' && al<='9') || (al>='A' && al<="F") || (al>='a' && al<="f")
								.if al>='a'
									sub		al,'a'-10
								.elseif al>='A'
									sub		al,'A'-10
								.else
									sub		al,'0'
								.endif
								shl		ah,4
								or		ah,al
							.endif
							mov		[ecx],ah
							inc		edx
							inc		ecx
						.else
							inc		edx
						.endif
					.endw
					sub		ecx,offset wordbuff
					add		nSize,ecx
					invoke WriteFile,hFile,offset wordbuff,ecx,addr nBytes,NULL
					jmp		@b
				.endif
				invoke CloseHandle,hFile
				inc		fModify
			.endif
		.endif
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseResource endp

ParseControl proc uses ebx esi edi,lpRCMem:DWORD,lpDlgMem:DWORD,nTab:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	mov		edi,lpDlgMem
	;Flag handle
	mov		[edi].DIALOG.hwnd,TRUE
	;Tab
	mov		eax,nTab
	mov		[edi].DIALOG.tab,eax
	;Caption
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke UnQuoteWord,offset wordbuff
	invoke strcpyn,addr [edi].DIALOG.caption,offset wordbuff,sizeof DIALOG.caption
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke GetName,lpProMem,offset wordbuff,addr [edi].DIALOG.idname,addr [edi].DIALOG.id
	;Class
	invoke GetWord,offset namebuff,esi
	add		esi,eax
	invoke UnQuoteWord,offset namebuff
	;Style
	invoke GetStyle,esi,0,TRUE
	add		esi,eax
	mov		[edi].DIALOG.style,edx
	;Pos & Size
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.dux,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duy,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duccx,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duccy,eax
	movzx	eax,byte ptr [esi]
	.if eax!=0Dh
		;ExStyle
		invoke GetStyle,esi,offset rsexstyledef,TRUE
		add		esi,eax
		mov		[edi].DIALOG.exstyle,edx
		movzx	eax,byte ptr [esi]
		.if eax!=0Dh
			;HelpID
			invoke GetNum,lpProMem
		.else
			xor		eax,eax
		.endif
		mov		[edi].DIALOG.helpid,eax
	.endif
	invoke strcmpi,offset namebuff,offset szEditClass
	.if !eax
		;Edit
		mov		[edi].DIALOG.ntype,1
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szStaticClass
	.if !eax
		;Static
		mov		eax,[edi].DIALOG.style
		and		eax,SS_TYPEMASK
		.if eax==SS_ICON || eax==SS_BITMAP
			;Image
			mov		[edi].DIALOG.ntype,17
		.elseif (eax>=SS_BLACKRECT && eax<=SS_WHITEFRAME) || (eax>=SS_ETCHEDHORZ && eax<=SS_ETCHEDFRAME) || eax==SS_OWNERDRAW
			;Shape
			mov		[edi].DIALOG.ntype,25
		.else
			;Static
			mov		[edi].DIALOG.ntype,2
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szButtonClass
	.if !eax
		;Button
		mov		eax,[edi].DIALOG.style
		and		eax,0Fh
		mov		edx,4
		.if eax==BS_GROUPBOX
			mov		edx,3
		.elseif eax==BS_AUTOCHECKBOX || eax==BS_CHECKBOX || eax==BS_AUTO3STATE || eax==BS_3STATE
			mov		edx,5
		.elseif eax==BS_AUTORADIOBUTTON || eax==BS_RADIOBUTTON
			mov		edx,6
		.endif
		mov		[edi].DIALOG.ntype,edx
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szComboBoxClass
	.if !eax
		;ComboBox
		mov		[edi].DIALOG.ntype,7
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szListBoxClass
	.if !eax
		;ListBox
		mov		[edi].DIALOG.ntype,8
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szScrollBarClass
	.if !eax
		;ScrollBar
		mov		edx,[edi].DIALOG.style
		and		edx,SBS_VERT
		add		edx,9
		mov		[edi].DIALOG.ntype,edx
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szTabControlClass
	.if !eax
		;TabControl
		mov		[edi].DIALOG.ntype,11
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szProgressBarClass
	.if !eax
		;ProgressBar
		mov		[edi].DIALOG.ntype,12
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szTreeViewClass
	.if !eax
		;TreeView
		mov		[edi].DIALOG.ntype,13
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szListViewClass
	.if !eax
		;ListView
		mov		[edi].DIALOG.ntype,14
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szTrackBarClass
	.if !eax
		;TrackBar
		mov		[edi].DIALOG.ntype,15
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szUpDownClass
	.if !eax
		;UpDown
		mov		[edi].DIALOG.ntype,16
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szToolBarClass
	.if !eax
		;ToolBar
		mov		[edi].DIALOG.ntype,18
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szStatusBarClass
	.if !eax
		;StatusBar
		mov		[edi].DIALOG.ntype,19
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szDateTimeClass
	.if !eax
		;DateTime
		mov		[edi].DIALOG.ntype,20
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szMonthViewClass
	.if !eax
		;MonthView
		mov		[edi].DIALOG.ntype,21
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szRichEditClass
	.if !eax
		;RichEdit
		mov		[edi].DIALOG.ntype,22
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szComboBoxExClass
	.if !eax
		;ComboBoxEx
		mov		[edi].DIALOG.ntype,24
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szIPAddressClass
	.if !eax
		;IPAddress
		mov		[edi].DIALOG.ntype,26
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szAnimateClass
	.if !eax
		;AnimateControl
		mov		[edi].DIALOG.ntype,27
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szHotKeyClass
	.if !eax
		;HotKey
		mov		[edi].DIALOG.ntype,28
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szPagerClass
	.if !eax
		;PagerControl
		mov		edx,[edi].DIALOG.style
		and		edx,PGS_HORZ
		neg		edx
		add		edx,30
		mov		[edi].DIALOG.ntype,edx
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szReBarClass
	.if !eax
		;ReBar
		mov		[edi].DIALOG.ntype,31
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szHeaderClass
	.if !eax
		;Header
		mov		[edi].DIALOG.ntype,32
		jmp		Ex
	.endif
	invoke strcmpi,offset namebuff,offset szSysLinkClass
	.if !eax
		;SysLink
		mov		[edi].DIALOG.ntype,33
		jmp		Ex
	.endif
	mov		ebx,offset custtypes
	.while [ebx].TYPES.ID
		invoke strcmpi,offset namebuff,[ebx].TYPES.lpclass
		.if !eax
			;Custom control
			mov		eax,[ebx].TYPES.ID
			mov		[edi].DIALOG.ntypeid,eax
			mov		eax,ebx
			sub		eax,offset custtypes
			mov		ecx,sizeof TYPES
			xor		edx,edx
			div		ecx
			add		eax,NoOfButtons
			mov		[edi].DIALOG.ntype,eax
			jmp		Ex
		.endif
		add		ebx,sizeof TYPES
	.endw
	;UserControl
	;Copy class
	invoke strcpy,addr [edi].DIALOG.class,offset namebuff
	mov		[edi].DIALOG.ntype,23
	jmp		Ex
  Ex:
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseControl endp

ParseControlType proc uses esi edi,nType:DWORD,nStyle:DWORD,nExStyle:DWORD,lpRCMem:DWORD,lpDlgMem:DWORD,nTab:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	mov		edi,lpDlgMem
	;Flag handle
	mov		[edi].DIALOG.hwnd,TRUE
	;Tab
	mov		eax,nTab
	mov		[edi].DIALOG.tab,eax
	;Type
	mov		eax,nType
	mov		[edi].DIALOG.ntype,eax
	;Style
	mov		eax,nStyle
	or		eax,WS_CHILD or WS_VISIBLE
	mov		[edi].DIALOG.style,eax
	mov		eax,nExStyle
	mov		[edi].DIALOG.exstyle,eax
	.if byte ptr [esi]=='"'
		;Caption
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpyn,addr [edi].DIALOG.caption,offset wordbuff,sizeof DIALOG.caption
	.elseif nType==17
		;ICON
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		lea		eax,[edi].DIALOG.caption
		invoke strcpyn,addr [edi].DIALOG.caption,offset wordbuff,sizeof DIALOG.caption
	.endif
	;Name / ID
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke GetName,lpProMem,offset wordbuff,addr [edi].DIALOG.idname,addr [edi].DIALOG.id
	;Pos & Size
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.dux,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duy,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duccx,eax
	invoke GetNum,lpProMem
	mov		[edi].DIALOG.duccy,eax
	movzx	eax,byte ptr [esi]
	.if eax!=0Dh
		;Style
		invoke GetStyle,esi,0,TRUE
		add		esi,eax
		or		[edi].DIALOG.style,edx
		movzx	eax,byte ptr [esi]
		.if eax!=0Dh
			;ExStyle
			invoke GetStyle,esi,offset rsexstyledef,TRUE
			add		esi,eax
			or		[edi].DIALOG.exstyle,edx
		.endif
		movzx	eax,byte ptr [esi]
		.if eax!=0Dh
			;HelpID
			invoke GetNum,lpProMem
		.else
			xor		eax,eax
		.endif
		mov		[edi+sizeof DLGHEAD].DIALOG.helpid,eax
	.endif
	mov		eax,[edi].DIALOG.style
	and		eax,SBS_VERT
	.if nType==9 && eax==SBS_VERT
		mov		[edi].DIALOG.ntype,10
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseControlType endp

ParseControls proc lpProMem:DWORD
	LOCAL	nTab:DWORD

	mov		nTab,-1
	lea		edi,[edi+sizeof DLGHEAD]
	xor		eax,eax
  Nxt:
	add		esi,eax
	add		edi,sizeof DIALOG
	inc		nTab
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szCONTROL
	.if !eax
		invoke ParseControl,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szEDITTEXT
	.if !eax
		invoke ParseControlType,1,ES_LEFT or WS_TABSTOP,WS_EX_CLIENTEDGE,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szLTEXT
	.if !eax
		invoke ParseControlType,2,SS_LEFT or WS_GROUP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szCTEXT
	.if !eax
		invoke ParseControlType,2,SS_CENTER or WS_GROUP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szRTEXT
	.if !eax
		invoke ParseControlType,2,SS_RIGHT or WS_GROUP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szICON
	.if !eax
		invoke ParseControlType,17,SS_ICON or SS_CENTERIMAGE,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szGROUPBOX
	.if !eax
		invoke ParseControlType,3,BS_GROUPBOX,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szPUSHBUTTON
	.if !eax
		invoke ParseControlType,4,BS_PUSHBUTTON or WS_TABSTOP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szDEFPUSHBUTTON
	.if !eax
		invoke ParseControlType,4,BS_DEFPUSHBUTTON or WS_TABSTOP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szAUTOCHECKBOX
	.if !eax
		invoke ParseControlType,5,BS_AUTOCHECKBOX or WS_TABSTOP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szAUTORADIOBUTTON
	.if !eax
		invoke ParseControlType,6,BS_AUTORADIOBUTTON or WS_TABSTOP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szCOMBOBOX
	.if !eax
		invoke ParseControlType,7,CBS_SIMPLE or WS_TABSTOP,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szLISTBOX
	.if !eax
		invoke ParseControlType,8,LBS_NOTIFY,WS_EX_CLIENTEDGE,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szSCROLLBAR
	.if !eax
		invoke ParseControlType,9,SBS_HORZ,0,esi,edi,nTab,lpProMem
		jmp		Nxt
	.endif
	invoke strcmpi,offset wordbuff,offset szENDSHORT
	or		eax,eax
	je		Ex
	invoke strcmpi,offset wordbuff,offset szEND
	or		eax,eax
	jne		@b
  Ex:
	ret

ParseControls endp

ParseDialogEx proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	hMem:DWORD

	invoke AddTypeMem,lpProMem,MaxMem,TPE_DIALOG
	mov		hMem,eax
	mov		edi,eax
	mov		[edi+sizeof DLGHEAD].DIALOG.hwnd,TRUE
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi+sizeof DLGHEAD].DIALOG.idname,addr [edi+sizeof DLGHEAD].DIALOG.id
	.if eax
		inc		eax
	.else
		mov		eax,1001
	.endif
	mov		[edi].DLGHEAD.ctlid,eax
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.dux,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duy,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duccx,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duccy,eax
	xor		eax,eax
	.if dl==','
		;HelpID
		invoke GetNum,lpProMem
	.endif
	mov		[edi+sizeof DLGHEAD].DIALOG.helpid,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		[edi].DLGHEAD.lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		[edi].DLGHEAD.sublang,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szCAPTION
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpyn,addr [edi+sizeof DLGHEAD].DIALOG.caption,offset wordbuff,sizeof DIALOG.caption
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFONT
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].DLGHEAD.fontsize,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpy,addr [edi].DLGHEAD.font,offset wordbuff
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Weight
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.weight,ax
		.endif
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Italic
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.italic,al
		.endif
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Charset
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.charset,al
		.endif
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
		.endw
		mov		eax,[edi].DLGHEAD.fontsize
		mov		dlgps,ax
		invoke ConvFontToUnicode,offset dlgfn,addr [edi].DLGHEAD.font
		invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
		invoke DestroyWindow,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szMENU
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcpy,addr [edi].DLGHEAD.menuid,offset wordbuff
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szCLASS
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpy,addr [edi].DLGHEAD.class,offset wordbuff
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szSTYLE
	.if !eax
		invoke GetStyle,esi,0,TRUE
		add		esi,eax
		mov		[edi+sizeof DLGHEAD].DIALOG.style,edx
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szEXSTYLE
	.if !eax
		invoke GetStyle,esi,offset rsexstyledef,TRUE
		add		esi,eax
		mov		[edi+sizeof DLGHEAD].DIALOG.exstyle,edx
		jmp		@b
	.endif
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		invoke ParseControls,lpProMem
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseDialogEx endp

ParseDialog proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nPixy:DWORD

	invoke AddTypeMem,lpProMem,MaxMem,TPE_DIALOG
	mov		hMem,eax
	mov		edi,eax
	mov		[edi+sizeof DLGHEAD].DIALOG.hwnd,TRUE
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi+sizeof DLGHEAD].DIALOG.idname,addr [edi+sizeof DLGHEAD].DIALOG.id
	.if eax
		inc		eax
	.else
		mov		eax,1001
	.endif
	mov		[edi].DLGHEAD.ctlid,eax
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.dux,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duy,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duccx,eax
	invoke GetNum,lpProMem
	mov		[edi+sizeof DLGHEAD].DIALOG.duccy,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		[edi].DLGHEAD.lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		[edi].DLGHEAD.sublang,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szCAPTION
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpyn,addr [edi+sizeof DLGHEAD].DIALOG.caption,offset wordbuff,sizeof DIALOG.caption
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szMENU
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcpy,addr [edi].DLGHEAD.menuid,offset wordbuff
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szCLASS
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpy,addr [edi].DLGHEAD.class,offset wordbuff
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szSTYLE
	.if !eax
		invoke GetStyle,esi,0,TRUE
		add		esi,eax
		mov		[edi+sizeof DLGHEAD].DIALOG.style,edx
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szEXSTYLE
	.if !eax
		invoke GetStyle,esi,offset rsexstyledef,TRUE
		add		esi,eax
		mov		[edi+sizeof DLGHEAD].DIALOG.exstyle,edx
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFONT
	.if !eax
		invoke GetDC,NULL
		push	eax
		invoke GetDeviceCaps,eax,LOGPIXELSY
		mov		nPixy,eax
		pop		edx
		push	eax
		invoke ReleaseDC,NULL,edx
		invoke GetNum,lpProMem
		mov		[edi].DLGHEAD.fontsize,eax
		pop		edx
		mul		edx
		mov		ecx,72
		div		ecx
		neg		eax
;		mov		[edi].DLGHEAD.fontht,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpy,addr [edi].DLGHEAD.font,offset wordbuff
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Weight
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.weight,ax
		.endif
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Italic
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.italic,al
		.endif
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			;Charset
			invoke GetNum,lpProMem
			mov		[edi].DLGHEAD.charset,al
		.endif
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
		.endw
		jmp		@b
	.endif
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		invoke ParseControls,lpProMem
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseDialog endp

ParseMenu proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	nNest:DWORD
	LOCAL	hMem:DWORD

	invoke AddTypeMem,lpProMem,MaxMem,TPE_MENU
	mov		hMem,eax
	mov		edi,eax
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi].MNUHEAD.menuname,addr [edi].MNUHEAD.menuid
	mov		eax,[edi].MNUHEAD.menuid
	inc		eax
	mov		[edi].MNUHEAD.startid,eax
	mov		[edi].MNUHEAD.menuex,FALSE
	mov		nNest,0
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		[edi].MNUHEAD.lang.lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		[edi].MNUHEAD.lang.sublang,eax
		jmp		@b
	.endif
	sub		esi,ebx
	add		edi,sizeof MNUHEAD
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		inc		nNest
		jmp		@b
	.endif
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szPOPUP
	.if !eax
		mov		[edi].MNUITEM.itemflag,TRUE
		mov		eax,nNest
		dec		eax
		mov		[edi].MNUITEM.level,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke UnQuoteWord,offset wordbuff
		invoke strcpyn,addr [edi].MNUITEM.itemcaption,offset wordbuff,sizeof MNUITEM.itemcaption
		Call	SetOptions
		add		edi,sizeof MNUITEM
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szMENUITEM
	.if !eax
		mov		[edi].MNUITEM.itemflag,TRUE
		mov		eax,nNest
		dec		eax
		mov		[edi].MNUITEM.level,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szSEPARATOR
		.if eax
			invoke strcmpi,offset wordbuff,offset szMFT_SEPARATOR
		.endif
		.if !eax
			mov		word ptr [edi].MNUITEM.itemcaption,'-'
			add		edi,sizeof MNUITEM
			jmp		@b
		.endif
		invoke UnQuoteWord,offset wordbuff
		mov		ebx,offset wordbuff
		.while word ptr [ebx]!='t\' && byte ptr [ebx]
			inc		ebx
		.endw
		.if word ptr [ebx]=='t\'
			push	ebx
			add		ebx,2
		  NxtKey:
			xor		eax,eax
			.if dword ptr [ebx]=='fihS'
				add		ebx,6
				or		[edi].MNUITEM.shortcut,100h
				jmp		NxtKey
			.elseif dword ptr [ebx]=='lrtC'
				add		ebx,5
				or		[edi].MNUITEM.shortcut,200h
				jmp		NxtKey
			.elseif dword ptr [ebx]=='+tlA'
				add		ebx,4
				or		[edi].MNUITEM.shortcut,400h
				jmp		NxtKey
			.elseif word ptr [ebx]>='A' && word ptr [ebx]<='Z' || word ptr [ebx]>='0' && word ptr [ebx]<='9'  ; *** MOD add 0...9
				movzx	eax,byte ptr [ebx]
				or		[edi].MNUITEM.shortcut,eax
			; *** MOD add
			.elseif dword ptr [ebx]=='hgiR'
				mov     eax,800h or VK_RIGHT
				or		[edi].MNUITEM.shortcut,eax	
			.elseif dword ptr [ebx]=='tfeL'
				mov     eax,800h or VK_LEFT
				or		[edi].MNUITEM.shortcut,eax	
			.elseif word ptr [ebx]=='pU'
				mov     eax,800h or VK_UP
				or		[edi].MNUITEM.shortcut,eax	
			.elseif dword ptr [ebx]=='nwoD'
				mov     eax,800h or VK_DOWN
				or		[edi].MNUITEM.shortcut,eax
			; ==================		
			.elseif byte ptr [ebx]=='F'
				invoke ResEdDecToBin,addr [ebx+1]
				add		eax,6Fh
				or		[edi].MNUITEM.shortcut,eax
			.endif
			pop		ebx
			.if eax
				mov		byte ptr [ebx],0
			.else
				mov		[edi].MNUITEM.shortcut,eax
			.endif
		.endif
		invoke strcpyn,addr [edi].MNUITEM.itemcaption,offset wordbuff,sizeof MNUITEM.itemcaption
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		;Name / ID
		invoke GetName,lpProMem,offset wordbuff,addr [edi].MNUITEM.itemname,addr [edi].MNUITEM.itemid
		Call	SetOptions
		add		edi,sizeof MNUITEM
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szEND
	.if eax
		invoke strcmpi,offset wordbuff,offset szENDSHORT
	.endif
	.if !eax
		dec		nNest
		je		Ex
		jmp		@b
	.endif
  Ex:
	mov		eax,esi
	sub		eax,lpRCMem
	ret

SetOptions:
	xor		ebx,ebx
	.while byte ptr [esi] && byte ptr [esi]!=0Dh
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szCHECKED
		.if !eax
			or		ebx,MFS_CHECKED
		.endif
		invoke strcmpi,offset wordbuff,offset szGRAYED
		.if !eax
			or		ebx,MFS_GRAYED
		.endif
		invoke strcmpi,offset wordbuff,offset szINACTIVE
		.if !eax
		.endif
		invoke strcmpi,offset wordbuff,offset szMENUBARBREAK
		.if !eax
		.endif
		invoke strcmpi,offset wordbuff,offset szMENUBREAK
		.if !eax
		.endif
		invoke strcmpi,offset wordbuff,offset szHELP
		.if !eax
			or		[edi].MNUITEM.ntype,MFT_RIGHTJUSTIFY
		.endif
	.endw
	mov		[edi].MNUITEM.nstate,ebx
	retn

ParseMenu endp

ParseMenuEx proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	nNest:DWORD
	LOCAL	hMem:DWORD
	LOCAL	fPopUp:DWORD

	invoke AddTypeMem,lpProMem,MaxMem,TPE_MENU
	mov		hMem,eax
	mov		edi,eax
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi].MNUHEAD.menuname,addr [edi].MNUHEAD.menuid
	mov		eax,[edi].MNUHEAD.menuid
	inc		eax
	mov		[edi].MNUHEAD.startid,eax
	mov		[edi].MNUHEAD.menuex,TRUE
	mov		nNest,0
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		[edi].MNUHEAD.lang.lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		[edi].MNUHEAD.lang.sublang,eax
		jmp		@b
	.endif
	sub		esi,ebx
	add		edi,sizeof MNUHEAD
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		inc		nNest
		jmp		@b
	.endif
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	mov		fPopUp,FALSE
	invoke strcmpi,offset wordbuff,offset szMENUITEM
	.if eax
		invoke strcmpi,offset wordbuff,offset szPOPUP
		.if !eax
			mov		fPopUp,TRUE
		.endif
	.endif
	.if !eax
		mov		[edi].MNUITEM.itemflag,TRUE
		mov		eax,nNest
		dec		eax
		mov		[edi].MNUITEM.level,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szMFT_SEPARATOR
		.if !eax
			mov		word ptr [edi].MNUITEM.itemcaption,'-'
			add		edi,sizeof MNUITEM
			jmp		@b
		.endif
		invoke UnQuoteWord,offset wordbuff
		mov		ebx,offset wordbuff
		.while word ptr [ebx]!='t\' && byte ptr [ebx]
			inc		ebx
		.endw
		.if word ptr [ebx]=='t\'
			push	ebx
			add		ebx,2
		  NxtKey:
			xor		eax,eax
			.if dword ptr [ebx]=='fihS'
				add		ebx,6
				or		[edi].MNUITEM.shortcut,100h
				jmp		NxtKey
			.elseif dword ptr [ebx]=='lrtC'
				add		ebx,5
				or		[edi].MNUITEM.shortcut,200h
				jmp		NxtKey
			.elseif dword ptr [ebx]=='+tlA'
				add		ebx,4
				or		[edi].MNUITEM.shortcut,400h
				jmp		NxtKey
			.elseif word ptr [ebx]>='A' && word ptr [ebx]<='Z' || word ptr [ebx]>='0' && word ptr [ebx]<='9'  ; *** MOD add 0...9
				movzx	eax,byte ptr [ebx]
				or		[edi].MNUITEM.shortcut,eax
			; *** MOD add
			.elseif dword ptr [ebx]=='hgiR'
				mov     eax,800h or VK_RIGHT
				or		[edi].MNUITEM.shortcut,eax	
			.elseif dword ptr [ebx]=='tfeL'
				mov     eax,800h or VK_LEFT
				or		[edi].MNUITEM.shortcut,eax	
			.elseif word ptr [ebx]=='pU'                   
				mov     eax,800h or VK_UP
				or		[edi].MNUITEM.shortcut,eax	
			.elseif dword ptr [ebx]=='nwoD'
				mov     eax,800h or VK_DOWN
				or		[edi].MNUITEM.shortcut,eax
			; ==================		
			.elseif byte ptr [ebx]=='F'
				invoke ResEdDecToBin,addr [ebx+1]
				add		eax,6Fh
				or		[edi].MNUITEM.shortcut,eax
			.endif
			pop		ebx
			.if eax
				mov		byte ptr [ebx],0
			.else
				mov		[edi].MNUITEM.shortcut,eax
			.endif
		.endif
		invoke strcpyn,addr [edi].MNUITEM.itemcaption,offset wordbuff,sizeof MNUITEM.itemcaption
		.if byte ptr [esi] && byte ptr [esi]!=0Dh
			invoke GetWord,offset wordbuff,esi
			mov		ecx,eax
			invoke IsBegin,offset wordbuff
			or		eax,eax
			jz		NxtBegin
			invoke IsEnd,offset wordbuff
			or		eax,eax
			jz		NxtEnd
			add		esi,ecx
			;Name / ID
			invoke GetName,lpProMem,offset wordbuff,addr [edi].MNUITEM.itemname,addr [edi].MNUITEM.itemid
			Call	SetOptions
		.endif
	  NxtBegin:
		add		edi,sizeof MNUITEM
		jmp		@b
	.endif
  NxtEnd:
	invoke strcmpi,offset wordbuff,offset szEND
	.if eax
		invoke strcmpi,offset wordbuff,offset szENDSHORT
	.endif
	.if !eax
		dec		nNest
		je		Ex
		jmp		@b
	.endif
  Ex:
	mov		eax,esi
	sub		eax,lpRCMem
	ret

SetOptions:
	invoke SkipSpace
	movzx	eax,byte ptr [esi]
	.if eax && eax!=0Dh
		.if eax==','
			inc		esi
		.else
			;Type
			invoke GetStyle,esi,offset menutypedef,FALSE
			test	edx,MFT_SEPARATOR
			.if !ZERO?
				xor		edx,MFT_SEPARATOR
				mov		word ptr [edi].MNUITEM.itemcaption,'-'
			.endif
			mov		[edi].MNUITEM.ntype,edx
			add		esi,eax
		.endif
	.endif
	invoke SkipSpace
	movzx	eax,byte ptr [esi]
	.if eax && eax!=0Dh
		.if eax==','
			inc		esi
		.else
			;State
			invoke GetStyle,esi,offset menustatedef,FALSE
			mov		[edi].MNUITEM.nstate,edx
			add		esi,eax
		.endif
	.endif
	invoke SkipSpace
	movzx	eax,byte ptr [esi]
	.if eax && eax!=0Dh
		;HelpID
		invoke GetNum,lpProMem
		mov		[edi].MNUITEM.helpid,eax
	.endif
	retn

ParseMenuEx endp

ParseAccelerators proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	lang:DWORD
	LOCAL	sublang:DWORD
	LOCAL	ascii:DWORD

	mov		lang,0
	mov		sublang,0
	invoke AddTypeMem,lpProMem,64*1024,TPE_ACCEL
	mov		edi,eax
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi].ACCELMEM.szname,addr [edi].ACCELMEM.value
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	mov		ebx,eax
	invoke strcmpi,offset wordbuff,offset szCHARACTERISTICS
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSION
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			shr		eax,16
		.endif
		mov		lang,eax
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
			invoke ConvNum,lpProMem,offset wordbuff
		.else
			invoke FindStyle,offset wordbuff,offset langdef
			and		eax,0FFFFh
		.endif
		mov		sublang,eax
		jmp		@b
	.endif
	sub		esi,ebx
	mov		eax,lang
	mov		[edi].ACCELMEM.lang.lang,eax
	mov		eax,sublang
	mov		[edi].ACCELMEM.lang.sublang,eax
	add		edi,sizeof ACCELMEM
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
	  Nxt:
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmpi,offset wordbuff,offset szENDSHORT
		.endif
		.if eax
			invoke ParseDefsSkip
			or		eax,eax
			je		Nxt
			mov		eax,dword ptr wordbuff
			and		eax,0FFFFFFh
			.if al=='"'
				invoke UnQuoteWord,offset wordbuff
				movzx	eax,wordbuff
				mov		ascii,eax
				.if eax>='a' && eax<='z'
					and		eax,5Fh
				.endif
			.elseif ax=='x0'
				invoke HexToBin,offset wordbuff+2
				mov		ascii,eax
			.elseif al>='0' && al<='9'
				invoke ResEdDecToBin,offset wordbuff
				mov		ascii,eax
			.elseif eax=='_KV'
				push	esi
				mov		esi,offset szAclKeys
				.while byte ptr [esi]
					lea		eax,[esi+1]
					invoke strcmp,offset wordbuff+3,eax
					.if !eax
						movzx	eax,byte ptr [esi]
						jmp		@f
					.endif
					invoke strlen,esi
					lea		esi,[esi+eax+1]
				.endw
				mov		eax,41h
			  @@:
				mov		ascii,eax
				pop		esi
			.else
				mov		eax,41h
				mov		ascii,eax
			.endif
			mov		ebx,eax
			push	esi
			push	edi
			xor		edi,edi
			mov		esi,offset szAclKeys
			.while byte ptr [esi]
				.break .if bl==byte ptr [esi]
				invoke strlen,esi
				inc		edi
				lea		esi,[esi+eax+1]
			.endw
			mov		eax,edi
			pop		edi
			pop		esi
			mov		[edi].ACCELMEM.nkey,eax
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke GetName,lpProMem,offset wordbuff,addr [edi].ACCELMEM.szname,addr [edi].ACCELMEM.value
			xor		ebx,ebx
			.while byte ptr [esi]!=0Dh
				invoke GetWord,offset wordbuff,esi
				add		esi,eax
				invoke strcmpi,offset wordbuff,offset szVIRTKEY
				.if !eax
					jmp		@f
				.endif
				invoke strcmpi,offset wordbuff,offset szASCII
				.if !eax
					mov		eax,ascii;[edi].ACCELMEM.nkey
					mov		[edi].ACCELMEM.nascii,eax
					mov		[edi].ACCELMEM.nkey,0
					jmp		@f
				.endif
				invoke strcmpi,offset wordbuff,offset szNOINVERT
				.if !eax
					jmp		@f
				.endif
				invoke strcmpi,offset wordbuff,offset szCONTROL
				.if !eax
					or		ebx,1
					jmp		@f
				.endif
				invoke strcmpi,offset wordbuff,offset szSHIFT
				.if !eax
					or		ebx,2
					jmp		@f
				.endif
				invoke strcmpi,offset wordbuff,offset szALT
				.if !eax
					or		ebx,4
				.endif
			  @@:
			.endw
			mov		[edi].ACCELMEM.flag,ebx
			add		edi,sizeof ACCELMEM
			jmp		Nxt
		.endif
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseAccelerators endp

ParseVersioninfo proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	nNest:DWORD

	invoke AddTypeMem,lpProMem,64*1024,TPE_VERSION
	mov		edi,eax
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi].VERSIONMEM.szname,addr [edi].VERSIONMEM.value
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
  @@:
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke ParseDefsSkip
	or		eax,eax
	je		@b
	invoke strcmpi,offset wordbuff,offset szFILEVERSION
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.fv[0],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.fv[4],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.fv[8],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.fv[12],eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szPRODUCTVERSION
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.pv[0],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.pv[4],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.pv[8],eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.pv[12],eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFILEFLAGSMASK
	.if !eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFILEFLAGS
	.if !eax
		mov		[edi].VERSIONMEM.ff,eax
		invoke GetNum,lpProMem
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFILEOS
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.os,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFILETYPE
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.ft,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szFILESUBTYPE
	.if !eax
		invoke GetNum,lpProMem
		mov		[edi].VERSIONMEM.fts,eax
		jmp		@b
	.endif
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmp,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		mov		ebx,edi
		add		edi,sizeof VERSIONMEM
		mov		nNest,1
	  @@:
		invoke GetWord,offset wordbuff,esi
		add		esi,eax
		invoke strcmpi,offset wordbuff,offset szBEGIN
		.if eax
			invoke strcmpi,offset wordbuff,offset szBEGINSHORT
		.endif
		.if !eax
			inc		nNest
			jmp		@b
		.endif
		invoke strcmpi,offset wordbuff,offset szBLOCK
		.if !eax
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			.if byte ptr wordbuff=='"'
				invoke UnQuoteWord,offset wordbuff
				movzx	eax,byte ptr wordbuff
				.if eax>='0' && eax<='9'
					mov		word ptr [wordbuff-2],'x0'
					invoke ConvNum,lpProMem,offset wordbuff-2
					movzx	edx,ax
					shr		eax,16
					mov		[ebx].VERSIONMEM.lng,eax
					mov		[ebx].VERSIONMEM.chs,edx
				.endif
			.endif
			jmp		@b
		.endif
		invoke strcmpi,offset wordbuff,offset szVALUE
		.if !eax
			invoke GetWord,offset wordbuff,esi
			add		esi,eax
			invoke UnQuoteWord,offset wordbuff
			invoke strcmpi,offset wordbuff,offset szTranslation
			.if !eax
				invoke GetNum,lpProMem
				mov		[ebx].VERSIONMEM.lng,eax
				invoke GetNum,lpProMem
				mov		[ebx].VERSIONMEM.chs,eax
			.else
				invoke strcpyn,addr [edi].VERSIONITEM.szname,offset wordbuff,sizeof VERSIONITEM.szname
				invoke GetWord,offset wordbuff,esi
				add		esi,eax
				invoke UnQuoteWord,offset wordbuff
				invoke strlen,offset wordbuff
				.if word ptr wordbuff[eax-2]=='0\'
					mov		byte ptr wordbuff[eax-2],0
				.endif
				invoke strcpyn,addr [edi].VERSIONITEM.szvalue,offset wordbuff,sizeof VERSIONITEM.szvalue
				add		edi,sizeof VERSIONITEM
			.endif
			jmp		@b
		.endif
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmp,offset wordbuff,offset szENDSHORT
		.endif
		.if !eax
			dec		nNest
			jne		@b
		.endif
	.endif
  Ex:
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseVersioninfo endp

ParseLanguage proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	lang:DWORD
	LOCAL	sublang:DWORD

	mov		esi,lpRCMem
	mov		lang,0
	mov		sublang,0
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
		invoke ConvNum,lpProMem,offset wordbuff
	.else
		invoke FindStyle,offset wordbuff,offset langdef
		shr		eax,16
	.endif
	mov		lang,eax
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
		invoke ConvNum,lpProMem,offset wordbuff
	.else
		invoke FindStyle,offset wordbuff,offset langdef
		and		eax,0FFFFh
	.endif
	mov		sublang,eax
	invoke AddTypeMem,lpProMem,sizeof LANGUAGEMEM,TPE_LANGUAGE
	mov		edi,eax
	mov		eax,lang
	mov		[edi].LANGUAGEMEM.lang,eax
	mov		eax,sublang
	mov		[edi].LANGUAGEMEM.sublang,eax
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseLanguage endp

ParseToolbar proc uses ebx esi edi,lpRCMem:DWORD,lpProMem:DWORD
	LOCAL	hMem:DWORD

	invoke AddTypeMem,lpProMem,MaxMem,TPE_TOOLBAR
	mov		hMem,eax
	mov		edi,eax
	;Name / ID
	invoke GetName,lpProMem,offset namebuff,addr [edi].TOOLBARMEM.szname,addr [edi].TOOLBARMEM.value
	mov		esi,lpRCMem
	invoke GetLoadOptions,esi
	add		esi,eax
	invoke GetNum,lpProMem
	mov		[edi].TOOLBARMEM.ccx,eax
	invoke GetNum,lpProMem
	mov		[edi].TOOLBARMEM.ccy,eax
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
		lea		edi,[edi+sizeof TOOLBARMEM]
	  @@:
		call	SkipSpace
		.if byte ptr [esi]==0Dh
			inc		esi
		.endif
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
		mov		edx,offset wordbuff
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			mov		al,[esi]
			mov		[edx],al
			inc		esi
			inc		edx
		.endw
		mov		byte ptr [edx],0
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmpi,offset wordbuff,offset szENDSHORT
		.endif
		.if eax
			mov		edx,offset wordbuff
			.while byte ptr [edx]
				mov		al,[edx]
				stosb
				inc		edx
			.endw
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
			jmp		@b
		.endif
		.if byte ptr [edi-1]==0Ah
			sub		edi,2
		.endif
		mov		al,0
		stosb
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
  Ex:
	ret

ParseToolbar endp

ParseTextInclude proc uses esi edi,lpRCMem:DWORD,lpProMem:DWORD

	invoke GetLoadOptions,esi
	add		esi,eax
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szBEGIN
	.if eax
		invoke strcmpi,offset wordbuff,offset szBEGINSHORT
	.endif
	.if !eax
	  @@:
		call	SkipSpace
		.if byte ptr [esi]==0Dh
			inc		esi
		.endif
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
		mov		edx,offset wordbuff
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			mov		al,[esi]
			mov		[edx],al
			inc		esi
			inc		edx
		.endw
		mov		byte ptr [edx],0
		invoke strcmpi,offset wordbuff,offset szEND
		.if eax
			invoke strcmpi,offset wordbuff,offset szENDSHORT
		.endif
		.if eax
			jmp		@b
		.endif
	.endif
	mov		eax,esi
	sub		eax,lpRCMem
	ret

ParseTextInclude endp

ParseRC proc uses esi edi,lpRCMem:DWORD,hRCMem:DWORD,lpProMem:DWORD

	mov		esi,lpRCMem
	mov		edi,lpProMem
	.while [edi].PROJECT.hmem
		add		edi,sizeof PROJECT
	.endw
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke GetLineNo,hRCMem,esi
	mov		[edi].PROJECT.lnstart,eax
	invoke strcmpi,offset wordbuff,offset szDEFINE
	.if !eax
		invoke ParseDefine,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szINCLUDE
	.if !eax
		invoke ParseInclude,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke ParseDefsSkip
	or		eax,eax
	je		Ex
	.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
		invoke ResEdDecToBin,offset wordbuff
		.if eax==RT_STRING
			invoke ParseStringTable,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.endif
	.endif
	invoke strcmpi,offset wordbuff,offset szSTRINGTABLE
	.if !eax
		invoke ParseStringTable,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szLANGUAGE
	.if !eax
		invoke ParseLanguage,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcpy,offset namebuff,offset wordbuff
	invoke GetWord,offset wordbuff,esi
	add		esi,eax
	invoke strcmpi,offset wordbuff,offset szDESIGNINFO
	.if !eax
		invoke ParseSkip,esi,lpProMem
		add		esi,eax
		jmp		Ex
	.endif
	.if byte ptr wordbuff>='0' && byte ptr wordbuff<='9'
		invoke ResEdDecToBin,offset wordbuff
		.if eax==RT_BITMAP
			invoke ParseResource,esi,lpProMem,0
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_CURSOR
			invoke ParseResource,esi,lpProMem,1
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_ICON
			invoke ParseResource,esi,lpProMem,2
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
;		.elseif eax==RT_AVI
		.elseif eax==RT_RCDATA
			invoke ParseResource,esi,lpProMem,4
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
;		.elseif eax==RT_WAVE
;		.elseif eax==RT_IMAGE
		.elseif eax==RT_LVIMAGE
			invoke ParseResource,esi,lpProMem,6
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_MANIFEST
			invoke ParseResource,esi,lpProMem,7
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_ANICURSOR
			invoke ParseResource,esi,lpProMem,8
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_FONT
			invoke ParseResource,esi,lpProMem,9
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_MESSAGETABLE
			invoke ParseResource,esi,lpProMem,10
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_ACCELERATOR
			invoke ParseAccelerators,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_VERSION
			invoke ParseVersioninfo,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_DIALOGEX
			invoke ParseDialogEx,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_DIALOG
			invoke ParseDialog,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_MENUEX
			invoke ParseMenuEx,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.elseif eax==RT_MENU
			invoke ParseMenu,esi,lpProMem
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.endif
	.endif
	mov		edi,offset rarstype
	xor		ebx,ebx
	.while [edi].RARSTYPE.sztype
		invoke strcmpi,offset wordbuff,addr [edi].RARSTYPE.sztype
		.if !eax
			invoke ParseResource,esi,lpProMem,ebx
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.endif
		add		edi,sizeof RARSTYPE
		inc		ebx
	.endw
	invoke strcmpi,offset wordbuff,offset szRT_MANIFEST
	.if !eax
		invoke ParseResource,esi,lpProMem,7
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szRT_RCDATA
	.if !eax
		invoke ParseResource,esi,lpProMem,4
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szACCELERATORS
	.if !eax
		invoke ParseAccelerators,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szVERSIONINFO
	.if !eax
		invoke ParseVersioninfo,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szDIALOGEX
	.if !eax
		invoke ParseDialogEx,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szDIALOG
	.if !eax
		invoke ParseDialog,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szMENU
	.if !eax
		invoke ParseMenu,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szMENUEX
	.if !eax
		invoke ParseMenuEx,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szTOOLBAR
	.if !eax
		invoke ParseToolbar,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	invoke strcmpi,offset wordbuff,offset szTEXTINCLUDE
	.if !eax
		invoke ParseTextInclude,esi,lpProMem
		.if eax==-1
			jmp		ExErr
		.endif
		add		esi,eax
		jmp		Ex
	.endif
	.if byte ptr wordbuff
		invoke strcpy,offset namebuff+1024,offset namebuff
		invoke strcat,offset namebuff+1024,offset szSPACE
		invoke strcat,offset namebuff+1024,offset wordbuff
		invoke SkipSpace
		.if byte ptr [esi]=='"'
			invoke strcat,offset namebuff+1024,offset szCustomType
			invoke MessageBox,hRes,offset namebuff+1024,offset szAppName,MB_ICONEXCLAMATION or MB_OKCANCEL
			.if eax==IDCANCEL
				mov		eax,-1
				jmp		ExErr
			.endif
			invoke ParseResource,esi,lpProMem,4
			.if eax==-1
				jmp		ExErr
			.endif
			add		esi,eax
			jmp		Ex
		.else
			invoke strcat,offset namebuff+1024,offset szUnknownType
			invoke MessageBox,hRes,offset namebuff+1024,offset szAppName,MB_ICONERROR or MB_OK
		.endif
	.endif
  Ex:
	invoke GetLineNo,hRCMem,esi
	mov		[edi].PROJECT.lnend,eax
	mov		eax,esi
	sub		eax,lpRCMem
	ret
  ExErr:
	mov		fClose,eax
	ret

ParseRC endp

ParseRCMem proc uses esi,hRCMem:DWORD,lpProMem:DWORD

	xor		eax,eax
	mov		fError,eax
	mov		fModify,eax
	mov		fParseError,eax
	mov		esi,hRCMem
	mov		hrcmem,esi
	.while TRUE
		invoke ParseRC,esi,hRCMem,lpProMem
		.break .if !eax || eax==-1 || fParseError
		add		esi,eax
	.endw
	mov		eax,lpProMem
	ret

ParseRCMem endp
