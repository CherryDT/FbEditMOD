.code

xGlobalAlloc proc fFlags:DWORD,nSize:DWORD

	invoke GlobalAlloc,fFlags,nSize
	.if !eax
		invoke MessageBox,hWnd,addr szMemFail,addr szAppName,MB_OK or MB_ICONERROR
		xor		eax,eax
	.endif
	ret

xGlobalAlloc endp

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

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
	ret

DwToAscii endp

DwToHex proc uses edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	mov		ecx,8
	.while ecx
		rol		eax,4
		call	HexNyb
		dec		ecx
	.endw
	mov		byte ptr [edi],0
	ret

HexNyb:
	push	eax
	and		eax,0Fh
	.if al>9
		add		al,41h-10
	.else
		add		al,30h
	.endif
	mov		[edi],al
	inc		edi
	pop		eax
	retn

DwToHex endp

HexToDw proc uses esi,lpAscii:DWORD

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

HexToDw endp

MakeKey proc lpszStr:DWORD,nInx:DWORD,lpszKey:DWORD

	invoke lstrcpy,lpszKey,lpszStr
	invoke lstrlen,lpszKey
	add		eax,lpszKey
	invoke DwToAscii,nInx,eax
	ret

MakeKey endp

ParseCmnd proc uses esi edi,lpStr:DWORD,lpCmnd:DWORD,lpParam:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

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
	mov		edi,lpCmnd
	.if word ptr [edi]=='\\'
		invoke lstrcpy,addr buffer,addr AppPath
		invoke lstrcat,addr buffer,addr [edi+1]
		invoke lstrcpy,edi,addr buffer
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
				jmp		CopyQuoted
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
				jmp		CopyToSpace
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
			jmp		CopyAll
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
	mov		esi,offset ProjectFileName
	invoke lstrlen,esi
	mov		ecx,eax
	.while ecx
		dec		ecx
		.break .if byte ptr [esi+ecx]=='.'
	.endw
	.if byte ptr [esi+ecx]!='.'
		invoke lstrlen,esi
		mov		ecx,eax
	.endif
	.while ecx
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		dec		ecx
	.endw
	pop		esi
	retn

ParseCmnd endp

GetStrItem proc	lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
  @@:
	mov		al,[esi]
	cmp		al,','
	jz		@f
	or		al,al
	jz		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	or		al,al
	jz		@f
	inc		esi
	mov		al,0
  @@:
	mov		[edi],al
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

GetStrItem endp

GrayedImageList proc uses ebx esi edi,hToolbar:DWORD
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	nCount:DWORD
	LOCAL	rect:RECT

	invoke ImageList_GetImageCount,hImlTbr
	mov		nCount,eax
	shl		eax,4
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,eax
	mov		rect.bottom,16
	invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR24,nCount,10
	mov		hImlTbrGray,eax
	invoke GetDC,NULL
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,rect.right,16
	mov		hBmp,eax
	invoke ReleaseDC,NULL,hDC
	invoke SelectObject,mDC,hBmp
	push	eax
	invoke CreateSolidBrush,0FF00FFh
	push	eax
	invoke FillRect,mDC,addr rect,eax
	xor		ecx,ecx
	.while ecx<nCount
		push	ecx
		invoke ImageList_Draw,hImlTbr,ecx,mDC,rect.left,0,ILD_TRANSPARENT
		pop		ecx
		add		rect.left,16
		inc		ecx
	.endw
	invoke GetPixel,mDC,0,0
	mov		ebx,eax
	xor		esi,esi
	.while esi<16
		xor		edi,edi
		.while edi<rect.right
			invoke GetPixel,mDC,edi,esi
			.if eax!=ebx
				bswap	eax
				shr		eax,8
				movzx	ecx,al			; red
				imul	ecx,ecx,66
				movzx	edx,ah			; green
				imul	edx,edx,129
				add		edx,ecx
				shr		eax,16			; blue
				imul	eax,eax,25
				add		eax,edx
				add		eax,128
				shr		eax,8
				add		eax,16
				imul	eax,eax,010101h
;				and		eax,0E0E0E0h
;				shr		eax,1
;				add		eax,0404040h
;				shr		eax,1
;				or		eax,0808080h
				and		eax,0fcfcfch
				shr		eax,2
				add		eax,0505050h
				invoke SetPixel,mDC,edi,esi,eax
			.endif
			inc		edi
		.endw
		inc		esi
	.endw
	pop		eax
	invoke DeleteObject,eax
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteDC,mDC
	invoke ImageList_AddMasked,hImlTbrGray,hBmp,ebx
	invoke DeleteObject,hBmp
	invoke SendMessage,hToolbar,TB_SETDISABLEDIMAGELIST,0,hImlTbrGray
	ret

GrayedImageList endp

