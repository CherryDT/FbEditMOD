
.data?

lpOldCCProc				dd ?
cclist					db 16384 dup(?)

.code

CodeCompleteProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_TAB || eax==VK_RETURN
			invoke SendMessage,ha.hEdt,WM_CHAR,VK_TAB,0
			jmp		Ex
		.elseif eax==VK_ESCAPE
			invoke ShowWindow,hWin,SW_HIDE
			jmp		Ex
		.endif
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		shr		eax,16
		xor		ecx,ecx ;LINEUP
		cmp		ax,0
		jge		@F
		inc		ecx ; LINEDOWN 
	   @@:
		invoke SendMessage,hWin,WM_VSCROLL,ecx,0
	.elseif eax==WM_LBUTTONDBLCLK
		invoke SendMessage,ha.hEdt,WM_CHAR,VK_TAB,0
		jmp		Ex
	.elseif eax==WM_SIZE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		edx,rect.bottom
		sub		edx,rect.top
		mov		da.win.ccwt,eax
		mov		da.win.ccht,edx
	.endif
	invoke CallWindowProc,lpOldCCProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

CodeCompleteProc endp

CreateCodeComplete proc

	invoke CreateWindowEx,NULL,addr szCCLBClassName,NULL,WS_CHILD or WS_SIZEBOX or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or STYLE_USEIMAGELIST,0,0,0,0,ha.hWnd,NULL,ha.hInstance,0
	mov		ha.hCC,eax
	invoke SetWindowLong,ha.hCC,GWL_WNDPROC,offset CodeCompleteProc
	mov		lpOldCCProc,eax
	invoke CreateWindowEx,NULL,addr szCCTTClassName,NULL,WS_POPUP or WS_BORDER or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,0,0,0,0,ha.hWnd,NULL,ha.hInstance,0
	mov		ha.hTT,eax
	invoke SendMessage,ha.hTab,WM_GETFONT,0,0
	push	eax
	invoke SendMessage,ha.hCC,WM_SETFONT,eax,FALSE
	pop		eax
	invoke SendMessage,ha.hTT,WM_SETFONT,eax,FALSE
	ret

CreateCodeComplete endp

AddList proc uses esi edi,lpList:DWORD,lpWord:DWORD,nImg:DWORD
	LOCAL	nCount:DWORD

	mov		nCount,0
	mov		esi,lpList
	mov		edi,offset cclist
	.while byte ptr [esi]
		call	Filter
		.if !eax
			push	edi
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			mov		byte ptr [edi],0
			inc		edi
			pop		eax
			invoke SendMessage,ha.hCC,CCM_ADDITEM,nImg,eax
			inc		nCount
		.else
			.while byte ptr [esi] && byte ptr [esi]!=','
				inc		esi
			.endw
		.endif
		.if byte ptr [esi]
			inc		esi
		.endif
	.endw
	mov		eax,nCount
	ret

