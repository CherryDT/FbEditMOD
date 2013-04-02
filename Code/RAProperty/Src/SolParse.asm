.const

szsolskipline				db 	10,7,'section'
							db	10,7,'include'
							db	10,6,'invoke'
							db	0,0,0

szsolword1					db	10,4,'proc'
							db	11,5,'struc'
							db	11,6,'struct'
							db	11,5,'union'
							db	12,5,'macro'
							db	13,4,'enum'
							db	0,0,0

szsolword2					db	10,3,'equ'
							db	0,0,0

szsolinproc					db	10,3,'arg'
							db	11,5,'local'
							db	12,4,'endp'
							db	13,4,'uses'
							db	0,0,0

szsolinstruct				db 10,5,'union'
							db 11,4,'endu'
							db 10,5,'struc'
							db 10,6,'struct'
							db 11,4,'ends'
							db	0,0,0

szsolinstructitem			db	10,2,'rs'
							db	11,2,'rb'
							db	11,2,'rw'
							db	11,2,'rd'
							db	0,0,0

szsolinmacro				db	10,4,'marg'
							db	11,4,'endm'
							db	0,0,0

szsolinenum					db	10,4,'ende'
							db	0,0,0

szsoldatatypes				db	10,2,'DB'
							db	10,2,'DW'
							db	10,2,'DD'
							db	10,2,'DQ'
							db	10,2,'DF'
							db	10,2,'DT'
							db	10,4,'BYTE'
							db	10,5,'SBYTE'
							db	10,4,'WORD'
							db	10,5,'SWORD'
							db	10,5,'FWORD'
							db	10,5,'DWORD'
							db	10,6,'SDWORD'
							db	10,5,'QWORD'
							db	10,5,'REAL4'
							db	10,5,'REAL8'
							db	10,6,'REAL10'
							db	10,5,'TBYTE'
							db	11,2,'RB'
							db	11,2,'RW'
							db	11,2,'RD'
							db	12,2,'RS'
							db	0,0,0

szsolcomment				db '/*',0
szsolstring					db '"',"'",0,0

.code

SolDestroyString proc lpMem:DWORD

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

SolDestroyString endp

SolDestroyCmntBlock proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	mov		esi,lpMem
  @@:
	invoke SearchMemDown,esi,addr szsolcomment,FALSE,FALSE,lpCharTab
	.if eax
		mov		esi,eax
		.while eax>lpMem
			.break .if byte ptr [eax-1]==VK_RETURN || byte ptr [eax-1]==0Ah
			dec		eax
		.endw
		mov		ecx,dword ptr szsolstring
		mov		edx,';'
		.while eax<esi
			.if byte ptr [eax]==cl || byte ptr [eax]==ch
				;String
				invoke SolDestroyString,eax
				mov		esi,eax
				jmp		@b
			.elseif byte ptr [eax]==dl
				;Comment
				inc		eax
				invoke DestroyToEol,eax
				mov		esi,eax
				jmp		@b
			.endif
			inc		eax
		.endw
		.while word ptr [esi]!='/*' && byte ptr [esi]
			mov		al,[esi]
			.if al!=VK_RETURN && al!=0Ah
				mov		byte ptr [esi],' '
			.endif
			inc		esi
		.endw
		.if word ptr [esi]=='/*'
			mov		word ptr [esi],'  '
		.endif
		jmp		@b
	.endif
	ret

SolDestroyCmntBlock endp

SolDestroyCommentsStrings proc uses esi,lpMem:DWORD

	mov		esi,lpMem
	mov		ecx,';'
	mov		edx,dword ptr szsolstring
	.while byte ptr [esi]
		.if byte ptr [esi]==cl
			invoke DestroyToEol,esi
			mov		esi,eax
		.elseif byte ptr [esi]==dl || byte ptr [esi]==dh
			invoke SolDestroyString,esi
			mov		esi,eax
			mov		ecx,';'
			mov		edx,dword ptr szsolstring
		.elseif byte ptr [esi]==VK_TAB
			mov		byte ptr [esi],VK_SPACE
		.else
			inc		esi
		.endif
	.endw
	ret

