
;StringEdit.dlg
IDD_DLGSTRING							equ 1200
IDC_GRDSTR								equ 1001
IDC_BTNSTRADD							equ 1002
IDC_BTNSTRDEL							equ 1003

;.data?

;strlng				LANGUAGEMEM <>

.code

ExportStringNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].STRINGMEM.szname || [esi].STRINGMEM.value
		.if byte ptr [esi].STRINGMEM.szname && [esi].STRINGMEM.value
			invoke SaveStr,edi,offset szDEFINE
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveStr,edi,addr [esi].STRINGMEM.szname
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveVal,[esi].STRINGMEM.value,FALSE
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
		.endif
		add		esi,sizeof STRINGMEM
	.endw
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportStringNames endp

ExportString proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	invoke SaveStr,edi,offset szSTRINGTABLE
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,offset szDISCARDABLE
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	.if [esi].STRINGMEM.lang.lang || [esi].STRINGMEM.lang.sublang
		invoke SaveLanguage,addr [esi].STRINGMEM.lang,edi
		add		edi,eax
	.endif
	invoke SaveStr,edi,offset szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	.while byte ptr [esi].STRINGMEM.szname || [esi].STRINGMEM.value
		mov		al,' '
		stosb
		stosb
		.if byte ptr [esi].STRINGMEM.szname
			invoke SaveStr,edi,addr [esi].STRINGMEM.szname
			add		edi,eax
		.else
			invoke SaveVal,[esi].STRINGMEM.value,FALSE
		.endif
		mov		al,' '
		stosb
		mov		al,'"'
		stosb
		xor		ecx,ecx
		.while byte ptr [esi+ecx].STRINGMEM.szstring
			mov		al,[esi+ecx].STRINGMEM.szstring
			.if al=='"'
				mov		[edi],al
				inc		edi
			.endif
			mov		[edi],al
			inc		ecx
			inc		edi
		.endw
		mov		al,'"'
		stosb
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		add		esi,sizeof STRINGMEM
	.endw
	invoke SaveStr,edi,offset szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportString endp

SaveStringEdit proc uses esi edi,hWin:HWND
	LOCAL	hGrd:HWND
	LOCAL	nRows:DWORD
	LOCAL	buffer[512]:BYTE

	invoke GetDlgItem,hWin,IDC_GRDSTR
	mov		hGrd,eax
	invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	.if !eax
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_STRING,FALSE
	.endif
	push	eax
	mov		edi,[eax].PROJECT.hmem
	xor		esi,esi
	.while esi<nRows
		;Name
		mov		ecx,esi
		shl		ecx,16
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		invoke strcpy,addr [edi].STRINGMEM.szname,addr buffer
		;ID
		mov		ecx,esi
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		mov		eax,dword ptr buffer
		mov		[edi].STRINGMEM.value,eax
		;String
		mov		ecx,esi
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		invoke strcpy,addr [edi].STRINGMEM.szstring,addr buffer
		.if [edi].STRINGMEM.szname || [edi].STRINGMEM.value
			add		edi,sizeof STRINGMEM
		.endif
		inc		esi
	.endw
	xor		eax,eax
	mov		[edi].STRINGMEM.szname,al
	mov		[edi].STRINGMEM.value,eax
	mov		[edi].STRINGMEM.szstring,al
	pop		eax
	ret

SaveStringEdit endp

StringEditProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	col:COLUMN
	LOCAL	row[3]:DWORD
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		fChanged,FALSE
		invoke GetDlgItem,hWin,IDC_GRDSTR
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,color.back,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,color.text,0
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;Name
		invoke ConvertDpiSize,100
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,MaxName-1
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;ID
		invoke ConvertDpiSize,40
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrID
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,5
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;String
		invoke ConvertDpiSize,230
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrString
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,511
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if !esi
			invoke SaveStringEdit,hWin
			mov		esi,eax
			invoke SetWindowLong,hWin,GWL_USERDATA,esi
			mov		fChanged,TRUE
		.endif
		mov		esi,[esi].PROJECT.hmem
		mov		lpResType,offset szSTRINGTABLE
		lea		eax,[esi].STRINGMEM.lang
		mov		lpResLang,eax
		.while [esi].STRINGMEM.szname || [esi].STRINGMEM.value
			lea		eax,[esi].STRINGMEM.szname
			mov		row[0],eax
			mov		eax,[esi].STRINGMEM.value
			mov		row[4],eax
			lea		eax,[esi].STRINGMEM.szstring
			mov		row[8],eax
			invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			add		esi,sizeof STRINGMEM 
		.endw
		invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		invoke PropertyList,-5
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDSTR
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrd,GM_GETCURSEL,0,0
				invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
				invoke SaveStringEdit,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNSTRADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNSTRDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				invoke NotifyParent
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDSTR
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_AFTERUPDATE
				mov		fDialogChanged,TRUE
				invoke NotifyParent
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		;invoke EndDialog,hWin,wParam
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_GRDSTR
		mov		hGrd,eax
		mov		rect.left,3
		mov		rect.top,3
		mov		rect.right,397
		sub		rect.bottom,6
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

StringEditProc endp
