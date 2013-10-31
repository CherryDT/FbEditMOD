
;AccelEdit.dlg
IDD_DLGACCEL		equ 1300
IDC_GRDACL			equ 1001
IDC_BTNACLADD		equ 1002
IDC_BTNACLDEL		equ 1003

.const

IAclGrdSize			dd 130,40,76,36,36,36,36

.data

szAccelName			db 'IDR_ACCEL',0
defacl				ACCELMEM <,1,0,0,0,<0,0>>
					ACCELMEM <>
.data?

fNoUpdate			dd ?
AclGrdSize			dd 7 dup(?)

.code

ExportAccelNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].ACCELMEM.szname || [esi].ACCELMEM.value
		.if byte ptr [esi].ACCELMEM.szname && [esi].ACCELMEM.value
			invoke ExportName,addr [esi].ACCELMEM.szname,[esi].ACCELMEM.value,edi
			lea		edi,[edi+eax]
		.endif
		add		esi,sizeof ACCELMEM
	.endw
	pop		eax
	ret

ExportAccelNames endp

ExportAccel proc uses esi edi,hMem:DWORD
	LOCAL	fAscii:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.if byte ptr [esi].ACCELMEM.szname
		invoke SaveStr,edi,addr [esi].ACCELMEM.szname
		add		edi,eax
	.else
		invoke SaveVal,[esi].ACCELMEM.value,FALSE
	.endif
	mov		al,' '
	stosb
	invoke SaveStr,edi,offset szACCELERATORS
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.if [esi].ACCELMEM.lang.lang || [esi].ACCELMEM.lang.sublang
		invoke SaveLanguage,addr [esi].ACCELMEM.lang,edi
		add		edi,eax
	.endif
	add		esi,sizeof ACCELMEM
	invoke SaveStr,edi,offset szBEGIN
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.while byte ptr [esi].ACCELMEM.szname || byte ptr [esi].ACCELMEM.value
		mov		al,' '
		stosb
		stosb
		mov		ecx,[esi].ACCELMEM.nkey
		.if ecx
			push	esi
			mov		esi,offset szAclKeys
			.while ecx
				push	ecx
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				pop		ecx
				dec		ecx
			.endw
			movzx	eax,byte ptr [esi]
			pop		esi
			mov		fAscii,FALSE
		.else
			mov		eax,[esi].ACCELMEM.nascii
			mov		fAscii,TRUE
		.endif
		invoke SaveVal,eax,FALSE
		mov		ax,' ,'
		stosw
		.if byte ptr [esi].ACCELMEM.szname
			invoke SaveStr,edi,addr [esi].ACCELMEM.szname
			add		edi,eax
		.else
			invoke SaveVal,[esi].ACCELMEM.value,FALSE
		.endif
		mov		ax,' ,'
		stosw
		.if fAscii
			mov		eax,offset szASCII
		.else
			mov		eax,offset szVIRTKEY
		.endif
		invoke SaveStr,edi,eax
		add		edi,eax
		test	[esi].ACCELMEM.flag,1
		.if !ZERO?
			mov		ax,' ,'
			stosw
			invoke SaveStr,edi,offset szCONTROL
			add		edi,eax
		.endif
		test	[esi].ACCELMEM.flag,2
		.if !ZERO?
			mov		ax,' ,'
			stosw
			invoke SaveStr,edi,offset szSHIFT
			add		edi,eax
		.endif
		test	[esi].ACCELMEM.flag,4
		.if !ZERO?
			mov		ax,' ,'
			stosw
			invoke SaveStr,edi,offset szALT
			add		edi,eax
		.endif
		mov		ax,' ,'
		stosw
		invoke SaveStr,edi,offset szNOINVERT
		add		edi,eax
		mov		ax,0A0Dh
		stosw
		add		esi,sizeof ACCELMEM
	.endw
	invoke SaveStr,edi,offset szEND
	add		edi,eax
	mov		eax,0A0D0A0Dh
	stosd
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportAccel endp

