	align 4 
	_PRM_SELECTPROPERTY:
		mov		ninx,0
		.while TRUE
			invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,ninx,0
			.break .if eax==CB_ERR
			.if eax==wParam
				invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_SETCURSEL,ninx,0
				.break
			.endif
			inc		ninx
		.endw
		invoke UpdateList,wParam
		xor		eax,eax
		ret
	align 4 
	_PRM_ADDPROPERTYTYPE:
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_ADDSTRING,0,lParam
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_SETITEMDATA,eax,wParam
		xor		eax,eax
		ret
	align 4 
	_PRM_ADDPROPERTYFILE:
		mov		eax,wParam
		movzx	edx,al
		shr		eax,8
		.if !eax
			mov		eax,2
		.endif
		invoke AddFileToWordList,edx,lParam,eax
		ret
	align 4 
	_PRM_SETGENDEF:
		push	esi
		mov		esi,lParam
		invoke strcpy,addr [ebx].RAPROPERTY.defgen.szCmntBlockSt,addr [esi].DEFGEN.szCmntBlockSt
		invoke strcpy,addr [ebx].RAPROPERTY.defgen.szCmntBlockEn,addr [esi].DEFGEN.szCmntBlockEn
		invoke strcpy,addr [ebx].RAPROPERTY.defgen.szCmntChar,addr [esi].DEFGEN.szCmntChar
		invoke strcpy,addr [ebx].RAPROPERTY.defgen.szString,addr [esi].DEFGEN.szString
		invoke strcpy,addr [ebx].RAPROPERTY.defgen.szLineCont,addr [esi].DEFGEN.szLineCont
		pop		esi
		xor		eax,eax
		ret
	align 4 
	_PRM_ADDIGNORE:
		.if ![ebx].RAPROPERTY.lpignore
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4*1024
			mov		[ebx].RAPROPERTY.lpignore,eax
		.endif
		push	esi
		mov		esi,[ebx].RAPROPERTY.lpignore
		add		esi,[ebx].RAPROPERTY.rpignorefree
		mov		eax,wParam
		mov		[esi],al
		inc		esi
		invoke strlen,lParam
		push	eax
		mov		[esi],al
		inc		esi
		invoke strcpy,esi,lParam
		pop		eax
		add		eax,3
		add		[ebx].RAPROPERTY.rpignorefree,eax
		pop		esi
		xor		eax,eax
		ret
	align 4 
	_PRM_ADDDEFTYPE:
		.if ![ebx].RAPROPERTY.lpdeftype
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32*1024
			mov		[ebx].RAPROPERTY.lpdeftype,eax
		.endif
		mov		edx,[ebx].RAPROPERTY.lpdeftype
		add		edx,[ebx].RAPROPERTY.rpfreedeftype
		invoke RtlMoveMemory,edx,lParam,sizeof DEFTYPE
		add		[ebx].RAPROPERTY.rpfreedeftype,sizeof DEFTYPE
		xor		eax,eax
		ret
	align 4 
	_PRM_PARSEFILE:
		mov		eax,[ebx].RAPROPERTY.nlanguage
		.if eax==nMASM
			; Masm
			invoke MPreParse,lParam
			invoke MParseFile,wParam,lParam
		.elseif eax==nTASM
			;Tasm
			invoke TasmPreParse,lParam
			invoke TasmParseFile,wParam,lParam
		.elseif eax==nFASM
			;Fasm
			invoke FasmPreParse,lParam
			invoke FasmParseFile,wParam,lParam
		.elseif eax==nGOASM
			; GoAsm
			invoke GoPreParse,lParam
			invoke GoParseFile,wParam,lParam
		.elseif eax==nNASM
		.elseif eax==nHLA
		.elseif eax==nCPP
			;C/C++
			invoke CppPreParse,lParam
			invoke CppParseFile,wParam,lParam
		.elseif eax==nFREEBASIC
			; FreeBASIC
			invoke FBPreParse,lParam,FALSE
			invoke FBParseFile,wParam,lParam
		.elseif eax==nFREEPASCAL
			;FreePASCAL
			invoke FpPreParse,lParam,[ebx].RAPROPERTY.lpchartab
			invoke FpParseFile,wParam,lParam
		.elseif eax==nSOLASM
			;SolAsm
			invoke SolPreParse,lParam,[ebx].RAPROPERTY.lpchartab
			invoke SolParseFile,wParam,lParam
		.elseif eax==nASEMW
			; asemw, Masm
			invoke MPreParse,lParam
			invoke MParseFile,wParam,lParam
		.elseif eax==nOTHER
		.endif
		xor		eax,eax
		ret
	align 4 
	_PRM_SETCHARTAB:
		mov		eax,lParam
		mov		[ebx].RAPROPERTY.lpchartab,eax
		xor		eax,eax
		ret
	align 4 
	_PRM_DELPROPERTY:
		invoke DeleteProperties,wParam
		invoke CompactProperties,TRUE
		xor		eax,eax
		ret
	align 4 
	_PRM_REFRESHLIST:
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETCURSEL,0,0
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,eax,0
		invoke UpdateList,eax
		xor		eax,eax
		ret
	align 4 
	_PRM_SELOWNER:
		mov		eax,wParam
		mov		[ebx].RAPROPERTY.nOwner,eax
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETCURSEL,0,0
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,eax,0
		invoke UpdateList,eax
		xor		eax,eax
		ret
	align 4 
	_PRM_GETSELBUTTON:
		mov		eax,[ebx].RAPROPERTY.nButton
		ret
	align 4 
	_PRM_SETSELBUTTON:
		invoke SendMessage,[ebx].RAPROPERTY.htbr,TB_CHECKBUTTON,[ebx].RAPROPERTY.nButton,FALSE
		mov		eax,wParam
		mov		[ebx].RAPROPERTY.nButton,eax
		invoke SendMessage,[ebx].RAPROPERTY.htbr,TB_CHECKBUTTON,[ebx].RAPROPERTY.nButton,TRUE
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETCURSEL,0,0
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,eax,0
		invoke UpdateList,eax
		xor		eax,eax
		ret
	align 4 
	_PRM_FINDFIRST:
		invoke strcpyn,addr [ebx].RAPROPERTY.szFindTypes,wParam,sizeof RAPROPERTY.szFindTypes
		invoke strcpyn,addr [ebx].RAPROPERTY.szFindText,lParam,sizeof RAPROPERTY.szFindText
		mov		[ebx].RAPROPERTY.rpFindPos,0
		invoke Find
		.if eax
			lea		eax,[eax+sizeof PROPERTIES]
		.endif
		ret
	align 4 
	_PRM_FINDNEXT:
		invoke Find
		.if eax
			lea		eax,[eax+sizeof PROPERTIES]
		.endif
		ret
	align 4 
	_PRM_FINDGETTYPE:
		mov		eax,[ebx].RAPROPERTY.nfindtype
		ret
	align 4 
	_PRM_GETWORD:
		mov		edx,lParam
		mov		ecx,wParam
		push	esi
		mov		esi,[ebx].RAPROPERTY.lpchartab
		.while ecx
			dec		ecx
			movzx	eax,byte ptr [edx+ecx]
			.if byte ptr [esi+eax]!=CT_CHAR
				inc		ecx
				.break
			.endif
		.endw
		xor		esi,esi
		.while ecx<wParam
			mov		al,[edx+ecx]
			mov		[edx+esi],al
			inc		ecx
			inc		esi
		.endw
		mov		byte ptr [edx+esi],0
		pop		esi
		ret
	align 4 
	_PRM_GETSTRUCTWORD:
		mov		eax,[ebx].RAPROPERTY.nlanguage
		.if eax==nMASM
			; Masm
			invoke MDestroyCommentsStrings,lParam
		.elseif eax==nTASM
			; Tasm
			invoke TasmDestroyCommentsStrings,lParam
		.elseif eax==nFASM
			; Fasm
			invoke FasmDestroyCommentsStrings,lParam
		.elseif eax==nGOASM
			; GoAsm
			invoke GoDestroyCommentsStrings,lParam
		.elseif eax==nNASM
		.elseif eax==nHLA
		.elseif eax==nCPP
			;C/C++
			invoke CppDestroyCommentsStrings,lParam
		.elseif eax==nFREEBASIC
			; FreeBASIC
			invoke FBDestroyCommentsStrings,lParam,FALSE
		.elseif eax==nFREEPASCAL
			;FreePASCAL
			invoke FpDestroyCommentsStrings,lParam
		.elseif eax==nSOLASM
			;sol_asm
			invoke SolDestroyCommentsStrings,lParam
		.elseif eax==nASEMW
		.elseif eax==nOTHER
		.endif
		mov		edx,lParam
		mov		ecx,wParam
		push	esi
		push	edi
		mov		esi,[ebx].RAPROPERTY.lpchartab
		xor		ebx,ebx
		.while ecx
			dec		ecx
			movzx	eax,byte ptr [edx+ecx]
			.if eax=='.'
				.if !ebx
					mov		ebx,ecx
				.endif
			.elseif word ptr [edx+ecx-1]=='>-'
				dec		ecx
				.if !ebx
					mov		ebx,ecx
				.endif
			.elseif byte ptr [edx+ecx]==')'
				xor		edi,edi
				.while ecx
					mov		al,[edx+ecx]
					dec		ecx
					.if al==')'
						inc		edi
					.elseif al=='('
						dec		edi
						.break .if ZERO?
					.endif
				.endw
			.elseif byte ptr [edx+ecx]==']'
				xor		edi,edi
				.while ecx
					mov		al,[edx+ecx]
					dec		ecx
					.if al==']'
						inc		edi
					.elseif al=='['
						dec		edi
						.break .if ZERO?
					.endif
				.endw
			.elseif byte ptr [esi+eax]!=CT_CHAR
				inc		ecx
				.break
			.endif
		.endw
		xor		esi,esi
		.while ecx<ebx
		  @@:
			mov		ax,[edx+ecx]
			.if al=='.'
				xor		eax,eax
			.elseif ax=='>-'
				xor		eax,eax
				inc		ecx
			.elseif al=='('
				.while ecx<ebx
					mov		al,[edx+ecx]
					inc		ecx
					.if al=='('
						inc		edi
					.elseif al==')'
						dec		edi
						.break .if ZERO?
					.endif
				.endw
				jmp		@b
			.elseif al=='['
				.while ecx<ebx
					mov		al,[edx+ecx]
					inc		ecx
					.if al=='['
						inc		edi
					.elseif al==']'
						dec		edi
						.break .if ZERO?
					.endif
				.endw
				jmp		@b
			.endif
			mov		[edx+esi],al
			inc		ecx
			inc		esi
		.endw
		mov		word ptr [edx+esi],0
		pop		edi
		pop		esi
		ret
	align 4 
	_PRM_FINDITEMDATATYPE:
		mov		edx,lParam
		.while byte ptr [edx]
			mov		ebx,edx
			mov		ecx,wParam
			.while byte ptr [ecx]
				mov		al,[ecx]
				cmp		al,[edx]
				jne		@f
				inc		ecx
				inc		edx
			.endw
			mov		ecx,wParam
			.if byte ptr [edx]==':'
				inc		edx
				.while byte ptr [edx] && byte ptr [edx]!=',' && byte ptr [edx]!='*' && byte ptr [edx]!=' '
					mov		al,[edx]
					mov		[ecx],al
					inc		ecx
					inc		edx
				.endw
				mov		byte ptr [ecx],0
				ret
			.elseif byte ptr [edx]=='['
				.while byte ptr [edx] && byte ptr [edx-1]!=']'
					inc		edx
				.endw
				.if byte ptr [edx]==':'
					inc		edx
					.while byte ptr [edx] && byte ptr [edx]!=',' && byte ptr [edx]!='*' && byte ptr [edx]!=' '
						mov		al,[edx]
						mov		[ecx],al
						inc		ecx
						inc		edx
					.endw
					mov		byte ptr [ecx],0
					ret
				.endif
			.endif
		  @@:
			mov		edx,ebx
			call	SkipToComma
		.endw
		mov		ecx,wParam
		mov		byte ptr [ecx],0
		ret
	align 4 
	_PRM_GETTOOLTIP:
		invoke GetToolTip,lParam,wParam
		ret
	align 4 
	_PRM_SETBACKCOLOR:
		invoke DeleteObject,[ebx].RAPROPERTY.hbrback
		mov		eax,lParam
		mov		[ebx].RAPROPERTY.backcolor,eax
		invoke CreateSolidBrush,eax
		mov		[ebx].RAPROPERTY.hbrback,eax
		invoke InvalidateRect,[ebx].RAPROPERTY.hcbo,NULL,TRUE
		invoke InvalidateRect,[ebx].RAPROPERTY.hlst,NULL,TRUE
		ret
	align 4 
	_PRM_GETBACKCOLOR:
		mov		eax,[ebx].RAPROPERTY.backcolor
		ret
	align 4 
	_PRM_SETTEXTCOLOR:
		mov		eax,lParam
		mov		[ebx].RAPROPERTY.textcolor,eax
		invoke InvalidateRect,[ebx].RAPROPERTY.hcbo,NULL,TRUE
		invoke InvalidateRect,[ebx].RAPROPERTY.hlst,NULL,TRUE
		ret
	align 4 
	_PRM_GETTEXTCOLOR:
		mov		eax,[ebx].RAPROPERTY.textcolor
		ret
	align 4 
	_PRM_SETOPRCOLOR:
		mov		eax,lParam
		mov		[ebx].RAPROPERTY.oprcolor,eax
		invoke InvalidateRect,[ebx].RAPROPERTY.hcbo,NULL,TRUE
		invoke InvalidateRect,[ebx].RAPROPERTY.hlst,NULL,TRUE
		ret
	align 4 
	_PRM_GETOPRCOLOR:
		mov		eax,[ebx].RAPROPERTY.oprcolor
		ret
	align 4 
	_PRM_ISINPROC:
		mov		edx,[ebx].RAPROPERTY.lpmem
		.if edx
			add		edx,[ebx].RAPROPERTY.rpproject
			mov		ecx,lParam
			.while [edx].PROPERTIES.nSize
				mov		eax,[ecx].ISINPROC.nOwner
				.if eax==[edx].PROPERTIES.nOwner
					movzx	eax,[edx].PROPERTIES.nType
					invoke IsType,[ecx].ISINPROC.lpszType,eax
					.if eax
						mov		eax,[ecx].ISINPROC.nLine
						.if eax>=[edx].PROPERTIES.nLine && eax<=[edx].PROPERTIES.nEnd
							; Found
							lea		eax,[edx+sizeof PROPERTIES]
							ret
						.endif
					.endif
				.endif
				mov		eax,[edx].PROPERTIES.nSize
				lea		edx,[edx+eax+sizeof PROPERTIES]
			.endw
		.endif
		xor		eax,eax
		ret
	align 4 
	_PRM_MEMSEARCH:
		mov		ebx,lParam
		xor		ecx,ecx
		xor		edx,edx
		mov		eax,[ebx].MEMSEARCH.fr
		test	eax,FR_MATCHCASE
		.if !ZERO?
			inc		ecx
		.endif
		test	eax,FR_WHOLEWORD
		.if !ZERO?
			inc		edx
		.endif
		test	eax,FR_DOWN
		.if !ZERO?
			invoke SearchMemDown,[ebx].MEMSEARCH.lpMem,[ebx].MEMSEARCH.lpFind,ecx,edx,[ebx].MEMSEARCH.lpCharTab
		.else
			invoke SearchMemUp,[ebx].MEMSEARCH.lpMem,[ebx].MEMSEARCH.lpFind,ecx,edx,[ebx].MEMSEARCH.lpCharTab
		.endif
		ret
	align 4 
	_PRM_FINDGETOWNER:
		mov		eax,[ebx].RAPROPERTY.nfindowner
		ret
	align 4 
	_PRM_FINDGETLINE:
		mov		eax,[ebx].RAPROPERTY.nfindline
		ret
	align 4 
	_PRM_FINDGETENDLINE:
		mov		eax,[ebx].RAPROPERTY.nfindendline
		ret
	align 4 
	_PRM_ISINWITHBLOCK:
		mov		edx,[ebx].RAPROPERTY.lpdeftype
		mov		ecx,[ebx].RAPROPERTY.rpfreedeftype
		lea		ecx,[ecx+edx]
		.while edx<ecx
			.if [edx].DEFTYPE.nDefType==DEFTYPE_WITHBLOCK
				movzx	eax,[edx].DEFTYPE.Def
				mov		edx,[ebx].RAPROPERTY.lpmem
				add		edx,[ebx].RAPROPERTY.rpproject
				.while [edx].PROPERTIES.nSize
					mov		ecx,wParam
					.if al==[edx].PROPERTIES.nType && ecx==[edx].PROPERTIES.nOwner
						mov		ecx,lParam
						.if ecx>=[edx].PROPERTIES.nLine && ecx<=[edx].PROPERTIES.nEnd
							; Found
							lea		eax,[edx+sizeof PROPERTIES]
							ret
						.endif
					.endif
					mov		ecx,[edx].PROPERTIES.nSize
					lea		edx,[edx+ecx+sizeof PROPERTIES]
				.endw
				.break
			.endif
			add		edx,sizeof DEFTYPE
		.endw
		xor		eax,eax
		ret
	align 4 
	_PRM_ADDISWORD:
		.if ![ebx].RAPROPERTY.lpisword
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4*1024
			mov		[ebx].RAPROPERTY.lpisword,eax
		.endif
		push	esi
		mov		esi,[ebx].RAPROPERTY.lpisword
		add		esi,[ebx].RAPROPERTY.rpiswordfree
		mov		eax,wParam
		mov		[esi],al
		inc		esi
		invoke strlen,lParam
		push	eax
		mov		[esi],al
		inc		esi
		invoke strcpy,esi,lParam
		pop		eax
		add		eax,3
		add		[ebx].RAPROPERTY.rpiswordfree,eax
		pop		esi
		xor		eax,eax
		ret
	align 4 
	_PRM_CLEARWORDLIST:
		.if [ebx].RAPROPERTY.hmem
			invoke GlobalFree,[ebx].RAPROPERTY.hmem
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.hmem,eax
		mov		[ebx].RAPROPERTY.lpmem,eax
		mov		[ebx].RAPROPERTY.cbsize,eax
		mov		[ebx].RAPROPERTY.rpproject,eax
		mov		[ebx].RAPROPERTY.rpfree,eax
		ret
	align 4 
	_PRM_GETSTRUCTSTART:
		mov		eax,[ebx].RAPROPERTY.nlanguage
		.if eax==nMASM
			; Masm
			invoke MDestroyCommentsStrings,lParam
		.elseif eax==nTASM
			; Tasm
			invoke TasmDestroyCommentsStrings,lParam
		.elseif eax==nFASM
			; Fasm
			invoke FasmDestroyCommentsStrings,lParam
		.elseif eax==nGOASM
			; GoAsm
			invoke GoDestroyCommentsStrings,lParam
		.elseif eax==nNASM
		.elseif eax==nHLA
		.elseif eax==nCPP
			;C/C++
			invoke CppDestroyCommentsStrings,lParam
		.elseif eax==nFREEBASIC
			; FreeBASIC
			invoke FBDestroyCommentsStrings,lParam,FALSE
		.elseif eax==nFREEPASCAL
			;FreePASCAL
			invoke FpDestroyCommentsStrings,lParam
		.elseif eax==nSOLASM
			;sol_asm
			invoke SolDestroyCommentsStrings,lParam
		.elseif eax==nASEMW
		.elseif eax==nOTHER
		.endif
		mov		edx,lParam
		mov		ecx,wParam
		push	esi
		push	edi
		mov		esi,[ebx].RAPROPERTY.lpchartab
		.while ecx
			dec		ecx
			movzx	eax,byte ptr [edx+ecx]
			.if eax=='.'
			.elseif word ptr [edx+ecx-1]=='>-'
				dec		ecx
			.elseif byte ptr [edx+ecx]==')'
				xor		edi,edi
				.while ecx
					mov		al,[edx+ecx]
					dec		ecx
					.if al==')'
						inc		edi
					.elseif al=='('
						dec		edi
						.break .if ZERO?
					.endif
				.endw
			.elseif byte ptr [edx+ecx]==']'
				xor		edi,edi
				.while ecx
					mov		al,[edx+ecx]
					dec		ecx
					.if al==']'
						inc		edi
					.elseif al=='['
						dec		edi
						.break .if ZERO?
					.endif
				.endw
			.elseif byte ptr [esi+eax]!=CT_CHAR
				inc		ecx
				.break
			.endif
		.endw
		xor		esi,esi
		.while byte ptr [edx+ecx]
			mov		al,[edx+ecx]
			mov		[edx+esi],al
			inc		ecx
			inc		esi
		.endw
		mov		word ptr [edx+esi],0
		pop		edi
		pop		esi
		ret
	align 4 
	_PRM_GETCURSEL:
		invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETCURSEL,0,0
		ret
	align 4 
	_PRM_GETSELTEXT:
		invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETTEXT,eax,lParam
		.endif
		ret
	align 4 
	_PRM_GETSORTEDLIST:
		invoke MakeSortedList,wParam
		mov		edx,lParam
		mov		[edx],ecx
		ret
	align 4 
	_PRM_FINDINSORTEDLIST:
		mov		edx,lParam
		invoke FindWord,[edx].MEMSEARCH.lpFind,[edx].MEMSEARCH.lpMem,wParam
		ret
	align 4 
	_PRM_ISTOOLTIPMESSAGE:
		invoke IsTooltipMessage,hWin,wParam,lParam
		ret
	align 4
	_PRM_SETLANGUAGE:
		mov		eax,wParam
		mov		[ebx].RAPROPERTY.nlanguage,eax
		ret
	align 4
	_PRM_SETTOOLTIP:
		mov		eax,wParam
		.if eax==1
			mov		eax,offset szCurrentFile
		.elseif eax==2
			mov		eax,offset szOpenFiles
		.elseif eax==3
			mov		eax,offset szSelectedProjectFile
		.elseif eax==4
			mov		eax,offset szAllProjectFiles
		.elseif eax==5
			mov		eax,offset szRefresh
		.else
			xor		eax,eax
		.endif
		.if eax
			invoke strcpyn,eax,lParam,64
		.endif
		ret
	align 4
	_PRM_PREPARSE:
		mov		eax,[ebx].RAPROPERTY.nlanguage
		.if eax==nMASM
			; Masm
			invoke MPreParse,lParam
		.elseif eax==nTASM
			; Tasm
			invoke TasmPreParse,lParam
		.elseif eax==nFASM
			; Fasm
			invoke FasmPreParse,lParam
		.elseif eax==nGOASM
			; GoAsm
			invoke GoPreParse,lParam
		.elseif eax==nNASM
		.elseif eax==nHLA
		.elseif eax==nCPP
			;C/C++
			invoke CppPreParse,lParam
		.elseif eax==nFREEBASIC
			; FreeBASIC
			invoke FBPreParse,lParam,wParam
		.elseif eax==nFREEPASCAL
			;FreePASCAL
			invoke FpPreParse,lParam,[ebx].RAPROPERTY.lpchartab
		.elseif eax==nSOLASM
			;sol_asm
			invoke SolPreParse,lParam,[ebx].RAPROPERTY.lpchartab
		.elseif eax==nASEMW
			; asemw, Masm
			invoke MPreParse,lParam
		.elseif eax==nOTHER
		.endif
		xor		eax,eax
		ret
	align 4
	_PRM_ISINLIST:
		invoke SearchMemDown,lParam,wParam,TRUE,TRUE,[ebx].RAPROPERTY.lpchartab
		ret
	align 4
	_PRM_ADDPROPERTYWORD:
		invoke strcpy,offset szname,lParam
		mov		edx,offset szname
		.while byte ptr [edx]
			.if byte ptr [edx]==',' || byte ptr [edx]=='|'
				mov		byte ptr [edx],0
			.endif
			inc		edx
		.endw
		mov		dword ptr [edx],0
		mov		eax,wParam
		movzx	edx,ah
		movzx	eax,al
		invoke AddWordToWordList,eax,0,0,0,offset szname,edx
		mov		eax,[ebx].RAPROPERTY.rpfree
		mov		[ebx].RAPROPERTY.rpproject,eax
		ret
	align 4
	_PRM_ADDPROPERTYLIST:
		push	esi
		push	edi
		mov		eax,[ebx].RAPROPERTY.rpfree
		sub		eax,[ebx].RAPROPERTY.rpproject
		push	eax
		mov		esi,lParam
		mov		edi,offset szname
		xor		ecx,ecx
		.while byte ptr [esi]
			mov		al,[esi]
			.if al==','
				mov		dword ptr [edi],0
				.if (szname<'0' || szname>'9') && szname!='-'
					mov		eax,wParam
					movzx	edx,ah
					movzx	eax,al
					push	ecx
					invoke AddWordToWordList,eax,0,0,0,offset szname,edx
					pop		ecx
					inc		ecx
				.endif
				mov		edi,offset szname
				inc		esi
			.else
				mov		[edi],al
				inc		esi
				inc		edi
			.endif
		.endw
		mov		dword ptr [edi],0
		.if szname
			.if (szname<'0' || szname>'9') && szname!='-'
				mov		eax,wParam
				movzx	edx,ah
				movzx	eax,al
				push	ecx
				invoke AddWordToWordList,eax,0,0,0,offset szname,edx
				pop		ecx
				inc		ecx
			.endif
		.endif
		pop		eax
		.if !eax
			mov		eax,[ebx].RAPROPERTY.rpfree
			mov		[ebx].RAPROPERTY.rpproject,eax
		.endif
		pop		edi
		pop		esi
		mov		eax,ecx
		ret
	align 4
	_PRM_COMPACTLIST:
		invoke CompactProperties,wParam
		ret
	align 4
	_PRM_RESET:
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_RESETCONTENT,0,0
		.if [ebx].RAPROPERTY.hmem
			invoke GlobalFree,[ebx].RAPROPERTY.hmem
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.hmem,eax
		mov		[ebx].RAPROPERTY.cbsize,eax
		mov		[ebx].RAPROPERTY.lpmem,eax
		mov		[ebx].RAPROPERTY.rpfree,eax
		mov		[ebx].RAPROPERTY.rpproject,eax
		invoke RtlZeroMemory,addr [ebx].RAPROPERTY.defgen,sizeof DEFGEN
		.if [ebx].RAPROPERTY.lpignore
			invoke GlobalFree,[ebx].RAPROPERTY.lpignore
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.lpignore,eax
		mov		[ebx].RAPROPERTY.rpignorefree,eax
		.if [ebx].RAPROPERTY.lpisword
			invoke GlobalFree,[ebx].RAPROPERTY.lpisword
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.lpisword,eax
		mov		[ebx].RAPROPERTY.rpiswordfree,eax
		.if [ebx].RAPROPERTY.lpdeftype
			invoke GlobalFree,[ebx].RAPROPERTY.lpdeftype
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.lpdeftype,eax
		mov		[ebx].RAPROPERTY.rpfreedeftype,eax
		.if [ebx].RAPROPERTY.hMemArray
			invoke GlobalFree,[ebx].RAPROPERTY.hMemArray
		.endif
		xor		eax,eax
		mov		[ebx].RAPROPERTY.hMemArray,eax
		ret
	align 4
	_PRM_GETSELTYP:
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETCURSEL,0,0
		.if eax!=CB_ERR
			invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,eax,0
		.else
			xor		eax,eax
		.endif
		ret
	align 4
	_PRM_ADDPROPERTYITEM:
		mov		edx,lParam
		invoke AddWordToWordList,[edx].PROPERTYITEM.nType,[edx].PROPERTYITEM.nOwner,[edx].PROPERTYITEM.nLine,[edx].PROPERTYITEM.nEndLine,[edx].PROPERTYITEM.lpszStr,[edx].PROPERTYITEM.nParts
		ret
	align 4 
	_PRM_GETCURRENTOWNER:
		mov		eax,[ebx].RAPROPERTY.nOwner
		ret

