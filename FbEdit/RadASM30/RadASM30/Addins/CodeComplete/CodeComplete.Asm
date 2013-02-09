;#########################################################################
;Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;Include file

include CodeComplete.inc

.code

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

InstallAddin proc uses ebx hWin:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get handles of codecomplete listbox
	mov		edx,[eax].ADDINHANDLES.hCC
	mov		hCC,edx
	;Get handles of codecomplete tooltip
	mov		edx,[eax].ADDINHANDLES.hTT
	mov		hTT,edx
	;Get handles of properties
	mov		edx,[eax].ADDINHANDLES.hProperty
	mov		hProperty,edx
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	mov		hook.hook1,HOOK_RASELCHANGE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallAddin Endp

IsLineCoInvoke proc uses esi edi,npos:DWORD

	mov		esi,offset linebuff
	mov		edi,offset szCoInvoke
	dec		esi
	mov		ecx,npos
	inc		ecx
  @@:
	dec		ecx
	je		Ex
	inc		esi
	mov		al,[esi]
	cmp		al,VK_SPACE
	je		@b
	cmp		al,VK_TAB
	je		@b
	dec		esi
	dec		edi
	inc		ecx
  @@:
	dec		ecx
	je		Ex
	inc		esi
	inc		edi
	mov		al,[edi]
	mov		ah,[esi]
;	;Not case sensitive
;	.if al>='a' && al<='z'
;		and		al,5Fh
;	.endif
;	.if ah>='a' && ah<='z'
;		and		ah,5Fh
;	.endif
	sub		ah,al
	je		@b
	.if !al && (ah==VK_SPACE || ah==VK_TAB)
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		mov		eax,esi
	.else
		jmp		Ex
	.endif
	ret
  Ex:
	;Not found
	xor		eax,eax
	ret

IsLineCoInvoke endp

Filter proc lpWord:DWORD,lpTyped:DWORD

	mov		ecx,lpWord
	mov		edx,lpTyped
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	.if ah && al
		;Not case sensitive
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		je		@b
		;Not found
		xor		eax,eax
	.else
		;Found
		mov		eax,edx
	.endif
	ret

Filter endp

;This proc fills the code complete list with words from the parsed wordlist
;NOTE it is not used in this example.
;Types from api files (uppercase):
;	P=Api's from winasmApi.api
;	M=Messages from winasmMsg.api
;	C=Constants from winasmConst.api
;	S=Structures from winasmStruct.api
;	T=Types from winasmType.api
;	W=Words from winasmWord.api
;Types from parsed code files (lowercase):
;	p=Procs from project
;	l=Labels from project
;	c=Constants from project
;	d=Data (variables) from project
;	s=Structures and unions parsed from project
;	m=Macros parsed from project
;	x=Objects parsed from project (masm/ObjAsm32 only)
;	y=Methods parsed from project (masm/ObjAsm32 only)
ListFromWordlist proc uses esi,lpTypes:DWORD,lpFilter:DWORD

	invoke SendMessage,hProperty,PRM_FINDFIRST,lpTypes,lpFilter
	.while eax
		mov		esi,eax
		invoke SendMessage,hProperty,PRM_FINDGETTYPE,0,0
		;Select an image depending on the returned value
		xor		edx,edx
		.if eax=='p'
			mov		edx,1
		.elseif eax=='W'
			mov		edx,2
		.elseif eax=='c'
			mov		edx,3
		.elseif eax=='d'
			mov		edx,14
		.elseif eax=='S'
			mov		edx,4
		.elseif eax=='s'
			mov		edx,5
		.elseif eax=='m'
			mov		edx,6
		.endif
		invoke SendMessage,hCC,CCM_ADDITEM,edx,esi
		invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
	.endw
	invoke SendMessage,hCC,CCM_GETCOUNT,0,0
	.if eax
		;Sort the list
		invoke SendMessage,hCC,CCM_SORT,FALSE,TRUE
		;Let RadASM show the listbox
		mov		eax,lpData
		mov		[eax].ADDINDATA.cctype,CCTYPE_USER
	.endif
	ret

