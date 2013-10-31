.data

szNOTStyle			db 'NOT WS_VISIBLE|',0
szNOTStyleHex		db 'NOT 0x10000000|',0
szDupTab			db 0Dh,0Ah,'Duplicate TabIndex',0
szMissTab			db 0Dh,0Ah,'Missing TabIndex',0


.code

SaveCtlSize proc uses ebx edx esi

	mov		eax,[esi].DIALOG.dux
	invoke SaveVal,eax,TRUE
	mov		eax,[esi].DIALOG.duy
	invoke SaveVal,eax,TRUE
	mov		eax,[esi].DIALOG.duccx
	invoke SaveVal,eax,TRUE
	mov		eax,[esi].DIALOG.duccy
	invoke SaveVal,eax,FALSE
	ret

SaveCtlSize endp

SaveType proc uses edx esi edi

	invoke GetTypePtr,[esi].DIALOG.ntype
	mov		edx,eax
	invoke SaveStr,edi,[edx].TYPES.lprc
	ret

SaveType endp

SaveName proc uses esi edi
	LOCAL	buffer[16]:BYTE

	mov		al,[esi].DIALOG.idname
	.if al
		invoke SaveStr,edi,addr [esi].DIALOG.idname
	.else
		invoke ResEdBinToDec,[esi].DIALOG.id,addr buffer
		invoke SaveStr,edi,addr buffer
	.endif
	ret

SaveName endp

SaveCaption proc

	mov		al,22h
	stosb
	lea		edx,[esi].DIALOG.caption
  @@:
	mov		al,[edx]
	.if al=='"'
		mov		[edi],al
		inc		edi
	.endif
	mov		[edi],al
	inc		edx
	inc		edi
	or		al,al
	jne		@b
	dec		edi
	mov		al,22h
	stosb
	ret

SaveCaption endp

SaveClass proc
	LOCAL	lpclass:DWORD

	invoke GetTypePtr,[esi].DIALOG.ntype
	push	[eax].TYPES.lpclass
	pop		lpclass
	mov		al,22h
	stosb
	invoke SaveStr,edi,lpclass
	add		edi,eax
	mov		al,22h
	stosb
	ret

SaveClass endp

SaveUDCClass proc

	mov		al,22h
	stosb
	invoke SaveStr,edi,addr [esi].DIALOG.class
	add		edi,eax
	mov		al,22h
	stosb
	ret

SaveUDCClass endp

SaveDlgClass proc

	mov		al,[esi].DLGHEAD.class
	.if al
		invoke SaveStr,edi,addr szCLASS
		add		edi,eax
		mov		al,' '
		stosb
		mov		al,22h
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.class
		add		edi,eax
		mov		al,22h
		stosb
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgClass endp

SaveDlgFont proc
	LOCAL	buffer[512]:BYTE
	LOCAL	val:DWORD

	mov		al,[esi].DLGHEAD.font
	.if al
		invoke SaveStr,edi,addr szFONT
		add		edi,eax
		mov		al,' '
		stosb
		push	[esi].DLGHEAD.fontsize
		pop		val
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		mov		ax,' ,'
		stosw
		mov     al,'"'
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.font
		add		edi,eax
		mov     al,'"'
		stosb
		mov		ax,' ,'
		stosw
		movzx	eax,[esi].DLGHEAD.weight
		mov		val,eax
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		mov		ax,' ,'
		stosw
		movzx	eax,[esi].DLGHEAD.italic
		mov		val,eax
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		invoke GetWindowLong,hRes,GWL_STYLE
		test	eax,DES_BORLAND
		.if ZERO?
			movzx	eax,[esi].DLGHEAD.charset
			mov		val,eax
			mov		ax,' ,'
			stosw
			invoke ResEdBinToDec,val,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
		.endif
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgFont endp

SaveDlgMenu proc

	mov		al,[esi].DLGHEAD.menuid
	.if al
		invoke SaveStr,edi,addr szMENU
		add		edi,eax
		mov		al,' '
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.menuid
		add		edi,eax
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgMenu endp

