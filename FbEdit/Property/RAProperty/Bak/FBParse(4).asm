
.code

FBDestroyString proc lpMem:DWORD,fKeepStrings:DWORD

	mov		eax,lpMem
	movzx	ecx,byte ptr [eax]
	inc		eax
	.while byte ptr [eax]!=0 && byte ptr [eax]!=0Dh
		mov		dx,[eax]
		.if dl==cl && dh==cl
			mov		byte ptr [eax],20h
			inc		eax
			mov		byte ptr [eax],20h
			inc		eax
		.else
			inc		eax
			.break .if dl==cl
			.if !fKeepStrings
				mov		byte ptr [eax-1],20h
			.endif
		.endif
	.endw
	ret

FBDestroyString endp

FBDestroyCmntBlock proc uses esi,lpMem:DWORD,fKeepStrings:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	fbyte:DWORD

	mov		fbyte,0
	mov		esi,lpMem
	invoke strcpy,addr buffer,addr [ebx].RAPROPERTY.defgen.szCmntBlockSt
	invoke strlen,addr buffer
	.if eax
		dec		eax
		.if byte ptr buffer[eax]=='+'
			mov		byte ptr buffer[eax],0
			.if byte ptr buffer[eax-1]==' '
				dec		eax
				mov		byte ptr buffer[eax],0
			.endif
			mov		fbyte,eax
		.endif
	  @@:
		.if word ptr buffer=="'/"
			.while byte ptr [esi]
				.if byte ptr [esi]=='"'
					invoke FBDestroyString,esi,fKeepStrings
					mov		esi,eax
				.elseif byte ptr [esi]=="'"
					invoke DestroyToEol,esi
					mov		esi,eax
				.elseif word ptr [esi]=="'/"
					invoke SearchMemDown,addr [esi+2],addr [ebx].RAPROPERTY.defgen.szCmntBlockEn,FALSE,FALSE,[ebx].RAPROPERTY.lpchartab
					.if eax
						mov		edx,eax
						.if [ebx].RAPROPERTY.defgen.szCmntBlockEn[1]
							inc		edx
						.endif
						.while esi<=edx
							mov		al,[esi]
							.if al!=0Dh && al!=0Ah
								mov		byte ptr [esi],' '
							.endif
							inc		esi
						.endw
					.else
						invoke DestroyToEof,esi
						mov		esi,eax
					.endif
				.else
					inc		esi
				.endif
			.endw
		.else
			invoke SearchMemDown,esi,addr buffer,FALSE,TRUE,[ebx].RAPROPERTY.lpchartab
			.if eax
				mov		esi,eax
				mov		ecx,dword ptr [ebx].RAPROPERTY.defgen.szCmntChar
				.while eax>lpMem
					.break .if byte ptr [eax-1]==0Dh || byte ptr [eax-1]==0Ah
					dec		eax
				.endw
				mov		ecx,dword ptr [ebx].RAPROPERTY.defgen.szString
				mov		edx,dword ptr [ebx].RAPROPERTY.defgen.szCmntChar
				.while eax<esi
					.if byte ptr [eax]==cl || byte ptr [eax]==ch
						;String
						invoke FBDestroyString,eax,fKeepStrings
						mov		esi,eax
						jmp		@b
					.elseif (byte ptr [eax]==dl && dh==0) || word ptr [eax]==dx
						;Comment
						invoke DestroyToEol,eax
						mov		esi,eax
						jmp		@b
					.endif
					inc		eax
				.endw
				.if fbyte
					add		esi,fbyte
					.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
						inc		esi
					.endw
					mov		ah,[esi]
					.if ah!=0Dh && ah!=0Ah
						mov		byte ptr [esi],' '
					.endif
					.while ah!=byte ptr [esi] && byte ptr [esi+1]
						mov		al,[esi]
						.if al!=0Dh && al!=0Ah
							mov		byte ptr [esi],' '
						.endif
						inc		esi
					.endw
					mov		al,[esi]
					.if al!=0Dh && al!=0Ah
						mov		byte ptr [esi],' '
						inc		esi
					.endif
					jmp		@b
				.else
					invoke SearchMemDown,esi,addr [ebx].RAPROPERTY.defgen.szCmntBlockEn,FALSE,TRUE,[ebx].RAPROPERTY.lpchartab
					.if eax
						mov		edx,eax
						.if [ebx].RAPROPERTY.defgen.szCmntBlockEn[1]
							inc		edx
						.endif
						.while esi<=edx
							mov		al,[esi]
							.if al!=0Dh && al!=0Ah
								mov		byte ptr [esi],' '
							.endif
							inc		esi
						.endw
						jmp		@b
					.endif
				.endif
			.endif
		.endif
	.endif
	ret

FBDestroyCmntBlock endp

FBDestroyCommentsStrings proc uses esi,lpMem:DWORD,fKeepStrings:DWORD

	mov		esi,lpMem
	mov		ecx,dword ptr [ebx].RAPROPERTY.defgen.szCmntChar
	mov		edx,dword ptr [ebx].RAPROPERTY.defgen.szString
	
	PrintHex cl
	PrintHex ch
	
	.while byte ptr [esi]
		.if (byte ptr [esi]==cl && ch==0)
			invoke DestroyToEol,esi
			mov		esi,eax
			;inc esi
		.elseif (byte ptr [esi]==cl && byte ptr [esi+1]==ch)
			invoke DestroyToEol,esi
			mov		esi,eax
			;inc esi 
		.elseif byte ptr [esi]==dl || byte ptr [esi]==dh
			push	ecx
			push	edx
			invoke FBDestroyString,esi,fKeepStrings             ; *** MOD TODO
			mov		esi,eax
			pop		edx
			pop		ecx
		.else
			inc		esi
		.endif
	.endw
	ret

FBDestroyCommentsStrings endp