.data
align 4
_RAPROPERTY_BASE \
	dd _PRM_SELECTPROPERTY		;equ WM_USER+0		;wParam=dwType, lParam=0
	dd _PRM_ADDPROPERTYTYPE		;equ WM_USER+1		;wParam=dwType, lParam=lpszType
	dd _PRM_ADDPROPERTYFILE		;equ WM_USER+2		;wParam=dwType, lParam=lpszFile
	dd _PRM_SETGENDEF			;equ WM_USER+3		;wParam=0, lParam=lpGENDEF
	dd _PRM_ADDIGNORE			;equ WM_USER+4		;wParam=IgnoreType, lParam=lpszWord
	dd _PRM_ADDDEFTYPE			;equ WM_USER+5		;wParam=0, lParam=lpTYPEDEF
	dd _PRM_PARSEFILE			;equ WM_USER+6		;wParam=nOwner, lParam=lpFileData
	dd _PRM_SETCHARTAB			;equ WM_USER+7		;wParam=0, lParam=lpCharTab
	dd _PRM_DELPROPERTY			;equ WM_USER+8		;wParam=nOwner, lParam=0
	dd _PRM_REFRESHLIST			;equ WM_USER+9		;wParam=0, lParam=0
	dd _PRM_SELOWNER			;equ WM_USER+10		;wParam=nOwner, lParam=0
	dd _PRM_GETSELBUTTON		;equ WM_USER+11		;wParam=0, lParam=0
	dd _PRM_SETSELBUTTON		;equ WM_USER+12		;wParam=nButton, lParam=0
	dd _PRM_FINDFIRST			;equ WM_USER+13		;wParam=lpszTypes, lParam=lpszText
	dd _PRM_FINDNEXT			;equ WM_USER+14		;wParam=0, lParam=0
	dd _PRM_FINDGETTYPE			;equ WM_USER+15		;wParam=0, lParam=0
	dd _PRM_GETWORD				;equ WM_USER+16		;wParam=pos, lParam=lpszLine
	dd _PRM_GETTOOLTIP			;equ WM_USER+17		;wParam=TRUE/FALSE (No case), lParam=lpTOOLTIP
	dd _PRM_SETBACKCOLOR		;equ WM_USER+18		;wParam=0, lParam=nColor
	dd _PRM_GETBACKCOLOR		;equ WM_USER+19		;wParam=0, lParam=0
	dd _PRM_SETTEXTCOLOR		;equ WM_USER+20		;wParam=0, lParam=nColor
	dd _PRM_GETTEXTCOLOR		;equ WM_USER+21		;wParam=0, lParam=0
	dd _PRM_ISINPROC			;equ WM_USER+22		;wParam=0, lParam=lpISINPROC
	dd _PRM_GETSTRUCTWORD		;equ WM_USER+23		;wParam=pos, lParam=lpszLine
	dd _PRM_FINDITEMDATATYPE	;equ WM_USER+24		;wParam=lpszItemName, lParam=lpszItemList
	dd _PRM_MEMSEARCH			;equ WM_USER+25		;wParam=0, lParam=lpMEMSEARCH
	dd _PRM_FINDGETOWNER		;equ WM_USER+26		;wParam=0, lParam=0
	dd _PRM_FINDGETLINE			;equ WM_USER+27		;wParam=0, lParam=0
	dd _PRM_ISINWITHBLOCK		;equ WM_USER+28		;wParam=nOwner, lParam=nLine
	dd _PRM_FINDGETENDLINE		;equ WM_USER+29		;wParam=0, lParam=0
	dd _PRM_ADDISWORD			;equ WM_USER+30		;wParam=IsWordType, lParam=lpszWord
	dd _PRM_SETOPRCOLOR			;equ WM_USER+31		;wParam=0, lParam=nColor
	dd _PRM_GETOPRCOLOR			;equ WM_USER+32		;wParam=0, lParam=0
	dd _PRM_CLEARWORDLIST		;equ WM_USER+33		;wParam=0, lParam=0
	dd _PRM_GETSTRUCTSTART		;equ WM_USER+34		;wParam=pos, lParam=lpszLine
	dd _PRM_GETCURSEL			;equ WM_USER+35		;wParam=0, lParam=0
	dd _PRM_GETSELTEXT			;equ WM_USER+36		;wParam=0, lParam=lpBuff
	dd _PRM_GETSORTEDLIST		;equ WM_USER+37		;wParam=lpTypes, lParam=lpCount
	dd _PRM_FINDINSORTEDLIST	;equ WM_USER+38		;wParam=0, lParam=lpWord
	dd _PRM_ISTOOLTIPMESSAGE	;equ WM_USER+39		;wParam=lpMESSAGE, lParam=lpTOOLTIP
	dd _PRM_SETLANGUAGE			;equ WM_USER+40		;wParam=nLanguage, lParam=0
	dd _PRM_SETTOOLTIP			;equ WM_USER+41		;wParam=n (1-5), lParam=lpszText
	dd _PRM_PREPARSE			;equ WM_USER+42		;wParam=fKeepStrings, lParam=lpFileData
	dd _PRM_ISINLIST			;equ WM_USER+43		;wParam=lpWord, lParam=lpList
	dd _PRM_ADDPROPERTYWORD		;equ WM_USER+44		;wParam=dwType, lParam=lpszWord
	dd _PRM_ADDPROPERTYLIST		;equ WM_USER+45		;wParam=dwType, lParam=lpszLineOfWords
	dd _PRM_COMPACTLIST			;equ WM_USER+46		;wParam=fProject, lParam=0
	dd _PRM_RESET				;equ WM_USER+47		;wParam=0, lParam=0
	dd _PRM_GETSELTYP			;equ WM_USER+48		;wParam=0, lParam=0
	dd _PRM_ADDPROPERTYITEM		;equ WM_USER+49		;wParam=0, lParam=lpPROPERTYITEM
    dd _PRM_GETCURRENTOWNER     ;equ WM_USER+50     ;wParam=0, lParam=0, returns nOwner
.code
align 4