SaveStyle proc uses ebx esi,nStyle:DWORD,nType:DWORD,fComma:DWORD
	LOCAL	nst:DWORD
	LOCAL	ncount:DWORD
	LOCAL	npos:DWORD

	.if fStyleHex
		invoke SaveHexVal,nStyle,fComma
	.else
		mov		nst,0
		mov		ncount,0
		mov		npos,edi
		push	edi
		mov		dword ptr namebuff,0
		mov		ebx,offset types
		mov		eax,nType
		.while eax!=[ebx].RSTYPES.ctlid && [ebx].RSTYPES.ctlid!=-1
			lea		ebx,[ebx+sizeof RSTYPES]
		.endw
		.if byte ptr [ebx].RSTYPES.style1
			lea		esi,[ebx].RSTYPES.style1
			call	AddStyles
		.endif
		.if byte ptr [ebx].RSTYPES.style2
			lea		esi,[ebx].RSTYPES.style2
			call	AddStyles
		.endif
		.if byte ptr [ebx].RSTYPES.style3
			lea		esi,[ebx].RSTYPES.style3
			call	AddStyles
		.endif
		pop		edi
		invoke strcpy,edi,offset namebuff+1
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		eax,nst
		.if eax!=nStyle
			.if ncount
				mov		byte ptr [edi],'|'
				inc		edi
			.endif
			xor		eax,nStyle
			invoke SaveHexVal,eax,fComma
		.elseif fComma
			mov		ax,' ,'
			stosw
		.endif
	.endif
	ret

Compare:
	xor		eax,eax
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		sub		al,[edi+ecx+8]
		.break .if eax
		inc		ecx
	.endw
	retn

AddStyles:
	.if [ebx].RSTYPES.ctlid
		mov		edi,offset srtstyledef
	.else
		mov		edi,offset srtstyledefdlg
	.endif
	mov		edx,nStyle
	.while dword ptr [edi]
		push	edi
		mov		edi,[edi]
		push	edx
		call	Compare
		pop		edx
		.if !eax
			mov		eax,edx
			and		eax,[edi+4]
			.if eax==[edi] && eax
				xor		ecx,ecx
				.if nType==1
					push	eax
					push	edx
					invoke IsNotStyle,addr [edi+8],offset editnot
					mov		ecx,eax
					pop		edx
					pop		eax
				.elseif nType==22
					push	eax
					push	edx
					invoke IsNotStyle,addr [edi+8],offset richednot
					mov		ecx,eax
					pop		edx
					pop		eax
				.endif
				.if !ecx
					or		nst,eax
					inc		ncount
					xor		edx,eax
					push	edx
					invoke strcat,offset namebuff,offset szOR
					invoke strcat,offset namebuff,addr [edi+8]
					pop		edx
				.endif
			.endif
		.endif
		pop		edi
		lea		edi,[edi+4]
	.endw
	retn

SaveStyle endp

SaveExStyle proc uses ebx esi,nExStyle:DWORD
	LOCAL	buffer1[8]:BYTE
	LOCAL	nst:DWORD
	LOCAL	ncount:DWORD
	LOCAL	npos:DWORD

	.if fStyleHex
		invoke SaveHexVal,nExStyle,FALSE
	.else
		mov		nst,0
		mov		ncount,0
		mov		npos,edi
		mov		dword ptr buffer1,'E_SW'
		mov		dword ptr buffer1[4],'_X'
		push	edi
		mov		dword ptr namebuff,0
		lea		esi,buffer1
		call	AddStyles
		pop		edi
		invoke strcpy,edi,offset namebuff+1
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		eax,nst
		.if eax!=nExStyle
			.if ncount
				mov		byte ptr [edi],'|'
				inc		edi
			.endif
			xor		eax,nExStyle
			invoke SaveHexVal,eax,FALSE
		.endif
	.endif
	ret

Compare:
	xor		eax,eax
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		sub		al,[edi+ecx+8]
		.break .if eax
		inc		ecx
	.endw
	retn

AddStyles:
	mov		edi,offset srtexstyledef
	mov		edx,nExStyle
	.while dword ptr [edi]
		push	edi
		mov		edi,[edi]
		push	edx
		call	Compare
		pop		edx
		.if !eax
			mov		eax,edx
			and		eax,[edi+4]
			.if eax==[edi] && eax
				or		nst,eax
				inc		ncount
				xor		edx,eax
				push	edx
				invoke strcat,offset namebuff,offset szOR
				invoke strcat,offset namebuff,addr [edi+8]
				pop		edx
			.endif
		.endif
		pop		edi
		lea		edi,[edi+4]
	.endw
	retn

SaveExStyle endp