FBPreParse proc lpMem:DWORD,fKeepStrings:DWORD             ; *** MOD FBPreParse proc uses esi,lpMem:DWORD,fKeepStrings:DWORD

	invoke FBDestroyCmntBlock,lpMem,fKeepStrings          ; *** MOD TODO
	invoke FBDestroyCommentsStrings,lpMem,fKeepStrings
	ret

FBPreParse endp

FBSkipLine proc uses esi,lpMem:DWORD,lpnpos:DWORD

	mov		eax,lpMem
	movzx	ecx,byte ptr [ebx].RAPROPERTY.defgen.szLineCont
	mov		esi,[ebx].RAPROPERTY.lpchartab
	.while byte ptr [eax] && byte ptr [eax]!=0Dh
		.if cl==byte ptr [eax] && byte ptr [eax+1]==0Dh
			.if cl=='_'
				movzx	edx,byte ptr [eax-1]
				.if byte ptr [esi+edx]==CT_CHAR
					inc eax
					.break
				.endif
			.endif
			mov		edx,lpnpos
			inc		dword ptr [edx]
			.if byte ptr [eax+2]==0Ah
				inc		eax
			.endif
			inc		eax
		.endif
		inc		eax
	.endw
	.if byte ptr [eax]==0Dh
		inc		eax
	.endif
	.if byte ptr [eax]==0Ah
		inc		eax
	.endif
	ret

FBSkipLine endp

FBGetWord proc uses esi,lpMem:DWORD,lpnpos:DWORD

	mov		edx,lpMem
	movzx	ecx,byte ptr [ebx].RAPROPERTY.defgen.szLineCont
	mov		esi,[ebx].RAPROPERTY.lpchartab
	.while byte ptr [edx]==VK_SPACE || byte ptr [edx]==VK_TAB || (cl==byte ptr [edx] && (byte ptr [edx+1]==VK_RETURN || byte ptr [edx+1]==VK_SPACE || byte ptr [edx+1]==VK_TAB))
		.if cl==byte ptr [edx]
			.while byte ptr [edx+1]==VK_SPACE || byte ptr [edx+1]==VK_TAB
				inc		edx
			.endw
			.break .if byte ptr [edx+1]!=VK_RETURN
			mov		eax,lpnpos
			inc		dword ptr [eax]
			.if byte ptr [edx+2]==0Ah
				inc		edx
			.endif
			inc		edx
		.endif
		inc		edx
	.endw
	xor		ecx,ecx
  @@:
	movzx	eax,byte ptr [edx+ecx]
	.if byte ptr [esi+eax]==CT_CHAR || eax=='.'
		inc		ecx
		jmp		@b
	.endif
	ret

FBGetWord endp

FBGetWordSkip proc uses esi,lpMem:DWORD,lpnpos:DWORD

	mov		edx,lpMem
	movzx	ecx,byte ptr [ebx].RAPROPERTY.defgen.szLineCont
	.while byte ptr [edx]==VK_SPACE || byte ptr [edx]==VK_TAB || (cl==byte ptr [edx] && byte ptr [edx+1]==0Dh)
		.if cl==byte ptr [edx]
			mov		eax,lpnpos
			inc		dword ptr [eax]
			.if byte ptr [edx+2]==0Ah
				inc		edx
			.endif
			inc		edx
		.endif
		inc		edx
	.endw
	xor		ecx,ecx
	mov		esi,[ebx].RAPROPERTY.lpchartab
  @@:
	movzx	eax,byte ptr [edx+ecx]
	.if byte ptr [esi+eax]==CT_CHAR || eax=='.'
		inc		ecx
		jmp		@b
	.elseif eax=='('
		.while byte ptr [edx+ecx] && byte ptr [edx+ecx]!=0Dh && byte ptr [edx+ecx]!=')'
			inc		ecx
		.endw
		.if byte ptr [edx+ecx]==')'
			inc		ecx
		.endif
		jmp		@b
	.endif
	ret

FBGetWordSkip endp

FBWhatIsIt proc uses esi,lpWord1:DWORD,len1:DWORD,lpWord2:DWORD,len2:DWORD

	mov		esi,[ebx].RAPROPERTY.lpdeftype
  @@:
	movzx	eax,[esi].DEFTYPE.nType
	.if eax
		movzx	ecx,[esi].DEFTYPE.len
		.if eax==TYPE_NAMEFIRST
			.if ecx==len2
				invoke Compare,lpWord2,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
		.elseif eax==TYPE_OPTNAMEFIRST
			.if ecx==len2
				invoke Compare,lpWord2,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
			.if ecx==len1
				invoke Compare,lpWord1,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
		.elseif eax==TYPE_NAMESECOND
			.if ecx==len1 && len2!=0
				invoke Compare,lpWord1,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
		.elseif eax==TYPE_OPTNAMESECOND
			.if ecx==len1
				invoke Compare,lpWord1,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
		.elseif eax==TYPE_TWOWORDS
			.if ecx==len1
				invoke Compare,lpWord1,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				.if ZERO?
					mov		eax,ecx
					movzx	ecx,[esi+eax].DEFTYPE.szWord
					.if ecx==len2
						invoke Compare,lpWord2,addr [esi+eax+1].DEFTYPE.szWord,ecx
						or		eax,eax
						je		Ex
					.endif
				.endif
			.endif
		.elseif eax==TYPE_ONEWORD
			.if ecx==len1
				invoke Compare,lpWord1,addr [esi].DEFTYPE.szWord,ecx
				or		eax,eax
				je		Ex
			.endif
		.endif
		add		esi,sizeof DEFTYPE
		jmp		@b
	.endif
	ret
  Ex:
	mov		eax,esi
	ret

FBWhatIsIt endp

