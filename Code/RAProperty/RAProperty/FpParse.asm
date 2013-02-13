
.const

szfpskipline				db 	10,7,'program'
							db	10,4,'uses'
							db	0,0,0

szfpword1					db	10,8,'function'
							db	11,9,'procedure'
							db	12,4,'type'
							db	13,5,'const'
							db	14,3,'var'
							db	15,5,'begin'
							db	16,3,'end'
							db	0,0,0

szfpword2					db	10,6,'record'
							db	11,3,'end'
							db	12,5,'array'
							db	13,2,'to'
							db	0,0,0

szfpcomment					db '{',0
szfpstring					db '"',"'",0,0

.code

FpDestroyString proc lpMem:DWORD

	mov		eax,lpMem
	movzx	ecx,byte ptr [eax]
	mov		ch,cl
	inc		eax
	.while byte ptr [eax]!=0 && byte ptr [eax]!=VK_RETURN
		mov		dx,[eax]
		.if dx==cx
			mov		word ptr [eax],'  '
			lea		eax,[eax+2]
		.else
			inc		eax
			.break .if dl==cl
			mov		byte ptr [eax-1],20h
		.endif
	.endw
	ret

FpDestroyString endp

FpDestroyCmntBlock proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	mov		esi,lpMem
  @@:
	invoke SearchMemDown,esi,addr szfpcomment,FALSE,FALSE,lpCharTab
	.if eax
		mov		esi,eax
		.while eax>lpMem
			.break .if byte ptr [eax-1]==VK_RETURN || byte ptr [eax-1]==0Ah
			dec		eax
		.endw
		mov		ecx,dword ptr szfpstring
		mov		edx,'//'
		.while eax<esi
			.if byte ptr [eax]==cl || byte ptr [eax]==ch
				;String
				invoke FpDestroyString,eax
				mov		esi,eax
				jmp		@b
			.elseif word ptr [eax]==dx
				;Comment
				invoke DestroyToEol,eax
				mov		esi,eax
				jmp		@b
			.endif
			inc		eax
		.endw
		.while byte ptr [esi]!='}' && byte ptr [esi]
			mov		al,[esi]
			.if al!=VK_RETURN && al!=0Ah
				mov		byte ptr [esi],' '
			.endif
			inc		esi
		.endw
		.if byte ptr [esi]=='}'
			mov		byte ptr [esi],' '
		.endif
		jmp		@b
	.endif
	ret

FpDestroyCmntBlock endp

FpDestroyCommentsStrings proc uses esi,lpMem:DWORD

	mov		esi,lpMem
	mov		ecx,'//'
	mov		edx,dword ptr szfpstring
	.while byte ptr [esi]
		.if word ptr [esi]==cx
			invoke DestroyToEol,esi
			mov		esi,eax
		.elseif byte ptr [esi]==dl || byte ptr [esi]==dh
			invoke FpDestroyString,esi
			mov		esi,eax
			mov		ecx,'//'
			mov		edx,dword ptr szfpstring
		.elseif byte ptr [esi]==VK_TAB
			mov		byte ptr [esi],VK_SPACE
		.else
			inc		esi
		.endif
	.endw
	ret

FpDestroyCommentsStrings endp

FpPreParse proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	invoke FpDestroyCmntBlock,lpMem,lpCharTab
	invoke FpDestroyCommentsStrings,lpMem
	ret

FpPreParse endp

FpIsWord proc uses ecx ebx esi edi,lpWord:DWORD,lenWord:DWORD,lpList:DWORD

	mov		esi,lpList
	mov		edi,lenWord
	.while byte ptr [esi]
		movzx	ebx,byte ptr [esi+1]
		.if ebx==edi
			invoke strcmpin,addr [esi+2],lpWord,edi
			.if !eax
				movzx	eax,byte ptr [esi]
				jmp		Ex
			.endif
		.endif
		lea		esi,[esi+ebx+2]
	.endw
	xor		eax,eax
  Ex:
	ret

FpIsWord endp