SolDestroyCommentsStrings endp

SolPreParse proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	invoke SolDestroyCmntBlock,lpMem,lpCharTab
	invoke SolDestroyCommentsStrings,lpMem
	ret

SolPreParse endp

SolIsWord proc uses ebx esi edi,lpWord:DWORD,lenWord:DWORD,lpList:DWORD

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

SolIsWord endp

SolParseFile proc uses ebx esi edi,nOwner:DWORD,lpMem:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpword1:DWORD
	LOCAL	len2:DWORD
	LOCAL	lpword2:DWORD
	LOCAL	lendt:DWORD
	LOCAL	lpdt:DWORD
	LOCAL	nnest:DWORD
	LOCAL	lenname[8]:DWORD
	LOCAL	lpname[8]:DWORD
	LOCAL	narray:DWORD
	LOCAL	lpCharTab:DWORD
	LOCAL	npos:DWORD
	LOCAL	nline:DWORD
	LOCAL	nenum:DWORD

	mov		eax,[ebx].RAPROPERTY.lpchartab
	mov		lpCharTab,eax
	mov		esi,lpMem
	invoke SolPreParse,esi,lpCharTab
	mov		npos,0
	.while byte ptr [esi]
		mov		eax,npos
		mov		nline,eax
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke SolIsWord,lpword1,len1,offset szsolskipline
			.if eax
				; Skip line
				jmp		Nxt
			.endif
			call	GetWord
			.if ecx
				mov		len2,ecx
				mov		lpword2,esi
				lea		esi,[esi+ecx]
				invoke SolIsWord,lpword1,len1,offset szsolword1
				.if eax
					.if eax==10
						; Proc
						call	_Proc
						jmp		Nxt
					.elseif eax==11
						; Struc, Union
						call	_Struct
						jmp		Nxt
					.elseif eax==12
						; Macro
						call	_Macro
						jmp		Nxt
					.elseif eax==13
						; Enum
						call	_Enum
						jmp		Nxt
					.endif
				.endif
				invoke SolIsWord,lpword2,len2,offset szsolword2
				.if eax
					.if eax==10
						; const equ 10
						call	_Const
						jmp		Nxt
					.endif
				.endif
				invoke SolIsWord,lpword2,len2,offset szsoldatatypes
				.if eax
					.if eax>=10 && eax<=12
						; data db ?, data byte ?, data rb 10, data rs RECT,10
						call	_Data
						jmp		Nxt
					.endif
				.endif
			.elseif byte ptr [esi]==':'
				; label:
				call	_Label
			.endif
		.endif
	  Nxt:
		call	SkipLine
	.endw
	ret

SkipLine:
	xor		eax,eax
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		.if byte ptr [esi]!=VK_SPACE
			mov		al,[esi]
		.endif
		inc		esi
	.endw
	.if byte ptr [esi]==VK_RETURN
		inc		npos
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	.if al=='\' || al==','
		jmp		SkipLine
	.endif
	retn

SkipSpc:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	xor		ecx,ecx
	.if byte ptr [esi]=='\' || byte ptr [esi]==','
		inc		ecx
		.while byte ptr [esi+ecx]==VK_SPACE
			inc		ecx
		.endw
		.if byte ptr [esi+ecx]==VK_RETURN
			lea		esi,[esi+ecx+1]
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
			inc		npos
			jmp		SkipSpc
		.endif
	.endif
	retn

GetWord:
	call	SkipSpc
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

SkipBrace:
	xor		eax,eax
	dec		eax