FBIsIgnore proc uses ecx esi,nType:DWORD,len:DWORD,lpWord:DWORD

	mov		esi,[ebx].RAPROPERTY.lpignore
	.if esi
	  @@:
		mov		al,byte ptr nType
		mov		ah,byte ptr len
		.if ax==word ptr [esi]
			invoke Compare,addr [esi+2],lpWord,len
			.if eax
				movzx	eax,byte ptr [esi+1]
				lea		esi,[esi+eax+3]
				jmp		@b
			.endif
			inc		eax
			jmp		Ex
		.elseif word ptr [esi]
			movzx	eax,byte ptr [esi+1]
			lea		esi,[esi+eax+3]
			jmp		@b
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

FBIsIgnore endp

FBIsFunction proc uses esi ecx,lpWord:DWORD,len:DWORD
	
	xor		eax,eax
	inc		eax
	.if len==3
		invoke Compare,offset szSub,lpWord,len
	.elseif len==8
		invoke Compare,offset szFunction,lpWord,len
	.endif
	ret

FBIsFunction endp

FBParseFile proc uses ebx esi edi,nOwner:DWORD,lpMem:DWORD
	LOCAL	lpword1:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpword2:DWORD
	LOCAL	len2:DWORD
	LOCAL	lpdef:DWORD
	LOCAL	npos:DWORD
	LOCAL	nline:DWORD
	LOCAL	lpdatatype:DWORD
	LOCAL	lendatatype:DWORD
	LOCAL	lpdatatype2:DWORD
	LOCAL	lendatatype2:DWORD
	LOCAL	rpnmespc[4]:DWORD
	LOCAL	rpwithblock[4]:DWORD
	LOCAL	nNest:DWORD
	LOCAL	fPtr:DWORD
	LOCAL	fRetType:DWORD
	LOCAL	fParam:DWORD
	LOCAL	endtype:DWORD
	LOCAL	fdim:DWORD
	LOCAL	narray:DWORD

	mov		npos,0
	mov		rpnmespc[0],-1
	mov		rpnmespc[4],-1
	mov		rpnmespc[8],-1
	mov		rpnmespc[12],-1
	mov		rpwithblock[0],-1
	mov		rpwithblock[4],-1
	mov		rpwithblock[8],-1
	mov		rpwithblock[12],-1
	mov		esi,lpMem
	.while byte ptr [esi]
		mov		eax,npos
		mov		nline,eax
		mov		fPtr,0
		mov		fRetType,0
		mov		fParam,0
		mov		fdim,0
		mov		lpdatatype,0
		mov		lpdatatype2,0
	  Nxtwrd:
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			invoke FBIsIgnore,IGNORE_LINEFIRSTWORD,ecx,esi
			.if eax
				jmp		Nxt
			.endif
			invoke FBIsIgnore,IGNORE_FIRSTWORD,ecx,esi
			.if eax
				lea		esi,[esi+ecx]
				jmp		Nxtwrd
			.endif
			invoke FBIsIgnore,IGNORE_FIRSTWORDTWOWORDS,ecx,esi
			.if eax
				lea		esi,[esi+ecx]
				invoke FBGetWord,esi,addr npos
				mov		esi,edx
				lea		esi,[esi+ecx]
				jmp		Nxtwrd
			.endif
			mov		lpword1,esi
			mov		len1,ecx
			lea		esi,[esi+ecx]
			mov		lpdatatype,0
			mov		lpdatatype2,0
			mov		fPtr,0
		  Nxtwrd1:
			invoke FBGetWord,esi,addr npos
			mov		esi,edx
			.if ecx
				invoke FBIsIgnore,IGNORE_LINESECONDWORD,ecx,esi
				.if eax
					jmp		Nxt
				.endif
				invoke FBIsIgnore,IGNORE_SECONDWORD,ecx,esi
				.if eax
					lea		esi,[esi+ecx]
					jmp		Nxtwrd1
				.endif
				invoke FBIsIgnore,IGNORE_PTR,ecx,esi
				.if eax
					lea		esi,[esi+ecx]
					inc		fPtr
					jmp		Nxtwrd1
				.endif
				invoke FBIsIgnore,IGNORE_SECONDWORDTWOWORDS,ecx,esi
				.if eax
					lea		esi,[esi+ecx]
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					lea		esi,[esi+ecx]
					jmp		Nxtwrd1
				.endif
				invoke FBIsIgnore,IGNORE_DATATYPEINIT,ecx,esi
				.if eax
					lea		esi,[esi+ecx]
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					mov		lpdatatype,esi
					mov		lendatatype,ecx
					lea		esi,[esi+ecx]
					jmp		Nxtwrd1
				.endif
			.elseif byte ptr [esi]=='*'
				inc		esi
				invoke FBGetWord,esi,addr npos
				mov		esi,edx
				lea		esi,[esi+ecx]
				jmp		Nxtwrd1
			.elseif byte ptr [esi]==':'
				inc		ecx
			.endif
			mov		lpword2,esi
			mov		len2,ecx
			lea		esi,[esi+ecx]
		  dim:
			invoke FBWhatIsIt,lpword1,len1,lpword2,len2
			.if eax
				mov		lpdef,eax
				movzx	edx,[eax].DEFTYPE.nDefType
				movzx	eax,[eax].DEFTYPE.nType
				mov		edi,offset szname
				.if edx==DEFTYPE_PROC
					mov		endtype,DEFTYPE_ENDPROC
					call	ParseProc
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
					.endif
				.elseif edx==DEFTYPE_FUNCTION
					mov		endtype,DEFTYPE_ENDFUNCTION
					call	ParseFunction
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
						invoke strlen,addr szname
						invoke strcpy,addr szname[eax+1],edi
						mov		edx,'f'
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
					.endif
				.elseif edx==DEFTYPE_LABEL
					call	ParseLabel
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,1
					.endif
				.elseif edx==DEFTYPE_MACRO
					call	ParseMacro
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
					.endif
				.elseif edx==DEFTYPE_CONSTRUCTOR
					mov		endtype,DEFTYPE_ENDCONSTRUCTOR
					call	ParseConstructor
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
					.endif
				.elseif edx==DEFTYPE_DESTRUCTOR
					mov		endtype,DEFTYPE_ENDDESTRUCTOR
					call	ParseDestructor
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
					.endif
				.elseif edx==DEFTYPE_PROPERTY
					mov		endtype,DEFTYPE_ENDPROPERTY
					call	ParseProperty
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
					.endif
				.elseif edx==DEFTYPE_OPERATOR
					mov		endtype,DEFTYPE_ENDOPERATOR
					call	ParseOperator
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
					.endif
				.elseif edx==DEFTYPE_DATA
					call	ParseData
					.if eax
						.if lpdatatype
							invoke FBIsFunction,lpdatatype,lendatatype
							.if !eax
								mov		eax,lpdatatype
								mov		lpword1,eax
								mov		eax,lendatatype
								mov		len1,eax
								inc		fdim
								jmp		dim
							.endif
						.endif
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
						call	SkipToComma
						.if byte ptr [esi]=='='
							inc		esi
							call	SkipToComma
						.endif
						.if byte ptr [esi]==','
							inc		esi
							jmp		Nxtwrd1
						.endif
					.endif
				.elseif edx==DEFTYPE_CONST
					call	ParseConst
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
					.endif
					call	SkipToComma
					.if byte ptr [esi]==','
						inc		esi
						jmp		Nxtwrd1
					.elseif byte ptr [esi]=='='
						inc		esi
						call	SkipToComma
						.if byte ptr [esi]==','
							inc		esi
							jmp		Nxtwrd1
						.endif
					.endif
				.elseif edx==DEFTYPE_STRUCT
					call	ParseStruct
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
					.endif
				.elseif edx==DEFTYPE_TYPE
				.elseif edx==DEFTYPE_NAMESPACE
					call	ParseNameSpace
					.if eax
						mov		eax,[ebx].RAPROPERTY.rpfree
						push	ebx
						xor		ebx,ebx
						.while rpnmespc[ebx*4]!=-1
							inc		ebx
						.endw
						.if ebx<=3
							mov		rpnmespc[ebx*4],eax
						.endif
						pop		ebx
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,-1,addr szname,1
					.endif
				.elseif edx==DEFTYPE_ENDNAMESPACE
					.if rpnmespc!=-1
						.if rpnmespc[0]!=-1
							mov		edx,[ebx].RAPROPERTY.lpmem
							push	ebx
							mov		ebx,3
							.while rpnmespc[ebx*4]==-1
								dec		ebx
							.endw
							add		edx,rpnmespc[ebx*4]
							mov		rpnmespc[ebx*4],-1
							pop		ebx
							mov		eax,npos
							mov		[edx].PROPERTIES.nEnd,eax
						.endif
					.endif
				.elseif edx==DEFTYPE_ENUM
					call	ParseEnum
					.if eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,2
					.endif
				.elseif edx==DEFTYPE_WITHBLOCK
					push	eax
					mov		esi,lpword2
					invoke FBGetWordSkip,esi,addr npos
					mov		esi,edx
					mov		lpword2,esi
					mov		len2,ecx
					lea		esi,[esi+ecx]
					pop		eax
					call	ParseWithBlock
					.if eax
						mov		eax,rpwithblock[8]
						mov		rpwithblock[12],eax
						mov		eax,rpwithblock[4]
						mov		rpwithblock[8],eax
						mov		eax,rpwithblock[0]
						mov		rpwithblock[4],eax
						mov		eax,[ebx].RAPROPERTY.rpfree
						mov		rpwithblock,eax
						mov		edx,lpdef
						movzx	edx,[edx].DEFTYPE.Def
						invoke AddWordToWordList,edx,nOwner,nline,-1,addr szname,1
					.endif
				.elseif edx==DEFTYPE_ENDWITHBLOCK
					.if rpwithblock!=-1
						mov		edx,[ebx].RAPROPERTY.lpmem
						add		edx,rpwithblock
						mov		eax,npos
						mov		[edx].PROPERTIES.nEnd,eax
						mov		eax,rpwithblock[4]
						mov		rpwithblock[0],eax
						mov		eax,rpwithblock[8]
						mov		rpwithblock[4],eax
						mov		eax,rpwithblock[12]
						mov		rpwithblock[8],eax
						mov		rpwithblock[12],-1
					.endif
				.elseif edx==DEFTYPE_IGNORE
					mov		endtype,DEFTYPE_ENDIGNORE
					call	ParseIgnore