FpParseFile proc uses ebx esi edi,nOwner:DWORD,lpMem:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpword1:DWORD
	LOCAL	len2:DWORD
	LOCAL	lpword2:DWORD
	LOCAL	lendt:DWORD
	LOCAL	lpdt:DWORD
	LOCAL	lenar:DWORD
	LOCAL	lpar:DWORD
	LOCAL	nnest:DWORD
	LOCAL	lenname[8]:DWORD
	LOCAL	lpname[8]:DWORD
	LOCAL	narray:DWORD
	LOCAL	lpCharTab:DWORD
	LOCAL	npos:DWORD
	LOCAL	nline:DWORD
	LOCAL	ntype:DWORD

	mov		eax,[ebx].RAPROPERTY.lpchartab
	mov		lpCharTab,eax
	mov		esi,lpMem
	invoke FpPreParse,esi,lpCharTab
	mov		npos,0
	mov		ntype,0
	.while byte ptr [esi]
		call	GetWord
		mov		eax,npos
		mov		nline,eax
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke FpIsWord,lpword1,len1,offset szfpskipline
			.if eax
				; Skip line
				.while byte ptr [esi] && byte ptr [esi]!=';'
					.if byte ptr [esi]==VK_RETURN
						inc		npos
					.endif
					inc		esi
				.endw
				jmp		NxtLine
			.endif
			invoke FpIsWord,lpword1,len1,offset szfpword1
			.if eax
				mov		ntype,eax
				.if eax==10
					;Function
					call	GetWord
					.if ecx
						mov		len1,ecx
						mov		lpword1,esi
						lea		esi,[esi+ecx]
						call	_Proc
					.endif
					mov		ntype,0
				.elseif eax==11
					;Procedure
					call	GetWord
					.if ecx
						mov		len1,ecx
						mov		lpword1,esi
						lea		esi,[esi+ecx]
						call	_Proc
					.endif
					mov		ntype,0
				.endif
			.elseif ntype
				mov		eax,ntype
				.if eax==12
					;Type
					call	_Struct
				.elseif eax==13
					;Const
					call	GetWord
					.if !ecx
						.if byte ptr [esi]==':'
							;Skip datatype
							inc		esi
							call	GetWord
							lea		esi,[esi+ecx]
							call	SkipSpc
						.endif
						.if byte ptr [esi]=='='
							inc		esi
							Call	_Const
						.endif
					.endif
				.elseif eax==14
					;Var
					call	GetWord
					.if !ecx
						.if byte ptr [esi]==':'
							call	_DataType
							.if eax
								call	_Data
							.endif
							.while byte ptr [esi] && byte ptr [esi]!=';'
								.if byte ptr [esi]==VK_RETURN
									inc		esi
									.if byte ptr [esi]==0Ah
										inc		esi
									.endif
									inc		npos
								.else
									inc		esi
								.endif
							.endw
						.elseif byte ptr [esi]==','
							call	_DataType
							.if eax
								call	_Data
							.endif
							inc		esi
							jmp		Nxt
						.endif
					.endif
				.endif
			.endif
		.endif
	  NxtLine:
		call	SkipLine
	  Nxt:
	.endw
	ret

SkipLine:
	xor		eax,eax
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		inc		esi
	.endw
	.if byte ptr [esi]==VK_RETURN
		inc		npos
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
	.endif
	retn

SkipSpc:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	retn

GetWord:
	call	SkipSpc
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
		inc		npos
	.endif
	mov		edx,lpCharTab
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	cmp		byte ptr [eax+edx],1
	je		@b
	retn

SaveWord1:
	push	ebx
	xor		ecx,ecx
	mov		ebx,lpword1
	.while ecx<len1
		mov		al,[ebx+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx],0
	lea		edi,[edi+ecx+1]
	pop		ebx
	retn

SaveWord2:
	push	ebx
	xor		ecx,ecx
	mov		ebx,lpword2
	.while ecx<len2
		mov		al,[ebx+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx],0
	lea		edi,[edi+ecx+1]
	pop		ebx
	retn

_DataType:
	mov		lpar,0
	push	esi
	push	npos
	.while byte ptr [esi] && byte ptr [esi]!=':'
		inc		esi
	.endw
	.if byte ptr [esi]==':'
		inc		esi
_DataType1:
		call	GetWord
		.if ecx
			invoke FpIsWord,esi,ecx,addr szfpword2
			.if eax==12;array
				lea		esi,[esi+ecx]
				call	GetWord
				.if byte ptr [esi]=='['
					xor		ecx,ecx
					.while byte ptr [esi+ecx] && byte ptr [esi+ecx]!=']'
						inc		ecx
					.endw
					.if byte ptr [esi+ecx]==']'
						inc		ecx
					.endif
					mov		lenar,ecx
					mov		lpar,esi
					lea		esi,[esi+ecx]
					call	GetWord
					lea		esi,[esi+ecx]
					jmp		_DataType1
				.endif
			.elseif !eax
				mov		lpdt,esi
				mov		lendt,ecx
				pop		npos
				pop		esi
				mov		eax,TRUE
				retn
			.endif
		.endif
	.endif
	pop		npos
	pop		esi
	xor		eax,eax
	retn