SkipBrace1:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	mov		al,[esi]
	inc		esi
	.if al=='('
		push	eax
		mov		ah,')'
		jmp		SkipBrace1
	.elseif al=='{'
		push	eax
		mov		ah,'}'
		jmp		SkipBrace1
	.elseif al=='['
		push	eax
		mov		ah,']'
		jmp		SkipBrace1
	.elseif al=='<'
		push	eax
		mov		ah,'>'
		jmp		SkipBrace1
	.elseif al=='"'
		push	eax
		mov		ah,'"'
		jmp		SkipBrace1
	.elseif al=="'"
		push	eax
		mov		ah,"'"
		jmp		SkipBrace1
	.elseif al==ah
		pop		eax
	.elseif ah==0FFh
		dec		esi
		retn
	.elseif al==VK_RETURN || al==0
		dec		esi
		pop		eax
	.endif
	jmp		SkipBrace1

ConvDataType:
	push	esi
	mov		esi,offset szSolDataConv
	.if lendt==2
		.while byte ptr [esi]
			invoke strcmpin,esi,lpdt,2
			.if !eax
				lea		esi,[esi+3]
				mov		lpdt,esi
				invoke strlen,esi
				mov		lendt,eax
				jmp		ExConvDataType
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
	.elseif lendt==4 || lendt==5 || lendt==6
		.while byte ptr [esi]
			lea		esi,[esi+3]
			invoke strcmpin,esi,lpdt,lendt
			.if !eax
				mov		lpdt,esi
				jmp		ExConvDataType
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
	.endif
  ExConvDataType:
	pop		esi
	retn

ArraySize:
	call	SkipSpc
	push	ebx
	mov		ebx,offset buff1[8192]
	mov		word ptr [ebx-1],0
	mov		word ptr buff1[4096-1],0
	mov		narray,0
	.while TRUE
		mov		al,[esi]
		.if al=='"' || al=="'"
			inc		esi
			.while al!=[esi] && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
				inc		esi
				inc		narray
			.endw
			.if al==[esi]
				inc		esi
			.endif
			mov		al,[esi]
		.elseif al=='<'
			call	SkipBrace
			inc		narray
		.endif
		mov		ah,[ebx-1]
		.if al==' ' || al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')' || al==','
			.if ah==' ' || (al==',' && ah==',')
				dec		ebx
			.endif
		.endif
		.if al==' '
			.if ah=='+' || ah=='-' || ah=='*' || ah=='/' || ah=='(' || ah==')' || ah==','
				mov		al,ah
				dec		ebx
			.endif
		.endif
		.if al==',' || al==VK_RETURN || !al
			.if byte ptr [ebx-1]
				inc		narray
			.endif
			mov		ebx,offset buff1[8192]
			mov		byte ptr [ebx],0
		  .break .if al==VK_RETURN || !al
		.else
			mov		[ebx],al
			inc		ebx
		.endif
		inc		esi
	.endw
	mov		byte ptr [ebx],0
	pop		ebx
	.if narray>1 || (byte ptr buff1[4096] && narray)
		.if byte ptr buff1[4096]
			invoke strcat,addr buff1[4096],addr szAdd
		.endif
		invoke DwToAscii,narray,addr buff1[8192+1024]
		invoke strcat,addr buff1[4096],addr buff1[8192+1024]
	.endif
	retn

AddParam:
	call	GetWord
	.if ecx
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		push	ecx
		invoke strcpyn,edi,lpword1,addr [ecx+1]
		pop		ecx
		lea		edi,[edi+ecx]
		call	SkipSpc
		.if byte ptr [esi]=='['
			.while byte ptr [esi] && byte ptr [esi-1]!=']'
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			call	SkipSpc
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		.if byte ptr [esi]==':'
			inc		esi
			call	GetWord
			mov		lendt,ecx
			mov		lpdt,esi
			lea		esi,[esi+ecx]
			call	ConvDataType
			mov		ecx,lendt
			push	ecx
			invoke strcpyn,edi,lpdt,addr [ecx+1]
			pop		ecx
			lea		edi,[edi+ecx]
			mov		byte ptr [edi],','
			inc		edi
		.else
			invoke strcpy,edi,addr szDword[1]
			lea		edi,[edi+5]
			mov		byte ptr [edi],','
			inc		edi
		.endif
		jmp		AddParam
	.elseif byte ptr [esi]==','
		inc		esi
		jmp		AddParam
	.endif
	retn

