.code

strgetitem proc uses esi edi,lpStrIn:DWORD,lpStrOut:DWORD

	mov		esi,lpStrIn
	mov		edi,lpStrOut
	.while byte ptr [esi] && byte ptr [esi]!=','
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	.if byte ptr [esi]
		inc		esi
	.endif
	mov		byte ptr [edi],0
	mov		eax,esi
	ret

strgetitem endp

; String handling
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
	sub		al,[edi+ecx]
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

strcmpin proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

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

strcmpin endp

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

AsciiToDw proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
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
    pop     esi
    pop     ebx
    ret

AsciiToDw endp

DwToHex proc uses edi,dwVal:DWORD,lpAscii:DWORD

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
	
DwToHex endp

MakeKey proc lpszStr:DWORD,nInx:DWORD,lpszKey:DWORD

	invoke strcpy,lpszKey,lpszStr
	invoke strlen,lpszKey
	add		eax,lpszKey
	invoke DwToAscii,nInx,eax
	ret

MakeKey endp

GrayedImageList proc uses ebx esi edi,hToolbar:DWORD
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	nCount:DWORD
	LOCAL	rect:RECT

	invoke ImageList_GetImageCount,ha.hImlTbr
	mov		nCount,eax
	shl		eax,4
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,eax
	mov		rect.bottom,16
	invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR24,nCount,10
	mov		ha.hImlTbrGray,eax
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
		invoke ImageList_Draw,ha.hImlTbr,ecx,mDC,rect.left,0,ILD_TRANSPARENT
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
	invoke ImageList_AddMasked,ha.hImlTbrGray,hBmp,ebx
	invoke DeleteObject,hBmp
	invoke SendMessage,hToolbar,TB_SETDISABLEDIMAGELIST,0,ha.hImlTbrGray
	ret

GrayedImageList endp

DoToolBar proc hInst:DWORD,hToolBar:HWND

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	invoke ImageList_LoadImage,hInst,IDB_TBRBMP,16,29,0FF00FFh,IMAGE_BITMAP,LR_CREATEDIBSECTION
	mov		ha.hImlTbr,eax
	invoke SendMessage,hToolBar,TB_SETIMAGELIST,0,ha.hImlTbr
	invoke GrayedImageList,hToolBar
	mov		eax,hToolBar
	ret

DoToolBar endp

DoStatusBar proc hWin:DWORD
	LOCAL	sbParts[4]:DWORD

	mov [sbParts+0],100				; pixels from left
	mov [sbParts+4],250				; pixels from left
	mov [sbParts+8],400				; pixels from left
	mov [sbParts+12],-1				; last part
	invoke SendMessage,hWin,SB_SETPARTS,4,addr sbParts
	ret

DoStatusBar endp

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
			invoke SendMessage,ha.hTbr,TB_COMMANDTOINDEX,mii.wID,0
			.if sdword ptr eax>=0
				invoke SendMessage,ha.hTbr,TB_GETBITMAP,mii.wID,0
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
	mov		ha.hMnuFont,eax
	invoke MakeMenuBitmap,23,0FFDFCFh;0FFCEBEh
	mov		hBmp,eax
	invoke CreatePatternBrush,hBmp
	mov		ha.hMenuBrushA,eax
	mov		MInfo.hbrBack,eax
	invoke DeleteObject,hBmp
	mov		MInfo.cbSize,SizeOf MENUINFO
	mov		MInfo.fMask,MIM_BACKGROUND or MIM_APPLYTOSUBMENUS
	invoke MakeMenuBitmap,20,0FFDFCFh-090909h
	mov		hBmp,eax
	invoke CreatePatternBrush,hBmp
	mov		ha.hMenuBrushB,eax
	invoke DeleteObject,hBmp
	mov		nInx,0
	mov		mnupos,0
  @@:
	invoke GetSubMenu,ha.hMnu,nInx
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
	invoke GetSubMenu,ha.hContextMnu,nInx
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

UpdateMRUMenu proc uses ebx esi edi,lpMRU:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		esi,lpMRU
	.if esi==offset mrufiles
		invoke GetMenuItemInfo,ha.hMnu,IDM_FILE_RECENTFILES,FALSE,addr mii
		mov		edi,25000
	.else
		invoke GetMenuItemInfo,ha.hMnu,IDM_FILE_RECENTSESSIONS,FALSE,addr mii
		mov		edi,25100
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