SetupMenu proc uses ebx esi edi,hSubMnu:HMENU
	LOCAL	nPos:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		nPos,0
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
  @@:
	lea		eax,buffer
	mov		word ptr [eax],0
	mov		mii.dwTypeData,eax
	mov		mii.cch,sizeof buffer
	invoke GetMenuItemInfo,hSubMnu,nPos,TRUE,addr mii
	.if eax
		mov		edi,offset mnubuff
		add		edi,mnupos
		mov		mii.dwItemData,edi
		mov		[edi].MENUDATA.img,0
		test	mii.fType,MFT_SEPARATOR
		.if ZERO?
			invoke SendMessage,hTbr,TB_COMMANDTOINDEX,mii.wID,0
			.if sdword ptr eax>=0
				invoke SendMessage,hTbr,TB_GETBITMAP,mii.wID,0
				inc		eax
				mov		[edi].MENUDATA.img,eax
			.endif
			mov		[edi].MENUDATA.tpe,0
			mov		eax,mii.fType
			and		eax,7Fh
			.if eax==MFT_STRING
				lea		esi,buffer
				mov		ecx,sizeof MENUDATA
				xor		edx,edx
				.while byte ptr [esi]
					mov		al,[esi]
					.if al==VK_TAB
						mov		al,0
						inc		edx
					.endif
					mov		[edi+ecx],al
					inc		ecx
					inc		esi
				.endw
				mov		al,0
				mov		[edi+ecx],al
				inc		ecx
				mov		[edi+ecx],al
				inc		ecx
				add		mnupos,ecx
			.else
				mov		[edi].MENUDATA.tpe,0
				mov		word ptr [edi+sizeof MENUDATA],0
				add		mnupos,sizeof MENUDATA+2
			.endif
		.else
			; Separator
			mov		[edi].MENUDATA.tpe,1
			add		mnupos,sizeof MENUDATA
		.endif
		or		mii.fType,MFT_OWNERDRAW
		invoke SetMenuItemInfo,hSubMnu,nPos,TRUE,addr mii
		.if mii.hSubMenu
			invoke SetupMenu,mii.hSubMenu
		.endif
		inc		nPos
		jmp		@b
	.endif
	ret

SetupMenu endp

MakeMenuBitmap proc uses ebx esi edi,wt:DWORD,nColor:DWORD
	LOCAL	hBmp:HBITMAP
	LOCAL	hOldBmp:HBITMAP
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hDeskTop:HWND

	invoke GetDesktopWindow
	mov		hDeskTop,eax
	invoke GetDC,hDeskTop
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,600,8
	mov		hBmp,eax
	invoke ReleaseDC,hDeskTop,hDC
	invoke SelectObject,mDC,hBmp
	mov		hOldBmp,eax
	xor		ebx,ebx
	.while ebx<8
		xor		edi,edi
		mov		esi,nColor
		.while edi<wt
			invoke SetPixel,mDC,edi,ebx,esi
			sub		esi,030303h
			inc		edi
		.endw
		.while edi<600
			invoke SetPixel,mDC,edi,ebx,0FFFFFFh
			inc		edi
		.endw
		inc		ebx
	.endw
	invoke SelectObject,mDC,hOldBmp
	invoke DeleteDC,mDC
	mov		eax,hBmp
	ret

MakeMenuBitmap endp

CoolMenu proc
	LOCAL	MInfo:MENUINFO
	LOCAL	nInx:DWORD
	LOCAL	hBmp:HBITMAP
	LOCAL	hBr:HBRUSH
	LOCAL	ncm:NONCLIENTMETRICS

	; Get menu font
	mov		ncm.cbSize,sizeof NONCLIENTMETRICS
	invoke SystemParametersInfo,SPI_GETNONCLIENTMETRICS,sizeof NONCLIENTMETRICS,addr ncm,0
	invoke CreateFontIndirect,addr ncm.lfMenuFont
	mov		hMnuFont,eax
	invoke MakeMenuBitmap,23,0FFDFCFh;0FFCEBEh
	mov		hBmp,eax
	invoke CreatePatternBrush,hBmp
	mov		hMenuBrushA,eax
	mov		MInfo.hbrBack,eax
	invoke DeleteObject,hBmp
	mov		MInfo.cbSize,SizeOf MENUINFO
	mov		MInfo.fMask,MIM_BACKGROUND or MIM_APPLYTOSUBMENUS
	invoke MakeMenuBitmap,20,0FFDFCFh-090909h
	mov		hBmp,eax
	invoke CreatePatternBrush,hBmp
	mov		hMenuBrushB,eax
	invoke DeleteObject,hBmp
	mov		nInx,0
	mov		mnupos,0
  @@:
	invoke GetSubMenu,hMnu,nInx
	.if eax
		push	eax
		invoke SetupMenu,eax
		pop		edx
		invoke SetMenuInfo,edx,addr MInfo
		inc		nInx
		jmp		@b
	.endif
	mov		nInx,0
  @@:
	invoke GetSubMenu,hContextMenu,nInx
	.if eax
		push	eax
		invoke SetupMenu,eax
		pop		edx
		invoke SetMenuInfo,edx,addr MInfo
		inc		nInx
		jmp		@b
	.endif
	ret

CoolMenu endp