;					.if eax
;						mov		edx,lpdef
;						movzx	edx,[edx].DEFTYPE.Def
;						invoke AddWordToWordList,edx,nOwner,nline,npos,addr szname,4
;					.endif
				.endif
			.endif
		.endif
	  Nxt:
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
	.endw
	ret

AddNamespace:
	push	eax
	push	esi
	xor		esi,esi
	.while esi<4
		.break .if rpnmespc[esi*4]==-1
		mov		edx,[ebx].RAPROPERTY.lpmem
		add		edx,rpnmespc[esi*4]
		invoke strcpy,edi,addr [edx+sizeof PROPERTIES]
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		word ptr [edi],'.'
		inc		edi
		inc		esi
	.endw
	pop		esi
	pop		eax
	retn

SaveName:
	mov		edx,edi
	.if eax==TYPE_NAMEFIRST
		mov		eax,len1
		inc		eax
		lea		edi,[edx+eax]
		invoke strcpyn,edx,lpword1,eax
	.elseif eax==TYPE_NAMESECOND || eax==TYPE_OPTNAMESECOND
		mov		eax,len2
		inc		eax
		lea		edi,[edx+eax]
		invoke strcpyn,edx,lpword2,eax
	.endif
	retn

SkipBrace:
	xor		eax,eax
	dec		eax