_Proc:
	mov		edi,offset szname
	call	SaveWord2
	mov		buff1,0
	mov		buff2,0
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke SolIsWord,lpword1,len1,offset szsolinproc
			.if eax==10
				;arg
				mov		edi,offset buff1
				invoke strlen,edi
				lea		edi,[edi+eax]
				call	AddParam
			.elseif eax==11
				;local
				mov		edi,offset buff2
				invoke strlen,edi
				lea		edi,[edi+eax]
				call	AddParam
			.elseif eax==12
				;endp
				.break
			.elseif eax==13
				;uses
			.endif
		.endif
	.endw
	invoke strlen,addr buff1
	.if byte ptr buff1[eax-1]==','
		mov		byte ptr buff1[eax-1],0
	.endif
	invoke strlen,addr buff2
	.if byte ptr buff2[eax-1]==','
		mov		byte ptr buff2[eax-1],0
	.endif
	;Name
	mov		edi,offset szname
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	;Parameters
	invoke strcpy,edi,addr buff1
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	;Return type
	mov		byte ptr [edi],0
	inc		edi
	;Locals
	invoke strcpy,edi,addr buff2
	mov		edx,'p'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
	retn

_Label:
	mov		edi,offset szname
	call	SaveWord1
	mov		edx,'l'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,1
	retn

_Const:
	mov		edi,offset szname
	call	SaveWord1
	call	SkipSpc
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
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

SaveStructNest:
	push	ebx
	xor		ebx,ebx
	.while ebx<nnest
		.if lpname[ebx*4]
			mov		eax,lenname[ebx*4]
			invoke strcpyn,edi,lpname[ebx*4],addr [eax+1]
			add		edi,lenname[ebx*4]
			mov		byte ptr [edi],'.'
			inc		edi
		.endif
		inc		ebx
	.endw
	pop		ebx
	retn

SaveStructItems:
	xor		eax,eax
	xor		ecx,ecx
	mov		nnest,eax
	.while ecx<8
		mov		lenname[ecx*4],eax
		mov		lpname[ecx*4],eax
		inc		ecx
	.endw
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke SolIsWord,lpword1,len1,addr szsolinstruct
			.if eax
				.if eax==10
					; union, struc, struct
					call	GetWord
					.if ecx
						; named
						mov		edx,nnest
						mov		lenname[edx*4],ecx
						mov		lpname[edx*4],esi
						lea		esi,[esi+ecx]
					.endif
					inc		nnest
				.elseif eax==11
					; endu, ends
					dec		nnest
					.if SIGN?
						.break
					.endif
					mov		ecx,nnest
					mov		lenname[ecx*4],0
					mov		lpname[ecx*4],0
				.endif
			.else
				; struct item
				call	SaveStructNest
				; item name
				call	SaveWord1
				dec		edi
				call	GetWord
				mov		lendt,ecx
				mov		lpdt,esi
				lea		esi,[esi+ecx]
				invoke SolIsWord,lpdt,lendt,addr szsolinstructitem
				.if eax==10
					; item rs RECT,2
					call	GetWord
					mov		lendt,ecx
					mov		lpdt,esi
					lea		esi,[esi+ecx]
					call	SkipSpc
					.if byte ptr [esi]==','
						inc		esi
						call	GetWord
						mov		len1,ecx
						mov		lpword1,esi
						lea		esi,[esi+ecx]
						mov		byte ptr [edi],'['
						inc		edi
						call	SaveWord1
						mov		byte ptr [edi-1],']'
					.endif
					; item datatype
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.elseif eax==11
					; item RB 10
					call	GetWord
					mov		len1,ecx
					mov		lpword1,esi
					lea		esi,[esi+ecx]
					mov		byte ptr [edi],'['
					inc		edi
					call	SaveWord1
					mov		byte ptr [edi-1],']'
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.elseif !eax
					; item datatype ?
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.endif
			.endif
		.endif
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	retn

