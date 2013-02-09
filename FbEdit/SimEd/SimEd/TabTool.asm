.code

TabToolGetMem proc uses ebx,hWin:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.break .if eax==hWin
		.endif
	.endw
	mov		eax,ebx
	ret

TabToolGetMem endp

TabToolGetInx proc uses ebx,hWin:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.break .if eax==hWin
		.endif
	.endw
	mov		eax,nInx
	ret

TabToolGetInx endp

TabToolSetText proc nInx:DWORD,lpFileName:DWORD
	LOCAL	tci:TCITEM

	invoke lstrlen,lpFileName
	mov		ecx,eax
	mov		edx,lpFileName
	.while ecx
		mov		al,[edx+ecx-1]
		.break .if al=='\'
		dec		ecx
	.endw
	lea		eax,[edx+ecx]
	mov		tci.pszText,eax
	mov		tci.imask,TCIF_TEXT
	invoke SendMessage,hTab,TCM_SETITEM,nInx,addr tci
	ret

TabToolSetText endp

TabToolActivate proc uses ebx
	LOCAL	tci:TCITEM

	invoke SendMessage,hTab,TCM_GETCURSEL,0,0
	mov		tci.imask,TCIF_PARAM
	mov		edx,eax
	invoke SendMessage,hTab,TCM_GETITEM,edx,addr tci
	invoke ShowWindow,hREd,SW_HIDE
	mov		ebx,tci.lParam
	mov		eax,[ebx].TABMEM.hwnd
	mov		hREd,eax
	invoke lstrcpy,offset FileName,addr [ebx].TABMEM.filename
	invoke SetWinCaption,offset FileName
	invoke SendMessage,hWnd,WM_SIZE,0,0
	invoke ShowWindow,hREd,SW_SHOW
	invoke SetFocus,hREd
	invoke RefreshCombo,hREd
	ret

TabToolActivate endp

TabToolAdd proc uses ebx,hWin:HWND,lpFileName:DWORD
	LOCAL	tci:TCITEM

	mov		tci.imask,TCIF_TEXT or TCIF_PARAM
	invoke lstrlen,lpFileName
	mov		ecx,eax
	mov		edx,lpFileName
	.while ecx
		mov		al,[edx+ecx-1]
		.break .if al=='\'
		dec		ecx
	.endw
	mov		tci.imask,TCIF_TEXT or TCIF_PARAM
	lea		eax,[edx+ecx]
	mov		tci.pszText,eax
	mov		tci.cchTextMax,20
	mov		eax,hWin
	invoke GetProcessHeap
	invoke HeapAlloc,eax,NULL,sizeof TABMEM
	mov		ebx,eax
	mov		eax,hWin
	mov		[ebx].TABMEM.hwnd,eax
	invoke lstrcpy,addr [ebx].TABMEM.filename,lpFileName
	mov		tci.lParam,ebx
	invoke SendMessage,hTab,TCM_INSERTITEM,999,addr tci
	invoke SendMessage,hTab,TCM_SETCURSEL,eax,0
	ret

TabToolAdd endp

TabToolDel proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.if eax==hWin
				invoke SendMessage,hTab,TCM_DELETEITEM,nInx,0
				invoke GetProcessHeap
				invoke HeapFree,eax,NULL,ebx
				xor eax,eax
			.endif
		.endif
	.endw
	invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
	.if !eax
		invoke CreateNew
		mov		nInx,0
	.endif
  @@:
	invoke SendMessage,hTab,TCM_SETCURSEL,nInx,0
	invoke SendMessage,hTab,TCM_GETCURSEL,0,0
	.if eax==-1
		dec		nInx
		jmp		@b
	.endif
	invoke TabToolActivate
	ret

TabToolDel endp