SkipBrace1:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
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

SkipToComma:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.while byte ptr [esi] && byte ptr [esi]!=0Dh && byte ptr [esi]!=',' && byte ptr [esi]!='='
		call	SkipBrace
		.if byte ptr [esi] && byte ptr [esi]!=0Dh && byte ptr [esi]!=',' && byte ptr [esi]!='='
			inc		esi
		.endif
	.endw
	retn

SkipSpc:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	retn

ParseWithBlock:
	call	SaveName
	xor		eax,eax
	inc		eax
	retn

ParseEnum:
	call	AddNamespace
	call	SaveName
	.while byte ptr [esi]
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			mov		lpword1,esi
			mov		len1,ecx
			lea		esi,[esi+ecx]
			invoke FBGetWord,esi,addr npos
			mov		esi,edx
			.if ecx
				mov		lpword2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				invoke FBWhatIsIt,lpword1,len1,lpword2,len2
				.if eax
					movzx	eax,[eax].DEFTYPE.nDefType
					.if eax==DEFTYPE_ENDENUM
						mov		byte ptr [edi],0
						retn
					.endif
				.endif
			.endif
			.if byte ptr [edi]==','
				inc		edi
			.endif
			mov		eax,len1
			inc		eax
			invoke strcpyn,edi,lpword1,eax
			add		edi,len1
			mov		word ptr [edi],','
		.endif
	.endw
	xor		eax,eax
	retn

ParseNameSpace:
	call	SaveName
	xor		eax,eax
	inc		eax
	retn

ParseMacro:
	call	AddNamespace
	call	SaveName
  @@:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if !ecx
		.if byte ptr [esi]==',' || byte ptr [esi]=='('
			inc		esi
			jmp		@b
		.endif
	.else
		mov		lpword1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		mov		edx,edi
		mov		eax,len1
		inc		eax
		lea		edi,[edx+eax]
		invoke strcpyn,edx,lpword1,eax
		mov		byte ptr [edi],','
		inc		edi
		call	SkipToComma
		.if byte ptr [esi]==','
			inc		esi
			jmp		@b
		.endif
	.endif
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		word ptr [edi],0
	.while byte ptr [esi]
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			mov		lpword1,esi
			mov		len1,ecx
			mov		lpword2,esi
			mov		len2,ecx
			lea		esi,[esi+ecx]
			invoke FBWhatIsIt,lpword1,len1,lpword2,len2
			.if eax
				movzx	eax,[eax].DEFTYPE.nDefType
				.if eax==DEFTYPE_ENDMACRO
					retn
				.endif
			.endif
		.endif
	.endw
	xor		eax,eax
	retn

ParseConstructor:
	call	AddNamespace
	call	SaveName
	call	SaveParam
	call	SaveRetType
	call	SaveLocal
	retn

ParseDestructor:
	call	AddNamespace
	call	SaveName
	call	SaveParam
	call	SaveRetType
	call	SaveLocal
	retn

ParseProperty:
	call	AddNamespace
	call	SaveName
	call	SaveParam
	call	SaveRetType
	call	SaveLocal
	retn

ParseOperator:
	call	AddNamespace
	mov		edx,edi
	.if eax==TYPE_NAMEFIRST
		mov		eax,len1
		inc		eax
		lea		edi,[edx+eax]
		invoke strcpyn,edx,lpword1,eax
	.elseif eax==TYPE_NAMESECOND
		mov		eax,len2
		inc		eax
		lea		edi,[edx+eax]
		invoke strcpyn,edx,lpword2,eax
	.elseif eax==TYPE_OPTNAMESECOND
		mov		edx,lpword2
	  @@:
		mov		al,[edx]
		.if al!=0 && al!=VK_SPACE && al!=VK_TAB && al!=VK_RETURN && al !='('
			mov		[edi],al
			inc		edx
			inc		edi
			jmp		@b
		.endif
		mov		byte ptr [edi],0
		inc		edi
		mov		esi,edx
	.endif
	call	SaveParam
	call	SaveRetType
	call	SaveLocal
	retn

ParseProc:
	call	AddNamespace
ParseProcNoNamespace:
	call	SaveName
	call	SaveParam
	call	SaveRetType
	.if fdim
		xor		eax,eax
		inc		eax
	.else
		call	SaveLocal
	.endif
	retn

ParseFunction:
	call	AddNamespace
ParseFunctionNoNamespace:
	call	SaveName
	call	SaveParam
	push	edi
	call	SaveRetType
	.if fdim
		xor		eax,eax
		inc		eax
	.else
		call	SaveLocal
	.endif
	pop		edi
	retn

ParseLabel:
	call	SaveName
	xor		eax,eax
	inc		eax
	retn