ListFromWordlist endp

AddinProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nFilter:DWORD
	LOCAL	lpFun:DWORD

	mov		eax,uMsg
	.if eax==AIM_RASELCHANGE
		push	ebx
		push	esi
		push	edi
		mov		ebx,lParam
		.if [ebx].RASELCHANGE.seltyp==SEL_TEXT && [ebx].RASELCHANGE.fchanged
			mov		eax,lpData
			.if [eax].ADDINDATA.nAsm==nMASM
				.if [eax].ADDINDATA.cctype==CCTYPE_NONE || [eax].ADDINDATA.cctype==CCTYPE_USER || [eax].ADDINDATA.cctype==CCTYPE_USERTOOLTIP
					;Get the line text
					mov		esi,[ebx].RASELCHANGE.lpLine
					mov		ecx,[esi].CHARS.len
					.if ecx>=sizeof linebuff
						mov		ecx,sizeof linebuff-1
					.endif
					lea		esi,[esi+sizeof CHARS]
					mov		edi,offset linebuff
					rep movsb
					;Zero terminate line
					mov		byte ptr [edi],0
					.if byte ptr [edi-1]==VK_RETURN
						;Dont want CR
						mov		byte ptr [edi-1],0
					.endif
					mov		eax,[ebx].RASELCHANGE.chrg.cpMin
					sub		eax,[ebx].RASELCHANGE.cpLine
					invoke IsLineCoInvoke,eax
					.if eax
						mov		edi,eax
						sub		eax,offset linebuff
						mov		nPos,eax
						invoke SendMessage,hCC,CCM_CLEAR,0,0
						;put some text into listbox
						mov		esi,offset szSomeText
						.while byte ptr [esi]
							invoke Filter,esi,edi
							.if eax
								mov		lpFun,esi
								movzx	eax,byte ptr [eax-1]
								mov		nFilter,eax
								invoke SendMessage,hCC,CCM_ADDITEM,1,esi
							.endif
							invoke lstrlen,esi
							lea		esi,[esi+eax+1]
							invoke lstrlen,esi
							lea		esi,[esi+eax+1]
						.endw
						invoke SendMessage,hCC,CCM_GETCOUNT,0,0
						.if eax==1 && nFilter==','
							;Let RadASM show the tooltip
							;Count commas
							mov		edx,[ebx].RASELCHANGE.chrg.cpMin
							sub		edx,[ebx].RASELCHANGE.cpLine
							xor		ecx,ecx
							xor		eax,eax
							.while ecx<edx
								.if linebuff[ecx]==','
									inc		eax
								.endif
								inc		ecx
							.endw
							.if eax
								dec		eax
							.endif
							mov		edi,lpData
							mov		[edi].ADDINDATA.tti.nitem,eax
							mov		esi,lpFun
							mov		[edi].ADDINDATA.tti.lpszApi,esi
							invoke lstrlen,esi
							lea		esi,[esi+eax+1]
							mov		[edi].ADDINDATA.tti.lpszParam,esi
							mov		[edi].ADDINDATA.tti.lpszRetType,0
							mov		[edi].ADDINDATA.tti.lpszDesc,0
							mov		[edi].ADDINDATA.tti.novr,0
							mov		[edi].ADDINDATA.tti.nsel,0
							mov		[edi].ADDINDATA.tti.nwidth,0
							mov		[edi].ADDINDATA.cctype,CCTYPE_USERTOOLTIP
						.elseif eax
							;Let RadASM show the listbox
							mov		eax,lpData
							mov		[eax].ADDINDATA.cctype,CCTYPE_USER
						.endif
					.endif
				.endif
			.endif
		.endif
		pop		edi
		pop		esi
		pop		ebx
 	.endif
	xor		eax,eax
  Ex:
	ret

AddinProc Endp

;#########################################################################

End DllEntry
