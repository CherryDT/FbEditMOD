
;IncludeEdit.dlg
IDD_DLGINCLUDE		equ 1000
IDC_GRDINC			equ 1001
IDC_BTNINCADD		equ 1002
IDC_BTNINCDEL		equ 1003

.const

IIncGrdSize		dd 370

.data?

IncGrdSize		dd 1 dup(?)

.code

ExportInclude proc uses esi edi,hMem:DWORD

	mov		fResourceh,FALSE
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].INCLUDEMEM.szfile
		invoke strcmpi,offset szResourceh,addr [esi].INCLUDEMEM.szfile
		.if !eax
			mov		fResourceh,TRUE
		.endif
		invoke SaveStr,edi,offset szINCLUDE
		add		edi,eax
		mov		al,' '
		stosb
		.if [esi].INCLUDEMEM.szfile!='<'
			mov		al,'"'
			stosb
		.endif
		xor		ecx,ecx
		.while byte ptr [esi+ecx].INCLUDEMEM.szfile
			mov		al,[esi+ecx].INCLUDEMEM.szfile
			.if al=='\'
				mov		al,'/'
			.endif
			mov		[edi],al
			inc		ecx
			inc		edi
		.endw
		.if [esi].INCLUDEMEM.szfile!='<'
			mov		al,'"'
			stosb
		.endif
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		add		esi,sizeof INCLUDEMEM
	.endw
	mov		ax,0A0Dh
	stosw
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportInclude endp

SaveIncludeEdit proc uses esi edi,hWin:HWND
	LOCAL	hGrd:HWND
	LOCAL	nRows:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetDlgItem,hWin,IDC_GRDINC
	mov		hGrd,eax
	invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	.if !eax
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_INCLUDE,FALSE
	.endif
	push	eax
	mov		edi,[eax].PROJECT.hmem
	xor		esi,esi
	.while esi<nRows
		;File
		mov		ecx,esi
		shl		ecx,16
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if buffer
			invoke strcpy,addr [edi].INCLUDEMEM.szfile,addr buffer
			add		edi,sizeof INCLUDEMEM
		.endif
		inc		esi
	.endw
	mov		[edi].INCLUDEMEM.szfile,0
	pop		eax
	ret

SaveIncludeEdit endp

IncludeEditProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	col:COLUMN
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke InitGridSize,1,offset IIncGrdSize,offset IncGrdSize
		mov		fChanged,FALSE
		invoke GetDlgItem,hWin,IDC_GRDINC
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
		;File
		mov		eax,IncGrdSize
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrFileName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITBUTTON
		mov		col.ctextmax,MAX_PATH
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if esi
			mov		esi,[esi].PROJECT.hmem
			.while [esi].INCLUDEMEM.szfile
				lea		eax,[esi].INCLUDEMEM.szfile
				mov		dword ptr buffer,eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr buffer
				add		esi,sizeof INCLUDEMEM 
			.endw
			invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		.else
			invoke SaveIncludeEdit,hWin
			invoke SetWindowLong,hWin,GWL_USERDATA,eax
			mov		fChanged,TRUE
		.endif
		invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
		invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,offset szINCLUDE
		invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,0,0
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDINC
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrd,GM_GETCURSEL,0,0
				invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
				invoke SaveIncludeEdit,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNINCADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNINCDEL
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
		invoke GetDlgItem,hWin,IDC_GRDINC
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		eax,[esi].GRIDNOTIFY.lpdata
				.if byte ptr [eax]
					invoke strcpy,addr buffer,[esi].GRIDNOTIFY.lpdata
					.if buffer=='<'
						lea		edx,buffer
						mov		eax,edx
						inc		eax
						.while byte ptr [eax]
							mov		cl,[eax]
							.if cl=='>'
								mov		cl,0
							.endif
							mov		[edx],cl
							inc		eax
							inc		edx
						.endw
						mov		byte ptr [edx],0
						.if szSystemPath
							invoke strcpy,addr buffer1,addr szSystemPath
							invoke strcat,addr buffer1,addr szBS
							invoke strcat,addr buffer1,addr buffer
							invoke strcpy,addr buffer,addr buffer1
							mov		ofn.lpstrInitialDir,offset szSystemPath
						.endif
					.endif
				.else
					mov		buffer,0
				.endif
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke RemovePath,addr buffer,addr szProjectPath
					lea		edx,buffer
					.if eax==edx
						invoke RemovePath,addr buffer,addr szSystemPath
						lea		edx,buffer
						.if eax!=edx
							mov		word ptr buffer,'<'
							invoke strcat,edx,eax
							invoke strlen,addr buffer
							mov		word ptr buffer[eax],'>'
							lea		eax,buffer
						.endif
					.endif
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke strcpy,edx,eax
					mov		[esi].GRIDNOTIFY.fcancel,FALSE
				.else
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			.elseif eax==GN_AFTERUPDATE
				mov		fDialogChanged,TRUE
				invoke NotifyParent
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke GetDlgItem,hWin,IDC_GRDINC
		mov		hGrd,eax
		invoke SaveGrdSize,hGrd,1,offset IncGrdSize
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
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
		.if rect.right<470
			mov		rect.right,470
		.endif
		invoke GetDlgItem,hWin,IDC_BTNINCADD
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3,64,22,TRUE
		invoke GetDlgItem,hWin,IDC_BTNINCDEL
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6,64,22,TRUE
		invoke GetDlgItem,hWin,IDC_GRDINC
		mov		hGrd,eax
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,3+64+6
		sub		rect.bottom,6
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

IncludeEditProc endp