NxtWordProc:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if ecx
		mov		lpword2,esi
		mov		len2,ecx
		lea		esi,[esi+ecx]
		invoke FBIsIgnore,IGNORE_PTR,len2,lpword2
		.if eax
			inc		fPtr
			jmp		NxtWordProc
		.endif
		invoke FBWhatIsIt,lpword1,len1,lpword2,len2
		.if eax
			movzx	edx,[eax].DEFTYPE.nDefType
			.if edx==endtype
				.if byte ptr [edi-1]==','
					dec		edi
				.endif
				mov		byte ptr [edi],0
				xor		eax,eax
				inc		eax
				retn
			.elseif edx==DEFTYPE_DATA
				push	eax
				invoke FBIsIgnore,IGNORE_DATATYPEINIT,len2,lpword2
				.if eax
					pop		eax
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					mov		lpdatatype,esi
					mov		lendatatype,ecx
					lea		esi,[esi+ecx]
					jmp		NxtWordProc
				.endif
				pop		eax
				movzx	edx,[eax].DEFTYPE.nDefType
				movzx	eax,[eax].DEFTYPE.nType
				call	ParseParamData
				mov		byte ptr [edi],','
				inc		edi
				call	SkipToComma
				.if byte ptr [esi]==','
					inc		esi
					jmp		NxtWordProc
				.endif
				mov		lpdatatype,0
				mov		lpdatatype2,0
			.elseif edx==DEFTYPE_WITHBLOCK
				push	eax
				push	edi
				movzx	eax,[eax].DEFTYPE.nType
				call	ParseWithBlock
				pop		edi
				pop		edx
				.if eax
					movzx	ecx,[edx].DEFTYPE.Def
					mov		eax,rpwithblock[8]
					mov		rpwithblock[12],eax
					mov		eax,rpwithblock[4]
					mov		rpwithblock[8],eax
					mov		eax,rpwithblock[0]
					mov		rpwithblock[4],eax
					mov		eax,[ebx].RAPROPERTY.rpfree
					mov		rpwithblock,eax
					invoke AddWordToWordList,ecx,nOwner,npos,-1,edi,1
				.endif
			.elseif edx==DEFTYPE_ENDWITHBLOCK
				.if rpwithblock!=-1
					mov		edx,[ebx].RAPROPERTY.lpmem
					add		edx,rpwithblock
					mov		eax,npos
					mov		[edx].PROPERTIES.nEnd,eax
					mov		eax,rpwithblock[4]
					mov		rpwithblock[0],eax
					mov		eax,rpwithblock[8]
					mov		rpwithblock[4],eax
					mov		eax,rpwithblock[12]
					mov		rpwithblock[8],eax
					mov		rpwithblock[12],-1
				.endif
			.endif
		.endif
	.elseif byte ptr [esi]=='*'
		inc		esi
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		lea		esi,[esi+ecx]
		jmp		NxtWordProc
	.endif
	xor		eax,eax
	retn

SaveParam:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if ecx
		invoke FBIsIgnore,IGNORE_PROCPARAM,ecx,esi
		.if eax
			lea		esi,[esi+ecx]
			jmp		SaveParam
		.endif
	.else
		.if byte ptr [esi]=='"'
			inc		esi
			.while byte ptr [esi]!='"' && byte ptr [esi]!=VK_RETURN
				inc		esi
			.endw
			.if byte ptr [esi]=='"'
				inc		esi
				jmp		SaveParam
			.endif
		.endif
	.endif
SaveParam1:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if !ecx
		.if byte ptr [esi]==',' || byte ptr [esi]=='('
			inc		esi
			inc		fParam
			jmp		SaveParam1
		.elseif byte ptr [esi]==')'
			inc		esi
		.elseif byte ptr [esi]!=VK_RETURN
			inc		esi
			jmp		SaveParam1
		.endif
	.else
		.if fParam
			invoke FBIsIgnore,IGNORE_PROCPARAM,ecx,esi
			.if eax
				lea		esi,[esi+ecx]
				jmp		SaveParam1
			.endif
			mov		lpword1,esi
			mov		len1,ecx
			lea		esi,[esi+ecx]
			mov		eax,TYPE_NAMEFIRST
			call	ParseParamData
			mov		byte ptr [edi],','
			inc		edi
			call	SkipSpc
			.if byte ptr [esi]==')'
				inc		esi
			.else
				call	SkipToComma
				.if byte ptr [esi]==','
					inc		esi
					jmp		SaveParam1
				.elseif byte ptr [esi]=='='
				  @@:
					inc		esi
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					.if byte ptr [esi]=='-' || byte ptr [esi]=='+' || byte ptr [esi]=='&'
						jmp		@b
					.endif
					lea		esi,[esi+ecx]
					jmp		SaveParam1
				.endif
			.endif
		.endif
	.endif
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		dword ptr [edi],0
	inc		edi
	retn

SaveRetType:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if ecx
		invoke FBIsIgnore,IGNORE_DATATYPEINIT,ecx,esi
		.if eax
			lea		esi,[esi+ecx]
		.endif
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			mov		word ptr [edi-1],0
			mov		edx,edi
			lea		edi,[edi+ecx]
			mov		eax,esi
			lea		esi,[esi+ecx]
			inc		ecx
			invoke strcpyn,edx,eax,ecx
			inc		fRetType
		  @@:
			invoke FBGetWord,esi,addr npos
			mov		esi,edx
			invoke FBIsIgnore,IGNORE_PTR,ecx,esi
			.if eax
				lea		esi,[esi+ecx]
				invoke strcpyn,edi,addr szPtr,5
				lea		edi,[edi+4]
				jmp		@b
			.endif
		.endif
	.endif
	mov		dword ptr [edi],0
	inc		edi
	retn

SaveLocal:
	.while byte ptr [esi]
		mov		fPtr,0
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			mov		lpword1,esi
			mov		len1,ecx
			lea		esi,[esi+ecx]
			call	NxtWordProc
			.if eax
				retn
			.endif
		.endif
	.endw
	xor		eax,eax
	retn

ParseData:
	call	AddNamespace
	call	SaveName
ParseData1:
	call	SkipSpc
	.if byte ptr [esi]=='('
		call	SkipBrace
	.endif
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	invoke FBIsIgnore,IGNORE_DATATYPEINIT,ecx,esi
	.if eax
		mov		fPtr,0
		lea		esi,[esi+ecx]
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		mov		lpdatatype,esi
		mov		lendatatype,ecx
		lea		esi,[esi+ecx]
	  @@:
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		invoke FBIsIgnore,IGNORE_PTR,ecx,esi
		.if eax
			lea		esi,[esi+ecx]
			inc		fPtr
			jmp		@b
		.endif
	.endif
	.if lpdatatype
		mov		eax,lendatatype
		inc		eax
		invoke strcpyn,edi,lpdatatype,eax
		add		edi,lendatatype
		.while fPtr
			invoke strcpyn,edi,addr szPtr,5
			lea		edi,[edi+4]
			dec		fPtr
		.endw
	.else
		invoke strcpy,edi,addr szInteger
		lea		edi,[edi+sizeof szInteger]
	.endif
	mov		byte ptr [edi],0
	xor		eax,eax
	inc		eax
	retn