ResetMenu proc uses ebx esi edi
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	rarstype:RARSTYPE

	; Standard menu
	.if hMnuFont
		invoke DeleteObject,hMenuBrushA
		invoke DeleteObject,hMenuBrushB
		invoke DeleteObject,hMnuFont
		xor		eax,eax
		mov		hMenuBrushA,eax
		mov		hMenuBrushB,eax
		mov		hMnuFont,eax
	.endif
	invoke LoadMenu,hInstance,IDR_MENU
	push	eax
	invoke SetMenu,hWnd,eax
	invoke DestroyMenu,hMnu
	pop		eax
	mov		hMnu,eax
	invoke DestroyMenu,hContextMenu
	invoke LoadMenu,hInstance,IDR_CONTEXT
	mov		hContextMenu,eax
	invoke GetSubMenu,eax,0
	mov		hContextMenuPopup,eax
	invoke SetToolMenu
	invoke SetHelpMenu
	xor		edi,edi
	mov		esi,offset mruproject
	.while edi<=9
		.if byte ptr [esi]
			mov		eax,edi
			shl		eax,8
			or		eax,' 0&'
			mov		dword ptr buffer,eax
			invoke lstrcpy,offset tmpbuff,esi
			invoke GetStrItem,offset tmpbuff,addr buffer1
			invoke PathCompactPathEx,addr buffer[3],addr buffer1,30,0
			invoke GetSubMenu,hMnu,0
			mov		edx,eax
			mov		ecx,edi
			add		ecx,21000
			invoke AppendMenu,edx,MF_STRING,ecx,addr buffer
			add		esi,MAX_PATH*2
		.endif
		inc		edi
	.endw
	;Set resource types
	mov		nInx,1
	.while nInx<=32
		invoke MakeKey,addr szCustType,nInx,addr buffer1
		mov		lpcbData,sizeof RARSTYPE
		invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
		invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,addr rarstype,addr lpcbData
		.if !rarstype.szext && rarstype.sztype && nInx>11
			invoke lstrcpy,addr buffer,addr szAdd
			invoke lstrcat,addr buffer,addr rarstype.sztype
			mov		ebx,nInx
			lea		ebx,[ebx+22000-12]
			invoke InsertMenu,hMnu,IDM_PROJRCT_ADD_TOOLBAR,MF_BYCOMMAND,ebx,addr buffer
		.endif
		inc		nInx
	.endw
	.if !grdsize.standardmnu
		invoke CoolMenu
	.endif
	ret

ResetMenu endp

RemovePath proc uses esi edi,lpFileName:DWORD,lpPath:DWORD

	mov		edi,lpFileName
	mov		esi,lpPath
	jmp		@f
  Nxt:
	inc		esi
	inc		edi
  @@:
	mov		al,[esi]
	or		al,al
	je		@f
	mov		ah,[edi]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		Nxt
  @@:
	.if byte ptr [edi]=='\'
		inc		edi
	.else
		mov		edi,lpFileName
	.endif
	mov		eax,edi
	ret

RemovePath endp

DelMruProject proc uses esi edi,nID:DWORD

	mov		eax,nID
	mov		ecx,MAX_PATH*2
	mul		ecx
	mov		edi,offset mruproject
	add		edi,eax
	mov		esi,edi
	add		esi,MAX_PATH*2
	.while esi<offset mruproject+MAX_PATH*2*11
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	ret

DelMruProject endp

FindMruProject proc uses esi

	mov		esi,offset mruproject
	xor		ecx,ecx
	.while ecx<10
		xor		edx,edx
		.while byte ptr ProjectFileName[edx]
			mov		al,ProjectFileName[edx]
			mov		ah,[esi+edx]
			.break .if al!=ah
			inc		edx
		.endw
		mov		al,ProjectFileName[edx]
		mov		ah,[esi+edx]
		.break .if !al && ah==','
		inc		ecx
		add		esi,MAX_PATH*2
	.endw
	mov		eax,ecx
	ret

FindMruProject endp

AddMruProject proc uses esi edi

	invoke FindMruProject
	.if eax<10
		invoke DelMruProject,eax
	.endif
	mov		edi,offset mruproject+MAX_PATH*2*10-1
	mov		esi,edi
	sub		esi,MAX_PATH*2
	.while esi>=offset mruproject
		mov		al,[esi]
		mov		[edi],al
		dec		esi
		dec		edi
	.endw
	invoke lstrcpy,offset mruproject,offset ProjectFileName
	invoke lstrcat,offset mruproject,offset szComma
	invoke lstrcat,offset mruproject,offset IncludeFileName
	invoke ResetMenu
	ret

AddMruProject endp

ClearMruProject proc

	invoke RtlZeroMemory,addr mruproject,sizeof mruproject
	invoke ResetMenu
	ret

ClearMruProject endp

SetWinCaption proc lpFileName:DWORD,Modified:DWORD
	LOCAL	buffer[sizeof szAppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,offset szAppName
	.if lpFileName
		mov		eax,' - '
		mov		dword ptr buffer1,eax
		invoke lstrcat,addr buffer,addr buffer1
		invoke lstrcat,addr buffer,lpFileName
		.if Modified
			invoke lstrcat,addr buffer,addr szAsterix
		.endif
	.endif
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