ResetMenu proc uses esi edi
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	rarstype:RARSTYPE

	; Standard menu
	.if ha.hMnuFont
		invoke DeleteObject,ha.hMenuBrushA
		invoke DeleteObject,ha.hMenuBrushB
		invoke DeleteObject,ha.hMnuFont
		xor		eax,eax
		mov		ha.hMenuBrushA,eax
		mov		ha.hMenuBrushB,eax
		mov		ha.hMnuFont,eax
	.endif
	invoke LoadMenu,ha.hInstance,IDM_MENU
	push	eax
	invoke SetMenu,ha.hWnd,eax
	invoke DestroyMenu,ha.hMnu
	pop		ha.hMnu
	mov		nInx,1
	mov		ebx,offset hCustDll
	.while nInx<=32
		invoke MakeKey,addr szCustType,nInx,addr buffer1
		mov		lpcbData,sizeof RARSTYPE
		invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
		invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr rarstype,addr lpcbData
		.if rarstype.sztype || rarstype.nid
			.if !rarstype.szext && rarstype.sztype && nInx>11
				invoke lstrcpy,addr buffer,addr szAdd
				invoke lstrcat,addr buffer,addr rarstype.sztype
				mov		edx,nInx
				lea		edx,[edx+22000-12]
				invoke InsertMenu,ha.hMnu,IDM_RESOURCE_TOOLBAR,MF_BYCOMMAND,edx,addr buffer
			.endif
		.endif
		inc		nInx
	.endw
	invoke DestroyMenu,ha.hContextMnu
	invoke LoadMenu,ha.hInstance,IDR_MENUCONTEXT
	mov		ha.hContextMnu,eax
	invoke SetToolMenu
	invoke SetHelpMenu
	invoke UpdateMRUMenu,offset mrufiles
	invoke UpdateMRUMenu,offset mrusessions
	invoke PostAddinMessage,ha.hWnd,AIM_MENUUPDATE,ha.hMnu,ha.hContextMnu,0,HOOK_MENUUPDATE
	invoke CoolMenu
	ret

ResetMenu endp