ParseParamData:
	call	SaveName
	dec		edi
ParseParamData1:
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if !ecx
		.if byte ptr [esi]=='('
			call	SkipBrace
			jmp		ParseParamData1
		.elseif byte ptr [esi]=='['
			call	SkipBrace
			jmp		ParseParamData1
		.endif
	.endif
	invoke FBIsIgnore,IGNORE_DATATYPEINIT,ecx,esi
	.if eax
	  @@:
		lea		esi,[esi+ecx]
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		invoke FBIsIgnore,IGNORE_DATATYPE,ecx,esi
		.if eax
			jmp		@b
		.endif
		mov		lpdatatype,esi
		mov		lendatatype,ecx
		lea		esi,[esi+ecx]
	  @@:
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		invoke FBIsIgnore,IGNORE_PTR,ecx,esi
		.if eax
			lea		esi,[esi+ecx]
			inc		fPtr
			jmp		@b
		.endif
		.if !ecx
			.if byte ptr [esi]=="="
				inc		esi
				invoke FBGetWord,esi,addr npos
				mov		esi,edx
				.if ecx
					mov		lpdatatype2,esi
					mov		lendatatype2,ecx
					lea		esi,[esi+ecx]
				.elseif byte ptr [esi]=='-' || byte ptr [esi]=='+' || byte ptr [esi]=='&'
					mov		lpdatatype2,esi
					inc		esi
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					lea		esi,[esi+ecx]
					mov		eax,esi
					sub		eax,lpdatatype2
					mov		lendatatype2,eax
				.endif
			.endif
		.endif
	.endif
	.if lpdatatype
		mov		byte ptr [edi],':'
		inc		edi
		mov		edx,edi
		mov		eax,lendatatype
		lea		edi,[edi+eax]
		inc		eax
		invoke strcpyn,edx,lpdatatype,eax
		.if lpdatatype2
			mov		byte ptr [edi],'['
			inc		edi
			mov		edx,edi
			mov		eax,lendatatype2
			lea		edi,[edi+eax]
			inc		eax
			invoke strcpyn,edx,lpdatatype2,eax
			mov		byte ptr [edi],']'
			inc		edi
			mov		lpdatatype2,0
		.endif
	.else
		mov		byte ptr [edi],':'
		inc		edi
		invoke strcpy,edi,addr szInteger
		lea		edi,[edi+sizeof szInteger-1]
	.endif
	.while fPtr
		invoke strcpyn,edi,addr szPtr,5
		lea		edi,[edi+4]
		dec		fPtr
	.endw
	mov		byte ptr [edi],0
	xor		eax,eax
	inc		eax
	retn

ParseConst:
	call	AddNamespace
	call	SaveName
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if ecx
		mov		lpword2,esi
		mov		len2,ecx
		invoke FBIsIgnore,IGNORE_CONSTANT,ecx,esi
		.if eax
			lea		esi,[esi+ecx]
			invoke FBGetWord,esi,addr npos
			mov		esi,edx
		.endif
		.while TRUE
			mov		al,[esi]
			.if !al || al==VK_RETURN
				.break
			.elseif al==VK_TAB
				mov		al,' '
			.endif
			mov		ah,[edi-1]
			.if al==' ' || al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')'
				.if ah==' '
					dec		edi
				.endif
			.endif
			.if al==' '
				.if ah=='+' || ah=='-' || ah=='*' || ah=='/' || ah=='(' || ah==')'
					mov		al,ah
					dec		edi
				.endif
			.endif
			mov		[edi],al
			inc		edi
			inc		esi
		.endw
	.endif
	.if byte ptr [edi-1]==' '
		dec		edi
	.endif
	mov		byte ptr [edi],0
	xor		eax,eax
	inc		eax
	retn