SaveCtl proc uses ebx esi edi
	LOCAL	buffer[512]:BYTE

	;Is ctl deleted
	mov		eax,[esi].DIALOG.hwnd
	.if eax!=-1
		mov		eax,[esi].DIALOG.ntype
		.if eax==0
			;Dialog
			invoke SaveName
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveCtlSize
			mov		edx,[esi].DIALOG.helpid
			.if edx
				mov		ax,' ,'
				stosw
				invoke ResEdBinToDec,edx,addr buffer
				invoke SaveStr,edi,addr buffer
				add		edi,eax
			.endif
			mov		eax,0A0Dh
			stosw
			mov		al,[esi].DIALOG.caption
			.if al
				invoke SaveStr,edi,addr szCAPTION
				add		edi,eax
				mov		al,20h
				stosb
				invoke SaveCaption
				mov		ax,0A0Dh
				stosw
			.endif
			;These are stored in DLGHEAD
			sub		esi,sizeof DLGHEAD
			invoke SaveDlgFont
			invoke SaveDlgClass
			.if byte ptr [esi].DLGHEAD.menuid
				invoke SaveDlgMenu
			.endif
			.if [esi].DLGHEAD.lang || [esi].DLGHEAD.sublang
				invoke SaveLanguage,addr [esi].DLGHEAD.lang,edi
				add		edi,eax
			.endif
			add		esi,sizeof DLGHEAD
			invoke SaveStr,edi,addr szSTYLE
			add		edi,eax
			mov		al,' '
			stosb
			mov		eax,[esi].DIALOG.style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				.if fStyleHex
					invoke SaveStr,edi,addr szNOTStyleHex
				.else
					invoke SaveStr,edi,addr szNOTStyle
				.endif
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].DIALOG.style,[esi].DIALOG.ntype,FALSE
			mov		ax,0A0Dh
			stosw
			.if [esi].DIALOG.exstyle
				invoke SaveStr,edi,addr szEXSTYLE
				add		edi,eax
				mov		al,' '
				stosb
				invoke SaveExStyle,[esi].DIALOG.exstyle
				mov		ax,0A0Dh
				stosw
			.endif
			invoke SaveStr,edi,addr szBEGIN
			add		edi,eax
			mov		ax,0A0Dh
			stosw
		.elseif eax==23
			;UserDefinedControl
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			;Caption
			invoke SaveCaption
			mov		ax,' ,'
			stosw
			invoke SaveName
			add		edi,eax
			mov		ax,' ,'
			stosw
			;Class
			invoke SaveUDCClass
			mov		ax,' ,'
			stosw
			mov		eax,[esi].DIALOG.style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				invoke SaveStr,edi,addr szNOTStyle
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].DIALOG.style,[esi].DIALOG.ntype,TRUE
			invoke SaveCtlSize
			.if [esi].DIALOG.exstyle || [esi].DIALOG.helpid
				mov		ax,' ,'
				stosw
				.if [esi].DIALOG.exstyle
					invoke SaveExStyle,[esi].DIALOG.exstyle
				.endif
				.if [esi].DIALOG.helpid
					mov		ax,' ,'
					stosw
					invoke ResEdBinToDec,[esi].DIALOG.helpid,addr buffer
					invoke SaveStr,edi,addr buffer
					add		edi,eax
				.endif
			.endif
			mov		ax,0A0Dh
			stosw
		.else
			;Control
			push	eax
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			pop		eax
			.if eax==17 || eax==27
				.if byte ptr [esi].DIALOG.caption=='#'
					; "#100"
					invoke SaveCaption
				.elseif  byte ptr [esi].DIALOG.caption>='0' && byte ptr [esi].DIALOG.caption<='9'
					; 100
					invoke SaveStr,edi,addr [esi].DIALOG.caption
					add		edi,eax
				.else
					xor		ebx,ebx
					.if byte ptr [esi].DIALOG.caption
						invoke GetWindowLong,hPrj,0
						invoke GetTypeMem,eax,TPE_RESOURCE
						.if [eax].PROJECT.hmem
							push	edi
							mov		edi,[eax].PROJECT.hmem
							.while byte ptr [edi].RESOURCEMEM.szname || [edi].RESOURCEMEM.value
								invoke strcmp,addr [edi].RESOURCEMEM.szname,addr [esi].DIALOG.caption
								.if !eax
									.if [edi].RESOURCEMEM.value
										; IDI_ICON
										pop		edi
										invoke SaveStr,edi,addr [esi].DIALOG.caption
										add		edi,eax
										push	edi
									.else
										; "IDI_ICON"
										pop		edi
										invoke SaveCaption
										push	edi
									.endif
									inc		ebx
									.break
								.endif
								add		edi,sizeof RESOURCEMEM
							.endw
							pop		edi
						.endif
					.endif
					.if !ebx
						invoke SaveCaption
					.endif
				.endif
			.else
				invoke SaveCaption
			.endif
			mov		ax,' ,'
			stosw
			invoke SaveName
			add		edi,eax
			mov		ax,' ,'
			stosw
			invoke SaveClass
			mov		ax,' ,'
			stosw
			mov		eax,[esi].DIALOG.style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				.if fStyleHex
					invoke SaveStr,edi,addr szNOTStyleHex
				.else
					invoke SaveStr,edi,addr szNOTStyle
				.endif
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].DIALOG.style,[esi].DIALOG.ntype,TRUE
			invoke SaveCtlSize
			.if [esi].DIALOG.exstyle || [esi].DIALOG.helpid
				mov		ax,' ,'
				stosw
				.if [esi].DIALOG.exstyle
					invoke SaveExStyle,[esi].DIALOG.exstyle
				.endif
				.if [esi].DIALOG.helpid
					mov		ax,' ,'
					stosw
					invoke ResEdBinToDec,[esi].DIALOG.helpid,addr buffer
					invoke SaveStr,edi,addr buffer
					add		edi,eax
				.endif
			.endif
			mov		ax,0A0Dh
			stosw
		.endif
	.endif
	mov		eax,edi
	ret