Filter:
	mov		edx,lpWord
	mov		ecx,esi
  @@:
	mov		al,[edx]
	.if al==VK_SPACE || al==VK_TAB || al==','
		xor		al,al
	.endif
	.if al
		mov		ah,[ecx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		inc		edx
		inc		ecx
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	retn

AddList endp

IsWordReg proc lpWord:DWORD

	invoke strlen,lpWord
	.if eax==3
		mov		eax,lpWord
		mov		eax,[eax]
		and		eax,5F5F5Fh
		.if eax=='RTP'
			mov		eax,2
		.elseif eax=='XAE'
			mov		eax,1
		.elseif eax=='XBE'
			mov		eax,1
		.elseif eax=='XCE'
			mov		eax,1
		.elseif eax=='XDE'
			mov		eax,1
		.elseif eax=='ISE'
			mov		eax,1
		.elseif eax=='IDE'
			mov		eax,1
		.elseif eax=='PBE'
			mov		eax,1
		.elseif eax=='PSE'
			mov		eax,1
		.elseif eax=='RTP'
			mov		eax,1
		.else
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
	.endif
	ret

IsWordReg endp

IsWordStruct proc uses esi,lpWord:DWORD

	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,offset szCCSs,lpWord
	.while TRUE
		.break .if !eax
		mov		esi,eax
		invoke strcmp,esi,lpWord
		.if !eax
			mov		eax,esi
			ret
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	ret

IsWordStruct endp

IsWordLocalStruct proc uses esi edi,lpLocal:DWORD,lpWord:DWORD,lpBuff:DWORD

	mov		eax,lpBuff
	mov		byte ptr [eax],0
	mov		edi,lpWord
	mov		esi,lpLocal
	; Skip proc name
	invoke strlen,esi
	lea		esi,[esi+eax+1]
	; Point to parameters
	invoke strcpy,lpBuff,edi
	invoke SendMessage,ha.hProperty,PRM_FINDITEMDATATYPE,lpBuff,esi
	mov		eax,lpBuff
	.if !byte ptr [eax]
		; Skip proc parameters
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		; Skip return type
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		; Point to local
		invoke strcpy,lpBuff,edi
		invoke SendMessage,ha.hProperty,PRM_FINDITEMDATATYPE,lpBuff,esi
	.endif
	mov		eax,lpBuff
	movzx	eax,byte ptr [eax]
	ret

IsWordLocalStruct endp

IsWordDataStruct proc uses esi edi,lpWord:DWORD,lpBuff:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,offset szCCd,lpWord
	.while TRUE
		.break .if !eax
		mov		esi,eax
		lea		edi,buffer
		xor		ecx,ecx
		.while byte ptr [esi+ecx] && byte ptr [esi+ecx]!=':' && ecx<255
			mov		al,[esi+ecx]
			mov		[edi+ecx],al
			inc		ecx
		.endw
		mov		byte ptr [edi+ecx],0
		invoke strcmp,edi,lpWord
		.if !eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			xor		ecx,ecx
			mov		edi,lpBuff
			.while byte ptr [esi+ecx]
				mov		al,[esi+ecx]
				.if al=='*'
					.break
				.endif
				mov		[edi+ecx],al
				inc		ecx
			.endw
			mov		byte ptr [edi+ecx],0
			mov		eax,esi
			.break
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	ret

IsWordDataStruct endp

IsStructItemStruct proc uses esi edi,lpStruct:DWORD,lpItem:DWORD
	LOCAL	buffer[256]:BYTE

	mov		buffer,0
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,offset szCCSs,lpStruct
	.while TRUE
		.break .if !eax
		mov		esi,eax
		invoke strcmp,esi,lpStruct
		.if !eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke strcpyn,addr buffer,lpItem,sizeof buffer
			invoke SendMessage,ha.hProperty,PRM_FINDITEMDATATYPE,addr buffer,esi
			.if buffer
				invoke strcpy,lpStruct,addr buffer
			.endif
			movzx	eax,buffer
			.break
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	ret

IsStructItemStruct endp

UpdateApiList proc uses ebx esi edi,lpWord:DWORD,lpApiType:DWORD
	LOCAL	nCount:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	isinproc:ISINPROC
	LOCAL	ccft:FINDTEXTEX

	mov		nCount,0
	invoke SendMessage,ha.hCC,CCM_CLEAR,0,0
	invoke SendMessage,ha.hCC,WM_SETREDRAW,FALSE,0
	mov		eax,lpWord
	mov		edx,lpApiType
	.if da.cctype==CCTYPE_STRUCT
		call	PreParse
		mov		eax,da.nAsm
		.if eax==nMASM || eax==nTASM
			; Find start
		  NxMASM0:
			mov		esi,offset LineTxt
			mov		edi,esi
			invoke strlen,esi
			.while eax
				.if byte ptr [esi+eax]==')'
					lea		edx,[esi+eax+1]
					push	edx
					.while byte ptr [esi+eax-1]!='(' && eax
						dec		eax
					.endw
					.while byte ptr [esi+eax]==' '
						inc		eax
					.endw
					.while byte ptr [esi+eax]!=' ' && byte ptr [esi+eax]!=')' && byte ptr [esi+eax]
						mov		dl,[esi+eax]
						mov		[edi],dl
						inc		eax
						inc		edi
					.endw
					pop		esi
					invoke strcpy,edi,esi
					jmp		NxMASM0
				.elseif byte ptr [esi+eax]==']'
					lea		edx,[esi+eax]
					push	edx
					.while byte ptr [esi+eax-1]!='['
						dec		eax
					.endw
					.while byte ptr [esi+eax]==' '
						inc		eax
					.endw
					.while byte ptr [esi+eax]!=' ' && byte ptr [esi+eax]!=']' && byte ptr [esi+eax]
						mov		dl,[esi+eax]
						mov		[edi],dl
						inc		eax
						inc		edi
					.endw
					pop		esi
					invoke strcpy,edi,addr [esi+1]
					jmp		NxMASM0
				.endif
				lea		edx,[esi+eax-1]
				.break .if byte ptr [edx]==',' || byte ptr [edx]==' ' || byte ptr [edx]=='(' || byte ptr [edx]=='=' || byte ptr [edx]=='>' || byte ptr [edx]=='<' || byte ptr [edx]=='!' || byte ptr [edx]=='|' || byte ptr [edx]=='&'
				dec		eax
			.endw
			lea		esi,[esi+eax]
			; Parse elements into zero terminated parts
			xor		ecx,ecx
			.while byte ptr [esi+ecx]
				mov		al,[esi+ecx]
				.if al=='.'
					mov		al,0
				.endif
				mov		[edi+ecx],al
				inc		ecx
			.endw
			mov		word ptr [edi+ecx],0
			.if LineTxt
				mov		esi,offset LineTxt
				invoke strcpy,addr buffer,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke IsWordReg,addr buffer
				.if eax
					; assume edx:ptr RECT
					; [edx].left
					invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr ccft.chrg
					mov		ccft.chrg.cpMax,0
					invoke strcpy,addr buffer1,offset szCCAssume
					invoke strcat,addr buffer1,addr buffer
					lea		eax,buffer1
					mov		ccft.lpstrText,eax
				  NxMASM2:
					invoke SendMessage,ha.hEdt,EM_FINDTEXTEX,FR_IGNOREWHITESPACE,addr ccft
					.if eax!=-1
						mov		eax,ccft.chrgText.cpMin
						dec		eax
						mov		ccft.chrg.cpMin,eax
						invoke SendMessage,ha.hEdt,REM_ISCHARPOS,ccft.chrgText.cpMax,0
						.if eax
							jmp		NxMASM2
						.endif
						invoke SendMessage,ha.hEdt,EM_LINEFROMCHAR,ccft.chrgText.cpMin,0
						mov		edx,eax
						mov		word ptr buffer,250
						invoke SendMessage,ha.hEdt,EM_GETLINE,edx,addr buffer
						mov		buffer[eax],0
						xor		eax,eax
						.while buffer[eax] && buffer[eax]!=':'
							inc		eax
						.endw
						.if buffer[eax]!=':'
							jmp		NxMASM2
						.endif
						inc		eax
						.while buffer[eax] && buffer[eax]==VK_SPACE
							inc		eax
						.endw
						.if !buffer[eax]
							jmp		NxMASM2
						.endif
						mov		edx,dword ptr buffer[eax]
						and		edx,5F5F5Fh
						.if edx!='RTP'
							jmp		NxMASM2
						.endif
						add		eax,3
						.while buffer[eax] && buffer[eax]==VK_SPACE
							inc		eax
						.endw
						push	esi
						lea		esi,buffer[eax]
						lea		edi,buffer
						.while TRUE
							movzx	eax,byte ptr [esi]
							invoke GetCharType,eax
							.break .if eax!=1
							mov		al,[esi]
							mov		[edi],al
							inc		esi
							inc		edi
						.endw
						mov		byte ptr [edi],0
						pop		esi
						jmp		NxMASM4
					.else
						; [edx].RECT
						.if !byte ptr [esi]
							mov		buffer,0
							invoke SendMessage,ha.hProperty,PRM_FINDFIRST,offset szCCSs,lpWord
							.while TRUE
								.break .if !eax
								push	eax
								invoke SendMessage,ha.hProperty,PRM_FINDGETTYPE,0,0
								.if eax=='S'
									mov		ecx,4
								.else
									mov		ecx,5
								.endif
								pop		edx
								invoke SendMessage,ha.hCC,CCM_ADDITEM,ecx,edx
								inc		nCount
								invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
							.endw
						.else
							invoke strcpy,addr buffer,esi
							invoke strlen,esi
							lea		esi,[esi+eax+1]
							jmp		NxMASM4
						.endif
					.endif
				.else
					invoke IsWordDataStruct,addr buffer,addr buffer1
					.if eax
						; rc RECT <>
						; rc.left
						invoke strcpy,addr buffer,addr buffer1
						jmp		NxMASM4
					.else
						mov		eax,da.nLastLine
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
							mov		edx,eax
							invoke IsWordLocalStruct,edx,addr buffer,addr buffer1
							.if eax
								; LOCAL rc:RECT
								; rc.left
								invoke strcpy,addr buffer,addr buffer1
							.endif
						.endif
					  NxMASM4:
						invoke IsWordStruct,addr buffer
						.if eax
							.if byte ptr [esi]
								invoke IsStructItemStruct,addr buffer,esi
								.if eax
									invoke strlen,esi
									lea		esi,[esi+eax+1]
									jmp		NxMASM4
								.endif
							.else
								push	eax
								invoke strlen,eax
								pop		edx
								lea		edx,[edx+eax+1]
								invoke AddList,edx,lpWord,15
								mov		nCount,eax
							.endif
						.endif
					.endif
				.endif
			.endif
		.elseif eax==nGOASM || eax==nFASM || eax==nSOLASM
			; Find start
			mov		esi,offset LineTxt
			mov		edi,esi
			invoke strlen,esi
			.while byte ptr [esi+eax-1]!='[' && byte ptr [esi+eax-1]!='+' && byte ptr [esi+eax-1]!=',' && byte ptr [esi+eax-1]!=' ' && eax
				dec		eax
			.endw
			lea		esi,[esi+eax]
			; Parse elements into zero terminated parts
			xor		ecx,ecx
			.while byte ptr [esi+ecx]
				mov		al,[esi+ecx]
				.if al=='.'
					mov		al,0
				.endif
				mov		[edi+ecx],al
				inc		ecx
			.endw
			mov		word ptr [edi+ecx],0
			.if LineTxt
				; LOCAL ms:MYSTRUCT
				; mov D[ms.aa],0
				; lea eax,ms
				; mov D[eax+MYSTRUCT.aa],0
				; mov eax,RECT.left
				mov		esi,offset LineTxt
				invoke strcpy,addr buffer,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke IsWordDataStruct,addr buffer,addr buffer1
				.if eax
					invoke strcpy,addr buffer,addr buffer1
					jmp		@f
				.else
					mov		eax,da.nLastLine
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
						mov		edx,eax
						invoke IsWordLocalStruct,edx,addr buffer,addr buffer1
						.if eax
							invoke strcpy,addr buffer,addr buffer1
						.endif
					.endif
				  @@:
					invoke IsWordStruct,addr buffer
					.if eax
						.if byte ptr [esi]
							invoke IsStructItemStruct,addr buffer,esi
							.if eax
								invoke strlen,esi
								lea		esi,[esi+eax+1]
								jmp		@b
							.endif
						.else
							push	eax
							invoke strlen,eax
							pop		edx
							lea		edx,[edx+eax+1]
							invoke AddList,edx,lpWord,15
							mov		nCount,eax
						.endif
					.endif
				.endif
			.endif
		.elseif eax==nCPP
;			call	PreParse
			mov		esi,offset LineTxt
			; Find start
			invoke strlen,esi
			.if byte ptr [esi+eax-1]=='-'
				mov		byte ptr [esi+eax-1],0
				dec		eax
			.endif
			.while eax
				.break .if byte ptr [esi+eax-1]=='+' || byte ptr [esi+eax-1]=='-' || byte ptr [esi+eax-1]==',' || byte ptr [esi+eax-1]==' ' || byte ptr [esi+eax-1]==VK_TAB || !eax
				.if eax>=2
					.if word ptr [esi+eax-2]=='>-'
						dec		eax
					.endif
				.endif
				dec		eax
			.endw
			lea		esi,[esi+eax]
			mov		edi,offset LineTxt
			; Parse elements into zero terminated parts
			xor		ecx,ecx
			.while byte ptr [esi+ecx]
				mov		ax,[esi+ecx]
				.if al=='.'
					mov		al,0
					mov		[edi+ecx],al
				.elseif ax=='>-'
					mov		al,0
					mov		[edi+ecx],al
					inc		ecx
					dec		edi
				.else
					mov		[edi+ecx],al
				.endif
				inc		ecx
			.endw
			mov		word ptr [edi+ecx],0
			.if LineTxt
				;Global or local
				;MYSTRUCT ms;
				mov		esi,offset LineTxt
				invoke strcpy,addr buffer,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke IsWordDataStruct,addr buffer,addr buffer1
				.if eax
					invoke strcpy,addr buffer,addr buffer1
					jmp		@f
				.else
					mov		eax,da.nLastLine
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
						mov		edx,eax
						invoke IsWordLocalStruct,edx,addr buffer,addr buffer1
						.if eax
							invoke strcpy,addr buffer,addr buffer1
						.endif
					.endif
				  @@:
					invoke IsWordStruct,addr buffer
					.if eax
						.if byte ptr [esi]
							invoke IsStructItemStruct,addr buffer,esi
							.if eax
								invoke strlen,esi
								lea		esi,[esi+eax+1]
								jmp		@b
							.endif
						.else
							push	eax
							invoke strlen,eax
							pop		edx
							lea		edx,[edx+eax+1]
							invoke AddList,edx,lpWord,15
							mov		nCount,eax
						.endif
					.endif
				.endif
			.endif
		.endif
	.elseif byte ptr [eax] || da.cctype==CCTYPE_ALL
		invoke SendMessage,ha.hProperty,PRM_FINDFIRST,lpApiType,lpWord
		.while TRUE
			.break .if !eax
			push	eax
			invoke SendMessage,ha.hProperty,PRM_FINDGETTYPE,0,0
			xor		ecx,ecx
			.if eax=='p'
				mov		ecx,1
			.elseif eax=='W'
				mov		ecx,2
			.elseif eax=='c'
				mov		ecx,3
			.elseif eax=='d'
				mov		ecx,14
			.elseif eax=='S'
				mov		ecx,4
			.elseif eax=='s'
				mov		ecx,5
			.elseif eax=='m'
				mov		ecx,6
			.endif
			pop		edx
			invoke SendMessage,ha.hCC,CCM_ADDITEM,ecx,edx
			inc		nCount
			invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		.endw
		.if da.cctype==CCTYPE_ALL
			mov		eax,da.nLastLine
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
				mov		ebx,offset cclist
				; Skip proc name and point to parameters
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				.if byte ptr [esi]
					push	esi
					invoke strcpy,addr tmpbuff,esi
					invoke strcat,addr tmpbuff,addr szComma
					mov		esi,offset tmpbuff
					mov		edx,esi
					.while byte ptr [esi]
						.if byte ptr [esi]==','
							mov		byte ptr [esi],0
							call Filter
							.if !eax
								invoke strcpy,ebx,edx
								invoke SendMessage,ha.hCC,CCM_ADDITEM,8,ebx
								invoke strlen,ebx
								lea		ebx,[ebx+eax+1]
								inc		nCount
							.endif
							lea		edx,[esi+1]
						.endif
						inc		esi
					.endw
					pop		esi
				.endif
				; Skip return type
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				; Point to locals
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke strcpy,addr tmpbuff,esi
				invoke strcat,addr tmpbuff,addr szComma
				mov		esi,offset tmpbuff
				mov		edx,esi
				.while byte ptr [esi]
					.if byte ptr [esi]==','
						mov		byte ptr [esi],0
						call Filter
						.if !eax
							invoke strcpy,ebx,edx
							invoke SendMessage,ha.hCC,CCM_ADDITEM,9,ebx
							invoke strlen,ebx
							lea		ebx,[ebx+eax+1]
							inc		nCount
						.endif
						lea		edx,[esi+1]
					.endif
					inc		esi
				.endw
			.endif
		.endif
	.endif
	.if nCount
		.if da.cctype!=CCTYPE_STRUCT
			invoke SendMessage,ha.hCC,CCM_SORT,FALSE,0
		.endif
		invoke SendMessage,ha.hCC,CCM_SETCURSEL,0,0
	.endif
	invoke SendMessage,ha.hCC,WM_SETREDRAW,TRUE,0
	mov		eax,nCount
	ret

PreParse:
	mov		esi,offset LineTxt
	mov		edi,esi
	;Skip white space
	.while (byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB) && byte ptr [esi]
		mov		byte ptr [esi],VK_SPACE
		inc		esi
	.endw
	push	esi
	.while byte ptr [esi]
		.if byte ptr [esi]==VK_TAB
			mov		byte ptr [esi],VK_SPACE
		.endif
		inc		esi
	.endw
	pop		esi
	mov		ebx,da.lpCharTab
	.while byte ptr [esi]
		movzx	eax,byte ptr [esi]
		.if byte ptr [ebx+eax]==CT_CHAR
			mov		[edi],al
			inc		edi
		.elseif edi>offset LineTxt
			movzx	edx,byte ptr [edi-1]
			.if byte ptr [ebx+edx]==CT_CHAR
				mov		[edi],al
				inc		edi
			.elseif eax!=VK_SPACE
				.if edx==VK_SPACE
					mov		[edi-1],al
				.else
					mov		[edi],al
					inc		edi
				.endif
			.endif
		.elseif eax!=VK_SPACE
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	mov		byte ptr [edi],0
	retn

Filter:
	push	edx
	mov		ecx,lpWord
  @@:
	mov		al,[ecx]
	.if al
		mov		ah,[edx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		inc		edx
		inc		ecx
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	pop		edx
	retn

UpdateApiList endp

UpdateApiConstList proc uses esi edi,lpApi:DWORD,lpWord:DWORD,lpCPos:DWORD

	mov		eax,lpWord
  @@:
	.while (byte ptr [eax]==VK_SPACE || byte ptr [eax]==VK_TAB) && eax<lpCPos
		inc		eax
	.endw
	mov		lpWord,eax
	.while byte ptr [eax] && byte ptr [eax]!=',' && eax<lpCPos
		.if byte ptr [eax]==VK_SPACE || byte ptr [eax]==VK_TAB
			jmp		@b
		.endif
		inc		eax
	.endw
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke SendMessage,ha.hCC,CCM_CLEAR,0,0
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr szCCC,lpApi
	.while eax
		mov		esi,eax
		invoke strcmpi,esi,lpApi
		.if !eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			.if byte ptr [edi]
				invoke strcat,edi,addr szComma
			.endif
			invoke strcat,edi,esi
		.endif
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,addr szCCC,lpApi
	.endw
	.if byte ptr [edi]
		invoke AddList,edi,lpWord,2
		.if eax
			invoke SendMessage,ha.hCC,CCM_SORT,FALSE,0
			invoke SendMessage,ha.hCC,CCM_SETCURSEL,0,0
			mov		eax,lpWord
		.endif
	.else
		xor		eax,eax
	.endif
	push	eax
	invoke GlobalFree,edi
	pop		eax
	ret

UpdateApiConstList endp

UpdateApiToolTip proc uses esi edi,lpWord:DWORD

	invoke RtlZeroMemory,addr tt,sizeof TOOLTIP
	mov		eax,lpWord
	.if byte ptr [eax]
		mov		tt.lpszType,offset szCCPp
		mov		tt.lpszLine,eax
		xor		edx,edx
		.if da.nAsm==nCPP
			mov		edx,TT_PARANTESES
		.endif
		invoke SendMessage,ha.hProperty,PRM_GETTOOLTIP,edx,addr tt
	.endif
	ret

UpdateApiToolTip endp

IsLineInvoke proc uses ebx,cpline:DWORD

	mov		edx,offset LineTxt
	mov		ebx,cpline
	call	SkipWhiteSpace
	mov		ecx,offset da.szCCTrig
	.if byte ptr [ecx]
		.while byte ptr [ecx]
			push	ecx
			push	edx
			push	ebx
			call	TestWord
			pop		ebx
			pop		edx
			pop		ecx
			.break .if eax
			;Next szCCTrig
			.while byte ptr [ecx]
				inc		ecx
			.endw
			inc		ecx
			.break .if !byte ptr [ecx]
		.endw
	.endif
	ret

SkipWhiteSpace:
	.while (byte ptr [edx]==VK_TAB || byte ptr [edx]==VK_SPACE) && ebx
		inc		edx
		dec		ebx
	.endw
	retn

TestWord:
	dec		ecx
	dec		edx
	inc		ebx
  @@:
	inc		ecx
	inc		edx
	dec		ebx
	je		@f
	mov		al,[ecx]
	.if al
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		mov		ah,[edx]
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	.if !eax
		call	SkipWhiteSpace
		.if byte ptr [edx]=='('
			inc		edx
		.endif
		call	SkipWhiteSpace
		mov		eax,edx
		sub		eax,offset LineTxt
	.else
  @@:
		xor		eax,eax
	.endif
	retn

IsLineInvoke endp

ApiListBox proc uses ebx esi edi,lpRASELCHANGE:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	cpline:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpRASELCHANGE
	mov		eax,[esi].RASELCHANGE.chrg.cpMin
	mov		edx,[esi].RASELCHANGE.cpLine
	mov		da.ccchrg.cpMin,edx
	mov		da.ccchrg.cpMax,eax
	sub		eax,edx
	mov		cpline,eax
	inc		eax
	.if eax<256
		mov		edx,[esi].RASELCHANGE.lpLine
		lea		edx,[edx+sizeof CHARS]
		invoke strcpyn,offset LineTxt,edx,eax
		.if da.cctype==CCTYPE_ALL
			call	GetWordLeft
			invoke strlen,addr buffer
			mov		edx,da.ccchrg.cpMax
			sub		edx,eax
			mov		da.ccchrg.cpMin,edx
			invoke UpdateApiList,addr buffer,offset szCCAll
			.if eax
				call	ShowList
			.endif
		.elseif da.cctype==CCTYPE_STRUCT
			call	GetWordLeft
			invoke strlen,addr buffer
			mov		edx,cpline
			sub		edx,eax
			mov		byte ptr LineTxt[edx-1],0
			mov		edx,da.ccchrg.cpMax
			sub		edx,eax
			mov		da.ccchrg.cpMin,edx
			invoke UpdateApiList,addr buffer,offset szCCSs
			.if eax
				call	ShowList
			.else
				call	HideAll
			.endif
		.elseif da.cctype==CCTYPE_USER
			call	GetWordLeft
			invoke strlen,addr buffer
			mov		edx,da.ccchrg.cpMax
			sub		edx,eax
			mov		da.ccchrg.cpMin,edx
			invoke SendMessage,ha.hCC,CCM_SETCURSEL,0,0
			call	ShowList
		.elseif da.cctype==CCTYPE_USERTOOLTIP
			call	ShowTooltip
		.elseif da.nAsm==nCPP || da.nAsm==nFREEBASIC || da.nAsm==nFREEPASCAL
			mov		esi,offset LineTxt
			add		da.ccchrg.cpMin,eax
			xor		eax,eax
			.while byte ptr [esi+eax]==VK_SPACE || byte ptr [esi+eax]==VK_TAB
				inc		eax
			.endw
			lea		esi,LineTxt[eax]
			call	DoItCpp
		.else
			invoke IsLineInvoke,cpline
			.if eax
				add		da.ccchrg.cpMin,eax
				lea		esi,LineTxt[eax]
				call	DoIt
			.else
				call	HideAll
			.endif
		.endif
	.else
		call	HideAll
	.endif
	ret

GetWordLeft:
	mov		esi,offset LineTxt
	mov		ebx,da.lpCharTab
	invoke strlen,esi
	lea		edi,buffer
	xor		ecx,ecx
	.while eax
		dec		eax
		movzx	edx,byte ptr [esi+eax]
		.if byte ptr [ebx+edx]!=CT_CHAR
			inc		eax
			.while byte ptr [esi+eax] && ecx<255
				mov		dl,[esi+eax]
				mov		[edi],dl
				inc		eax
				inc		edi
				inc		ecx
			.endw
			.break
		.elseif !eax
			.while byte ptr [esi+eax] && ecx<255
				mov		dl,[esi+eax]
				mov		[edi],dl
				inc		eax
				inc		edi
				inc		ecx
			.endw
			.break
		.endif
	.endw
	mov		byte ptr [edi],0
	retn

SkipScope:
	xor		eax,eax
	xor		ecx,ecx
	call	SkipScope1
	retn

SkipScope1:
	or		edi,edi
	je		@f
	mov		al,[esi+edi]
	dec		edi
	.if al==ah
		dec		ecx
		retn
	.elseif al==']'
		push	eax
		inc		ecx
		mov		ah,'['
		call	SkipScope1
		pop		eax
	.elseif al==')'
		push	eax
		inc		ecx
		mov		ah,'('
		call	SkipScope1
		pop		eax
	.elseif al=='}'
		; Begin / End
		push	eax
		inc		ecx
		mov		ah,'{'
		call	SkipScope1
		pop		eax
	.elseif al=='"' || al=="'"
		; String
		inc		ecx
		.while al!=[esi+edi] && edi
			dec		edi
		.endw
		.if al==[esi+edi]
			dec		edi
			dec		ecx
		.endif
	.endif
	or		ecx,ecx
	jne		SkipScope1
  @@:
	retn

DoIt:
	invoke UpdateApiList,esi,offset szCCPp
	.if eax
		mov		da.cctype,CCTYPE_PROC
		call	ShowList
	.else
DoItCpp:
		invoke IsWindowVisible,ha.hCC
		.if eax
			invoke PostAddinMessage,ha.hWnd,AIM_CODECOMPLETESHOW,-1,ha.hCC,0,HOOK_CODECOMPLETESHOW
			invoke ShowWindow,ha.hCC,SW_HIDE
		.endif
		mov		da.cctype,CCTYPE_NONE
		invoke UpdateApiToolTip,esi
		.if tt.lpszApi
			mov		eax,cpline
			add		eax,offset LineTxt
			sub		eax,esi
			xor		ecx,ecx
			xor		edx,edx
			.while edx<eax
				.if byte ptr [esi+edx]=="'"
					inc		edx
					.while edx<eax && byte ptr [esi+edx]!="'"
						inc		edx
					.endw
				.elseif byte ptr [esi+edx]=='"'
					inc		edx
					.while edx<eax && byte ptr [esi+edx]!='"'
						inc		edx
					.endw
				.elseif byte ptr [esi+edx]==',' || byte ptr [esi+edx]=='('
					inc		ecx
					lea		edi,[esi+edx+1]
				.endif
				inc		edx
			.endw
			invoke SendMessage,ha.hProperty,PRM_ISTOOLTIPMESSAGE,offset ttmsg,addr tt
			.if eax
				invoke AddList,eax,edi,2
				sub		edi,offset LineTxt
				mov		esi,lpRASELCHANGE
				add		edi,[esi].RASELCHANGE.cpLine
				mov		da.ccchrg.cpMin,edi
				mov		da.cctype,CCTYPE_CONST
				;invoke SendMessage,ha.hCC,CCM_SORT,FALSE,0
				invoke SendMessage,ha.hCC,CCM_SETCURSEL,0,0
				call	ShowList
			.else
				mov		da.cctype,CCTYPE_TOOLTIP
				mov		da.tti.lpszRetType,0
				mov		da.tti.lpszDesc,0
				mov		da.tti.novr,0
				mov		da.tti.nsel,0
				mov		da.tti.nwidth,0
				mov		eax,tt.ovr.lpszParam
				mov		edx,tt.lpszApi
				mov		ecx,tt.nPos
				mov		da.tti.lpszApi,edx
				mov		da.tti.lpszParam,eax
				mov		da.tti.nitem,ecx
				inc		ecx
				invoke BinToDec,ecx,addr buffer
				invoke strcat,addr buffer,da.tti.lpszApi
				mov		eax,cpline
				add		eax,offset LineTxt
				invoke UpdateApiConstList,addr buffer,edi,eax
				.if eax
					mov		da.cctype,CCTYPE_CONST
					mov		edi,eax
					sub		edi,offset LineTxt
					mov		esi,lpRASELCHANGE
					add		edi,[esi].RASELCHANGE.cpLine
					mov		da.ccchrg.cpMin,edi
					mov		eax,[esi].RASELCHANGE.chrg.cpMin
					sub		eax,[esi].RASELCHANGE.cpLine
					.while byte ptr LineTxt[eax] && byte ptr LineTxt[eax]!=VK_SPACE && byte ptr LineTxt[eax]!=VK_TAB && byte ptr LineTxt[eax]!=','
						inc		eax
					.endw
					add		eax,[esi].RASELCHANGE.cpLine
					mov		da.ccchrg.cpMax,eax
					call	ShowList
				.else
					mov		da.cctype,CCTYPE_TOOLTIP
					call	ShowTooltip
				.endif
			.endif
		.else
			call	HideAll
		.endif
	.endif
	retn

HideAll:
	mov		da.cctype,CCTYPE_NONE
	invoke ShowWindow,ha.hTT,SW_HIDE
	invoke IsWindowVisible,ha.hCC
	.if eax
		invoke PostAddinMessage,ha.hWnd,AIM_CODECOMPLETESHOW,-1,ha.hCC,0,HOOK_CODECOMPLETESHOW
		invoke ShowWindow,ha.hCC,SW_HIDE
	.endif
	retn

ShowList:
	invoke ShowWindow,ha.hTT,SW_HIDE
	invoke GetCaretPos,addr pt
	invoke ClientToScreen,ha.hEdt,addr pt
	invoke ScreenToClient,ha.hWnd,addr pt
	invoke GetClientRect,ha.hWnd,addr rect
	mov		eax,pt.y
	add		eax,da.win.ccht
	add		eax,20
	.if eax>rect.bottom
		mov		eax,da.win.ccht
		add		eax,5
		sub		pt.y,eax
	.else
		add		pt.y,20
	.endif
	invoke SetWindowPos,ha.hCC,HWND_TOP,pt.x,pt.y,da.win.ccwt,da.win.ccht,SWP_SHOWWINDOW or SWP_NOACTIVATE
	invoke PostAddinMessage,ha.hWnd,AIM_CODECOMPLETESHOW,-2,ha.hCC,0,HOOK_CODECOMPLETESHOW
	invoke ShowWindow,ha.hCC,SW_SHOWNA
	retn

ShowTooltip:
	invoke IsWindowVisible,ha.hCC
	.if eax
		invoke PostAddinMessage,ha.hWnd,AIM_CODECOMPLETESHOW,-1,ha.hCC,0,HOOK_CODECOMPLETESHOW
		invoke ShowWindow,ha.hCC,SW_HIDE
	.endif
	invoke GetCaretPos,addr pt
	invoke ClientToScreen,ha.hEdt,addr pt
	add		pt.y,20
	invoke SendMessage,ha.hTT,TTM_SETITEM,0,addr da.tti
	sub		pt.x,eax
	invoke SetWindowPos,ha.hTT,HWND_TOP,pt.x,pt.y,0,0,SWP_NOACTIVATE or SWP_NOSIZE
	invoke ShowWindow,ha.hTT,SW_SHOWNA
	invoke InvalidateRect,ha.hTT,NULL,TRUE
	retn

ApiListBox endp

CaseConvertWord proc uses ebx,wParam:DWORD,cp:DWORD

	.if da.edtopt.fopt & EDTOPT_CASECONVERT
		invoke GetCharType,wParam
		.if eax!=1
			invoke SendMessage,ha.hEdt,REM_ISCHARPOS,cp,0
			.if !eax
				invoke SendMessage,ha.hEdt,REM_SETCHARTAB,'.',CT_CHAR
				invoke SendMessage,ha.hEdt,REM_GETWORDFROMPOS,cp,addr tmpbuff
				.if eax
					invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr szCaseTypes,addr tmpbuff
					mov		ebx,eax
					.while ebx
						invoke strcmpi,ebx,addr tmpbuff
						.if !eax
							invoke SendMessage,ha.hEdt,REM_CASEWORD,cp,ebx
							invoke SendMessage,ha.hEdt,EM_LINEFROMCHAR,cp,0
							invoke SendMessage,ha.hEdt,REM_INVALIDATELINE,eax,0
							.break
						.endif
						invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
						mov		ebx,eax
					.endw
				.endif
				invoke SendMessage,ha.hEdt,REM_SETCHARTAB,'.',CT_HICHAR
			.endif
		.endif
	.endif
	ret

CaseConvertWord endp

BlockComplete proc uses ebx esi edi,hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	chrg1:CHARRANGE
	LOCAL	ln:DWORD
	LOCAL	lx:DWORD
	LOCAL	lz:DWORD
	LOCAL	tp:DWORD
	LOCAL	buffer[256]:BYTE

	;Get linenumber where return was pressed
	invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,ha.hEdt,EM_LINEFROMCHAR,chrg.cpMin,0
	dec		eax
	mov		ln,eax
	invoke SendMessage,ha.hEdt,REM_GETBOOKMARK,ln,0
	.if eax==1
		;The line is a block, find block type
		mov		edi,offset da.rabd
		.while [edi].RABLOCKDEF.lpszStart
			mov		eax,[edi].RABLOCKDEF.flag
			and		eax,0F0000h
			.if !eax
				invoke SendMessage,ha.hEdt,REM_ISLINE,ln,[edi].RABLOCKDEF.lpszStart
				.if eax!=-1
					;Block type found
					.break .if ![edi].RABLOCKDEF.lpszEnd
					mov		eax,ln
					inc		eax
					mov		lx,eax
					mov		lz,0
					.while lx!=-1
						invoke SendMessage,ha.hEdt,REM_PRVBOOKMARK,lx,1
						mov		lx,eax
						.if lx!=-1
							invoke SendMessage,ha.hEdt,REM_GETBLOCKEND,lx,0
							.if !eax
								dec		eax
							.endif
							mov		lz,eax
							mov		tp,0
							.if eax==-1
								invoke SendMessage,ha.hEdt,REM_ISLINE,lx,[edi].RABLOCKDEF.lpszStart
								mov		tp,eax
								.break
							.elseif eax>ln
								invoke SendMessage,ha.hEdt,REM_ISLINE,lx,[edi].RABLOCKDEF.lpszStart
								mov		tp,eax
								.break .if tp==-1
							.endif
						.endif
					.endw
					.if lz!=-1 || tp==-1
						call	InsertTab
						.break 
					.endif
					;Do the block complete
					invoke SendMessage,ha.hEdt,REM_LOCKUNDOID,TRUE,0
					invoke SendMessage,hWin,WM_CHAR,VK_RETURN,0
					mov		eax,[edi].RABLOCKDEF.lpszEnd
					.if byte ptr [eax]=='?' || byte ptr [eax]=='$'
						;Skip indent
						mov		word ptr buffer,255
						invoke SendMessage,ha.hEdt,EM_GETLINE,ln,addr buffer
						mov		buffer[eax],0
						xor		ebx,ebx
						.while buffer[ebx] && (buffer[ebx]==VK_TAB || buffer[ebx]==VK_SPACE)
							inc		ebx
						.endw
						;Get name
						push	ebx
						.while buffer[ebx] && buffer[ebx]!=VK_TAB && buffer[ebx]!=VK_SPACE
							inc		ebx
						.endw
						mov		buffer[ebx],0
						pop		ebx
						mov		esi,[edi].RABLOCKDEF.lpszStart
						.while byte ptr [esi]
							.if byte ptr [esi]=='?' || byte ptr [esi]=='$'
								add		esi,2
							.endif
							invoke strcmpi,addr buffer[ebx],esi
							.break .if !eax
							invoke strlen,esi
							lea		esi,[esi+eax+1]
						.endw
						.if eax
							invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,addr buffer[ebx]
							mov		word ptr buffer,VK_SPACE
							invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,addr buffer
						.endif
						mov		eax,[edi].RABLOCKDEF.lpszEnd
						add		eax,2
					.endif
					invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,eax
					invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg1
					invoke CaseConvertWord,VK_RETURN,chrg1.cpMin
					invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
					call	InsertTab
					invoke SendMessage,ha.hEdt,REM_LOCKUNDOID,FALSE,0
					.break
				.endif
			.endif
			lea		edi,[edi+sizeof RABLOCKDEF]
		.endw
	.endif
	ret

InsertTab:
	.if da.edtopt.fopt & EDTOPT_EXPTAB
		xor		ecx,ecx
		.while ecx<da.edtopt.tabsize
			mov		buffer[ecx],' '
			inc		ecx
		.endw
		mov		buffer[ecx],0
	.else
		mov		word ptr buffer,VK_TAB
	.endif
	invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,addr buffer
	invoke SendMessage,ha.hEdt,EM_SCROLLCARET,0,0
	retn

BlockComplete endp