SaveAccelEdit proc uses ebx esi edi,hWin:HWND
	LOCAL	hGrd:HWND
	LOCAL	nRows:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetDlgItem,hWin,IDC_GRDACL
	mov		hGrd,eax
	invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		ebx,eax
	.if !ebx
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_ACCEL,FALSE
		mov		ebx,eax
		invoke RtlMoveMemory,[ebx].PROJECT.hmem,offset defacl,sizeof ACCELMEM*2
	.endif
	push	ebx
	invoke GetProjectItemName,ebx,addr buffer
	invoke SetProjectItemName,ebx,addr buffer
	mov		edi,[ebx].PROJECT.hmem
	add		edi,sizeof ACCELMEM
	xor		esi,esi
	.while esi<nRows
		;Name
		mov		ecx,esi
		shl		ecx,16
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		invoke strcpy,addr [edi].ACCELMEM.szname,addr buffer
		;ID
		mov		ecx,esi
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		mov		eax,dword ptr buffer
		mov		[edi].ACCELMEM.value,eax
		;Key
		mov		ecx,esi
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		mov		eax,dword ptr buffer
		mov		[edi].ACCELMEM.nkey,eax
		;Ascii
		mov		ecx,esi
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		movzx	eax,byte ptr buffer
		mov		[edi].ACCELMEM.nascii,eax
		xor		ebx,ebx
		;Ctrl
		mov		ecx,esi
		shl		ecx,16
		add		ecx,4
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if dword ptr buffer
			or		ebx,1
		.endif
		;Shift
		mov		ecx,esi
		shl		ecx,16
		add		ecx,5
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if dword ptr buffer
			or		ebx,2
		.endif
		;Alt
		mov		ecx,esi
		shl		ecx,16
		add		ecx,6
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if dword ptr buffer
			or		ebx,4
		.endif
		mov		[edi].ACCELMEM.flag,ebx
		add		edi,sizeof ACCELMEM
		inc		esi
	.endw
	xor		eax,eax
	mov		[edi].ACCELMEM.szname,al
	mov		[edi].ACCELMEM.value,eax
	mov		[edi].ACCELMEM.nkey,eax
	mov		[edi].ACCELMEM.flag,eax
	pop		eax
	ret

SaveAccelEdit endp

AccelEditProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	col:COLUMN
	LOCAL	row[7]:DWORD
	LOCAL	val:DWORD
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke InitGridSize,7,offset IAclGrdSize,offset AclGrdSize
		mov		fChanged,FALSE
		invoke GetDlgItem,hWin,IDC_GRDACL
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
		mov		eax,AclGrdSize
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITCOMBOBOX
		mov		col.ctextmax,MaxName-1
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		invoke GetWindowLong,hPrj,0
		mov		esi,eax
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_MENU && ![esi].PROJECT.delete
				push	esi
				mov		esi,[esi].PROJECT.hmem
				lea		esi,[esi+sizeof MNUHEAD]
				.while [esi].MNUITEM.itemflag
					.if [esi].MNUITEM.itemname
						invoke SendMessage,hGrd,GM_COMBOFINDSTRING,0,addr [esi].MNUITEM.itemname
						.if eax==-1
							invoke SendMessage,hGrd,GM_COMBOADDSTRING,0,addr [esi].MNUITEM.itemname
						.endif
					.endif
					lea		esi,[esi+sizeof MNUITEM]
				.endw
				pop		esi
			.elseif [esi].PROJECT.ntype==TPE_ACCEL && ![esi].PROJECT.delete
				push	esi
				mov		esi,[esi].PROJECT.hmem
				lea		esi,[esi+sizeof ACCELMEM]
				.while [esi].ACCELMEM.szname || [esi].ACCELMEM.value
					.if [esi].ACCELMEM.szname
						invoke SendMessage,hGrd,GM_COMBOFINDSTRING,0,addr [esi].ACCELMEM.szname
						.if eax==-1
							invoke SendMessage,hGrd,GM_COMBOADDSTRING,0,addr [esi].ACCELMEM.szname
						.endif
					.endif
					lea		esi,[esi+sizeof ACCELMEM]
				.endw
				pop		esi
			.endif
			lea		esi,[esi+sizeof PROJECT]
		.endw
		;ID
		mov		eax,AclGrdSize[4]
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
		;Keys
		mov		eax,AclGrdSize[8]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrKey
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_COMBOBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Fill Keys in the combo
		mov		esi,offset szAclKeys
		.while byte ptr [esi]
			inc		esi
			invoke SendMessage,hGrd,GM_COMBOADDSTRING,2,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		;Ascii
		mov		eax,AclGrdSize[12]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrAscii
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,1
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Ctrl
		mov		eax,AclGrdSize[16]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrCtrl
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Shift
		mov		eax,AclGrdSize[20]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrShift
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Alt
		mov		eax,AclGrdSize[24]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrAlt
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if !esi
			invoke GetFreeProjectitemID,TPE_ACCEL
			mov		esi,offset defacl
			mov		[esi].ACCELMEM.value,eax
			invoke strcpy,addr [esi].ACCELMEM.szname,addr szAccelName
			invoke GetUnikeName,addr [esi].ACCELMEM.szname
			invoke SaveAccelEdit,hWin
			mov		esi,eax
			invoke SetWindowLong,hWin,GWL_USERDATA,esi
			mov		fChanged,TRUE
		.endif
		mov		esi,[esi].PROJECT.hmem
		mov		lpResType,offset szACCELERATORS
		lea		eax,[esi].ACCELMEM.szname
		mov		lpResName,eax
		lea		eax,[esi].ACCELMEM.value
		mov		lpResID,eax
		lea		eax,[esi].ACCELMEM.lang
		mov		lpResLang,eax
		add		esi,sizeof ACCELMEM
		.while [esi].ACCELMEM.szname || [esi].ACCELMEM.value
			lea		eax,[esi].ACCELMEM.szname
			mov		row,eax
			mov		eax,[esi].ACCELMEM.value
			mov		row[4],eax
			mov		eax,[esi].ACCELMEM.nkey
			mov		row[8],eax
			mov		eax,[esi].ACCELMEM.nascii
			mov		val,eax
			.if eax
				lea		eax,val
			.endif
			mov		row[12],eax
			xor		eax,eax
			mov		row[16],eax
			mov		row[20],eax
			mov		row[24],eax
			mov		eax,[esi].ACCELMEM.flag
			shr		eax,1
			rcl		row[16],1
			shr		eax,1
			rcl		row[20],1
			shr		eax,1
			rcl		row[24],1
			invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			add		esi,sizeof ACCELMEM
		.endw
		invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		invoke PropertyList,-4
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDACL
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrd,GM_GETCURSEL,0,0
				.if ax<4
					invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
				.endif
				invoke SaveAccelEdit,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNACLADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNACLDEL
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
		invoke GetDlgItem,hWin,IDC_GRDACL
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BEFOREEDIT
				.if [esi].GRIDNOTIFY.col==3
					mov		ecx,[esi].GRIDNOTIFY.row
					shl		ecx,16
					add		ecx,2
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
					.if dword ptr val
						mov		[esi].GRIDNOTIFY.fcancel,TRUE
					.endif
				.endif
			.elseif eax==GN_BEFOREUPDATE
				.if [esi].GRIDNOTIFY.col==0
					invoke CheckName,[esi].GRIDNOTIFY.lpdata
					.if eax
						mov		[esi].GRIDNOTIFY.fcancel,TRUE
					.endif
				.endif
			.elseif eax==GN_AFTERUPDATE
				.if [esi].GRIDNOTIFY.col==2 && !fNoUpdate
					mov		ecx,[esi].GRIDNOTIFY.row
					shl		ecx,16
					add		ecx,2
					push	ecx
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
					pop		ecx
					.if dword ptr val
						inc		ecx
						mov		fNoUpdate,TRUE
						invoke SendMessage,hGrd,GM_SETCELLDATA,ecx,NULL
						mov		fNoUpdate,FALSE
					.endif
				.endif
				mov		fDialogChanged,TRUE
				invoke NotifyParent
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke GetDlgItem,hWin,IDC_GRDACL
		mov		hGrd,eax
		invoke SaveGrdSize,hGrd,7,offset AclGrdSize
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
		invoke GetDlgItem,hWin,IDC_BTNACLADD
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3,64,22,TRUE
		invoke GetDlgItem,hWin,IDC_BTNACLDEL
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6,64,22,TRUE
		invoke GetDlgItem,hWin,IDC_GRDACL
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

AccelEditProc endp