SaveCtl endp

ExportDialogNames proc uses ebx esi edi,hMem:DWORD
	LOCAL	buffer[16]:BYTE

	mov		esi,hMem
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
  @@:
	;Is ctl deleted
	.if [esi].DIALOG.hwnd!=-1
		.if byte ptr [esi].DIALOG.idname && [esi].DIALOG.id
			invoke ExportName,addr [esi].DIALOG.idname,[esi].DIALOG.id,edi
			lea		edi,[edi+eax]
		.endif
	.endif
	add		esi,size DIALOG
	cmp		[esi].DIALOG.hwnd,0
	jne		@b
	pop		eax
	ret

ExportDialogNames endp

VerifyTebIndex proc uses esi,hMem:DWORD
	LOCAL	tab[1024]:BYTE
	LOCAL	maxtab:DWORD
	LOCAL	szerr[256]:BYTE

	mov		maxtab,-1
	invoke RtlZeroMemory,addr tab,sizeof tab
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
	invoke strcpy,addr szerr,addr [esi].DIALOG.idname
	add		esi,sizeof DIALOG
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			mov		eax,[esi].DIALOG.tab
			.if sdword ptr eax>maxtab
				mov		maxtab,eax
			.endif
			inc		byte ptr tab[eax]
		.endif
		add		esi,sizeof DIALOG
	.endw
	.if maxtab!=-1
		xor		ecx,ecx
		.while ecx<=maxtab
			push	ecx
			.if byte ptr tab[ecx]>1
				invoke strcat,addr szerr,addr szDupTab
				invoke MessageBox,hDEd,addr szerr,addr szToolTip,MB_ICONERROR or MB_OK
				pop		ecx
				.break
			.elseif byte ptr tab[ecx]==0
				invoke strcat,addr szerr,addr szMissTab
				invoke MessageBox,hDEd,addr szerr,addr szToolTip,MB_ICONERROR or MB_OK
				pop		ecx
				.break
			.endif
			pop		ecx
			inc		ecx
		.endw
	.endif
	ret

VerifyTebIndex endp

ExportDialog proc uses esi edi,hRdMem:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	nTab:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		esi,hRdMem
	invoke VerifyTebIndex,esi
	mov		edi,hWrMem
	mov		esi,hRdMem
	add		esi,sizeof DLGHEAD
	invoke SaveCtl
	mov		edi,eax
	add		esi,sizeof DIALOG
	mov		nTab,0
  @@:
	call	FindCtlTab
	.if eax
		invoke SaveCtl
		mov		edi,eax
		inc		nTab
		jmp		@b
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		eax,0A0Dh
	stosw
	stosd
	mov		eax,hWrMem
	ret

FindCtlTab:
	mov		esi,hRdMem
	lea		esi,[esi+sizeof DLGHEAD+sizeof DIALOG]
	xor		eax,eax
	mov		edx,nTab
	.while [esi].DIALOG.hwnd
		.if edx==[esi].DIALOG.tab && [esi].DIALOG.hwnd!=-1
			inc		eax
			retn
		.endif
		lea		esi,[esi+sizeof DIALOG]
	.endw
	retn

ExportDialog endp