_Data:
	mov		edi,offset szname
	call	SaveWord1
	dec		edi
	.if lpar
		mov		eax,lenar
		invoke strcpyn,edi,lpar,addr [eax+1]
		add		edi,lenar
	.endif
	mov		byte ptr [edi],':'
	inc		edi
	mov		eax,lendt
	invoke strcpyn,edi,lpdt,addr [eax+1]
	add		edi,lendt
	mov		word ptr [edi],0
	mov		edx,'d'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

_Local:
	mov		eax,len1
	invoke strcpyn,edi,lpword1,addr [eax+1]
	add		edi,len1
	call	_DataType
	.if lpar
		mov		eax,lenar
		invoke strcpyn,edi,lpar,addr [eax+1]
		add		edi,lenar
	.endif
	mov		byte ptr [edi],':'
	inc		edi
	mov		eax,lendt
	invoke strcpyn,edi,lpdt,addr [eax+1]
	add		edi,lendt
	mov		word ptr [edi],','
	inc		edi
	retn

_Proc:
	mov		edi,offset szname
	call	SaveWord1
	mov		buff1,0
	mov		nnest,0
	call	GetWord
	.if !ecx
		.if byte ptr [esi]=='('
			;Parameters
			inc		esi
			.while byte ptr [esi] && byte ptr [esi]!=')'
				call	GetWord
				.if ecx
					push	ecx
					invoke strcpyn,edi,esi,addr [ecx+1]
					pop		ecx
					lea		edi,[edi+ecx]
					lea		esi,[esi+ecx]
					call	GetWord
					.if !ecx
						.if byte ptr[esi]==':'
							movsb
							push	ecx
							invoke strcpyn,edi,esi,addr [ecx+1]
							pop		ecx
							lea		edi,[edi+ecx]
							lea		esi,[esi+ecx]
						.endif
					.endif
				.elseif byte ptr [esi]==';'
					inc		esi
					mov		byte ptr [edi],','
					inc		edi
				.endif
			.endw
			mov		byte ptr [edi],0
			inc		edi
			.if byte ptr [esi]==')'
				inc		esi
				.if ntype==10
					;Return type
					call	GetWord
					.if !ecx
						.if byte ptr [esi]==':'
							inc		esi
							call	GetWord
							.if ecx
								push	ecx
								invoke strcpyn,edi,esi,addr [ecx+1]
								pop		ecx
								lea		edi,[edi+ecx]
								lea		esi,[esi+ecx]
							.endif
						.endif
					.endif
				.endif
			.endif
			mov		byte ptr [edi],0
			inc		edi
		.endif
	.endif
	push	edi
	mov		edi,offset buff1
	.while byte ptr [esi]
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke FpIsWord,lpword1,len1,offset szfpword1
			.if eax==14
				;Var
				mov		ntype,eax
			.elseif eax==15
				;Begin
				mov		ntype,eax
				inc		nnest
			.elseif eax==16
				;end
				mov		ntype,eax
				dec		nnest
				.break .if ZERO?
				.break .if SIGN?
			.elseif ntype==14 && !eax
				call	_Local
			.else
				mov		ntype,eax
			.endif
		.else
			.if ntype==14 && byte ptr [esi]==':'
				.while byte ptr [esi] && byte ptr [esi]!=';'
					inc		esi
				.endw
			.else
				inc		esi
			.endif
		.endif
	.endw
	.if buff1
		.if byte ptr [edi-1]==','
			mov		byte ptr [edi-1],0
		.endif
	.endif
	pop		edi
	invoke strcpy,edi,addr buff1
	mov		edx,'p'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
	retn

_Const:
	mov		edi,offset szname
	call	SaveWord1
	call	SkipSpc
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN && byte ptr [esi]!=';'
		mov		al,[esi]
		.if al!=VK_SPACE
			mov		[edi],al
			inc		edi
		.elseif byte ptr [edi-1]!=VK_SPACE
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	.if byte ptr [edi-1]==VK_SPACE
		dec		edi
	.endif
	mov		byte ptr [edi],0
	mov		edx,'c'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

_Struct:
	mov		edi,offset szname
	call	SaveWord1
	call	GetWord
	.if !ecx
		inc		esi
		call	GetWord
		mov		lpword1,esi
		mov		len1,ecx
		invoke FpIsWord,lpword1,len1,offset szfpword2
		.if eax==10;record
			.while byte ptr [esi]
				call	GetWord
				.if ecx
					mov		lpword1,esi
					mov		len1,ecx
					lea		esi,[esi+ecx]
					invoke FpIsWord,lpword1,len1,offset szfpword2
					.if eax==11;end
						mov		edx,'s'
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
						.break
					.else
						call	GetWord
						.if !ecx
							.if byte ptr [esi]==':'
								call	_Local
							.endif
						.endif
					.endif
				.else
					inc		esi
				.endif
			.endw
		.endif
	.endif
	retn

FpParseFile endp