_Struct:
	mov		edi,offset szname
	call	SaveWord2
	call	SaveStructItems
	mov		edx,'s'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

_Macro:
	mov		edi,offset szname
	call	SaveWord2
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke SolIsWord,lpword1,len1,offset szsolinmacro
			.if eax
				.if eax==10
					; marg
					.while byte ptr [esi]
						call	GetWord
						.if ecx
							mov		len1,ecx
							mov		lpword1,esi
							lea		esi,[esi+ecx]
							call	SaveWord1
							dec		edi
						.elseif !byte ptr [esi] || byte ptr [esi]==VK_RETURN
							.break
						.else
							mov		al,[esi]
							mov		[edi],al
							inc		esi
							inc		edi
						.endif
					.endw
				.elseif eax==11
					; endm
					.break
				.endif
			.endif
		.endif
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	mov		edx,'m'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

_Data:
	push	eax
	mov		edi,offset szname
	call	SaveWord1
	dec		edi
	mov		eax,lpword2
	mov		lpdt,eax
	mov		eax,len2
	mov		lendt,eax
	pop		eax
	.if eax==10
		; data dd ?
		call	ConvDataType
		call	ArraySize
		.if byte ptr buff1[4096]
			mov		byte ptr [edi],'['
			inc		edi
			invoke strcpy,edi,addr buff1[4096]
			invoke strlen,edi
			lea		edi,[edi+eax]
			mov		byte ptr [edi],']'
			inc		edi
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		mov		eax,len2
		invoke strcpyn,edi,lpword2,addr [eax+1]
		add		edi,len2
	.elseif eax==11
		; data rb 10
		call	GetWord
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		mov		byte ptr [edi],'['
		inc		edi
		call	SaveWord1
		mov		byte ptr [edi-1],']'
		mov		byte ptr [edi],':'
		inc		edi
		call	ConvDataType
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		call	SaveWord2
		add		edi,len2
	.elseif eax==12
		; data rs RECT,10
		call	GetWord
		mov		lendt,ecx
		mov		lpdt,esi
		lea		esi,[esi+ecx]
		call	SkipSpc
		.if byte ptr [esi]==','
			inc		esi
			call	GetWord
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			mov		byte ptr [edi],'['
			inc		edi
			call	SaveWord1
			mov		byte ptr [edi-1],']'
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		call	ConvDataType
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		call	SaveWord2
		add		edi,len2
	.endif
	mov		byte ptr [edi],0
	mov		edx,'d'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

_Enum:
	mov		edi,offset szname
	call	SaveWord2
	mov		nenum,0
	call	SkipSpc
	.if byte ptr [esi]==','
		inc		esi
		call	GetWord
		.if ecx
			invoke AsciiToDw,esi
			mov		nenum,eax
		.endif
	.endif
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke SolIsWord,lpword1,len1,offset szsolinenum
			.if eax
				.if eax==10
					.break
				.endif
			.endif
			push	edi
			call	SaveWord1
			pop		eax
			invoke strcpy,offset buff1,eax
			invoke strlen,offset buff1
			lea		eax,buff1[eax+1]
			invoke DwToAscii,nenum,eax
			mov		edx,'c'
			invoke AddWordToWordList,edx,nOwner,nline,npos,addr buff1,2
			inc		nenum
		.endif
		mov		byte ptr [edi-1],','
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	mov		edx,'e'
	invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
	retn

SolParseFile endp