SetWinCaption proc lpFileName:DWORD
	LOCAL	buffer[sizeof szAppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke strcpy,addr buffer,offset szAppName
	.if lpFileName
		mov		eax,' - '
		mov		dword ptr buffer1,eax
		invoke strcat,addr buffer,addr buffer1
		invoke strcat,addr buffer,lpFileName
	.endif
	invoke SetWindowText,ha.hWnd,addr buffer
	ret

SetWinCaption endp

SetFormat proc hWin:HWND
	LOCAL	rafnt:RAFONT

	mov		eax,ha.hFont
	mov		rafnt.hFont,eax
	mov		eax,ha.hIFont
	mov		rafnt.hIFont,eax
	mov		eax,ha.hLnrFont
	mov		rafnt.hLnrFont,eax
	;Set fonts
	invoke SendMessage,hWin,REM_SETFONT,0,addr rafnt
	;Set tab width & expand tabs
	invoke SendMessage,hWin,REM_TABWIDTH,edopt.tabsize,edopt.exptabs
	;Set autoindent
	invoke SendMessage,hWin,REM_AUTOINDENT,0,edopt.indent
	;Set number of lines mouse wheel will scroll
	;NOTE! If you have mouse software installed, set to 0
	invoke SendMessage,hWin,REM_MOUSEWHEEL,3,0
	mov		eax,edopt.hiliteline
	.if eax
		mov		eax,2
	.endif
	invoke SendMessage,hWin,REM_HILITEACTIVELINE,0,eax
	ret

SetFormat endp

ShowPos proc nLine:DWORD,nPos:DWORD
	LOCAL	buffer[64]:BYTE

	mov		edx,nLine
	inc		edx
	invoke DwToAscii,edx,addr buffer[4]
	mov		dword ptr buffer,' :nL'
	invoke strlen,addr buffer
	mov		dword ptr buffer[eax],'soP '
	mov		dword ptr buffer[eax+4],' :'
	mov		edx,nPos
	inc		edx
	invoke DwToAscii,edx,addr buffer[eax+6]
	invoke SendMessage,ha.hSbr,SB_SETTEXT,0,addr buffer
	ret

ShowPos endp

ShowProc proc uses esi,nLine:DWORD
	LOCAL	isinproc:ISINPROC
	LOCAL	buffer[512]:BYTE

	mov		buffer,0
	.if ha.hREd
		invoke GetWindowLong,ha.hREd,GWL_ID
		.if eax==IDC_RAE
			mov		eax,nLine
			mov		isinproc.nLine,eax
			mov		eax,ha.hREd
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
	invoke SendMessage,ha.hSbr,SB_SETTEXT,3,addr buffer
	ret

ShowProc endp

ShowSession proc
	LOCAL	buffer[MAX_PATH]:BYTE

	.if da.MainFile
		invoke strcpy,addr buffer,addr szMainFile
		mov		dword ptr buffer[4],' :'
		invoke strlen,addr da.MainFile
		.while da.MainFile[eax-1]!='\'
			dec		eax
		.endw
		invoke strcat,addr buffer,addr da.MainFile[eax]
	.else
		mov		buffer,0
	.endif
	invoke SendMessage,ha.hSbr,SB_SETTEXT,1,addr buffer
	.if da.szSessionFile
		invoke strcpy,addr buffer,addr szSession
		mov		dword ptr buffer[7],' :'
		invoke strlen,addr da.szSessionFile
		.while da.szSessionFile[eax-1]!='\'
			dec		eax
		.endw
		invoke strcat,addr buffer,addr da.szSessionFile[eax]
	.else
		mov		buffer,0
	.endif
	invoke SendMessage,ha.hSbr,SB_SETTEXT,2,addr buffer
	ret

ShowSession endp

RemoveFileExt proc lpFileName:DWORD

	invoke strlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='.'
			mov		byte ptr [edx+eax],0
			.break
		.endif
	.endw
	ret

RemoveFileExt endp

RemoveFileName proc lpFileName:DWORD

	invoke strlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='\'
			mov		byte ptr [edx+eax+1],0
			.break
		.endif
	.endw
	ret

RemoveFileName endp

SetKeyWords proc uses esi edi
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[64]:BYTE

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,65536*8
	mov		hMem,eax
	invoke SetHiliteWords,0,0
	;Define $ as a character
	invoke SendMessage,ha.hOut,REM_SETCHARTAB,'$',CT_CHAR
	mov		nInx,0
	.while nInx<16
		invoke RtlZeroMemory,hMem,65536*8
		invoke MakeKey,offset szGroup,nInx,addr buffer
		mov		lpcbData,65536*8
		invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,hMem,addr lpcbData
		mov		ecx,hMem
		mov		edx,nInx
		.if !byte ptr [ecx]
			mov		ecx,kwofs[edx*4]
		.endif
		invoke SetHiliteWords,kwcol[edx*4],ecx
		inc		nInx
	.endw
	; Add api calls to Group#15
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'P'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,kwcol[15*4],hMem
	; Add api constants to Group#14
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'C'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	mov		esi,eax
	.while esi
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		mov		byte ptr [edi],'^'
		inc		edi
		.while byte ptr [esi]
			mov		al,[esi]
			.if al==','
				mov		byte ptr [edi],' '
				inc		edi
				mov		al,'^'
			.endif
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		mov		esi,eax
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,kwcol[14*4],hMem
	; Add api words to Group#14
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'W'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,kwcol[14*4],hMem
	; Add api structs to Group#13
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'S'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,kwcol[13*4],hMem
	; Add api types to Group#12
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'T'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		cl,[eax]
		mov		ch,cl
		and		cl,5Fh
		.if cl==ch
			; Case sensitive
			mov		byte ptr [edi],'^'
			inc		edi
		.endif
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,kwcol[12*4],hMem
	invoke GlobalFree,hMem
	invoke SendMessage,ha.hResEd,PRO_SETHIGHLIGHT,col.styles,col.words
	ret

SetKeyWords endp

IndentComment proc uses esi,nChr:DWORD,fN:DWORD
	LOCAL	ochr:CHARRANGE
	LOCAL	chr:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	buffer[32]:BYTE

	invoke SendMessage,ha.hREd,WM_SETREDRAW,FALSE,0
	invoke SendMessage,ha.hREd,REM_LOCKUNDOID,TRUE,0
	.if fN
		mov		eax,nChr
		mov		dword ptr buffer[0],eax
	.endif
	invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr ochr
	invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chr
	invoke SendMessage,ha.hREd,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chr.cpMin
	mov		LnSt,eax
	mov		eax,chr.cpMax
	dec		eax
	invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxt:
	mov		eax,LnSt
	.if eax<=LnEn
		invoke SendMessage,ha.hREd,EM_LINEINDEX,LnSt,0
		mov		chr.cpMin,eax
		inc		LnSt
		.if fN
			; Indent / Comment
			mov		chr.cpMax,eax
			invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chr
			invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,addr buffer
			invoke strlen,addr buffer
			add		ochr.cpMax,eax
			jmp		nxt
		.else
			; Outdent / Uncomment
			invoke SendMessage,ha.hREd,EM_LINEINDEX,LnSt,0
			mov		chr.cpMax,eax
			invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chr
			invoke SendMessage,ha.hREd,EM_GETSELTEXT,0,addr tmpbuff
			mov		esi,offset tmpbuff
			xor		eax,eax
			mov		al,[esi]
			.if eax==nChr
				inc		esi
				invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,esi
				dec		ochr.cpMax
			.elseif nChr==09h
				mov		ecx,edopt.tabsize
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
				mov		eax,edopt.tabsize
				sub		eax,ecx
				sub		ochr.cpMax,eax
				invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,esi
			.endif
			jmp		nxt
		.endif
	.endif
	invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr ochr
	invoke SendMessage,ha.hREd,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
	invoke SendMessage,ha.hREd,REM_LOCKUNDOID,FALSE,0
	invoke SendMessage,ha.hREd,WM_SETREDRAW,TRUE,0
	invoke SendMessage,ha.hREd,REM_REPAINT,0,0
	ret

IndentComment endp

GetSelText proc lpBuff:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	sub		eax,chrg.cpMin
	.if !eax
		invoke SendMessage,ha.hREd,REM_GETWORD,sizeof buffer,addr buffer
		.if buffer
			invoke strcpy,lpBuff,addr buffer
		.endif
	.elseif eax<256
		invoke SendMessage,ha.hREd,EM_GETSELTEXT,0,lpBuff
	.endif
	ret

GetSelText endp

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
	mov		esi,offset da.FileName
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

IsFileCodeFile proc lpFile:DWORD

	invoke strlen,lpFile
	mov		edx,lpFile
	lea		edx,[edx+eax-4]
	mov		edx,[edx]
	and		edx,05f5F5Fffh
	xor		eax,eax
	.if edx=='MSA.' || edx=='CNI.'
		inc		eax
	.endif
	ret

IsFileCodeFile endp

RemovePath proc	uses esi edi,lpszFileName:DWORD,lpPath:DWORD,lpBuff:DWORD

	add		lpBuff,21
	invoke strcpy,lpBuff,lpszFileName
	mov		edi,lpBuff
	mov		esi,lpPath
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[edi]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		@b
	.if	al
	  @@:
		dec		esi
		dec		edi
		mov		al,[esi]
		cmp		al,'\'
		jne		@b
		inc		esi
		inc		edi
	.endif
  @@:
	mov		al,[esi]
	inc		esi
	.if	al=='\'
		dec		edi
		mov		[edi],al
		dec		edi
		dec		edi
		mov		word ptr [edi],'..'
		jmp		@b
	.elseif	al
		jmp		@b
	.endif
	mov		eax,edi
	ret

RemovePath endp

SaveBreakpoints proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke SendMessage,hWin,EM_GETMODIFY,0,0
				.if !eax
					lea		edi,buffer2
					mov		word ptr [edi],0
					mov		esi,-1
					.while TRUE
						invoke SendMessage,hWin,REM_NEXTBREAKPOINT,esi,0
						.break .if eax==-1
						mov		esi,eax
						mov		byte ptr [edi],','
						invoke DwToAscii,esi,addr [edi+1]
						invoke strlen,edi
						lea		edi,[edi+eax]
					.endw
					invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
					invoke WritePrivateProfileString,addr szBreakPoint,addr buffer1,addr buffer2[1],addr da.szSessionFile
				.endif
			.endif
		.endif
	.endif
	ret

SaveBreakpoints endp

LoadBreakpoints proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
				invoke GetPrivateProfileString,addr szBreakPoint,addr buffer1,addr szNULL,addr buffer2,sizeof buffer2,addr da.szSessionFile
				lea		esi,buffer2
				.while byte ptr [esi]
					invoke strgetitem,esi,addr buffer1
					mov		esi,eax
					.if buffer1
						invoke AsciiToDw,addr buffer1
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETBREAKPOINT,eax,TRUE
					.endif
				.endw
			.endif
		.endif
	.endif
	ret

LoadBreakpoints endp

SaveBookMarks proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke SendMessage,hWin,EM_GETMODIFY,0,0
				.if !eax
					lea		edi,buffer2
					mov		word ptr [edi],0
					mov		esi,-1
					.while TRUE
						invoke SendMessage,hWin,REM_NXTBOOKMARK,esi,3
						.break .if eax==-1
						mov		esi,eax
						mov		byte ptr [edi],','
						invoke DwToAscii,esi,addr [edi+1]
						invoke strlen,edi
						lea		edi,[edi+eax]
					.endw
					invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
					invoke WritePrivateProfileString,addr szBookMark,addr buffer1,addr buffer2[1],addr da.szSessionFile
				.endif
			.endif
		.endif
	.endif
	ret

SaveBookMarks endp

LoadBookMarks proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
				invoke GetPrivateProfileString,addr szBookMark,addr buffer1,addr szNULL,addr buffer2,sizeof buffer2,addr da.szSessionFile
				lea		esi,buffer2
				.while byte ptr [esi]
					invoke strgetitem,esi,addr buffer1
					mov		esi,eax
					.if buffer1
						invoke AsciiToDw,addr buffer1
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETBOOKMARK,eax,3
					.endif
				.endw
			.endif
		.endif
	.endif
	ret

LoadBookMarks endp

SaveCollapse proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE
	LOCAL	chrg:CHARRANGE
	LOCAL	lpBuff:DWORD

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke SendMessage,hWin,EM_GETMODIFY,0,0
				.if !eax
					lea		edi,buffer2
					invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chrg.cpMin
					invoke DwToAscii,eax,edi
					invoke strlen,edi
					lea		edi,[edi+eax]
					mov		lpBuff,edi
					push	ebx
					mov		ebx,-1
					xor		edi,edi
				  @@:
					shl		edi,1
					and		edi,7FFFFFFFh
					.if !edi
						.if ebx!=-1
							push	edi
							mov		edi,lpBuff
							mov		byte ptr [edi],','
							inc		edi
							invoke DwToAscii,esi,edi
							invoke strlen,edi
							lea		edi,[edi+eax]
							mov		lpBuff,edi
							pop		edi
						.else
							invoke SendMessage,hWin,EM_GETLINECOUNT,0,0
							mov		ebx,eax
						.endif
						xor		esi,esi
						inc		edi
					.endif
					invoke SendMessage,hWin,REM_PRVBOOKMARK,ebx,1
					push	eax
					invoke SendMessage,hWin,REM_PRVBOOKMARK,ebx,2
					pop		edx
					or		esi,edi
					.if sdword ptr edx>=eax
						mov		eax,edx
						xor		esi,edi
					.endif
					mov		ebx,eax
					cmp		ebx,-1
					jne		@b
					pop		ebx
					mov		edi,lpBuff
					mov		byte ptr [edi],','
					inc		edi
					invoke DwToAscii,esi,edi
					invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
					invoke WritePrivateProfileString,addr szCollapse,addr buffer1,addr buffer2,addr da.szSessionFile
				.endif
			.endif
		.endif
	.endif
	ret

SaveCollapse endp

LoadCollapse proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[MAX_PATH*4]:BYTE
	LOCAL	chrg:CHARRANGE

	.if da.fProject && da.szSessionFile
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		.if [ebx].TABMEM.pid
			invoke GetWindowLong,hWin,GWL_ID
			.if eax==IDC_RAE
				invoke wsprintf,addr buffer1,addr szFmtDec,[ebx].TABMEM.pid
				invoke GetPrivateProfileString,addr szCollapse,addr buffer1,addr szNULL,addr buffer2,sizeof buffer2,addr da.szSessionFile
				lea		esi,buffer2
				invoke strgetitem,esi,addr buffer1
				mov		esi,eax
				.if buffer1
					invoke AsciiToDw,addr buffer1
					invoke SendMessage,hWin,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hWin,EM_SCROLLCARET,0,0
					invoke SendMessage,hWin,REM_VCENTER,0,0
					invoke SendMessage,hWin,EM_SCROLLCARET,0,0
					invoke SendMessage,hWin,EM_GETLINECOUNT,0,0
					invoke SendMessage,hWin,REM_PRVBOOKMARK,eax,1
					mov		ebx,eax
					.while byte ptr [esi]
						invoke strgetitem,esi,addr buffer1
						mov		esi,eax
						invoke AsciiToDw,addr buffer1
						xor		ecx,ecx
						.while ecx<31
							shr		eax,1
							push	eax
							push	ecx
							.if CARRY?
								invoke SendMessage,hWin,REM_COLLAPSE,ebx,0
							.endif
							invoke SendMessage,hWin,REM_PRVBOOKMARK,ebx,1
							mov		ebx,eax
							pop		ecx
							pop		eax
							inc		ecx
							cmp		ebx,-1
							je		@f
						.endw
					.endw
				  @@:
				.endif
			.endif
		.endif
	.endif
	ret

LoadCollapse endp

UpdateAll proc uses ebx esi edi,nFunction:DWORD,lParam:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	hefnt:HEFONT
	LOCAL	chrg:CHARRANGE
	LOCAL	nLn:DWORD
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE

	invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
	mov		nInx,eax
	mov		tci.imask,TCIF_PARAM
	.while nInx
		dec		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,nFunction
			.if eax==WM_SETFONT
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_STYLE
					.if edopt.hilitecmnt
						or		eax,STYLE_HILITECOMMENT
					.else
						and		eax,-1 xor STYLE_HILITECOMMENT
					.endif
					invoke SetWindowLong,[ebx].TABMEM.hwnd,GWL_STYLE,eax
					invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETCOLOR,0,addr col
					invoke SetFormat,[ebx].TABMEM.hwnd
				.elseif eax==IDC_HEX
					mov		eax,ha.hFont
					mov		hefnt.hFont,eax
					mov		eax,ha.hLnrFont
					mov		hefnt.hLnrFont,eax
					invoke SendMessage,[ebx].TABMEM.hwnd,HEM_SETFONT,0,addr hefnt
				.endif
			.elseif eax==WM_PAINT
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,[ebx].TABMEM.hwnd,REM_REPAINT,0,0
				.elseif eax==IDC_HEX
					invoke SendMessage,[ebx].TABMEM.hwnd,HEM_REPAINT,0,0
				.endif
			.elseif eax==WM_CLOSE
				mov		eax,nInx
				.if eax!=nTabInx
					invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
					.if eax==IDC_USER
						invoke PostAddinMessage,[ebx].TABMEM.hwnd,AIM_GETMODIFY,IDC_USER,addr [ebx].TABMEM.filename,0,HOOK_GETMODIFY
					.else
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
					.endif
					.if eax
						invoke TabToolGetInx,[ebx].TABMEM.hwnd
						invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
						invoke TabToolActivate
						invoke SetFocus,ha.hREd
						invoke GetWindowLong,ha.hREd,GWL_ID
						invoke PostAddinMessage,ha.hREd,AIM_FILECLOSE,eax,offset da.FileName,0,HOOK_FILECLOSE
						.if !eax
							invoke WantToSave,ha.hREd,offset da.FileName
						.endif
						or		eax,eax
						jne		Ex
					.endif
				.endif
			.elseif eax==CLOSE_ALL
				mov		eax,nInx
				.if eax!=nTabInx
					invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
					mov		esi,eax
					.if esi==IDC_RAE
						invoke DeleteGoto,[ebx].TABMEM.hwnd
						.if !da.fProject
							invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,[ebx].TABMEM.hwnd,0
						.else
							invoke SaveCollapse,[ebx].TABMEM.hwnd
						.endif
					.endif
					invoke PostAddinMessage,[ebx].TABMEM.hwnd,AIM_FILECLOSED,esi,[ebx].TABMEM.filename,0,HOOK_FILECLOSED
					.if esi!=IDC_RES && esi!=IDC_USER
						invoke DestroyWindow,[ebx].TABMEM.hwnd
					.endif
					invoke TabToolDel,[ebx].TABMEM.hwnd
				.endif
			.elseif eax==WM_DESTROY
				invoke SendMessage,ha.hTab,TCM_DELETEITEM,nInx,0
				invoke DestroyWindow,[ebx].TABMEM.hwnd
				invoke GetProcessHeap
				invoke HeapFree,eax,NULL,ebx
			.elseif eax==IS_OPEN
				invoke lstrcmpi,lParam,addr [ebx].TABMEM.filename
				.if !eax
					mov		eax,[ebx].TABMEM.hwnd
					jmp		Ex
				.endif
			.elseif eax==IS_OPEN_ACTIVATE
				invoke lstrcmpi,offset da.FileName,addr [ebx].TABMEM.filename
				.if !eax
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					invoke SetFocus,ha.hREd
					mov		eax,TRUE
					jmp		Ex
				.endif
			.elseif eax==IS_RESOURCE
				mov		eax,[ebx].TABMEM.hwnd
				.if eax==ha.hRes
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					invoke SetFocus,ha.hREd
					mov		eax,TRUE
					jmp		Ex
				.endif
			.elseif eax==IS_RESOURCE_OPEN
				mov		eax,[ebx].TABMEM.hwnd
				.if eax==ha.hRes
					mov		eax,TRUE
					jmp		Ex
				.endif
			.elseif eax==SAVE_ALL
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_USER
					mov		edx,eax
					invoke PostAddinMessage,[ebx].TABMEM.hwnd,AIM_GETMODIFY,edx,addr [ebx].TABMEM.filename,0,HOOK_GETMODIFY
				.else
					invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
				.endif
				.if eax
					invoke SaveEdit,[ebx].TABMEM.hwnd,addr [ebx].TABMEM.filename
				.endif
			.elseif eax==IS_CHANGED
				mov		[ebx].TABMEM.fnonotify,FALSE
				.if [ebx].TABMEM.nchange
					invoke ReleaseCapture
					mov		[ebx].TABMEM.nchange,0
					invoke strcpy,addr LineTxt,addr szChanged
					invoke strcat,addr LineTxt,addr [ebx].TABMEM.filename
					invoke strcat,addr LineTxt,addr szReopen
					invoke MessageBox,ha.hWnd,addr LineTxt,addr szAppName,MB_YESNO or MB_ICONQUESTION
					.if eax==IDYES
						invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
						.if eax==IDC_RAE
							invoke LoadEditFile,[ebx].TABMEM.hwnd,addr [ebx].TABMEM.filename
						.elseif eax==IDC_HEX
							invoke LoadHexFile,[ebx].TABMEM.hwnd,addr [ebx].TABMEM.filename
						.elseif eax==IDC_RES
							invoke LoadRCFile,addr [ebx].TABMEM.filename
						.endif
					.endif
				.endif
			.elseif eax==CLEAR_CHANGED
				.if [ebx].TABMEM.nchange
					mov		[ebx].TABMEM.nchange,0
				.endif
			.elseif eax==SAVE_SESSIONFILE
				invoke strcmp,addr [ebx].TABMEM.filename,addr szNewFile
				.if eax
					invoke strcpy,addr buffer1,addr da.szSessionFile
					invoke strlen,addr buffer1
					.while eax && buffer1[eax-1]!='\'
						dec		eax
					.endw
					mov		buffer1[eax],0
					invoke RemovePath,addr [ebx].TABMEM.filename,addr buffer1,addr buffer2
					invoke strcpy,addr buffer1,eax
					invoke strcpy,addr LineTxt,addr tmpbuff
					invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
					.if eax==IDC_RAE
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXGETSEL,0,addr chrg
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					.elseif eax==IDC_HEX
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXGETSEL,0,addr chrg
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXLINEFROMCHAR,0,chrg.cpMin
						add		eax,2
						neg		eax
					.else
						mov		eax,-1
					.endif
					mov		edx,eax
					invoke DwToAscii,edx,addr tmpbuff
					invoke strcat,addr tmpbuff,addr szComma
					invoke strcat,addr tmpbuff,addr buffer1
					invoke strcat,addr tmpbuff,addr szComma
					invoke strcat,addr tmpbuff,addr LineTxt
				.endif
			.elseif eax==SAVE_SESSIONREGISTRY
				invoke strcmp,addr [ebx].TABMEM.filename,addr szNewFile
				.if eax
					invoke strcpy,addr buffer1,addr da.szSessionFile
					invoke strcpy,addr LineTxt,addr tmpbuff
					invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
					.if eax==IDC_RAE
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXGETSEL,0,addr chrg
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					.elseif eax==IDC_HEX
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXGETSEL,0,addr chrg
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXLINEFROMCHAR,0,chrg.cpMin
						add		eax,2
						neg		eax
					.else
						mov		eax,-1
					.endif
					mov		edx,eax
					invoke DwToAscii,edx,addr tmpbuff
					invoke strcat,addr tmpbuff,addr szComma
					invoke strcat,addr tmpbuff,addr [ebx].TABMEM.filename
					invoke strcat,addr tmpbuff,addr szComma
					invoke strcat,addr tmpbuff,addr LineTxt
				.endif
			.elseif eax==CLEAR_ERRORS
				mov		ErrID,0
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_NEXTERROR,eax,0
						.break .if eax==-1
						push	eax
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETERROR,eax,FALSE
						pop		eax
					.endw
				.endif
			.elseif eax==FIND_ERROR
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					mov		nLn,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_NEXTERROR,nLn,0
						.break .if eax==-1
						mov		nLn,eax
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_GETERROR,nLn,0
						mov		edx,nErrID
						.if eax==ErrID[edx*4]
							invoke TabToolGetInx,[ebx].TABMEM.hwnd
							invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
							invoke TabToolActivate
							invoke SendMessage,[ebx].TABMEM.hwnd,EM_LINEINDEX,nLn,0
							mov		chrg.cpMin,eax
							mov		chrg.cpMax,eax
							invoke SendMessage,[ebx].TABMEM.hwnd,EM_EXSETSEL,0,addr chrg
							invoke SendMessage,[ebx].TABMEM.hwnd,EM_SCROLLCARET,0,0
							invoke SetFocus,[ebx].TABMEM.hwnd
							mov		eax,TRUE
							ret
						.endif
					.endw
				.endif
			.elseif eax==CLEAR_BREAKPOINTS
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_NEXTBREAKPOINT,eax,0
						.break .if eax==-1
						push	eax
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETBREAKPOINT,eax,FALSE
						pop		eax
					.endw
				.endif
			.elseif eax==SET_BREAKPOINTS
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					mov		eax,-1
					.while TRUE
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_NEXTBREAKPOINT,eax,0
						.break .if eax==-1
						push	eax
						lea		edx,[eax+1]
						invoke DebugCommand,FUNC_BPADDLINE,edx,addr [ebx].TABMEM.filename
						pop		eax
					.endw
				.endif
			.elseif eax==LOCK_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke IsFileCodeFile,addr [ebx].TABMEM.filename
					.if eax
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_READONLY,0,TRUE
					.endif
				.endif
			.elseif eax==UNLOCK_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke IsFileCodeFile,addr [ebx].TABMEM.filename
					.if eax
						invoke SendMessage,[ebx].TABMEM.hwnd,REM_READONLY,0,FALSE
					.endif
				.endif
			.elseif eax==UNSAVED_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke IsFileCodeFile,addr [ebx].TABMEM.filename
					.if eax
						invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
						.if eax
							inc		nUnsaved
						.endif
					.endif
				.endif
			.elseif eax==NEWER_SOURCE_FILES
				invoke GetWindowLong,[ebx].TABMEM.hwnd,GWL_ID
				.if eax==IDC_RAE
					invoke IsFileCodeFile,addr [ebx].TABMEM.filename
					.if eax
						invoke CompareFileTime,addr [ebx].TABMEM.ft,addr ftexe
						.if sdword ptr eax>0
							inc		nNewer
						.endif
					.endif
				.endif
			.elseif eax==ADDTOPROJECT
				mov		edx,lParam
				.if edx
					invoke strlen,addr [ebx].TABMEM.filename
					.while eax
						.if byte ptr [ebx].TABMEM.filename[eax-1]=='.'
							mov		eax,dword ptr [ebx].TABMEM.filename[eax-1]
							and		eax,5F5F5FFFh
							.break
						.endif
						dec		eax
					.endw
					.if eax=='MSA.'
						;Assembly
						mov		edx,-2
					.elseif eax=='CNI.'
						;Include
						mov		edx,-3
					.elseif eax=='CR.'
						;Resource
						mov		edx,-5
					.else
						;Misc
						mov		edx,-4
					.endif
				.endif
				invoke SendMessage,ha.hPbr,RPBM_ADDNEWFILE,edx,addr [ebx].TABMEM.filename
				.if eax
					mov		eax,[eax].PBITEM.id
					mov		[ebx].TABMEM.pid,eax
					invoke ParseEdit,[ebx].TABMEM.hwnd,eax
				.endif
			.endif
		.endif
		xor		eax,eax
	.endw
  Ex:
	ret

UpdateAll endp

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

RemoveFromRegistry proc uses ebx
	LOCAL	buffer[256]:BYTE
	LOCAL	cbSize:DWORD
	LOCAL	ftm:FILETIME

	invoke RegOpenKeyEx,HKEY_CURRENT_USER,addr szMasmEd,NULL,KEY_READ or KEY_WRITE,addr ha.hReg
	.if eax==ERROR_SUCCESS
		xor		ebx,ebx
		.while TRUE
			mov		cbSize,sizeof buffer
			invoke RegEnumKeyEx,ha.hReg,ebx,addr buffer,addr cbSize,NULL,NULL,NULL,addr ftm
			.break .if eax!=ERROR_SUCCESS
			invoke RegDeleteKey,ha.hReg,addr buffer
			inc		ebx
		.endw
		invoke RegCloseKey,ha.hReg
		invoke RegOpenKeyEx,HKEY_CURRENT_USER,addr szSoftware,NULL,KEY_READ or KEY_WRITE,addr ha.hReg
		.if eax==ERROR_SUCCESS
			invoke RegDeleteKey,ha.hReg,addr szMasmEd1000
			invoke RegCloseKey,ha.hReg
		.endif
	.endif
	ret

RemoveFromRegistry endp

OutputString proc uses ebx,lpString:DWORD

	mov		ebx,ha.hOut
	.if nOutSel
		mov		ebx,ha.hImmOut
	.endif
	invoke SendMessage,ebx,EM_SETSEL,-1,-1
	invoke SendMessage,ebx,EM_REPLACESEL,FALSE,lpString
	invoke SendMessage,ebx,EM_REPLACESEL,FALSE,addr szCr
	invoke SendMessage,ebx,EM_SCROLLCARET,0,0
	ret

OutputString endp

OutputClear proc uses ebx

	mov		ebx,ha.hOut
	.if nOutSel
		mov		ebx,ha.hImmOut
	.endif
	invoke SendMessage,ebx,WM_SETTEXT,0,0
	invoke SendMessage,ebx,EM_SCROLLCARET,0,0
	ret

OutputClear endp

OutputShow proc uses ebx edi,fShow:DWORD

	mov		ebx,ha.hOut
	mov		edi,ha.hImmOut
	.if nOutSel
		mov		ebx,ha.hImmOut
		mov		edi,ha.hOut
	.endif
	.if fShow
		or		wpos.fView,4
		invoke ShowWindow,ebx,SW_SHOWNA
		invoke ShowWindow,edi,SW_HIDE
		invoke SendMessage,ha.hWnd,WM_SIZE,0,0
	.else
		test	wpos.fView,4
		.if !ZERO?
			xor		wpos.fView,4
			invoke ShowWindow,ebx,SW_HIDE
			invoke ShowWindow,edi,SW_HIDE
			invoke SendMessage,ha.hWnd,WM_SIZE,0,0
		.endif
	.endif
	mov		fTimer,1
	ret

OutputShow endp

OutputSelect proc nSel:DWORD

	invoke SendMessage,ha.hTabOut,TCM_SETCURSEL,nSel,0
	mov		eax,nSel
	mov		nOutSel,eax
	ret

OutputSelect endp

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

UpdateGoto proc uses ebx edi,hWin:HWND,cp:DWORD,n:DWORD
	LOCAL	chrg:CHARRANGE

	;Delete
	mov		eax,cp
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	add		eax,n
	.if eax<chrg.cpMin
		mov		chrg.cpMin,eax
	.else
		mov		chrg.cpMax,eax
	.endif
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

	invoke SendMessage,ha.hREd,REM_GETWORD,sizeof buffer,addr buffer
	.if buffer
		.if da.fProject
			invoke GetWindowLong,ha.hREd,GWL_USERDATA
			mov		eax,[eax].TABMEM.pid
		.else
			mov		eax,ha.hREd
		.endif
		mov		isinproc.nOwner,eax
		mov		isinproc.lpszType,offset szCCp
		invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,chrg.cpMin,0
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
					invoke SendMessage,ha.hREd,EM_LINEINDEX,nln,0
					mov		ftxt.chrgText.cpMin,eax
					mov		ftxt.chrgText.cpMax,-1
					mov		ftxt.chrg.cpMin,eax
					mov		ftxt.chrg.cpMax,-1
					invoke SendMessage,ha.hREd,EM_FINDTEXTEX,FR_WHOLEWORD or FR_MATCHCASE or FR_DOWN,addr ftxt
					.if eax!=-1
						mov		ftxt.chrg.cpMin,eax
						mov		ftxt.chrg.cpMax,eax
						invoke PushGoto,ha.hREd,chrg.cpMin
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr ftxt.chrg
						invoke SendMessage,ha.hREd,REM_VCENTER,0,0
						invoke SetFocus,ha.hREd
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
				invoke PushGoto,ha.hREd,chrg.cpMin
				invoke SendMessage,ha.hProperty,PRM_FINDGETOWNER,0,0
				.if da.fProject
					push	eax
					invoke TabToolGetInxFromPid,eax
					pop		edx
					.if eax==-1
						;The file is not open
						invoke SendMessage,ha.hPbr,RPBM_FINDITEM,edx,0
						.if eax
							invoke OpenEditFile,addr [eax].PBITEM.szitem,IDC_RAE
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
				invoke SendMessage,ha.hREd,EM_LINEINDEX,eax,0
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,REM_VCENTER,0,0
				invoke SetFocus,ha.hREd
				.break
			.endif
			invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		.endw
	.endif
  Ex:
	ret

GotoDeclare endp

ReturnDeclare proc
	LOCAL	chrg:CHARRANGE

	mov		edx,offset gotostack
	.if [edx].DECLARE.hWin
		invoke TabToolGetInx,[edx].DECLARE.hWin
		invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
		invoke TabToolActivate
		mov		edx,offset gotostack
		mov		eax,[edx].DECLARE.cp
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
		invoke SendMessage,ha.hREd,REM_VCENTER,0,0
		invoke SetFocus,ha.hREd
		invoke PopGoto
	.endif
	ret

ReturnDeclare endp

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

LoadMRU proc uses ebx esi edi,lpKey:DWORD,lpMRU:DWORD

	invoke RtlZeroMemory,offset tmpbuff,sizeof tmpbuff
	mov		lpcbData,sizeof tmpbuff
	invoke RegQueryValueEx,ha.hReg,lpKey,0,addr lpType,addr tmpbuff,addr lpcbData
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
	.while byte ptr [esi]
		push	esi
		.while byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		mov		byte ptr [edi],','
		inc		edi
		pop		esi
		lea		esi,[esi+MAX_PATH]
	.endw
	mov		byte ptr [edi-1],0
	invoke strlen,addr tmpbuff
	inc		eax
	invoke RegSetValueEx,ha.hReg,lpKey,0,REG_SZ,addr tmpbuff,eax
	ret

SaveMRU endp

OpenMRU proc uses ebx esi edi,nID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		ebx,nID
	.if ebx<25100
		sub		ebx,25000
		mov		esi,offset mrufiles
	.else
		sub		ebx,25100
		mov		esi,offset mrusessions
	.endif
	mov		eax,MAX_PATH
	mul		ebx
	lea		esi,[esi+eax]
	invoke strcpy,addr buffer,esi
	invoke OpenEditFile,addr buffer,0
	ret

OpenMRU endp

GetCharType proc nChar:DWORD
	
	mov		eax,nChar
	add		eax,da.lpCharTab
	movzx	eax,byte ptr [eax]
	ret

GetCharType endp