ParseStruct:
	mov		byte ptr szstructnest,0
	mov		nNest,1
	call	AddNamespace
	call	SaveName
	invoke FBGetWord,esi,addr npos
	mov		esi,edx
	.if ecx
		invoke FBIsIgnore,IGNORE_STRUCTTHIRDWORD,ecx,esi
		.if eax
			xor		eax,eax
			retn
		.endif
	.endif
	mov		byte ptr [edi],0
	.while byte ptr [esi]
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
	  ParseStruct1:
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			invoke FBIsIgnore,IGNORE_STRUCTLINEFIRSTWORD,ecx,esi
			.if !eax
				invoke FBIsIgnore,IGNORE_STRUCTITEMFIRSTWORD,ecx,esi
				.if eax
					; As Integer x
					lea		esi,[esi+ecx]
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					mov		lpword2,esi
					mov		len2,ecx
					lea		esi,[esi+ecx]
				  @@:
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					.if !ecx
						.if byte ptr [esi]=='*'
							inc		esi
							invoke FBGetWord,esi,addr npos
							mov		esi,edx
							lea		esi,[esi+ecx]
							jmp		@b
						.endif
					.endif
					invoke FBIsIgnore,IGNORE_PTR,ecx,esi
					.if eax
						; ptr
						inc		fPtr
						lea		esi,[esi+ecx]
						jmp		@b
					.endif
					mov		lpword1,esi
					mov		len1,ecx
					lea		esi,[esi+ecx]
					jmp		ParseStruct3
				.endif
				invoke FBIsIgnore,IGNORE_STRUCTITEMINIT,ecx,esi
				.if eax
					; Declare Sub MySub()
					; Declare Function MyFunction() As Integer
					lea		esi,[esi+ecx]
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					invoke FBIsIgnore,IGNORE_STRUCTITEMINIT,ecx,esi
					.if eax
						lea		esi,[esi+ecx]
						invoke FBGetWord,esi,addr npos
						mov		esi,edx
					.endif
					mov		lpword2,esi
					mov		len2,ecx
					lea		esi,[esi+ecx]
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					mov		lpword1,esi
					xor		ecx,ecx
					.while byte ptr [esi]!=VK_SPACE && byte ptr [esi]!=VK_TAB && byte ptr [esi]!=VK_RETURN && byte ptr [esi]!='('
						inc		esi
						inc		ecx
					.endw
					mov		len1,ecx
					jmp		ParseStruct3
				.else
					mov		lpword1,esi
					mov		len1,ecx
					lea		esi,[esi+ecx]
				.endif
			  ParseStruct2:
				invoke FBGetWord,esi,addr npos
				mov		esi,edx
				.if byte ptr [esi]=='('
					; MyItem(0 To 7) As Integer
					.while byte ptr [esi] && byte ptr [esi]!=0Dh && byte ptr [esi]!=')'
						inc		esi
					.endw
					.if byte ptr [esi]==')'
						inc		esi
					.endif
					jmp		ParseStruct2
				.elseif byte ptr [esi]==':'
					inc		esi
					invoke FBGetWord,esi,addr npos
					mov		esi,edx
					lea		esi,[esi+ecx]
					jmp		ParseStruct2
				.endif
				.if ecx
					invoke FBIsIgnore,IGNORE_STRUCTITEMSECONDWORD,ecx,esi
					.if eax
						; As Integer
						lea		esi,[esi+ecx]
						invoke FBGetWord,esi,addr npos
						mov		esi,edx
						mov		lpword2,esi
						mov		len2,ecx
						lea		esi,[esi+ecx]
					  @@:
						invoke FBGetWord,esi,addr npos
						mov		esi,edx
						invoke FBIsIgnore,IGNORE_PTR,ecx,esi
						.if eax
							; ptr
							inc		fPtr
							lea		esi,[esi+ecx]
							jmp		@b
						.endif
						jmp		ParseStruct3
					.endif
				.endif
				mov		lpword2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				invoke FBWhatIsIt,lpword1,len1,lpword2,len2
				.if eax
					movzx	eax,[eax].DEFTYPE.nDefType
					.if eax==DEFTYPE_ENDSTRUCT
						mov		byte ptr szstructnest,0
						dec		nNest
						.if ZERO?
							mov		byte ptr [edi],0
							retn
						.endif
					.elseif eax==DEFTYPE_STRUCT
						.if len2!=0 && [ebx].RAPROPERTY.nlanguage==nMASM
							mov		eax,len2
							inc		eax
							invoke strcpyn,offset szstructnest,lpword2,eax
							invoke strcat,offset szstructnest,offset szDot
						.else
							mov		byte ptr szstructnest,0
						.endif
						inc		nNest
					.endif
				.else
		  		  ParseStruct3:
					.if byte ptr [edi]==','
						inc		edi
					.endif
					invoke FBIsFunction,lpword2,len2
					.if !eax
						inc		fdim
						mov		fRetType,0
						add		edi,32
						push	edi
						mov		eax,TYPE_NAMEFIRST
						call	ParseProcNoNamespace
						pop		edi
						mov		edx,'t'
						invoke AddWordToWordList,edx,nOwner,nline,npos,edi,4
						push	ebx
						lea		ebx,[edi-32]
						invoke strcpy,ebx,edi
						invoke strlen,edi
						lea		edi,[edi+eax+1]
						lea		ebx,[ebx+eax]
						.if byte ptr [edi]
;							mov		byte ptr [ebx],'('
;							inc		ebx
;							invoke strcpy,ebx,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
;							lea		ebx,[ebx+eax]
;							mov		byte ptr [ebx],')'
;							inc		ebx
						.else
							inc		edi
						.endif
						mov		byte ptr [ebx],':'
						inc		ebx
						.if fRetType
							invoke strcpy,ebx,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
							lea		ebx,[ebx+eax]
						.else
							mov		eax,len2
							inc		eax
							invoke strcpyn,ebx,lpword2,eax
							add		ebx,len2
						.endif
						mov		edi,ebx
						pop		ebx
					.else
						mov		eax,len1
						inc		eax
						invoke strcpyn,edi,lpword1,eax
						add		edi,len1
						mov		word ptr [edi],':'
						inc		edi
						mov		eax,len2
						inc		eax
						invoke strcpyn,edi,lpword2,eax
						add		edi,len2
						.while fPtr
							invoke strcpyn,edi,addr szPtr,5
							lea		edi,[edi+4]
							dec		fPtr
						.endw
					.endif
					mov		word ptr [edi],','
					call	SkipToComma
					.if byte ptr [esi]==','
						inc		esi
						invoke FBGetWord,esi,addr npos
						mov		esi,edx
						.if ecx
							mov		lpword1,esi
							mov		len1,ecx
							lea		esi,[esi+ecx]
							jmp		ParseStruct3
						.endif
					.endif
				.endif
			.endif
		.endif
	.endw
	xor		eax,eax
	retn

ParseIgnore:
	.while byte ptr [esi]
		invoke FBSkipLine,esi,addr npos
		inc		npos
		mov		esi,eax
		invoke FBGetWord,esi,addr npos
		mov		esi,edx
		.if ecx
			mov		lpword1,esi
			mov		len1,ecx
			lea		esi,[esi+ecx]
			invoke FBGetWord,esi,addr npos
			mov		esi,edx
			.if ecx
				mov		lpword2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				invoke FBWhatIsIt,lpword1,len1,lpword2,len2
				.if eax
					movzx	eax,[eax].DEFTYPE.nDefType
					.break .if eax==DEFTYPE_ENDIGNORE
				.endif
			.endif
		.endif
	.endw
	retn

FBParseFile endp
